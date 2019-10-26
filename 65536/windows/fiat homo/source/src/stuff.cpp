#include "stuff.hpp"

extern unsigned char vauvadata[];
extern unsigned char vauvadata2[];

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
	if (arvo < 0)
		arvo = 0;
	if (arvo > 1)
		arvo = 1;

	return arvo;
}

void unpack(unsigned char *source, unsigned long *dest)
{
	int i;
	int offset = 0;
	for (i=0;i<128*64;i++)
	{
		unsigned char value = source[i];
		unsigned char p1 = value&0xF0;
		unsigned char p2 = (value&0xF)<<4;

		unsigned int pix1 = 0xFFFFFF-(p1+(p1<<8)+(p1<<16));
		unsigned int pix2 = 0xFFFFFF-(p2+(p2<<8)+(p2<<16));

		pix1 |= 0xFF000000;
		pix2 |= 0xFF000000;
#ifdef BIGENDIAN
		pix1 = (((pix1&0x000000FF)<<24)+((pix1&0x0000FF00)<<8)+((pix1&0x00FF0000)>>8)+((pix1&0xFF000000)>>24));
		pix2 = (((pix2&0x000000FF)<<24)+((pix2&0x0000FF00)<<8)+((pix2&0x00FF0000)>>8)+((pix2&0xFF000000)>>24));
#endif

		dest[offset++] = pix1;
		dest[offset++] = pix2;
	}

}


void textures_init()
{
	int x, y;
	unsigned long *palluratemp = new unsigned long[128*128];
	unsigned long *palluratemp2 = new unsigned long[128*128];
	unsigned long *kasvottemp = new unsigned long[128*128];

	int offset = 0;

	unsigned char *kasvoptr = (unsigned char *)kasvottemp;

	for (y=-64;y<64;y++)
	{
		for (x=-64;x<64;x++)
		{
			const float sisempiradius = 25;
			const float rengassisempi = 53;
			const float rengasulompi  = 62;

			float dist = (float)sqrt(x*x+y*y);

			palluratemp2[offset] = 0x00000000;//0xFFFFFFFF;
			palluratemp[offset] = 0x00000000;

			if (dist <= sisempiradius)
			{
				palluratemp[offset] = 0xFF000000;
				goto pixeldone;
			}
			if (dist >= rengassisempi && dist <= rengasulompi)
			{
				palluratemp[offset] = 0xFF000000;
				palluratemp2[offset] = 0xFF000000;
			}
pixeldone:
#ifdef BIGENDIAN
			palluratemp[offset] = (((palluratemp[offset]&0x000000FF)<<24)+((palluratemp[offset]&0x0000FF00)<<8)+((palluratemp[offset]&0x00FF0000)>>8)+((palluratemp[offset]&0xFF000000)>>24));
			palluratemp2[offset] = (((palluratemp2[offset]&0x000000FF)<<24)+((palluratemp2[offset]&0x0000FF00)<<8)+((palluratemp2[offset]&0x00FF0000)>>8)+((palluratemp2[offset]&0xFF000000)>>24));
#endif
			offset++;
		}
	}
	//dekoodataan kasvodata
	unpack(vauvadata, kasvottemp);
	kasvot = new Texture(128, 128, kasvottemp);
	kasvot->upload();

	unpack(vauvadata2, kasvottemp);
	kasvot2 = new Texture(128, 128, kasvottemp);
	kasvot2->upload();

	pallura = new Texture(128, 128, palluratemp);
	pallura->upload();
	pallura2 = new Texture(128, 128, palluratemp2);
	pallura2->upload();
	render512_0 = new Texture(512, 512);
	render512_0->upload();
	render512_1 = new Texture(512, 512);
	render512_1->upload();
	render512_2 = new Texture(512, 512);
	render512_2->upload();
	planeetantekstuuri = new Texture(512, 512);//, palluratemp);
	planeetantekstuuri->upload();

	delete [] palluratemp;
	delete [] palluratemp2;
	delete [] kasvottemp;
}

void textures_free()
{
	delete pallura;
	delete pallura2;
}
