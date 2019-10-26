#ifndef __DELAY_H__
#define __DELAY_H__

#include "syn_types.h"

// Fractional mono delay line with linear interpolation

// Inputs:
// 0 - signal
// 1 - delay length in seconds

// Outputs:
// 0 - delayed signal

enum {DELAY_IN_SIGNAL, DELAY_IN_LEN};
enum {DELAY_OUT_SIGNAL};

typedef struct {
    output_signal out;
    input_signal in;

    int line_len;
    int fractional;
    float *line;
    int pos;
} Delay;

Delay *delays[10];
int n_delays = 0;

Delay *new_delay(float max_len, int frac)
{
    Delay *del = malloc(sizeof(Delay));
    int len_samples = (int)(max_len * SRATE) + 1;
    int i;
    make_conns(del, 2, 1);

    del->line = malloc(len_samples*sizeof(float)); // samples in delay line
    for (i=0; i<len_samples; i++){
	del->line[i] = 0.0f;
    }
    del->line_len = len_samples;
    del->pos = 0;
    del->fractional = frac;

    delays[n_delays++] = del;
    return del;
}

void process_delay(Delay *del)
{
    float s1, s2;
    float delay_samples = SRATE * IN(del, 1);
    int delay_fixed = (int)(delay_samples * 256);
    int delay_whole = delay_fixed >> 8;
    float delay_frac = (delay_fixed  - (float)delay_whole * 256) / 256;
    
    // put input to delay line
    //del->line[del->pos += --del->pos < 0 ? del->line_len - 1: -1] = IN(del, 0);
    del->line[del->pos--] = IN(del, 0);
    if (del->pos < 0){
	del->pos = del->line_len - 1;
    }

    if (del->fractional){
	// fetch samples    
	s1 = del->line[(del->pos + delay_whole) % del->line_len];
	s2 = del->line[(del->pos + delay_whole + 1) % del->line_len];

	// write linearly interpolated value to output
	OUT(del, 0) = s2 * delay_frac + s1 * (1 - delay_frac);
    } else{	
	OUT(del, 0) = del->line[(del->pos + delay_whole) % del->line_len];
    }
}

#endif
