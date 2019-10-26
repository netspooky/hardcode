#include <stdio.h>
#include <stdlib.h>
#include "perhonen.hpp"
#include "kellu.hpp"

int perhovertexcount = 2000;
Vector *perhovertices;
Vector *perhovertices2;
Object *perhosmaasto;

int syncobjects = 500;
int syncpositions = 1000;
int *syncdata;
unsigned char *suunnat;

const int perhosgridx = 50;
const int perhosgridy = 50;

/*
int perhotilpecount = 4000;
Palanen *perhotilpes;
*/

Sync *perhossync;
Sync *perhoskamerasync;


const int greetingscount = 30;
const int greetingslength = 27;
const char greetings[greetingscount][greetingslength] = {

"ümlaüt design",
"trailer park demos",
"synesthetics",
"stravaganza",
"static",
"pyrotech",
"plastic", 
"promille dezign", 
"outbreak",
"numedia cyclops",
"neuro.concept",
"mfx", 
"matt current",
"lobstarrs",
"lame apartment of graphics",
"jumalauta", 
"hedelmae",
"gluterol",
"fairlight",
"faktory", 
"division",
"digital devotion",
"demarche",
"conspiracy",
"asd",
"ananasmurska",
" ",
"butterfly",
"thoughts",
"out to",
};

/*
const char greetings[greetingscount][greetingslength] = {
"butterfly",
"thoughts",
"out to",
" ",
"Anna <3",
"ananasmurska",
"asd",
"conspiracy",
"demarche",
"faktory", 
"fairlight",
"gluterol",
"hedelmae",
"jumalauta", 
"lobstarrs",
"matt current",
"mfx", 
"neuro.concept",
"numedia cyclops",
"outbreak",
"promille design", 
"plastic", 
"pyrotech",
"static",
"synesthetics",
"ümlaut design",
};
*/
void perhonen(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	//kaikki paitsi perhoset
	const float fadeoutalpha = 1-calcPosFloat(aika, 0.8f, 0.9f);
	//perhoset
	const float fadeoutalpha2 = 1;// -calcPosFloat(aika, 0.97f, 0.99f);

	float synk = perhossync->getValue();
	static int camindex = 0;

	static int perhosindex = 0;
	if (perhossync->getActivated())
	{
		perhosindex++;
		for (i=0;i<syncpositions;i++)
		{
			syncdata[i] = rand()%(perhosgridx*perhosgridy);
			suunnat[i] = rand()%255;
		}
	}

	perhoskamerasync->getValue();
	if (perhoskamerasync->getActivated())
	{
		camindex++;
	}
	glLoadIdentity();

	const int camcount = 5;
	Vector campositions[camcount] = { Vector(-1, 0, -2),
									  Vector(1.5f, 1, -1),
									  Vector(1.7f, 3, -0.2f),
									  Vector(-2.3f, 4, -0.6f),
									  Vector(0.9f, 2.1f, -1.5f)
	};

	const float camkulma = aika*4.4f;
	Vector camrot = Vector((float)sin(camkulma), 0, (float)cos(camkulma))*2.0f;
	Vector camdelta = Vector(0, 0, 14)*aika;
	Vector campos = Vector(0, 7+aika, -7.0f) + camdelta + camrot + campositions[camindex%camcount];
	Vector camtarget = Vector(0, 0, 2) + camdelta;

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, aika*0.1f, 1, 0);

//	glRotatef(aika*1000, 1, 1, -1);

	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

/*	glPointSize(3);
	glBegin(GL_POINTS);
	int i;
	Vertex *vertices = perhosmaasto->getVertices();
	for (i=0;i<perhosmaasto->getVertexCount();i++)
	{
		Vector p = vertices[i].position + Vector(0, 0, 10);
		glVertex3fv((float *)&p);
	}
	glEnd();

*/
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(sininen.x, sininen.y, sininen.z, alpha*0.2f*fadeoutalpha);
	Vertex *vertices = perhosmaasto->getVertices();
	Face *faces = perhosmaasto->getFaces();

	glBegin(GL_LINES);
	for (i=0;i<perhosmaasto->getFaceCount();i+=2)
	{
		Vector maastomove = Vector(0, 0, 17);
		Vector v1 = vertices[faces[i].v1].position + maastomove;
		Vector v2 = vertices[faces[i].v2].position + maastomove;
		Vector v3 = vertices[faces[i].v3].position + maastomove;

		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
		glVertex3fv((float *)&v2);
		glVertex3fv((float *)&v3);

	}
	glEnd();

