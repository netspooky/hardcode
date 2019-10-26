#include "everything.h"
#pragma warning(disable : 4305)


////////////////////////////////////////////////////////////////////////////////
// 
cLighting::cLighting()
{
}

cLighting::~cLighting()
{
}

void
cLighting::setSpecular(float r, float g, float b, float a)
{
	specular.r=r;	specular.g=g;	specular.b=b;	specular.a=a;
}

void
cLighting::setDiffuse(float r, float g, float b, float a)
{
	diffuse.r=r;	diffuse.g=g;	diffuse.b=b;	diffuse.a=a;
}

void
cLighting::setAmbient(float r, float g, float b, float a)
{
	ambient.r=r;	ambient.g=g;	ambient.b=b;	ambient.a=a;
}

void
cLighting::setPosition(float x, float y, float z, float d)
{
	position.x=x;	position.y=y;	position.z=z;	direction=d;
	basePos=position;
}


void
//cLighting::init(cLightStuff liSt, unsigned int targetNum)
cLighting::init(unsigned int targetNum)
{
	lightNum=targetNum;
	convert();
}

void
cLighting::move(cVec3f pos)
{
	position=basePos + pos;
}

void
cLighting::convert(void)
{
	pos[0]=position.x;
	pos[1]=position.y;
	pos[2]=position.z;
	pos[3]=direction;
}

void
cLighting::on(void)
{
	glEnable(GL_LIGHTING);
	glEnable(lightNum);
	glEnable(GL_NORMALIZE);
	glEnable(GL_COLOR_MATERIAL);
	glLightfv(lightNum, GL_SPECULAR, &specular.r);
	glLightfv(lightNum, GL_DIFFUSE, &diffuse.r);
	glLightfv(lightNum, GL_AMBIENT, &ambient.r);
	glLightfv(lightNum, GL_POSITION, pos);
}

void
cLighting::off(void)
{
	glDisable(GL_COLOR_MATERIAL);
	glDisable(GL_LIGHTING);
	glDisable(lightNum);
	glDisable(GL_NORMALIZE);
}
