/*
  This file is part of fxmp, an .xm player.
  fxmp is copyright 2000 by Osman Keskin <spectre@winterland.net>
  
  this version of fxmp is tailored for 64k GNU/Linux and win32 intro
  development (as part of Jeeves64 by Kuno Woudt <warp-tmt@dds.nl>).
  
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING; if not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
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
  fopen and fclose; so I can just search and replace those procedures
  with my replacements  (called mread, mseek, mgetc, mtell, mopen and 
  mclose :).                               
  
  -- Warp <warp-tmt@dds.nl>

  NOTE: multiple open `files' is not supported :)
*/

static int mlength;
static int moffset;
static char* mdata;

int
mopen(char* data, int len)
{
	mlength = len;
	moffset = 0;
	mdata   = data;

	return 23;
}

void 
mclose(int f) { }

void 
mread(void* dst, int size, int count, int f)
{
	memcpy(dst, mdata+moffset, count*size);
	moffset += count*size;
}

void
mseek(int f, int offset, int start)
{
	switch(start)
	{
	case SEEK_CUR: moffset +=          offset; break; /* Current position */
	case SEEK_END: moffset = mlength + offset; break; /* End of file */
	case SEEK_SET: moffset =           offset; break; /* Beginning of file */
	}
}

char
mgetc(int f)
{
	moffset++;
	return mdata[moffset-1];
}

long
mtell(int f)
{
	return moffset;
}

