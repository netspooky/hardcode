#ifndef __OVERDRIVE__
#define __OVERDRIVE__

#include "syn_types.h"

// Inputs:
// 0 - signal

// Outputs:
// 0 - signal

typedef struct {
    output_signal out;
    input_signal in;
} Overdrive;

Overdrive *overdrives[10];
int n_overdrives = 0;

Overdrive *new_overdrive()
{
    Overdrive *od = malloc(sizeof(Overdrive));
    make_conns(od, 1, 1);

    overdrives[n_overdrives++] = od;
    return od;
}

void process_overdrive(Overdrive *od)
{
    OUT(od, 1) = IN(od, 1);
}

#endif
