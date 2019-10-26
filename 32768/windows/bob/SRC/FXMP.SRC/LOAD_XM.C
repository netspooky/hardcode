/*
  load_xm.c - xm loader code
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

  NOTE: this is a modified version of load_xm.c to load .xm's
  from memory and not from file. -- Kuno Woudt <warp-tmt@dds.nl>
*/

#include <stdlib.h>
#include <stdio.h>
#include "fxmp.h"

#ifdef _WIN32
#include <memory.h>
#endif

/* 
  to replace load_xm with a version which reads the .xm from memory i
  have decided to mimick the behaviour of fread, fseek, fgetc, ftell,
  fopen and fclose; so I can just #define some replacements (called 
  mread, mseek, mgetc, mtell, mopen and mclose :).                               
 
  -- Warp <warp-tmt@dds.nl>

  NOTE: multiple open `files' is not supported :)
*/

#define fopen(a, b)       mopen(a, b)
#define fclose(a)   
#define fgetc(a)          mgetc(a)
#define ftell(a)          moffset
#define fread(a, b, c, d) mread(a, b, c, d)
#define fseek(a, b, c)    mseek(a, b, c)

/* static int mlength; */
static int moffset;
static char* mdata;

FILE *
mopen(char* data, char * open)
{
        FILE * t = (FILE *) 1; /* kludge, kludge, kludge! :) */

/*	mlength = len; */
	moffset = 0;
	mdata   = data;

	return t;
}

size_t
mread(void* dst, int size, int count, FILE * f)
{
	memcpy(dst, mdata+moffset, count*size);
	moffset += count*size;
        return count;
}

int
mseek(FILE * f, int offset, int start)
{
	switch(start)
	{
	case SEEK_CUR: moffset +=          offset; break; /* Current position */
/*	case SEEK_END: moffset = mlength + offset; break; */ /* End of file */
	case SEEK_SET: moffset =           offset; break; /* Beginning of file */
	}
        return 0;
}

char mgetc(FILE * f)
{
	moffset++;
	return mdata[moffset-1];
}



uchar *
calc_static_envelope (fxmp_envpoint env[], uchar numpts)
{
  uchar *staticbuffer;
  int curpoint = 0, pos = 0;
  float val, steps;

  staticbuffer = (uchar *) calloc (env[numpts - 1].pos + 1, 1); 	/* length of envelope */

  steps = (float) (env[1].val - env[0].val) / env[1].pos; 	/* first step thing */

  val = (float) env[0].val;
  for (; ; )
  {
    staticbuffer[pos++] = (uchar) (val + 0.5);

    if ((uchar) (val + 0.5) == env[curpoint + 1].val && pos >= env[curpoint + 1].pos)
    {
      curpoint++;
      if (curpoint >= numpts - 1)
        break;
      steps = (float) (env[curpoint + 1].val - env[curpoint].val) / (env[curpoint + 1].pos - env[curpoint].pos);
    }
    val += steps;
  }
  staticbuffer[pos] = staticbuffer[pos - 1];
  return staticbuffer;
}

