#ifndef _MOLEKYYLI_HPP_
#define _MOLEKYYLI_HPP_

#include "../stuff.hpp"

class Aine
{
public:

	Aine() {}
	~Aine() { if (vertices) delete [] vertices; }

	int vertexcount;
	Vector *vertices;

	void draw(Vector color, float kohta, float alpha);
	void init(int count, Vector *vert);
};

void molekyyli_init();
void molekyyli_free();

void square(Vector pos, float alpha);
void nitrogen(Vector pos, float alpha);
void hydrogen(Vector pos, float alpha);
void oxygen(Vector pos, float alpha);
void fluorine(Vector pos, float alpha);
void carbon(Vector pos, float alpha);

void fluvoxamine(float alpha, float kohta);
void fluoxetine(float alpha, float kohta);
void citalopram(float alpha, float kohta);
void serotonin(float alpha, float kohta);


#endif
