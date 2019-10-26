#ifndef _RANTA_HPP_
#define _RANTA_HPP_

class Valonheitin
{
public:
	Vector location;
	float starttime;
	float endtime;

	float speed;
	float kulmaspeed;
	float kulma;	
	
	void draw(float aika, float alpha);


};

class Talo
{
public:
	Vector location;
	Vector color;
	float korkeus;
	float leveys;

	float starttime;
	float endtime;

	int stipple;

	void draw(float aika, float alpha);
};

class Vekotin
{
public:
	float starttime;
	float endtime;

	Vector startpos;
	Vector endpos;
	Vector color;

	void draw(float aika, float alpha);

};

void ranta_init();
void ranta_free();
void ranta(float aika);
void ranta_tausta(float aika);

#endif
