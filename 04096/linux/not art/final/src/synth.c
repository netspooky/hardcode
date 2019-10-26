#include "synth.h"
#include "dl_init.h"
#include <stdlib.h>

#define msin(x) __builtin_sinf(x)
#define mcos(x) __builtin_cosf(x)
#define mfmodf(x,y) fn.fmodf(x,y)

extern float current_time;

float mtan(float x)
{
	float sin_x, cos_x;
	#ifdef X86_ASM
                __asm__("fsincos" : "=t" (cos_x), "=u" (sin_x) : "0" (x));
        #else
                sin_x=msin(x);
                cos_x=mcos(x);
        #endif

	return sin_x/cos_x;
}


// Computes ADSR value for instrument i at time pos - linear interpolation
float getAmp(Instrument *i, float pos)
{
	if (pos <= i->A)
		return (pos/i->A);
	
	pos -= i->A;

	if (pos <= i->D)
		return (1.0f-(pos * (1.0f - i->S)) / i->D);

	pos -= i->D;

	if (pos <= i->sustain_time)
		return i->S;

	pos -= i->sustain_time;

	if (pos < i->R)
		return i->S - i->S * (pos/i->R);
	else
		return 0;
}

int synth(Voice *v, int len, float *mix_buf)
{
	Instrument *ins=v->ins;
	//float pitch_sine  = v->pitch * ins->sine_detune;
	float pitch_square= v->pitch * ins->square_detune;
	float pitch_saw   = v->pitch * ins->saw_detune;
	float vol, res, t;
	int i;

	float periodo_square = 1.0f/pitch_square;

	for (i=0; i<len; ++i)
	{
		res=0;
		t=(v->pos+i)*invSAMPLE_RATE;
		
		// Sine
		//res = ins->sine_vol * msin(DOSPI*pitch_sine*t);
		
		
		// Square
		if (mfmodf(t, periodo_square) > (periodo_square/2.0f))
			res += ins->square_vol;
		else
			res -= ins->square_vol;
		
		// Saw
		res += ins->saw_vol * (mfmodf(t*pitch_saw, 2.0f) - 1.0f);
		
		// Noise
		res += ins->noise_vol*(2.0f*(fn.rand()/(float)RAND_MAX)-1.0f) ;
		
		// ADSR
		vol = getAmp(ins, t);
		res *= vol;

		// LFO for filter cutoff
		float cutoff;
		cutoff= ins->cutoff + ins->lfo_amp * mcos(DOSPI * ins->lfo_freq * t);

		float r = ins->resonance;
		// Filter coefs
		float c, c2,a1,a2,b1,b2;
		
		float param_tan = PI_samplerate * cutoff;

		//if (cutoff > 0.0f) // Low-pass
		//{
			c=1.0f / mtan(param_tan);
			c2 = c*c;

			a1 = 1.0f / ( 1.0f + r * c + c2);
			a2 = 2.0f * a1;
			b1 = 2.0f * ( 1.0f - c2) * a1;
		//}
		/*
		else // High-pass
		{
			c = mtan(-param_tan);
			c2 = c*c;

			a1 = 1.0f / ( 1.0f + r * c + c2);
			a2 = -2*a1;
			b1 = 2.0f * ( c2 - 1.0f) * a1;
		}
		*/
		b2 = ( 1.0f - r * c + c2) * a1;

                v->yn[0] = a1*res + a2*v->xn[1] + a1*v->xn[2] -
				b1*v->yn[1] - b2*v->yn[2];

                v->xn[2]=v->xn[1];
                v->xn[1]=res;
                v->yn[2]=v->yn[1];
                v->yn[1]=v->yn[0];

		mix_buf[i] += v->yn[0] * v->vol;
	}

	v->pos+=len;

	if (vol > 0.0f)
		return 1;
	return 0;
}
