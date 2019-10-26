#include "kukka.hpp"

const int kukkacount = 500;
const float flowerspeed = 60;
Flower *kukat;

void kukka(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glLoadIdentity();
	glDisable(GL_DEPTH_TEST);

	const float rotangle = aika*0.4f;

	const float rotradius = 1.8f + 0.6f*(float)sin(aika*16);

	Vector campos = Vector(rotradius*(float)cos(aika*8), 
						   1.3f + 0.4f*(float)sin(aika*15), 
						   rotradius*(float)sin(aika*8));

	const float eteen = (float)pow(aika, 17);

	Vector camtarget = Vector(0, eteen, 0);
	const float tilt = 0.3f*(float)sin(aika*4*3.141592f);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z+eteen*3, tilt, 1-tilt, 0);

	glDepthMask(1);
	glEnable(GL_DEPTH_TEST);

	for (i=0;i<kukkacount;i++)
	{
		kukat[i].draw(calcPosFloat(aika, kukat[i].starttime, kukat[i].endtime), alpha*0.7f);
	}
}

void Flower::draw(float aika, float alpha)
{
	int i, j;

	const float kohta = calcSaturate(aika, 0, 1, 1);

	if (aika <= 0.0001f || aika >= 0.9999f)
	{
		return;
	}

	//varsi
	glLineWidth(1.0f);
	glEnable(GL_BLEND);

	glBegin(GL_LINES);

	Vector end1 = Vector(0, -0.4f, 0)+pos;
	Vector end2 = Vector(0,0,0)+pos;

	glColor4f(1,1,1, kohta*alpha);
	glVertex3fv((float *)&end1);
	glColor4f(0.1f, 0.4f, 0.05f, kohta*alpha);
	glVertex3fv((float *)&end2);
	
	glEnd();

	//terälehdet
	for (i=0;i<teralehtia;i++)
	{
		const float petaladd = 2*3.141592f / teralehtia;
		const float kulma = i*petaladd;
		//terälehden kärki
		Vector endpoint = Vector(teralehtipituus*(float)sin(kulma), korkeus, teralehtipituus*(float)cos(kulma))*kohta; 
		Vector origo = Vector(0, 0, 0);

		//suuntavektorit bezier-käyrille
		Vector sivu1 = Vector((float)sin(kulma-teralehtikulma), endpoint.y*0.5f, (float)cos(kulma-teralehtikulma))*teralehtipower*kohta;
		Vector keskus = Vector((float)sin(kulma), endpoint.y*0.5f-teralehtikayristyma, (float)cos(kulma))*teralehtipower2*kohta;
		Vector sivu2 = Vector((float)sin(kulma+teralehtikulma), endpoint.y*0.5f, (float)cos(kulma+teralehtikulma))*teralehtipower*kohta;

		//terälehden reunat. Bezier-käyrät keskeltä kärkeen suuntavektorin suuntaisesti
		const int petalvertices = 10;
		const float petalstep = 1.0f / (petalvertices-1);

		QuadraticBezierCurve curve1, curve2, curve3;

		curve1.set(origo, keskus, endpoint);
		curve2.set(origo, sivu1, endpoint);
		curve3.set(origo, sivu2, endpoint);

		Vector centerpoints[petalvertices];
		Vector points1[petalvertices];
		Vector points2[petalvertices];

		Matrix rotation;
		rotation.makeRotation(rotate.x, rotate.y, rotate.z);

		for (j=0;j<petalvertices;j++)
		{
			centerpoints[j] = (curve1.getValue(j*petalstep)*petalvariation[i])*rotation;
			points1[j] = (curve2.getValue(j*petalstep)*petalvariation[i])*rotation;
			points2[j] = (curve3.getValue(j*petalstep)*petalvariation[i])*rotation;
		}
		glEnable(GL_BLEND);
		//terälehdet itse
		
		glColor4f(color.x, color.y, color.z, alpha*petalcolors[i]);
		glBegin(GL_TRIANGLE_STRIP);
		for (j=0;j<petalvertices;j++)
		{
			glVertex3fv((float *)&(pos+centerpoints[j]));
			glVertex3fv((float *)&(pos+points1[j]));
		}
		glEnd();
		glBegin(GL_TRIANGLE_STRIP);
		for (j=0;j<petalvertices;j++)
		{
			glVertex3fv((float *)&(pos+centerpoints[j]));
			glVertex3fv((float *)&(pos+points2[j]));
		}
		glEnd();

		//terälehtien reunat
		glDisable(GL_BLEND);

		glColor4f(1-alpha, 1-alpha, 1-alpha, alpha);
		glBegin(GL_LINE_STRIP);

		for (j=0;j<petalvertices;j++)
		{
			glVertex3fv((float *)&(pos+points1[j]));
		}
		glEnd();
		glBegin(GL_LINE_STRIP);
		for (j=0;j<petalvertices;j++)
		{
			glVertex3fv((float *)&(pos+points2[j]));
		}
		glEnd();
	}

	glEnable(GL_BLEND);

	glColor4f(0.9f, 0.7f, 0.2f, alpha);
	glBegin(GL_LINES);
	for (i=0;i<hedecount;i++)
	{
		glVertex3fv((float *)&(heteet[(i<<1)]*kohta+pos));
		glVertex3fv((float *)&(heteet[(i<<1)+1]*kohta+pos));
	}
	glEnd();
}

