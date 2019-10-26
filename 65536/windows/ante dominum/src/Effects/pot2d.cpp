#include "pot2d.hpp"

const int potgridx = 55;
const int potgridy = 55;
const int grids = 16;
float **potgrid;

void pot2d(float aika)
{
	int i;
	int x, y;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector campos = Vector(0, 0, -160.0f+70*(float)cos(aika*18));
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	static int piirrettava = 0;

	float *dest = potgrid[piirrettava%grids];

	const float vaihtoalku = 0.4f;
	const float vaihtoloppu = 0.6f;
	const float vaihto = calcPosFloat(aika, vaihtoalku, vaihtoloppu);
	
	pot2d_clear(dest);
	pot2d_func1(aika, 1-vaihto, dest);
	pot2d_func2(aika, vaihto, dest);

	piirrettava++;
	glRotatef(aika*40+12, 0.1f, 0.13f, 0.7f);

	glBegin(GL_QUADS);
	for (i=0;i<grids;i++)
	{
		glColor4f(0, 0, 0, alpha*(0.2f+0.2f*(i/(float)grids)));
		for (y=0;y<potgridy;y++)
		{
			for (x=0;x<potgridx;x++)
			{
				const float size = 90.0f;
				Vector kohta = Vector((float)x/potgridx-0.5f, (float)y/potgridy-0.5f, 0)*size;
				kohta.z = i*15.0f;

				const float maxpolysize = 1.5f;
				const float polysize = maxpolysize * potgrid[(i+piirrettava)%grids][x+y*potgridx];
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
	}
	glEnd();
}

void pot2d_init()
{
	int i;
	potgrid = new float*[grids];
	for (i=0;i<grids;i++)
	{
		potgrid[i] = new float[potgridx*potgridy];
		for (int j=0;j<potgridx*potgridy;j++)
		{
			potgrid[i][j] = 0;
		}
	}
}

void pot2d_func1(float aika, float mul, float *dest)
{
	int x, y;

	if (mul < 0.001f)
		return;

	const float speed = 5.0f;
	const float s = 10.0f;
	float *destptr = dest;
	for (y=0;y<potgridy;y++)
	{
		float yval = 0.5f+(float)(0.25*sin(aika*speed*17+y*0.03f*s)+0.25*cos(aika*speed*11-y*0.01*s));
		for (x=0;x<potgridx;x++)
		{
			float xval = 0.5f*(float)(0.25*sin(aika*speed*14+x*0.02f*s)+0.25*cos(aika*speed*18+x*0.023*s));
			*destptr++ += (xval+yval)*0.5f*mul;
		}
	}
}
void pot2d_func2(float aika, float mul, float *dest)
{
	int x, y;

	if (mul < 0.001f)
		return;

	Vector pos1 = Vector((float)sin(aika*11), (float)cos(aika*15+0.4f), 0)*potgridx*1.5f;
	Vector pos2 = Vector((float)sin(aika*5+2), (float)cos(aika*25+0.4f), 0)*potgridx*1.5f;
	Vector pos3 = Vector((float)sin(aika*5+2)*0.5f+(float)cos(aika*11+3)*0.5f, 
						 (float)cos(aika*25+0.4f)*0.5f+(float)sin(aika*8+2)*0.5f, 0)*potgridx*1.5f;

	pos1 += Vector(potgridx*0.5f, potgridy*0.5f, 0);
	pos2 += Vector(potgridx*0.5f, potgridy*0.5f, 0);
	pos3 += Vector(potgridx*0.5f, potgridy*0.5f, 0);

	int offs = 0;
	for (y=0;y<potgridy;y++)
	{
		for (x=0;x<potgridx;x++)
		{
			const float maxlength = Vector(potgridx*0.5f, potgridy*0.5f, 0).length();
			float d1 = (Vector((float)x, (float)y, 0)-pos1).length()/maxlength;
			float d2 = (Vector((float)x, (float)y, 0)-pos2).length()/maxlength;
			float d3 = (Vector((float)x, (float)y, 0)-pos3).length()/maxlength;

			dest[offs++] += (1-(float)sin((d1+d2+2*d3)*0.25 *2*3.141592f))*0.5f*mul;
		}
	}
}
void pot2d_clear(float *dest)
{
	int i;
	for (i=0;i<potgridx*potgridy;i++)
	{
		dest[i] = 0;
	}

}

void pot2d_free()
{
	int i;
	for (i=0;i<grids;i++)
	{
		delete[] potgrid[i];
	}
	delete [] potgrid;
} 
