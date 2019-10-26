/* Credits */

#include "alku.hpp"

void alku_init()
{
}

void alku_free()
{
}

void alku(float aika)
{
	const float blend1 = calcSaturate(aika, 0.15f, 0.35f, 2);
	const float blend2 = calcSaturate(aika, 0.20f, 0.40f, 2);
	const float blend3 = calcSaturate(aika, 0.22f, 0.42f, 2);
	const float blend4 = calcSaturate(aika, 0.24f, 0.44f, 2);

	glColor4f(blend1, blend1, blend1, blend1);
	font_write(-0.4f, 0, "Traction as");
	glColor4f(blend2, blend2, blend2, blend2);
	font_write(0.0f, -0.00f, "Preacher");
	glColor4f(blend3, blend3, blend3, blend3);
	font_write(0.0f, -0.07f, "Kofeiini");
	glColor4f(blend4, blend4, blend4, blend4);
	font_write(0.0f, -0.15f, "Grip");
	
	const float blend5 = calcSaturate(aika, 0.5f, 0.9f, 2);
	if (aika > 0.5f)
	{
		glColor4f(blend5, blend5, blend5, blend5);
		font_write(-0.17f, 0.0f, "\"Fiat Homo\"");
	}
}
