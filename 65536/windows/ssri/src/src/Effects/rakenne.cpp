#include "rakenne.hpp"
#include "../tausta.hpp"

const int rakennecount = 10000;
Vector *rakennevertices1;
Vector *rakennevertices2;

const int rakenneglowcount = 1000;
Vector *glowvertices1;
Vector *glowvertices2;


void rakenne(float aika)
{
	int i;
	int j;

//	glowfilter_setup();

	const float fade = calcPosFloat(aika, 0.265f, 0.30f);
	const float alpha = calcSaturate(aika, 0, 1, 17)*calcPosFloat(aika, 0, 0.1f);
	
//	taustahori(0.4f, calcPosFloat(aika, 0.7f, 1.0f));

	glLoadIdentity();

	Vector campos = Vector(3-aika*6, 0, 2.5f+0.5f*(float)sin(aika*7));
	Vector camtarget = campos;
	camtarget.z = 0;
	const float rot = (float)cos(aika*11)*0.1f;

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, rot, 1-rot, 0);

	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	glLineWidth(2.0f);

	const float alphamod = calcPosFloat(aika, 0.0, 0.05f)*(0.9f+0.2f*(float)sin(aika*41));

	//rinkulat
	const int rinkulacount = 15;
	const float width3d = 10;

	for (i=0;i<rinkulacount;i++)
	{
		const float kohta = i / (float)rinkulacount;
		const float xcoord = (kohta-0.5f)*width3d;

		const float radius = 0.55f +0.05f*(float)sin(kohta*7+aika*25);

		const float pyori = -aika*10;

		glDisable(GL_DEPTH_TEST);

		const int strips = 64;
/*		if (i%2)
			glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*0.7f);
		else
			glColor4f(sininen.x, sininen.y, sininen.z, alpha*0.7f);
*/
/*
		switch(i%4)
		{
			case 0: glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*0.7f); break;
			case 1: glColor4f(sininen.x, sininen.y, sininen.z, alpha*0.7f); break;
			case 2: glColor4f(violetti.x, violetti.y, violetti.z, alpha*0.7f); break;
			case 3: glColor4f(punainen.x, punainen.y, punainen.z, alpha*0.7f); break;
		}
*/
		switch(i%2)
		{
			case 0: glColor4f(violetti.x, violetti.y, violetti.z, alpha*0.7f); break;
			case 1: glColor4f(punainen.x, punainen.y, punainen.z, alpha*0.7f); break;
		}
		glLineWidth(4);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glBegin(GL_LINES);
		for (j=0;j<strips;j++)
		{
			const float kohta2 = j / (float)(strips-1);
			const float kulma = kohta2*2*3.141592f + pyori;

//			if (j%2)
//				glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha);
//			else
//				glColor4f(sininen.x, sininen.y, sininen.z, alpha);

			Vector v = Vector(xcoord, (float)sin(kulma)*radius, (float)cos(kulma)*radius);
			glVertex3fv((float *)&v );
		}
		glEnd();

		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		glLineWidth(1.0f);
		glColor4f(1,1,1,alpha);
		glBegin(GL_LINES);
		for (j=0;j<strips;j++)
		{
			const float kohta2 = j / (float)(strips-1);
			const float kulma = kohta2*2*3.141592f + pyori;

			Vector v = Vector(xcoord, (float)sin(kulma)*radius, (float)cos(kulma)*radius);
			glVertex3fv((float *)&v );
		}
		glEnd();
	}
	
	glRotatef(aika*130, 1, 0, 0);
	glDisable(GL_DEPTH_TEST);

	glLineWidth(1+fade*3);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBegin(GL_LINES);
	glColor4f(sininen.x, sininen.y, sininen.z, alpha);

	for (i=0;i<rakennecount;i+=2)
	{
		glVertex3fv((float *)&rakennevertices1[i]);
		glVertex3fv((float *)&rakennevertices2[i]);
	}
	glEnd();
	glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha);
	glBegin(GL_LINES);
	for (i=1;i<rakennecount;i+=2)
	{
		glVertex3fv((float *)&rakennevertices1[i]);
		glVertex3fv((float *)&rakennevertices2[i]);
	}
	glEnd();

	glLineWidth(1.0f);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glBegin(GL_LINES);
	glColor4f(1,1,1, fade*alpha);

	for (i=0;i<rakennecount;i+=2)
	{
		glVertex3fv((float *)&rakennevertices1[i]);
		glVertex3fv((float *)&rakennevertices2[i]);
	}
	glEnd();
//	glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha);
	glBegin(GL_LINES);
	for (i=1;i<rakennecount;i+=2)
	{
		glVertex3fv((float *)&rakennevertices1[i]);
		glVertex3fv((float *)&rakennevertices2[i]);
	}
	glEnd();

//	glowfilter_draw();

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glLineWidth(4);
	glBegin(GL_LINES);
	for (i=0;i<rakenneglowcount;i++)
	{
		if (i%2)
			glColor4f(punainen.x, punainen.y, punainen.z, alpha*0.7f);
		else
			glColor4f(violetti.x, violetti.y, violetti.z, alpha*0.7f);
		glVertex3fv((float *)&glowvertices1[i]);
		glVertex3fv((float *)&glowvertices2[i]);
	}
	glEnd();
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);

	glLineWidth(1);
	glColor4f(1,1,1,alpha*1.0f);
	glBegin(GL_LINES);
	for (i=0;i<rakenneglowcount;i++)
	{
		glVertex3fv((float *)&glowvertices1[i]);
		glVertex3fv((float *)&glowvertices2[i]);
	}
	glEnd();

}


void rakenne_init()
{
	int i;
	rakennevertices1 = new Vector[rakennecount];
	rakennevertices2 = new Vector[rakennecount];
	glowvertices1 = new Vector[rakenneglowcount];
	glowvertices2 = new Vector[rakenneglowcount];

	Matrix scale, scale2;
	Vector scalevec = Vector(10, 1, 1);
	Vector scalevec2 = scalevec*2;

	scale.makeScale(scalevec.x, scalevec.y, scalevec.z);
	scale2.makeScale(scalevec2.x, scalevec2.y, scalevec2.z);

	setSeed(16);
	for (i=0;i<rakennecount;i++)
	{
		Vector v1 = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*scale;
		Vector v2;

		const float xlength = 0.3f;
		const float ylength = 0.2f;
		const float zlength = 0.2f;

		switch(i%3)
		{
			case 0: v2 = v1 + Vector(randFloat()-0.5f, 0, 0) * xlength; break;
			case 1: v2 = v1 + Vector(0, randFloat()-0.5f, 0) * ylength; break;
			case 2: v2 = v1 + Vector(0, 0, randFloat()-0.5f) * zlength; break;
		}
		rakennevertices1[i] = v1;
		rakennevertices2[i] = v2;
	}
	for (i=0;i<rakenneglowcount;i++)
	{
		Vector v1 = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*scale;
		Vector v2;

		const float xlength = 0.5f;
		const float ylength = 0.1f;
		const float zlength = 0.1f;

		switch(i%3)
		{
			case 0: v2 = v1 + Vector(randFloat()-0.5f, 0, 0) * xlength; break;
			case 1: v2 = v1 + Vector(0, randFloat()-0.5f, 0) * ylength; break;
			case 2: v2 = v1 + Vector(0, 0, randFloat()-0.5f) * zlength; break;
		}
		glowvertices1[i] = v1;
		glowvertices2[i] = v2;

	}
}

void rakenne_free()
{
	delete [] rakennevertices1;
	delete [] rakennevertices2;
	delete [] glowvertices1;
	delete [] glowvertices2;
}
