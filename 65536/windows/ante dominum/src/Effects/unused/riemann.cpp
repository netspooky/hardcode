#include "riemann.hpp"

const int rgridx = 100;
const int rgridy = 100;
float *rgrid;

void riemann(float aika)
{
	int i;
	int x, y;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector campos = Vector(0, 0, -360.0f);//+70*(float)cos(aika*18));
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(aika*160, 0.2f, 0.1f, 0.71f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	for (y=0;y<rgridy;y++)
	{
		for (x=0;x<rgridx;x++)
		{
			float real = x/(float)rgridx;
			float imag = y/(float)rgridy;

			real *= 1+aika*3;
			imag *= 1+aika*3;

			real -= 1.5f*aika;
			imag -= 1.5f*aika;

			//zeta(n) = summa 1->oo 1/(k^n)
			const int iterations = 10;

			Complex k = Complex(real, imag);
			Complex summa = Complex(0, 0);
			for (i=0;i<iterations;i++)
			{
				summa += Complex(1.0f, 0.0f)/(k.power((float)i));
			}
			rgrid[x+y*rgridx] = summa.i*0.000001f;
		}
	}
	glBegin(GL_QUADS);
	glColor4f(0, 0, 0, alpha);
	for (y=0;y<rgridx;y++)
	{
		for (x=0;x<rgridy;x++)
		{
			const float size = 130.0f;
			Vector kohta = Vector((float)x/rgridx-0.5f, (float)y/rgridy-0.5f, 0)*size;

			const float maxpolysize = 0.5f;
			const float polysize = maxpolysize * rgrid[x+y*rgridx];
			Vector v1 = kohta + Vector(-polysize, -polysize, 0);
			Vector v2 = kohta + Vector( polysize, -polysize, 0);
			Vector v3 = kohta + Vector( polysize,  polysize, 0);
			Vector v4 = kohta + Vector(-polysize,  polysize, 0);

			glVertex3fv((float *)&v1);
			glVertex3fv((float *)&v2);
			glVertex3fv((float *)&v3);
			glVertex3fv((float *)&v4);
		}
	}
	glEnd();
	
}

void riemann_init()
{
	int i;
	rgrid = new float[rgridx*rgridy];

	for (i=0;i<rgridx*rgridy;i++)
	{
		rgrid[i] = 0;
	}
}

void riemann_free()
{
	delete [] rgrid;
}