//	for (i=0;i<greetingscount;i++)
	{
		i = 0;
		const float ikohta = i / (float)greetingscount;
		const float greetscale = 20;

		float galpha = (float)pow(ikohta, 7)+aika;
		if (galpha > 1.0f)
			galpha = 1.0f;

		galpha *= fadeoutalpha;

		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glColor4f(sininen.x, sininen.y, sininen.z, alpha*galpha);
		glPushMatrix();
		glRotatef(180, 0, 0, -1);
//		glTranslatef(0, 0, greetscale-ikohta*greetscale);
//		glTranslatef(0, 0, ikohta);
//		glTranslatef(0, 0, 0);
		glRotatef(90, 1, 0, 0);
glScalef(0.03,0.03,0.03);
//		font_write3d(greetings[i]);
//printf("%s\n",greetings[i]);
		font_write3d("greetings");

		glPopMatrix();
glScalef(1,1,1);
	}

	if (synk > 0.0f)
	{
		const float length = (synk)*0.9f;
		Vertex *vertices = perhosmaasto->getVertices();

		glLineWidth(4.0f);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glBegin(GL_LINES);

		for (i=0;i<syncobjects;i++)
		{
			Vector pos = (vertices+syncdata[i])->position;
			Vector v1 = pos + Vector(length, 0, 0);
			Vector v2 = pos + Vector(0, 0, length);
			Vector v3 = pos + Vector(-length, 0, 0);
			Vector v4 = pos + Vector(0, 0, -length);

			Vector col;
			if (syncdata[i]%2)
				col = oranssi;
			else
				col = sininen;

			const float maxalpha = 0.7f*synk;

			unsigned char suunta = suunnat[i];

			if (suunta&2)
			{
				glColor4f(col.x, col.y, col.z, alpha*maxalpha);
				glVertex3fv((float *)&pos);
				glColor4f(col.x, col.y, col.z, 0);
				glVertex3fv((float *)&v1);
			}
			if (suunta&4)
			{
				glColor4f(col.x, col.y, col.z, alpha*maxalpha);
				glVertex3fv((float *)&pos);
				glColor4f(col.x, col.y, col.z, 0);
				glVertex3fv((float *)&v2);
			}
			if (suunta&8)
			{
				glColor4f(col.x, col.y, col.z, alpha*maxalpha);
				glVertex3fv((float *)&pos);
				glColor4f(col.x, col.y, col.z, 0);
				glVertex3fv((float *)&v3);
			}
			if (suunta&16)
			{
				glColor4f(col.x, col.y, col.z, alpha*maxalpha);
				glVertex3fv((float *)&pos);
				glColor4f(col.x, col.y, col.z, 0);
				glVertex3fv((float *)&v4);
			}
		}
		glEnd();

		glLineWidth(1.0f);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		glBegin(GL_LINES);

		for (i=0;i<syncobjects;i++)
		{
			Vector pos = (vertices+syncdata[i])->position;
			Vector v1 = pos + Vector(length, 0, 0);
			Vector v2 = pos + Vector(0, 0, length);
			Vector v3 = pos + Vector(-length, 0, 0);
			Vector v4 = pos + Vector(0, 0, -length);

			const float maxalpha = 1;

			unsigned char suunta = suunnat[i];

			if (suunta&2)
			{
				glColor4f(1,1,1, alpha*maxalpha);
				glVertex3fv((float *)&pos);
				glColor4f(1,1,1, 0);
				glVertex3fv((float *)&v1);
			}
			if (suunta&4)
			{
				glColor4f(1,1,1, alpha*maxalpha);
				glVertex3fv((float *)&pos);
				glColor4f(1,1,1, 0);
				glVertex3fv((float *)&v2);
			}
			if (suunta&8)
			{
				glColor4f(1,1,1, alpha*maxalpha);
				glVertex3fv((float *)&pos);
				glColor4f(1,1,1, 0);
				glVertex3fv((float *)&v3);
			}
			if (suunta&16)
			{
				glColor4f(1,1,1, alpha*maxalpha);
				glVertex3fv((float *)&pos);
				glColor4f(1,1,1, 0);
				glVertex3fv((float *)&v4);
			}
		}
		glEnd();

	}







	
	const int perhoscount = 9;

	const int perhospaikkacount = 15;

	float perhopositions[perhospaikkacount][3] = { 
		{0, 0, aika*18-3},
		{3+aika, 2, aika*13},
		{-3, 1.5f, 2+aika*15},
		{0.6f+aika*0.1f, 2.0f, 15+aika*15},
		{-4+aika*0.7f, 0.5f, 6+aika*23},
		{4.2f-aika*1.3f, 1.0f, 19+aika*10},
		{0.2f+aika*0.1f, 1.0f, 8+aika*11},
		{-6, 4, aika*12-3},
		{6, 4, aika*12-3},
		{4.2f-aika*1.3f, -2.1f, 7+aika*12},
		{3-aika, 5, aika*11},
		{-8+aika*0.7f, 1.3f, 3+aika*23},
		{-3, -1.5f, 3+aika*18},
		{4.2f-aika*1.3f, -2.1f, 7+aika*12},
		{6, -3, 4+aika*12-3},
	};

	float perhophases[perhoscount] = {
		0.3f,
		0.7f,
		3.6f,
		4.8f,
		1.6f,
		5.6f,
		2.8f,
		3.6f,
		4.6f,
	};

	float perhorotations[perhoscount][3] = {
		{7*(float)sin(aika*7), 3*(float)sin(aika*7), 0},
		{8*(float)sin(aika*14), 4*(float)sin(aika*7), 0},
		{5*(float)sin(aika*9), 5*(float)sin(aika*7), 0},
		{11*(float)sin(aika*5), 2*(float)sin(aika*7), 0},
		{8*(float)sin(aika*11), 3*(float)sin(aika*7), 0},
		{7*(float)sin(aika*6), 7*(float)sin(aika*7), 0},
		{11*(float)sin(aika*16), 7*(float)sin(aika*7), 0},
		{15*(float)sin(aika*6), 4*(float)sin(aika*7), 0},
		{17*(float)sin(aika*11), 16*(float)sin(aika*7), 0},

		//		{0, 0, 0},
//		{0, 0, 0},
//		{0, 0, 0},
//		{0, 0, 0},
//		{0, 0, 0}
	};

											
	const float scale = 0.4f;

	for (i=0;i<perhoscount;i++)
	{
		glPushMatrix();

		Vector perhopos = Vector(perhopositions[(i+perhosindex)%perhospaikkacount][0],
								 perhopositions[(i+perhosindex)%perhospaikkacount][1],
								 perhopositions[(i+perhosindex)%perhospaikkacount][2]);
//		glTranslatef(perhopositions[i][0], perhopositions[i][1], perhopositions[i][2]);
		glTranslatef(perhopos.x, perhopos.y, perhopos.z);
		glRotatef(90, 0, -1, 0);
		glRotatef(perhorotations[i][0], 1, 0, 0);
		glRotatef(perhorotations[i][1], 0, 1, 0);
		glRotatef(perhorotations[i][2], 0, 0, 1);
//		glRotatef(360, perhorotations[i][0], perhorotations[i][1], perhorotations[i][2]);
		glScalef(scale, scale, scale);

		const float perhosviive = i*0.1f;

		Vector col;
/*		if (i%2)
			col = oranssi;
		else
			col = sininen;
*/
		switch((i+camindex)%3)
		{
			case 0: col = punainen; break;
			case 1: col = oranssi; break;
			case 2: col = sininen; break;

		}
		butterfly(300,  calcPosFloat(aika, 0.1f+perhosviive, 0.35f+perhosviive), aika+perhophases[i], alpha*fadeoutalpha, col);
		glPopMatrix();
	}
}

