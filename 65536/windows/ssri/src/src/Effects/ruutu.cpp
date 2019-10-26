//1c - 23

/*1C                     00 0C 14 2C 30 34
1D                     00 1A 30 34
1E                      00 0C 14 2C 30 34
1F                      00 0C 14 2C 30 34
20                     00 0C 14 2C 30 34 
21                     00 1A 30 34
22                     00 0C 14 2C 30 34
23                     00 0C 14 2C 30 34 38 3C
*/

#include "ruutu.hpp"
#include "molekyyli.hpp"

const int gridx = 60;
const int gridy = 60;
const float ruutusize = 2.5f;

Vector *ruudukko;
float *ruudukkorot;

const int ruutuitemcount = 700;
Ruutuitem *ruutuitems;
Sync *ruutusync;

void ruutu(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 6);
	glLoadIdentity();

	const float rotate = aika*4;
	Vector campos = Vector(0, 1+aika*aika*aika*0.2f, -1.0f+aika*2.3f);
	Vector camtarget = Vector(0, 0, 0);
	Vector pyorii = Vector((float)sin(rotate), 0, (float)cos(rotate))*(3.2f+0.5f*(float)cos(aika*15))*(0.8f+0.2f*ruutusync->getValue());;

	Vector loppu = Vector(0, 3, 0) * (float)pow(aika-0.1f, 56)*500;

	campos += loppu;
	campos += pyorii;
	camtarget += loppu;

	const float camrot = aika*0.1f;
	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, camrot, 1-camrot, camrot*0.3f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	int x, y;

 	ruutuplasma(aika*2, (float)sin(calcSaturate(aika, 0.245f, 1, 6)*3.141592f*0.5f)*0.20f);
	const float linealpha = calcPosFloat(aika, 0.047f, 0.110f);

	glLineWidth(2);
	glBegin(GL_LINES);

	for (y=0;y<gridy;y++)
	{
		for (x=0;x<gridx;x++)
		{
			Matrix rotationmatrix;
//			rotationmatrix.makeRotation(0, ruudukkorot[x+y*gridx], 0);
			rotationmatrix.makeRotation(0, ruudukkorot[x+y*gridx], 0);
			Vector v1 = ruudukko[x+y*gridx];
			Vector v2 = (v1+ Vector(0, 0.15f*aika, 0))*rotationmatrix;

			glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*0.7f*linealpha);
			glVertex3fv((float *)&v1);
			glColor4f(sininen.x, sininen.y, sininen.z, alpha*0.7f*linealpha);
			glVertex3fv((float *)&v2);
		}
	}
	glEnd();

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	const float alustapos = 1-calcPosFloat(aika, 0.0f, 0.03f);
	const float kork = 0.1f+(float)pow(sin((alustapos)*0.5f*3.141592f),16)*0.5f;

	Vector position = Vector(0, -kork, 0);
	glLineWidth(3);
	lightquad(position, Vector(0.5f*3.141592f, 0, 0), ruutusize*0.5f, ruutusize*0.5f, oranssi, alpha*0.05f, alpha*0.45f);
	lightquad(position+Vector(0, -0.1f, 0)*(1-alustapos), Vector(0.5f*3.141592f, 0, 0), ruutusize*0.43f, ruutusize*0.43f, oranssi, alpha*0.05f, alpha*0.45f);
	lightquad(position+Vector(0, -0.15f, 0)*(1-alustapos), Vector(0.5f*3.141592f, 0, 0), ruutusize*0.36f, ruutusize*0.36f, oranssi, alpha*0.02f, alpha*0.45f);
	
	//aikaa ronkitaan, varo!

	for (i=0;i<ruutuitemcount;i++)
	{
		float t = calcPosFloat(aika, ruutuitems[i].starttime, ruutuitems[i].endtime);
		if (t >= 0.001f && t <= 0.999f)
		{
			Vector pos = lerpVector(ruutuitems[i].startpos, 
									ruutuitems[i].endpos, 
									calcSaturate(t, 0, 2, 0.5f)*2);

			float twist = ruutuitems[i].starttwist*(1-t) + ruutuitems[i].endtwist*t;
			float radius = ruutuitems[i].startradius*(1-t) + ruutuitems[i].endradius*t;
			Vector displace = Vector((float)cos(twist), 0, (float)sin(twist))*radius;

			pos += displace;

			float a = calcSaturate(t*t, 0, 1, 0.7f);

			glPushMatrix();
			const float scale = 0.03f;
			glScalef(scale, scale, scale);
			glTranslatef(pos.x, pos.y, pos.z);

			glRotatef(ruutuitems[i].startrot*t + ruutuitems[i].endrot*(1-t), 
					  ruutuitems[i].rotangles.x, 
					  ruutuitems[i].rotangles.y,
					  ruutuitems[i].rotangles.z);

			switch(i%3)
			{
				case 0: fluoxetine(alpha*a, t); break;
				case 1: fluvoxamine(alpha*a, t); break;
				case 2: citalopram(alpha*a, t); break;
			}
			glPopMatrix();
		}
	}
}

void ruutuplasma(float aika, float power)
{
	int x, y;
 
	for (y=0;y<gridy;y++)
	{
		for (x=0;x<gridx;x++)
		{
			const float ypos = y / (float)gridy;
			const float xpos = x / (float)gridx;

			const float speed = 1;
			ruudukkorot[x+y*gridx] = (float)(sin(xpos*16 + aika*5*speed) + 
											 cos(ypos*11 + aika*6*speed) + 
											 sin(xpos*11 + ypos*5 + aika*2*speed) + 
											 cos(ypos*xpos*7 + aika*4*speed)) * power;

			


		}
	}

}

