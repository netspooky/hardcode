#include <stdio.h>
#include <stdlib.h>
#include "kasvu.hpp"

const int kasvucount = 20;
KasvuItem *kasvut;
Sync *kasvusync;

void KasvuItem::draw(float alpha, float aika)
{
	int i;

	const float kohta = calcPosFloat(aika, starttime, endtime);
	const float epsilon = 0.0001f;

	if (kohta <= epsilon)
		return;
	if (kohta >= 1.0f-epsilon)
		return;
	const int asti = (int)(count*kohta);

	const float alphamod = (float)sin(kohta*3.141592f);

	glPushMatrix();
	glTranslatef(position.x, position.y, position.z);
//	glColor4f(sininen.x, sininen.y, sininen.z, alpha*0.25f*alphamod);
	glColor4f(color1.x, color1.y, color1.z, alpha*0.25f*alphamod);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBegin(GL_TRIANGLE_FAN);
	for (i=0;i<asti;i++)
	{
		glVertex3fv((float *)&vertices[i]);
	}
	glEnd();
//	glColor4f(sininen.x, sininen.y, sininen.z, alpha*0.8f*alphamod);
	glColor4f(color2.x, color2.y, color2.z, alpha*0.50f*alphamod);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glBegin(GL_LINE_STRIP);
	for (i=0;i<asti;i++)
	{
		glVertex3fv((float *)&vertices[i]);
	}
	glEnd();
	glPopMatrix();

}
void kasvu(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 16);
	glLoadIdentity();

	const float cammove = 1-(float)sin(calcPosFloat(aika, 0, 0.1f)*0.5f*3.141592f);
	glTranslatef(-1.0f + aika*2, 0, -7.0f-cammove*3);

	Vector p1 = Vector(0, -1, 1.5f);

	glPushMatrix();
	glRotatef(aika*10, 0, 1, 0);

	const int lc = 25;
	const float height = 1.0f;
	Vector start = Vector(-7, height, 1.5f);
	Vector end = Vector(7, height, 1.5f);

	const float synk = kasvusync->getValue();
	const float vilkku = synk*0.5f;//(35*aika - (int)(35*aika))*0.4f;

	static float accum = 0;
	static float xrot = 0;
	static float yrot = 0;
	static float zrot = 0;
	static bool kasvuswitch = true;

	if (kasvusync->getActivated())
	{
		kasvuswitch ^= 1;
		accum += 25;
		xrot = (float)sin(aika*187);
		yrot = (float)sin(aika*114);
		zrot = (float)sin(aika*81);
	}

	for (i=0;i<lc;i++)
	{
		const float kohta = i / (float)lc;
		Matrix invert;
		invert.makeScale(1, -1, 1);

		Vector v1 = lerpVector(start, end, kohta);
		Vector v2 = v1 + Vector(0.25f, 0, 0);

		const float depth = 4;
		Vector v3 = v1 + Vector(0, 0, -depth);
		Vector v4 = v2 + Vector(0, 0, -depth);

		if (kasvuswitch)
		{
			lightline(v1, v2, violetti, 5, alpha*0.6f*vilkku, alpha*vilkku);
			lightline(v3, v4, violetti, 5, alpha*0.6f*vilkku, alpha*vilkku);
			lightline(v1, v3, violetti, 5, alpha*0.6f*vilkku, alpha*vilkku);
			lightline(v2, v4, violetti, 5, alpha*0.6f*vilkku, alpha*vilkku);

			Vector v5 = v1 * invert;
			Vector v6 = v2 * invert;
			Vector v7 = v3 * invert;
			Vector v8 = v4 * invert;

			lightline(v5, v6, violetti, 5, alpha*0.6f*vilkku, alpha*vilkku);
			lightline(v7, v8, violetti, 5, alpha*0.6f*vilkku, alpha*vilkku);
			lightline(v5, v7, violetti, 5, alpha*0.6f*vilkku, alpha*vilkku);
			lightline(v6, v8, violetti, 5, alpha*0.6f*vilkku, alpha*vilkku);
		}
		else
		{
			const float vet = 0.5f;
			const float vet2 = 0.09f;
			Vector v9 = v1 + Vector(-vet2, 0, vet);
			Vector v10 = v2 + Vector(vet2, 0, vet);
			Vector v11 = v3 + Vector(-vet2, 0, -vet);
			Vector v12 = v4 + Vector(vet2, 0, -vet);

			Vector v13 = v9 * invert;
			Vector v14 = v10 * invert;
			Vector v15 = v11 * invert;
			Vector v16 = v12 * invert;

			lightline(v9, v10, punainen, 5, alpha*0.5f*vilkku, alpha*vilkku);
			lightline(v9, v11, punainen, 5, alpha*0.5f*vilkku, alpha*vilkku);
			lightline(v11, v12, punainen, 5, alpha*0.5f*vilkku, alpha*vilkku);
			lightline(v10, v12, punainen, 5, alpha*0.5f*vilkku, alpha*vilkku);

			lightline(v13, v14, punainen, 5, alpha*0.5f*vilkku, alpha*vilkku);
			lightline(v13, v15, punainen, 5, alpha*0.5f*vilkku, alpha*vilkku);
			lightline(v15, v16, punainen, 5, alpha*0.5f*vilkku, alpha*vilkku);
			lightline(v14, v16, punainen, 5, alpha*0.5f*vilkku, alpha*vilkku);
		}
	}


	glPopMatrix();

	glPushMatrix();

	glRotatef(aika*360, 0, 1, 0.2f);
	glRotatef(accum, xrot, yrot, zrot);

	glDisable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);

	glEnable(GL_BLEND);
	glLineWidth(3.0f);

	for (i=0;i<kasvucount;i++)
	{
		kasvut[i].draw(alpha, aika);
	}

	glPopMatrix();


}
void kasvu_init()
{
	int i, j;
	kasvut = new KasvuItem[kasvucount];
	setSeed(10650);

	kasvusync = new Sync(44);
	const int synclength = 300;
	kasvusync->add(0x24, 0x00, synclength);
	kasvusync->add(0x24, 0x0C, synclength);
	kasvusync->add(0x24, 0x14, synclength);
	kasvusync->add(0x24, 0x2C, synclength);
	kasvusync->add(0x24, 0x30, synclength);
	kasvusync->add(0x24, 0x34, synclength);

	kasvusync->add(0x25, 0x00, synclength);
	kasvusync->add(0x25, 0x1A, synclength);
	kasvusync->add(0x25, 0x30, synclength);
	kasvusync->add(0x25, 0x34, synclength);

	kasvusync->add(0x26, 0x00, synclength);
	kasvusync->add(0x26, 0x0C, synclength);
	kasvusync->add(0x26, 0x14, synclength);
	kasvusync->add(0x26, 0x2C, synclength);
	kasvusync->add(0x26, 0x30, synclength);
	kasvusync->add(0x26, 0x34, synclength);

	kasvusync->add(0x27, 0x00, synclength);
	kasvusync->add(0x27, 0x0C, synclength);
	kasvusync->add(0x27, 0x14, synclength);
	kasvusync->add(0x27, 0x2C, synclength);
	kasvusync->add(0x27, 0x30, synclength);
	kasvusync->add(0x27, 0x34, synclength);

	kasvusync->add(0x28, 0x00, synclength);
	kasvusync->add(0x28, 0x0C, synclength);
	kasvusync->add(0x28, 0x14, synclength);
	kasvusync->add(0x28, 0x2C, synclength);
	kasvusync->add(0x28, 0x30, synclength);
	kasvusync->add(0x28, 0x34, synclength);

	kasvusync->add(0x29, 0x00, synclength);
	kasvusync->add(0x29, 0x1A, synclength);
	kasvusync->add(0x29, 0x30, synclength);
	kasvusync->add(0x29, 0x34, synclength);

	kasvusync->add(0x2a, 0x00, synclength);
	kasvusync->add(0x2a, 0x0C, synclength);
	kasvusync->add(0x2a, 0x14, synclength);
	kasvusync->add(0x2a, 0x2C, synclength);
	kasvusync->add(0x2a, 0x30, synclength);
	kasvusync->add(0x2a, 0x34, synclength);

	kasvusync->add(0x2b, 0x00, synclength);
	kasvusync->add(0x2b, 0x0C, synclength);
	kasvusync->add(0x2b, 0x14, synclength);
	kasvusync->add(0x2b, 0x2C, synclength);
	kasvusync->add(0x2b, 0x30, synclength);
	kasvusync->add(0x2b, 0x34, synclength);

/*
24                     00 0C 14 2C 30 34  
25                     00 1A 30 34  
26                     00 0C 14 2C 30 34 
27                     00 0C 14 2C 30 34
28                     00 0C 14 2C 30 34
29                     00 1A 30 34
2A                     00 0C 14 2C 30 34
*/

	for (i=0;i<kasvucount;i++)
	{
		const float kohta = i / (float)kasvucount;
		const float step = 1.0f / (float)kasvucount;

		kasvut[i].starttime = kohta;
		kasvut[i].endtime = kohta+step*4.0f;
		kasvut[i].position = randomSphereVector(1.0f);

		const int minkasvut = 300;
		const int maxkasvut = 400;
		kasvut[i].count = RAND_INT(minkasvut, maxkasvut);
		kasvut[i].vertices = new Vector[kasvut[i].count];
		switch(rand()%2)
		{
			case 0: kasvut[i].color1 = sininen; kasvut[i].color2 = oranssi; break;
			case 1: kasvut[i].color1 = Vector(0, 0, 0); kasvut[i].color2 = punainen; break;
		}
/*
		switch(RAND_INT(0, 3))
		{
			case 0: kasvut[i].color1 = sininen; break;
			case 1: kasvut[i].color1 = oranssi; break;
			case 2: kasvut[i].color1 = punainen; break;
			case 3: kasvut[i].color1 = violetti; break;
		}
		switch(RAND_INT(0, 3))
		{
			case 0: kasvut[i].color2 = sininen; break;
			case 1: kasvut[i].color2 = oranssi; break;
			case 2: kasvut[i].color2 = punainen; break;
			case 3: kasvut[i].color2 = violetti; break;
		}
*/
		Vector point = Vector(0, 0, 0);

		float phi = randFloat();
		float theta = randFloat();

		float dtheta = 0.01f+randFloat()*0.1f;
		float dphi = 0.01f+randFloat()*0.1f;

		Vector painopiste = Vector(0, 0, 0);
		
		for (j=0;j<kasvut[i].count;j++)
		{
			const float add = 0.02f*0+randFloat()*0.10f;
			point += sphereCoord(add, phi*3.141592f*2, theta*3.141592f);
			kasvut[i].vertices[j] = point;

			phi += dphi;
			theta += dtheta;

			dphi *= (0.75f+randFloat()*0.5f);
			dtheta *= (0.75f+randFloat()*0.5f);

			painopiste += point;
		}
/*
		for (j=0;j<kasvut[i].count;j++)
		{
			kasvut[i].vertices[j] -= painopiste*(1/kasvut[i].count);
		}
*/
	}
}

void kasvu_free()
{
	int i;
	for (i=0;i<kasvucount;i++)
	{
		delete [] kasvut[i].vertices;
	}
	delete [] kasvut;
	delete kasvusync;
}
