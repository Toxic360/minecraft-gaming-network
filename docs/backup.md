# Backup-Dokumentation

## Backup-Skript

Das Skript `backup/backup.sh` erstellt tar-Archivdateien des Serverordners:

```
server/
├── config/      # server.properties, ops.json, whitelist.json, …
├── world/       # Weltdaten
└── plugins/     # Plugins
```

## Nutzung (auf dem VPS)

```bash
bash backup/backup.sh --keep 14
bash backup/backup.sh --clean --keep 30
```

## GitHub-Repo

Nachdem du dich bei GitHub angemeldet hast:

```bash
cd minecraft-gaming-network
git init
git add .
git commit -m "Initiale Struktur und Backup-Skript"
git branch -M main
git remote add origin git@github.com:<nutzername>/<repo>.git
git push -u origin main
```

## Ruhestand-Plan

Die Endlosschleife des Backups läuft auf dem VPS (z. B. via systemd/cron).
Das Repository bleibt als sichere Kopie der Konfiguration und Artefakte.

## Login-Daten

Bei Bedarf später übermitteln – `gh auth login` + SSH-Key.
