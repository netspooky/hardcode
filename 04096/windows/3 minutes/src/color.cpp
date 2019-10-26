#include <windows.h>
#include "color.h"

color create(float x, float y, float z)
{
	color v = { x, y, z };
	return v;
}

color add(color vec1, color vec2)
{
	color v = { vec1.p[0] + vec2.p[0], vec1.p[1] + vec2.p[1], vec1.p[2] + vec2.p[2] };
	return v;
}

color sub(color vec1, color vec2)
{
	color v = { vec1.p[0] - vec2.p[0], vec1.p[1] - vec2.p[1], vec1.p[2] - vec2.p[2] };
	return v;
}

color mul(color vec1, color vec2)
{
	color v = { vec1.p[0] * vec2.p[0], vec1.p[1] * vec2.p[1], vec1.p[2] * vec2.p[2] };
	return v;
}

color mul(color vec, float scal)
{
	color v = { vec.p[0] * scal, vec.p[1] * scal, vec.p[2] * scal };
	return v;
}

color clamp(color vec)
{
	color v = { max(0, min(1, vec.p[0])), max(0, min(1, vec.p[1])), max(0, min(1, vec.p[2])) };
	return v;
}

color sepia(color vec)
{
	float r = vec.p[0]*.500 + vec.p[1]*.770 + vec.p[2]*.300;
	float g = vec.p[0]*.349 + vec.p[1]*.686 + vec.p[2]*.168;
	float b = vec.p[0]*.300 + vec.p[1]*.506 + vec.p[2]*.131;
	color v = { r, g, b };
	return v;
}