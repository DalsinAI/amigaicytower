/* Icy Tower on GFOS: version string, stack, and the game's own drawer as
 * the current directory (it loads gfx/ and sfx/ by relative path, which from
 * a Shell would otherwise be wherever the Shell is).
 * MIT, like the Icy Tower remake. Copyright (c) 2026 AmiCradle Team. */
#include <proto/dos.h>

unsigned long __stack = 256 * 1024;
const char gfos_version[] = "$VER: IcyTower 1.3.1 (16.11.2026) GFOS 68040";

static BPTR old_dir;
static BPTR prog_dir;

__attribute__((constructor)) static void gfos_into_progdir(void)
{
    prog_dir = Lock((CONST_STRPTR)"PROGDIR:", SHARED_LOCK);
    if (prog_dir)
        old_dir = CurrentDir(prog_dir);
}

__attribute__((destructor)) static void gfos_out_of_progdir(void)
{
    if (prog_dir) {
        CurrentDir(old_dir);
        UnLock(prog_dir);
    }
}
