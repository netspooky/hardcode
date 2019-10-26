/*
  fxmp.h - fxmp header
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

#ifndef __FXMP_H__
#define __FXMP_H__

#include "types.h"
#include "config.h"

#define FXMP_VERSION "0.0.21"

#define FXMP_DRV_SEQ 1
#define FXMP_DRV_DSP 2
#define FXMP_DRV_WIN 3

#define FXMP_LOOP_MASK 0x03
#define FXMP_LOOP_NONE 0
#define FXMP_LOOP_FORWARD 1
#define FXMP_LOOP_PINGPONG 2
#define FXMP_SAMPLE_16BIT 0x10

#define FXMP_TYPE_SOFTWARE 0
#define FXMP_TYPE_HARDWARE 1

#define FXMP_BUFFER_SIZE 16384
#define FXMP_SAMPLE_RATE 44100

typedef struct _fxmp_panel fxmp_panel;
typedef struct _fxmp_note fxmp_note;
typedef struct _fxmp_patheader fxmp_patheader;
typedef struct _fxmp_sample fxmp_sample;
typedef struct _fxmp_envpoint fxmp_envpoint;
typedef struct _fxmp_inst fxmp_inst;
typedef struct _fxmp_module fxmp_module;
typedef struct _fxmp_channel fxmp_channel;
typedef struct _fxmp_driver fxmp_driver;
typedef struct _fxmp_player fxmp_player;

typedef struct _fxmp_panel
{
  uchar l, r;       /* volume for left & right channels */
}
_fxmp_panel;        /* pan element :) */

typedef struct _fxmp_note
{
  uchar note;
  uchar inst;
  uchar vol;
  uchar fx;
  uchar parm;
}
_fxmp_note;

typedef struct _fxmp_patheader
{
  ulong length;
  uchar packtype;
  ushort numrows;
  ushort size;
}
_fxmp_patheader;

typedef struct _fxmp_sample
{
  ulong length;
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
  uchar patchnr; 		/* added by smoke ! */
}
_fxmp_sample;

typedef struct _fxmp_envpoint
{
  ushort pos;
  ushort val;
}
_fxmp_envpoint;

typedef struct _fxmp_inst
{
  ulong hdrsize;
  uchar name[22];
  uchar type;

  ushort n_samples;
  ulong sample_hdrsize;
  uchar sample_of[96];
  fxmp_envpoint volenv[12];
  fxmp_envpoint panenv[12];
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
  ushort volfade;
  ushort reserved;
  fxmp_sample *sample;
  /* internal player variables */
  uchar *static_volenv;
  uchar *static_panenv;
  ushort static_volsustain;
  ushort static_volloopstart;
  ushort static_volloopend;
  ushort static_pansustain;
  ushort static_panloopstart;
  ushort static_panloopend;
}
_fxmp_inst;

typedef struct _fxmp_module
{
  uchar header[17];
  uchar songname[20];
  uchar id;
  uchar tracker[20];
  ushort trver;
  ulong hdrsize;
  ushort songlen;
  ushort restartpos;
  ushort n_chans;
  ushort n_pats;
  ushort n_insts;
  ushort flags;
  ushort speed;
  ushort bpm;
  uchar order[256];
  fxmp_patheader *patheader;
  fxmp_note **pattern;
  fxmp_inst *inst;
}
_fxmp_module;

typedef struct _fxmp_channel
{
  uchar id;

  uchar note;
  sshort inst, oldinst;
  slong period, old_period;
  ulong freq;

  uchar sample_num;
  slong sample_pos; 		/* 24.8 fixed */
  slong sample_inc; 		/* 24.8 fixed */
  slong sample_len;
  slong sample_start;
  slong sample_end;

  uchar keyoff;
  uchar pingpong;
  schar finetune;
  schar volume;
  ushort volfade;
  ushort volfade_dec;
  sshort pan;
  uchar type;

  uchar oldparm[20]; 			/* last non-zero fx parameter for each fx */
  uchar flags;
  /*
     flags:
     bit 1 - update freq
  */

  /* tick based fx related */
  uchar arpeggio;

  uchar vibrato_wave;
  schar vibrato_pos;
  uchar vibrato_speed;
  uchar vibrato_depth;

  uchar tremolo_wave;
  schar tremolo_pos;
  uchar tremolo_speed;
  uchar tremolo_depth;

  schar volumeslide;
  uchar portaup;
  uchar portadown;
  ulong portanote_period;
  uchar portanote_speed;
  uchar glissando;
  uchar cutnote;

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

  int hit;        /* note hit for the first time boolean */
  int pitchbend;

  /* current sample/instrument pointers (to pass to drv funcs directly) */
  fxmp_inst *insptr;
  fxmp_sample *smpptr;
}
_fxmp_channel;

typedef struct _fxmp_driver
{
  uchar type;
  int dev;
  int (*init) (fxmp_player *p);
  void (*deinit) (fxmp_player *p);
  void (*set_note) (fxmp_channel *chan, int note);
  void (*set_patch) (fxmp_channel *chan, int patch);
  void (*set_bend) (fxmp_channel *chan, int bend);
  void (*set_volume) (fxmp_channel *chan, int volume);
  void (*set_pan) (fxmp_channel *chan, int pan);
  void (*set_offset) (fxmp_channel *chan, int offset);
  void (*load_patches) (fxmp_player *p);
  void (*ticker) (fxmp_player *p);
}
_fxmp_driver;

typedef struct _fxmp_player
{
  ushort ord, pat, row, tick, tord, trow;
  fxmp_panel pantable[256];
  uchar global_volume;
  uchar global_volumeslide;
  int speed;

  fxmp_module *module;
  fxmp_driver *driver;
  fxmp_channel *channel;
}
_fxmp_player;

#include "load_xm.h"
#include "freq.h"
#include "ticker.h"

extern schar verbose;

int fxmp_init (fxmp_player *p, fxmp_driver *d, int dev);
void fxmp_deinit (fxmp_player *p);
int fxmp_play (fxmp_player *p);
void fxmp_load_patches (fxmp_player *p);
void fxmp_set_order (fxmp_player *p, int order);

#define fxmp_poll fxmp_ticker

#endif
