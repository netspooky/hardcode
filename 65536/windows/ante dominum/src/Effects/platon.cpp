#include <stdio.h>
#include "platon.hpp"

Lista *platonstructs;
const int platoncount = 250;

Path *platoncam;
Path *platontarget;

Matrix platonrotate; //hack :(

void platonStruct::draw(float aika, float alpha)
{
	Vector pos = this->startpos;//lerpVector(this->startpos, this->endpos, t);
	Vector rot = lerpVector(this->startrot, this->endrot, aika);

	glPushMatrix();
    Vector pos2 = pos*platonrotate;

	glTranslatef(pos2.x, pos2.y, pos2.z);

	glRotatef(360*rot.x, 1, 0, 0);
	glRotatef(360*rot.y, 0, 1, 0);
	glRotatef(360*rot.z, 0, 0, 1);

	const float s = 0.04f;
	glScalef(s, s, s);
	switch(this->type)
	{
		case 0: tetrahedron(); break;
		case 1: octahedron(); break;
		case 2: hexahedron(); break;
		case 3: icosahedron(); break;
		case 4: dodecahedron(); break;
	}

	glEnd();
	glPopMatrix();
}
void platon(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);

	const float ambientvalo[] = {1, 0.4f, 0.4f, 1};
	const float specularvalo[] = {1, 0.2f, 0.2f, 1};
	const float diffusevalo[] = {1, 0.5f, 0.5f, 1};
	const float valoposition[] = {2, 2, 17*(float)sin(aika*6), 1.0f };

	glLightfv(GL_LIGHT1, GL_AMBIENT, ambientvalo);
  	glLightfv(GL_LIGHT1, GL_DIFFUSE, diffusevalo);
	glLightfv(GL_LIGHT1, GL_SPECULAR, specularvalo);
	glShadeModel(GL_SMOOTH);
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT1);

    platonrotate.makeRotation(0, 0, 0);

    const float k = aika;
    Matrix camrot;
    camrot.makeRotation(0, 0, 0);

	Vector campos = Vector(0, 0, -9.0f+aika*3);
	Vector camtarget = Vector(0, 0, 0);
    Vector camup = Vector(0, 1, 0)*camrot;

	glLoadIdentity();
	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, camup.x, camup.y, camup.z);
  
    glRotatef(aika*50, 0.1f, 0, 1);
	glLightfv(GL_LIGHT1, GL_POSITION, valoposition);
	float fogcol[] = {1,1,1,1};
	glFogi(GL_FOG_MODE, GL_LINEAR); //EXP, EXP2, LINEAR
	glFogfv(GL_FOG_COLOR, fogcol);
	glFogf(GL_FOG_DENSITY, 0.4f+0.4f*(float)cos(aika*10));
	glHint(GL_FOG_HINT, GL_DONT_CARE);
	glFogf(GL_FOG_START, 1);
	glFogf(GL_FOG_END, 4);
	glEnable(GL_FOG);
	glDisable(GL_CULL_FACE);
	glEnable(GL_NORMALIZE);

	platonstructs->goToStart();
	for (i=0;i<platonstructs->getNodeCount();i++)
	{
		platonStruct *s = (platonStruct *)platonstructs->getCurrent();
		s->draw(aika, alpha);
		platonstructs->goForward();
	}
	glDisable(GL_FOG);
	glDisable(GL_LIGHTING);
	glDisable(GL_LIGHT1);
	glDisable(GL_NORMALIZE);

	perspective2D(1,1);
	glLoadIdentity();
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDepthMask(0);
	glDisable(GL_DEPTH_TEST);
	glColor4f(1,1,1,1-calcSaturate(aika, 0, 1, 10));
	glBegin(GL_QUADS);
	glVertex2f(0, 0);
	glVertex2f(1, 0);
	glVertex2f(1, 1);
	glVertex2f(0, 1);
	glEnd();
	glDepthMask(1);
	perspective3D();
	glLoadIdentity();
}
	
void platon_init()
{
	int i;

	srand(15106919);
	setSeed(5161968);

	platonstructs = new Lista();

    Path *polku = new Path();

    Vector p1 = randomSphereVector(1);
    polku->addpoint(p1);
    for (i=0;i<16;i++)
    {
        polku->addpoint(randomSphereVector(1));
    }
    polku->addpoint(p1);


	for (i=0;i<platoncount;i++) 
	{
        const float t = i / (float)platoncount;
		platonStruct *s = new platonStruct();

		s->starttime = randFloat()*0.8f;
		s->endtime = s->starttime + 0.1f;
		s->startrot = Vector(randFloat(), randFloat(), randFloat());
		s->endrot = Vector(randFloat(), randFloat(), randFloat())*2;

		const float dim = 3.0f;
		const float z = 10;

		Vector kohta = Vector(randFloat()-0.5f, randFloat()-0.5f, 0)*dim;
//		s->startpos = kohta + Vector(0, 0, -randFloat()*10);//randFloat()*0);
//		s->endpos = kohta + Vector(0, 0, -z);

        s->startpos = polku->getValue(t) - Vector(0, 0, 5);

		s->type = rand()%5;

		Matrix rot;
		rot.makeRotation(randFloat()*2*3.141592f, randFloat()*2*3.141592f, randFloat()*2*3.141592f);

		platonstructs->add(s);
	}

    delete polku;
}

void platon_free()
{
	platonstructs->destroy();
	delete platonstructs;
} 
