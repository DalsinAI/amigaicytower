# Icy Tower for GFOS

The Icy Tower 1.3.1 open remake (royeldar/icytower, MIT) built for GFOS
(AmigaOS 3.2.3 with GFOpenUp) on a 68040, on amigaallegro: Allegro 5 drawing
through SDL2.module, GL.module and OpenGPU, with Ogg Vorbis sound.

Jump Harold up the tower, floor by floor; land multi-floor jumps in a row for
combos. Left and Right move, Space jumps, P pauses, Esc leaves.

## Install

    1> GFOpenUpTool INSTALL Parts/IcyTower

installs `SYS:Games/IcyTower/` (the game, its gfx and sfx, licence). Needs a
68040 or 68060.

## Build

    STOVE=~/AmiCradle/stoves/os32-gcc16-open6 OUT=out ./build-amiga.sh

`it.lock` pins the remake and amigaallegro by commit (libogg 1.3.5 and
libvorbis 1.3.7 by tag and commit in scripts/build-allegro.sh); nothing
third-party is kept in this repository.

## Tests

    IT_SRC=<icytower checkout> sh tests/test_host.sh

## Licence and game data

The remake's code is MIT (see LICENSE). Its gfx/ and sfx/ were extracted from
the original freeware Icy Tower 1.3.1 by Free Lunch Design; they need a
rights review before any release of this part.

Port: Copyright (c) 2026 AmiCradle Team.

Designed, tested and delivered by The AmiCradle Team.
