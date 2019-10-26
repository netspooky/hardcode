#include "synty.hpp"

Cluster *stars;
int starcount;

void synty_draw(float aika, float rotateaika, float camadd, float scale, float alpha)
{
	int i, j;

	glLoadIdentity();

	Vector campos = Vector(0, 0, -9.0f+camadd);
	Vector camtarget = Vector(0, 0, 0+camadd);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(rotateaika*25, 0.2f, 0.8f, -0.1f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	
	Vector xr, yr, zr;
	antiRotate(&xr, &yr, &zr);

	glScalef(scale, scale,scale);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, flare->ID);
	glBegin(GL_QUADS);
	for (i=0;i<starcount;i++)
	{
		for (j=0;j<stars[i].count;j++)
		{
			float t = calcPosFloat(aika, stars[i].starttimes[j], stars[i].endtimes[j]);
			if (t > 0.001f)
			{
				const float a = t*alpha;
				Vector p = stars[i].points[j];
				Vector c = stars[i].colors[j];
				const float size = t*0.2f;

				glColor4f(c.x, c.y, c.z, a);

				Vector v1 = p - xr*size - yr*size;
				Vector v2 = p + xr*size - yr*size;
				Vector v3 = p + xr*size + yr*size;
				Vector v4 = p - xr*size + yr*size;

				glTexCoord2f(0, 0);
				glVertex3fv((float *)&v1);
				glTexCoord2f(1, 0);
				glVertex3fv((float *)&v2);
				glTexCoord2f(1, 1);
				glVertex3fv((float *)&v3);
				glTexCoord2f(0, 1);
				glVertex3fv((float *)&v4);
			}
		}
	}
	glEnd();
	glDisable(GL_TEXTURE_2D);
	glLineWidth(2.0f);
	glBegin(GL_LINES);
	for (i=0;i<starcount;i++)
	{
		for (j=0;j<stars[i].count;j++)
		{
			float t = calcPosFloat(aika, stars[i].starttimes[j], stars[i].endtimes[j]);
			if (t > 0.001f)
			{
				const float a = t*alpha*0.4f;
				Vector p1 = stars[i].points[j];
				Vector p2 = stars[i].points[stars[i].indices[j]];
				Vector c = stars[i].colors[j];

				glColor4f(c.x, c.y, c.z, a);
				glVertex3fv((float *)&p1);
				glVertex3fv((float *)&p2);
			}
		}
	}
	glEnd();
/*
	glBegin(GL_QUADS);
	for (i=0;i<stripcount;i++)
	{
		float d = (float)fabs(strips[i].vertices[0].z-kohta.z);
		if (d < 25)
		{
			float a = 0.8f+0.4f*(float)sin(d);
			glColor4f(0.9f, 0.4f, 0.3f, a*alpha);
			const float size = 0.2f*a;

			for (j=0;j<strips[i].count2;j++)
			{
				Vector p = strips[i].vertices2[j];

				Vector v1 = p - xr*size - yr*size;
				Vector v2 = p + xr*size - yr*size;
				Vector v3 = p + xr*size + yr*size;
				Vector v4 = p - xr*size + yr*size;

				glTexCoord2f(0, 0);
				glVertex3fv((float *)&v1);
				glTexCoord2f(1, 0);
				glVertex3fv((float *)&v2);
				glTexCoord2f(1, 1);
				glVertex3fv((float *)&v3);
				glTexCoord2f(0, 1);
				glVertex3fv((float *)&v4);

			}
		}
	}
	glEnd();
*/


}


void synty(float aika)
{
	synty_draw(aika, aika, (float)pow(aika+0.1f, 3)*8, 1, calcSaturate(aika, 0, 1, 6));
}

void synty_init()
{
	int i;
	int j;
	starcount = 100;
	stars = new Cluster[starcount];

	srand(16516);
	setSeed(169);
	for (i=0;i<starcount;i++)
	{
		int count = 5+rand()%17;

		stars[i].count = count;
		stars[i].points = new Vector[count];
		stars[i].colors = new Vector[count];
		stars[i].starttimes = new float[count];
		stars[i].endtimes = new float[count];
		stars[i].indices = new int [count];

		float basetime = randFloat();
		Vector basepos = randomSphereVector(4);
		Vector basecolor = Vector(0.6f+randFloat()*0.2f, 0.3f+randFloat()*0.2f, 0.1f+randFloat()*0.2f);

		for (j=0;j<count;j++)
		{
			stars[i].starttimes[j] = basetime + randFloat()*0.05f;
			stars[i].endtimes[j] = stars[i].starttimes[j] + randFloat()*0.1f;
			stars[i].points[j] = basepos + randomSphereVector(0.3f);
			stars[i].colors[j] = basecolor + Vector(randFloat()*0.1f,randFloat()*0.1f, randFloat()*0.1f);//randomSphereVector(0.3f);
			do
			{
				stars[i].indices[j] = rand()%count;
			} while (stars[i].indices[j]==j);

		}
	}
}

void synty_free()
{
	int i;
	for (i=0;i<starcount;i++)
	{
		delete [] stars[i].points;
		delete [] stars[i].starttimes;
		delete [] stars[i].endtimes;

	}
} 
