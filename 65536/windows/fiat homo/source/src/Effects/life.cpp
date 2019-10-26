#include "../stuff.hpp"
#include "life.hpp"

bool *life1;
bool *life2;
bool *active;
bool filterfrom1to2 = true;

const int lifex = 50;
const int lifey = 40;

const int lifeframes = 16;
const float lifeframelength = 1.0f / (float)lifeframes;
float lifecurrentframepassed = 0.0f;
float lifeframestart = 0.0f;

void lifefilter(bool *t1, bool *t2);
bool lifesafeget(bool *source, int x, int y);
void lifeotus(int x, int y, float age, float aika, float alpha, Vector &position);

void life(float aika)
{
	int x, y;
	float alpha = calcSaturate(aika, 0, 1, 5);
	glLoadIdentity();
	glTranslatef(0, 0, -8.0f+(float)(1-cos(aika*0.5f*3.141592f))*3.5f);
	glRotatef(aika*30, -0.5f, 0.2f, 0.4f);
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	lifecurrentframepassed = aika - lifeframestart;

	if (lifecurrentframepassed > lifeframelength)
	{
		lifeframestart = aika;
		lifecurrentframepassed -= lifeframelength;
		if (filterfrom1to2)
		{
			lifefilter(life1, life2);
			active = life2;
		}
		else
		{
			lifefilter(life2, life1);
			active = life1;
		}
		filterfrom1to2 ^= 1;
	}

	const float pos = calcSaturate(lifecurrentframepassed, 0, lifeframelength, 2);

	const float xsize = 8;
	const float ysize = 8*((float)lifey/(float)lifex);

	Vector keskipiste = Vector(-xsize*0.5f, -ysize*0.5f, 0);
	for (y=0;y<lifey;y++)
	{
		keskipiste.x = -xsize*0.5f;
		for (x=0;x<lifex;x++)
		{
			if (active[x+y*lifex])
			{
				glColor4f(0,0,0,alpha*pos);
				lifeotus(x, y, pos, aika, alpha, keskipiste);
			}
			keskipiste.x += xsize / lifex;
		}
		keskipiste.y += ysize / lifey;
	}
}

void lifeotus(int x, int y, float age, float aika, float alpha, Vector &position)
{
	int i;
	const int maxkarvat = 4;
	const int minkarvat = 0;
	const int karvacount = minkarvat + ((x*17)+(y*19)+(x*y*23))%(maxkarvat-minkarvat);

	const int maxsakarat = 66;
	int sakarat = 0;
	int strips = 32;

	if (!((x*161179+y*14519)%5))
	{
		sakarat = (x*y*15+x+y*99)%maxsakarat;
		glColor4f(0.04f, 0.3f, 0.1f, alpha*age*0.7f);

	}
	else
	{
		glColor4f(0, 0, 0, alpha*age*0.7f);
		strips = 10;
	}

	float suunta = (x*y*x*y*x*y*x*y*x*y*x*y/10000.0f);
	position += Vector((float)sin(suunta), (float)cos(suunta), 0)*0.02f*aika;

	const float size = 0.07f * age;
	float kulma = 0.0f;

	glBegin(GL_LINE_STRIP);
	for (i=0;i<strips;i++)
	{
		const float kohta = i/(float)(strips-1);
		const float sizemod = (float)sin(kohta*2*3.141592f*sakarat*(1+aika));
		Vector p = position + Vector((float)sin(kulma), (float)cos(kulma), 0)*size*(1+sizemod);
		glVertex3fv((float *)&p);
		kulma += 2*3.141592f / (strips-1);
	}
	glEnd();

	//pisteet

	glPointSize(1.5f);
	glBegin(GL_POINTS);
	glColor4f(0.02f, 0.2f, 0.07f, alpha*age*0.7f);
	const int pointcount = 20;
	for (i=0;i<pointcount;i++)
	{
		const float pkohta = i/(float)pointcount;
		const float direction = pkohta*18+aika*6;
		const float dist = age*pkohta*0.4f;

		Vector p = position + Vector((float)sin(direction), (float)cos(direction), 0)*dist;
		glVertex3fv((float *)&p);
	}
	glEnd();
}


bool lifesafeget(bool *source, int x, int y)
{
	if (x < 0)
		x += lifex;
	if (y < 0)
		y += lifey;

	int tempx = x%lifex;
	int tempy = y%lifey;

	return source[tempx+tempy*lifex];
}

void lifefilter(bool *t1, bool *t2)
{
	int x, y;
	int index = 0;
	for (y=0;y<lifey;y++)
	{
		for (x=0;x<lifex;x++)
		{
			int naapurit = lifesafeget(t1, x-1, y-1);
			naapurit += lifesafeget(t1, x,  y-1);
			naapurit += lifesafeget(t1, x+1,y-1);
			naapurit += lifesafeget(t1, x-1,y);
			naapurit += lifesafeget(t1, x,  y);
			naapurit += lifesafeget(t1, x+1,y);
			naapurit += lifesafeget(t1, x-1,y+1);
			naapurit += lifesafeget(t1, x,  y+1);
			naapurit += lifesafeget(t1, x+1,y+1);

			//kuolema
			if (naapurit <= 1 || naapurit >= 4)
			{
				t2[index]=false;
			}
			//selviytyminen
			else if (t1[index]==true)
			{
				t2[index] = true;
			}
			else
			{
				//syntymä
				if (naapurit==3)
					t2[index] = true;
			}
			index++;
		}
	}
}

void life_init()
{
	int i;

	life1 = new bool[lifex*lifey];
	life2 = new bool[lifex*lifey];
	active = life2; //ekassa framessa life1->life2

	setSeed(15010);

	for (i=0;i<lifex*lifey;i++)
	{
		life2[i]=false;
		if (RAND_INT(0,2)<1)
			life1[i]=true;
		else
			life1[i]=false;
	}
}
void life_free()
{
	delete [] life1;
	delete [] life2;
}
