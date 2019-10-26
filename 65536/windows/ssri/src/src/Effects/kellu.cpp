//8-13

#include "kellu.hpp"

const int palanencount = 5000;
Palanen *palaset;

Sync *kellusync;

void kellu(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector campos = Vector(3-aika*6, 0, 2.5f+0.5f*(float)sin(aika*7));
	Vector camtarget = campos;
	camtarget.z = 0;
	const float rot = (float)cos(aika*11)*0.1f;

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, rot, 1-rot, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	const float syncval = kellusync->getValue();//0.5f+0.5f*(float)sin(aika*177);

	glLineWidth(3);
	glBegin(GL_LINES);
	for (i=0;i<palanencount;i++)
	{
		Matrix rot;
		Vector rotaatio = lerpVector(palaset[i].startrot, palaset[i].endrot, aika);
		rot.makeRotation(rotaatio.x, rotaatio.y, rotaatio.z);

		Vector v1 = palaset[i].pos + Vector(palaset[i].length, 0, 0) * rot;
		Vector v2 = palaset[i].pos + Vector(-palaset[i].length, 0, 0) * rot;
		glColor4f(palaset[i].color.x, palaset[i].color.y, palaset[i].color.z, alpha*(0.3f+0.4f*syncval));

		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
	}
	glEnd();

	glLineWidth(1);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glColor4f(1,1,1,alpha*syncval);
	glBegin(GL_LINES);
	for (i=0;i<palanencount;i++)
	{
		Matrix rot;
		Vector rotaatio = lerpVector(palaset[i].startrot, palaset[i].endrot, aika);
		rot.makeRotation(rotaatio.x, rotaatio.y, rotaatio.z);

		Vector v1 = palaset[i].pos + Vector(palaset[i].length, 0, 0) * rot;
		Vector v2 = palaset[i].pos + Vector(-palaset[i].length, 0, 0) * rot;

		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
	}
	glEnd();
	
}

void kellu_init()
{
	int i;
	palaset = new Palanen[palanencount];

	Matrix scale, scale2;
	Vector scalevec = Vector(10, 1, 1);
	Vector scalevec2 = scalevec*2;

	scale.makeScale(scalevec.x, scalevec.y, scalevec.z);
	scale2.makeScale(scalevec2.x, scalevec2.y, scalevec2.z);

	for (i=0;i<palanencount;i++)
	{
		switch(i%3)
		{
			case 0: palaset[i].color = punainen; break;
			case 1: palaset[i].color = sininen; break;
			case 2: palaset[i].color = violetti; break;
		}
		const float rotamount = 5;
		palaset[i].startrot = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*rotamount;
		palaset[i].endrot = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*rotamount;

		palaset[i].pos = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*scale2;
		palaset[i].length = 0.01f + randFloat()*0.02f;
	}

	kellusync = new Sync(50);
/*
4-10                   00 0C 2C
11                      00 0C 2C 36
12                      00 0C 2C
13                      20 2C
*/
	const int synctime = 400;
	kellusync->add(0x04, 0x00, synctime);
	kellusync->add(0x04, 0x0C, synctime);
	kellusync->add(0x04, 0x2C, synctime);
	kellusync->add(0x05, 0x00, synctime);
	kellusync->add(0x05, 0x0C, synctime);
	kellusync->add(0x05, 0x2C, synctime);
	kellusync->add(0x06, 0x00, synctime);
	kellusync->add(0x06, 0x0C, synctime);
	kellusync->add(0x06, 0x2C, synctime);
	kellusync->add(0x07, 0x00, synctime);
	kellusync->add(0x07, 0x0C, synctime);
	kellusync->add(0x07, 0x2C, synctime);
	kellusync->add(0x08, 0x00, synctime);
	kellusync->add(0x08, 0x0C, synctime);
	kellusync->add(0x08, 0x2C, synctime);
	kellusync->add(0x09, 0x00, synctime);
	kellusync->add(0x09, 0x0C, synctime);
	kellusync->add(0x09, 0x2C, synctime);
	kellusync->add(0x0a, 0x00, synctime);
	kellusync->add(0x0a, 0x0C, synctime);
	kellusync->add(0x0a, 0x2C, synctime);
	kellusync->add(0x0b, 0x00, synctime);
	kellusync->add(0x0b, 0x0C, synctime);
	kellusync->add(0x0b, 0x2C, synctime);
	kellusync->add(0x0c, 0x00, synctime);
	kellusync->add(0x0c, 0x0C, synctime);
	kellusync->add(0x0c, 0x2C, synctime);
	kellusync->add(0x0d, 0x00, synctime);
	kellusync->add(0x0d, 0x0C, synctime);
	kellusync->add(0x0d, 0x2C, synctime);
	kellusync->add(0x0e, 0x00, synctime);
	kellusync->add(0x0e, 0x0C, synctime);
	kellusync->add(0x0e, 0x2C, synctime);
	kellusync->add(0x0f, 0x00, synctime);
	kellusync->add(0x0f, 0x0C, synctime);
	kellusync->add(0x0f, 0x2C, synctime);
	kellusync->add(0x10, 0x00, synctime);
	kellusync->add(0x10, 0x0C, synctime);
	kellusync->add(0x10, 0x2C, synctime);
	kellusync->add(0x11, 0x00, synctime);
	kellusync->add(0x11, 0x0C, synctime);
	kellusync->add(0x11, 0x2C, synctime);
	kellusync->add(0x11, 0x36, synctime);
	kellusync->add(0x12, 0x00, synctime);
	kellusync->add(0x12, 0x0C, synctime);
	kellusync->add(0x12, 0x2C, synctime);
	kellusync->add(0x13, 0x0C, synctime);
	kellusync->add(0x13, 0x2C, synctime);


}

void kellu_free()
{
	delete [] palaset;

	delete kellusync;
}
