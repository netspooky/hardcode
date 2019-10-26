/*
   Voxel Bukkake - A 4k intro for BCNparty'101.
   Copyright (C) 2005 Jorge Gorbe (aka slack/Necrostudios)

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License version 2
   as published by the Free Software Foundation.
*/

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

// Devuelve el valor del ADSR en el tiempo pos
// Interpolacion lineal
float getAmp(Instrument *i, float pos)
{
	//return 1-3*pos;
	float A=i->A/100.0f+0.00001;
	if (pos <= A)
		return (pos/A);
	
	pos -= A;
	
	float D=i->D/100.0f;
	float S=i->S/100.0f;
	if (pos <= D)
		return (1.0f-(pos * (1.0f - S)) / D);

	pos -= D;

	float sustain_time=i->sustain_time/100.0f;
	if (pos <= sustain_time)
		return S;

	pos -= sustain_time;
	
	float R=i->R/100.0f;
	if (pos < R)
		return S - S * (pos/R);
	else
		return 0;
}

float whitenoise()
{
	return fn.rand()/(float)RAND_MAX;
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
		// En primer lugar sumamos los osciladores
		
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
		res += ins->noise_vol*(2.0f*whitenoise()-1.0f) ;
		
		// Ahora aplicamos el ADSR
		vol = getAmp(ins, t);
		res *= vol;

		//__builtin_printf("%f\t%f\n", t,getAmp(ins,t));
		
		
		// Calculamos el valor del cutoff aplicando LFO
		float cutoff, lfo_freq;
		if (ins->lfo_freq < 0)
		{
			lfo_freq=-ins->lfo_freq;
			t=current_time;
		}
		else
		{
			lfo_freq=ins->lfo_freq;
		}
		cutoff= ins->cutoff + ins->lfo_amp * mcos(DOSPI * lfo_freq * t);

		float r = ins->resonance;
		// Calculamos los coeficientes del filtro
		float c, c2,a1,a2,b1,b2;
		
		// Extraemos algunos calculos que son redundantes en HP y LP
		float param_tan = PI_samplerate * cutoff;

		if (cutoff > 0.0f) // Low-pass
		{
			c=1.0f / mtan(param_tan);
			c2 = c*c;

			a1 = 1.0f / ( 1.0f + r * c + c2);
			a2 = 2.0f * a1;
			b1 = 2.0f * ( 1.0f - c2) * a1;
		}
		
		else // High-pass
		{
			c = mtan(-param_tan);
			c2 = c*c;

			a1 = 1.0f / ( 1.0f + r * c + c2);
			a2 = -2*a1;
			b1 = 2.0f * ( c2 - 1.0f) * a1;
		}
		
		b2 = ( 1.0f - r * c + c2) * a1;

                v->yn[0] = a1*res + a2*v->xn[1] + a1*v->xn[2] -
				b1*v->yn[1] - b2*v->yn[2];

                v->xn[2]=v->xn[1];
                v->xn[1]=res;
                v->yn[2]=v->yn[1];
                v->yn[1]=v->yn[0];

		// A partir de aqui res ya esta filtrado
		//res = v->yn[0];
		
		mix_buf[i] += v->yn[0] * v->vol;
	}

	v->pos+=len;

	//vol=getAmp(ins,t);
	//__builtin_printf("active=%f\n", t);	
	if (vol > 0.0f)
		return 1;
	return 0;
}
