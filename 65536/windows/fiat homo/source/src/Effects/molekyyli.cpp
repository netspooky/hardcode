#include "../stuff.hpp"
#include "molekyyli.hpp"
#include "atomi.hpp"

const int kasvustoja = 30;
const int kasvustonminkoko = 20;
const int kasvustonmaxkoko = 60;

Vector **kasvustot;
Vector *kasvustomovedeltas;
int *kasvustonkoot;

void molekyyli(float aika)
{
	int i, j;
	float alpha = calcSaturate(aika, 0, 1, 7);//(aika, 0.0f, 0.2f);
	//korjataan atomin aiheuttama matriisin kusu
	glLoadIdentity();
	glLineWidth(1.0f);

	glScalef(1,1,1);
	glLoadIdentity();
	glTranslatef(0, 0, -5.0f);
	glRotatef(aika*100, 1, 1.0f, 0.2f);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	Vector x, y, z;
	antiRotate(&x, &y, &z);

	glDisable(GL_DEPTH_TEST);
	glDepthMask(0);
	glBindTexture(GL_TEXTURE_2D, pallura->ID);

	//atomit
	for (i=0;i<kasvustoja;i++)
	{
		int raja = (int)(aika*kasvustonkoot[i]);
		float frac = aika*kasvustonkoot[i] - raja;

		Vector notfinishedpos = kasvustot[i][raja] + kasvustomovedeltas[i]*aika;
		glColor4f(0, 0, 0, alpha*frac);
		billboard(notfinishedpos, x, y, z, 0.05f);

		//piirretään valmiit
		glColor4f(0, 0, 0, alpha);
		for (j=0;j<raja;j++)
		{
			Vector pos = kasvustot[i][j] + kasvustomovedeltas[i]*aika;
			billboard(pos, x, y, z, 0.05f);

		}
	}
	//linkit
	glDisable(GL_TEXTURE_2D);
	for (i=0;i<kasvustoja;i++)
	{
		int raja = (int)(aika*kasvustonkoot[i]);
		float frac = aika*kasvustonkoot[i] - raja;

		//eivielävalmis.. <- eikö vai? :-)
		glBegin(GL_LINES);
		if (raja > 0)
		{
			Vector kohta = lerpVector(kasvustot[i][raja-1], kasvustot[i][raja], frac);
			glVertex3fv((float *)&(kasvustot[i][raja-1]+kasvustomovedeltas[i]*aika));
			glVertex3fv((float *)&(kohta+kasvustomovedeltas[i]*aika));
		}
		glEnd();
		glBegin(GL_LINE_STRIP);
		for (j=0;j<raja;j++)
		{
			glColor4f(0.7f, 0, 0, alpha);
			glVertex3fv((float *)&(kasvustot[i][j]+ kasvustomovedeltas[i]*aika));
		}
		glEnd();
	}
}

void molekyyli_init()
{
	int i, j;
	kasvustot = new Vector*[kasvustoja];
	kasvustonkoot = new int[kasvustoja];
	kasvustomovedeltas = new Vector[kasvustoja];

	for (i=0;i<kasvustoja;i++)
	{
		const float movesize = 2.5f*randFloat();
		kasvustomovedeltas[i] = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*movesize;
		kasvustonkoot[i] = kasvustonminkoko + RAND_INT(0, kasvustonmaxkoko-kasvustonminkoko);//randInt()%(kasvustonmaxkoko-kasvustonminkoko);
		kasvustot[i] = new Vector[kasvustonkoot[i]];

		const float alkuradius = 1 + 4*randFloat();
		
		Vector alkupiste = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*alkuradius;

		for (j=0;j<kasvustonkoot[i];j++)
		{

			float kulma1 = randFloat()*3.141592f;
			float kulma2 = randFloat()*3.141592f*2;
			float matka = 0.2f + 0.05f*randFloat();
			Vector delta = sphereCoord(matka, kulma1, kulma2);

			kasvustot[i][j] = alkupiste;
			alkupiste += delta;
		}
	}
}

void molekyyli_free()
{
	int i;
	for (i=0;i<kasvustoja;i++)
	{
		delete [] kasvustot[i];
	}
	delete [] kasvustot;
	delete [] kasvustonkoot;
	delete [] kasvustomovedeltas;
}
