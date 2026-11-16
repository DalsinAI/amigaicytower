#!/bin/sh
# Writes the Part file GFOpenUpTool INSTALL reads (gfopenup src/openuptool.c):
# "copy" for each file under the part drawer, each to SYS:<its path>; the
# icons as "default", so the user's own stay.
#   write-part.sh <part drawer> <version>
# MIT. Copyright (c) 2026 AmiCradle Team.
set -eu
P=$1; V=$2
{
    echo "part IcyTower $V"
    echo "; Icy Tower 1.3.1 open remake on Allegro 5: jump up the tower floors, keep the combo going"
    echo "needs 68040"
    (cd "$P" && find Games -type f ! -name Part | LC_ALL=C sort) | while read -r f; do
        case "$f" in
            *.info) echo "default \"$f\" \"SYS:$f\"" ;;
            *) echo "copy \"$f\" \"SYS:$f\"" ;;
        esac
    done
} > "$P/Part"