uchar *
calc_static_envelope (xm_envpoint env[], uchar numpts)
{
	uchar *staticbuffer;
	int curpoint = 0, pos = 0;
	float val, steps;

	staticbuffer = (uchar *) calloc(1, env[numpts - 1].pos + 1);	/* length of envelope */

	steps = (float) (env[1].val - env[0].val) / env[1].pos;	/* first step thing */

	val = (float) env[0].val;
	for (;;)
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

xm_module *
xm_load (char *fn, int len)
{
	xm_module *xm;
  /*	FILE *f; */
	int f;
	schar temp, *samp;
	int dummy, i, j;
	unsigned int k;

  /*	f = mopen (fn, "rb"); */
	f = mopen (fn, len);
	if (f == 0)
		return 0;

	xm = (xm_module *) calloc(1, sizeof (xm_module));

	mread (xm->header, 17, 1, f);
	mread (xm->songname, 20, 1, f);
	xm->id = mgetc (f);
	mread (xm->tracker, 20, 1, f);
	mread (&xm->trver, 2, 1, f);
	mread (&xm->headersize, 4, 1, f);
	mread (&xm->songlen, 2, 1, f);
	mread (&xm->restartpos, 2, 1, f);
	mread (&xm->numchans, 2, 1, f);
	mread (&xm->numpats, 2, 1, f);
	mread (&xm->numinsts, 2, 1, f);
	mread (&xm->flags, 2, 1, f);
	mread (&xm->tempo, 2, 1, f);
	mread (&xm->bpm, 2, 1, f);
	mread (xm->order, 256, 1, f);

	/*
	  printf ("songname: %s\n", xm->songname); 
		printf ("id: %2x\n", xm->id); 
		printf ("tracker: %s\n", xm->tracker); 
		printf ("version: %d\n", xm->trver >> 8); 
		printf ("headersize: %d\n", (int) xm->headersize); 
		printf ("songlen: %d\n", xm->songlen); 
		printf ("restartpos: %d\n", xm->restartpos); 
		printf ("number of channels: %d\n", xm->numchans); 
		printf ("number of patterns: %d\n", xm->numpats); 
		printf ("number of instruments: %d\n", xm->numinsts); 
		printf ("flags: %d\n", xm->flags); 
		printf ("tempo: %d\n", xm->tempo); 
		printf ("bpm: %d\n", xm->bpm); 
	*/

	xm->patheader = (xm_patheader *) calloc(1, xm->numpats * sizeof (xm_patheader));
	xm->pattern = (xm_note **) calloc(1, xm->numpats * sizeof (xm_note *));

	for (i = 0; i < xm->numpats; i++)
		{
			mread (&xm->patheader[i].len, 4, 1, f);
			mread (&xm->patheader[i].packtype, 1, 1, f);
			mread (&xm->patheader[i].numrows, 2, 1, f);
			mread (&xm->patheader[i].size, 2, 1, f);
			xm->pattern[i] = (xm_note *) calloc(1, xm->numchans * xm->patheader[i].numrows * sizeof (xm_note));
			if (xm->patheader[i].size == 0)
				continue;
			for (j = 0; j < xm->numchans * xm->patheader[i].numrows; j++)
				{
					temp = mgetc (f);
					if (temp & 0x80)
						{
							if (temp & 1)
								xm->pattern[i][j].note = mgetc (f);
							if (temp & 2)
								xm->pattern[i][j].inst = mgetc (f);
							if (temp & 4)
								xm->pattern[i][j].vol = mgetc (f);
							if (temp & 8)
								xm->pattern[i][j].fx = mgetc (f);
							if (temp & 16)
								xm->pattern[i][j].parm = mgetc (f);
						}
					else
						{
							xm->pattern[i][j].note = temp;
							xm->pattern[i][j].inst = mgetc (f);
							xm->pattern[i][j].vol = mgetc (f);
							xm->pattern[i][j].fx = mgetc (f);
							xm->pattern[i][j].parm = mgetc (f);
						}
				}
		}

	xm->inst = (xm_inst *) calloc(1, xm->numinsts * sizeof (xm_inst));

	for (i = 0; i < xm->numinsts; i++)
		{
			dummy = mtell (f);
			mread (&xm->inst[i].headersize, 4, 1, f);
			mread (xm->inst[i].name, 22, 1, f);
			mread (&xm->inst[i].type, 1, 1, f);
			mread (&xm->inst[i].numsamples, 2, 1, f);

			if (xm->inst[i].headersize <= 29)
				continue;
			mread (&xm->inst[i].sampleheadersize, 4, 1, f);

			mread (xm->inst[i].samplenum, 96, 1, f);
			mread (xm->inst[i].volenv, 48, 1, f);
			mread (xm->inst[i].panenv, 48, 1, f);
			xm->inst[i].numvolpts = mgetc (f);
			xm->inst[i].numpanpts = mgetc (f);
			xm->inst[i].volsustain = mgetc (f);
			xm->inst[i].volloopstart = mgetc (f);
			xm->inst[i].volloopend = mgetc (f);
			xm->inst[i].pansustain = mgetc (f);
			xm->inst[i].panloopstart = mgetc (f);
			xm->inst[i].panloopend = mgetc (f);
			xm->inst[i].voltype = mgetc (f);
			xm->inst[i].pantype = mgetc (f);
			xm->inst[i].vibtype = mgetc (f);
			xm->inst[i].vibsweep = mgetc (f);
			xm->inst[i].vibdepth = mgetc (f);
			xm->inst[i].vibrate = mgetc (f);

			if (xm->inst[i].numsamples > 0)
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

			mread (&xm->inst[i].volfadeout, 2, 1, f);
			mseek (f, dummy + xm->inst[i].headersize, SEEK_SET);
			if (xm->inst[i].numsamples != 0)
				xm->inst[i].sample = (xm_sample *) calloc(1, xm->inst[i].numsamples * sizeof (xm_sample));
			else
				xm->inst[i].sample = NULL;

			for (j = 0; j < xm->inst[i].numsamples; j++)
				{
					mread (&xm->inst[i].sample[j].len, 4, 1, f);
					mread (&xm->inst[i].sample[j].loopstart, 4, 1, f);
					mread (&xm->inst[i].sample[j].looplen, 4, 1, f);
					xm->inst[i].sample[j].volume = mgetc (f);
					xm->inst[i].sample[j].finetune = mgetc (f);
					xm->inst[i].sample[j].type = mgetc (f);

					xm->inst[i].sample[j].pan = mgetc (f);
					xm->inst[i].sample[j].relnote = mgetc (f);
					xm->inst[i].sample[j].reserved = mgetc (f);
					mread (xm->inst[i].sample[j].name, 22, 1, f);
				}
			for (j = 0; j < xm->inst[i].numsamples; j++)
				{
					if (xm->inst[i].sample[j].len == 0)
						continue;
					if (xm->inst[i].sample[j].type & 16)
						{
							xm->inst[i].sample[j].data = (sshort *) calloc(1, xm->inst[i].sample[j].len);
							mread (xm->inst[i].sample[j].data, xm->inst[i].sample[j].len, 1, f);
							xm->inst[i].sample[j].len >>= 1;
							xm->inst[i].sample[j].loopstart >>= 1;
							xm->inst[i].sample[j].looplen >>= 1;
							for (k = 1; k < xm->inst[i].sample[j].len; k++)
								xm->inst[i].sample[j].data[k] += xm->inst[i].sample[j].data[k - 1];
						}
					else
						{
							xm->inst[i].sample[j].data = (sshort *) calloc(1, xm->inst[i].sample[j].len * 2);
							if (xm->inst[i].sample[j].data == NULL) { printf("error can't alloc samples\n"); exit(1); }
							samp = (schar *) calloc(1, xm->inst[i].sample[j].len);
							mread (samp, xm->inst[i].sample[j].len, 1, f);
							for (k = 0; k < xm->inst[i].sample[j].len; k++)
								xm->inst[i].sample[j].data[k] = samp[k] << 8;
							for (k = 1; k < xm->inst[i].sample[j].len; k++)
								xm->inst[i].sample[j].data[k] += xm->inst[i].sample[j].data[k - 1];
							free (samp);
						}
				}
		}

	mclose (f);

	channel = (chn *) calloc(1, xm->numchans * sizeof (chn));

	return xm;
}
