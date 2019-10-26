/* Galaxy effect and greetings */

#include "galaksi.hpp"
#include <stdio.h>

const int galaksicount = 16000;
const int biggerstarcount = 200;
Vector *stars;
Vector *stars2;
Vector *colors;

const int greetingscount = 19;
const int greetingslength = 16;

const char greetings[greetingscount][greetingslength] = {
"ananasmurska",
"asd",
"conspiracy",
"demarche",
"faktory", 
"fairlight",
"jumalauta", 
"mfx", 
"numedia cyclops",
"outbreak",
"promille design", 
"plastic", 
"static",
"hedelmae",
"ümlaut design",
"neuro.concept",
"Anna",
"matt current",
"gluterol"
};

int greetingstars[greetingscount] = {
	925, //ananasmurska
	1002, //asd ok
	808, //cns ok
	1601, //demarche ok
	1025, //faktory ok
	708, //fairlight ok
	920, //jumalauta ok
	1123, //mfx ok
	1717, //numedia cyclops ok
	1124, //outbreak ok
	1294,//	promille design
	1174, //plastic ok
	1615, //static ok
	1024, //hedelmae
	6097, //üd
	819,//neuro.concept
	1422, //anna <3
	1274, //matt current
	954, //gluterol

};

void galaksi(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 9);

	glLoadIdentity();
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_TEXTURE_2D);

	Vector campos = Vector(aika*0.4f, 1.0f+aika*0.4f, -4.0f+aika);
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0.2f, 1, 0);

	glRotatef(aika*10, 0, 1, 0);

	int kohta, kohta2;

	//fade out in the end
	if (aika < 0.5f)
	{
		kohta = (int)(alpha*galaksicount);
		kohta2 = (int)(alpha*biggerstarcount);
	}
	else
	{
		kohta = galaksicount;
		kohta2 = biggerstarcount;
	}

	glPointSize(3.0f);
	glBegin(GL_POINTS);
	for (i=0;i<kohta;i++)
	{
		const float phase = i / (float)galaksicount;
		const float alphamod = 0.8f+0.4f*(float)sin(phase*70 + aika*27);

		glColor4f(1, 1, 1, alpha*0.4f*alphamod);
		glVertex3fv((float *)&stars[i]);
	}
	glEnd();
	glPointSize(5.0f);
	glBegin(GL_POINTS);
	for (i=0;i<kohta2;i++)
	{
		const float phase = i / (float)biggerstarcount;
		const float alphamod = 0.8f+0.4f*(float)sin(phase*170 + aika*30);
		glColor4f(colors[i].x, colors[i].y, colors[i].z, alpha*0.5f*alphamod);
		glVertex3fv((float *)&stars2[i]);
	}
	glEnd();
	
	//Show the greetings
	const float greetingalpha = calcPosFloat(aika, 0.65f, 0.69f);
	glColor4f(1,1,1,alpha*greetingalpha);

	for (i=0;i<greetingscount;i++)
	{
		int index = greetingstars[i];
		Vector greetpos = stars[index];
		
		glBegin(GL_POINTS);
		glVertex3fv((float *)&greetpos);
		glEnd();
		
		glPushMatrix();
		const float fontscale = 0.002f;
		glScalef(fontscale, fontscale, fontscale);
		glRotatef(180, 0, 1, 0);
		const float mul = 1.0f/fontscale;
		glTranslatef(-greetpos.x*mul, -greetpos.y*mul, -greetpos.z*mul);
		font_write3d(greetings[i]);
		glPopMatrix();
	}
}

void galaksi_init()
{
	int i;
	stars = new Vector[galaksicount];
	stars2 = new Vector[biggerstarcount];
	colors = new Vector[biggerstarcount];

	setSeed(1699);
	for (i=0;i<galaksicount;i++)
	{
		const float kohta = i / (float)galaksicount;
		const float planardist = (float)(pow(randFloat(), 2)*2.0f) * 
										 (float)pow(0.5f+0.5f*(float)sin(3.141592*6*kohta), 2);
		const float planarangle = randFloat()*2*3.141592f;

		//0...25

		const float height = (randFloat()-0.5f) * 0.1f;
		stars[i] = Vector(planardist*(float)sin(planarangle), height, planardist*(float)cos(planarangle));
	}
	for (i=0;i<biggerstarcount;i++)
	{
		const float planardist = randFloat()*randFloat()*2.0f;
		const float planarangle = randFloat()*2*3.141592f;
		const float height = (randFloat()-0.5f) * 0.1f;
		stars2[i] = Vector(planardist*(float)sin(planarangle), height, planardist*(float)cos(planarangle));

		float redsub = 0.1f;
		float greensub = 0.1f;
		float bluesub = 0.0f;

		colors[i] = Vector(1-randFloat()*redsub, 1-randFloat()*greensub, 1-randFloat()*bluesub);
	}
}

void galaksi_free()
{
	delete [] stars;
	delete [] stars2;
	delete [] colors;
}
