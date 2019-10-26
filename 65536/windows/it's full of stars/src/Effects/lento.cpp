#include "lento.hpp"

int lentox;
int lentoy;
Vector *planeetta;

int kuucount;
Kiertolainen *kuut;

void lento(float aika)
{
	int i;
	int x, y;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();
	Vector kohta = Vector(-aika*0.3f, 10+aika*2, 0) + Vector(0, 1 ,7)*(float)pow(aika, 17)*2;
	Vector campos = kohta + Vector(0, 0, -7.0f);
	Vector camtarget = kohta + Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	glDepthMask(1);


	float fogcol[] = {0, 0, 0,1};
	glFogi(GL_FOG_MODE, GL_LINEAR); //EXP, EXP2, LINEAR
	glFogfv(GL_FOG_COLOR, fogcol);
	glFogf(GL_FOG_DENSITY, 0.4f+0.4f*(float)cos(aika*10));
	glHint(GL_FOG_HINT, GL_DONT_CARE);
	glFogf(GL_FOG_START, 7);
	glFogf(GL_FOG_END, 10);
	glEnable(GL_FOG);

	const float ambientvalo[] = {0.1f,0.1f,0.1f,1};
	const float specularvalo[] = {1,1,1, 1};
	const float diffusevalo[] = {1,1,1, 0.2f};
	const float valoposition[] = {0, 0, 0, 1.0f };

	glLightfv(GL_LIGHT1, GL_AMBIENT, ambientvalo);
  	glLightfv(GL_LIGHT1, GL_DIFFUSE, diffusevalo);
	glLightfv(GL_LIGHT1, GL_SPECULAR, specularvalo);

	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

	float planetalpha = alpha*0.5f;
	if (planetalpha > 0.3f)
		planetalpha = 0.3f;
	glColor4f(0.9f, 0.45f, 0.3f, planetalpha);
	glLineWidth(3.0f);
	glPushMatrix();
	glBegin(GL_TRIANGLES);
	for (y=10;y<lentoy-10;y++)
	{
		for (x=10;x<lentox-10;x++)
		{
			Vector v1 = planeetta[x+y*lentox];
			Vector v2 = planeetta[((x+1)%lentox)+y*lentox];
			Vector v3 = planeetta[x+((y+1)%lentoy)*lentox];
			glVertex3fv((float *)&v1);
			glVertex3fv((float *)&v2);
			glVertex3fv((float *)&v3);
		}
	}
	glEnd();
	glPopMatrix();

	glLineWidth(2.0f);
	glDepthMask(1);
	for (i=0;i<kuucount;i++)
	{
		float t = aika;
		float k1 = kuut[i].startkulma1*(1-t) + kuut[i].endkulma1*t;
		float k2 = kuut[i].startkulma2*(1-t) + kuut[i].endkulma2*t;

		Vector p = sphereCoord(kuut[i].radius, k1, k2);
		Vector c = kuut[i].color;
		Vector r = kuut[i].startrot*(1-t) + kuut[i].endrot;
		float s = kuut[i].size;
		float s2 = kuut[i].size*1.04f;

		if ((p-campos).length() > 15)
			continue;

		glPushMatrix();
		glTranslatef(p.x, p.y, p.z);
		glRotatef(360*r.x, 1, 0, 0);
		glRotatef(360*r.y, 0, 1, 0);
		glRotatef(360*r.z, 0, 0, 1);
		glScalef(s, s, s);
		glColor4f(c.x, c.y, c.z, 0.2f*alpha);

		glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT1);
		glDisable(GL_CULL_FACE);
		glEnable(GL_NORMALIZE);

		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
		glShadeModel(GL_FLAT);

		const float ambientmat[] = {0, 0, 0, 0};
		const float diffusemat[] = {c.x, c.y, c.z, 0.25f*alpha};
		const float specularmat[] = {c.x, c.y, c.z, 1.55f*alpha};
		const float emissionmat[] = {0, 0, 0, 1};
		float shininessmat = 1.0f;

		glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, ambientmat);
		glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, diffusemat);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, specularmat);
		glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, specularmat);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, &shininessmat);
		
		switch(kuut[i].type)
		{
			case 0: icosahedron(); break;
			case 1: dodecahedron(); break;
		}
		glPopMatrix();

		glDisable(GL_LIGHTING);
		glDisable(GL_LIGHT1);
		glDisable(GL_NORMALIZE);
		
		glPushMatrix();
		glTranslatef(p.x, p.y, p.z);
		glRotatef(360*r.x, 1, 0, 0);
		glRotatef(360*r.y, 0, 1, 0);
		glRotatef(360*r.z, 0, 0, 1);
		glColor4f(c.x, c.y, c.z, 0.7f*alpha);

		glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
		glPushMatrix();
		glScalef(s2, s2, s2);
		switch(kuut[i].type)
		{
			case 0: icosahedron(); break;
			case 1: dodecahedron(); break;
		}
		glPopMatrix();
		glScalef(s2*1.4f, s2*1.4f, s2*1.4f);
		glColor4f(c.x, c.y, c.z, 0.4f*alpha);
		switch(kuut[i].type)
		{
			case 0: icosahedron(); break;
			case 1: dodecahedron(); break;
		}
		glPopMatrix();
	}
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glDisable(GL_FOG);
}

void lento_init()
{
	int i;
	int x, y;
	lentox = 30;
	lentoy = 30;

	planeetta = new Vector[lentox*lentoy];

	int offs = 0;
	for (y=0;y<lentoy;y++)
	{
		const float ykohta = y / (float)lentoy;
		for (x=0;x<lentox;x++)
		{
			const float xkohta = x / (float)lentox;
			const float radius = 10;
			Vector p = sphereCoord(radius, xkohta*3.141592f, ykohta*3.141592f);
			planeetta[offs++] = p;
		}
	}
	
	kuucount = 200;
	kuut = new Kiertolainen[kuucount];

	setSeed(2);;
	for (i=0;i<kuucount;i++)
	{
		kuut[i].startkulma1 = randFloat()*2*3.141592f;
		kuut[i].endkulma1 = kuut[i].startkulma1 + randFloat()*0.3f;
		kuut[i].startkulma2 = randFloat()*2*3.141592f;
		kuut[i].endkulma2 = kuut[i].startkulma2 + randFloat()*0.3f;

		kuut[i].type = rand()%2;
		kuut[i].startrot = Vector(randFloat(), randFloat(), randFloat())*0.2f*3.141592f;
		kuut[i].endrot = Vector(randFloat(), randFloat(), randFloat())*0.2f*3.141592f;
		kuut[i].size = 0.2f + 0.2f*randFloat();
		kuut[i].color = Vector(0.6f+randFloat()*0.2f, 0.3f+randFloat()*0.1f, 0.1f+randFloat()*0.2f);
		kuut[i].radius = 11 + randFloat()*3;

	}
}

void lento_free()
{
} 
