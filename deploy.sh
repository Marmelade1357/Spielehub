#!/bin/bash
# Deploy-Skript für "Spielehub" auf dem Raspberry Pi (duckpi).
# Holt den neuesten Stand von GitHub und baut/startet den Container neu.
#
# Einmalig ausführbar machen:
#   chmod +x deploy.sh
#
# Aufruf (im Projektordner, z.B. ~/spielehub):
#   ./deploy.sh
#
# Wichtig: Widerstand und Wizard müssen bereits laufen (127.0.0.1:8092 bzw.
# 127.0.0.1:8093), sonst zeigt der Hub für die jeweilige Kachel einen Fehler.

set -e  # bei jedem Fehler sofort abbrechen

echo "==> Hole neuesten Stand von GitHub ..."
git pull

echo "==> Baue und starte Container neu ..."
docker compose up -d --build

echo "==> Fertig. Aktueller Status:"
docker compose ps

echo ""
echo "Logs ansehen mit: docker compose logs -f   (Beenden mit Strg+C)"
