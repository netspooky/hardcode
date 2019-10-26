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

#include "synth.h"
#include "dl_init.h"
#include <stdlib.h>

//#include <math.h>
#define msin(x) __builtin_sinf(x)
#define mcos(x) __builtin_cosf(x)
#define mfmodf(x,y) fn.fmodf(x,y)

float getEnvelope(Envelope *e, float t)
{
	int i=0;
	float amp=0.0f;
	while(!(*((int *)&(e->nodes[i].time)) & 0x80000000))
	{
		if (t >= e->nodes[i].time)
		{
			// interpolacion lineal
			float dx = e->nodes[i+1].time - e->nodes[i].time;
			float dy = e->nodes[i+1].amp - e->nodes[i].amp;
			amp = e->nodes[i].amp + (dy/dx)*(t - e->nodes[i].time);
		}
		++i;
	}
	return amp;
}

static float buf[BUFFER_SIZE];

int synth(Voice *v, int len, float *mix_buf)
{
	Instr *ins=v->ins;
	Channel *chn=v->chn;
	float pitch1, pitch2, chanvol;

	float cutoff, omega, sin_omega, cos_omega, alpha, scalar, A0, A1, A2, B1, B2;
	float *xn=v->xn;
	float *yn=v->yn;
	const float resonance=1.0f;
	
	int i;
	int start=v->pos;
	
	float t,wop;

	// Preparamos el filtro de la pradera
	t=(float)(start)/SAMPLE_RATE;

	//__builtin_printf("ins=%p chn=%p\n", ins, chn);
	cutoff = getEnvelope(ins->filter_envelope, t);
	/*	
	if (cutoff > chn->cutoff)
	{
		cutoff=chn->cutoff;
	}
	*/
	
	omega = DOSPI_samplerate * cutoff;

#ifdef X86_ASM
	asm ("fsincos" : "=t" (cos_omega), "=u" (sin_omega) : "0" (omega));
#else
	sin_omega=msin(omega);
	cos_omega=mcos(omega);
#endif


	alpha = sin_omega / (2.0f * resonance);

	scalar = 1.0f / (1.0f + alpha);

	A1 = (1.0f - cos_omega) * scalar;
	A0 = 0.5f * A1;
	A2 = A0;
	B1 = -2.0f * cos_omega * scalar;
	B2 = (1.0f - alpha) * scalar;


	pitch1=v->pitch*ins->Osc1_Detune;
	pitch2=v->pitch*ins->Osc2_Detune;
	
	chanvol=chn->vol;

	wop = 1.0f/pitch2;


	for (i=0; i<len; ++i)
        {
                t=((float)(i+start))/SAMPLE_RATE;
                // Sawtooth
                buf[i] = (mfmodf(t*pitch1, 1.0f) - 1.0f) * ins->Osc1_Vol;

                // Square
                if ( mfmodf( t, wop) > (wop/2.0f) )
                        buf[i] -= ins->Osc2_Vol;
                else
                        buf[i] += ins->Osc2_Vol;
		// Noise
		buf[i] += (fn.rand()/(float)RAND_MAX)*ins->NoiseVol;
	
		buf[i] *= getEnvelope(ins->volume_envelope, t) * chanvol *0.5;

		
                xn[0] = buf[i];
                yn[0] = A0*xn[0] + A1*xn[1] + A2*xn[2]- B1*yn[1] - B2*yn[2];
                buf[i] = yn[0];

                xn[2]=xn[1];
                xn[1]=xn[0];
                yn[2]=yn[1];
                yn[1]=yn[0];
		

		//printf("%f - %f = ",buf[i-1], buf[i]);

		//buf[i]=(buf[i-1]-buf[i]);

		//printf("%f\n", buf[i]);
		mix_buf[i] += buf[i];
        }
	v->pos+=len;
	return (getEnvelope(ins->volume_envelope,t)!=0.0f);

}
