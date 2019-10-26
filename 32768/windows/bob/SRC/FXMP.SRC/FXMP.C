/*
  fxmp.c - fxmp main code
  Copyright (C) 1999-2001, Bekir Osman Keskin <spectre@portent.net>

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

/* NOTE the hardware mixing frequency is a bit off still */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#ifdef LINUX
#include <pthread.h>
#endif
#ifdef _WIN32
#include <memory.h>
#endif


#include "fxmp.h"

#ifdef LINUX
#include "drv_seq.h"
#include "drv_dsp.h"
#endif

#ifdef _WIN32
#include "drv_win.h"
#endif

schar verbose = 0;

void calc_pan_table (fxmp_player *p)
{
  int i;

  for (i = 0; i < 256; i++)
  {
    p->pantable[i].l = 64 - (i / 4);
    p->pantable[i].r = i / 4;
  }
}

int fxmp_init (fxmp_player *p, fxmp_driver *d, int dev)
{
  memset (p, 0, sizeof (fxmp_player));

  p->driver = d;
  d->dev = dev;
  if (d->init (p) != 0) return 1;
  calc_pan_table (p);
  p->global_volume = 64;
  /* precalclinear(); */

/*  printf("+ Flare XM Player %s init\n", FXMP_VERSION); */
  return 0;
}

void fxmp_load_patches (fxmp_player *p)
{
  if (p->driver->type == FXMP_TYPE_HARDWARE)
  {
    p->driver->load_patches (p);
  }
}

void fxmp_deinit (fxmp_player *p)
{
  if (p->driver->deinit) p->driver->deinit (p);
}

float frac (float bla)
{
  return bla - (int) bla;
}

void fxmp_set_order (fxmp_player *p, int order)
{
  p->ord = p->tord = order;
}

#ifdef LINUX
void *thread_func (void *arg)
{
  while (!fxmp_ticker ((fxmp_player *) arg));
  pthread_exit(0);
  return 0;
}
#endif

int fxmp_play (fxmp_player *p)
{
  int i;
#ifdef THREADS
  pthread_t pth;
  /* pthread_attr_t pth_attr; */
#endif

  p->speed = 0;
  p->ord = 0;
  p->tord = 0;
  p->trow = 0;

  p->row = -1;
  p->tick = p->module->speed - 1;
  p->pat = p->module->order[p->ord];

  memset (p->channel, 0, sizeof (fxmp_channel) * p->module->n_chans);
  for (i = 0; i < p->module->n_chans; i++)
  {
    p->channel[i].id = i;
  }

  /*
    if (p->driver->type == TYPE_HARDWARE)
    {
      seq_start_timer ();
      seq_sync ();
    }
  */
#ifdef THREADS
#ifdef LINUX
  /*
     pthread_attr_init(&pth_attr);
     pthread_attr_setschedpolicy(&pth_attr,-20);
  */
  if (pthread_create (&pth, NULL, thread_func, (void *) p) != 0)
  {
    printf ("Can't create thread!\n");
    return 1;
  }
#endif
#else
/*   while (!ticker (xm)); */
#endif

  return 0;
}
