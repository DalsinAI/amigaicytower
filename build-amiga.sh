#!/bin/sh
# Builds the Icy Tower 1.3.1 open remake for GFOS (AmigaOS 3.2.3 with
# GFOpenUp) with a stove, on amigaallegro (Allegro 5 over SDL2.module,
# GL.module and OpenGPU), with Ogg Vorbis for its sounds and music:
#   STOVE=.../stoves/os32-gcc16-open6 OUT=out ./build-amiga.sh
# The remake and amigaallegro are fetched at what it.lock gives; nothing
# third-party is kept here. Allegro is built once and kept; a run that ends
# out of time says so, and the next run goes on.
# OUT gets Parts/IcyTower, a GFOpenUp part:
#   GFOpenUpTool INSTALL Parts/IcyTower  -> SYS:Games/IcyTower/
# MIT, like the remake. Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$HERE/it.lock"
STOVE=${STOVE:-"$HOME/AmiCradle/stoves/os32-gcc16-open6"}
WORK="${WORK:-$HOME/.cache/amigaicytower/build}"; OUT="${OUT:-$WORK/out}"
JOBS=${JOBS:-$(nproc 2>/dev/null || echo 4)}; export JOBS
TC="$STOVE/prefix"; PATH="$TC/bin:$PATH"; export PATH
mkdir -p "$WORK" "$OUT"; OUT=$(cd "$OUT" && pwd)
t0=$(date +%s)
m68k-amigaos-gcc --version | head -n 1

# --- amigaallegro with Ogg Vorbis (kept between runs) ------------------------------
set +e
ALLEGRO_BUDGET=$(( ${BUDGET_TOTAL:-840} - 60 )) sh "$HERE/scripts/build-allegro.sh" "$STOVE" "$WORK" "$ALLEGRO_GIT" "$ALLEGRO_COMMIT" > "$WORK/allegro.out"
rc=$?
set -e
[ $rc -eq 3 ] && { echo "out of time in allegro, run again to go on"; exit 0; }
[ $rc -eq 0 ] || exit $rc
PFX=$(tail -n 1 "$WORK/allegro.out"); VP="$WORK/vorbis-prefix"
echo "allegro: $PFX ($(( $(date +%s) - t0 )) s)"

# --- the remake at its pinned commit, with patches/ -----------------------------------
SRC="$WORK/icytower"
PSUM=$(cat "$HERE"/patches/*.patch 2>/dev/null | sha256sum | cut -c1-16)
if [ "$(cat "$SRC/.patched" 2>/dev/null)" != "$IT_COMMIT-$PSUM" ]; then
    rm -rf "$SRC"; mkdir -p "$SRC"; git -C "$SRC" init -q
    git -C "$SRC" fetch -q --depth 1 "$IT_GIT" "$IT_COMMIT"; git -C "$SRC" checkout -q FETCH_HEAD
    for p in "$HERE"/patches/*.patch; do
        [ -f "$p" ] || continue
        patch -s -d "$SRC" -p1 < "$p" || { echo "patch failed: $p"; exit 1; }
    done
    echo "$IT_COMMIT-$PSUM" > "$SRC/.patched"
fi

# --- compile and link ---------------------------------------------------------------------
SYSROOT="$TC/m68k-amigaos"; DEPS="$SYSROOT/port-deps"
ARCH="-mcrt=nix20 -m68040 -m68881 -pthread"
CF="$ARCH -std=gnu99 -O2 -fomit-frame-pointer -Wall -DALLEGRO_STATICLINK=1 -D__AMIGAOS3__=1 -I$PFX/include -I$SYSROOT/include"
O="$WORK/obj"; rm -rf "$O"; mkdir -p "$O"
for f in icytower gfx sfx menu options characters floor_types fullscreen game physics; do
    m68k-amigaos-gcc $CF -c "$SRC/$f.c" -o "$O/$f.o" 2> "$O/$f.log" || { cat "$O/$f.log"; exit 1; }
done
m68k-amigaos-gcc $CF -c "$HERE/amiga/amiga_start.c" -o "$O/amiga_start.o"
m68k-amigaos-gcc $ARCH -o "$WORK/IcyTower.debug" "$O"/*.o \
    "$PFX/lib/liballegro_monolith-static.a" "$VP/lib/libvorbisfile.a" "$VP/lib/libvorbis.a" "$VP/lib/libogg.a" \
    "$SYSROOT/lib/libSDL2.a" "$SYSROOT/lib/libGL.a" "$DEPS/lib/libpng.a" "$DEPS/lib/libz.a" -lm -lpthread

# --- the GFOpenUp part: Parts/IcyTower -------------------------------------------------------
P="$OUT/Parts/IcyTower"; D="$P/Games/IcyTower"; rm -rf "$P"; mkdir -p "$D"
m68k-amigaos-strip -o "$D/IcyTower" "$WORK/IcyTower.debug"
cp -R "$SRC/gfx" "$SRC/sfx" "$D/"
cp "$SRC/LICENSE" "$D/License.txt"; cp "$HERE/README.md" "$D/ReadMe"
cp "$HERE/amiga/icons/IcyTower.info" "$HERE/amiga/icons/ReadMe.info" "$D/"
cp "$HERE/amiga/icons/IcyTower-drawer.info" "$P/Games/IcyTower.info"
sh "$HERE/scripts/write-part.sh" "$P" "$IT_VERSION"
ls -l "$D/IcyTower"
strings "$D/IcyTower" | grep -q 'IcyTower 1.3.1 (16.11.2026) GFOS' || { echo "no \$VER"; exit 1; }
echo "part: $(grep -c '^copy\|^default' "$P/Part") files, $(du -sk "$P" | cut -f1) KB"
echo "total: $(( $(date +%s) - t0 )) s"
