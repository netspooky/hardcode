#ifndef _NEURONIT_HPP_
#define _NEURONIT_HPP_

#include "../stuff.hpp"

struct Neuron
{
	Vector pos;
	
	int linkcount;
	int *links;
	Vector *displacements;
};

void neuronit(float aika);
void neuronit_init();
void neuronit_free();

#endif
