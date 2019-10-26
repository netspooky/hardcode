#include "virta.hpp"
#include "molekyyli.hpp"

const int virtagridx = 70;
const int virtagridy = 70;

Vector *virtagrid;
Vector *virtalines;
float *virtaheights;
float *virtaangles;
float *virtaalphas;

Path *virtapath;
Path *virtapath2;
Path *virtapath3;

const int virtalinecount = 1500;
VirtaLine *lines;

Sync *virtasync;

int vneuroncount = 55;
Neuron *vneurons;

void virta(float aika)
{
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	int i;
	int x, y;
	const float alpha = calcSaturate(aika, 0, 1, 6);
	const float virtaalpha = calcPosFloat(aika, 0.115f, 0.215f);
	const float serotoninlightup = calcPosFloat(aika, 0.615f, 0.64f);

	static int vaihto = 0xFFFFFFF;//0;

	float synk = virtasync->getValue();
	if (virtasync->getActivated())
	{
//		vaihto++;
	}

	glLoadIdentity();

	Vector moveback = Vector(0, -30, 40)*(float)pow(aika, 50);
	Vector campos = Vector(-aika*0.2f, 0, -7.0f) - moveback;
	Vector camtarget = Vector(1.5f, 0, 0)-moveback;

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, -0.3f, 1, 0);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glLineWidth(4);
	glDisable(GL_DEPTH_TEST);

	float *alphabuf = new float[60000];
	int offs = 0;

	const float neuronalpha = calcSaturate(aika, 0.05f, 0.95f, 15);

	for (i=0;i<vneuroncount;i++)
	{
		for (int j=0;j<vneurons[i].naapuricount;j++)
		{
			glBegin(GL_LINE_STRIP);
			for (int k=0;k<vneurons[i].pathvertices[j];k++)
			{
				const float kohta = k / (float)vneurons[i].pathvertices[j];
				alphabuf[offs] = alpha*(1-calcSaturate(kohta, 0.0f, 1.0f, 1)); 
				
				glColor4f(0, 0, 0,0.2f*alphabuf[offs]*neuronalpha);
				Vector p = vneurons[i].vertices[j][k];
				glVertex3fv((float *)&p);

				offs++;
			}
			glEnd();
		}
	}
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	
	glLineWidth(1);
	offs = 0;
	for (i=0;i<vneuroncount;i++)
	{
		for (int j=0;j<vneurons[i].naapuricount;j++)
		{
			glBegin(GL_LINE_STRIP);
			for (int k=0;k<vneurons[i].pathvertices[j];k++)
			{
				const float kohta = k / (float)vneurons[i].pathvertices[j];

				float valoadd = (float)(0.5f+0.5f*sin(kohta*26+aika*147));
				glColor4f(1,1,1,alphabuf[offs++]*0.7f*synk*valoadd*neuronalpha);
				Vector p = vneurons[i].vertices[j][k];
				glVertex3fv((float *)&p);
			}
			glEnd();
		}
	}
	delete [] alphabuf;

	
	glRotatef(aika*10, 0, 0, 1);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	const float width = 1.2f;
	const float height = 1.2f;

	Vector pos = Vector(0.13f, -0.2f, -6);

	virtaplasma(virtaheights, aika);
	virtaplasma2(virtaangles, aika);

	int offset = 0;
	for (y=0;y<virtagridy;y++)
	{
		for (x=0;x<virtagridx;x++)
		{
			Matrix scale;
			scale.makeScale(width, 1, height);

			float kulma = virtaangles[x+y*virtagridx]*2*3.141592f;
			const float virtapower = 0.03f;
			const float virtaheight = 0.05f;
			Vector p = pos + Vector((x-virtagridx*0.5f)/virtagridx, 0, (y-virtagridy*0.5f)/virtagridy)*scale;
			Vector p2 = p + Vector(virtapower*(float)sin(kulma), 
								   virtaheights[x+y*virtagridx]*virtaheight, 
								   virtapower*(float)cos(kulma));
			virtalines[offset++] = p;
			virtalines[offset++] = p2;
		}
	}

	const float lightup = calcPosFloat(aika, 0.2f, 0.22f);
	
	glDisable(GL_DEPTH_TEST);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glLineWidth(4);
	offset = 0;

	glBegin(GL_LINES);
	for (y=0;y<virtagridy;y++)
	{
		for (x=0;x<virtagridx;x++)
		{
			glColor4f(0, 0, 0, alpha*0.5f*(0.5f+0.5f*lightup)*virtaheights[x+y*virtagridx]);
			glVertex3fv((float *)&virtalines[offset++]);
			glVertex3fv((float *)&virtalines[offset++]);
		}
	}
	glEnd();
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glLineWidth(1);

	glColor4f(1,1,1,alpha*0.25f*serotoninlightup);
	offset = 0;

	glBegin(GL_LINES);
	for (y=0;y<virtagridy;y++)
	{
		for (x=0;x<virtagridx;x++)
		{
			glVertex3fv((float *)&virtalines[offset++]);
			glVertex3fv((float *)&virtalines[offset++]);
		}
	}
	glEnd();

	for (i=0;i<virtalinecount;i++)
	{
		const float linespeed = 4;
		const float maxradius = 0.4f;
		lines[i].pos = lines[i].linephase + aika*linespeed;
		lines[i].pos -= (int)lines[i].pos;

		lines[i].alpha = calcSaturate(lines[i].pos, 0, 1, 3)*virtaalpha;

		float k1 = lines[i].frequency*aika + lines[i].phase;
		float k2 = lines[i].frequency2*aika + lines[i].phase2;
		float radius = maxradius*(float)sin(lines[i].radiusphase + aika*lines[i].radiusfrequency);

		lines[i].displace = sphereCoord(radius, k1, k2);
		Vector rot = lerpVector(lines[i].startrot, lines[i].endrot, lines[i].pos);
		Matrix rotate;
		rotate.makeRotation(rot.x, rot.y, rot.z);
		lines[i].v1 = Vector(0, lines[i].length*0.5f, 0)*rotate;
		lines[i].v2 = Vector(0, -lines[i].length*0.5f, 0)*rotate;

		//setuppi tehty, voidaan piirtää

	}
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glLineWidth(4);

	Vector displace = Vector((float)sin(aika*17+3), (float)cos(aika*11+2), (float)cos(aika*15+1))*0.25f;
	Vector displace2 = Vector((float)sin(aika*15+0.4f), (float)sin(aika*19+2), (float)cos(aika*16+3))*0.25f;
	Vector displace3 = Vector((float)sin(aika*11+2), (float)cos(aika*7+5), (float)sin(aika*15+1))*0.25f;

	glBegin(GL_LINES);
	for (i=0;i<virtalinecount;i++)
	{
		const float isoalpha = 0.9f;
		Vector position = lines[i].displace + virtapath->getValue(lines[i].pos);
		Vector position2 = lines[i].displace + virtapath2->getValue(lines[i].pos);
		Vector position3 = lines[i].displace + virtapath3->getValue(lines[i].pos);

		position += displace;
		position2 += displace2;
		position3 += displace3;

		if (vaihto&1)
		{
			glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*isoalpha*lines[i].alpha);
			glVertex3fv((float *)&(position + lines[i].v1));
			glVertex3fv((float *)&(position + lines[i].v2));
		}
