#include "pyorre.hpp"
#include "molekyyli.hpp"
#include "../tausta.hpp"

const int pyorrecount = 10000;
PyorreItem *pyorteet;

Path *spiral1;
Sync *pyorresync;

void pyorre(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 6);

//	taustahori(0.4f, 1-calcPosFloat(aika, 0.8f, 1.0f));



	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	
	glLoadIdentity();

//	Vector liike = Vector(1-aika*2, 0, 0);
	Vector camtarget = Vector(0, aika, 0);// - liike;


	static int camindex=0;
	const int maxcampositions = 7;
	Vector campositions[maxcampositions] = { Vector(0, 2, -7.0f),
											 Vector(1, 3, -5.0f),
											 Vector(-2, 2.3f, -8.0f),
											 Vector(-3, -4, 5),
											 Vector(3, -2.3f, 7.0f),
											 Vector(2, 1.3f, 5.0f),
											 Vector(1, -4.3f, 5.0f)


	};

//	Vector campos = Vector(0, 2, -7.0f) - liike;
	Vector campos = campositions[camindex%maxcampositions];


	Vector loppu = Vector(-0.9f, 2, -1) * (float)pow((aika-0.10f), 46)*300;

	campos += loppu;
	camtarget += loppu;

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0.2f, 0.8f, 0);
	glRotatef(aika*70, 0, 1, 0);

	const float glowamount = calcPosFloat(aika, 0.15f, 0.2f);
	const float syncamount = pyorresync->getValue();

	static bool eka = true;


	if (pyorresync->getActivated())
	{
//		if (eka)
//			eka = false;
//		else
			camindex++;
	}
	//kartio
	const int kartiopoints = 2500;
	glPointSize(4);
	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);

	glDisable(GL_DEPTH_TEST);
	glDepthMask(1);

	const int pyorreasti = (int)(pyorrecount*calcPosFloat(aika, 0.02f, 0.07f));

	Vector *readypoints = new Vector[pyorreasti];
	float *readycolors = new float[pyorreasti*4];

	int offs = 0;
	for (i=0;i<pyorreasti;i++)
	{
		const float kohta = i / (float)pyorrecount;
		float t = aika*0.6f + kohta*0.5f + pyorteet[i].phase;
		if (t > 1.0f)
		{
			int size = (int)t;
			t -= size;
		}
		const float radius = (pyorteet[i].startradius*(1-t) + pyorteet[i].endradius*t );
		const float kulma = pyorteet[i].startangle-(radius);

		const float pyorrepointalpha = 0.3f;

		readypoints[i] = Vector((float)sin(kulma), 0, (float)cos(kulma))*radius;
		if (i%7)
		{
			readycolors[offs++] = sininen.x;
			readycolors[offs++] = sininen.y;
			readycolors[offs++] = sininen.z;
			readycolors[offs++] = alpha*calcSaturate(t, 0, 1, 5)*pyorrepointalpha;
		}
		else
		{
			readycolors[offs++] = oranssi.x;
			readycolors[offs++] = oranssi.y;
			readycolors[offs++] = oranssi.z;
			readycolors[offs++] = alpha*calcSaturate(t, 0, 1, 5)*pyorrepointalpha;
		}
	}

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_DEPTH_TEST);
	glPointSize(4);
	glDepthMask(0);
	glBegin(GL_POINTS);
	for (i=0;i<pyorreasti;i++)
	{
#ifndef BIGENDIAN
		glColor4fv((float *)&readycolors[i<<2]);
#else
		glColor4fv((float *)&readycolors[i*4]);
#endif
		glVertex3fv((float *)&readypoints[i]);
	}
	glEnd();
	glDepthMask(1);
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_DEPTH_TEST);
	glPointSize(1);
	glBegin(GL_POINTS);
	glColor4f(1,1,1,alpha*syncamount);
	for (i=0;i<pyorreasti;i++)
	{
		glVertex3fv((float *)&readypoints[i]);
	}
	glEnd();

	delete [] readypoints;
	delete [] readycolors;
	
	const float kartioalpha = 2*glowamount*(0.9f+0.2f*randFloat())*(0.15f+0.15f*(float)(cos(aika*74)*cos(aika*137)*cos(aika*215)));
	const float EPSILON = 0.001f;
	if (kartioalpha > EPSILON)
	{
		glPointSize(4);
		glBegin(GL_POINTS);
		for (i=0;i<kartiopoints;i++)
		{
			float kohta = i / (float)kartiopoints;

			const float radius = kohta*0.4f;
			const float kulma = kohta*141592653;

			Vector pos = Vector((float)sin(kulma)*radius, -(kohta)*2, (float)cos(kulma)*radius);
	//		glColor4f(sininen.x, sininen.y, sininen.z, (1-kohta)*alpha*kartioalpha);
			glColor4f(oranssi.x, oranssi.y, oranssi.z, (1-kohta)*alpha*kartioalpha*2);
			glVertex3fv((float *)&pos);
		}
		glEnd();

		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		glDepthMask(1);
		glBegin(GL_POINTS);

		for (i=0;i<kartiopoints;i++)
		{
			float kohta = i / (float)kartiopoints;

			const float radius = kohta*0.4f;
			const float kulma = kohta*141592653;

			Vector pos = Vector((float)sin(kulma)*radius, (kohta)*2, (float)cos(kulma)*radius);
			glColor4f(oranssi.x, oranssi.y, oranssi.z, (1-kohta)*alpha*kartioalpha);
			glVertex3fv((float *)&pos);
		}
		glEnd();

		const int palasia = 400;
		float t;
		glDepthMask(1);
		glDisable(GL_DEPTH_TEST);
 		for (t=0.0f;t<1.0f;t += 1.0f/palasia)
		{
			float aika2 = t-aika*0.6f;
			if (aika2 > 1.0f)
				aika2 -= (int)aika2;
			if (aika2 < 0.0f)
				aika2 = 1.0f+aika2;
			Vector v = spiral1->getValue(aika2);

			float maxkoko = 0.1f;
			float koko = aika2*maxkoko;

			const float a1 = 0.25f*alpha*(1-aika2*aika2)*glowamount;
			const float a2 = 0.90f*alpha*(1-aika2*aika2)*glowamount;

			const float speed = 0.5f;
			Vector rotate = Vector(17*aika2*(float)cos(aika*11*speed), 
								   -14*aika2*(float)cos(aika*15*speed), 
								   12.4f*aika2*(float)cos(aika*16*speed))*t;

			lightquad(v, rotate, koko, koko, oranssi, a1, a2);
			v.x = -v.x;
			v.z = -v.z;

			//basarisynkki tähän
			const float ylimaarainen = 1.2f;
			lightquad(v, rotate, koko, koko, punainen, a1*syncamount*ylimaarainen, a2*syncamount*ylimaarainen);

			v.y = -v.y;
			const float amod = (float)(0.8f+0.4f*(float)cos(aika*64));
			lightquad(v, rotate, koko, koko, sininen, a1*amod, a2*amod);
			v.x = -v.x;
			v.z = -v.z;
			lightquad(v, rotate, koko, koko, violetti, a1*amod*syncamount*ylimaarainen, a2*amod*syncamount*ylimaarainen);

		}
	}
	
	
	
	/*

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_DEPTH_TEST);
	glPointSize(2);
	glBegin(GL_POINTS);
	for (i=0;i<pyorreasti;i++)
	{
#ifndef BIGENDIAN
		glColor4fv((float *)&readycolors[i<<2]);
#else
		glColor4fv((float *)&readycolors[i*4]);
#endif
		glVertex3fv((float *)&readypoints[i]);
	}
	glEnd();
*/
}

