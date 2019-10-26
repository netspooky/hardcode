#ifndef _RUUTU_HPP_
#define _RUUTU_HPP_

#include "../stuff.hpp"

struct Ruutuitem
{
public:
	float starttime;
	float endtime;
	Vector startpos;
	Vector endpos;

	Vector rotangles;
	float startrot;
	float endrot;

	float starttwist;
	float endtwist;
	float startradius;
	float endradius;


};

void ruutu(float aika);
void ruutu_init();
void ruutu_free();

void ruutuplasma(float aika, float power);

#endif
