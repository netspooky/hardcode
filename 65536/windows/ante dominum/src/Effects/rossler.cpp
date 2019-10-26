#include <stdio.h>
#include "rossler.hpp"

Vector *rosslerattractor;
int rosslercount;
Vector *rosslerstars;
int rosslerstarcount;

void rosslerview(Vector &cam, Vector &t, float aika, float alpha)
{
	int i;
	glLoadIdentity();
	gluLookAt(cam.x, cam.y, cam.z, t.x, t.y, t.z, 0, 1, 0);
	glRotatef(aika*40, 0.2f, 0.1f, -0.9f);
	glRotatef(aika*aika*80, -1, 0, 0); 


	glColor4f(0, 0, 0, alpha*0.5f);
	glPointSize(2.0f);
	glBegin(GL_POINTS);
	for (i=0;i<rosslerstarcount;i++)
	{
		glVertex3fv((float *)&rosslerstars[i]);
	}
	glEnd();

	glLineWidth(2.5f);
	const int todraw = (int)(rosslercount*calcPosFloat(aika, 0, 1));
/*
	glBegin(GL_LINE_STRIP);
	for (i=0;i<todraw;i++)
	{
		const float kohta = i / (float)rosslercount;
		const float a = (float)(0.5f+0.5f*sin(kohta*1000 + aika*15));
		glColor4f(0, 0, 0, alpha*0.7f*a);
		glVertex3fv((float *)&rosslerattractor[i]);
	}
	glEnd(); 
 */
 	glLineWidth(1.0f);
	glColor4f(0, 0, 0, alpha*0.4f);
	glBegin(GL_LINES);
	for (i=0;i<todraw;i++)
	{
		int offset2 = (i + 10)%rosslercount;
		glVertex3fv((float *)&rosslerattractor[i]);
		glVertex3fv((float *)&rosslerattractor[offset2]);
	}
	glEnd();


}

void rossler(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
	glEnable(GL_LINE_SMOOTH);
	glDisable(GL_DEPTH_TEST); 

	const float camt = calcPosFloat(aika, 0.45f, 0.55f);

	const float camspeed = 0.01f;
	static int camoffset = 2480;//95;
/*
	if (GetAsyncKeyState(VK_UP))
		camoffset++;
	if (GetAsyncKeyState(VK_DOWN))
		camoffset--;

	if (camoffset<0)
		camoffset = 0;

	char num[160];
	sprintf(num, "%d", camoffset);
	debugprint(num, 1);
	
*/
	int offset = (int)(aika*rosslercount*camspeed+camoffset);
	float frac = (aika*rosslercount*camspeed+camoffset ) - offset;

	Vector v1 = rosslerattractor[offset];
	Vector v2 = rosslerattractor[(offset+1)%rosslercount];
	Vector cam1 = Vector(0, 0, -aika*6);
	Vector cam2 = v1 + (v2-v1)*frac;
	Vector target = Vector(0, 0, 0);

	if (camt < 0.001f)
	{
		rosslerview(cam1, target, aika, alpha);
	}

	if (camt > 0.001f && camt < 0.999f)
	{
		rosslerview(cam1, target, aika, alpha*(1-camt));
		rosslerview(cam2, target, aika, alpha*(camt));
	}
	if (camt > 0.999f)
	{
		rosslerview(cam2, target, aika, alpha);
	}

}

void rossler_init()
{
	int i;
	rosslercount = 10000;
	rosslerstarcount = 4000;

	rosslerattractor = new Vector[rosslercount];
	float x = 0.03f;
	float y = 0.08f;
	float z = 0.01f;

	float a = 0.2f;
	float b = 0.2f;
	float c = 5.7f;
	float h = 0.02f;

	for (i=0;i<rosslercount;i++)
	{
		const float size = 0.1f;
		float x2 = x + h * -(y+z);
		float y2 = y + h * (x + a*y);
		float z2 = z + h * (b + z*(x-c));

		rosslerattractor[i] = Vector(x2, y2, z2)*size;
		x = x2;
		y = y2;
		z = z2;
	}

	rosslerstars = new Vector[rosslerstarcount];

	for (i=0;i<rosslerstarcount;i++)
	{
		rosslerstars[i] = randomSphereVector(5);
	}
}


void rossler_free()
{
	delete [] rosslerattractor;
	delete [] rosslerstars;

} 
