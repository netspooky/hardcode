#include "../stuff.hpp"
#include "ranta.hpp"

Vector *rantagrid;
Vector *saari;

Vector keskusta = Vector(0, 0, 4.0f);
const float taloradius = 2.0f;
	
int talocount = 50;
Talo *talot;

int rantagridx = 60;
int rantagridz = 60;
const float rantaxsize = 0.2f;
const float rantazsize = 0.2f;

int vekotincount = 500;
Vekotin *vekottimet;

int valonheitincount = 11;
float valonheitinradius = 1.7f;
Valonheitin *valonheittimet;

void ranta_tausta(float aika)
{
	int y;
	glDepthMask(0);
	perspective2D(1, 1);

	const int strips = 32;
	const float stripstep = 1.0f / strips;

	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glBegin(GL_QUADS);

	const float rajakohta = 0.5f;
	const float alpha = calcPosFloat(aika, 0.2f, 1.0f);

	const float pimennys = 1-calcPosFloat(aika, 0.7f, 0.9f);

	clearcolor = Vector(pimennys, pimennys, pimennys);
	
	for (y=0;y<strips;y++)
	{
		float y1 = y*stripstep*0.5f + rajakohta;
		float y2 = (y+1)*stripstep*0.5f + rajakohta;

		const float col = (1-y*stripstep*alpha)*pimennys;
		glColor3f(col, col, col);

		Vector v1 = Vector(0, y1, 0);
		Vector v2 = Vector(1, y1, 0);
		Vector v3 = Vector(1, y2, 0);
		Vector v4 = Vector(0, y2, 0);

		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
		glVertex3fv((float *)&v3);
		glVertex3fv((float *)&v4);
	}
	glEnd();

	perspective3D();
	glLoadIdentity();
	glDepthMask(1);
}
void ranta(float aika)
{
	int i;
	int x, y;

	const float alpha = calcSaturate(aika, 0, 1, 7);

	if (!spookyflag)
		ranta_tausta(aika);

	glLoadIdentity();
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	const float ylos = (float)pow(aika, 53);
	const float alas = (float)pow(1-aika, 33);


	const float up  = (float)pow(aika, 60)*40;
	Vector loppu = Vector(0, up, 0);

	Vector cam = Vector(aika*4.5f, 0.35f+aika*2.4f, -6.5f+aika*2.4f) + loppu;// + cam2;
	Vector camtarget = Vector(aika*aika*aika*2+ylos*10, -alas + ylos*25+aika*1.5f, 0) + loppu;
	gluLookAt(cam.x, cam.y, cam.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	//saari	
	glDepthMask(1);
	glEnable(GL_DEPTH_TEST);
	glClear(GL_DEPTH_BUFFER_BIT);

	//monoliitti
	const float monolithalpha = 1-calcPosFloat(aika, 0.6f, 0.62f)*alpha;
	if (monolithalpha > 0)
	{
		monoliitti(Vector(-3, 1, 3), monolithalpha, 0.4f);
	}


	glBegin(GL_QUADS);

	for (y=0;y<rantagridz-1;y++)
	{
		for (x=0;x<rantagridx-1;x++)
		{
			int modifier = (x^y)%4;
			int modifier2 = ((x+15)^(y+11))%4;
			float mul = 0.7f + (modifier/3.0f)*0.3f;
			float mul2 = 0.7f + (modifier/3.0f)*0.3f;
			Vector maastoncolor = Vector(0.85f,0.95f,0.85f)*(1-aika*aika)*mul + Vector(0.8f,0.8f,0.8f)*aika*aika*mul2;
			glColor4f(maastoncolor.x, maastoncolor.y, maastoncolor.z,alpha);
			Vector v1 = saari[((x  ))+((y  ))*rantagridx];
			Vector v2 = saari[((x+1))+((y  ))*rantagridx];
			Vector v3 = saari[((x+1))+((y+1))*rantagridx];
			Vector v4 = saari[((x  ))+((y+1))*rantagridx];

			if ((v1.y > 0) ||(v2.y > 0) ||(v3.y > 0) ||(v4.y > 0))
			{
				glVertex3fv((float *)&v1);
				glVertex3fv((float *)&v2);
				glVertex3fv((float *)&v3);
				glVertex3fv((float *)&v4);
			}
		}
	}
	glEnd();

	//talot
	
	glDepthMask(1);
	glEnable(GL_DEPTH_TEST);

	for (i=0;i<talocount;i++)
	{
		talot[i].draw(aika, alpha);
	}

	//saaret
	glDepthMask(0);

	glPushMatrix();
	const float scaleval = 1.03f;

	glScalef(1, scaleval, 1);

	Vector col = Vector(0,0,0)*(1-aika) + Vector(0.13f,0.2f,0.1f)*aika;
	glColor4f(col.x,col.y,col.z,alpha*0.7f);

	glBegin(GL_LINE_STRIP);
	for (y=0;y<rantagridz-1;y++)
	{
		for (x=0;x<rantagridx-1;x++)
		{
			Vector v1 = saari[((x  )%rantagridx)+((y  )%rantagridz)*rantagridx];
			Vector v2 = saari[((x+1)%rantagridx)+((y  )%rantagridz)*rantagridx];
			Vector v3 = saari[((x  )%rantagridx)+((y+1)%rantagridz)*rantagridx];

			if ((v1.y > 0) || (v2.y > 0) || (v3.y > 0))
			{
				glVertex3fv((float *)&v1);
				glVertex3fv((float *)&v2);
				glVertex3fv((float *)&v1);
				glVertex3fv((float *)&v3);
			}
		}
	}
	glEnd();
	glPopMatrix();

	//meri
	
	glColor4f(0.1f, 0.2f, 0.4f, alpha*0.6f);
	glBegin(GL_LINES);
	for (y=0;y<rantagridz-1;y++)
	{
		for (x=0;x<rantagridx-1;x++)
		{
			glVertex3fv((float *)&rantagrid[(x%rantagridx)+(y%rantagridz)*rantagridx]);
			glVertex3fv((float *)&rantagrid[((x+1)%rantagridx)+(y%rantagridz)*rantagridx]);
			glVertex3fv((float *)&rantagrid[(x%rantagridx)+(y%rantagridz)*rantagridx]);
			glVertex3fv((float *)&rantagrid[(x%rantagridx)+((y+1)%rantagridz)*rantagridx]);
		}
	}
	glEnd();

	//lentokoneet

	for (i=0;i<vekotincount;i++)
	{
		vekottimet[i].draw(aika, alpha);
	}
	//valonheittimet
	for (i=0;i<valonheitincount;i++)
	{
		valonheittimet[i].draw(aika, alpha);
	}
}

void ranta_init()
{
	int i;
	int x, y;

	const int nyppylacount = 7;
	Vector maasto[] = { 
						Vector(0,0,0),
					    Vector(5,0,4),
					    Vector(2,0,3.4f),
					    Vector(-5,0,8),
						Vector(-3,0,3),
						Vector(3,0,6),
						Vector(-1,0,7) 
						};

	rantagrid = new Vector[rantagridx*rantagridz];
	saari = new Vector[rantagridx*rantagridz];
	for (y=0;y<rantagridz;y++)
	{
		for (x=0;x<rantagridx;x++)
		{
			//nollatasoon
			Vector kohta = Vector((x-rantagridx*0.5f)*rantaxsize, 0, (y-rantagridz*0.5f)*rantazsize);
			rantagrid[x+y*rantagridx] = kohta;
			//saari

			float korkeus = 0;
			for (i=0;i<nyppylacount;i++)
			{
				Vector vuori = maasto[i];
				float dist = (kohta - vuori).length();
				const float max = 3.0f;
				float val = (max - dist)/max; //0..1

				if (val < 0)
					val = 0;

				korkeus += (float)sin(val*3.141592f*0.5f);
			}

			saari[x+y*rantagridx] = kohta + Vector(0, korkeus, 0);
		}
	}

	talot = new Talo[talocount];

	setSeed(16088);
	for (i=0;i<talocount;i++)
	{
		const float kohta = i / (float)talocount;
		const float step = 1.0f / (float)talocount;
		const float radius = taloradius*randFloat();
		const float angle = randFloat()*2*3.141592f;

		talot[i].location = Vector((float)sin(angle), 0, (float)cos(angle))*radius + keskusta;
		talot[i].korkeus = 1.0f + randFloat()*2.5f + (1.3f-radius)*1.2f;
		talot[i].leveys = 0.3f;

		if (radius > 1.5f)
			talot[i].korkeus *= 0.4f;

		talot[i].starttime = 0.1f + 0.4f*kohta;
		talot[i].endtime = talot[i].starttime + step*0.3f;

		const float harmaus = 0.4f + randFloat()*0.3f;
		talot[i].color = Vector(harmaus, harmaus, harmaus);

		talot[i].stipple = RAND_INT(2,5);
	}

	vekottimet = new Vekotin[vekotincount];
	
	for (i=0;i<vekotincount;i++)
	{
		const float basetime = 0.35f;
		const float kohta = (float)i/(float)vekotincount;
		const float step = 1.0f / (float)vekotincount;

		vekottimet[i].starttime = basetime + 0.001f*i;
		vekottimet[i].endtime = vekottimet[i].starttime + 0.27f;
		const float harmaus = 0.5f + randFloat()*0.3f;
		vekottimet[i].color = Vector(harmaus, harmaus, harmaus);

		const float matka = 10.0f;
		const float korkeus = 2.1f;
		
		Vector random = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f)*0.6f;

		switch(i%4)
		{
			case 0: vekottimet[i].startpos = Vector(-matka, korkeus, 0) + keskusta + random; break;
			case 1: vekottimet[i].startpos = Vector(matka, korkeus, 0) + keskusta + random; break;
			case 2: vekottimet[i].startpos = Vector(0, korkeus, matka) + keskusta + random; break;
			case 3: vekottimet[i].startpos = Vector(0, korkeus, -matka) + keskusta + random; break;
		}
		vekottimet[i].endpos = Vector(0, korkeus, 0) + keskusta + random;
	}

	valonheittimet = new Valonheitin[valonheitincount];
	for (i=0;i<valonheitincount;i++)
	{
		const float valonheitinstart = 0.5f;
		const float kohta = i / (float)valonheitincount;

		valonheittimet[i].starttime = valonheitinstart + kohta*0.1f;
		valonheittimet[i].endtime = valonheittimet[i].starttime + 0.1f;

		const float kulma = kohta *2*3.141592f;
		valonheittimet[i].location = keskusta + Vector((float)sin(kulma), 
											 0, 
											(float)cos(kulma))*valonheitinradius;
		valonheittimet[i].location.y = 0.5f;

		valonheittimet[i].speed = 10;
		valonheittimet[i].kulma = 0.3f*3.141592f + randFloat()*0.3f;
		valonheittimet[i].kulmaspeed = 15 + randFloat()*7;

	}
}

