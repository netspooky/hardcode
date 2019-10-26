#include "kaupunki.hpp"
#include "kellu.hpp"
#include "molekyyli.hpp"

Object *kaupunkigrid;
Path *kaupunkikamera;
Path *kaupunkikameratarget;

const int talocount = 150;
Talo *talot;

const int polkucount = 15 ;
Polku **polut;

const int kaupunkipalacount = 500;
Palanen *kaupunkipalaset;

void kaupunki(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 3);

	glLoadIdentity();

	Vector campos = kaupunkikamera->getValue(aika);
	Vector camtarget = kaupunkikameratarget->getValue(aika);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	
	for (i=0;i<polkucount;i++)
	{
		polut[i]->draw(aika, alpha);
	}
	for (i=0;i<talocount;i++)
	{
		talot[i].drawLines(aika, alpha);
	}
	for (i=0;i<talocount;i++)
	{
		talot[i].drawPolys(aika, alpha);
	}

	glEnable(GL_DEPTH_TEST);



	const float palaalpha = calcPosFloat(aika, 0.36f, 0.41f);

	if (palaalpha > 0)
	{

		for (i=0;i<kaupunkipalacount;i++)
		{
			float temp = kaupunkipalaset[i].phase + kaupunkipalaset[i].speed*aika;
			float tilpet = temp - (int)temp;

			const float tilpealpha = palaalpha*calcSaturate(tilpet, 0, 1, 3)*alpha*calcPosFloat(tilpet, 0, 1);

			Vector pos = lerpVector(kaupunkipalaset[i].pos, kaupunkipalaset[i].pos2, tilpet);
			Vector rot = lerpVector(kaupunkipalaset[i].startrot, kaupunkipalaset[i].endrot, tilpet);
			Vector c;
			
			switch(i%4)
			{
				case 0: c = sininen; break;
				case 1: c = violetti; break;
				case 2: c = oranssi; break;
				case 3: c = punainen; break;

			}
			if (i%17)
			{
				lightquad2(pos, rot, 0.1f, 0.1f, c, tilpealpha*0.5f, tilpealpha*0.8f, tilpealpha);
			}
			else
			{
				glPushMatrix();
				const float scale = 0.1f;
				glTranslatef(pos.x, pos.y, pos.z);
				glScalef(scale, scale, scale);
//				glRotatef(360*aika, rot.x, rot.y, rot.z);
				const float rotspeed = 60;
				glRotatef(rotspeed*rot.x, 1, 0, 0);
				glRotatef(rotspeed*rot.y, 0, 1, 0);
				glRotatef(rotspeed*rot.z, 0, 0, 1);
				serotonin(tilpealpha, 1);
				glPopMatrix();
			}
		}
	}

}

