#ifndef SYNTH_H
#define SYNTH_H

#define BUFFER_SIZE 1024*8
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

/*
typedef struct Channel_STRUCT
{
	float cutoff;
	float vol;
} Channel;
*/

typedef struct Voice_STRUCT
{
	int active;
	float pitch;

	float xn[3];
	float yn[3];

	int pos; // en samples
	Instr *ins;
	float chnvol;
} Voice;

//extern int synth(Voice *c, float *mix_buf);
int __fastcall synth(Voice *v, int len, float *mix_buf);


#endif