void ranta_free()
{
	delete [] talot;
	delete [] vekottimet;

	delete [] rantagrid;
	delete [] saari;
}


void Vekotin::draw(float aika, float alpha)
{
	float pos = calcPosFloat(aika, starttime, endtime);
	if (pos < 0.0001f)
		return;
	if (pos > 0.9999f)
		return;

	const float size = 0.03f;
	float alpha2 = calcSaturate(aika, starttime, endtime, 3);

	Vector location = startpos * (1-pos) + endpos*pos;

	Vector k1 = location + Vector(-size, size, -size);
	Vector k2 = location + Vector( size, size, -size);
	Vector k3 = location + Vector( size, size,  size);
	Vector k4 = location + Vector(-size, size,  size);

	Vector k5 = location + Vector(-size, -size, -size);
	Vector k6 = location + Vector( size, -size, -size);
	Vector k7 = location + Vector( size, -size,  size);
	Vector k8 = location + Vector(-size, -size,  size);
	
	glColor4f(color.x, color.y, color.z, alpha*alpha2);

	glBegin(GL_QUAD_STRIP);		
	
	glVertex3fv((float *)&k1);
	glVertex3fv((float *)&k5);
	glVertex3fv((float *)&k2);
	glVertex3fv((float *)&k6);
	glVertex3fv((float *)&k3);
	glVertex3fv((float *)&k7);
	glVertex3fv((float *)&k4);
	glVertex3fv((float *)&k8);

	glEnd();
	glBegin(GL_QUADS);
	glVertex3fv((float *)&k1);
	glVertex3fv((float *)&k2);
	glVertex3fv((float *)&k3);
	glVertex3fv((float *)&k4);

	glVertex3fv((float *)&k5);
	glVertex3fv((float *)&k6);
	glVertex3fv((float *)&k7);
	glVertex3fv((float *)&k8);

	glEnd();
}

