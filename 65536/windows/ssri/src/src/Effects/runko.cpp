#include "runko.hpp"

void runko(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector campos = Vector(0, 0, -7.0f);
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	
}

void runko_init()
{
}

void runko_free()
{
}
