#ifndef _KAUPUNKI_HPP_
#define _KAUPUNKI_HPP_

#include "../stuff.hpp"


class Polku
{
public:

	Polku(float start, float end, Vector &col, Vector &point1, Vector &point2);
	~Polku();

	void draw(float aika, float alpha);
	void generate(Vector &point1, Vector &point2);
	

	int vertexcount;
	Vector *vertices1;
	Vector *vertices2;

	float *alpha1;
	float *alpha2;
	Vector color;

	float starttime;
	float endtime;
};


class Talo
{
public:
	Vector pos;
	Vector color;
	float height;
	float width;

	float starttime;
	float endtime;

	int viivacount;
	Vector *viivat;

	void drawLines(float aika, float alpha);
	void drawPolys(float aika, float alpha);
};




void kaupunki(float aika);
void kaupunki_init();
void kaupunki_free();

#endif
