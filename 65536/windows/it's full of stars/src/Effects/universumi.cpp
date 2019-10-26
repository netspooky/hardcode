#include "universumi.hpp"

int universecount;
Universe *universes;

void universumi(float aika)
{
	int i, j;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector kohta = Vector(aika*0.3f+0.3f, 0, -20+aika*10);
	Vector campos = kohta + Vector(-0.7f, 0, 0);
	Vector camtarget = kohta + Vector(0, 0, 5);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	float fogcol[] = {0, 0, 0,1};
	glFogi(GL_FOG_MODE, GL_LINEAR); //EXP, EXP2, LINEAR
	glFogfv(GL_FOG_COLOR, fogcol);
	glFogf(GL_FOG_DENSITY, 0.4f+0.4f*(float)cos(aika*10));
	glHint(GL_FOG_HINT, GL_DONT_CARE);
	glFogf(GL_FOG_START, 3);
	glFogf(GL_FOG_END, 6);
	glEnable(GL_FOG);

	//spiraali
	const int spiralcount = 5;

	const float spiralvertices = 200;
	float spiralstartpos = kohta.z;
	float spiralendpos = kohta.z + 6;

	glLineWidth(3);

	for (j=0;j<spiralcount;j++)
	{
		const float spirallength = 7;
		const float spiralradius = 0.5f+j*0.01f*aika;
		const float spiraltwist = 3.4f;
		Vector sc = Vector(0.9f, 0.4f, 0.3f);

		const float kulmatwist = j*0.27f;
		glColor4f(sc.x, sc.y, sc.z, alpha*0.4f);
		glBegin(GL_LINE_STRIP);
		for (i=0;i<spiralvertices;i++)
		{
			float t = i / (float)spiralvertices;
			float z = spiralstartpos*(1-t) + spiralendpos*t;

			float kulma = z*spiraltwist + kulmatwist;
			Vector p = Vector((float)sin(kulma)*spiralradius, (float)cos(kulma)*spiralradius, z);
			glVertex3fv((float *)&p);
		}
		glEnd();
	}

	glLineWidth(2.0f);
	for (j=0;j<universecount;j++)
	{
		const float s = 0.5f*(float)pow(sin(alpha*0.5f*3.141592f), 2);

		Vector r = Vector(j*0.1f+aika, j*0.04f+aika*0.6f, j*0.12f-aika*0.2f);
		if ((campos - universes[j].basepos).length() > 7)
			continue;
		if (campos.z > (universes[j].basepos.z+1))
			continue;
		glPushMatrix();
		glTranslatef(universes[j].basepos.x, universes[j].basepos.y, universes[j].basepos.z);

		const float rotamount = 100;
		glRotatef(rotamount*r.x, 1, 0, 0);
		glRotatef(rotamount*r.y, 0, 1, 0);
		glRotatef(rotamount*r.z, 0, 0, 1);

		Vector c = universes[j].basecolor;
		glScalef(s, s, s);
		glBegin(GL_LINES);
		for (i=0;i<universes[j].lines.count;i++)
		{
			glColor4f(c.x, c.y, c.z, alpha*0.7f*universes[j].alphas[i]);
			glVertex3fv((float *)&universes[j].lines.vertices[i]);
			glVertex3fv((float *)&universes[j].lines.vertices2[i]);
		}
		glEnd();
		glPointSize(5);
		glBegin(GL_POINTS);
		for (i=0;i<universes[j].lines.count;i++)
		{
			glColor4f(c.x, c.y, c.z, alpha*universes[j].alphas[i]);
			glVertex3fv((float *)&universes[j].lines.vertices[i]);
			glVertex3fv((float *)&universes[j].lines.vertices2[i]);
		}
		glEnd();
		glPopMatrix();
	}
	glEnd();
	glDisable(GL_FOG);


}

void universumi_init()
{
	int i;
	int j;
	universecount = 10;
	universes = new Universe[universecount];

	for (i=0;i<universecount;i++)
	{
		int count = 270;
		universes[i].lines.count = count;
		universes[i].lines.vertices = new Vector[count];
		universes[i].lines.vertices2 = new Vector[count];
		universes[i].alphas = new float[count];

		for (j=0;j<count;j++)
		{
			Vector p1 = randomBoxVector(1);

			const float maxd = 1.0f;

			float l = 0.05f + 0.12f*randFloat();
			Vector p2;
			switch(rand()%3)
			{
				case 0: p2 = Vector(l, 0, 0); break;
				case 1: p2 = Vector(0, l, 0); break;
				case 2: p2 = Vector(0, 0, l); break;
			}
			universes[i].lines.vertices[j] = p1;
			universes[i].lines.vertices2[j] = p1+p2;
			universes[i].alphas[j] = (float)pow(p1.length()+0.1f, 1.7f);
		}
		universes[i].basecolor = Vector(0.6f+randFloat()*0.2f, 0.3f+randFloat()*0.2f, 0.1f+randFloat()*0.2f);
		universes[i].basepos = Vector(0, 0, -i*2.0f);
	}
}

void universumi_free()
{
	int i;
	for (i=0;i<universecount;i++)
	{
		delete [] universes[i].lines.vertices;
		delete [] universes[i].lines.vertices2;
		delete [] universes[i].alphas;
	}
	delete [] universes;
} 
