#ifndef COLOR_H
#define COLOR_H

struct color
{
	float p[3];
};


color create(float x, float y, float z);
color add(color vec1, color vec2);
color sub(color vec1, color vec2);
color mul(color vec1, color vec2);
color mul(color vec, float scal);
color clamp(color vec);
color sepia(color vec);
#endif