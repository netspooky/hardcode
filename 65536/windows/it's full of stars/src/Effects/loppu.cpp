#include "loppu.hpp"
#include "synty.hpp"

void loppu(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 1);

	glLoadIdentity();

	const float kohta = aika*2;
	Vector campos = Vector(0, 0, -7.0f+aika*4.5f);
	Vector camtarget = Vector(0, 0, aika);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	const float zoom = 0.01f+(float)pow(sin(calcPosFloat(aika, 0.1f, 0.7f)*0.5f*3.141592f), 3.0f)*0.6f;
	const float size = 50;
	const float z = 20.0f;
	Vector p = Vector(0, -2, -aika*7*(0.4f+zoom));
	Vector p1 = p+Vector(-size, 0, -size);
	Vector p2 = p+Vector(size, 0, -size);
	Vector p3 = p+Vector(size, 0, size);
	Vector p4 = p+Vector(-size, 0, size);

	glLineWidth(3.0f);
	glColor4f(1,1,1, alpha*0.15f);
	glPushMatrix();
	glRotatef(17+aika*10, 0, 1, 0);
	renderGrid(p1, p2, p3, p4, 40);

    glPushMatrix();
    glScalef(0.6f, 0.6f, 0.6f);
    glRotatef(210, 0, 1, 0);
    glTranslatef(-4, 0, -2);
	glColor4f(0.8f, 0.5f, 0.2f, alpha);
    font_write3d("it's full of stars");
    glPopMatrix();
	glPopMatrix();



	
	
}

void loppu_init()
{
}

void loppu_free()
{
} 
