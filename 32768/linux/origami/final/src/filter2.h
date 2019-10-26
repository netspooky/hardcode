#ifndef __FILTER2_H__
#define __FILTER2_H__

// Resonant filter 2

// Inputs:
// 0 - Input signal
// 1 - Cutoff modulation
// 2 - Resonance modulation
// Outputs:
// 0 - Filtered signal

typedef struct {
    output_signal out;
    input_signal in;

    float cutoff, resonance;

    float D1, D2;
    float f, q;
} Filter2;

Filter *filters2[10];
int n_filters2 = 0;

Filter *new_filter2(float cutoff, float resonance)
{
    Filter *fil = malloc(sizeof(Filter));
    make_conns(fil, 3, 1);

    fil->cutoff = cutoff;
    fil->resonance = resonance;

    fil->D1 = 0.0f;
    fil->D2 = 0.0f;
    fil->f = cutoff;
    fil->q = resonance;

    filters[n_filters++] = fil;
    return fil;
}

void process_filter2(Filter2 *fil)
{
    float out = fil->D2 + fil->f * fil->D1;
    fil->D1 = fil->f * (IN(fil, 0) - out - fil->q * fil->D1) + fil->D1;
    fil->D2 = out;

    OUT(fil, 0) = out;
}

#endif