void butterfly(float speed, float kohta, float aika, float alpha, Vector &color)
{
	int i;

	for (i=0;i<perhovertexcount;i++)
	{
		const float asento = 0.4f*(float)(0.5f+0.5f*sin(aika*speed));
		perhovertices[i].y = (float)fabs(perhovertices[i].z)*asento;
	}

	const int asti = (int)(perhovertexcount*kohta);

	alpha *= kohta;

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glLineWidth(4.0f);
	glColor4f(color.x, color.y, color.z, alpha*0.7f);
	glBegin(GL_LINE_STRIP);
	for (i=0;i<asti;i++)
	{
		glVertex3fv((float *)&perhovertices[i]);
	}
	glEnd();
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glLineWidth(1.0f);
	glColor4f(1,1,1, alpha*0.4f);
	glBegin(GL_LINE_STRIP);
	for (i=0;i<asti;i++)
	{
		glVertex3fv((float *)&perhovertices[i]);
	
	}
	glEnd();


}

void perhonen_init()
{
	int i;
	perhovertices = new Vector[perhovertexcount];
	perhovertices2 = new Vector[perhovertexcount];

	Vector point;
	float t;

	for (i=0;i<perhovertexcount;i++)
	{
		t = i*24*3.141592f / perhovertexcount;
		point.x = (float)(cos(t)*(exp(cos(t))-2*cos(4*t)-pow(sin(t/12),5.0f)));
		point.z = (float)(sin(t)*(exp(cos(t))-2*cos(4*t)-pow(sin(t/12),5.0f)));
		point.y = 0;//(float)fabs(point.z)/2;

		perhovertices[i] = point;
	}

	perhosmaasto = new Object();
	perhosmaasto->buildPlane(70, perhosgridx, perhosgridy, Vector(0, 0, 0));

//	perhotilpes = new Palanen[perhotilpecount];
/*
	int offs = 0;
	for (i=0;i<perhotilpecount;i++)
	{
		Matrix scale;
		scale.makeScale(44, 1, 30);


		const float z1 = 1.4f;
		const float z2 = -0.1f;

		Vector paikka = Vector(randFloat()-0.5f, 0, z1);
		Vector paikka2 = Vector(paikka.x, 0, z2);

		perhotilpes[i].pos = paikka*scale;
		perhotilpes[i].pos2 = paikka2*scale;

		switch(i%4)
		{
			case 0: perhotilpes[i].color = punainen; break;
			case 1: perhotilpes[i].color = sininen; break;
			case 2: perhotilpes[i].color = oranssi; break;
			case 3: perhotilpes[i].color = violetti; break;
		}

		perhotilpes[i].startrot = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*6;
		perhotilpes[i].endrot = perhotilpes[i].startrot + Vector(1+randFloat()-0.5f, 1+randFloat()-0.5f, 1+randFloat()-0.5f)*34;

		perhotilpes[i].speed = 0.7f + randFloat()*0.6f;
		perhotilpes[i].phase = randFloat();

		perhotilpes[i].speed = perhotilpes[i].speed;
		perhotilpes[i].phase = perhotilpes[i].phase;

		perhotilpes[i].length = 0.1f + randFloat()*0.1f;
	}
*/
//int syncobjects = 150;
//int syncpositions = 1000;
//int *syncdata;

	syncdata = new int[syncpositions];
	suunnat = new unsigned char[syncpositions];
	perhossync = new Sync(200);
	perhoskamerasync = new Sync(200);
	const int synctime = 400;
//32                     00 08 14 24 30 3C
//33                     00 06 0C 16 1C 20 2C
/*	for (int j=0;j<5;j++)
	{
		for (i=0;i<0x40;i+=0xC)
		{
			perhossync->add(j, i, synctime);
		}
	}
*/
	perhossync->add(0x32, 0x00, synctime);
	perhossync->add(0x32, 0x08, synctime);
	perhossync->add(0x32, 0x14, synctime);
	perhossync->add(0x32, 0x24, synctime);
	perhossync->add(0x32, 0x30, synctime);
	perhossync->add(0x32, 0x3C, synctime);

	perhossync->add(0x33, 0x00, synctime);
	perhossync->add(0x33, 0x06, synctime);
	perhossync->add(0x33, 0x0C, synctime);
	perhossync->add(0x33, 0x16, synctime);
	perhossync->add(0x33, 0x1C, synctime);
	perhossync->add(0x33, 0x20, synctime);
	perhossync->add(0x33, 0x2C, synctime);

	perhossync->add(0x34, 0x00, synctime);
	perhossync->add(0x34, 0x02, synctime);
	perhossync->add(0x34, 0x04, synctime);
	perhossync->add(0x34, 0x06, synctime);
	perhossync->add(0x34, 0x08, synctime);
	perhossync->add(0x34, 0x0A, synctime);
	perhossync->add(0x34, 0x0C, synctime);
	perhossync->add(0x34, 0x0E, synctime);
	perhossync->add(0x34, 0x10, synctime);
	perhossync->add(0x34, 0x12, synctime);
	perhossync->add(0x34, 0x14, synctime);
	perhossync->add(0x34, 0x16, synctime);
	perhossync->add(0x34, 0x18, synctime);
	perhossync->add(0x34, 0x1A, synctime);
	perhossync->add(0x34, 0x1C, synctime);
	perhossync->add(0x34, 0x1E, synctime);
	perhossync->add(0x34, 0x20, synctime);
	for (i=0x21;i<0x2F;i++)
		perhossync->add(0x34, i, synctime);

//1C                     00 0C 14 2C 30 34
//1D                     00 1A 30 34
//1E                      00 0C 14 2C 30 34
//1F                      00 0C 14 2C 30 34
	perhossync->add(0x35, 0x00, synctime);
	perhossync->add(0x35, 0x0C, synctime);
	perhossync->add(0x35, 0x14, synctime);
	perhossync->add(0x35, 0x2C, synctime);
	perhossync->add(0x35, 0x30, synctime);
	perhossync->add(0x35, 0x34, synctime);

	perhossync->add(0x36, 0x00, synctime);
	perhossync->add(0x36, 0x1A, synctime);
	perhossync->add(0x36, 0x30, synctime);
	perhossync->add(0x36, 0x34, synctime);

	perhossync->add(0x37, 0x00, synctime);
	perhossync->add(0x37, 0x0C, synctime);
	perhossync->add(0x37, 0x14, synctime);
	perhossync->add(0x37, 0x2C, synctime);
	perhossync->add(0x37, 0x30, synctime);
	perhossync->add(0x37, 0x34, synctime);
/*
	perhossync->add(0x38, 0x00, synctime);
	perhossync->add(0x38, 0x0C, synctime);
	perhossync->add(0x38, 0x14, synctime);
	perhossync->add(0x38, 0x2C, synctime);
	perhossync->add(0x38, 0x30, synctime);
	perhossync->add(0x38, 0x34, synctime);
*/
/*
	perhossync->add(0x39, 0x00, synctime);
	perhossync->add(0x39, 0x0C, synctime);
	perhossync->add(0x39, 0x14, synctime);
	perhossync->add(0x39, 0x2C, synctime);
	perhossync->add(0x39, 0x30, synctime);
	perhossync->add(0x39, 0x34, synctime);
*/
//#endif

	perhoskamerasync->add(0x32, 0x00, synctime);
	perhoskamerasync->add(0x32, 0x08, synctime);
	perhoskamerasync->add(0x32, 0x14, synctime);
	perhoskamerasync->add(0x32, 0x24, synctime);
	perhoskamerasync->add(0x32, 0x30, synctime);
	perhoskamerasync->add(0x32, 0x3C, synctime);

	perhoskamerasync->add(0x33, 0x00, synctime);
	perhoskamerasync->add(0x33, 0x06, synctime);
	perhoskamerasync->add(0x33, 0x0C, synctime);
	perhoskamerasync->add(0x33, 0x16, synctime);
	perhoskamerasync->add(0x33, 0x1C, synctime);
	perhoskamerasync->add(0x33, 0x20, synctime);
	perhoskamerasync->add(0x33, 0x2C, synctime);

//1C                     00 0C 14 2C 30 34
//1D                     00 1A 30 34
//1E                      00 0C 14 2C 30 34
//1F                      00 0C 14 2C 30 34
	perhoskamerasync->add(0x35, 0x00, synctime);
	perhoskamerasync->add(0x35, 0x0C, synctime);
	perhoskamerasync->add(0x35, 0x14, synctime);
	perhoskamerasync->add(0x35, 0x2C, synctime);
	perhoskamerasync->add(0x35, 0x30, synctime);
	perhoskamerasync->add(0x35, 0x34, synctime);

	perhoskamerasync->add(0x36, 0x00, synctime);
	perhoskamerasync->add(0x36, 0x1A, synctime);
	perhoskamerasync->add(0x36, 0x30, synctime);
	perhoskamerasync->add(0x36, 0x34, synctime);

	perhoskamerasync->add(0x37, 0x00, synctime);
	perhoskamerasync->add(0x37, 0x0C, synctime);
	perhoskamerasync->add(0x37, 0x14, synctime);
	perhoskamerasync->add(0x37, 0x2C, synctime);
	perhoskamerasync->add(0x37, 0x30, synctime);
	perhoskamerasync->add(0x37, 0x34, synctime);

	perhoskamerasync->add(0x38, 0x00, synctime);
	perhoskamerasync->add(0x38, 0x0C, synctime);
	perhoskamerasync->add(0x38, 0x14, synctime);
	perhoskamerasync->add(0x38, 0x2C, synctime);
	perhoskamerasync->add(0x38, 0x30, synctime);
	perhoskamerasync->add(0x38, 0x34, synctime);

	perhoskamerasync->add(0x39, 0x00, synctime);
	perhoskamerasync->add(0x39, 0x0C, synctime);
	perhoskamerasync->add(0x39, 0x14, synctime);
	perhoskamerasync->add(0x39, 0x2C, synctime);
	perhoskamerasync->add(0x39, 0x30, synctime);
	perhoskamerasync->add(0x39, 0x34, synctime);


}

void perhonen_free()
{
	delete [] perhovertices;
	delete [] perhovertices2;

	delete [] syncdata;
	delete [] suunnat;

//	delete [] perhotilpes;
	delete perhosmaasto;
	delete perhossync;
	delete perhoskamerasync;

}
