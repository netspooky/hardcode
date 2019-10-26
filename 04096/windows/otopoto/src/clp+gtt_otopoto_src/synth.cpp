/*
	This file is part of "otopoto / Collapse & Gatitos".

    "otopoto / Collapse & Gatitos" is free software: you can redistribute
	it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

    "otopoto / Collapse & Gatitos" is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "otopoto / Collapse & Gatitos".  If not, see 
	<http://www.gnu.org/licenses/>.
*/

#include "defines.h"
#include "port.h"
#include "synth.h"
#include <string.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

extern float current_time;

#pragma code_seg ("code_detune")
float detune(float base, int coarse, int fine)
{
    return base*powf(2.0f, (coarse+(fine/100.0f))/12.0f);
}

#pragma code_seg ("code_synth")
void synth(Voice *v, int len, float *mix_buf)
{
    if (!v->ins) return;

    if (v->pos < 0) {
        mix_buf -= v->pos;
        len += v->pos;
        v->pos = 0;
    }

    int iPC=0; // instrument program counter
    int wave=0;
    for (;;) {
        uint8 ins = v->ins[iPC++];
        uint8 op1 = v->ins[iPC++];
        int8 op2 = v->ins[iPC++];
        //printf("wave %d, ins=%d (%d, %d)\n", wave, ins, op1, op2);
        for (int i=0; i<len; i++) {
            float pitch = detune(v->pitch, (int8) op1, 0);
            float time=(v->pos+i)*invSAMPLE_RATE;
            float pw = op2/100.0f;
            float period = 1.0f/pitch; // wave period (in seconds)
            float op1_sample = v->waves[wave-op1][i];
            float prev_sample = v->waves[wave-1][i];
            switch (ins) {
                case CONST:
                    {
                        // op1: integer part, op2: decimal part * 100
                        float value = op1 + pw;
                        v->waves[wave][i] = value;
                        break;
                    }
                case SQUARE:
                    {
                        // op1: signed coarse detune, op2: pulse width (%)
                        if (fmodf(time, period) < (period*pw))
                            v->waves[wave][i] = 1.0f;
                        else
                            v->waves[wave][i] = -1.0f;
                        break;
                    }
                case TRIANGLE:
                    {
                        float half_period = pw*period;
                        float t = fmodf(time,period);
                        if (t < half_period)
                            v->waves[wave][i] = 2.0f*(t/half_period)-1.0f;
                        else {
                            v->waves[wave][i] = 1.0f-2.0f*(t-half_period)/(period-half_period);
                        }
                        break;
                    }
                case NOISE:
                    v->waves[wave][i] = 2.0f*(rand()/(float)RAND_MAX)-1.0f;
                    break;

                case SUM:
                    v->waves[wave][i] = op1_sample + prev_sample;
                    break;
                case MUL:
                    v->waves[wave][i] = op1_sample * prev_sample;
                    break;

                case LPF:
                    {
                        // op1, op2: cutoff(wave), resonance
                        float input = prev_sample;
                        float cutoff = op1_sample;
                        float r = op2/10.0f;
                        //printf("op1=%d, op2=%d, cutoff=%f; r=%f\n", op1, op2, cutoff, r);

                        float *data = (float*)v->data[wave];
                        // data[0-3] == pole1..pole4
                        // Arif Ove Karlsen's 24dB Ladder Approximation, 3.nov 2007
                        // http://musicdsp.org/showArchiveComment.php?ArchiveID=141
                        float rez = data[3]*r; if (rez > 1.0f) rez = 1.0f;
                        input = input-rez;
                        data[0] = data[0] + ((-data[0]+input)   * cutoff);
                        data[1] = data[1] + ((-data[1]+data[0]) * cutoff);
                        data[2] = data[2] + ((-data[2]+data[1]) * cutoff);
                        data[3] = data[3] + ((-data[3]+data[2]) * cutoff);

						v->waves[wave][i] = data[3];
                        break;
                    }
                case SIGMOID:
                    {
                        float f = (float)((int8)op1);
                        float d = op2/10.0f;
                        v->waves[wave][i] = 1.0f - 1.0f/(1.0f+expf(-f*(time-d)));
                        break;
                    }

                default:
                    goto end;
            }
        }
        ++wave;
    }

end:
    v->pos+=len;
    for (int i=0; i<len; i++)
        mix_buf[i] += v->waves[wave-1][i]*v->vol;

}


