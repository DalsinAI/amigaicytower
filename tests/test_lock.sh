#!/bin/sh
# it.lock pins full commits; $VER carries the locked version; build-amiga.sh
# compiles exactly the objects of the remake's Makefile (IT_SRC=<checkout>).
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$HERE/it.lock"
for c in "$IT_COMMIT" "$ALLEGRO_COMMIT"; do echo "$c" | grep -Eqx '[0-9a-f]{40}' || { echo "FAIL commit $c"; exit 1; }; done
grep -q "IcyTower $IT_VERSION " "$HERE/amiga/amiga_start.c" || { echo "FAIL \$VER"; exit 1; }
ours=$(sed -n 's/^for f in \(icytower .*\); do$/\1/p' "$HERE/build-amiga.sh" | tr ' ' '\n' | sort | tr '\n' ' ')
[ -n "$ours" ] || { echo "FAIL no source list"; exit 1; }
if [ -n "${IT_SRC:-}" ]; then
    up=$(sed -n 's/^icytower: //p' "$IT_SRC/Makefile" | tr ' ' '\n' | sed 's/\.o$//' | sort | tr '\n' ' ')
    [ "$ours" = "$up" ] || { echo "FAIL sources: ours [$ours] upstream [$up]"; exit 1; }
    for p in "$HERE"/patches/*.patch; do [ -f "$p" ] || continue; patch -s --dry-run -d "$IT_SRC" -p1 < "$p" || { echo "FAIL $p"; exit 1; }; done
fi
echo "test_lock: pass"
