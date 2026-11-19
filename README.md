# minecraft-gaming-network

Minecraft-Netzwerk (Crossplay) – Freebuild, Citybuild, Minispiele auf VPS.
Dieses Repository enthält die **Backups und Konfiguration** für den Server.

## Struktur

```text
minecraft-gaming-network/
├── .gitignore                     # Welche Dateien verworfen werden
├── README.md                      # Projektübersicht
├── server/
│   ├── config/                    # server.properties, ops.json, whitelist.json …
│   └── world/                     # Weltdaten (ignoriert – zu groß)
├── backup/
│   ├── backup.sh                  # Backup-Skript (läuft auf dem VPS)
│   ├── backups/                   # Backup-Archive (lokal, nicht gepusht)
│   └── README.md                  # Backup-Dokumentation
└── docs/
    ├── backup.md                  # Backup-Doku
    └── github-setup.md            # GitHub-Autorisierung
```

## Backup-Strategie

- **Was wird gepusht:** `config/`, `backup/` (Artefakte), `docs/`, `.gitignore`
- **Was wird ignoriert:** `world/` (zu groß, ändert sich ständig),
  `server.jar`, `logs/`, `build/`, `*.log`, temporär-Dateien
- **Wohin:** GitHub (SSH/HTTPS) – sichere Kopie vom VPS
- **Häufigkeit:** Täglich (oder nach jedem Schritt über den Server)
