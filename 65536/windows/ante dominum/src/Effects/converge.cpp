#include "converge.hpp"

#pragma warning(disable:4244)

Lista *floaterlist;
Path *convergecam;
Path *convergetarget;

int convergefloatercount;
const int maxconvergefloatercount = 10000;
const float maxrange = 6.7f;
const float maxenergy = 0.05f;
 
Vector grad(float xp, float yp, float zp, float tp, float(*func)(float x, float y, float z, float t))
{
	const float epsilon = 0.001f;

	const float dx = func(xp+epsilon, yp, zp, tp) - func(xp, yp, zp, tp);
	const float dy = func(xp, yp+epsilon, zp, tp) - func(xp, yp, zp, tp);
	const float dz = func(xp, yp, zp+epsilon, tp) - func(xp, yp, zp, tp);

	return Vector(dx, dy, dz);
}

float div(float xp, float yp, float zp, float tp, float(*func)(float x, float y, float z, float t))
{
	const float epsilon = 0.001f;

	const float dx = func(xp+epsilon, yp, zp, tp) - func(xp, yp, zp, tp);
	const float dy = func(xp, yp+epsilon, zp, tp) - func(xp, yp, zp, tp);
	const float dz = func(xp, yp, zp+epsilon, tp) - func(xp, yp, zp, tp);

	return dx+dy+dz;
 
}

Vector convergefunc1(float x, float y, float z, float t)
{
	const float dist = (float)sqrt(x*x+y*y+z*z)*0.1f;
	Vector v = Vector(x, y, z)*dist;
	return v;
}

Vector convergefunc2(float x, float y, float z, float t)
{
	Vector p1 = Vector((float)cos(t*24)*7+(float)sin(t*13.5f)*3, 
					   7*(float)cos(t*56+0.2f), 
					   (float)cos(t*15)*7);
	Vector p2 = Vector((float)cos(t*17)*5, 19*(float)cos(t*26), (float)cos(t*11)*7);
	float d = (Vector(x, y, z)-p1).length();
	float d2 = (Vector(x, y, z)-p2).length();

	const float rotamount = (float)sin((d+d2)*0.4f*t);
	Matrix rot;
	rot.makeRotation(0, rotamount+t*16*0, 0);
	return Vector(1, 0, 0)*rot;
}

Vector convergefunc3(float x, float y, float z, float t)
{
	const float s = 0.3f;
	const float s2 = 10.0f;
	float tx = (float)sin(1.4f*x*s + 1.7f*z *s + 0.6f*t*s2);
	float ty = (float)sin(0.7f*x*s + 0.8f*t*s2);
	float tz = (float)sin(1.335f*x*s + 0.94*t*s2);

	return Vector(tx, 0, tz);

}

Vector convergedirector(float x, float y, float z, float t)
{
	const float starfieldstart = 0.0f;
	const float starfieldend = 0.6f;
	float starfieldpos = (1-calcPosFloat(t, starfieldstart, starfieldend))*3;

	if (starfieldpos > 1.0f)
		starfieldpos = 1.0f;

	float convergefunct = (0.5f+0.5f*(float)sin(t*24))*(1-calcPosFloat(t, 0.8f, 1.0f));

	return convergefunc1(x, y, z, t)*starfieldpos + (convergefunc2(x, y, z, t)*convergefunct+convergefunc3(x,y,z,t)*(1-convergefunct))*(1-starfieldpos);
}

void converge(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 6);

	static float previousframe = 0.0f;

	float dt = aika- previousframe;
	previousframe = aika;

	glLoadIdentity();

	const float angle = aika*7;
//	Vector campos = Vector(0, 8+4*(float)cos(aika*17), 0) + Vector((float)cos(angle), 0, (float)sin(angle))*20;;
//	Vector campos = Vector(0.1f, 25, 0.1f);

	Vector campos = convergecam->getValue(aika);
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	glColor4f(0, 0, 0, alpha);

	const float gridstep = 0.25f;


	Vector (*vectorfield)(float x, float y, float z, float t) = convergedirector;
/*
	glBegin(GL_LINES);
	for (z=-maxrange;z<maxrange;z+=gridstep)
	{
		for (x=-maxrange;x<maxrange;x+=gridstep)
		{
			const float scale = 1.0f;
			Vector v = Vector(x, 0, z)*scale;
			Vector v2 = v + vectorfield(x, 0, z, aika)*0.2f;
			glColor4f(0, 0, 0, alpha*0.3f);
			glVertex3fv((float *)&v);
			glColor4f(0, 0, 0, 0);
			glVertex3fv((float *)&v2);
		}
	}
	glEnd();
*/
//	glPointSize(3);
	glDisable(GL_DEPTH_TEST);
	glLineWidth(3);
	glBegin(GL_LINES);
	glColor4f(1, 0, 0, alpha);

	floaterlist->goToStart();
	while (floaterlist->goForward())
	{
		const float floaterspeed = 40.0f;
		Floater *f = (Floater *)floaterlist->getCurrent();
		if (f->update(dt*1.5f, maxrange, vectorfield(f->pos.x, f->pos.y, f->pos.z, aika)*floaterspeed))
		{
			f->draw(alpha);
		}
		else
		{
			floaterlist->remove();
			f = new Floater(false, maxenergy, maxrange);
			floaterlist->add(f);
		}
	}
	glEnd();
}


void converge_init()
{
	int i;
	floaterlist = new Lista();
	convergefloatercount = 0;

	srand(160917);
	for (i=0;i<maxconvergefloatercount;i++)
	{
		Floater *f = new Floater(false, maxenergy*1.0f, maxrange);
		floaterlist->add(f);
	}

	convergecam = new Path();
	convergetarget = new Path();

	convergecam->addpoint(Vector(1.1f, 15, -1.3f));
	convergecam->addpoint(Vector(1.1f, 15, -1.3f));
	convergecam->addpoint(Vector(1.1f, 15, -1.3f));
	convergecam->addpoint(Vector(1.1f, 15, -1.3f));
	convergecam->addpoint(Vector(1.1f, 25, -1.3f));
	convergecam->addpoint(Vector(5.1f, 30, -1.3f));
	convergecam->addpoint(Vector(9.1f, 30, -1.3f));
	convergecam->addpoint(Vector(14.1f, 20, -1.3f));
	convergecam->addpoint(Vector(17.1f, 6, -5.3f));
	convergecam->addpoint(Vector(21.1f, 6, -13.3f));
	convergecam->addpoint(Vector(19.1f, 8, -15.3f));
	convergecam->addpoint(Vector(14.1f, 11, -12.3f));
//	convergecam->addpoint(Vector(7,  4, -3));
//	convergecam->addpoint(Vector(14,  2, -10));
//	convergecam->addpoint(Vector(4,  11, -12));
//	convergecam->addpoint(Vector(-7,  13, -7));
//	convergecam->addpoint(Vector(-14,  9, -2));
}

void converge_free()
{
	floaterlist->destroy();
	delete floaterlist;

	delete convergecam;
	delete convergetarget;


} 
