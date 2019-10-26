#include "rata.hpp"

Path *ratapath;

const int ratasegments = 100;

void rata(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 6);
	const float speed = 2.5f;
	float kohta = speed*aika - (int)(speed*aika);

	glLoadIdentity();

//	Vector campos = Vector(0, 0, -7.0f);
//	Vector camtarget = Vector(0, 0, 0);

	const float advance = 1.05f;
	const float cameraheight = 1.2f;
	Vector campos = ratapath->getValue(kohta) + Vector(0, cameraheight, 0);
	Vector camtarget = ratapath->getValue(kohta+advance) + Vector(0, cameraheight, 0);
	
	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
//	glRotatef(-aika*200, 0, 0.5f, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);

	int count = 0;
	glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha);
	glBegin(GL_LINE_STRIP);
	for (float t=0;t<=1.0f;t+=1.0f / ratasegments)
	{
		Vector p = ratapath->getValue(t);
		glVertex3fv((float *)&p);
		glVertex3fv((float *)&(p+Vector(0, 0.2f, 0)));
		glVertex3fv((float *)&(p+Vector(0.2f, 0, 0)));
		glVertex3fv((float *)&(p+Vector(0, 0, 0.2f)));
		count++;
	}
	glEnd();
/*
	const float korkeus = 0.05f;
	glPointSize(3);

	Vector pos = ratapath->getValue(kohta) + Vector(0, korkeus, 0);
	glColor4f(sininen.x, sininen.y, sininen.z, alpha);
	glBegin(GL_POINTS);
	glVertex3fv((float *)&pos);
	glEnd();
*/
}

void rata_init()
{
	int i;
	ratapath = new Path();

	for (i=0;i<ratasegments;i++)
	{
		const float kohta = i / (float)ratasegments;

		const float radius = 2;
		const float kulma = kohta*2*3.141592f;

		Vector pos = Vector((float)cos(kulma), 0, (float)sin(kulma))*radius;
		pos.y = 1+(float)sin(kulma*4)*0.4f;

		ratapath->addpoint(pos);
	}
}

void rata_free()
{
	delete ratapath;
}