void pyorre_init()
{
	int i;
	pyorteet = new PyorreItem[pyorrecount];
	spiral1 = new Path();

	pyorresync = new Sync(15);
	//22-27 = 16-1b
	const int synclength = 700;
	pyorresync->add(0x16, 0x00, synclength);
	pyorresync->add(0x16, 0x20, synclength);
	pyorresync->add(0x16, 0x28, synclength);
	pyorresync->add(0x17, 0x00, synclength);
	pyorresync->add(0x17, 0x20, synclength);
	pyorresync->add(0x17, 0x28, synclength);
	pyorresync->add(0x18, 0x28, synclength);
	pyorresync->add(0x19, 0x00, synclength);
	pyorresync->add(0x19, 0x08, synclength);
	pyorresync->add(0x19, 0x14, synclength);
	pyorresync->add(0x19, 0x20, synclength);
	pyorresync->add(0x19, 0x28, synclength);
	pyorresync->add(0x1B, 0x2c, synclength);
	pyorresync->add(0x1B, 0x32, synclength);
	pyorresync->add(0x1B, 0x38, synclength);

	
/*	pyorresync = new Sync(12);
	pyorresync->add(0, 0x10, 1000);
	pyorresync->add(0, 0x20, 1000);
	pyorresync->add(0, 0x30, 1000);
	pyorresync->add(1, 0x10, 1000);
	pyorresync->add(1, 0x20, 1000);
	pyorresync->add(1, 0x30, 1000);
	pyorresync->add(2, 0x10, 1000);
	pyorresync->add(2, 0x20, 1000);
	pyorresync->add(2, 0x30, 1000);
	pyorresync->add(3, 0x10, 1000);
	pyorresync->add(3, 0x20, 1000);
	pyorresync->add(3, 0x30, 1000);
*/

	const int pointcount = 200;
	for (i=0;i<pointcount;i++)
	{
		const float k = i / (float)pointcount;
		const float twists = 5.0;
		const float phase = 3.5f;

		const float kulma = k*2*3.141592f*twists+phase;
		const float radius = k*k*k*4.3f;
		const float riseheight = k*1.5f;

		spiral1->addpoint(Vector((float)sin(kulma)*radius, riseheight, (float)cos(kulma)*radius));
	}

//	spiral1->addpoint(Vector(0, 0, 0));
//	spiral1->addpoint(Vector(0, 1, 0));
//	spiral1->addpoint(Vector(1, 1, 0));
//	spiral1->addpoint(Vector(1, 2, 0));

	setSeed(1691);
	for (i=0;i<pyorrecount;i++)
	{
		const int minrotations = 1;
		const int maxrotations = 2;
		const float rotations = minrotations + randFloat()*(maxrotations-minrotations);

		float basekulma = 0.0f;
		switch(i%5)
		{
			case 0: basekulma = 0.5f; break;
			case 1: basekulma = 0.5f+(1.0f/5)*2*3.141592f; break;
			case 2: basekulma = 0.5f+(2.0f/5)*2*3.141592f; break;
			case 3: basekulma = 0.5f+(3.0f/5)*2*3.141592f; break;
			case 4: basekulma = 0.5f+(4.0f/5)*2*3.141592f; break;
		}

		pyorteet[i].startangle = basekulma + (randFloat())*0.55f;

		const float startmax = 5.0f;
		const float startmin = 4.0f;
		const float endmax = 0.2f;
		const float endmin = 0.05f;

		pyorteet[i].endradius = endmin + (endmax-endmin)*randFloat();
		pyorteet[i].startradius = startmin + (startmax-startmin)*randFloat();

		pyorteet[i].phase = randFloat();
	}
}

void pyorre_free()
{
	delete [] pyorteet;
	delete pyorresync;
	delete spiral1;
}
