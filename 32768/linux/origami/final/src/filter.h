#ifndef __FILTER_H__
#define __FILTER_H__

// Resonant filter

// Inputs:
// 0 - Input signal
// 1 - Cutoff modulation
// 2 - Resonance modulation
// Outputs:
// 0 - Filtered signal

enum {FILTER_IN_SIGNAL, FILTER_MOD_CUTOFF, FILTER_MOD_RESONANCE};
enum {FILTER_OUT_SIGNAL};

enum {LP, HP, BP, BR};

typedef struct {
    output_signal out;
    input_signal in;
    
    int type;
    float cutoff, resonance;

    float D1, D2;
    float f, q;
} Filter;

Filter *filters[25];
int n_filters = 0;

Filter *new_filter(int type, float cutoff, float resonance)
{
    Filter *fil = malloc(sizeof(Filter));
    make_conns(fil, 3, 1);

    fil->cutoff = cutoff;
    fil->resonance = resonance;
    fil->type = type;

    fil->D1 = 0.0f;
    fil->D2 = 0.0f;
    fil->f = cutoff;
    fil->q = resonance;

    filters[n_filters++] = fil;
    return fil;
}

void process_filter(Filter *fil)
{
    // cutoff modulation
    float f = fil->f * IN(fil, 1);

    float out = fil->D2 + f * fil->D1;
    float hpout = IN(fil, 0) - out - (fil->q * fil->D1);
    fil->D1 = f * hpout + fil->D1;
    fil->D2 = out;

    switch (fil->type){
    case LP:
	OUT(fil, 0) = out;
	break;
    case HP:
	OUT(fil, 0) = hpout;
	break;
    case BP:
	OUT(fil, 0) = fil->D1;
	break;
    }
}

#endif
