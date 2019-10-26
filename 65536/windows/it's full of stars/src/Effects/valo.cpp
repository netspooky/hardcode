#include "valo.hpp"
#include "../linestrip.hpp"

int aaltocount;
LineStrip *aallot;

void valo(float aika)
{
	int i, j;
	float alpha = 1;

	if (aika < 0.5f)
		alpha *= calcPosFloat(aika, 0.0f, 0.01f);
	else
		alpha *= (1-calcPosFloat(aika, 0.7f, 1.0f));

	const float aaltoalpha = calcPosFloat(aika, 0.0f, 0.15f)*0.7f;

	glLoadIdentity();

	Vector campos = Vector(0, 0, -7.0f + aika*2);
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	glLineWidth(3);
	for (i=0;i<aaltocount;i++)
	{
		const float aaltot = calcPosFloat(aika, aallot[i].starttime, aallot[i].endtime);
		if (aaltot > 0.001f || aaltot < 0.99f)
		{
			glBegin(GL_LINE_STRIP);
			for (j=0;j<aallot[i].count;j++)
			{
				Vector p = aallot[i].vertices[j];
				Vector c = aallot[i].vertices2[j];
				float a = aallot[i].alphas[j] * alpha * aaltoalpha;

				glColor4f(c.x, c.y, c.z, a);
				glVertex3fv((float *)&p);
			}
			glEnd();
		}
	}
}

void valo_init()
{
	int i, j;
	aaltocount = 40;

	srand(160591);
	aallot = new LineStrip[aaltocount];

	for (i=0;i<aaltocount;i++)
	{
		const int vcount = 70;

		aallot[i].count = vcount;
		aallot[i].vertices = new Vector[vcount];
		aallot[i].vertices2 = new Vector[vcount];
		aallot[i].alphas = new float[vcount];

		aallot[i].starttime = randFloat();
		aallot[i].endtime = randFloat();

		Vector v1 = sphereCoord(12, randFloat()*3.141592f, randFloat()*2*3.141592f);
		Vector v2 = randomSphereVector(0.0f);//sphereCoord(2+2*randFloat(), randFloat()*3.141592f, randFloat()*2*3.141592f);//randomSphereVector(1.5f);
		Vector v3 = sphereCoord(12, randFloat()*3.141592f, randFloat()*2*3.141592f);

		Path *polku = new Path();

		polku->addpoint(v1);
		polku->addpoint(v2);
		polku->addpoint(v3);

		float t = 0.0f;
		Vector color = Vector(0.6f+randFloat()*0.2f, 0.3f+randFloat()*0.2f, 0.1f+randFloat()*0.3f);
		for (j=0;j<vcount;j++)
		{
			aallot[i].vertices[j] = polku->getValue(t);
			aallot[i].alphas[j] = (float)pow(0.7f+0.3f*sin(t*2*52*3.141592f), 1.4f);
			aallot[i].vertices2[j] = color;
			t += 1.0f / vcount;
		}
		delete polku;
	}
}

void valo_free()
{
	int i;
	for (i=0;i<aaltocount;i++)
	{
		delete [] aallot[i].vertices;
		delete [] aallot[i].vertices2;
		delete [] aallot[i].alphas;
	}
	delete [] aallot;

} 
