#ifndef __MULTIPLIER_H__
#define __MULTIPLIER_H__

// N-input multiplier
// 0 .. n - Inputs
// Outputs:
// 0 - Product

typedef struct {
    output_signal out;
    input_signal in;

    int n_inputs;
} Multiplier;

Multiplier *multipliers[20];
int n_multipliers = 0;

Multiplier *new_multiplier(int inputs)
{
    Multiplier *mul = malloc(sizeof(Multiplier));
    make_conns(mul, inputs, 1);

    mul->n_inputs = inputs;

    multipliers[n_multipliers++] = mul;
    return mul;
}

void process_multiplier(Multiplier *mul)
{
    int i;
    float out = 1;
    for (i=0; i<mul->n_inputs; i++){
	out *= IN(mul, i);
    }

    OUT(mul, 0) = out;
}

#endif
