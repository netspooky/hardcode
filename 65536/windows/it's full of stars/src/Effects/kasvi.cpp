#include "kasvi.hpp"
#include "../linestrip.hpp"

int kasvicount;
Kukka *kukat;

void kasvi(float aika)
{
	int i, j, k;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	static bool osuma = false;
	static float aaltoalpha = 0.0f;
	if (sound.getOrder() == 0xC)
	{
		osuma = true;
	}

	static float prevaika;
	float dt = aika - prevaika;
	prevaika = aika;

	if (osuma)
	{
		if (aaltoalpha < 0.4f)
			aaltoalpha += dt*2.5f;
	}

	glLoadIdentity();

	Vector campos = Vector(0, 0, -35.0f+aika*20);
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(aika*20, 0.1f, 0.4f, 0.9f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	glLineWidth(3);
	for (i=0;i<kasvicount;i++)
	{
		Kukka *flower = &kukat[i];
		if (aika >= flower->starttime && aika <= flower->endtime)
		{
			glPushMatrix();

			const float t = calcPosFloat(aika, flower->starttime, flower->endtime);
			const float a = calcSaturate(aika, flower->starttime, flower->endtime, 1);
			Vector c = flower->color;
			Vector p = flower->pos;
			glTranslatef(p.x, p.y, p.z);
			const int kohta = flower->stripcount;

			glColor4f(c.x, c.y, c.z,a*alpha*0.3f);
			for (j=0;j<kohta;j++)
			{
//				const float fade = 1-j/(float)kohta;
				glBegin(GL_LINE_STRIP);
				for (k=0;k<flower->strips[j].count;k++)
				{
					glVertex3fv((float *)&flower->strips[j].vertices[k]);
				}
				glEnd();
			}
			glPopMatrix();
		}
	}
}

void kasvi_init()
{
	int i;
	int j;
	int k;
	kasvicount = 40;
	kukat = new Kukka[kasvicount];
	const int vertexcount = 20;


	srand(16099);

	for (k=0;k<kasvicount;k++)
	{
		kukat[k].stripcount = 100;
		kukat[k].strips = new LineStrip[kukat[k].stripcount];

		kukat[k].starttime = randFloat();
		kukat[k].endtime = kukat[k].starttime + 0.5f + 0.1f*randFloat();
		kukat[k].pos = randomSphereVector(11);

		kukat[k].color = Vector(0.6f+randFloat()*0.2f, 0.3f+randFloat()*0.2f, 0.1f+randFloat()*0.2f);

		Lista *curvelist = new Lista();

		Matrix rot;
		rot.makeRotation(randFloat()*2*3.141592f, randFloat()*2*3.141592f, randFloat()*2*3.141592f);
		Vector v1 = Vector(0, -4, 0)*rot;
		Vector t1 = randomSphereVector(1).normalize();
		Vector v2 = Vector(0, 16, 0)*rot;
		Vector t2 = randomSphereVector(1).normalize();

		HermiteCurve *c = new HermiteCurve(v1, v1+t1, v2+t2, v2);
		curvelist->add(c);

		for (i=0;i<kukat[k].stripcount;i++)
		{
			kukat[k].strips[i].count = vertexcount;
			kukat[k].strips[i].vertices = new Vector[vertexcount];

			//valitaan listasta joku olemassaoleva kurvi 
			int count = curvelist->getNodeCount();
			int index = (rand()%(count+1))-1;
			if (i==0 || i==1 || i==2)
				index = 0;

			curvelist->goToNode(index);
			HermiteCurve *curve = (HermiteCurve *)curvelist->getCurrent();

			const float maxlength = 1;//1-i / (float)kukat[k].stripcount;

			const float curvet = 0.5f*randFloat();
			Vector p1 = curve->getValue(curvet*maxlength);
			Vector p2 = curve->getDerivative(curvet*maxlength);//randomSphereVector(3);
			Vector p3 = p1+randomSphereVector(maxlength);
			Vector p4 = randomSphereVector(maxlength);

			HermiteCurve *curve2 = new HermiteCurve(p1, p1+p2, p3, p3+p4);
			curvelist->add(curve2);

			float t=0.0f;
			for (j=0;j<vertexcount;j++)
			{
				kukat[k].strips[i].vertices[j] = curve2->getValue(t);
				t += 1.0f / vertexcount;
			}
		}

		delete curvelist;
	}

}

void kasvi_free()
{
	int i, j;
	for (i=0;i<kasvicount;i++)
	{
		for (j=0;j<kukat[i].stripcount;j++)
		{
			delete [] kukat[i].strips[j].vertices;
		}
		delete [] kukat[i].strips;
	}
	delete [] kukat;


} 
 
