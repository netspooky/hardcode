#include "alku.hpp"

void writer(Vector kohta, Vector color, float scale, float aika, float starttime, float endtime, 
			float alpha, char *teksti, char *teksti2)
{

}



void alku(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 6);
	glLoadIdentity();
	glTranslatef(0, 0, -5);

	const float glow = 0.9f+0.2f*(float)sin(aika*45);
	const float t1 = calcSaturate(aika, 0.1f, 0.45f, 2)*glow;
	const float t2 = calcSaturate(aika, 0.55f, 0.90f, 2)*glow;

	glDisable(GL_DEPTH_TEST);
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glColor4f(0.8f, 0.5f, 0.2f, t1*alpha);
	font_write(-0.7f, -0.15f, "Traction");
	glColor4f(0.8f, 0.5f, 0.2f, t2*alpha);
	font_write(-1.2f, -0.15f, "Preacher + Grip");
}

void alku_init()
{
}

void alku_free()
{
} 
