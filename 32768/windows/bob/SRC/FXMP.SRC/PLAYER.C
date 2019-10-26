/*
  player.c - example/test player using fxmp
  Copyright (C) 1999-2001,
  Bekir Osman Keskin <spectre@portent.net>
  Tijs van Bakel <smoke@casema.net>
  Kuno Woudt <warp-tmt@dds.nl>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/* hint, set env vars like 'MIX=1' or 'ORD=3' */

#include <stdio.h>
#include <stdlib.h>

#include "fxmp.h"

#ifdef LINUX
#include "drv_seq.h"
#include "drv_dsp.h"
#endif

#ifdef _WIN32
#include "drv_win.h"
#endif

int main (int argc, char *argv[])
{
  fxmp_player player;
  fxmp_module *xm; /* this isn't needed in fact */

#ifdef _WIN32
  int driver = FXMP_DRV_WIN;
#else
  int driver = FXMP_DRV_DSP;
#endif

  if (getenv ("MIX"))
  {
    /* 1 = hw mixer */
    /* 2 = sw mixer */
    driver = atoi (getenv ("MIX"));
  }

  printf ("[F]lare [XM] [P]layer by spectre of flare\n");
  printf ("/dev/sequencer support by smoke of crap\n");
  printf ("win32 waveOut support by warp of bliss\n\n");

#ifdef LINUX
  if (driver == FXMP_DRV_DSP)
  {
    if (fxmp_init (&player, &fxmp_drv_dsp, 0)) exit (1);
  }
  else
  {
    if (fxmp_init (&player, &fxmp_drv_seq, 0)) exit (1);
  }
#endif

#ifdef _WIN32
  if (driver == FXMP_DRV_WIN)
  {
    if (fxmp_init (&player, &fxmp_drv_win, 0)) exit (1);
  }
#endif

  if (argc > 1)
  {
    xm = fxmp_load (&player, argv[1]);
    if (xm == 0)
    {
      printf ("Can't open file!\n");
      exit (1);
    }
  }
  else
  {
    printf ("Usage: %s file.xm\n", argv[0]);
    exit (0);
  }

  fxmp_load_patches (&player);

  if (getenv ("ORD")) fxmp_set_order (&player, atoi (getenv ("ORD")));

  fxmp_play (&player);
#ifdef THREADS
  printf ("playing... press enter to stop\n");
  getchar ();
#else
  printf ("playing... press ctrl-c to stop\n");
  while (!fxmp_poll (&player));
#endif

  fxmp_deinit (&player);
  return 0;
}
