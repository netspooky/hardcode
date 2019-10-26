#include "molekyylidata.hpp"

Vector fluvoksamiinindata[] = {

	Vector(0, 0, 0), //keskipiste
	Vector(0, 1, 0), //ylöspäin
	//hiilirengas
	Vector(0, 1, 0), 
	Vector(1, 1.5f, 0),
	Vector(1, 1.5f, 0),
	Vector(1, 2.5f, 0),
	Vector(1, 2.5f, 0),
	Vector(0, 3.0f, 0),
	Vector(0, 1, 0), 
	Vector(-1, 1.5f, 0),
	Vector(-1, 1.5f, 0),
	Vector(-1, 2.5f, 0),
	Vector(-1, 2.5f, 0),
	Vector(0, 3.0f, 0),

	//kaksoissidokset
	Vector(0, 2.85f, 0),
	Vector(0.85f, 2.40f, 0),
	Vector(-0.85f, 2.4f, 0),
	Vector(-0.85f, 1.6f, 0),
	Vector(0, 1.2f, 0),
	Vector(0.85f, 1.6f, 0),

	//14 (ja 6)

	//fluoritähti ylhäällä
	Vector(0, 3.0f, 0),
	Vector(0, 5.0f, 0),
	Vector(-1, 4.0f, 0),
	Vector(1, 4.0f, 0),

	//18

	//keskeltä alas oikealle
	Vector(0, 0, 0),
	Vector(-1, -0.5f, 0),
	Vector(-1, -0.5f, 0),
	Vector(-1, -1.5f, 0),
	Vector(-1, -1.5f, 0),
	Vector(-2, -2, 0),
	Vector(-2, -2, 0),
	Vector(-2, -3, 0),
	Vector(-2, -3, 0),
	Vector(-3, -3.5f, 0), //HAPPI
	Vector(-3, -3.5f, 0),
	Vector(-3, -4.5f, 0),

	//30
	Vector(0, 0, 0),
	Vector(1, -0.5f, 0),

	//kaksoissidos
	Vector(0, -0.2f, 0),
	Vector(1, -0.7f, 0),

	Vector(1, -0.5f, 0),  //TYPPI
	Vector(1, -1.5f, 0),
	Vector(1, -1.5f, 0),
	Vector(2, -2, 0),
	Vector(2, -2, 0),
	Vector(2, -3, 0),
	Vector(2, -3, 0),
	Vector(3, -3.5f, 0), //TYPPIRYHMÄ + VEDYT

	//42

};
int fluvoksamiininverteksit = 48;

Vector fluoksetiinindata[] = {

	//vasemmalle
	Vector(0, 0, 0),
	Vector(1, 0.5f, 0),
	Vector(1, 0.5f, 0),
	Vector(2, 0.0f, 0),
	Vector(2, 0.0f, 0),
	Vector(3, 0.5f, 0),
	//ylös (tähän typpi + happi-kombinaatio)
	Vector(3, 0.5f, 0),
	Vector(3, 1.5f, 0),


	//alas
	Vector(0, 0, 0),
	Vector(0, -1, 0),

	//hiilirengas
	Vector(0, -1, 0),
	Vector(1, -1.5f, 0),

	Vector(1, -1.5f, 0),
	Vector(1, -2.5f, 0),

	Vector(1, -2.5f, 0),
	Vector(0, -3.0f, 0),

	Vector(0, -3.0f, 0),
	Vector(-1, -2.5f, 0),

	Vector(-1, -2.5f, 0),
	Vector(-1, -1.5f, 0),

	Vector(-1, -1.5f, 0),
	Vector(0, -1, 0),

	//ja sen kaksoissidokset
	Vector(0, -1.2f, 0),
	Vector(-0.85f, -1.6f, 0),

	Vector(-0.85f, -2.4f, 0),
	Vector(0, -2.8f, 0),

	Vector(0.85f, -1.6f, 0),
	Vector(0.85f, -2.4f, 0),

	//oikealle ja ylös
	Vector(0, 0, 0),
	Vector(-1, 0.5f, 0), //happi tähän
	Vector(-1, 0.5f, 0), //happi tähän
	Vector(-1, 1.5f, 0), 

	//32 tähän saakka
	//hiilirengas
	Vector(-1, 1.5f, 0), 
	Vector(0, 2, 0),
	Vector(0, 2, 0),
	Vector(0, 3, 0),
	Vector(0, 3, 0),
	Vector(-1, 3.5f, 0),
	Vector(-1, 1.5f, 0), 
	Vector(-2, 2, 0),
	Vector(-2, 2, 0),
	Vector(-2, 3, 0),
	Vector(-2, 3, 0),
	Vector(-1, 3.5f, 0),

	//kaksoissidokset
	Vector(-1, 3.3f, 0),
	Vector(-1.85f, 2.9f, 0),
	Vector(-1.85f, 2.1f, 0),
	Vector(-1, 1.7f, 0),

	Vector(-0.15f, 2.1f, 0),
	Vector(-0.15f, 2.9f, 0),

	//ja fluoritähti
	Vector(-1, 3.5f, 0),
	Vector(-1, 5.5f, 0),
	Vector(-2, 4.5f, 0),
	Vector(-0, 4.5f, 0),
};
int fluoksetiininverteksit = 54;//30;

