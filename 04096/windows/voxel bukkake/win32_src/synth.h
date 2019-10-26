#ifndef _SYNTH_H_
#define _SYNTH_H_

#define Uint8 unsigned char
#define Uint16 unsigned short int
#define Sint16 signed short int

#define BUFFER_SIZE 1024*8
#define HALF_BS 512
#define SAMPLE_RATE 44100.0f
#define invSAMPLE_RATE 0.000022675736961451248f

#define FLOAT2INTCAST(x) (*((int*)(&x)))
#define FLOAT2UINTCAST(x) (*((unsigned int*)(&x)))

#define PI_X 0x40490FDB
#define DOSPI_X 0x40C90FDB
#define PI_2_X 0x3FC90FDB

#define PI 3.14159265352f
#define PI_samplerate 0.000071237928652829774f
#define DOSPI 6.2831853071795862f
#define DOSPI_samplerate 0.00014247585730565955f


typedef struct _Instrument
{
	// Volume envelope
	Uint8 A, D, S, R; // En 1/100th de segundo salvo S que es vol*100 
	Uint8 sustain_time; // En 1/100th de segundo

	// Filter
	float cutoff; // >0 LP; <0 HP
	float resonance;
	float lfo_freq, lfo_amp;

	float square_detune;
	float saw_detune;

	float square_vol;
	float saw_vol;
	float noise_vol;

} Instrument;


typedef struct _Voice
{
	float pitch;
	int pos; // posicion en samples desde el inicio
	
	Instrument *ins;

	float vol;

	float xn[3];
	float yn[3];

	Uint8 active; // { 0 ==> inactiva, (not 0) ==> activa }

} Voice;

extern int synth(Voice *c, int len, float *mix_buf);
extern float whitenoise();

#endif
