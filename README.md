# Spielehub

Eine einzige Landingpage (`games.oualid.de`) mit Kacheln, die zu den eigenständigen Spiele-Servern führen:

- **🕵️ Der Widerstand** → `/widerstand/` → proxied zu `127.0.0.1:8092` (eigener Container, siehe `../Widerstand`)
- **🧙 Wizard** → `/wizard/` → proxied zu `127.0.0.1:8093` (eigener Container, siehe `../Wizard`)
- **🃏 Bluff** → `/bluff/` → proxied zu `127.0.0.1:8095` (eigener Container, siehe `../Bluff`)
- **🗿 Tempel des Schreckens** → `/tempel/` → proxied zu `127.0.0.1:8096` (eigener Container, siehe `../TempelDesSchreckens`)
- **♠️ Poker** → `/poker/` → proxied zu `127.0.0.1:8097` (eigener Container, siehe `../Poker`)
- **🚪 Munchkin** → `/munchkin/` → proxied zu `127.0.0.1:8098` (eigener Container, siehe `../Munchkin`)

So muss nur eine Subdomain/Adresse eingerichtet und geteilt werden, obwohl alle Spiele technisch komplett unabhängige Node-Server bleiben (eigene Docker-Container, eigenes Deployment, eigene Tests) - der Hub ist nur ein schlanker nginx-Reverse-Proxy plus die statische Startseite.

## Wie es funktioniert

nginx terminiert auf Port 8094 (per `network_mode: host`, damit `127.0.0.1:8092`-`8098` der anderen Container erreichbar sind) und:

1. liefert unter `/` die statische Startseite (`public/index.html`) aus,
2. leitet alles unter `/widerstand/*`, `/wizard/*`, `/bluff/*`, `/tempel/*`, `/poker/*` bzw. `/munchkin/*` an den jeweiligen Container weiter (inkl. WebSocket-Upgrade für Socket.IO),
3. schneidet dabei jeweils das Präfix ab, bevor die Anfrage beim jeweiligen Spiel-Server ankommt - die Spiele "wissen" also gar nichts von diesem Hub.

Damit das funktioniert, mussten alle Spiele minimal angepasst werden: Der Socket.IO-Client (`public/client.js`) ermittelt jeweils automatisch aus der aktuellen Browser-URL, unter welchem Pfad-Präfix er gerade läuft, und verbindet sich entsprechend. Bei direktem Zugriff (z. B. weiterhin `wd.oualid.de` ohne Hub) ist das Präfix leer und es ändert sich nichts am bisherigen Verhalten - alle Zugriffswege funktionieren parallel.

## Voraussetzung

Widerstand, Wizard, Bluff, Tempel des Schreckens, Poker und Munchkin müssen als eigene Container bereits laufen (`127.0.0.1:8092`, `8093`, `8095`, `8096`, `8097` bzw. `8098`), bevor der Hub gestartet wird - er leitet nur weiter, hostet die Spiele nicht selbst.

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