void Valonheitin::draw(float aika, float alpha)
{
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_DEPTH_TEST);
	glDepthMask(0);

	//neljä kolmiota

	const float beamheight = 4.8f;
	const float width = 0.15f;
	const float instantkulma = kulmaspeed*aika;

	Vector p = location + Vector((float)sin(instantkulma), beamheight, (float)cos(instantkulma))*kulma;
	Vector v1 = location;
	Vector v2 = p + Vector(-width, 0, -width);
	Vector v3 = p + Vector(width, 0, -width);
	Vector v4 = p + Vector(width, 0, width);
	Vector v5 = p + Vector(-width, 0, width);

	const float valonheitinpos = calcPosFloat(aika, starttime, endtime);

	const float brightness = 0.4f*valonheitinpos;
	glBegin(GL_TRIANGLES);
	glColor4f(1,1,1,alpha*brightness);
	glVertex3fv((float *)&v1);
	glColor4f(1,1,1,0);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);

	glColor4f(1,1,1,alpha*brightness);
	glVertex3fv((float *)&v1);
	glColor4f(1,1,1,0);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);

	glColor4f(1,1,1,alpha*brightness);
	glVertex3fv((float *)&v1);
	glColor4f(1,1,1,0);
	glVertex3fv((float *)&v4);
	glVertex3fv((float *)&v5);

	glColor4f(1,1,1,alpha*brightness);
	glVertex3fv((float *)&v1);
	glColor4f(1,1,1,0);
	glVertex3fv((float *)&v5);
	glVertex3fv((float *)&v2);

	glEnd();
	glDepthMask(1);
}