void kukka_init()
{
	int i, j;
	kukat = new Flower[kukkacount];

	for (i=0;i<kukkacount;i++)
	{
		const float kohta = i / (float)kukkacount;
		const float step = 1.0f / (float)kukkacount;

		if ((i%2)==0)
		{
			const float tangle = randFloat()*2*3.141592f;
			kukat[i].pos = Vector((float)sin(tangle), 0, (float)cos(tangle))*randFloat()*1.2f;
		}
		else
		{
			kukat[i].pos = Vector((float)(0.5*sin(kohta*35) + 0.7f*cos(kohta*25) - 0.3*cos(kohta*16+0.4f)),
								  0, 
								  (float)(0.78*cos(kohta*33.4) - 0.5*cos(kohta*21-0.4) + 0.25*sin(kohta*14.2+2.1)));

			const float randrad = 0.25f*randFloat();
			const float randang = 2*3.141592f*randFloat();
			kukat[i].pos += Vector((float)sin(randang), 0, (float)cos(randang))*randrad;
		}

		const float maxrotate = 1.0f;
		kukat[i].rotate = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*maxrotate;

		kukat[i].starttime = kohta;
		kukat[i].endtime = kohta+step*flowerspeed;

		if ((i%26)==0)
			kukat[i].teralehtia = 55 + (int)(5*sin(kohta*17));
		else
			kukat[i].teralehtia = 11 + (int)(5*sin(kohta*17));

		kukat[i].teralehtipituus = 0.17f + randFloat()*0.06f;
		kukat[i].teralehtikulma = 0.24f + randFloat()*0.12f + 0.04f*(float)sin(kohta*25);
		kukat[i].teralehtipower = 0.18f + randFloat()*0.05f;
		kukat[i].teralehtipower2 = 0.15f + randFloat()*0.02f;
		kukat[i].teralehtikayristyma = 0.1f + 0.05f*(float)sin(kohta*11);//randFloat()*0.03f;
		kukat[i].korkeus = 0.08f + randFloat()*0.05f;

		kukat[i].petalcolors = new float[kukat[i].teralehtia];
		kukat[i].petalvariation = new float[kukat[i].teralehtia];
		for (j=0;j<kukat[i].teralehtia;j++)
		{
			kukat[i].petalcolors[j] = 0.9f + 0.2f*randFloat();
			kukat[i].petalvariation[j] = 0.85f + 0.3f*randFloat();
		}

		kukat[i].hedecount = RAND_INT(10,20);
		kukat[i].heteet = new Vector[kukat[i].hedecount*2];
		for (j=0;j<kukat[i].hedecount;j++)
		{
			//alaosa
			const float heteenkorkeusmax = 0.05f;
			const float heteenkorkeusmin = 0.02f;
			const float hederadmax = 0.03f;
			const float hederadmin = 0.01f;
			const float hedeangle = randFloat()*2*3.141592f;
			kukat[i].heteet[(j<<1)] = Vector((float)sin(hedeangle), 0, (float)cos(hedeangle))*(hederadmin);
			kukat[i].heteet[(j<<1)+1] = Vector(0, heteenkorkeusmin+randFloat()*(heteenkorkeusmax-heteenkorkeusmin), 0) 
										+ Vector((float)sin(hedeangle), 0, (float)cos(hedeangle))*
											   (hederadmin+(hederadmax-hederadmin)*randFloat());
		}

		const float vaihtelu = 0.1f;
		switch(RAND_INT(0, 4))
		{
			case 0: kukat[i].color = Vector(0.9f+randFloat()*vaihtelu, 0.15f+randFloat()*vaihtelu, 0.07f+randFloat()*vaihtelu); break;
			case 1: kukat[i].color = Vector(0.9f+randFloat()*vaihtelu, 0.8f+randFloat()*vaihtelu, 0.15f+randFloat()*vaihtelu); break;
			case 2: kukat[i].color = Vector(0.9f+randFloat()*vaihtelu, 0.25f+randFloat()*vaihtelu, 0.7f+randFloat()*vaihtelu); break;
			case 3: kukat[i].color = Vector(0.11f+randFloat()*vaihtelu, 0.2f+randFloat()*vaihtelu, 0.9f+randFloat()*vaihtelu); break;
			case 4: kukat[i].color = Vector(0.9f+randFloat()*vaihtelu, 0.9f+randFloat()*vaihtelu, 0.9f+randFloat()*vaihtelu); break;
		}
	}
}

void kukka_free()
{
	int i;
	for (i=0;i<kukkacount;i++)
	{
		delete [] kukat[i].petalcolors;
		delete [] kukat[i].petalvariation;
	}
	delete [] kukat;
}
