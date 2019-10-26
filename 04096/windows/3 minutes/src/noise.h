#ifndef NOISE_H
#define NOISE_H

#include "color.h"
#include "helper.h"

float Noise2d(int x, int y, int octave, int seed);
float SmoothNoise(int x, int y, int octave, int seed);
float Interpolate(float x, float y, float param);
float PNoise(float x, float y, int seed);

#endif