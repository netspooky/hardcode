#include "bigbang.hpp"

Vector *bigbang_start;
Vector *bigbang_end;

const int bigbang_points = 30000;

//se hippunen, johon zoomataan
const int targetindex = 26012;

void bigbang(float aika)
{
	int i;

	aika = (float)sin(aika*3.141592f*0.5f);
	aika *= aika;

	float alpha = calcPosFloat(aika, 0.0f, 0.5f)*0.8f;
	float bigbangaika = aika;

	float kameraaika = (float)(aika*aika);

//	kamera.. liikkuu [0,0,6] lähelle tarkasteltavaa pistettä

	//targetoitavan hitusen paikka
	Vector targetpos = lerpVector(Vector(0,0,0), bigbang_end[targetindex], kameraaika);

	//kameran paikka liikkuu kohti targetoitavaa hitusta, mutta ei ihan lähelle.. 
	Vector camerapos = lerpVector(Vector(0,0,-6), targetpos + Vector(0.06f, 0.06f, 0.06f), kameraaika*aika*0.94f);


	glLoadIdentity();
	gluLookAt(camerapos.x, camerapos.y, camerapos.z, targetpos.x, targetpos.y, targetpos.z, 0, 1, 0);
	
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glColor4f(0, 0, 0,alpha);

	const float pointsize = 2.5f + 1.5f*(float)sin(aika*3.141592f);
	glPointSize(pointsize);
	glColor4f(0, 0, 0,alpha);
	glBegin(GL_POINTS);
	for (i=0;i<bigbang_points;i++)
	{
		//aika = bigbangpos
		Vector pos = lerpVector(bigbang_start[i], bigbang_end[i], bigbangaika);
		glVertex3fv((float *)&pos);
	}
	glEnd();

}
void bigbang_init()
{
	int i;
	bigbang_start = new Vector[bigbang_points];
	bigbang_end	  = new Vector[bigbang_points];

	for (i=0;i<bigbang_points;i++)
	{
		bigbang_start[i] = Vector(0, 0, 0);

		const float suunta1 = randFloat() * 3.141592f;
		const float suunta2 = randFloat() * 3.141592f*2;

		const float minradius = 10;
		const float maxradius = 35;
		const float radius = minradius + randFloat()*(maxradius-minradius);

		bigbang_end[i] = sphereCoord(radius, suunta1, suunta2);
	}
}


void bigbang_free()
{
	delete [] bigbang_start;
	delete [] bigbang_end;
}
