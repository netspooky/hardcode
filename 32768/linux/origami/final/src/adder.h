#ifndef __ADDER_H__
#define __ADDER_H__

// N-input adder

// Inputs:
// 0 .. n - Values
// Outputs:
// 0 - Sum

typedef struct {
    output_signal out;
    input_signal in;
    
    int n_inputs;
} Adder;

Adder *adders[20];
int n_adders = 0;

Adder *new_adder(int inputs)
{
    Adder *add = malloc(sizeof(Adder));
    make_conns(add, inputs, 1);

    add->n_inputs = inputs;

    adders[n_adders++] = add;
    return add;
}

void process_adder(Adder *add)
{
    int i;
    float out = 0;
    for (i=0; i<add->n_inputs; i++){
	out += IN(add, i);
    }

    OUT(add, 0) = out;
}

#endif