//		if ((vaihto>>1)&1)
		if ((vaihto/2)&1)
		{
			glColor4f(violetti.x, violetti.y, violetti.z, alpha*isoalpha*lines[i].alpha);
			glVertex3fv((float *)&(position2 + lines[i].v1));
			glVertex3fv((float *)&(position2 + lines[i].v2));
		}
//		if ((vaihto>>2)&1)
		if ((vaihto/4)&1)
		{
			glColor4f(sininen.x, sininen.y, sininen.z, alpha*isoalpha*lines[i].alpha);
			glVertex3fv((float *)&(position3 + lines[i].v1));
			glVertex3fv((float *)&(position3 + lines[i].v2));
		}
	}
	glEnd();
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glLineWidth(1);
	glBegin(GL_LINES);

	for (i=0;i<virtalinecount;i++)
	{
		Vector position = lines[i].displace + virtapath->getValue(lines[i].pos);
		Vector position2 = lines[i].displace + virtapath2->getValue(lines[i].pos);
		Vector position3 = lines[i].displace + virtapath3->getValue(lines[i].pos);

		position += displace;
		position2 += displace2;
		position3 += displace3;

		if ((i%32)==0)
		{
			glEnd();
			const float scale = 0.04f;

			if (serotoninlightup > 0.0f)
			{
				glPushMatrix();
				glTranslatef(position.x, position.y, position.z);
				glScalef(scale, scale, scale);
				serotonin(alpha*serotoninlightup*lines[i].alpha, 1);
				glPopMatrix();

				glPushMatrix();
				glTranslatef(position2.x, position2.y, position2.z);
				glScalef(scale, scale, scale);
				serotonin(alpha*serotoninlightup*lines[i].alpha, 1);
				glPopMatrix();

				glPushMatrix();
				glTranslatef(position3.x, position3.y, position3.z);
				glScalef(scale, scale, scale);
				serotonin(alpha*serotoninlightup*lines[i].alpha, 1);
				glPopMatrix();
			}
			glBlendFunc(GL_SRC_ALPHA, GL_ONE);
			glDisable(GL_DEPTH_TEST);
			glBegin(GL_LINES);
		}

		glColor4f(1,1,1,lines[i].alpha*alpha*0.6f);
		if (vaihto&1)
		{
			glVertex3fv((float *)&(position + lines[i].v1));
			glVertex3fv((float *)&(position + lines[i].v2));
		}
//		if ((vaihto>>1)&1)
		if ((vaihto/2)&1)
		{
			glVertex3fv((float *)&(position2 + lines[i].v1));
			glVertex3fv((float *)&(position2 + lines[i].v2));
		}
//		if ((vaihto>>2)&1)
		if ((vaihto/4)&1)
		{
			glVertex3fv((float *)&(position3 + lines[i].v1));
			glVertex3fv((float *)&(position3 + lines[i].v2));
		}
	}


	glEnd();



}

