#!/bin/sh
# Unit test for scripts/write-part.sh on a fake part drawer.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
D="$T/Games/IcyTower"; mkdir -p "$D/gfx/font1" "$D/sfx"
for f in IcyTower IcyTower.info ReadMe gfx/bgtile.bmp gfx/font1/00000020.bmp sfx/cheer.ogg; do : > "$D/$f"; done
sh "$HERE/scripts/write-part.sh" "$T" 1.3.1
fail() { echo "FAIL: $*"; cat "$T/Part"; exit 1; }
[ "$(sed -n 1p "$T/Part")" = "part IcyTower 1.3.1" ] || fail header
grep -qx 'needs 68040' "$T/Part" || fail needs
grep -qx 'copy "Games/IcyTower/IcyTower" "SYS:Games/IcyTower/IcyTower"' "$T/Part" || fail program
grep -qx 'default "Games/IcyTower/IcyTower.info" "SYS:Games/IcyTower/IcyTower.info"' "$T/Part" || fail icon
grep -qx 'copy "Games/IcyTower/gfx/font1/00000020.bmp" "SYS:Games/IcyTower/gfx/font1/00000020.bmp"' "$T/Part" || fail font
[ "$(grep -c '^copy\|^default' "$T/Part")" = 6 ] || fail count
echo "test-part: pass"
