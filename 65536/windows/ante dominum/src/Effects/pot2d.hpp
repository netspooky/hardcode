#ifndef _POT2D_HPP_
#define _POT2D_HPP_

#include "../stuff.hpp"

void pot2d_clear(float *dest);
void pot2d_func1(float aika, float mul, float *dest);
void pot2d_func2(float aika, float mul, float *dest);

void pot2d(float aika);
void pot2d_init();
void pot2d_free();

#endif 
