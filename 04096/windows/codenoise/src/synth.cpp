#include <stdlib.h>
#include <math.h>

#include "synth.h"

int		__fastcall rand_4k(void);
#define ifmod(a,b) fmod_4k(a,b)
float	__fastcall fmod_4k (float, float);

float __fastcall getEnvelope(Envelope *e, float t)
{
	int i=0;
	float amp=0.0f;
	while(!(((int)(e->nodes[i].time)) < 0))
	//while(e->nodes[i].time > 0.00001f) // worse compression
	{
		if (t >= e->nodes[i].time)
		{
			// Linear interpolation
			float dx = e->nodes[i+1].time - e->nodes[i].time;
			float dy = e->nodes[i+1].amp - e->nodes[i].amp;
			amp = e->nodes[i].amp + (dy/dx)*(t - e->nodes[i].time);
		}
		++i;
	}

	return amp;
}

int __fastcall synth(Voice *v, int len, float *mix_buf)
{
	Instr *ins=v->ins;
	float *xn=v->xn;
	float *yn=v->yn;
	float t = (v->pos)/SAMPLE_RATE;
	float pitch1, pitch2, sin_omega, cos_omega, A0, A1, B1, B2, buf, volume;
	int   i;

	volume  = getEnvelope(ins->volume_envelope, t);
	volume *= v->chnvol;

	cos_omega = DOSPI_samplerate * getEnvelope(ins->filter_envelope, t);

	sin_omega = sin(cos_omega);
	sin_omega *= 0.5f;
	cos_omega = cos(cos_omega);

	B2 = 1.0f / (1.0f + sin_omega);

	A1 = (1.0f - cos_omega) * B2;
	A0 = 0.5f * A1;
	B1 = -2.0f * cos_omega * B2;
	B2 = (1.0f - sin_omega) * B2;

	pitch1 = v->pitch*ins->Osc1_Detune;
	pitch2 = 1.0f/v->pitch*ins->Osc2_Detune;

	for (i=0; i<len; ++i)
	{
		t=(i+v->pos)/SAMPLE_RATE;

		// Sawtooth + Noise					(todo en uno, oiga - shash)
		// Compresses better, dunno why
		buf =	((ifmod(t*pitch1, 1.0f) - 1.0f) * ins->Osc1_Vol)
				+ (rand_4k()/(float)RAND_MAX)*ins->NoiseVol;

		// Square
		if ( ifmod( t, pitch2)*2.0f > pitch2 )
			buf -= ins->Osc2_Vol;
		else
			buf += ins->Osc2_Vol;

		xn[0] = buf * volume;// * chanvol;
		buf = A0*(xn[0]+xn[2]) + A1*xn[1] /*+ A0*xn[2]*/ - B1*yn[1] - B2*yn[2];

		xn[2]=xn[1];
		xn[1]=xn[0];
		yn[2]=yn[1];
		yn[1]=buf;
		
		mix_buf[i] += buf;
	}

	v->pos += len;

	return (volume!=0.0f);
}