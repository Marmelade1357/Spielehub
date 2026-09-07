# Spielehub

Eine einzige Landingpage (`games.oualid.de`) mit zwei Kacheln, die zu den beiden eigenständigen Spiele-Servern führen:

- **🕵️ Der Widerstand** → `/widerstand/` → proxied zu `127.0.0.1:8092` (eigener Container, siehe `../Widerstand`)
- **🧙 Wizard** → `/wizard/` → proxied zu `127.0.0.1:8093` (eigener Container, siehe `../Wizard`)

So muss nur eine Subdomain/Adresse eingerichtet und geteilt werden, obwohl beide Spiele technisch komplett unabhängige Node-Server bleiben (eigene Docker-Container, eigenes Deployment, eigene Tests) - der Hub ist nur ein schlanker nginx-Reverse-Proxy plus die statische Startseite.

## Wie es funktioniert

nginx terminiert auf Port 8094 (per `network_mode: host`, damit `127.0.0.1:8092`/`8093` der beiden anderen Container erreichbar sind) und:

1. liefert unter `/` die statische Startseite (`public/index.html`) aus,
2. leitet alles unter `/widerstand/*` an `127.0.0.1:8092` weiter (inkl. WebSocket-Upgrade für Socket.IO),
3. leitet alles unter `/wizard/*` an `127.0.0.1:8093` weiter (inkl. WebSocket-Upgrade),
4. schneidet dabei jeweils das Präfix (`/widerstand` bzw. `/wizard`) ab, bevor die Anfrage beim jeweiligen Spiel-Server ankommt - die beiden Spiele "wissen" also gar nichts von diesem Hub.

Damit das funktioniert, mussten beide Spiele minimal angepasst werden: Der Socket.IO-Client (`public/client.js`) ermittelt jetzt automatisch aus der aktuellen Browser-URL, unter welchem Pfad-Präfix er gerade läuft, und verbindet sich entsprechend. Bei direktem Zugriff (z. B. weiterhin `wd.oualid.de` ohne Hub) ist das Präfix leer und es ändert sich nichts am bisherigen Verhalten - beide Zugriffswege funktionieren parallel.

## Voraussetzung

Widerstand und Wizard müssen als eigene Container bereits laufen (`127.0.0.1:8092` bzw. `127.0.0.1:8093`), bevor der Hub gestartet wird - er leitet nur weiter, hostet die Spiele nicht selbst.

## Deployment (Raspberry Pi)

```bash
./deploy.sh
```

Danach auf dem bestehenden Reverse Proxy des Pi die Subdomain `games.oualid.de` auf `127.0.0.1:8094` routen (genau wie `wd.oualid.de` → 8092).

## Lokal testen

```bash
docker compose up --build
# http://localhost:8094/          -> Startseite
# http://localhost:8094/widerstand/
# http://localhost:8094/wizard/
```
