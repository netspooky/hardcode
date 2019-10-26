#include "cell.hpp"

#pragma warning(disable : 4244)
const int cgridx = 120;
const int cgridy = 120;
const int cellitemcount = 20;

float *cgrid;

CellItem *cellitems;

const int greetcount = 40; //ei saa olla pienempi kuin cellitemcount!
const int maxgreetlength = 30;
const char greetings[greetcount][maxgreetlength] = 
{
	"ananasmurska",
	"asd",
    "booZoholics",
    "brain control",
    "brainstorm",
    "candela",
    "collapse",
	"conspiracy",
    "cubicle",
	"demarche",
	"digital devotion",
    "division",
    "excess",
	"exhouse",
    "faktory",
    "gluterol",
	"hedelmae",
	"jumalauta",
    "kosmoplovci",
	"LAG",
    "lobstarrs",
	"matt current",
	"mfx",
	"neuro.concept",
    "numedia cyclops",
	"outbreak",
    "outracks",
	"promille deZign",
	"plastic",
	"rgba",
	"static",
    "stravaganZa",
	"synesthetics",
	"ümlaüt design",
    "youth uprising",
    "and everyone",
    "at Breakpoint",
    "and",
    "The Gathering"
};

int calculateDist(int x1, int y1, int x2, int y2);

void cell(float aika)
{
	int i;
	int x, y;
	const float alpha = calcSaturate(aika, 0, 1, 26);

	glLoadIdentity();

	Vector campos = Vector(20+aika*70, 0, -140.0f-aika*25);//+70*(float)cos(aika*18));
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(aika*20, 0.2f, 0.1f, 0.54f);
	glRotatef(-45, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

//	glViewport(0, 0, 512, 512);

	int count = 1+(int)((cellitemcount-1)*aika);
	float cellfrac = ((cellitemcount-1)*aika) - (int)((cellitemcount-1)*aika);

	for (i=0;i<count;i++)
	{
		float temp = cellitems[i].powerspeed*aika + cellitems[i].powerphase;
		cellitems[i].power = 0.5f+0.5f*(float)sin((temp - (int)temp)*3.141592f);

		if (i==count-1)
			cellitems[i].power *= cellfrac;

		float temp2 = cellitems[i].anglespeed*aika + cellitems[i].anglephase;
		temp2 *= 2*3.141592f;
		cellitems[i].pos = Vector((float)sin(temp2)+aika*2, (float)cos(temp2), 0)*cellitems[i].radius;
	}

	int offs = 0;
	for (y=0;y<cgridy;y++)
	{
		for (x=0;x<cgridx;x++)
		{
			int mindist = 1000000; //tarpeeksi :) 
			int index = 0;
			for (int i=0;i<count;i++)
            {
				int dist = calculateDist(x, y, cellitems[i].pos.x, cellitems[i].pos.y);//*cellitems[i].power;
				if (dist < mindist)
				{
					mindist = dist;
					index = i;
				}
			}
//			if (index == count-1)
//				cgrid[offs++] = (mindist*cellitems[index].power)/256.0f;
//			else
				cgrid[offs++] = (mindist)/256.0f;

		}
	}

	const float size = 160.0f + (float)pow((calcPosFloat(aika, 0.9f, 1.0f)*3.14592f*0.5f), 29)*360;
	const float valmul = calcPosFloat(aika, 0, 0.1f)*1.3f;
	glBegin(GL_QUADS);
	glColor4f(0, 0, 0, alpha);
	for (y=0;y<cgridx;y++)
	{
		for (x=1;x<cgridy;x++)
		{
			const float val = -cgrid[x+y*cgridx]+cgrid[x+y*cgridx-1];
			const float polysize = (0.3f+(val)*valmul);
			Vector kohta = Vector((float)x/cgridx-0.5f, (float)y/cgridy-0.5f, -val*0.04f)*size;

 			Vector v1 = kohta + Vector(-polysize, -polysize, 0);
			Vector v2 = kohta + Vector( polysize, -polysize, 0);
			Vector v3 = kohta + Vector( polysize,  polysize, 0);
			Vector v4 = kohta + Vector(-polysize,  polysize, 0);

			glVertex3fv((float *)&v1);
			glVertex3fv((float *)&v2);
			glVertex3fv((float *)&v3);
			glVertex3fv((float *)&v4);
		}
	}
	glEnd();
/*
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, render512_0->ID);
	glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, 512, 512, 0);
	glViewport(0, 0, OPENGL_XRES, OPENGL_YRES);

	glDisable(GL_DEPTH_TEST);
	perspective2D(1,1);

	glColor4f(1,1,1,1);
	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);
	glBegin(GL_QUADS);
	glVertex2f(0, 0);
	glVertex2f(1, 0);
	glVertex2f(1, 1);
	glVertex2f(0, 1);
	glEnd();

	glEnable(GL_TEXTURE_2D);

	glColor3f(1,1,1);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE_MINUS_SRC_COLOR, GL_SRC_COLOR);

	glBegin(GL_QUADS);
	glTexCoord2f(0, 0);
	glVertex2f(0, 0);
	glTexCoord2f(1, 0);
	glVertex2f(1, 0);
	glTexCoord2f(1, 1);
	glVertex2f(1, 1);
	glTexCoord2f(0, 1);
	glVertex2f(0, 1);
	glEnd();


	perspective3D();
	glDisable(GL_TEXTURE_2D);

*/
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	const float gt = calcSaturate(cellfrac, 0, 1, 1);
	glColor4f(1,0,0,gt);
	glPushMatrix();
	const float s = 2.5f;
	glScalef(s, s, s);
	glRotatef(180, 0, 1, 0);

	glTranslatef(-3.2f, 0, 0);
    glPushMatrix();
	font_write3d(greetings[(count*2)-1]);
    glPopMatrix();
    glPushMatrix();
	glTranslatef(0, -1.9f, 0);
	font_write3d(greetings[(count*2)]);
    glPopMatrix();
    glPopMatrix();
}

int calculateDist(int x1, int y1, int x2, int y2)
{
	int dx = abs(x1-x2);
	int dy = abs(y1-y2);
	if (dx > (cgridx/2)) 
		dx = cgridx-dx;
	if (dy > (cgridy/2)) 
		dy = cgridy-dy;
	return dx*dx + dy*dy;
}

void cell_init()
{
	int i;
	cgrid = new float[cgridx*cgridy];
	for (i=0;i<cgridx*cgridy;i++)
	{
		cgrid[i] = 0;
	}

	cellitems = new CellItem[cellitemcount];

	srand(1698516);
	setSeed(16891);
	for (i=0;i<cellitemcount;i++)
	{
		cellitems[i].pos = Vector((float)(rand()%cgridx), (float)(rand()%cgridy), 0);
		cellitems[i].powerspeed = 1 + 4*randFloat();
		cellitems[i].powerphase = randFloat();

		cellitems[i].radius = (1-randFloat()*randFloat())*128;
		cellitems[i].anglephase = randFloat();
		cellitems[i].anglespeed = 1 + 1*randFloat() - cellitems[i].radius/64;

	}

}

void cell_free()
{
	delete [] cgrid;
	delete [] cellitems;
} 
