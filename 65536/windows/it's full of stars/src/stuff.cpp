#include "stuff.hpp"

#define INTENDIAN(x) ((((x)&0x000000FF)<<24)+(((x)&0x0000FF00)<<8)+(((x)&0x00FF0000)>>8)+(((x)&0xFF000000)>>24));

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
	int i;
	int x, y;
	
	unsigned int alpha = 255<<24;
#ifdef BIGENDIAN
	alpha = INTENDIAN(alpha);
#endif

	flare = new Texture(64, 64);
	flare2 = new Texture(64, 64);

	render0 = new Texture(512, 512);
	render1 = new Texture(512, 512);
	render2 = new Texture(512, 512);

	for (i=0;i<512*512;i++)
	{
		render0->data[i] = (unsigned long)alpha;
		render1->data[i] = (unsigned long)alpha;
		render2->data[i] = (unsigned long)alpha;

	}
	int offs = 0;

	for (y=0;y<64;y++)
	{
		for (x=0;x<64;x++)
		{
			unsigned int col = 0;
			const float dist = (float)sqrt((x-32)*(x-32)+(y-32)*(y-32));
			const float maxdist = 32;

			if (dist > maxdist)
			{
				flare->data[x+y*64] = 0 + alpha;
				continue;
			}
			const float sdist = (maxdist-dist)/maxdist; //0..1
			const float c = (float)pow(sdist, 3);
			const float c2 = (float)pow(sdist, 4.5f);
			const int ci = (int)(c*255);
			int ci2 = (int)(c2*255);
			if (ci2 > 255)
				ci2 = 255;
			flare->data[x+y*64] = ci + (ci<<8) + (ci<<16) + alpha;
#ifdef BIGENDIAN
			flare->data[x+y*64] = INTENDIAN(flare->data[x+y*64]);
#endif

			float dx = 1-(float)fabs(x-32)/32;
			float dy = 1-(float)fabs(x-32)/32;
			const int c3 = (int)(((float)(pow(sdist, 6))*300)*(dx+dy)*0.5f);

			int punainen = (ci2>>2) + c3;
			int vihrea = (ci2>>2) + c3;
#ifdef BIGENDIAN
			punainen = INTENDIAN(punainen);
			vihrea = INTENDIAN(vihrea);
#endif

			int sininen = (ci2) + c3;

			if (punainen > 255)
				punainen = 255;
			if (vihrea > 255)
				vihrea = 255;
			if (sininen > 255)
				sininen = 255;
			flare2->data[x+y*64] = punainen + (vihrea<<8) + (sininen<<16) + alpha;
#ifdef BIGENDIAN
			flare2->data[x+y*64] = INTENDIAN(flare2->data[x+y*64]);
			flare2->data[x+y*64] = INTENDIAN(flare2->data[x+y*64]);
#endif

		}
	}

	flare->upload();
	flare2->upload();
	render0->upload();
	render1->upload();
	render2->upload();
}

void textures_free()
{
	delete flare;
	delete flare2;
}

