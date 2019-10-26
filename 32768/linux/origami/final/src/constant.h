#ifndef __CONSTANT_H__
#define __CONSTANT_H__

// Constant

// Inputs:

// Outputs:
// 0 - value

typedef struct {
    output_signal out;
    input_signal in;
} Constant;

Constant *new_constant(float value)
{
    Constant *cnst = malloc(sizeof(Constant));
    make_conns(cnst, 1, 1);
    
    OUT(cnst, 0) = value;
    return cnst;
}

// no need to process

#endif
