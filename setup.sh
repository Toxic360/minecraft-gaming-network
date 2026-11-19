#!/usr/bin/env bash
# Gaming Netzwerk — Einrichtung auf dem VPS (Ubuntu/Debian).
# Aufruf:  bash setup.sh            startet Proxy + Lobby + Freebuild + Citybuild
#          bash setup.sh --minigames  startet zusaetzlich den Minispiel-Server
set -euo pipefail
cd "$(dirname "$0")"

echo "== Gaming Netzwerk Setup =="

command -v docker >/dev/null 2>&1 || {
  echo "Docker fehlt. Installieren mit:  curl -fsSL https://get.docker.com | sh"
  exit 1
}
docker compose version >/dev/null 2>&1 || {
  echo "Das docker-compose-Plugin fehlt (docker compose version)."
  exit 1
}

# --- .env anlegen und Geheimnisse erzeugen ---
[ -f .env ] || cp .env.example .env
set -a; . ./.env; set +a

gen_secret() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 24
  else
    head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n'
  fi
}
FORWARDING_SECRET="${FORWARDING_SECRET:=$(gen_secret)}"
RCON_PASSWORD="${RCON_PASSWORD:=$(gen_secret)}"
LP_DB_PASSWORD="${LP_DB_PASSWORD:=$(gen_secret)}"

cat > .env <<EOF
DOMAIN=${DOMAIN:-play.example.de}
FORWARDING_SECRET=${FORWARDING_SECRET}
RCON_PASSWORD=${RCON_PASSWORD}
LP_DB_PASSWORD=${LP_DB_PASSWORD}
EOF

# --- Verzeichnisse ---
mkdir -p rendered velocity \
  data/proxy data/lobby data/freebuild data/citybuild data/minigames data/mariadb \
  servers/lobby servers/freebuild servers/citybuild servers/minigames

# --- Forwarding-Secret (Proxy) ---
printf '%s' "$FORWARDING_SECRET" > velocity/forwarding.secret
chmod 600 velocity/forwarding.secret

# --- paper-global.yml je Backend rendern ---
for s in lobby freebuild citybuild minigames; do
  sed "s/__FORWARDING_SECRET__/${FORWARDING_SECRET}/g" templates/paper-global.yml > "servers/$s/paper-global.yml"
done

# --- LuckPerms-Konfiguration (gemeinsame MariaDB) ---
sed "s/__LP_DB_PASSWORD__/${LP_DB_PASSWORD}/g" templates/luckperms-config.yml > rendered/luckperms-config.yml

# --- Geyser/Floodgate auf dem Proxy vorkonfigurieren ---
mkdir -p data/proxy/plugins/Geyser-Velocity data/proxy/plugins/floodgate
if [ ! -f data/proxy/plugins/Geyser-Velocity/config.yml ]; then
  cp templates/geyser-config.yml data/proxy/plugins/Geyser-Velocity/config.yml
fi
if [ ! -f data/proxy/plugins/floodgate/config.yml ]; then
  cp templates/floodgate-proxy-config.yml data/proxy/plugins/floodgate/config.yml
fi

# --- Proxy + DB zuerst starten (Floodgate erzeugt key.pem) ---
docker compose up -d mariadb proxy

echo "Warte auf Floodgate-Schluessel (key.pem)..."
for _ in $(seq 1 90); do
  [ -f data/proxy/plugins/floodgate/key.pem ] && break
  sleep 2
done
if [ ! -f data/proxy/plugins/floodgate/key.pem ]; then
  echo "key.pem nicht erschienen. Proxy-Logs pruefen:  docker compose logs proxy"
  exit 1
fi

# --- key.pem auf alle Backends verteilen (binary-safe) ---
for s in lobby freebuild citybuild minigames; do
  mkdir -p "data/$s/plugins/floodgate"
  cp data/proxy/plugins/floodgate/key.pem "data/$s/plugins/floodgate/key.pem"
done

# --- Rest starten ---
if [ "${1:-}" = "--minigames" ]; then
  docker compose --profile minigames up -d
else
  docker compose up -d
fi

echo
docker compose ps
echo
echo "== Fertig =="
echo "Java:      SERVER-IP:25565"
echo "Bedrock:   SERVER-IP, Port 19132"
echo "Webkarte:  http://SERVER-IP:8100 (BlueMap, Freebuild)"
echo
echo "Naechste Schritte:"
echo "  1. Firewall:  sudo ufw allow 25565/tcp && sudo ufw allow 19132/tcp && sudo ufw allow 19132/udp && sudo ufw allow 19133/udp"
echo "  2. Admin-Rechte:  docker compose attach proxy   (Konsole: 'op <Name>' gibt es erst auf dem Backend;"
echo "     besser: docker compose exec lobby rcon-cli op <Name>)"
echo "  3. Citybuild:  im Spiel auf dem Citybuild-Server '/plot setup' ausfuehren"
echo "  4. Details:  README.md"
