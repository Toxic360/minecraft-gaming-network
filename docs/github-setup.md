# GitHub für Backups einrichten

Du möchtest Backups von deinem Minecraft-Server auf GitHub ablegen, damit der
Server auf dem VPS (oder jederzeit) wiederhergestellt werden kann.

## Sofort (ohne Login-Daten)

1. Repositories mit dem Backup-Ordner lokal initialisieren
2. `.gitignore` und `backup.sh` konfigurieren
3. README und Dokumentation vorbereiten

## Sobald du die Login-Daten gibst

1. `gh auth login` → GitHub-Account eintragen (HTTPS oder SSH)
2. `gh repo create minecraft-gaming-network --private` erzeugt das nebenliegende
   GitHub-Repo
3. `git push -u origin main` lässt alles im Cloud-Repo landen

## Was danach im Repo landet

| Ordner | Inhalt | Gepusht |
|---|---|---|
| `server/config/` | server.properties, ops.json, … | ✅ |
| `docs/` | Setup-Dokumentation | ✅ |
| `backup/*.sh` | Backup-Skript | ✅ |
| `server/world/` | Weltdaten | ❌ (zu groß, ignoriert) |
| `server/*.log` | Logs | ❌ (ignoriert) |

## Danach

- Cron/Journal dient die Ausführung des Backup-Skripts
- Die Backups landen alle 1–24 h auf GitHub
- Der Server startet von der letzten Backup kopie wieder her

---

Die Login-Daten geben wir dir später. Soll ich vorbereiten, was dann beim
Login folgt? (Nur `gh auth login` + SSH-Key übrig)