fxmp_module *
fxmp_load (fxmp_player *p, unsigned char *fn)
{
  fxmp_module *xm;
  FILE *f;
  schar temp, *samp;
  int dummy, i, j;
  unsigned int k;

  f = fopen (fn, "rb");
  if (f == 0)
    return 0;

  xm = (fxmp_module *) calloc (sizeof (fxmp_module), 1);

  fread (xm->header, 17, 1, f);
  fread (xm->songname, 20, 1, f);
  /*  printf ("songname: %s\n", xm->songname); */
  xm->id = fgetc (f);
  /*  printf ("id: %2x\n", xm->id); */
  fread (xm->tracker, 20, 1, f);
  /*  printf ("tracker: %s\n", xm->tracker); */
  fread (&xm->trver, 2, 1, f);
  /*  printf ("version: %d\n", xm->trver >> 8); */
  fread (&xm->hdrsize, 4, 1, f);
  /*  printf ("hdrsize: %d\n", (int) xm->hdrsize); */
  fread (&xm->songlen, 2, 1, f);
  /*  printf ("songlen: %d\n", xm->songlen); */
  fread (&xm->restartpos, 2, 1, f);
  /*  printf ("restartpos: %d\n", xm->restartpos); */
  fread (&xm->n_chans, 2, 1, f);
  /*  printf ("number of channels: %d\n", xm->n_chans); */
  fread (&xm->n_pats, 2, 1, f);
  /*  printf ("number of patterns: %d\n", xm->n_pats); */
  fread (&xm->n_insts, 2, 1, f);
  /*  printf ("number of instruments: %d\n", xm->n_insts); */
  fread (&xm->flags, 2, 1, f);
  /*  printf ("flags: %d\n", xm->flags); */
  fread (&xm->speed, 2, 1, f);
  /*  printf ("speed: %d\n", xm->speed); */
  fread (&xm->bpm, 2, 1, f);
  /*  printf ("bpm: %d\n", xm->bpm); */
  fread (xm->order, 256, 1, f);

  xm->patheader = (fxmp_patheader *) calloc (xm->n_pats * sizeof (fxmp_patheader), 1);
  xm->pattern = (fxmp_note **) calloc (xm->n_pats * sizeof (fxmp_note *), 1);

  for (i = 0; i < xm->n_pats; i++)
  {
    fread (&xm->patheader[i].length, 4, 1, f);
    fread (&xm->patheader[i].packtype, 1, 1, f);
    fread (&xm->patheader[i].numrows, 2, 1, f);
    fread (&xm->patheader[i].size, 2, 1, f);
    xm->pattern[i] = (fxmp_note *) calloc (xm->n_chans * xm->patheader[i].numrows * sizeof (fxmp_note), 1);
    if (!xm->patheader[i].size) continue;

    for (j = 0; j < xm->n_chans * xm->patheader[i].numrows; j++)
    {
      temp = fgetc (f);
      if (temp & 0x80)
      {
        if (temp & 1)
          xm->pattern[i][j].note = fgetc (f);
        if (temp & 2)
          xm->pattern[i][j].inst = fgetc (f);
        if (temp & 4)
          xm->pattern[i][j].vol = fgetc (f);
        if (temp & 8)
          xm->pattern[i][j].fx = fgetc (f);
        if (temp & 16)
          xm->pattern[i][j].parm = fgetc (f);
      }
      else
      {
        xm->pattern[i][j].note = temp;
        xm->pattern[i][j].inst = fgetc (f);
        xm->pattern[i][j].vol = fgetc (f);
        xm->pattern[i][j].fx = fgetc (f);
        xm->pattern[i][j].parm = fgetc (f);
      }
    }
  }

  xm->inst = (fxmp_inst *) calloc (xm->n_insts * sizeof (fxmp_inst), 1);

  for (i = 0; i < xm->n_insts; i++)
  {
    dummy = ftell (f);
    fread (&xm->inst[i].hdrsize, 4, 1, f);
    fread (xm->inst[i].name, 22, 1, f);
    fread (&xm->inst[i].type, 1, 1, f);
    fread (&xm->inst[i].n_samples, 2, 1, f);

    if (xm->inst[i].hdrsize <= 29) continue;
    fread (&xm->inst[i].sample_hdrsize, 4, 1, f);

    fread (xm->inst[i].sample_of, 96, 1, f);
    fread (xm->inst[i].volenv, 48, 1, f);
    fread (xm->inst[i].panenv, 48, 1, f);
    xm->inst[i].numvolpts = fgetc (f);
    xm->inst[i].numpanpts = fgetc (f);
    xm->inst[i].volsustain = fgetc (f);
    xm->inst[i].volloopstart = fgetc (f);
    xm->inst[i].volloopend = fgetc (f);
    xm->inst[i].pansustain = fgetc (f);
    xm->inst[i].panloopstart = fgetc (f);
    xm->inst[i].panloopend = fgetc (f);
    xm->inst[i].voltype = fgetc (f);
    xm->inst[i].pantype = fgetc (f);
    xm->inst[i].vibtype = fgetc (f);
    xm->inst[i].vibsweep = fgetc (f);
    xm->inst[i].vibdepth = fgetc (f);
    xm->inst[i].vibrate = fgetc (f);

    if (xm->inst[i].n_samples > 0)
    {
      if (xm->inst[i].voltype & 1)
        xm->inst[i].static_volenv = calc_static_envelope (xm->inst[i].volenv, xm->inst[i].numvolpts);
      if (xm->inst[i].voltype & 2)
        xm->inst[i].static_volsustain = xm->inst[i].volenv[xm->inst[i].volsustain].pos;
      if (xm->inst[i].voltype & 4)
      {
        xm->inst[i].static_volloopstart = xm->inst[i].volenv[xm->inst[i].volloopstart].pos;
        xm->inst[i].static_volloopend = xm->inst[i].volenv[xm->inst[i].volloopend].pos;
      }
      if (xm->inst[i].pantype & 1)
        xm->inst[i].static_panenv = calc_static_envelope (xm->inst[i].panenv, xm->inst[i].numpanpts);
      if (xm->inst[i].pantype & 2)
        xm->inst[i].static_pansustain = xm->inst[i].panenv[xm->inst[i].pansustain].pos;
      if (xm->inst[i].pantype & 4)
      {
        xm->inst[i].static_panloopstart = xm->inst[i].panenv[xm->inst[i].panloopstart].pos;
        xm->inst[i].static_panloopend = xm->inst[i].panenv[xm->inst[i].panloopend].pos;
      }
    }
    else
    {
      /* fix */
      xm->inst[i].voltype = xm->inst[i].pantype = 0;
    }

    fread (&xm->inst[i].volfade, 2, 1, f);
    fseek (f, dummy + xm->inst[i].hdrsize, SEEK_SET);

    if (xm->inst[i].n_samples != 0)
      xm->inst[i].sample = (fxmp_sample *) calloc (xm->inst[i].n_samples * sizeof (fxmp_sample), 1);
    else
      xm->inst[i].sample = NULL;

    for (j = 0; j < xm->inst[i].n_samples; j++)
    {
      fread (&xm->inst[i].sample[j].length, 4, 1, f);
      fread (&xm->inst[i].sample[j].loopstart, 4, 1, f);
      fread (&xm->inst[i].sample[j].looplen, 4, 1, f);
      xm->inst[i].sample[j].volume = fgetc (f);
      xm->inst[i].sample[j].finetune = fgetc (f);
      xm->inst[i].sample[j].type = fgetc (f);

      xm->inst[i].sample[j].pan = fgetc (f);
      xm->inst[i].sample[j].relnote = fgetc (f);
      xm->inst[i].sample[j].reserved = fgetc (f);
      fread (xm->inst[i].sample[j].name, 22, 1, f);
    }
    for (j = 0; j < xm->inst[i].n_samples; j++)
    {
      if (xm->inst[i].sample[j].length == 0)
        continue;

      if (xm->inst[i].sample[j].type & 16)
      {
        xm->inst[i].sample[j].data = (sshort *) calloc (xm->inst[i].sample[j].length, 1);
        fread (xm->inst[i].sample[j].data, xm->inst[i].sample[j].length, 1, f);
        xm->inst[i].sample[j].length >>= 1;
        xm->inst[i].sample[j].loopstart >>= 1;
        xm->inst[i].sample[j].looplen >>= 1;
        for (k = 1; k < xm->inst[i].sample[j].length; k++)
          xm->inst[i].sample[j].data[k] += xm->inst[i].sample[j].data[k - 1];
      }
      else
      {
        xm->inst[i].sample[j].data = (sshort *) calloc (xm->inst[i].sample[j].length * 2, 1);
        if (xm->inst[i].sample[j].data == NULL)
        {
          printf ("error can't alloc samples\n"); exit(1);
        }
        samp = (schar *) calloc (xm->inst[i].sample[j].length, 1);
        fread (samp, xm->inst[i].sample[j].length, 1, f);
        for (k = 0; k < xm->inst[i].sample[j].length; k++)
          xm->inst[i].sample[j].data[k] = samp[k] << 8;
        for (k = 1; k < xm->inst[i].sample[j].length; k++)
          xm->inst[i].sample[j].data[k] += xm->inst[i].sample[j].data[k - 1];
        free (samp);
      }
    }
  }

  fclose (f);

  p->channel = (fxmp_channel *) calloc (xm->n_chans * sizeof (fxmp_channel), 1);
  p->module = xm;

  return xm;
}
