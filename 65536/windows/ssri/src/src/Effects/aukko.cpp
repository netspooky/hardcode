#include <stdio.h>
#include "aukko.hpp"
#include "molekyyli.hpp"

Path *aukkokamera;

void aukko(float aika)
{
	int i;
	int j;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

//	Vector alas = Vector(0, -aika, aika)*15*(float)pow(aika, 16);
//	Vector campos = Vector(aika*2,  2+3*(float)pow(aika, 2), -15.0f+aika*3);// + alas;
//	Vector camtarget = Vector(aika, 2, 0);// + alas;

	Vector camup = Vector((float)pow(aika, 60)*150, -(float)pow(aika, 40)*105, 0);

	Vector campos = aukkokamera->getValue(aika*0.97f);
	Vector camtarget = camup + Vector(0, (float)sin(aika*3.141592f*0.5f)*0.3f , 0);//aukkokamera->getValue(aika*0.97f+0.03f);

/*	char buf[160];
	glColor4f(1,1,1,1);
	glLoadIdentity();
	glTranslatef(0, 0, -1.0f);
	glDisable(GL_TEXTURE_2D);
	sprintf(buf, "%f %f %f",campos.x, campos.y, campos.z);
	font_write(-0.4f, 0, buf);
*/
	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, -aika*0.2f, 1, 0);
	glRotatef(aika*140, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);
	glDepthMask(1);

	const int splits = 16;

	for (i=0;i<splits;i++)
	{
		const float kohta = i / (float)splits;
		const float kohta2 = (i+1) / (float)splits;

		const int strips = 100;
		const float pohjay = -20.0f;
		const float kattoy = 0.0f;
		const float minradius = 0.1f;
		const float maxradius = 13.0f;

		const int asti = (int)(strips*calcPosFloat(aika, 0, 0.02f));

		Vector *vertices = new Vector[asti];
		float *alphas = new float[asti];

		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glBegin(GL_TRIANGLE_STRIP);

		for (j=0;j<asti;j++)
		{
			const float jkohta = 1-(j / (float)strips);
			const float y = pohjay*(1-jkohta)+kattoy*jkohta;
			const float r = (float)pow(jkohta, 15.0f);
			const float radius = minradius*(1-r) + maxradius*(r);
			float alphaval = 1-(float)pow(jkohta, 6);//(float)pow(1-(radius/maxradius), 2);

			const float rot = (1-j)*0.1f;

			Vector v1 = Vector(radius*(float)sin(rot+kohta*2*3.141592f), y, radius*(float)cos(rot+kohta*2*3.141592f));
			Vector v2 = Vector(radius*(float)sin(rot+kohta2*2*3.141592f), y, radius*(float)cos(rot+kohta2*2*3.141592f));

			if (i%2)
				glColor4f(sininen.x, sininen.y, sininen.z, alpha*alphaval);
			else
				glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*alphaval);

			vertices[j] = v1+Vector(0, 0.05f, 0);
			alphas[j] = alphaval;
			glVertex3fv((float *)&v1);
			glVertex3fv((float *)&v2);
		}
		glEnd();
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		glLineWidth(3.0f);
		glBegin(GL_LINE_STRIP);
		
		for (j=0;j<asti;j++)
		{
/*			if (i%2)
				glColor4f(sininen.x, sininen.y, sininen.z, alpha*2*alphas[j]);
			else
				glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*2*alphas[j]);*/
			glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*2*alphas[j]);
			glVertex3fv((float *)&vertices[j]);

		}
		glEnd();

		delete [] alphas;
		delete [] vertices;
	}

	const int lonkerot = 9;
	glColor4f(sininen.x, sininen.y, sininen.z, alpha);
	glLineWidth(2.0f);

	const float lonkeropowers[lonkerot] = { 1.2f, 
											1.5f, 
											1.1f, 
											1.7f, 
											1.2f,
											1.1f,
											1.6f,
											1.3f,
											1.2f};

	const float lonkerospeeds[lonkerot] = { 17,
											14,
											11,
											21,
											13,
											18.5f,
											9,
											12,
											16};

	const float lonkeroangles[lonkerot] = { 5,
											6,
											3,
											8,
											4,
											3,
											6,
											7,
											5};

	const Vector rotations[lonkerot] = { Vector(0.3f, 0.1f, -0.7f),
										 Vector(-0.1f, 0.7f, 0.3f),
										 Vector(0.8f, -0.2f, 0.6f),
										 Vector(-0.3f, 0.5f, 0.17f),
										 Vector(0.2f, 0.8f, -0.3f),
										 Vector(0.5f, -0.85f, 0.4f),
										 Vector(0.72f, 0.118f, -0.9f),
										 Vector(0.95f, -0.85f, 0.4f),
										 Vector(-0.7f, 0.8f, -0.5f) };



	for (i=0;i<lonkerot;i++)
	{
		const float kohta = i / (float)lonkerot;
		const float kulma = kohta*2*3.141592f;

		const float alaradius = 0.04f;
		const float ylaradius = 1.6f;

		const int lonkeropieces = 50;

		const int asti = (int)(lonkeropieces*calcPosFloat(aika, -0.01f, 0.03f));
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glLineWidth(3);
		glColor4f(sininen.x, sininen.y, sininen.z, alpha);
		glEnable(GL_DEPTH_TEST);
		glBegin(GL_LINES);

		Vector *lonkero = new Vector[lonkeropieces];

		for (j=0;j<asti;j++)
		{
			const float jkohta = j / (float)lonkeropieces;
			const float factor = (float)pow(jkohta, 8);

			const float bendradius = 1.1f;
			const float bendkulma = kulma + lonkeroangles[i]*aika;

			Vector bend = Vector((float)sin(bendkulma), 1.2f*lonkeropowers[i]*(float)(-0.5f-0.5f*cos(aika*lonkerospeeds[i])), (float)cos(bendkulma))*bendradius;

			Vector v1 = Vector((float)sin(kulma)*alaradius, -5.0f, (float)cos(kulma)*alaradius);
			Vector v2 = Vector((float)sin(kulma)*ylaradius, 4.0f, (float)cos(kulma)*ylaradius)+bend*factor;

			Vector v = lerpVector(v1, v2, jkohta);
			glVertex3fv((float *)&v);
			lonkero[j] = v;
		}
		glEnd();

		const float lonkeroeriaikastart = i*0.01f;
		const float lonkerofade = calcPosFloat(aika, 0.45f+lonkeroeriaikastart, 0.6f+lonkeroeriaikastart);

		if (lonkerofade > 0.0f)
		{
			const int palasia = 16;
			glBlendFunc(GL_SRC_ALPHA, GL_ONE);
			glDisable(GL_DEPTH_TEST);
			glLineWidth(1);
			glBegin(GL_LINES);
			for (j=lonkeropieces-1;j>lonkeropieces-palasia-1;j--)
			{
				glColor4f(1,1,1,alpha*1.0f*lonkerofade);
				glVertex3fv((float *)&lonkero[j]);
			}
			glEnd();
			glEnable(GL_DEPTH_TEST);
		}

		glPushMatrix();

		const float scale = 0.15f;
		glTranslatef(lonkero[lonkeropieces-1].x, 
					 lonkero[lonkeropieces-1].y, 
					 lonkero[lonkeropieces-1].z);

		glScalef(scale, scale, scale);

		const float molealpha = 0.4f*alpha*calcPosFloat(aika, 0.15f, 0.24f);
		const float rotpos = 30 + 60*aika;
		glRotatef(rotpos, rotations[i].x, rotations[i].y, rotations[i].z);

		serotonin(molealpha, 1);
/*		switch(i%3)
		{
			case 0: citalopram(molealpha, 1); break;
			case 1: fluvoxamine(molealpha, 1); break;
			case 2: fluoxetine(molealpha, 1); break;
		}
*/
		glPopMatrix();

		delete [] lonkero;
	}
}

