#!/usr/bin/env bash
# -------------------------------------------------------------------
# backup.sh – Minecraft-Server-Backup auf GitHub (VPS oder Desktop)
# -------------------------------------------------------------------
# Nutzung:
#   bash backup.sh [--clean] [--keep N]
#
# --clean : alte Backups (> 7 Tage) löschen
# --keep N: behalte N neueste Backups (Standard 14)
# -------------------------------------------------------------------

set -euo pipefail

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(dirname "$BACKUP_DIR")/server"
REPO_DIR="$(dirname "$BACKUP_DIR")"
ARCHIVE_DIR="$BACKUP_DIR/backups"
KEEP="${2:-14}"          # --keep N über Argument 2
CLEAN=false

# Argumente parsen
for arg in "$@"; do
  case "$arg" in
    --clean) CLEAN=true ;;
    --keep)  shift; KEEP="${1:-14}" ;;
  esac
done

# Ziel-Archiv
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE="$ARCHIVE_DIR/server_${TIMESTAMP}.tar.gz"
mkdir -p "$ARCHIVE_DIR"

echo "[backup] Starte Backup: $ARCHIVE"

# Falls der Server noch nicht existiert, Abbruch
if [[ ! -d "$SERVER_DIR" ]]; then
  echo "[backup] Hinweis: server/ existiert noch nicht – kein Backup."
  exit 0
fi

# Archiv erstellen (exclude vor den Dateien)
tar -czf "$ARCHIVE" -C "$SERVER_DIR" \
  --exclude='logs/*' \
  --exclude='*.log' \
  config \
  world \
  plugins

SIZE=$(du -h "$ARCHIVE" | cut -f1)
echo "[backup] Archiv erstellt: $SIZE"

# Komprimiere mit gzip (vorsichtig: tar -czf bereits komprimiert)
if [[ "$KEEP" != "0" ]]; then
  # Bestehende Backups sortiert + alte löschen
  ls -1t "$ARCHIVE_DIR"/server_*.tar.gz 2>/dev/null | tail -n +$((KEEP+1)) | while read -r OLD; do
    echo "[backup] Lösche alt: $(basename "$OLD")"
    rm -f "$OLD"
  done
fi

if $CLEAN; then
  find "$ARCHIVE_DIR" -name 'server_*.tar.gz' -mtime +7 -delete
  echo "[backup] Luxusbackups (>7 Tage) gelöscht"
fi

echo "[backup] Fertig – $ARCHIVE"
