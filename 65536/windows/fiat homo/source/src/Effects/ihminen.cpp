#include "ihminen.hpp"

const int ihmiscount = 250;
Vector *ihmiset;
float *ihmiskoot;

const int ihmispistecount = 200;
Vector *ihmispisteet;

void ihminen(float aika)
{
	int i;
	float alpha = calcSaturate(aika, 0, 1, 9);
	glLoadIdentity();
	glEnable(GL_BLEND);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_TEXTURE_2D);
	glDepthMask(1);
	glDisable(GL_DEPTH_TEST);

	Vector campos = Vector(-1-aika*3, (float)sin(aika*1.9f*3.141592f), -7.0f+aika*10);
	Vector camtarget = Vector(3.6f+aika*5 + aika*aika*aika*aika*aika*aika*aika*aika*10000, 0, aika*2);

	const float tilt = 0.2f*(float)sin(aika*3.141592f);
	const float tiltamount = 0.7f;
	Vector rotation = Vector(0, tiltamount*(float)cos(tilt), tiltamount*(float)sin(tilt));

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, rotation.x, rotation.y, rotation.z);

	glLineWidth(1.0f);
	for (i=0;i<ihmiscount;i++)
	{
		const float starttime = i*(1.0f/ihmiscount);
		const float stoptime = starttime + 0.01f;
		const float sizemod = calcPosFloat(aika, starttime, stoptime);

		const float leavestart = 0.8f + i*(0.1f/ihmiscount);
		const float leavestop = leavestart + 0.1f;
		const float leavepos = calcPosFloat(aika, leavestart, leavestop);
		const float leavesize = 1-leavepos;

		//eka isoks ja sit pieneks.. ja koodista tulee luettavaa :)
		const float size = ihmiskoot[i]*(float)sin(sizemod*0.5*3.141592f)*leavesize;

		const float alhaalta = ((float)pow((1-sin(calcPosFloat(aika, 0.0f, 0.04f)*3.141592f*0.5f)), 1.5f))*-7;

		Vector pos = ihmiset[i] + Vector(100*(float)pow(leavepos, 11), 0, 0) + Vector(0, alhaalta, 0);

		Matrix rot;
		const float kul = 0.1f*(float)sin((i/(float)ihmiscount)*100+aika*6	);
		rot.makeRotation(kul, kul, kul);

		glEnable(GL_TEXTURE_2D);
		Vector v1 = Vector(0, -size, -size)*rot;
		Vector v2 = Vector(0,  size, -size)*rot;
		Vector v3 = Vector(0,  size, size)*rot;
		Vector v4 = Vector(0, -size, size)*rot;
		if (i%2)
			glBindTexture(GL_TEXTURE_2D, kasvot->ID);
		else
			glBindTexture(GL_TEXTURE_2D, kasvot2->ID);

		glColor4f(1,1,1,alpha*0.5f);
		if (i%3)
			glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		else
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		glBegin(GL_QUADS);
		glTexCoord2f(0,1);
		glVertex3fv((float *)&(pos+v1));
		glTexCoord2f(0,0);
		glVertex3fv((float *)&(pos+v2));
		glTexCoord2f(1,0);
		glVertex3fv((float *)&(pos+v3));
		glTexCoord2f(1,1);
		glVertex3fv((float *)&(pos+v4));
		glEnd();

		glDisable(GL_TEXTURE_2D);
		glColor4f(1,1,1,alpha*0.4f);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		glBegin(GL_LINE_LOOP);
		glVertex3fv((float *)&(pos+v1));
		glVertex3fv((float *)&(pos+v2));
		glVertex3fv((float *)&(pos+v3));
		glVertex3fv((float *)&(pos+v4));
		glEnd();
	}

	glPointSize(3);
	glColor4f(1,1,1,alpha*0.3f);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_DEPTH_TEST);
	glBegin(GL_POINTS);
	for (i=0;i<ihmispistecount;i++)
	{
		glVertex3fv((float *)&ihmispisteet[i]);
	}
	glEnd();
}



void ihminen_init()
{
	int i;
	ihmiset = new Vector[ihmiscount];
	ihmiskoot = new float[ihmiscount];
	ihmispisteet = new Vector[ihmispistecount];

	const float xmin = 3.5f;
	const float xmax = 0.3f;

	const float ymin = -1.5f;
	const float ymax =  1.5f;

	const float zmin = -5.0f;
	const float zmax =  5.0f;

	const float sizemin = 0.2f;
	const float sizemax = 0.7f;

	for (i=0;i<ihmiscount;i++)
	{
		ihmiset[i] = Vector(xmin+randFloat()*(xmax-xmin), 
							ymin+randFloat()*(ymax-ymin), 
							zmin+randFloat()*(zmax-zmin));

		ihmiskoot[i] = sizemin + randFloat()*(sizemax-sizemin);
	}
	for (i=0;i<ihmispistecount;i++)
	{
		ihmispisteet[i] = Vector(xmin+randFloat()*(xmax-xmin), 
								ymin+randFloat()*(ymax-ymin), 
								zmin+randFloat()*(zmax-zmin));
	}
}

void ihminen_free()
{
	delete [] ihmiskoot;
	delete [] ihmiset;
	delete [] ihmispisteet;
}