void aukko_init()
{
	aukkokamera = new Path();

//	aukkokamera->addpoint(Vector(0, 0, -20));
/*
	aukkokamera->addpoint(Vector(-11, 2.7f, -16));
	aukkokamera->addpoint(Vector(-7, 2.9f, -12));
	aukkokamera->addpoint(Vector(-3, 3.1f, -7));
	aukkokamera->addpoint(Vector(1, 3, -5));
	aukkokamera->addpoint(Vector(5, 2.5f, 7));
	aukkokamera->addpoint(Vector(11, 2, 14));
	aukkokamera->addpoint(Vector(13, 3 , 20));
	aukkokamera->addpoint(Vector(-5, 4, 24));
*/

	aukkokamera->addpoint(Vector(-11, 2.1f, -20));
	aukkokamera->addpoint(Vector(-7, 2.3f, -12));
	aukkokamera->addpoint(Vector(-3, 2.4f, -7));
	aukkokamera->addpoint(Vector(1, 2.2f, -5));
	aukkokamera->addpoint(Vector(5, 2.1f, 7));
	aukkokamera->addpoint(Vector(7, 2, 14));
	aukkokamera->addpoint(Vector(3, 3 , 20));
	aukkokamera->addpoint(Vector(-5, 4, 24));

}

void aukko_free()
{
	delete aukkokamera;
}
