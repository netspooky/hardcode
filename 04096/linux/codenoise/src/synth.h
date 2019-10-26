/* 
  *      Copyright (C) 2004 Jorge Gorbe Moya <slack@frikis.org>
  *
  *
  *      This program is free software; you can redistribute it and/or modify
  *      it under the terms of the GNU General Public License version 2, as 
  *      published by the Free Software Foundation.
  *
  *      This program is distributed in the hope that it will be useful,
  *      but WITHOUT ANY WARRANTY; without even the implied warranty of
  *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *      GNU General Public License for more details.
  *
  *      You should have received a copy of the GNU General Public License
  *      along with this program; if not, write to the
  *      Free Software Foundation, Inc.,
  *      59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */



#ifndef SYNTH_H
#define SYNTH_H

#define BUFFER_SIZE 1024
#define HALF_BS 512
#define SAMPLE_RATE 44100.0f
#define PI 3.14159265352f
#define DOSPI 6.2831853071795862f
#define DOSPI_samplerate 0.00014247585730565955f


typedef struct EnvelopeNode_STRUCT
{
	float time;
	float amp;
} EnvelopeNode;

typedef struct Envelope_STRUCT
{
	EnvelopeNode *nodes;
} Envelope;

typedef struct Instr_STRUCT
{
	float Osc1_Vol;
	float Osc1_Detune;
	
	float Osc2_Vol;
	float Osc2_Detune;

	float NoiseVol;

	Envelope *volume_envelope;
	Envelope *filter_envelope;

} Instr;

typedef struct Channel_STRUCT
{
	float cutoff;
	float vol;
} Channel;

typedef struct Voice_STRUCT
{
	int active;
	float pitch;

	float xn[3];
	float yn[3];

	int pos; // en samples
	Instr *ins;
	Channel *chn;
} Voice;

extern int synth(Voice *c, int len, float *mix_buf);


#endif
