#include "atomi.hpp"

Atomi *a1;
Atomi *a2;
Atomi *a3;
Atomi *a4;
Atomi *a5;
Atomi *a6;
Atomi *a7;
Atomi *a8;
Atomi *a9;

void atomi(float aika)
{
	//atomi "putkahtaa" esiin.. 
	float scalefactor = calcPosFloat(aika, 0.0f, 0.03f);
	scalefactor *= scalefactor;
	scalefactor = (float)sin(scalefactor*0.5*3.141592f);
	float alpha = calcPosFloat(aika, 0.0f, 0.05f);

	float scalefactor2 = calcPosFloat(aika, 0.96f, 1.0f);

	scalefactor -= scalefactor2;
	if (scalefactor < 0)
		scalefactor = 0;

	glLoadIdentity();

	Vector startpos = Vector(0, 0, -8.0f);
	Vector endpos = Vector(1, 1.4f, -6.5f);

	Vector targetstart = Vector(0, 0, 0);
	Vector targetend = Vector(1.5f, 0.8f, 0.0f);

	Vector look1 = lerpVector(startpos, endpos, aika);
	Vector look2 = lerpVector(targetstart, targetend, aika);

	gluLookAt(look1.x, look1.y, look1.z, look2.x, look2.y, look2.z, 0, 1, 0);
	glScalef(scalefactor, scalefactor, scalefactor);

	a1->draw(aika, alpha);
	a2->draw(aika*1.5f, alpha*calcPosFloat(aika, 0.53f, 0.63f));
	a3->draw(aika*1.7f, alpha*calcPosFloat(aika, 0.58f, 0.68f));
	a4->draw(aika*1.2f, alpha*calcPosFloat(aika, 0.63f, 0.73f));
	a5->draw(aika*1.4f, alpha*calcPosFloat(aika, 0.68f, 0.78f));
	a6->draw(aika*2.4f, alpha*calcPosFloat(aika, 0.73f, 0.83f));
	a8->draw(aika*1.8f, alpha*calcPosFloat(aika, 0.83f, 0.93f));
	a9->draw(aika*1.6f, alpha*calcPosFloat(aika, 0.88f, 0.98f));
}


void atomi_init()
{
	a1 = new Atomi(146011160, 16, 31, 1, Vector(0,0,0));
	a2 = new Atomi(69137629, 3, 8, 0.35f, Vector(5.3f, 1.6f, 3));
	a3 = new Atomi(11134, 6, 14, 0.3f, Vector(5.7f, -2.8f, 4.0f));
	a4 = new Atomi(1123534, 8, 14, 0.4f, Vector(2.7f, 2.8f, 4.0f));
	a5 = new Atomi(11341, 7, 13, 0.37f, Vector(-4.7f, -2.3f, 5.0f));
	a6 = new Atomi(11374, 8, 15, 0.37f, Vector(2.7f, -2.3f, 6.0f));
	a7 = new Atomi(11354, 11, 20, 0.47f, Vector(-1.7f, 1.3f, 5.5f));
	a8 = new Atomi(11834, 3, 5, 0.27f,  Vector(1.9f,  2.3f, 4.3f));
	a9 = new Atomi(11234, 5, 10, 0.57f, Vector(-3.0f, -3.3f, 5.1f));
}

void atomi_free()
{
	delete a1;
	delete a2;
	delete a3;
	delete a4;
	delete a5;
	delete a6;
	delete a7;
	delete a8;
	delete a9;
}

Atomi::Atomi(int randseed, int ecount, int ycount, float radiusmul, Vector pos)
{
	electroncount = ecount;
	ydincount = ycount;

	position = pos;

	int i, j;
	setSeed(randseed);
	rotates = new float*[electroncount];
	speeds = new float[electroncount];
	positions = new float[electroncount];
	radii = new float[electroncount];
	ydin = new Vector[ydincount];

	for (i=0;i<electroncount;i++)
	{
		rotates[i] = new float[3];
		for (j=0;j<3;j++)
		{
			rotates[i][j] = randFloat()*2*3.141592f;
		}

		const float minspeed = 10;
		const float maxspeed = 40;
		speeds[i] = minspeed + randFloat()*(maxspeed-minspeed);

		positions[i] = randFloat() * 2*3.141592f;
		radii[i] = (1.3f + 2.4f*randFloat())*radiusmul;
	}

	for (i=0;i<ydincount;i++)
	{
		const float suunta1 = randFloat() * 3.141592f;
		const float suunta2 = randFloat() * 3.141592f*2;
		const float radius = 0.1f+randFloat()*0.1f;

		ydin[i] = sphereCoord(radius, suunta1, suunta2);
	}
}

Atomi::~Atomi()
{
	int i;
	for (i=0;i<electroncount;i++)
	{
		delete [] rotates[i];
	}
	delete [] rotates;
	delete [] speeds;
	delete [] positions;
	delete [] radii;
	delete [] ydin;
}

void Atomi::draw(float aika, float alpha)
{
	int i, j;
	Matrix rotate, globalrotate;

	if (alpha <= 0.0f)
		return;
	globalrotate.makeRotation(aika*7, aika*5, aika*-2.1f);

	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	//kiertoradat
	glColor4f(0, 0, 0,alpha*0.7f);
	for (i=0;i<electroncount;i++)
	{
		rotate.makeRotation(rotates[i][0], rotates[i][1], rotates[i][2]);
		glBegin(GL_LINES);
		const int strips = 256;
		//piirretään ympyrä ja rotatoidaan se, ja piirretään se sitten 
		for (j=0;j<strips;j++)
		{
			const float kohta = 2*3.141592f*j / (float)(strips-1);
			const float tval = kohta * 2*3.141592f;

			Vector p = Vector((float)sin(kohta), (float)cos(kohta), 0) * radii[i];
			glVertex3fv((float *)&(position + (p*rotate)*globalrotate));
		}
		glEnd();
	}

	Vector x, y, z;
	antiRotate(&x, &y, &z);
	//elektronit

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBindTexture(GL_TEXTURE_2D, pallura->ID);

	glColor4f(0, 0, 0, alpha);

	for (i=0;i<electroncount;i++)
	{
		rotate.makeRotation(rotates[i][0], rotates[i][1], rotates[i][2]);
		const float kohta = positions[i] + speeds[i] * aika;

		Vector electronpos = Vector((float)sin(kohta), (float)cos(kohta), 0) * radii[i];
		electronpos *= rotate;
		electronpos *= globalrotate;
		electronpos += position;

		const float scale = 0.1f;
		billboard(electronpos, x, y, z, scale);
	}
	//PIIRRETÄÄN YDIN TOISTAISEKSI WANHALLA TAVaLLA
	glDisable(GL_TEXTURE_2D);

	for (i=0;i<ydincount;i++)
	{
		Vector ydinpos = ydin[i]*globalrotate + position;
		const float ydinradius = 0.06f; //protoni
		const float ydinradius2 = 0.1f; //rengas
		if (i%2)
		{
			//musta pohja
			glColor4f(0.5f,0,0,alpha);
			filledcircle(ydinpos, ydinradius);
			glColor4f(0,0,0,alpha*0.8f);
			circle(ydinpos, ydinradius2);
		}
		else
		{
			//valkoinen pohja
			glColor4f(1,1,1,alpha);
			filledcircle(ydinpos, ydinradius);
			glColor4f(0,0,0,alpha);
			circle(ydinpos, ydinradius); //reunus valkoiseen
			glColor4f(0,0,0,alpha*0.8f);
			circle(ydinpos, ydinradius2);
		}
	}
}
