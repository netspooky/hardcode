#include "primitives.hpp"

void lightline(Vector end1, Vector end2, Vector color, float width, float alpha1, float alpha2)
{
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glLineWidth(width);

	glColor4f(color.x, color.y, color.z, alpha1);
	glBegin(GL_LINES);
	glVertex3fv((float *)&end1);
	glVertex3fv((float *)&end2);
	glEnd();
	glColor4f(1,1,1,alpha2);
	glLineWidth(1);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE );
	glBegin(GL_LINES);
	glVertex3fv((float *)&end1);
	glVertex3fv((float *)&end2);
	glEnd();
}

void lightquad2(Vector position, Vector rotate, float width, float height, Vector color, float alpha1, float alpha2, float alpha3)
{
	Matrix rot;
	rot.makeRotation(rotate.x, rotate.y, rotate.z);

	Vector v1 = position + Vector(-width, -height, 0)*rot;
	Vector v2 = position + Vector(width, -height, 0)*rot;
	Vector v3 = position + Vector(width, height, 0)*rot;
	Vector v4 = position + Vector(-width, height, 0)*rot;

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(color.x, color.y, color.z, alpha1);
	glBegin(GL_QUADS);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);
	glEnd();

//	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glLineWidth(4);
	glDepthMask(0);
	glColor4f(color.x, color.y, color.z, alpha2);
	glBegin(GL_LINE_LOOP);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);
	glEnd();

	glDepthMask(1);
	glLineWidth(1);

	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glColor4f(1,1,1, alpha3);
	glBegin(GL_LINE_LOOP);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);
	glEnd();
	

}

void lightquad(Vector position, Vector rotate, float width, float height, Vector color, float alpha1, float alpha2)
{
	Matrix rot;
	rot.makeRotation(rotate.x, rotate.y, rotate.z);

	Vector v1 = position + Vector(-width, -height, 0)*rot;
	Vector v2 = position + Vector(width, -height, 0)*rot;
	Vector v3 = position + Vector(width, height, 0)*rot;
	Vector v4 = position + Vector(-width, height, 0)*rot;

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(color.x, color.y, color.z, alpha1);
	glBegin(GL_QUADS);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);
	glEnd();

	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glColor4f(color.x, color.y, color.z, alpha2);
	glBegin(GL_LINE_LOOP);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);
	glEnd();
}
