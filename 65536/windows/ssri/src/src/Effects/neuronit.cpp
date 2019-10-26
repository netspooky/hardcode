#include "neuronit.hpp"

int neuroncount = 60;
Neuron *neurons;

void neuronit(float aika)
{
	int i, j;
	const float alpha = calcSaturate(aika, 0, 1, 6) * (0.9f+0.2f*(float)cos(aika*32));

	glLoadIdentity();

	Vector campos = Vector(1-aika*2, 0, -3.0f);
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glRotatef(aika*70, 0.1f, 1.0f, -0.3f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);

	float kohta = neuroncount*calcPosFloat(aika, 0.0f, 0.2f);
	int asti = (int)kohta;
	float frac = kohta-asti;


	for (i=0;i<asti;i++)
	{
		glPointSize(5);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glBegin(GL_POINTS);
		glColor4f(sininen.x, sininen.y, sininen.z,alpha);
		glVertex3fv((float *)&neurons[i].pos);
		glEnd();

		float alphamod = alpha;
		if (i==asti-1)
			alphamod *= frac;

		for (j=0;j<neurons[i].linkcount;j++)
		{
			Vector v1 = neurons[i].pos;
			Vector v2 = neurons[neurons[i].links[j]].pos;
			Vector puolimatka = (v1+v2)*0.5f + neurons[i].displacements[j];

			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			glColor4f(oranssi.x, oranssi.y, oranssi.z, alphamod*0.25f);
			glBegin(GL_TRIANGLES);
			glVertex3fv((float *)&v1);
			glVertex3fv((float *)&v2);
			glVertex3fv((float *)&puolimatka);
			glEnd();

			glBlendFunc(GL_SRC_ALPHA, GL_ONE);//_MINUS_SRC_ALPHA);
			glColor4f(oranssi.x, oranssi.y, oranssi.z, alphamod*0.4f);
			glBegin(GL_LINE_LOOP);
			glVertex3fv((float *)&v1);
			glVertex3fv((float *)&v2);
			glVertex3fv((float *)&puolimatka);
			glEnd();


/*			float t;
			const int segments = 16;
			glBegin(GL_LINE_STRIP);

			for (t=0;t<=1.0f;t+=1.0f/segments)
			{
				glVertex3fv((float *)&lerpVector(v1, puolimatka, t));
			}
			glEnd();
			glBegin(GL_LINE_STRIP);
			for (t=0;t<=1.0f;t+=1.0f/segments)
			{
				glVertex3fv((float *)&lerpVector(v2, puolimatka, t));
			}
			glEnd();
*/
		}
		glEnd();
	}
}

void neuronit_init()
{
	int i;
	int j;
	neurons = new Neuron[neuroncount];

	Matrix scale;
	scale.makeScale(2.5f, 1.6f, 1.6f);

	setSeed(1609);
	for (i=0;i<neuroncount;i++)
	{
		neurons[i].pos = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*scale;
		neurons[i].linkcount = RAND_INT(1,2);
		neurons[i].links = new int[neurons[i].linkcount];
		neurons[i].displacements = new Vector[neurons[i].linkcount];

		for (j=0;j<neurons[i].linkcount;j++)
		{
			neurons[i].links[j] = RAND_INT(0, neuroncount-1);
			neurons[i].displacements[j] = sphereCoord(0.05f+0.2f*randFloat(), 
													  randFloat()*3.141592f,
													  randFloat()*3.141592f*2);
		}
	}
}

void neuronit_free()
{
	int i;
	for (i=0;i<neuroncount;i++)
	{
		delete [] neurons[i].links;
		delete [] neurons[i].displacements;
	}
	delete [] neurons;
}
