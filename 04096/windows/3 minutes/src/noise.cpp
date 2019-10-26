#include "noise.h"

float Noise2d(int x, int y, int octave, int seed)
{
	int n = (x + octave * 100) + (y + octave * 200) * 570000 + seed * 200;
	n = (n << 13) ^ n;
	return (1.0f - ((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0);
}

float SmoothNoise(int x, int y, int octave, int seed)
{
    return (Noise2d(x, y, octave, seed) + Noise2d(x - 1, y, octave, seed) + Noise2d(x + 1, y, octave, seed) + Noise2d(x, y - 1, octave, seed) +
                    Noise2d(x, y + 1, octave, seed)) * 0.19;
}

float Interpolate(float x, float y, float param)
{
    return x * (1 - param) + y * param;
}

float PNoise(float x, float y, int seed)
{
	int Octaves = 3;
	x /= 1000;
	y /= 1000;
	float amplitude = 1, total = 0, frequency = 1, persistence = 0.55f;

	int i;

	for (i = 0; i < Octaves; i++)
	{
		int intX, intY;
		float fractX, fractY, v1, v2, v3, v4, i1, i2;

		x *= frequency;
		y *= frequency;
	    intX = MYFLOORF(x);
		intY = MYFLOORF(y);
		fractX = x - intX;
		fractY = y - intY;
		if (fractX < 0.0)
			fractX += 1.0f;
		if (fractY < 0.0f)
			fractY += 1.0f;
		v1 = SmoothNoise(intX, intY, i, seed);
		v2 = SmoothNoise(intX + 1, intY, i, seed);
		v3 = SmoothNoise(intX, intY + 1, i, seed);
		v4 = SmoothNoise(intX + 1, intY + 1, i, seed);
		i1 = Interpolate(v1, v2, fractX);
		i2 = Interpolate(v3, v4, fractX);
		total = total + Interpolate(i1, i2, fractY) * amplitude;
		amplitude *= persistence;
		frequency *= 2;
	}

	return total * 0.5 + 0.5;
}