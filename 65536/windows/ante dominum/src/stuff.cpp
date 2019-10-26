#include "stuff.hpp"

void perspective2D(float width, float height)
{
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();	
	glOrtho(0,width, 0,height,-1,1);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix(); 
	glLoadIdentity();
}
void perspective3D()
{
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
}

const bool testaaPos(const int aika, const int ajat[])
{
	int alku = ajat[0];
	int loppu = ajat[1];

	if (aika >= alku && aika <= loppu)
		return true;
	else 
		return false;
}

const float laskePos(const int aika, const int ajat[])
{

	int alku = ajat[0];
	int loppu = ajat[1];
	if (aika <= alku)
		return 0;
	if (aika >= loppu)
		return 1;
	const float pos = (float)(aika-alku) / (loppu-alku);
	return pos;
}

float calcPosInt(int value, int limit1, int limit2)
{
	if (value <= limit1)
		return 0;
	if (value >= limit2)
		return 1;
	else
		return (float)(value-limit1)/(limit2-limit1);
}

//interpoloi, palauttaa 0 jos value1 < limit1, palauttaa 0..1 jos välissä, 1 jos menee yli
float calcPosFloat(float value, float limit1, float limit2)
{
	if (value <= limit1)
		return 0;
	if (value >= limit2)
		return 1;
	else
		return (float)(value-limit1)/(limit2-limit1);
}

float calcSaturate(float value, float limit1, float limit2, float multiply)
{
	float pos, arvo;
	if (value <= limit1)
		return 0;
	if (value >= limit2)
		return 0;
	else
		pos = (float)(value-limit1)/(limit2-limit1);

	arvo = (float)sin(pos*3.141592f)*multiply;
	if (arvo < 0) //TÄSSÄ SIZEOPTAUS?
		arvo = 0;
	if (arvo > 1)
		arvo = 1;

	return arvo;
}


void textures_init()
{
	render512_0 = new Texture(512, 512);
	render512_1 = new Texture(512, 512);
	render512_2 = new Texture(512, 512);
	render512_0->upload();
	render512_1->upload();
	render512_2->upload();
}

void textures_free()
{
	delete render512_0;
	delete render512_1;
	delete render512_2;
}

 
