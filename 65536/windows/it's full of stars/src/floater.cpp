#include "floater.hpp"

Floater::Floater(bool ydim, float maxenergy, float maxsize)
{
	const float prop = 0.7f;
	this->energy = maxenergy*prop + randFloat()*(1-prop);
	this->originalenergy = this->energy;
	if (ydim)
		this->pos = Vector(randFloat()*2-1, randFloat()*2-1, randFloat()*2-1)*maxsize;
	else
		this->pos = Vector(randFloat()*2-1, 0, randFloat()*2-1)*maxsize;

	this->prevpos = this->pos;

}

void Floater::draw(float alpha)
{
	const float t = this->energy / this->originalenergy; // 1..0
	const float a = calcSaturate(t, 0, 1, 3);//(float)sin(t*3.141592f);
	glColor4f(1, 0, 0, alpha*a);
	glVertex3fv((float *)&this->pos);
	glVertex3fv((float *)&this->prevpos);
}

bool Floater::update(float dt, float maxrange, Vector &suunta)
{
	float energymod = 1.0f;
	if (this->pos.x > maxrange || this->pos.x < -maxrange ||
		this->pos.y > maxrange || this->pos.y < -maxrange ||
		this->pos.z > maxrange || this->pos.z < -maxrange)
		energymod *= 5;

	const float mindt = 0.0015f;
	if (dt < mindt)
		dt = mindt;

	this->prevpos = this->pos;

	this->energy -= dt*energymod;
	if (this->energy <= 0.0f)
		return false;

	this->pos += suunta*dt;

	return true;
}
 
