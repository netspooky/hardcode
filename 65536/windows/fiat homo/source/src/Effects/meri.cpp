#include "../stuff.hpp"
#include "meri.hpp"

const int merenpohjacount = 2000;
int *merenpohjaindices;
Vector *merenpohjavertices;

const int kasvicount = 3000;
Vector *kasvipos;

const int kuplacount = 500;
float *kuplastart;
float *kuplaend;
Vector *kuplastartpos;

void meri(float aika)
{
	int i;
	int j;
	float alpha = calcSaturate(aika, 0, 1, 4);
	glLoadIdentity();
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	const float camrad = 1.5f;
	const float camkulma = aika*5;

	const float suddenturn = (float)pow(aika, 37);//aika*aika*aika*aika*aika*aika*aika*aika;
	const float suddenkulma = suddenturn*180;

	Vector campos = Vector(camrad*(float)sin(camkulma), 2+1.2f*(float)cos(aika*5), -4-aika*2+camrad*(float)cos(camkulma));
	Vector camtarget = Vector(0, 1-aika*0.5f, 0);
	glRotatef(suddenkulma, -0.01f, 0, 0);
	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glRotatef(suddenkulma, 0, 1, -0.9f);

	glDepthMask(1);
	glDisable(GL_DEPTH_TEST);

	//merenpohja
	const int pohjacount = (int)(merenpohjacount*calcPosFloat(aika, 0, 0.1f));
	
	glColor4f(0, 0, 0, alpha*0.4f);
	glBegin(GL_LINES);

	for (i=0;i<pohjacount;i++)
	{
		glVertex3fv((float *)&merenpohjavertices[merenpohjaindices[i*2]]);
		glVertex3fv((float *)&merenpohjavertices[merenpohjaindices[i*2+1]]);
	}
	glEnd();

	//kasvit
	const int kasvipiirto = (int)(kasvicount*calcPosFloat(aika, 0.3f, 0.6f));

	for (i=0;i<kasvipiirto;i++)
	{
		const float kohta = i / (float)kasvicount;
		const int kasvistrips = 10;

		glLineWidth(1.5f+0.5f*(float)sin(kohta*17));
		glBegin(GL_LINE_STRIP);
		Vector alku = kasvipos[i];

		const float alkuaika = kohta*0.3f;
		const float loppuaika = alkuaika + 0.3f;

		float kasvu = calcPosFloat(aika-0.3f, alkuaika, loppuaika);

		for (j=0;j<kasvistrips;j++)
		{
			const float jpos = j / (float)kasvistrips;
			const float jstep = 1.0f / (float)kasvistrips;
			const float globaalivirtaus = 0.1f*jstep*(float)sin(kohta*17+aika*4*3.141592f);

			glColor4f(0, 0.3f,0,alpha*0.7f*(1-jpos)*kasvu);
			glVertex3fv((float *)&alku);
			alku += Vector(0.01f*(float)sin(jpos*aika*17), (0.070f+0.04f*kohta)*kasvu, 0.01f*(float)cos(jpos*aika*11));
			alku += Vector(globaalivirtaus, 0, globaalivirtaus);
		}
		glEnd();
	}

	glEnable(GL_DEPTH_TEST);
	//kuplat
	Vector x, y, z;
	antiRotate(&x, &y, &z);

	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, pallura2->ID);

	for (i=0;i<kuplacount;i++)
	{
		const float kalpha = calcSaturate(aika, kuplastart[i], kuplaend[i], 4);
		if (kalpha == 0)
			continue;
		const float t = calcPosFloat(aika, kuplastart[i], kuplaend[i]);

		Vector p1 = kuplastartpos[i];
		Vector p2 = kuplastartpos[i] + Vector(0, 3, 0);
		Vector p = p1*(1-t) + p2*t;

		glColor4f(0,0,0,alpha*0.8f*kalpha);
		billboard(p, x, y, z, 0.04f);
	}
	//korjataan seuraavaa framea/efektiä varten tämä
	glLineWidth(1.0f);

}
void meri_init()
{
	int i;
	int j;

	merenpohjavertices = new Vector[merenpohjacount];
	merenpohjaindices = new int[merenpohjacount*2];
	kasvipos = new Vector[kasvicount];

	kuplastart = new float[kuplacount];
	kuplaend = new float[kuplacount];
	kuplastartpos = new Vector[kuplacount];

	const int maxradius = 7;

	for (i=0;i<merenpohjacount;i++)
	{
		const float kulma = randFloat()*2*3.141592f;
		const float radius = randFloat()*maxradius;
		merenpohjavertices[i] = Vector((float)sin(kulma)*radius, randFloat()*0.05f, (float)cos(kulma)*radius);

		//nollataan nämä tässä
		merenpohjaindices[i*2] = 0;
		merenpohjaindices[i*2+1] = 0;
	}

	for (i=0;i<kasvicount;i++)
	{
		const float kulma = randFloat()*2*3.141592f;
		const float radius = randFloat()*maxradius;
		kasvipos[i] = Vector((float)sin(kulma)*radius, 0, (float)cos(kulma)*radius);
	}

	for (i=0;i<kuplacount;i++)
	{
		const float pos = i / (float)kuplacount;
		const float traveltime = 0.2f;
		const float starttime = 0.5f;

		const float kulma = randFloat()*2*3.141592f;
		const float radius = randFloat()*maxradius;
		kuplastartpos[i] = Vector((float)sin(kulma)*radius, 0, (float)cos(kulma)*radius);

		kuplastart[i] = pos+starttime;
		kuplaend[i] = kuplastart[i]+traveltime;


	}

	for (i=0;i<merenpohjacount;i++)
	{
		float dist = 1000000.0f;
		int indeksi = 0;
		for (j=0;j<merenpohjacount;j++)
		{
			if (i==j)
				continue;

			const float etaisyys = (merenpohjavertices[i]-merenpohjavertices[j]).length();

			if (etaisyys < dist)
			{
				//ei samaa kahta kertaa
				if (merenpohjaindices[j*2+1]==i)
					continue;

				indeksi = j;
				dist = etaisyys;
			}
		}
		//viiva lähimpään toiseen pisteeseen
		merenpohjaindices[(i<<1)] = i;
		merenpohjaindices[(i<<1)+1] = indeksi;
	}


}
void meri_free()
{
	delete [] merenpohjavertices;
	delete [] merenpohjaindices;
	delete [] kasvipos;
	delete [] kuplastart;
	delete [] kuplaend;
	delete [] kuplastartpos;
}
