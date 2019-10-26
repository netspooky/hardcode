#include <stdio.h>
#include "lorentz.hpp"

Vector *lorentzattractor;
int lorentzcount;
Vector *stars;
int starcount;

void lorentz(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
	glEnable(GL_LINE_SMOOTH);
	glDisable(GL_DEPTH_TEST);

	glLoadIdentity();

	Vector cam = Vector(0, 0, -aika*4);
	Vector t = Vector(0, 0, 0);
	gluLookAt(cam.x, cam.y, cam.z, t.x, t.y, t.z, 0, 1, 0);
	
	glRotatef(aika*40, 0.2f, 0.1f, -0.9f);


	glColor4f(0, 0, 0, alpha*0.5f);
	glPointSize(2.0f);
	glBegin(GL_POINTS);
	for (i=0;i<starcount;i++)
	{
		glVertex3fv((float *)&stars[i]);

	}
	glEnd();

/*

	float x = 0.03f;
	float y = 0.08f;
	float z = 0.01f;

	float a = 10.0f;
	float b = 28.0f;
	float c = 8.0f / 3.0f + aika*7; // <------------ hieno 
	float h = 0.01f;

	for (i=0;i<lorentzcount;i++)
	{
		const float size = 0.1f;
		float x2 = x + h * a*(y-x);
		float y2 = y + h * (x*(b-z) - y);
		float z2 = z + h * (x*y - c*z);

		lorentzattractor[i] = Vector(x2, y2, z2)*size;
		x = x2;
		y = y2;
		z = z2;
	}


*/

	
	glLineWidth(2.5f);
	const int todraw = (int)(lorentzcount*calcPosFloat(aika, 0, 1));

	glBegin(GL_LINE_STRIP);
	for (i=0;i<todraw;i++)
	{
		const float kohta = i / (float)lorentzcount;
		const float a = (float)(0.5f+0.5f*sin(kohta*2000 + aika*15));
		glColor4f(0, 0, 0, alpha*0.7f*a);
		glVertex3fv((float *)&lorentzattractor[i]);
	}
	glEnd(); 
/*
	glLineWidth(1.0f);
	glColor4f(0, 0, 0, alpha*0.4f);
	glBegin(GL_LINES);
	for (i=0;i<lorentzcount;i++)
	{
		int offset2 = (i + 10)%lorentzcount;
		glVertex3fv((float *)&lorentzattractor[i]);
		glVertex3fv((float *)&lorentzattractor[offset2]);
	}
	glEnd();
*/
}

void lorentz_init()
{
	int i;
	lorentzcount = 5000;
	starcount = 4000;

	lorentzattractor = new Vector[lorentzcount];
	float x = 0.03f;
	float y = 0.08f;
	float z = 0.01f;

	float a = 10.0f;
	float b = 28.0f;
	float c = 8.0f / 3.0f;
	float h = 0.01f;

//	a = 28, b = 46.92, c = 4
	for (i=0;i<lorentzcount;i++)
	{
		const float size = 0.1f;
		float x2 = x + h * a*(y-x);
		float y2 = y + h * (x*(b-z) - y);
		float z2 = z + h * (x*y - c*z);

		lorentzattractor[i] = Vector(x2, y2, z2)*size;
		x = x2;
		y = y2;
		z = z2;
	}

	stars = new Vector[starcount];

	for (i=0;i<starcount;i++)
	{
		stars[i] = randomSphereVector(5);
	}
}


void lorentz_free()
{
	delete [] lorentzattractor;
	delete [] stars;

} 
