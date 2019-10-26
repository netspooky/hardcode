#include "curves.hpp"


Curve *kayrat;
const int curvecount = 700;

void curves(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector campos = Vector(0, 0, -27.0f);
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glRotatef(aika*50, 0.2f, 0.5f, 0.1f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);
	glDepthMask(1);

	glLineWidth(4);
	float fogcol[] = {1,1,1,1};

	glFogi(GL_FOG_MODE, GL_LINEAR); //EXP, EXP2, LINEAR
	glFogfv(GL_FOG_COLOR, fogcol);
	glFogf(GL_FOG_DENSITY, 0.4f+0.4f*(float)cos(aika*10));
	glHint(GL_FOG_HINT, GL_DONT_CARE);
	glFogf(GL_FOG_START, 15 );
	glFogf(GL_FOG_END, 25);
	glEnable(GL_FOG);

	for (i=0;i<curvecount;i++)
	{
		kayrat[i].draw(aika, alpha);
	}
	glDisable(GL_FOG);


	
}

void Curve::draw(float aika, float alpha)
{
	int i;
	const float t = calcPosFloat(aika, this->starttime, this->endtime);
	if (t < 0.001f || t > 0.999f)
		return;

	const float maxalpha = 0.7f;
	int destvertex = (int)(t*this->vertexcount);
	float frac = t*this->vertexcount - destvertex;

	float a = calcSaturate(t, 0, 1, 3)*maxalpha;

	glPushMatrix();

	glTranslatef(this->pos.x, this->pos.y, this->pos.z);

	Vector r = lerpVector(this->startrot, this->endrot, t);
	const float maxrot = 360;
	glRotatef(maxrot*r.x, 1, 0, 0);
	glRotatef(maxrot*r.y, 0, 1, 0);
	glRotatef(maxrot*r.z, 0, 0, 1);

//	glLineWidth(this->width);
	glBegin(GL_LINE_STRIP);
	for (i=0;i<destvertex;i++)
	{
		Vector v = this->vertices[i];
		if (i == destvertex-1)
			glColor4f(this->color.x, this->color.y, this->color.z, alpha*a*frac);
		else
			glColor4f(this->color.x, this->color.y, this->color.z, alpha*a);
		glVertex3fv((float *)&v);
	}
	glEnd();
	glPopMatrix();
}

void curves_init()
{
	int i, j;
	kayrat = new Curve[curvecount];

	srand(168);
	for (i=0;i<curvecount;i++)
	{
		const float dim = 20;
		Matrix scale;
		scale.makeScale(dim, dim, dim);

		kayrat[i].pos = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*scale;

		Vector r1 = Vector(0, 0, 0);
		Vector r2 = Vector(randFloat(), randFloat(), randFloat())*0.2f;

		kayrat[i].starttime = 0;//randFloat();
		kayrat[i].endtime = 1;//kayrat[i].starttime + 0.1f;

		if ((rand()%100) < 16)
		{
			kayrat[i].color = Vector(1, 0, 0);
		}
		else
		{
			kayrat[i].color = Vector(0, 0, 0);
		}

		kayrat[i].startrot = r1;
		kayrat[i].endrot = r2;

		kayrat[i].width = 2 + (float)(rand()%3);

		kayrat[i].vertexcount = 100;
		kayrat[i].vertices = new Vector[kayrat[i].vertexcount];

		float a = randFloat()*2*3.141592f;
		float b = randFloat()*2*3.141592f;

		float da = randFloat()*0.5f;
		float db = randFloat()*0.5f;

		float s = 0.1f+randFloat()*0.2f;
		Vector c = Vector(0, 0, 0);
		for (j=0;j<kayrat[i].vertexcount;j++)
		{
			Vector dc = sphereCoord(s, a, b);
			a+=da;
			b+=db;
			kayrat[i].vertices[j] = c;
			c += dc;
		}
	}
}

void curves_free()
{
	int i;
	for (i=0;i<curvecount;i++)
	{
		delete [] kayrat[i].vertices;
	}
	delete [] kayrat;
} 