Vector sitalopraamindata[] = {
	//keskeltä ylös ja alas
	Vector(0,0,0),
	Vector(0,1,0),
	Vector(0,0,0),
	Vector(0,-1,0),

	//ylempi hiilirengas
	Vector(0, 1, 0), 
	Vector(1, 1.5f, 0),
	Vector(1, 1.5f, 0),
	Vector(1, 2.5f, 0),
	Vector(1, 2.5f, 0),
	Vector(0, 3.0f, 0),
	Vector(0, 1, 0), 
	Vector(-1, 1.5f, 0),
	Vector(-1, 1.5f, 0),
	Vector(-1, 2.5f, 0),
	Vector(-1, 2.5f, 0),
	Vector(0, 3.0f, 0),

	//kaksoissidokset
	Vector(0, 2.85f, 0),
	Vector(0.85f, 2.40f, 0),
	Vector(-0.85f, 2.4f, 0),
	Vector(-0.85f, 1.6f, 0),
	Vector(0, 1.2f, 0),
	Vector(0.85f, 1.6f, 0),

	//alempi hiilirengas
	Vector(0, -1, 0), 
	Vector(1, -1.5f, 0),
	Vector(1, -1.5f, 0),
	Vector(1, -2.5f, 0),
	Vector(1, -2.5f, 0),
	Vector(0, -3.0f, 0),
	Vector(0, -1, 0), 
	Vector(-1, -1.5f, 0),
	Vector(-1, -1.5f, 0),
	Vector(-1, -2.5f, 0),
	Vector(-1, -2.5f, 0),
	Vector(0, -3.0f, 0),
	//kaksoissidokset
	Vector(0, -2.85f, 0),
	Vector(0.85f, -2.40f, 0),
	Vector(-0.85f, -2.4f, 0),
	Vector(-0.85f, -1.6f, 0),
	Vector(0, -1.2f, 0),
	Vector(0.85f, -1.6f, 0),
	//alaosan typpihiilijuttu
	Vector(0, -3.0f, 0),
	Vector(0, -4.0f, 0),
	//alaosan kolmoissidos typpeen
	Vector(0, -4.0f, 0),
	Vector(0, -5.0f, 0),
	Vector(0.1f, -4.0f, 0),
	Vector(0.1f, -5.0f, 0),
	Vector(-0.1f, -4.0f, 0),
	Vector(-0.1f, -5.0f, 0),

	//viiden atomin hiilirengas hapella
	Vector(0, 0, 0),
	Vector(-1, 0.2f, 0),
	Vector(-1, 0.2f, 0),
	Vector(-1.5, -0.5f, 0),
	Vector(-1.5, -0.5f, 0),
	Vector(-1, -1.5f, 0),

	//yläosan fluori
	Vector(0, 3, 0),
	Vector(0, 4, 0),

	//ja vasemmalle sivulle
	Vector(0, 0, 0),
	Vector(1, 0.5f, 0),
	Vector(1, 0.5f, 0),
	Vector(2, 0.0f, 0),
	Vector(2, 0.0f, 0),
	Vector(3, 0.5f, 0),
	Vector(3, 0.5f, 0),
	Vector(4, 0.0f, 0),
	//typen vapaat osat
	Vector(4, 0.0f, 0),
	Vector(4.7f, 0.7f, 0),
	Vector(4, 0.0f, 0),
	Vector(4.2f, -0.9f, 0),
};

int sitalopraaminverteksit = 68;

Vector serotoniinindata[] = 
{
	//rengas
	Vector(0, 1, 0), 
	Vector(1, 1.5f, 0),
	Vector(1, 1.5f, 0),
	Vector(1, 2.5f, 0),
	Vector(1, 2.5f, 0),
	Vector(0, 3.0f, 0),
	Vector(0, 1, 0), 
	Vector(-1, 1.5f, 0),
	Vector(-1, 1.5f, 0),
	Vector(-1, 2.5f, 0),
	Vector(-1, 2.5f, 0),
	Vector(0, 3.0f, 0),

	//kaksoissidokset
	Vector(0, 2.85f, 0),
	Vector(-0.85f, 2.4f, 0),
	Vector(0.85f, 2.40f, 0),
	Vector(0.85f, 1.6f, 0),
	Vector(0, 1.2f, 0),
	Vector(-0.85f, 1.6f, 0),

	//pienempi rengas
	Vector(0, 1.0f, 0),
	Vector(-0.5f, -0.3f, 0), //typpi + vety tähän
	Vector(-0.5f, -0.3f, 0), 
	Vector(-1.5f, -0.1f, 0), 
	Vector(-1.5f, -0.1f, 0), 
	Vector(-1.9f, 1.0f, 0), 
	Vector(-1.9f, 1.0f, 0), 
	Vector(-1, 1.5f, 0),

	//kaksoissidos
//	Vector(-1.5f, -0.1f, 0), 
//	Vector(-1.9f, 1.0f, 0), 
	Vector(-1.35f, -0.0f, 0), 
	Vector(-1.7f, 0.9f, 0), 

	//kahva
	Vector(-1.9f, 1.0f, 0), 
	Vector(-2.9f, 1.5f, 0), 
	Vector(-2.9f, 1.5f, 0), 
	Vector(-3.9f, 1.0f, 0), 
	Vector(-3.9f, 1.0f, 0), 
	Vector(-4.9f, 1.5f, 0), //typpi tähän

	//antenni päällä
	Vector(0, 3.0f, 0),
	Vector(0, 4.0f, 0), //happi
};

int serotoniininverteksit = 36;
