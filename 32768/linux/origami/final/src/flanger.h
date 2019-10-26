#ifndef __FLANGER_H__
#define __FLANGER_H__

#include "delay.h"
#include "oscillator.h"
#include "connect.h"

// Flanger

// Inputs:
// 0 - input signal
// 1 - frequency (Hz)
// 2 - depth (seconds)
// 3 - mix

// Outputs:
// 0 - output signal


typedef struct {
    output_signal out;
    input_signal in;
} Flanger;

Flanger *flangers[10];
int n_flangers = 0;

Flanger *new_flanger()
{
    Flanger *fln = malloc(sizeof(Flanger));
    Oscillator *lfo = new_oscillator(TRIANGLE, 1.0f, 1.0f);
    Delay *del = new_delay(0.1f);
    Adder *add = new_adder(2);

    make_conns(fln, 3, 1);

    connect(lfo, 0, add, 0);
    connect(add, 0, del, 1);

    flangers[n_flangers++] = fln;
    return fln;
}

void process_flanger(Flanger *fln)
{
}

#endif