void virtaplasma(float *dest, float aika)
{
	int x, y;

	for (y=0;y<virtagridx;y++)
	{
		const float speed = 1;
		float yval = 0.5f + 0.25f*(float)(sin(y*0.2f + aika*17*speed)+cos(y*0.4f+aika*11*speed));
		for (x=0;x<virtagridx;x++)
		{
			float xval = 0.5f + 0.25f*(float)(sin(x*0.23f + aika*19*speed)+cos(x*0.5f+aika*8.5f*speed));
			dest[x+y*virtagridx] = (xval+yval)*0.5f;
		}
	}
}

void virtaplasma2(float *dest, float aika)
{
	int x, y;

	for (y=0;y<virtagridx;y++)
	{
		const float speed = 1;
		float yval = 0.5f + 0.25f*(float)(sin(y*0.3f + aika*11*speed)+cos(y*0.2f+aika*19*speed));
		for (x=0;x<virtagridx;x++)
		{
			float xval = 0.5f + 0.25f*(float)(sin(x*0.27f + aika*14*speed)+cos(x*0.7f+aika*11.5f*speed));
			dest[x+y*virtagridx] = (xval+yval)*0.5f;
		}
	}
}

void virta_init()
{
	int i;
	int x, y;

	virtagrid = new Vector[virtagridx*virtagridy];
	virtalines = new Vector[2*virtagridx*virtagridy];
	virtaheights = new float[virtagridx*virtagridy];
	virtaangles= new float[virtagridx*virtagridy];
	virtaalphas= new float[virtagridx*virtagridy];

	virtapath = new Path();
	virtapath2 = new Path();
	virtapath3 = new Path();

	for (y=0;y<virtagridx;y++)
	{
		for (x=0;x<virtagridx;x++)
		{


		}
	}
	virtapath->addpoint(Vector(8, 0, 4));
	virtapath->addpoint(Vector(3, 1, 0));
	virtapath->addpoint(Vector(0, -1, -2));
	virtapath->addpoint(Vector(-4, -1, -7));

	virtapath2->addpoint(Vector(8, 0.3f, 5));
	virtapath2->addpoint(Vector(6, 0.6f, 7));
	virtapath2->addpoint(Vector(4, 1.1f, 1));
	virtapath2->addpoint(Vector(2, 0.5f, 0.1f));
	virtapath2->addpoint(Vector(-1, 0.1f, -2));
	virtapath2->addpoint(Vector(-1, 2.83f, 0.3f));

/*	virtapath3->addpoint(Vector(5, 1, 7));
	virtapath3->addpoint(Vector(3, 0.2f, 4));
	virtapath3->addpoint(Vector(2, -0.6f, 1));
	virtapath3->addpoint(Vector(2.5f, -1.0f, -2));
	virtapath3->addpoint(Vector(2.0f, 0.8f, -8));
*/
	virtapath3->addpoint(Vector(5, 0.4f, 7));
	virtapath3->addpoint(Vector(7, 0.2f, 4));
	virtapath3->addpoint(Vector(5 , - 0.2f, 1));
	virtapath3->addpoint(Vector(0 , -0.6f, -7));
//	virtapath3->addpoint(Vector(2.0f, 0.4f, -8));

	setSeed(1091059);

	lines = new VirtaLine[virtalinecount];

	for (i=0;i<virtalinecount;i++)
	{
/*
		struct VirtaLine
{
public:
	Vector startrot;
	Vector endrot;
	float length;

	float phase, phase2;
	float frequency, frequency2;

	Vector v1;
	Vector v2;

	float linephase;
	float alpha;
	float pos;
};
*/
		lines[i].startrot = Vector(randFloat(), randFloat(), randFloat())*2*3.141592f;
		lines[i].endrot = Vector(randFloat(), randFloat(), randFloat())*2*3.141592f * 6;
		lines[i].length = 0.1f + 0.1f*randFloat();
		lines[i].phase = randFloat()*2*3.141592f;
		lines[i].phase2 = randFloat()*2*3.141592f;
		lines[i].frequency = 5 + 2*3.141592f*randFloat()*4;
		lines[i].frequency2 = 5 + 2*3.141592f*randFloat()*4;
		lines[i].radiusphase = randFloat()*2*3.141592f;
		lines[i].radiusfrequency = 5 + 2*3.141592f*randFloat()*4;

		lines[i].linephase = randFloat();
	}

	virtasync = new Sync(400);
	const int synctime = 700;
/*
35 - 00 0C 14 2C 30 34
36 - 00 1A 30 34
37 - 00 0C 14 2C 30 34
38 - 00 0C 14 2C 30 34
39 - 00 0C 14 2C 30 34
3a - 00 1A 30 34
3b - 00 0C 14 2C 30 34
3c - 00 0C 14 2C 30 34 38 3C
3d - 00 0C 14 2C 30 34
3e - 00 1A 30 34
3f - 00 0C 14 2C 30 34
*/
	/*
#ifndef COMPLETEINTRO
	for (int j=0;j<5;j++)
	{
		for (i=0;i<0x40;i+=0xC)
		{
			virtasync->add(j, i, synctime);
		}
	}
#else
*/
/*	virtasync->add(0x35, 0x00, synctime);
	virtasync->add(0x35, 0x0C, synctime);
	virtasync->add(0x35, 0x14, synctime);
	virtasync->add(0x35, 0x2C, synctime);
	virtasync->add(0x35, 0x30, synctime);
	virtasync->add(0x35, 0x34, synctime);
*/
	virtasync->add(0x36, 0x00, synctime);
	virtasync->add(0x36, 0x1A, synctime);
	virtasync->add(0x36, 0x30, synctime);
	virtasync->add(0x36, 0x34, synctime);

	virtasync->add(0x37, 0x00, synctime);
	virtasync->add(0x37, 0x0C, synctime);
	virtasync->add(0x37, 0x14, synctime);
	virtasync->add(0x37, 0x2C, synctime);
	virtasync->add(0x37, 0x30, synctime);
	virtasync->add(0x37, 0x34, synctime);

	virtasync->add(0x38, 0x00, synctime);
	virtasync->add(0x38, 0x0C, synctime);
	virtasync->add(0x38, 0x14, synctime);
	virtasync->add(0x38, 0x2C, synctime);
	virtasync->add(0x38, 0x30, synctime);
	virtasync->add(0x38, 0x34, synctime);

	virtasync->add(0x39, 0x00, synctime);
	virtasync->add(0x39, 0x0C, synctime);
	virtasync->add(0x39, 0x14, synctime);
	virtasync->add(0x39, 0x2C, synctime);
	virtasync->add(0x39, 0x30, synctime);
	virtasync->add(0x39, 0x34, synctime);

	virtasync->add(0x3a, 0x00, synctime);
	virtasync->add(0x3a, 0x1A, synctime);
	virtasync->add(0x3a, 0x30, synctime);
	virtasync->add(0x3a, 0x34, synctime);

	virtasync->add(0x3b, 0x00, synctime);
	virtasync->add(0x3b, 0x0C, synctime);
	virtasync->add(0x3b, 0x14, synctime);
	virtasync->add(0x3b, 0x2C, synctime);
	virtasync->add(0x3b, 0x30, synctime);
	virtasync->add(0x3b, 0x34, synctime);

	virtasync->add(0x3c, 0x00, synctime);
	virtasync->add(0x3c, 0x0C, synctime);
	virtasync->add(0x3c, 0x14, synctime);
	virtasync->add(0x3c, 0x2C, synctime);
	virtasync->add(0x3c, 0x30, synctime);
	virtasync->add(0x3c, 0x34, synctime);
	virtasync->add(0x3c, 0x38, synctime);
	virtasync->add(0x3c, 0x3c, synctime);

	virtasync->add(0x3d, 0x00, synctime);
	virtasync->add(0x3d, 0x0C, synctime);
	virtasync->add(0x3d, 0x14, synctime);
	virtasync->add(0x3d, 0x2C, synctime);
	virtasync->add(0x3d, 0x30, synctime);
	virtasync->add(0x3d, 0x34, synctime);

	virtasync->add(0x3e, 0x00, synctime);
	virtasync->add(0x3e, 0x1A, synctime);
	virtasync->add(0x3e, 0x30, synctime);
	virtasync->add(0x3e, 0x34, synctime);

	virtasync->add(0x3f, 0x00, synctime);
	virtasync->add(0x3f, 0x0C, synctime);
	virtasync->add(0x3f, 0x14, synctime);
	virtasync->add(0x3f, 0x2C, synctime);
	virtasync->add(0x3f, 0x30, synctime);
	virtasync->add(0x3f, 0x34, synctime);

//#endif
	vneurons = new Neuron[vneuroncount];
	for (i=0;i<vneuroncount;i++)
	{
		Matrix scale;
		scale.makeScale(16,9,7);
		const Vector globalpos = Vector(8, 2, 8);
		vneurons[i].pos = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*scale + globalpos;
	}
	for (i=0;i<vneuroncount;i++)
	{
		vneurons[i].naapuricount = RAND_INT(2,5);
		vneurons[i].pathvertices = new int [vneurons[i].naapuricount];
		vneurons[i].vertices = new Vector *[vneurons[i].naapuricount];

		for (int j=0;j<vneurons[i].naapuricount;j++)
		{
			int naapuri = 0;
			do
			{
				naapuri = RAND_INT(0, vneuroncount-1);
			} while (naapuri==i);

			const int count = 20;
			vneurons[i].pathvertices[j] = count;
			vneurons[i].vertices[j] = new Vector[count];

			float step = 1.0f / (count-1);
			for (int k=0;k<count;k++)
			{
				float kohta = k * step;

				Vector pos = vneurons[naapuri].pos*(1-kohta) + vneurons[i].pos*kohta;
				pos += randomSphereVector(0.1f);
				vneurons[i].vertices[j][k] = pos;
			}
		}
	}
}

void virta_free()
{
	delete [] virtaheights;
	delete [] virtalines;
	delete [] virtaangles;
	delete [] virtaalphas;
	delete [] virtagrid;

	delete [] lines;

	delete virtapath;
	delete virtapath2;
	delete virtapath3;

	delete virtasync;

	int i;
	for (i=0;i<vneuroncount;i++)
	{
		delete [] vneurons[i].pathvertices;
		delete [] vneurons[i].vertices;
	}
	delete [] vneurons;
}
