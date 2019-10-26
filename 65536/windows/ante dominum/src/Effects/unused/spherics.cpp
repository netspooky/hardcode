#include <stdio.h>
#include "spherics.hpp"

extern int *fibonaccinumbers; //fibotree.cpp

Lista *sphericsstructs;
const int sphericscount = 500;

void sphericsStruct::draw(float aika, float alpha)
{
	int i;
	float t = calcPosFloat(aika, this->starttime, this->endtime);

	float a = calcSaturate(t, 0, 1, 1)*0.4f;
	Vector pos = lerpVector(this->startpos, this->endpos, t);
	Vector rot = lerpVector(this->startrot, this->endrot, t);

	glPushMatrix();
	glTranslatef(pos.x, pos.y, pos.z);

	glRotatef(360*rot.x, 1, 0, 0);
	glRotatef(360*rot.y, 0, 1, 0);
	glRotatef(360*rot.z, 0, 0, 1);

	glColor4f(0,0,0,alpha*a);

//	glBegin(this->type);
	glBegin(GL_LINE_LOOP);
	for (i=0;i<this->count;i++)
	{
		glVertex3fv((float *)&this->vertices[i]);
	}
	glEnd();
	glPopMatrix();
}
void spherics(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector campos = Vector(0, 0, -21.0f);
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(aika*50, 0, 0, -1);
	glTranslatef(-aika*2, aika*1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	float fogcol[] = {1,1,1,1};

	glFogi(GL_FOG_MODE, GL_LINEAR); //EXP, EXP2, LINEAR
	glFogfv(GL_FOG_COLOR, fogcol);
	glFogf(GL_FOG_DENSITY, 0.4f+0.4f*(float)cos(aika*10));
	glHint(GL_FOG_HINT, GL_DONT_CARE);
	glFogf(GL_FOG_START, 20);
	glFogf(GL_FOG_END, 35);
	glEnable(GL_FOG);

	int i;

	glLineWidth(2);
	sphericsstructs->goToStart();
	for (i=0;i<sphericsstructs->getNodeCount();i++)
	{
		sphericsStruct *s = (sphericsStruct *)sphericsstructs->getCurrent();
		s->draw(aika, alpha);
		sphericsstructs->goForward();
	}
	glDisable(GL_FOG);
}
	
void spherics_init()
{
	int i;

	srand(15106919);

	sphericsstructs = new Lista();

	for (i=0;i<sphericscount;i++) 
	{
		const int count = fibonaccinumbers[5+(rand()%7)];

		sphericsStruct *s = new sphericsStruct();
		s->count = count;
		s->vertices = new Vector[s->count];

		s->starttime = randFloat();
		s->endtime = s->starttime + 0.3f+randFloat()*0.7f;

		s->startrot = Vector(randFloat(), randFloat(), randFloat());
		s->endrot = Vector(randFloat(), randFloat(), randFloat());

		const float dim = 15.0f;
		const float z = 20;
		Vector kohta = Vector(randFloat()-0.5f, randFloat()-0.5f, 0)*dim;
		s->startpos = kohta + Vector(0, 0, randFloat()*10);
		s->endpos = kohta + Vector(0, 0, -z+4);

		Matrix rot;
		rot.makeRotation(randFloat()*2*3.141592f, randFloat()*2*3.141592f, randFloat()*2*3.141592f);

		const float scale = 0.4f+0.25f*(randFloat()-0.5f);

		const int rmuli = s->count/10;//rand()%8;
		const float rmulf = randFloat()-0.5f;
		const float dmulf = 1+(randFloat()-0.5f)*2;

		switch(rand()%2)
		{
			case 0: s->type = GL_TRIANGLE_FAN; break;
			case 1: s->type = GL_LINE_LOOP; break;

		}

		for (int k=0;k<count;k++)
		{
			float t = k / (float)count;
			float r = scale + rmulf*(float)cos(t*rmuli*3.141592f);
			float d = 2*3.141592f*dmulf;
			Vector p = Vector((float)sin(t*d), (float)cos(t*d), 0)*r*rot;
			s->vertices[k] = p;

		}
		sphericsstructs->add(s);
	}
}

void spherics_free()
{
	sphericsstructs->destroy();
	delete sphericsstructs;
}