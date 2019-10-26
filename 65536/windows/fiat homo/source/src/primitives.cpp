#include "primitives.hpp"

void billboard(Vector &kohta, Vector &x, Vector &y, Vector &z, float scale)
{
	glBegin(GL_QUADS);
	Vector v1 = kohta - x*scale - y*scale;
	Vector v2 = kohta + x*scale - y*scale;
	Vector v3 = kohta + x*scale + y*scale;
	Vector v4 = kohta - x*scale + y*scale;

	glTexCoord2f(0, 0);
	glVertex3fv((float *)&v1);
	glTexCoord2f(1, 0);
	glVertex3fv((float *)&v2);
	glTexCoord2f(1, 1);
	glVertex3fv((float *)&v3);
	glTexCoord2f(0, 1);
	glVertex3fv((float *)&v4);
	glEnd();
}

void filledcircle(Vector &kohta, float radius)
{
	int j;
	const int ympyrastrips = 48;
	glBegin(GL_POLYGON);
	for (j=0;j<ympyrastrips;j++)
	{
		const float ympkohta = 2*3.141592f*j / (ympyrastrips-1);
		Vector v = kohta + Vector((float)sin(ympkohta), (float)cos(ympkohta), 0)*radius;
		glVertex3fv((float *)&v);

	}
	glEnd();
}

void circle(Vector &kohta, float radius)
{
	int j;
	const int ympyrastrips = 48;
	glBegin(GL_LINE_STRIP);
	for (j=0;j<ympyrastrips;j++)
	{
		const float ympkohta = 2*3.141592f*j / (ympyrastrips-1);
		Vector v = kohta + Vector((float)sin(ympkohta), (float)cos(ympkohta), 0)*radius;
		glVertex3fv((float *)&v);

	}
	glEnd();
}

void monoliitti(Vector kohta, float alpha, float scale)
{
	const float monolithz = 0.1f*scale;
	const float monolithx = 0.4f*scale;
	const float monolithy = 0.9f*scale;

	Vector etuvasenala = kohta + Vector(monolithx*-0.5f, 0, monolithz*-0.5f);
	Vector etuoikeaala = kohta + Vector(monolithx* 0.5f, 0, monolithz*-0.5f);
	Vector takavasenala = kohta + Vector(monolithx*-0.5f, 0, monolithz*0.5f);
	Vector takaoikeaala = kohta + Vector(monolithx* 0.5f, 0, monolithz*0.5f);
	Vector etuvasenyla = kohta + Vector(monolithx*-0.5f, monolithy, monolithz*-0.5f);
	Vector etuoikeayla = kohta + Vector(monolithx* 0.5f, monolithy, monolithz*-0.5f);
	Vector takavasenyla = kohta + Vector(monolithx*-0.5f, monolithy, monolithz*0.5f);
	Vector takaoikeayla = kohta + Vector(monolithx* 0.5f, monolithy, monolithz*0.5f);

	Vector harmaa1 = Vector(0.25f, 0.25f, 0.25f);
	Vector harmaa2 = Vector(0.14f, 0.14f, 0.14f);
	Vector harmaa3 = Vector(0.2f, 0.2f, 0.2f);

	glBegin(GL_QUADS);
	glColor4f(harmaa1.x, harmaa1.y, harmaa1.z, alpha);
	//alapuoli
	glVertex3fv((float *)&etuvasenala);
	glVertex3fv((float *)&etuoikeaala);
	glVertex3fv((float *)&takaoikeaala);
	glVertex3fv((float *)&takavasenala);
	//yläpuoli
	glVertex3fv((float *)&etuvasenyla);
	glVertex3fv((float *)&etuoikeayla);
	glVertex3fv((float *)&takaoikeayla);
	glVertex3fv((float *)&takavasenyla);
	glColor4f(harmaa2.x, harmaa2.y, harmaa2.z, alpha);
	//vasen
	glVertex3fv((float *)&etuvasenala);
	glVertex3fv((float *)&takavasenala);
	glVertex3fv((float *)&takavasenyla);
	glVertex3fv((float *)&etuvasenyla);
	//oikea
	glVertex3fv((float *)&etuoikeaala);
	glVertex3fv((float *)&takaoikeaala);
	glVertex3fv((float *)&takaoikeayla);
	glVertex3fv((float *)&etuoikeayla);
	glColor4f(harmaa3.x, harmaa3.y, harmaa3.z, alpha);
	//etu
	glVertex3fv((float *)&etuvasenyla);
	glVertex3fv((float *)&etuvasenala);
	glVertex3fv((float *)&etuoikeaala);
	glVertex3fv((float *)&etuoikeayla);
	//taka
	glVertex3fv((float *)&takavasenyla);
	glVertex3fv((float *)&takavasenala);
	glVertex3fv((float *)&takaoikeaala);
	glVertex3fv((float *)&takaoikeayla);
	glEnd();
}