void kaupunki_init()
{
	int i;
	kaupunkigrid = new Object();
	kaupunkigrid->buildPlane(40, 40, 40, Vector(0, 0, 0));

	kaupunkikamera = new Path();
	kaupunkikameratarget = new Path();

	kaupunkikamera->addpoint(Vector(0, 2, -5.0f));
	kaupunkikamera->addpoint(Vector(0, 3, -8.0f));
	kaupunkikamera->addpoint(Vector(-2, 7, -11.0f));
	kaupunkikamera->addpoint(Vector(-2, 7, -1.0f));
//	kaupunkikamera->addpoint(Vector(-3, 7, -1.0f));
	kaupunkikamera->addpoint(Vector(-2, 4, 8.0f));
	kaupunkikamera->addpoint(Vector(4, 2, 9.0f));
	kaupunkikamera->addpoint(Vector(8, 6, 12.0f));
	kaupunkikamera->addpoint(Vector(9, 7, 13.0f));

	setSeed(16091);

	kaupunkikameratarget->addpoint(Vector(0, 4, 0));
	kaupunkikameratarget->addpoint(Vector(1, 0, 0));
	kaupunkikameratarget->addpoint(Vector(-3, 0, 0));
	kaupunkikameratarget->addpoint(Vector(-1.2f, 0, 0));
//	kaupunkikameratarget->addpoint(Vector(-1, 0, 2));
	kaupunkikameratarget->addpoint(Vector(-0.3f, 1, -1));
	kaupunkikameratarget->addpoint(Vector(0.7f, 2, -4));
	kaupunkikameratarget->addpoint(Vector(0, 4, 0));
	kaupunkikameratarget->addpoint(Vector(0, 6, 0));

	talot = new Talo[talocount];
	polut = new Polku*[polkucount];

	for (i=0;i<talocount;i++)
	{
		const float kohta = i / (float)talocount;
		const float step = 1.0f  / (float)talocount;

		const float talostart = 0.27f;
		talot[i].starttime = talostart + kohta*0.4f;
		talot[i].endtime = talot[i].starttime + step*4.4f;

		const float kulma = randFloat()*2*3.141592f;
		const float radius = 0.03f+randFloat()*2.5f;
		talot[i].pos = Vector((float)sin(kulma), 0, (float)cos(kulma))*radius;

		const float maxheight = 3.3f;
		const float minheight = 0.5f;
		talot[i].height = minheight + (maxheight-minheight)*randFloat();
		
		const float maxwidth = 0.2f;
		const float minwidth = 0.1f;
		talot[i].width = minwidth + (maxwidth-minwidth)*randFloat();
		if (talot[i].width > maxwidth-0.02f)
			talot[i].height *= 1.5f;

/*
		if (i%3)
			talot[i].color = oranssi;
		else
			talot[i].color = sininen;
			*/
		switch(i%3)
		{
			case 0: talot[i].color = oranssi; break;
			case 1: talot[i].color = sininen; break;
			case 2: talot[i].color = violetti; break;
		}
	}

	for (i=0;i<polkucount;i++)
	{
		const float innerradius = 0.2f;
		const float outerradius = 14.5f;
		const float kohta = i / (float)polkucount;
		float kulma = kohta * 2*3.141592f;

		Vector p1 = Vector((float)sin(kulma), 0, (float)cos(kulma))*innerradius;
		Vector p2 = Vector((float)sin(kulma), 0, (float)cos(kulma))*outerradius;

		Vector color;
/*		if (i%2)
			color = oranssi;
		else
			color = sininen;
*/
		switch(i%3)
		{
			case 0: color = oranssi; break;
			case 1: color = sininen; break;
			case 2: color = violetti; break;

		}
		polut[i] = new Polku(0, 0.35f, color, p2, p1);
	}

	kaupunkipalaset = new Palanen[kaupunkipalacount];

	for (i=0;i<kaupunkipalacount;i++)
	{
		const float ala = 0;
		const float yla = 15;
		const float radius = 1;
		
		const float k = randFloat()*2*3.141592f;

		float r = radius*randFloat();
		float r2 = r*6.5f;
		Vector p = Vector((float)sin(k), 0, (float)cos(k))*r;
		Vector p2 = Vector((float)sin(k), 0, (float)cos(k))*r2;
		kaupunkipalaset[i].pos = p + Vector(0, ala, 0);
		kaupunkipalaset[i].pos2 = p2 + Vector(0, yla, 0);

		kaupunkipalaset[i].phase = randFloat();
		kaupunkipalaset[i].speed = 3+randFloat();
		kaupunkipalaset[i].startrot = Vector(randFloat(), randFloat(), randFloat())*2*3.141592f;
		kaupunkipalaset[i].endrot = Vector(randFloat(), randFloat(), randFloat())*4*3.141592f;
	}

}

void kaupunki_free()
{
	int i;
	delete kaupunkigrid;
	delete kaupunkikamera;
	delete kaupunkikameratarget;

	delete [] talot;
	
	for (i=0;i<polkucount;i++)
	{
		delete polut[i];
	}
	delete [] polut;
	delete [] kaupunkipalaset;
}

void Talo::drawLines(float aika, float alpha)
{
	float kohta = calcPosFloat(aika, starttime, endtime);

	Vector v1 = Vector(-width, height, -width);
	Vector v2 = Vector(width, height, -width);
	Vector v3 = Vector(width, height, width);
	Vector v4 = Vector(-width, height, width);

	Vector v5 = Vector(-width, 0, -width);
	Vector v6 = Vector(width, 0, -width);
	Vector v7 = Vector(width, 0, width);
	Vector v8 = Vector(-width, 0, width);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glPushMatrix();
	glTranslatef(pos.x, pos.y, pos.z);
	glDepthMask(1);
	glEnable(GL_DEPTH_TEST);

	glColor4f(color.x, color.y, color.z, alpha);
	glLineWidth(4.0f);
	glBegin(GL_LINE_LOOP);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);
	glEnd();
	glBegin(GL_LINE_LOOP);
	glVertex3fv((float *)&v5);
	glVertex3fv((float *)&v6);
	glVertex3fv((float *)&v7);
	glVertex3fv((float *)&v8);
	glEnd();
	glBegin(GL_LINES);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v5);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v6);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v7);
	glVertex3fv((float *)&v4);
	glVertex3fv((float *)&v8);
	glEnd();

	glDisable(GL_DEPTH_TEST);


	v1 *= kohta;
	v2 *= kohta;
	v3 *= kohta;
	v4 *= kohta;
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glColor4f(1,1,1,kohta*alpha);
	glLineWidth(1.0f);
	glBegin(GL_LINE_LOOP);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);
	glEnd();
	glBegin(GL_LINE_LOOP);
	glVertex3fv((float *)&v5);
	glVertex3fv((float *)&v6);
	glVertex3fv((float *)&v7);
	glVertex3fv((float *)&v8);
	glEnd();
	glBegin(GL_LINES);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v5);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v6);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v7);
	glVertex3fv((float *)&v4);
	glVertex3fv((float *)&v8);
	glEnd();
	glPopMatrix();

}