void ruutu_init()
{
	int i;
	int x, y;
	setSeed(160919);

	ruudukko = new Vector[gridx*gridy];
	ruudukkorot = new float[gridx*gridy];

	for (y=0;y<gridy;y++)
	{
		for (x=0;x<gridx;x++)
		{
			const float xpos = x/(float)gridx;
			const float ypos = y/(float)gridy;

			ruudukko[x+y*gridx] = Vector(xpos-0.5f, 0, ypos-0.5f) * ruutusize;
		}
	}

	ruutuitems = new Ruutuitem[ruutuitemcount];
	for (i=0;i<ruutuitemcount;i++)
	{
		const float step = 1.0f / (float)ruutuitemcount;

		const float start = 0.25f;
		ruutuitems[i].starttime = start + i*step;
		ruutuitems[i].endtime = ruutuitems[i].starttime + 0.06f + 0.10f*randFloat();

		const float ala = 0;
		const float yla = 30+randFloat()*5;

		Vector temp = polarCoord(randFloat(), randFloat()*2*3.141592f)*32;
		ruutuitems[i].startpos = Vector(temp.x, ala, temp.y);
		ruutuitems[i].endpos = Vector(temp.x, yla, temp.y);

		ruutuitems[i].rotangles = Vector(1-randFloat()*2, 1-randFloat()*2, 1-randFloat()*2);
		ruutuitems[i].startrot = 360 * randFloat();
		ruutuitems[i].endrot = 520 * randFloat();

		ruutuitems[i].starttwist = randFloat()*2*3.141592f;
		ruutuitems[i].endtwist = randFloat()*3*3.141592f;
		ruutuitems[i].startradius = randFloat()*1;
		ruutuitems[i].endradius = randFloat()*5;
	}

	ruutusync = new Sync(46);

	const int synctime = 500;
/*1C                     00 0C 14 2C 30 34
1D                     00 1A 30 34
1E                      00 0C 14 2C 30 34
1F                      00 0C 14 2C 30 34
20                     00 0C 14 2C 30 34 
21                     00 1A 30 34
22                     00 0C 14 2C 30 34
23                     00 0C 14 2C 30 34 38 3C
*/

	ruutusync->add(0x1c, 0x00, synctime);
	ruutusync->add(0x1c, 0x0c, synctime);
	ruutusync->add(0x1c, 0x14, synctime);
	ruutusync->add(0x1c, 0x2c, synctime);
	ruutusync->add(0x1c, 0x30, synctime);
	ruutusync->add(0x1c, 0x34, synctime);

	ruutusync->add(0x1d, 0x00, synctime);
	ruutusync->add(0x1d, 0x1a, synctime);
	ruutusync->add(0x1d, 0x30, synctime);
	ruutusync->add(0x1d, 0x34, synctime);

	ruutusync->add(0x1e, 0x00, synctime);
	ruutusync->add(0x1e, 0x0c, synctime);
	ruutusync->add(0x1e, 0x14, synctime);
	ruutusync->add(0x1e, 0x2c, synctime);
	ruutusync->add(0x1e, 0x30, synctime);
	ruutusync->add(0x1e, 0x34, synctime);

	ruutusync->add(0x1f, 0x00, synctime);
	ruutusync->add(0x1f, 0x0c, synctime);
	ruutusync->add(0x1f, 0x14, synctime);
	ruutusync->add(0x1f, 0x2c, synctime);
	ruutusync->add(0x1f, 0x30, synctime);
	ruutusync->add(0x1f, 0x34, synctime);

	ruutusync->add(0x20, 0x00, synctime);
	ruutusync->add(0x20, 0x0c, synctime);
	ruutusync->add(0x20, 0x14, synctime);
	ruutusync->add(0x20, 0x2c, synctime);
	ruutusync->add(0x20, 0x30, synctime);
	ruutusync->add(0x20, 0x34, synctime);

	ruutusync->add(0x21, 0x00, synctime);
	ruutusync->add(0x21, 0x1a, synctime);
	ruutusync->add(0x21, 0x30, synctime);
	ruutusync->add(0x21, 0x34, synctime);

	ruutusync->add(0x22, 0x00, synctime);
	ruutusync->add(0x22, 0x0c, synctime);
	ruutusync->add(0x22, 0x14, synctime);
	ruutusync->add(0x22, 0x2c, synctime);
	ruutusync->add(0x22, 0x30, synctime);
	ruutusync->add(0x22, 0x34, synctime);

	ruutusync->add(0x23, 0x00, synctime);
	ruutusync->add(0x23, 0x0c, synctime);
	ruutusync->add(0x23, 0x14, synctime);
	ruutusync->add(0x23, 0x2c, synctime);
	ruutusync->add(0x23, 0x30, synctime);
	ruutusync->add(0x23, 0x34, synctime);
	ruutusync->add(0x23, 0x38, synctime);
	ruutusync->add(0x23, 0x3c, synctime);
}

void ruutu_free()
{
	delete [] ruudukko;
	delete [] ruudukkorot;

	delete [] ruutuitems;
	delete ruutusync;

}
