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

#ifndef _FXMP_H
#define _FXMP_H

#include "types.h"
#include "config.h"

#define FXMP_VERSION "0.0.20"

#define DRV_SEQUENCER 1
#define DRV_DSP       2

#define XM_LOOP_MASK 0x03
#define XM_LOOP_NONE 0
#define XM_LOOP_FORWARD 1
#define XM_LOOP_PINGPONG 2
#define XM_SAMPLE_16BIT 0x10

#define TYPE_SOFTWARE 0
#define TYPE_HARDWARE 1

typedef struct
{
	uchar l, r;  /* volume for left & right channels */

}
panel;         /* pan element :) */

typedef struct
{
	uchar note, inst, vol, fx, parm;
}
xm_note;

typedef struct
{
	ulong len;
	uchar packtype;
	ushort numrows;
	ushort size;
}
xm_patheader;

typedef struct
{
	ulong len;
	ulong loopstart;
	ulong looplen;
	uchar volume;
	schar finetune;
	uchar type;
	uchar pan;
	schar relnote;
	uchar reserved;
	uchar name[22];
	sshort *data;
	uchar patchnr;   /* added by smoke ! */
}
xm_sample;

typedef struct
{
	ushort pos;
	ushort val;
}
xm_envpoint;

typedef struct
{
	ulong headersize;
	uchar name[22];
	uchar type;

	ushort numsamples;
	ulong sampleheadersize;
	uchar samplenum[96];
	xm_envpoint volenv[12];
	xm_envpoint panenv[12];
	uchar numvolpts;
	uchar numpanpts;
	uchar volsustain;
	uchar volloopstart;
	uchar volloopend;
	uchar pansustain;
	uchar panloopstart;
	uchar panloopend;
	uchar voltype;
	uchar pantype;
	uchar vibtype;
	uchar vibsweep;
	uchar vibdepth;
	uchar vibrate;
	ushort volfadeout;
	ushort reserved;
	xm_sample *sample;
	/*  internal player variables; */
	uchar *static_volenv;
	uchar *static_panenv;
	ushort static_volsustain;
	ushort static_volloopstart;
	ushort static_volloopend;
	ushort static_pansustain;
	ushort static_panloopstart;
	ushort static_panloopend;
}
xm_inst;

typedef struct
{
	uchar header[17];
	uchar songname[20];
	uchar id;
	uchar tracker[20];
	ushort trver;
	ulong headersize;
	ushort songlen;
	ushort restartpos;
	ushort numchans;
	ushort numpats;
	ushort numinsts;
	ushort flags;
	ushort tempo;
	ushort bpm;
	uchar order[256];
	xm_patheader *patheader;
	xm_note **pattern;
	xm_inst *inst;
}
xm_module;


typedef struct
{
	sshort inst,oldinst;
	ulong period;
	ulong freq;
	uchar samplenum;
	slong samplepos;    /* 24.8 fixed */

	slong sampleinc;    /* 24.8 fixed */

	slong samplelen;
	slong samplestart;
	slong sampleend;
	uchar keyoff;
	uchar pingpong;
	schar finetune;
	schar volume;
	ushort volfade;
	sshort pan;
	uchar type;
	uchar oldparm[20];    /* last non-zero fx parameter for each fx */

	/* tick based fx related */
	uchar vibratowave;
	schar vibratopos;
	uchar vibratospeed;
	uchar vibratodepth;
	uchar tremolowave;
	schar tremolopos;
	uchar tremolospeed;
	uchar tremolodepth;

	schar volumeslide;
	uchar portaup;
	uchar portadown;
	ulong portanoteperiod;
	uchar portanotespeed;
	uchar glissando;

	/* envelope stuff */
	ushort env_volpos;
	ushort env_volsustain;
	ushort env_volloopstart;
	ushort env_vollooplen;
	ushort env_volloopend;
	ushort env_volend;
	uchar env_volactive;
	ushort env_panpos;
	ushort env_pansustain;
	ushort env_panloopstart;
	ushort env_panlooplen;
	ushort env_panloopend;
	ushort env_panend;
	uchar env_panactive;

	uchar note;
	int hit;        /* note hit for the first time boolean */
	int pitchbend;

	/* current sample/instrument pointers (to pass to drv funcs directly) */
	xm_inst *insptr;
	xm_sample *smpptr;
}
chn;


typedef struct
{
	uchar type;
	int dev;
	int  (*init) ();
	void (*deinit) ();
	int  (*get_bytes) (void);
	void (*set_note) (int chan, int note);
	void (*set_patch) (int chan, int patch);
	void (*set_bend) (int chan, int bend);
	void (*set_volume) (int chan, int volume);
	void (*set_pan) (int chan, int pan);
	void (*set_offset) (int chan, int offset);
	void (*load_patches) (xm_module * xm);
	void (*ticker) (xm_module * xm);
}
driver;

int  fxmp_init (driver * d, int dev);
void fxmp_deinit ();
xm_module *xm_load (char *fn, int len);
void fxmp_play (xm_module * xm);
void fxmp_load_patches (xm_module * xm);
void fxmp_set_ord (int order);
unsigned short fxmp_get_ord (void);
int fxmp_get_bytes (void);
int fxmp_poll (xm_module * xm);

extern unsigned char globalvolume;
extern chn *channel;
extern driver *drv;

#endif
