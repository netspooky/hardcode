#include "tunneli.hpp"
#include "../linestrip.hpp"

int tunnelicount;
LineStrip *tunnelstrips;

void tunneli(float aika)
{
	int i, j;
	float alpha = calcSaturate(aika, 0, 1, 2);

	if (aika > 0.5f)
		alpha = 1;

	glLoadIdentity();

	float kohta = -4+aika*aika*100;
	Vector campos = Vector(0, 0, -2+kohta);
	Vector camtarget = Vector(0, 0, kohta);

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
	glFogf(GL_FOG_START, 6);
	glFogf(GL_FOG_END, 10);
	glEnable(GL_FOG);

	glLineWidth(3);
	glPointSize(5);
	glBegin(GL_LINES);
	for (i=0;i<tunnelicount;i++)
	{
		glColor4f(0.3f, 0.6f, 0.9f, alpha*0.46f);
		if ((tunnelstrips[i].vertices[0].z < kohta+10) &&
			(tunnelstrips[i].vertices[0].z > kohta-3))
		for (j=0;j<tunnelstrips[i].count;j++)
		{
			glVertex3fv((float *)&tunnelstrips[i].vertices[j]);
			glVertex3fv((float *)&tunnelstrips[i].vertices2[j]);
		}
	}
	glEnd();
	glBegin(GL_POINTS);
	for (i=0;i<tunnelicount;i++)
	{
		glColor4f(0.3f, 0.6f, 0.9f, alpha*1.0f);
		if ((tunnelstrips[i].vertices[0].z < kohta+10) &&
			(tunnelstrips[i].vertices[0].z > kohta-3))
		for (j=0;j<tunnelstrips[i].count;j++)
		{
			glVertex3fv((float *)&tunnelstrips[i].vertices[j]);
			glVertex3fv((float *)&tunnelstrips[i].vertices2[j]);
		}
	}
	glEnd();
	glDisable(GL_FOG);

}

void tunneli_init()
{
	int i;
	int j;

	tunnelicount = 180;
	const int stripcount = 200;

	tunnelstrips = new LineStrip[tunnelicount];
	for (i=0;i<tunnelicount;i++)
	{
		const float ikohta = i / (float)tunnelicount;
		tunnelstrips[i].count = stripcount;
		tunnelstrips[i].vertices = new Vector[tunnelstrips[i].count];
		tunnelstrips[i].vertices2 = new Vector[tunnelstrips[i].count];

		for (j=0;j<tunnelstrips[i].count;j++)
		{
			const float kohta = j / (float)(tunnelstrips[i].count);
			const float radiusmodifier = 0.4f*(float)sin(ikohta*10);

			const float radius = 1.0f+ randFloat()*0.1f + radiusmodifier;
			const float radius2 = 1.1f+ randFloat()*0.1f + radiusmodifier;
			const float z = i*0.5f;
			const float kulma = kohta*2*3.141592f + randFloat()*0.1f;

			tunnelstrips[i].vertices[j] = (Vector((float)sin(kulma), (float)cos(kulma), 0))*radius;
			tunnelstrips[i].vertices2[j] = (Vector((float)sin(kulma), (float)cos(kulma), 0))*radius2;
			tunnelstrips[i].vertices[j].z = z;
			tunnelstrips[i].vertices2[j].z = z;

		}
	}
}

void tunneli_free()
{
} 
