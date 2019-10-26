#include "viivatus.hpp"
#include "../line.hpp"
#include "molekyyli.hpp"
#include "../tausta.hpp"

const int viivacount = 700;
const int matocount = 20;

Line **viivat;

const int viivamolekyylicount = 50;
Vector *viivamolekyylit;
Vector *viivarotations;
Sync *viivasync;

void viivatus(float aika)
{
	int i, j;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	//HIRVITTÄVÄ PURKKA!!!
//	if (kello.getMilliseconds() > 40000)
//		taustahori(0.4f, 1);

	glLoadIdentity();

	Vector loppu = Vector(0.7f, 0, 1) * (float)pow((aika-0.1f), 46)*300;

	Vector campos = Vector(-3.5f+aika*6.3f, 0, -3.0f+0.2f*(float)sin(aika*11))+loppu;
	Vector camtarget = Vector(-3.5f+aika*6.1f+0.3f*(float)sin(aika*8), 0, 0)+loppu;

	const float keinu = (float)cos(aika*11)*0.1f;
	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, keinu, 1-keinu, 0);

	static float kierto = 0;
	const float designalpha = viivasync->getValue();

	if (viivasync->getActivated())
	{
		kierto -= 34;
	}



	glRotatef(aika*160, 1, 0, 0);
	glRotatef(kierto, 1, 0, 0);
	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	for (i=0;i<matocount;i++)
	{
		const float ikohta = i / (float)matocount;
		const int eteneminen = (int)((ikohta-0.3f)*viivacount);
		
		int asti = (int)(viivacount*aika)*2 + eteneminen;
		if (asti > viivacount)
			asti = viivacount;
		if (asti < 0)
			asti = 0;

		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		if (i%2)
			glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*0.7f);
		else
			glColor4f(sininen.x, sininen.y, sininen.z, alpha*0.7f);

		glLineWidth(4.0f);
		glBegin(GL_LINE_STRIP);
		for (j=0;j<asti;j++)
		{
			Vector v1, v2;
			viivat[i][j].calcPos(aika, &v1, &v2);
			glVertex3fv((float *)&v1);
			glVertex3fv((float *)&v2);
		}
		glEnd();
		glLineWidth(1.0f);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		glColor4f(1,1,1,alpha*0.5f*(0.9f+0.2f*(float)cos(aika*51+ikohta*2*3.141592f/matocount )));
//		if (i%2)
//			glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*0.4f);
//		else
//			glColor4f(sininen.x, sininen.y, sininen.z, alpha*0.4f);
		glBegin(GL_LINE_STRIP);
		for (j=0;j<asti;j++)
		{
			Vector v1, v2;
			viivat[i][j].calcPos(aika, &v1, &v2);
			glVertex3fv((float *)&v1);
			glVertex3fv((float *)&v2);
		}
		glEnd();
	}

	for (i=-5;i<5;i++)
	{
		const float ikohta = (i+5) / (float)10.0f;
		glPushMatrix();
		glScalef(0.1f, 0.1f, 0.1f);
		glTranslatef(i*10.0f, 0, 0);
		glRotatef(ikohta*360, 1, 0, 0);
		if (i%2)
		{
			glTranslatef(0, 3, 0);
			fluoxetine(alpha*0.7f, 1);
		}
		else
		{
			glTranslatef(0, -3, 0);
			fluvoxamine(alpha*0.7f, 1);
		}
		glPopMatrix();
	}

	if (designalpha > 0.0f)
	{
		for (i=0;i<viivamolekyylicount;i++)
		{
			glPushMatrix();
			glScalef(0.05f, 0.05f, 0.05f);
			glTranslatef(viivamolekyylit[i].x, viivamolekyylit[i].y, viivamolekyylit[i].z);
			glRotatef(90, viivarotations[i].x, viivarotations[i].y, viivarotations[i].z);
			switch(i%3)
			{
				case 0: fluoxetine(alpha*designalpha, 1); break;
				case 1: fluvoxamine(alpha*designalpha, 1); break;
				case 2: citalopram(alpha*designalpha, 1); break;
			}

			glPopMatrix();
		}
	}
}

void viivatus_init()
{
	int i;
	int j;

	viivat = new Line*[matocount];
	viivamolekyylit = new Vector[viivamolekyylicount];
	viivarotations = new Vector[viivamolekyylicount];

	viivasync = new Sync(24);
	const int synctime = 200;

	viivasync->add(0xE, 0x00, synctime);
	viivasync->add(0xE, 0x0C, synctime);
	viivasync->add(0xE, 0x2C, synctime);

	viivasync->add(0xF, 0x00, synctime);
	viivasync->add(0xF, 0x0C, synctime);
	viivasync->add(0xF, 0x2C, synctime);

	viivasync->add(0x10, 0x00, synctime);
	viivasync->add(0x10, 0x0C, synctime);
	viivasync->add(0x10, 0x2C, synctime);

	viivasync->add(0x11, 0x00, synctime);
	viivasync->add(0x11, 0x0C, synctime);
	viivasync->add(0x11, 0x2C, synctime);
	viivasync->add(0x11, 0x36, synctime);

	viivasync->add(0x12, 0x00, synctime);
	viivasync->add(0x12, 0x0C, synctime);
	viivasync->add(0x12, 0x2C, synctime);

	viivasync->add(0x13, 0x20, synctime);
	viivasync->add(0x13, 0x2C, synctime);

	viivasync->add(0x14, 0x00, synctime);
	viivasync->add(0x14, 0x20, synctime);
	viivasync->add(0x14, 0x28, synctime);

	viivasync->add(0x15, 0x00, synctime);
	viivasync->add(0x15, 0x20, synctime);
	viivasync->add(0x15, 0x28, synctime);


/*4-10                   00 0C 2C
11                      00 0C 2C 36
12                      00 0C 2C
13                      20 2C
14-17                 00 20 28    
*/

	for (i=0;i<matocount;i++)
	{
		const float ipos = i / (float)matocount;
		viivat[i] = new Line[viivacount];
		for (j=0;j<viivacount;j++)
		{
			const float jpos = j / (float)viivacount;

			const float xpos = (jpos-0.5f)*10;
			const float ypos = 0.2f*(float)(sin(jpos*19)+cos(jpos*15+ipos*17)+ipos);
			const float zpos = 0.3f*(float)(sin(jpos*24)+cos(jpos*17+ipos*7));

			Matrix rotate;
			rotate.makeRotation(jpos*25, 0, 0);

			viivat[i][j].startpos = Vector(xpos, ypos, zpos)*rotate;
			viivat[i][j].endpos = Vector(xpos, ypos, zpos)*rotate;

			viivat[i][j].startrot = Vector(randFloat(), randFloat(), randFloat());
			viivat[i][j].endrot = Vector(randFloat(), randFloat(), randFloat())*5;

			viivat[i][j].starttime = 0.0f;
			viivat[i][j].endtime = randFloat();

			viivat[i][j].length = randFloat()*0.05f;
		}
	}
	for (i=0;i<viivamolekyylicount;i++)
	{
		Matrix scale;
		scale.makeScale(200, 30, 30);
		viivamolekyylit[i] = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*scale;
		viivarotations[i] = Vector(randFloat(), randFloat(), randFloat());//*2*3.141592f;
	}
}

void viivatus_free()
{
	int i;

	for (i=0;i<matocount;i++)
	{
		delete [] viivat[i];
	}
	delete [] viivat;
	delete [] viivamolekyylit;
	delete [] viivarotations;

	delete viivasync;
}
