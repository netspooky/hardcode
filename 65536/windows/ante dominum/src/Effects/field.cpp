#include "field.hpp"

#pragma warning(disable:4244)

Lista *fieldfloaterlist;
Path *fieldcam;
Path *fieldtarget;

int floatercount;
const int maxfieldfloatercount = 8000;
const float maxfieldrange = 10;
const float maxfieldenergy = 0.05f;

Vector fieldfunc1(float x, float y, float z, float t)
{
	const float dist = (float)sqrt(x*x+y*y+z*z)*0.05f;
	Vector v = Vector(x, y, z)*dist;
	return v;
}

Vector fieldfunc2(float x, float y, float z, float t)
{
	Vector p1 = Vector((float)cos(t*24)*7+(float)sin(t*13.5f)*3, 
					   7*(float)cos(t*56+0.2f), 
					   (float)cos(t*15)*7);
	Vector p2 = Vector((float)cos(t*17)*5, 19*(float)cos(t*26), (float)cos(t*11)*7);
	float d = (Vector(x, y, z)-p1).length();
	float d2 = (Vector(x, y, z)-p2).length();

	const float rotamount = (float)sin((d+d2)*1.0f*t);
	Matrix rot;
	rot.makeRotation(rotamount*0.5f, rotamount+t*6*0, 0);
	return Vector(5, 0, 0)*rot;
}

Vector fieldfunc3(float x, float y, float z, float t)
{
	const float s = 0.5f;
	const float s2 = 50.0f;
	float tx = (float)sin(1.4f*x*s + 0.7f*y*s + 1.7f*z *s + 0.6f*t*s2);
	float ty = (float)sin(0.7f*y*s + 0.8f*t*s2);
	float tz = (float)sin(1.335f*z*s + 0.8*x + 0.94*t*s2);

	return Vector(tx, ty, tz)*2;
}
Vector fielddirector(float x, float y, float z, float t)
{
	float t1 = calcPosFloat(t, 0.0f, 0.25f);
	float t2 = 0.5f+0.5f*(float)cos(t*19);

	Vector v = fieldfunc2(x,y,z,t)*(t2)+fieldfunc3(x,y,z,t)*(1-t2);
	return fieldfunc1(x, y, z, t)*(1-t1) + v*t1;

}


void field(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 3);

	static float previousframe = 0.0f;

	float dt = aika- previousframe;
	previousframe = aika;

	glLoadIdentity();

	const float angle = aika*7;
	glTranslatef(0, 0, -45);
	glRotatef(aika*360, 0.2f, 0.9f, 0.4f);

//	Vector campos = fieldcam->getValue(aika);
//	Vector camtarget = Vector(0, 0, 0);
//	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	glColor4f(0, 0, 0, alpha);

	const float gridstep = 0.25f;

	Vector (*vectorfield)(float x, float y, float z, float t) = fielddirector;
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

//	const float sca = 1+(float)sin(calcPosFloat(aika, 0.92f, 0.95f)*0.5f*3.141592f)*14;
	glPushMatrix();
//	glScalef(sca, sca, sca);


	glLineWidth(3);

	glEnable(GL_LINE_SMOOTH);
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST); 
	glBegin(GL_LINES);
	glColor4f(1, 0, 0, alpha);

	fieldfloaterlist->goToStart();
	while (fieldfloaterlist->goForward())
	{
		const float floaterspeed = 25.0f; //40.0f
		Floater *f = (Floater *)fieldfloaterlist->getCurrent();
		if (f->update(dt*1.0f, maxfieldrange, vectorfield(f->pos.x, f->pos.y, f->pos.z, aika)*floaterspeed))
		{
			f->draw(alpha);
		}
		else
		{
			fieldfloaterlist->remove();
			f = new Floater(true, maxfieldenergy, maxfieldrange);
			fieldfloaterlist->add(f);
		}
	}
	glEnd();
	glPopMatrix();
}


void field_init()
{
	int i;
	fieldfloaterlist = new Lista();
	floatercount = 0;

	srand(160917);
	for (i=0;i<maxfieldfloatercount;i++)
	{
		Floater *f = new Floater(true, maxfieldenergy*1.0f, maxfieldrange);
		fieldfloaterlist->add(f);
	}

	fieldcam = new Path();
	fieldtarget = new Path();

	fieldcam->addpoint(Vector(1.1f, 15, -1.3f));
	fieldcam->addpoint(Vector(1.1f, 15, -1.3f));
	fieldcam->addpoint(Vector(1.1f, 15, -1.3f));
	fieldcam->addpoint(Vector(1.1f, 15, -1.3f));
	fieldcam->addpoint(Vector(1.1f, 25, -1.3f));
	fieldcam->addpoint(Vector(5.1f, 30, -1.3f));
	fieldcam->addpoint(Vector(9.1f, 30, -1.3f));
	fieldcam->addpoint(Vector(14.1f, 20, -1.3f));
	fieldcam->addpoint(Vector(17.1f, 6, -5.3f));
	fieldcam->addpoint(Vector(21.1f, 6, -13.3f));
	fieldcam->addpoint(Vector(19.1f, 8, -15.3f));
	fieldcam->addpoint(Vector(14.1f, 11, -12.3f));
//	fieldcam->addpoint(Vector(7,  4, -3));
//	fieldcam->addpoint(Vector(14,  2, -10));
//	fieldcam->addpoint(Vector(4,  11, -12));
//	fieldcam->addpoint(Vector(-7,  13, -7));
//	fieldcam->addpoint(Vector(-14,  9, -2));
}

void field_free()
{
	fieldfloaterlist->destroy();
	delete fieldfloaterlist;

	delete fieldcam;
	delete fieldtarget;


} 