void Talo::drawPolys(float aika, float alpha)
{
	float kohta = calcPosFloat(aika, starttime, endtime);
	Vector v1 = Vector(-width, height, -width);
	Vector v2 = Vector(width, height, -width);
	Vector v3 = Vector(width, height, width);
	Vector v4 = Vector(-width, height, width);

	Vector v5 = Vector(-width, 0, -width);
	Vector v6 = Vector(width, 0, -width);
	Vector v7 = Vector(width, 0, width);
	Vector v8 = Vector(-width, 0, width);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glPushMatrix();
	glTranslatef(pos.x, pos.y, pos.z);
	glColor4f(harmaa.x, harmaa.y, harmaa.z, alpha);

	glEnable(GL_DEPTH_TEST);
	glDepthMask(1);
	glBegin(GL_QUADS);

	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);

	glVertex3fv((float *)&v5);
	glVertex3fv((float *)&v6);
	glVertex3fv((float *)&v7);
	glVertex3fv((float *)&v8);

	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v6);
	glVertex3fv((float *)&v5);

	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v7);
	glVertex3fv((float *)&v6);

	glVertex3fv((float *)&v4);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v5);
	glVertex3fv((float *)&v8);

	glVertex3fv((float *)&v4);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v7);
	glVertex3fv((float *)&v8 );

	glEnd();
	glPopMatrix();
}
/*
	int vertexcount;
	Vector *vertices1;
	Vector *vertices2;

	void draw(float aika, float alpha);
	void generate(Vector &point1, Vector &point2);
*/

Polku::Polku(float start, float end, Vector &col, Vector &point1, Vector &point2)
{
	starttime = start;
	endtime = end;
	color = col;
	generate(point1, point2);


}
void Polku::draw(float aika, float alpha)
{
	int i;
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	glDepthMask(0);
	glLineWidth(4);

	const float kohta = calcPosFloat(aika, starttime, endtime);

	glBegin(GL_LINES);
	for (i=0;i<vertexcount;i++)
	{
		const float max = 0.7f;
		glColor4f(color.x, color.y, color.z, alpha*alpha1[i]*max); 
		glVertex3fv((float *)&vertices1[i]);
		glColor4f(color.x, color.y, color.z, alpha*alpha2[i]*max); 
		glVertex3fv((float *)&vertices2[i]);
	}
	glEnd();
	glLineWidth(1);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glBegin(GL_LINES);

	const int asti = (int)(vertexcount*kohta);
	const float frac = vertexcount*kohta - asti;

	for (i=0;i<asti;i++)
	{
		float maxwhite = 1.2f;
		if (i==asti-1)
			maxwhite *= frac;
		glColor4f(1,1,1,alpha*kohta*alpha1[i]*maxwhite);
		glVertex3fv((float *)&vertices1[i]);
		glColor4f(1,1,1,alpha*kohta*alpha1[i]*maxwhite);
		glVertex3fv((float *)&vertices2[i]);
	}
	glEnd();

	glDepthMask(1);

}

void Polku::generate(Vector &point1, Vector &point2)
{
	int i;
	vertexcount = 200; 

	const float leveys = 0.6f;
	vertices1 = new Vector[vertexcount];
	vertices2 = new Vector[vertexcount];

	alpha1 = new float[vertexcount];
	alpha2 = new float[vertexcount];

	for (i=0;i<vertexcount;i++)
	{
		float kohta = i / (float)vertexcount;
		Vector p = lerpVector(point1, point2, kohta);

		const float kulma = 17*kohta*(0.7f+0.3f*randFloat());

		Vector rvec1 = Vector(randFloat()-0.5f, 0, randFloat()-0.5f)*0.1f*randFloat();
		Vector rvec2 = Vector(randFloat()-0.5f, 0, randFloat()-0.5f)*0.1f*randFloat();
		vertices1[i] = rvec1 + p + Vector((float)sin(kulma), 0, (float)cos(kulma))*leveys*0.5f;
		vertices2[i] = rvec2 + p + Vector((float)sin(kulma), 0, (float)cos(kulma))*leveys*-0.5f;

		alpha1[i] = (float)pow(kohta, 2);
		alpha2[i] = (float)pow(kohta, 2);
	}
}

Polku::~Polku()
{
	delete [] vertices1;
	delete [] vertices2;

	delete [] alpha1;
	delete [] alpha2;
}
