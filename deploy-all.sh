#!/bin/bash
# Deployt ALLE Spiele auf dem Raspberry Pi (duckpi) in einem Rutsch:
# pro Projekt "git pull" + "docker compose up -d --build" (wie deren deploy.sh).
#
# Die Projektordner werden automatisch gefunden (neben oder innerhalb des
# Spielehub-Ordners, bis 2 Ebenen tief). Der Hub kommt zuletzt.
#
# Einmalig:   chmod +x deploy-all.sh
# Aufruf:     ./deploy-all.sh              (alle)
#             ./deploy-all.sh poker wizard (nur bestimmte)
# Anderer Basisordner: BASE=/pfad ./deploy-all.sh

SELF="$(cd "$(dirname "$0")" && pwd)"
# Suchorte: eigener Ordner, dessen Eltern- und Grosselternordner (bis 2 Ebenen tief),
# damit es egal ist, ob die Spiele neben oder INNERHALB eines Ordners liegen.
# Eigener Suchort: BASE=/pfad ./deploy-all.sh
if [ -n "$BASE" ]; then ROOTS="$BASE"; else ROOTS="$SELF $SELF/.. $SELF/../.."; fi

# Reihenfolge: Spiele zuerst, Hub zuletzt (er braucht die anderen als Ziele).
ALL="bluff poker wizard widerstand tempeldesschreckens munchkin monopoly unonomercy dereisernethron spielehub"
WANT="${*:-$ALL}"

ok=(); failed=(); missing=()

find_dir() {  # Projektordner (mit docker-compose.yml) ohne Beachtung der Gross-/Kleinschreibung finden
  local name="$1" r d
  [ "$name" = "spielehub" ] && [ -f "$SELF/docker-compose.yml" ] && { echo "$SELF"; return 0; }
  for depth in 1 2; do for r in $ROOTS; do
    d="$(find "$r" -maxdepth $depth -type d -iname "$name" -not -path '*/node_modules/*' 2>/dev/null \
         | while read -r c; do [ -f "$c/docker-compose.yml" ] && { echo "$c"; break; }; done)"
    [ -n "$d" ] && { (cd "$d" && pwd); return 0; }
  done; done
  return 1
}

for name in $WANT; do
  [ "$name" = "tempel" ] && name="tempeldesschreckens"
  echo
  echo "=================== $name ==================="
  if ! dir="$(find_dir "$name")"; then
    echo "Ordner nicht gefunden (gesucht in: $ROOTS) - uebersprungen."
    missing+=("$name"); continue
  fi
  if ( cd "$dir" && git pull && docker compose up -d --build ); then
    ok+=("$name")
  else
    echo "!!! Fehler bei $name"
    failed+=("$name")
  fi
done

echo
echo "=================== Zusammenfassung ==================="
echo "OK:            ${ok[*]:-–}"
echo "Nicht gefunden: ${missing[*]:-–}"
echo "Fehlgeschlagen: ${failed[*]:-–}"
echo
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
[ ${#failed[@]} -eq 0 ]