void Talo::draw(float aika, float alpha)
{
	Vector color2 = color*0.8f; //raidat kuin seepralla.. .
	color2.z += 0.04f;

	float pos = calcPosFloat(aika, starttime, endtime);
	if (pos < 0.0001f)
		return;

	const int strips = 130;
	const float step = korkeus / (float)strips;
	const int saakka = (int)(pos * strips);

	const float size = leveys * 0.5f;

	for (int i=0;i<saakka;i++)
	{
		const float kohta = (float)i / (float)strips;
		float y1 = (korkeus*kohta);
		float y2 = (y1 + step);

		Vector k1 = location + Vector(-size, y1, -size);
		Vector k2 = location + Vector(size, y1, -size);
		Vector k3 = location + Vector(size, y1, size);
		Vector k4 = location + Vector(-size, y1, size);

		Vector k5 = location + Vector(-size, y2, -size);
		Vector k6 = location + Vector(size, y2, -size);
		Vector k7 = location + Vector(size, y2, size);
		Vector k8 = location + Vector(-size, y2, size);

		if ((i%stipple))
			glColor4f(color.x, color.y, color.z, alpha);
		else
			glColor4f(color2.x, color2.y, color2.z, alpha);
		glBegin(GL_QUAD_STRIP);		
		
		glVertex3fv((float *)&k1);
		glVertex3fv((float *)&k5);
		glVertex3fv((float *)&k2);
		glVertex3fv((float *)&k6);
		glVertex3fv((float *)&k3);
		glVertex3fv((float *)&k7);

		glEnd();
	}

	if (korkeus > 3.0f)
	{
		glColor4f(0, 0, 0, alpha*0.6f);
		Vector a1 = location + Vector(0, korkeus, 0) * pos;
		Vector a2= location + Vector(0, korkeus+0.2f*pos, 0) * pos;

		glBegin(GL_LINES);
		glVertex3fv((float *)&a1);
		glVertex3fv((float *)&a2);
		glEnd();

		glPointSize(2.5f*pos);
		glBegin(GL_POINTS);
		glVertex3fv((float *)&a2);
		glEnd();
	}
}
