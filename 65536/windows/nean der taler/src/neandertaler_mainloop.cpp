 /**

	coded by macaw / rasmus @ cromatics . dk

	released at the party 2000 - back to the fruits

	sourcecode notes : i decided to release the source for the "effects" in this crap intro.
				       you may abuse, rape, delete, copy, rip, re-release and do whatever you want with this,
					   as long as you don't contact me about it.

  
	reviews? check http://cde.calodox.org/index.php3?select_prod=106



	i know it's crap, and the code is fastcoded ( and doesnt compile :] )	
					   


  **/


#pragma warning(disable : 4244)
#pragma warning(disable : 4305) 


#define PI		3.1415926535897932384626433832795
#define PI2		6.283185307179586476925286766559
#define PID2	1.5707963267948966192313216916398

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <gl\gl.h>
#include <gl\glu.h>

#include <math.h>

#include <stdio.h>

#include "loadxm.h"

typedef struct {
	GLfloat x, y, z;
} Vector;

typedef struct {
	GLfloat u, v;
} MapCoord;

typedef struct {
	GLfloat r, g, b;
} Colors;

typedef struct {
	Vector		*vertices;
	GLuint		*faces;
	MapCoord	*mapping;
	Colors		*colors;
	int			numverts, numfaces;
	int			numsides;
	Vector		centrum;
} Object;


float sintab[1024], costab[1024];

long startTime = 0;
extern volatile long currentTime;

volatile GLdouble c = 0;

//glClearColor(0.38, 0, 0.22, 0.5);
GLfloat fogColor[4] = {0.125f, 0.05f,0.0025f,0.5f};

GLfloat blueBoxColor[4] = {0.4f, 0.5f, 0.6f, 0.05f};

GLfloat purpleBoxColor[4] = {0.5f, 0.5f, 0.5f, 0.5f};

GLfloat orangeBoxColor[4] = {0.8, 0.6, 0.4, 0.5};


//void loadJPEG(char *szFileName, int id);

#define LOGO	15
#define REPAY	16
#define CREDITS	17
#define TEXTIMG	18
#define SLIDER1	19
#define SLIDER2	20
#define SLIDER3	21
#define SLIDER4	22
#define SLIDER5	23
#define MACAW	24
#define PRAT	25
#define GREETS  26
#define GREETS2 27
#define TITLE   28
#define GROUPS1 29
#define GROUPS2 30
#define CIRKEL	31
#define CIRKEL2 32
#define FLARE	33

void vLin(int x, int ystart, int yslut, int *dest, int color, int width, int height) {
	//if (ystart<0 || yslut>480) return;
	if (x<0 || x>width) return;

	if (ystart<0) ystart=0;
	if (yslut>height) yslut=height;

	int off=ystart*width+x;
	
	for (int y=ystart+1; y<yslut-1; y++) {
		dest[off]=color;
		off+=width;
	}
}

void ellipse(int xc, int yc, int a, int b, int *dest, int color, int width, int height) {
	int		x, y;
	long	aa, aa2, bb, bb2, d, dx, dy;

	x=0;
	y=b;
	aa=long(a)*a;
	aa2=2*aa;
	bb=long(b)*b;
	bb2=2*bb;
	d=bb - aa * b + aa/4;
	dx=0;
	dy=aa2*b;
	vLin(xc, yc - y, yc + y, dest, color, width, height);

	while (dx < dy) {
		if (d > 0) {
			y--;
			dy-=aa2;
			d-=dy;
		}
		x++;
		dx+=bb2;
		d+=bb+dx;
	    vLin(xc - x, yc - y, yc + y, dest, color, width, height);
		vLin(xc + x, yc - y, yc + y, dest, color, width, height);
	}

	d+=(3 * (aa - bb) / 2 - (dx + dy)) / 2;

	while (y >= 0) {
		if (d < 0) {
			x++;
			dx+=bb2;
			d+=bb+dx;
			vLin(xc - x, yc - y, yc + y, dest, color, width, height);
			vLin(xc + x, yc - y, yc + y, dest, color, width, height);
		}
		y--;
		dy-=aa2;
		d+=aa-dy;
	}
}


void addObject(Object *o) {
	if (o->numsides==3) glBegin(GL_TRIANGLES);
	else if (o->numsides==4) glBegin(GL_QUADS);
	
	
	for (int i=0; i<o->numfaces*o->numsides; i++) {
		GLuint num = o->faces[i];
		GLuint v = i/o->numsides;
		glColor3f (o->colors[v].r, o->colors[v].g, o->colors[v].b);
		//glColor3f (1, 41, 0);
		glVertex3f(o->vertices[num].x, o->vertices[num].y,  o->vertices[num].z);
	}
	
	glEnd();
}

void addObjectLine(Object *o, GLfloat color) {
	for (int i=0; i<o->numfaces; i++) {
		glBegin(GL_LINES);
		glColor3f (color, color, color);
		for (int j=0; j<o->numsides; j++) {
			
			GLuint v = (i*4)+j;
			GLuint num = o->faces[v];
			//glColor3f (o->colors[v].r, o->colors[v].g, o->colors[v].b);
			//glColor3f (1, 41, 0);
			glVertex3f(o->vertices[num].x, o->vertices[num].y,  o->vertices[num].z);
		}
		glEnd();
	}
}


Object *allocateObject(int numverts, int numfaces, int numsides) {
	Object *o = new Object;
	
	o->numfaces=numfaces;
	o->numverts=numverts;
	o->numsides=numsides;

	o->faces = new GLuint [numfaces*numsides];
	o->vertices = new Vector [numverts];
	o->colors = new Colors [numfaces];
	o->mapping = new MapCoord [numverts];

	return o;
}




Object *makeSphere(float scale, int xsteps, int ysteps) {
	Object *o = allocateObject(xsteps*(ysteps+1), xsteps*ysteps*2+ysteps*2, 3);

	for (int y=0; y<ysteps+1; y++)
		for (int x=0; x<xsteps; x++) {
			Vector *p = &(o->vertices[y*xsteps+x]);
			MapCoord *m = &(o->mapping[y*xsteps+x]);
			

			double xs = (double)((PI2)/(xsteps)*x);
			double ys = (double)((PI2)/(ysteps)*y);
			p->x = sin(ys)*sin(xs)*scale;
			p->y = cos(ys)*scale;
			p->z = sin(ys)*cos(xs)*scale;

			m->u = (1.0/xsteps*x);
			m->v = (1.0/ysteps*y);
		}

		unsigned int * faces = o->faces;

		o->numfaces=0;
		for (y=0; y<ysteps; y++) {
			for (int x=0; x<xsteps; x++) {
				*faces=y*xsteps+x; faces++;
				*faces=(y*xsteps+x+1)&(xsteps*ysteps-1); faces++;
				*faces=(y+1)*xsteps+x; faces++;
				o->numfaces++;

				*faces=(y*xsteps+x+1)&(xsteps*ysteps-1); faces++;
				*faces=((y+1)*xsteps+x+1)&(xsteps*ysteps-1); faces++;
				*faces=((y+1)*xsteps+x)&(xsteps*ysteps-1); faces++;
				o->numfaces++;

			}
		}

		Colors		 * colors = o->colors;
		unsigned int   cnt = 0;
		for (int i=0; i<o->numfaces; i++) {
			
//				colors[cnt].r = 1.0/o->numfaces*i;
//				colors[cnt].g = 1.0/o->numfaces*i;
//				colors[cnt++].b = 1.0/o->numfaces*i;
			
			o->colors[i].r=o->colors[i].g=o->colors[i].b=fabs(o->vertices[o->faces[i*3]].x/10);
		}

//		o->numfaces=0;
//		o->numverts=0;

	return o;
}

Object *makeTetra(float size, float centerx, float centery, float centerz) {
	Object *o = allocateObject(4, 4, 3);

	int j=0;
	
	o->vertices[j].x = centerx; o->vertices[j].y = -1.0f*size + centery; o->vertices[j].z = -1.0f*size + centerz;
	o->mapping[j].u = 0; o->mapping[j].v = 0;
	j++;
	
	o->vertices[j].x = centerx; o->vertices[j].y = 1.0f*size + centery; o->vertices[j].z = -1.0f*size + centerz;
	o->mapping[j].u = 0; o->mapping[j].v = 1;
	j++;

	o->vertices[j].x = 1.0f*size + centerx; o->vertices[j].y = centery; o->vertices[j].z = 1.0f*size + centerz;
	o->mapping[j].u = 1; o->mapping[j].v = 0;
	j++;

	o->vertices[j].x = -1.0f*size + centerx; o->vertices[j].y = centery; o->vertices[j].z = 1.0f*size + centerz;
	o->mapping[j].u = 1; o->mapping[j].v = 1;
	j++;

	j=0;
	o->faces[j++]=0; o->faces[j++]=1; o->faces[j++]=3;
	o->faces[j++]=0; o->faces[j++]=3; o->faces[j++]=2;
	o->faces[j++]=1; o->faces[j++]=2; o->faces[j++]=3;
	o->faces[j++]=2; o->faces[j++]=1; o->faces[j++]=0;

	j=0;
	o->colors[j].r = orangeBoxColor[0]*0.8;
	o->colors[j].g = orangeBoxColor[1]*0.8;
	o->colors[j++].b = orangeBoxColor[2]*0.8;

	o->colors[j].r = orangeBoxColor[0]*0.9;
	o->colors[j].g = orangeBoxColor[1]*0.9;
	o->colors[j++].b = orangeBoxColor[2]*0.9;


	o->colors[j].r = orangeBoxColor[0];
	o->colors[j].g = orangeBoxColor[1];
	o->colors[j++].b = orangeBoxColor[2];

	o->colors[j].r = orangeBoxColor[0]*0.7;
	o->colors[j].g = orangeBoxColor[1]*0.7;
	o->colors[j++].b = orangeBoxColor[2]*0.7;

	return o;
}


void blob(Object *o, Object *original, float blob, float xdiv, float ydiv, float zdiv, float scalefactor) {
	for (int count=0; count<o->numverts; count++) {
		float scale=(float)(1.0+
			sin(original->vertices[count].x/xdiv+blob*2.2)*scalefactor+
			sin(original->vertices[count].y/ydiv+blob*5)*scalefactor+
			sin(original->vertices[count].z/zdiv+blob*4.9)*scalefactor);
			o->vertices[count].x = original->vertices[count].x*scale;
			o->vertices[count].y = original->vertices[count].y*scale;
			o->vertices[count].z = original->vertices[count].z*scale;                                       
	}
}

void putBlueBox(GLfloat scale) {
	glBegin(GL_QUADS);
	glColor4f(blueBoxColor[0]*0.7f, blueBoxColor[1]*0.7f, blueBoxColor[2]*0.7f, blueBoxColor[3]);
	glVertex3f (-scale, scale,-scale);
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale,-scale,-scale);
	glVertex3f (-scale,-scale,-scale);
	
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f (-scale,-scale, scale);
	
	glColor4f(blueBoxColor[0]*0.9f, blueBoxColor[1]*0.9f, blueBoxColor[2]*0.9f, blueBoxColor[3]);
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f (-scale,-scale,-scale);
	
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	
	glColor4f(blueBoxColor[0], blueBoxColor[1], blueBoxColor[2], blueBoxColor[3]);
	glVertex3f (-scale,-scale,-scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale, scale,-scale);
	glEnd();

}

void putWhiteBox(GLfloat scale) {
	glBegin(GL_QUADS);
	glColor4f(0.7f, 0.7f, 0.7f, 0.5f);
	glVertex3f (-scale, scale,-scale);
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale,-scale,-scale);
	glVertex3f (-scale,-scale,-scale);
	
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f (-scale,-scale, scale);
	
	glColor4f(0.9f, 0.9f, 0.9f, 0.5f);
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f (-scale,-scale,-scale);
	
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	
	glColor4f(1, 1, 1, 0.5f);
	glVertex3f (-scale,-scale,-scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale, scale,-scale);
	glEnd();

}

void putLineBox(GLfloat scale, float color) {
	glColor3f (color, color, color);
	glBegin(GL_LINES);
//	glColor3f (0.2f, 0.3f, 0.4f);
	
	glVertex3f (-scale, scale,-scale);
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale,-scale,-scale);
	glVertex3f (-scale,-scale,-scale);
	glVertex3f (-scale, scale,-scale);
	
//	glEnd();
	

//	glBegin(GL_LINES);
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f (-scale, scale, scale);
//	glEnd();

	
//	glColor3f (0.3f, 0.4f, 0.5f);

//	glBegin(GL_LINES);
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f (-scale,-scale,-scale);
	glVertex3f (-scale, scale,-scale);
//	glEnd();


	
//	glBegin(GL_LINES);
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	glVertex3f ( scale, scale,-scale);
//	glEnd();
	
//	glColor3f (0.4f, 0.5f, 0.6f);

//	glBegin(GL_LINES);
	glVertex3f (-scale,-scale,-scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	glVertex3f (-scale,-scale,-scale);
//	glEnd();
	

//	glBegin(GL_LINES);
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f (-scale, scale,-scale);
	glVertex3f ( scale, scale,-scale);
	glEnd();
}

void makeLineBox(GLfloat scale, float color) {
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);					// Set Line Antialiasing
	glEnable(GL_BLEND);							// Enable Blending
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	putLineBox(scale, color);
	glPushMatrix();
		glRotatef(90, 1, 0, 0);
		putLineBox(scale, color);
	glPopMatrix();

	glDisable(GL_BLEND);
	
}

void putGreyBox(GLfloat scale) {
	glBegin(GL_QUADS);
	glColor3f (0.3f, 0.3f, 0.3f);
	glVertex3f (-scale, scale,-scale);
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale,-scale,-scale);
	glVertex3f (-scale,-scale,-scale);
	
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f (-scale,-scale, scale);
	
	glColor3f (0.4f, 0.4f, 0.4f);
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f (-scale,-scale,-scale);
	
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	
	glColor3f (0.5f, 0.5f, 0.5f);
	glVertex3f (-scale,-scale,-scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale, scale,-scale);
	glEnd();
}


void putPurpleBox(GLfloat scale) {
	glBegin(GL_QUADS);
	glColor3f (purpleBoxColor[0], purpleBoxColor[1], purpleBoxColor[2]);
	glVertex3f (-scale, scale,-scale);
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale,-scale,-scale);
	glVertex3f (-scale,-scale,-scale);
	
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f (-scale,-scale, scale);
	
	glColor3f (purpleBoxColor[0]*0.9, purpleBoxColor[1]*0.9, purpleBoxColor[2]*0.9);
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f (-scale,-scale,-scale);
	
	glVertex3f ( scale, scale,-scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	
	glColor3f (purpleBoxColor[0]*0.7, purpleBoxColor[1]*0.7, purpleBoxColor[2]*0.7);
	glVertex3f (-scale,-scale,-scale);
	glVertex3f (-scale,-scale, scale);
	glVertex3f ( scale,-scale, scale);
	glVertex3f ( scale,-scale,-scale);
	
	glVertex3f (-scale, scale,-scale);
	glVertex3f (-scale, scale, scale);
	glVertex3f ( scale, scale, scale);
	glVertex3f ( scale, scale,-scale);
	glEnd();
}

static Object *tetraedeOrange;
static Object *graaKugle;
static Object *kugle2;
static GLfloat *tunnelSpeed;

#define NUMBOXES	10
static GLfloat *boxes;


extern unsigned char font_raw[429*30];
extern unsigned char slider1_raw[64*64];
extern unsigned char slider2_raw[64*64];
extern unsigned char slider3_raw[64*64];
extern unsigned char slider4_raw[64*64];
extern unsigned char slider5_raw[64*64];
extern unsigned char greets_raw[256*256];

char *letters = "abcdefghijklmnopqrstuvxyz";
int font_num_chars = 25;
int font_pos[25*2] = {6,22,25,39,41,55,57,72,74,88,89,102,104,120,122,138,141,152,153,165,166,183,186,197,200,222,224,241,243,259,259,276,278,293,298,309,311,325,329,338,341,356,360,374,375,392,394,410,413,427};

int font_width = 400;
int font_height = 30;


void loadRAW(unsigned char *memseg, int width, int height, int id) {
	unsigned char *rgba = new unsigned char [width*height*4];
	unsigned int index = 0;

	for (int y=0; y<height; y++)
		for (int x=0; x<width; x++) {
			unsigned char v = memseg[y*width+x];
			rgba[index++]=v;
			rgba[index++]=v;
			rgba[index++]=v;
			rgba[index++]=v;
		}
	
	glBindTexture (GL_TEXTURE_2D, id);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, rgba);
	

	delete rgba;
}

void loadRAW32(unsigned char *memseg, int width, int height, int id) {
	glBindTexture (GL_TEXTURE_2D, id);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexImage2D (GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, memseg);
}

void putstring(char *str, unsigned char *dest, int posx, int posy, int destwidth, int destheight) {
	int i=0;
	int pos=posx;

	while (str[i]!='\0') {
		if (str[i]!=' ') {
			int j = 0;
			int newpos;
			while (letters[j]!=str[i]) j++;
			for (int y=0; y<font_height; y++) {
				newpos=pos;
				for (int x=font_pos[j*2]; x<font_pos[(j*2)+1]; x++) {
					
					if (pos+x-font_pos[j*2]>0 && pos+x-font_pos[j*2]<destwidth 
						&& (y+posy)>0 && (y+posy)<destheight) {

						int val = dest[(pos+x-font_pos[j*2])+(y+posy)*destwidth]+font_raw[y*429+x];
						if (val>255) val=255;
						dest[(pos+x-font_pos[j*2])+(y+posy)*destheight]=val;
					}
					newpos++;
				}
			}
			pos=newpos-4;
		} else pos+=8;

		i++;
	}
}

Object * makeKnot(int SCALING_FACTOR1, int SCALING_FACTOR2, double RADIUS1, double RADIUS2, double RADIUS3) {
	int Count1, Count2;
	double Alpha, Beta, Distance, MinDistance, Rotation;

	Object * o = allocateObject(SCALING_FACTOR1 * SCALING_FACTOR2, SCALING_FACTOR1 * SCALING_FACTOR2 * 4, 4);
	
	o->numfaces=0;
	o->numverts=0;

	for(Alpha = 0, Count2 = 0; Count2 < SCALING_FACTOR2; Count2++, Alpha += 2 * PI / SCALING_FACTOR2) {
		double X = RADIUS2 * cos(2 * Alpha) + RADIUS1 * sin(Alpha);
		double Y = RADIUS2 * sin(2 * Alpha) + RADIUS1 * cos(Alpha);
		double Z = RADIUS2 * cos(3 * Alpha);
		double dx = -2 * RADIUS2 * sin(2 * Alpha) + RADIUS1 * cos(Alpha);
		double dy = 2 * RADIUS2 * cos(2 * Alpha) - RADIUS1 * sin(Alpha);
		double dz = -3 * RADIUS2 * sin(3 * Alpha);
		double Value = sqrt(dx * dx + dz * dz);
		double Modulus = sqrt(dx * dx + dy * dy + dz * dz);

		for(Beta = 0, Count1 = 0; Count1 < SCALING_FACTOR1; Count1++, Beta += 2 * PI / SCALING_FACTOR1)
		{
			o->vertices[o->numverts].x = X - RADIUS3 * (cos(Beta) * dz - sin(Beta) * dx * dy / Modulus) / Value;
			o->vertices[o->numverts].y = Y - RADIUS3 * sin(Beta) * Value / Modulus;
			o->vertices[o->numverts].z = Z + RADIUS3 * (cos(Beta) * dx + sin(Beta) * dy * dz / Modulus) / Value;
			

			GLfloat dist = sqrt(o->vertices[o->numverts].x*o->vertices[o->numverts].x +
						        o->vertices[o->numverts].y*o->vertices[o->numverts].y +
								o->vertices[o->numverts].z*o->vertices[o->numverts].z);

				
			o->colors[o->numverts].r = ((2/dist)+(0.5*sin(Beta)+0.5))/2.0;
			o->colors[o->numverts].g = ((2/dist)+(0.5*sin(Beta)+0.5))/2.0;
			o->colors[o->numverts].b = ((2/dist)+(0.5*sin(Beta)+0.5))/2.0;
			
			o->numverts++;
		}
	}
	for(Count1 = 0; Count1 < SCALING_FACTOR2; Count1++)
	{
		int Index1 = Count1 * SCALING_FACTOR1;
		int Index2 = Index1 + SCALING_FACTOR1;
		Index2 %= o->numverts;
		Rotation = 0;
		MinDistance = (o->vertices[Index1].x - o->vertices[Index2].x) * (o->vertices[Index1].x - o->vertices[Index2].x) +
	                  (o->vertices[Index1].y - o->vertices[Index2].y) * (o->vertices[Index1].y - o->vertices[Index2].y) +
                      (o->vertices[Index1].z - o->vertices[Index2].z) * (o->vertices[Index1].z - o->vertices[Index2].z);
		for(Count2 = 1; Count2 < SCALING_FACTOR1; Count2++)
		{
			Index2 = Count2 + Index1 + SCALING_FACTOR1;
			if(Count1 == SCALING_FACTOR2 - 1) Index2 = Count2;
		    Distance = (o->vertices[Index1].x - o->vertices[Index2].x) * (o->vertices[Index1].x - o->vertices[Index2].x) +
	                   (o->vertices[Index1].y - o->vertices[Index2].y) * (o->vertices[Index1].y - o->vertices[Index2].y) +
                       (o->vertices[Index1].z - o->vertices[Index2].z) * (o->vertices[Index1].z - o->vertices[Index2].z);
			if(Distance < MinDistance)
			{
				MinDistance = Distance;
				Rotation = Count2;
			}
		}
		for(Count2 = 0; Count2 < SCALING_FACTOR1; Count2++)
		{
			Index2 = ((int)(SCALING_FACTOR1 + Count2 + Rotation)) % SCALING_FACTOR1;
			o->faces[4*(Index1+Count2)+0] = Index1 + Count2;

			Index2 = Count2 + 1;
			Index2 %= SCALING_FACTOR1;
			o->faces[4*(Index1+Count2)+1] = Index1 + Index2;

			Index2 = Count2 + Rotation + 1;
			Index2 %= SCALING_FACTOR1;
			o->faces[4*(Index1+Count2)+2] = (Index1 + Index2 + SCALING_FACTOR1) % o->numverts;
			
			Index2 = Count2 + Rotation;
			Index2 %= SCALING_FACTOR1;

			o->faces[4*(Index1+Count2)+3]= (Index1 + Index2 + SCALING_FACTOR1) % o->numverts;

			o->numfaces++;
		}
	}

	return o;
}


void reCalcKnot(int SCALING_FACTOR1, int SCALING_FACTOR2, double RADIUS1, double RADIUS2, double RADIUS3, Object *o) {
	int Count1, Count2;
	double Alpha, Beta;

	o->numverts=0;

	for(Alpha = 0, Count2 = 0; Count2 < SCALING_FACTOR2; Count2++, Alpha += 2 * PI / SCALING_FACTOR2) {
		double X = RADIUS2 * cos(2 * Alpha) + RADIUS1 * sin(Alpha);
		double Y = RADIUS2 * sin(2 * Alpha) + RADIUS1 * cos(Alpha);
		double Z = RADIUS2 * cos(3 * Alpha);
		double dx = -2 * RADIUS2 * sin(2 * Alpha) + RADIUS1 * cos(Alpha);
		double dy = 2 * RADIUS2 * cos(2 * Alpha) - RADIUS1 * sin(Alpha);
		double dz = -3 * RADIUS2 * sin(3 * Alpha);
		double Value = sqrt(dx * dx + dz * dz);
		double Modulus = sqrt(dx * dx + dy * dy + dz * dz);

		for(Beta = 0, Count1 = 0; Count1 < SCALING_FACTOR1; Count1++, Beta += 2 * PI / SCALING_FACTOR1)
		{
			o->vertices[o->numverts].x = X - RADIUS3 * (cos(Beta) * dz - sin(Beta) * dx * dy / Modulus) / Value;
			o->vertices[o->numverts].y = Y - RADIUS3 * sin(Beta) * Value / Modulus;
			o->vertices[o->numverts].z = Z + RADIUS3 * (cos(Beta) * dx + sin(Beta) * dy * dz / Modulus) / Value;
			

			GLfloat dist = sqrt(o->vertices[o->numverts].x*o->vertices[o->numverts].x +
						        o->vertices[o->numverts].y*o->vertices[o->numverts].y +
								o->vertices[o->numverts].z*o->vertices[o->numverts].z);

				
			o->colors[o->numverts].r = ((2/dist)+(0.5*sin(Beta)+0.5))/2.0;
			o->colors[o->numverts].g = ((2/dist)+(0.5*sin(Beta)+0.5))/2.0;
			o->colors[o->numverts].b = ((2/dist)+(0.5*sin(Beta)+0.5))/2.0;
			
			o->numverts++;
		}
	}
}




#define RGBA(r, g, b, a) (a<<24)+(r<<16)+(g<<8)+b

static GLfloat cirkelposx[10];
static GLfloat cirkelposy[10];
Object *knude, *knude2;


void init() {
/*
#ifdef SOUND
	soundEnabled=1;
#else
	soundEnabled=0;
#endif
*/
   int i=0;
   while (i<1024) {
    sintab[i]=sin(2*i*3.1415/1024.0);
	costab[i]=cos(2*i*3.1415/1024.0);
	i++;
   }

	knude = makeKnot(20, 100, 6.3, 5.0, 2.5);
	knude2 = makeKnot(20, 100, 6.3, 5.0, 2.5);
	
	for (int p=0; p<10; p++) {
		cirkelposy[p]=(p-5.0f)/5.0f;
		cirkelposx[p]=sin(p*5);
	}

	tunnelSpeed = new GLfloat [100];
	boxes = new GLfloat [NUMBOXES];

	for (int j=0; j<100; j++) tunnelSpeed[j]=j;
	for (i=0; i<NUMBOXES; i++) boxes[i]=i;
	tetraedeOrange = makeTetra(1, 0, 0, 0);
	graaKugle = makeSphere(5, 32/2, 32/2);
	kugle2 = makeSphere(5, 32/2, 32/2);

	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);	
	
	loadRAW(slider1_raw, 64, 64, SLIDER1);
	loadRAW(slider2_raw, 64, 64, SLIDER2);
	loadRAW(slider3_raw, 64, 64, SLIDER3);
	loadRAW(slider4_raw, 64, 64, SLIDER4);
	loadRAW(slider5_raw, 64, 64, SLIDER5);

	unsigned char *credits = new unsigned char [256*256];
	memset(credits, 0, 256*256);
	putstring("coded by macavv\0", credits, 0, 0, 256, 256);
	loadRAW(credits, 256, 256, MACAW);
	delete credits;

	credits = new unsigned char [256*256];
	memset(credits, 0, 256*256);
	putstring("music by prat\0", credits, 0, 0, 256, 256);
	loadRAW(credits, 256, 256, PRAT);
	delete credits;

	credits = new unsigned char [256*256];
	memset(credits, 0, 256*256);
	putstring("nean der taler\0", credits, 0, 0, 256, 256);
	loadRAW(credits, 256, 256, TITLE);
	delete credits;

	credits = new unsigned char [256*256];
	memset(credits, 0, 256*256);
	putstring("non alien nature five\0", credits, 0, 0, 256, 256);
	loadRAW(credits, 256, 256, GROUPS1);
	delete credits;

	credits = new unsigned char [256*256];
	memset(credits, 0, 256*256);
	putstring("bypass\0", credits, 0, 0, 256, 256);
	loadRAW(credits, 256, 256, GROUPS2);
	delete credits;

	credits = new unsigned char [256*256];
	memset(credits, 0, 256*256);

	for (int y=0; y<256; y++) {
		for (int x=0; x<256; x++) {
			GLfloat n = (256-sqrt((x-128)*(x-128)+(y-128)*(y-128))*2.5);
				
			if (n<0) n=0;
			n*=1.7;
			if (n>255) n=255;

			credits[y*256+x]=n;
/*
			credits[(255-y)*256+x]=n;
			credits[y*256+(255-x)]=n;
			credits[(255-y)*256+(255-x)]=n;
*/

		}
	}
	loadRAW(credits, 256, 256, FLARE);
	delete credits;

	credits = new unsigned char [256*256];
	memset(credits, 0, 256*256);

	putstring("hello to\0", credits, 0, 0, 256, 256);
	y=30;
	putstring("aardbei\0", credits, 0, y+=30, 256, 256);
	putstring("alien prophets\0", credits, 0, y+=30, 256, 256);
	putstring("blasphemy\0", credits, 0, y+=30, 256, 256);
	putstring("fudge\0", credits, 0, y+=30, 256, 256);
	putstring("haujobb\0", credits, 0, y+=30, 256, 256);
	putstring("klan\0", credits, 0, y+=30, 256, 256);
	loadRAW(credits, 256, 256, GREETS);
	delete credits;

	credits = new unsigned char [256*256];
	memset(credits, 0, 256*256);
	y=30;	
	putstring("kolor\0", credits, 0, y+=30, 256, 256);
	putstring("loonies\0", credits, 0, y+=30, 256, 256);
	putstring("mainloop\0", credits, 0, y+=30, 256, 256);
	putstring("prone\0", credits, 0, y+=30, 256, 256);
	putstring("purple\0", credits, 0, y+=30, 256, 256);
	putstring("tivoliet\0", credits, 0, y+=30, 256, 256);
	loadRAW(credits, 256, 256, GREETS2);
	delete credits;


	credits = new unsigned char [256*256*4];
	memset(credits, 0, 256*256*4);
	//putstring("bypass\0", credits, 0, 0, 256, 256);
	ellipse(128, 128, 100, 120, (int*)credits, RGBA(75,75,75,75), 256, 256);
	loadRAW32(credits, 256, 256, CIRKEL);
	delete credits;

	credits = new unsigned char [128*128*4];
	memset(credits, 0, 128*128*4);
	//putstring("bypass\0", credits, 0, 0, 256, 256);
	ellipse(64, 64, 60, 64, (int*)credits, RGBA(50,50,50,50), 128, 128);
	loadRAW32(credits, 128, 128, CIRKEL2);
	delete credits;

	
	//	loadRAW(greets_raw, 256, 256, GREETS);
}

void close() {
}


void putImage(int image, float x, float y, float z) {
	glPushMatrix();

		glDisable(GL_DEPTH_TEST);
		
		glColor4f( 1,1,1,0 );	

		glTranslatef(x,y,z);						

		glBindTexture(GL_TEXTURE_2D, image);			
		glBegin(GL_QUADS);									
			glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.1f, -1.1f,  0.0f);	
			glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.1f, -1.1f,  0.0f);	
			glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.1f,  1.1f,  0.0f);	
			glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.1f,  1.1f,  0.0f);	
		glEnd();	

		glEnable(GL_DEPTH_TEST);
	glPopMatrix();
}

void putTransMaskImage(int image, float x, float y, float z, float blend) {
	glPushMatrix();
	

		glDisable(GL_DEPTH_TEST);
		
		glTranslatef(x,y,z);						

		glEnable(GL_BLEND);
			//glColor4f(1,1,1,blend);


			glBlendFunc(GL_SRC_COLOR,GL_ZERO);
			glBindTexture(GL_TEXTURE_2D, image);			
			/*
			glBegin(GL_QUADS);									
				glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.1f, -1.1f,  0.0f);	
				glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.1f, -1.1f,  0.0f);	
				glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.1f,  1.1f,  0.0f);	
				glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.1f,  1.1f,  0.0f);	
			glEnd();	
			*/

			glBlendFunc(GL_ONE, GL_ONE);
			glBindTexture(GL_TEXTURE_2D, image);	
			/*
			glBegin(GL_QUADS);									
				glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.1f, -1.1f,  0.0f);	
				glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.1f, -1.1f,  0.0f);	
				glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.1f,  1.1f,  0.0f);	
				glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.1f,  1.1f,  0.0f);	
			glEnd();	
			*/
		glDisable(GL_BLEND);

		glEnable(GL_DEPTH_TEST);

	glPopMatrix();
}

void putTransImage(int image, float x, float y, float z, float blend, char test) {
	glPushMatrix();

		if (!test) glDisable(GL_DEPTH_TEST);
		
		glTranslatef(x,y,z);						
		glColor4f(1.0f,1.0f,1.0f,blend);
		glBlendFunc(GL_SRC_ALPHA,GL_ONE);
		glEnable(GL_BLEND);
			glBindTexture(GL_TEXTURE_2D, image);	
			glBegin(GL_QUADS);									
				glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.1f, -1.1f,  0.0f);	
				glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.1f, -1.1f,  0.0f);	
				glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.1f,  1.1f,  0.0f);	
				glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.1f,  1.1f,  0.0f);	
			glEnd();	
		glDisable(GL_BLEND);

		//glBlendFunc(GL_ONE, GL_ONE);

		if (!test) glEnable(GL_DEPTH_TEST);
	glPopMatrix();
}

GLfloat xydist = 1.0f;
GLfloat zdist = 1.0f;
Vector  lookpoint = {0,0,0};
static GLfloat startz = 10;

extern int volatile row, pattern;

void intro(long starttime, long stoptime) {
	glLoadIdentity();	

	if (currentTime-starttime<4000) {
		startz=10.0f-((currentTime-starttime)*0.0025f);
	}
	if (4000+currentTime>stoptime) {
			startz=10.0f-(stoptime-currentTime)*0.0025f;
	}
	//if (startz>0) startz-=0.25;

	glPushMatrix();
	
	

	static GLfloat add = 0;
	
	//if (currentTime-starttime<10000) numrows = (currentTime-starttime)/1000;
	int static numrows = 1;

	switch (pattern) {
		case 6 :
			if (row>=8) { numrows=2; add=1; }
			if (row>=24) { numrows=3; add=0; }
			if (row>=40) { numrows=4; add=2; }
			if (row>=56) { numrows=5; add=1; }
			break;

		case 7 :
			if (row>=8) { numrows=6; add=2; }
			if (row>=24) { numrows=7; add=0; }
			if (row>=40) { numrows=8; add=1; }
			if (row>=56) { numrows=9; add=0; }
			break;

		case 8 :
			if (row>8) { numrows=10; add=2; }
			if (row>24) add=1;
			if (row>40) add=0;
			if (row>56) add=2;
			break;
		
		case 9 :
			if (row>8) add=0;
			if (row>24) add=1;
			if (row>40) add=0;
			if (row>56) add=2;
			break;
	};

	gluLookAt(10*cos((c/2)+add), 10, 10*sin((c)+add), 5*cos(c/3+PI), startz, 5*sin(c+PI), 0, 1, 0);
	
	GLfloat sub = numrows/2.0f;
	for (int x=0; x<numrows; x++)
		for (int y=0; y<numrows; y++)
			for (int z=0; z<numrows; z++) {
				GLfloat xf = x-sub;
				GLfloat yf = y-sub;
				GLfloat zf = z-sub;
				GLfloat sizef = 0.125+sin(c*5+x+y+z)*0.125;
				glPushMatrix();
					glTranslatef(xf, yf, zf);
					putBlueBox(sizef);
					makeLineBox(sizef*1.20, 0);
				glPopMatrix();
			}
	glPopMatrix();
}

void tunnel() {
//	glClear(GL_DEPTH_BUFFER_BIT);
	//glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);	
	glDisable(GL_MODULATE);
	glDisable(GL_BLEND);
//	GLdouble c = currentTime/500.0;

	glColor4f(1, 1, 1, 0.5);
	
//	GLfloat fogColor[4]={0.4, 0.03, 0.34, 0.1};
//	glClearColor(0.88, 0.47, 0.07, 0.5);
	glFogi(GL_FOG_MODE, GL_EXP);			// Fog Mode
	glFogfv(GL_FOG_COLOR, fogColor);					// Set Fog Color
	glFogf(GL_FOG_DENSITY, 0.05f);						// How Dense Will The Fog Be
	glHint(GL_FOG_HINT, GL_DONT_CARE);					// Fog Hint Value
	glFogf(GL_FOG_START, 0.0f);							// Fog Start Depth
	glFogf(GL_FOG_END, 10.0f);							// Fog End Depth
	glEnable(GL_FOG);									// Enables GL_FOG

	
//	glLoadIdentity();
	
	glPushMatrix();
		gluLookAt(1*sin(c/2), 1*cos(c/3), 110-(10*sin(c)+10), 
				3*sin(c/2+PI/2), 3*cos(c/3+PI/2), 25*sin(c/5+PI/2)+75, 
				0, 1, 0);

/*
		for (int j=0; j<100; j++) {
		}*/
		int q = 0;

		static long myLastTime = 0;
		

		for (int i=0; i<100; i++) {
			glPushMatrix();
				glTranslatef(0, 0, tunnelSpeed[i]);
				glRotatef(360*sin(c+i), 1, 1, 1.25);
				glScalef(0.25, 0.25, 0.25);
				putBlueBox(0.75);
				makeLineBox(1, 0);
				//addObject(tetraedeOrange);
				
				//putPurpleBox(0.25);
			glPopMatrix();
			//glPushMatrix();
				//glTranslatef(0, 0, tunnelSpeed[i]);
				//glTranslatef(sin(4*PI2/100.0*tunnelSpeed[i]), cos(4*PI2/100.0*tunnelSpeed[i]), tunnelSpeed[i]);
			//	putTransImage(FLARE, 1, -1, -10,0.75, 1);
				//putTransImage(FLARE, 1, -1, -10, 0.75, 1);

				//putTransImage(FLARE, -1, 1, -5, 0.75, 1);
				//putTransImage(FLARE, -1, 1, -5, 0.75, 1);

			//	putTransMaskImage(TEXTIMG, 0, 0, 0, 1);
			//glPopMatrix();

		

			if (q++==1) {
				q=0;
				glPushMatrix();
					//glRotatef(360*sin(c+(PI2/100.0*i)), 0, 0, 1.25);
					glTranslatef(0,0, tunnelSpeed[i]);
					putTransImage(FLARE, 1, 0, 0, 0.25, 1);
				glPopMatrix();

				glPushMatrix();
					//glRotatef(360*sin(c+(PI2/100.0*i)), 0, 0, 1.25);
					glTranslatef(0,0, tunnelSpeed[i]);
					putTransImage(FLARE, -1, 0, 0, 0.25, 1);
				glPopMatrix();
			}
			

			putTransMaskImage(TEXTIMG, 0, 0, 0, 1);
			glPushMatrix();
				glRotatef(360*sin(c+(PI2/100.0*i)), 0, 0, 1.25);
				glTranslatef(2*sin(4*PI2/100.0*tunnelSpeed[i]), 2*cos(4*PI2/100.0*tunnelSpeed[i]), tunnelSpeed[i]);
				

				glPushMatrix(); 
					glRotatef(c, 0, 1, 1.25);
					putPurpleBox(0.4);
				glPopMatrix();
				//putLineBox(0.5, 0);
			glPopMatrix();

			glPushMatrix();
				//glRotatef(c+(PI2/100.0*i), 0, 0, 1.25);
				glRotatef(360*sin(c+(PI2/100.0*i)), 0, 0, 1.25);
				glTranslatef(2*sin(4*PI2/100.0*tunnelSpeed[i]+PI), 2*cos(4*PI2/100.0*tunnelSpeed[i]+PI), tunnelSpeed[i]);
				glPushMatrix(); 
					glRotatef(c, 1, 1, 1);
					putPurpleBox(0.4);
				glPopMatrix();
			glPopMatrix();
//			tunnelSpeed[i]+=0.06;
			tunnelSpeed[i]+=(currentTime-myLastTime)/1000.0f;
			//if (tunnelSpeed[i]>100) tunnelSpeed[i]=10;
		}
		myLastTime = currentTime;
	glPopMatrix();

	glDisable(GL_FOG);
}

void kasser(GLfloat blend) {
	glLoadIdentity();

//	GLfloat fogColor[4] = {0.4, 0.03, 0.34, 0.1};
	
	glFogi(GL_FOG_MODE, GL_EXP);			// Fog Mode
	glFogfv(GL_FOG_COLOR, fogColor);					// Set Fog Color
	glFogf(GL_FOG_DENSITY, blend);
	glHint(GL_FOG_HINT, GL_DONT_CARE);					// Fog Hint Value
	glFogf(GL_FOG_START, 0.0f);							// Fog Start Depth
	glFogf(GL_FOG_END, 5.0f);							// Fog End Depth
	glEnable(GL_FOG);									// Enables GL_FOG

//	glColor4f(1, 1, 1, blend);
//	glBlendFunc(GL_SRC_ALPHA,GL_ONE);
//	glEnable(GL_BLEND);
	glPushMatrix();
		glColor4f(1.0f,1.0f,1.0f,1);
		gluLookAt(5*sin(c), 5*cos(c), 0, 
				  0, 0, 5, 
				  0, 1, 0);
		
		for (int i=0; i<NUMBOXES; i++) {
			GLfloat rot = (GLfloat)(90.0f/NUMBOXES)*i;
			GLfloat size = 1+1*sin((PI/NUMBOXES*boxes[i])+c);

			glPushMatrix();
				glRotatef(rot, 0, 0, 1);
				glTranslatef(-size, 0, boxes[i]);
				putWhiteBox(size/2);
			glPopMatrix();

			glPushMatrix();
				glRotatef(rot, 0, 0, 1);
				glTranslatef(size, 0, boxes[i]);
				putWhiteBox(size/2);
			glPopMatrix();
		
			glPushMatrix();
				glRotatef(rot, 0, 0, 1);
				glTranslatef(0, size, boxes[i]);
				putWhiteBox(size/2);
			glPopMatrix();
			
			glPushMatrix();
				glRotatef(rot, 0, 0, 1);
				glTranslatef(0, -size, boxes[i]);
				putWhiteBox(size/2);
			glPopMatrix();
			
			boxes[i]+=0.1;
			if (boxes[i]>NUMBOXES) boxes[i]=0;
		}	
	glPopMatrix();

	glDisable(GL_FOG);
}


void rek_tree(GLfloat angle, int level, GLfloat add) {
	if (level>0) {
		glPushMatrix();
			glTranslatef(0, 2, 0);
			
			
			glPushMatrix();
				glRotatef(angle+add, 1, 0, 1);
				rek_tree(angle+add, level-1, add);
			glPopMatrix();
			
			glPushMatrix();
				glRotatef(angle-add, 0, 1, 1);
				rek_tree(angle-add, level-1, add);
			glPopMatrix();

			//addObject(tetraedeOrange);
			putBlueBox(1);
		glPopMatrix();
	}
}

void threedeetree() {
	glLoadIdentity();

	glPushMatrix();
		gluLookAt(20*sin(c), 10*sin(c*2), 10, 
				  0, 10, 0, 
				  0, 1, 0);

		glColor4f(1.0f,1.0f,1.0f,0.15f);
		glBlendFunc(GL_DST_ALPHA,GL_ONE);
		glEnable(GL_BLEND);

		rek_tree(45*cos(c*2)+46, 7+sin(c/3)*2.5, 45*sin(c/2)+90);

		glDisable(GL_BLEND);
	glPopMatrix();
}




static GLfloat hoveder_trans = 0.25;
static GLfloat bag_tekst = 5;
static test = 0;
long lastTime = 0;




void vortexeffect(Object *o, float rot) {
	int count=0;
    int phix2,phiy2,phiz2,twirl;
    int phix3,phiy3,phiz3;
	float vx,vy,vz,px,py,pz;

	phix2=(int)(70*rot)&1023;
    phiy2=(int)(60*rot)&1023;
	phiz2=(int)(100*rot)&1023;
	for (count=0; count<(int)(o->numverts); count++) {
      //twirl=(pointsdist[i]+pos)/4;
		px=o->vertices[count].x;
		py=o->vertices[count].y;
		pz=o->vertices[count].z;
		twirl=sintab[(int)(sqrt(px*px+py*py+pz*pz)*50.5+rot*1000)&1023]*100;
		phix3=(phix2+twirl)&1023;
		phiy3=(phiy2+twirl)&1023;
		phiz3=(phiz2+twirl)&1023;
		vx=(costab[phiy3]*px-sintab[phiy3]*pz);
		vy=(costab[phiz3]*py-sintab[phiz3]*vx);
		vz=(costab[phiy3]*pz+sintab[phiy3]*px);
		o->vertices[count].x=(costab[phiz3]*vx+sintab[phiz3]*py);
		o->vertices[count].y=(costab[phix3]*vy+sintab[phix3]*vz);
		o->vertices[count].z=(costab[phix3]*vz-sintab[phix3]*vy);
	}
}


void visKnuden(float add, float muller) {
	glLoadIdentity();	

	
	reCalcKnot(20, 100, 10*sin(c)+12, 4*cos(c)+5, (2*sin(c*2)+3)*muller, knude);
	//memcpy(knude->vertices, knude2->vertices, sizeof(Vector)*knude->numverts);
	
	vortexeffect(knude, c);
	
	

	glPushMatrix();
		gluLookAt((40+add)*sin(c/3), (40+add)*cos(c/3), 20, 0, 0, 0, 0, 1, 0);
	//gluLookAt(20*cos(c/2), 20, 20*sin(c), 1, 1, 1, 0, 1, 0);

		for (int i=0; i<100; i++) {
			glPushMatrix();
				glRotatef(360.0/20.0*(i-c*10), 1, 1, 1);
				glPushMatrix();
					glTranslatef(12*sin(PI2/10.0*i), 12*cos(PI2/10.0*i),  12*sin(PI2/10.0*i));
					glRotatef(360.0/20.0*(i-c*10), 1, 1, 1);
					addObject(tetraedeOrange);
				glPopMatrix();
			glPopMatrix();
		}

	
	addObject(knude);
	glPopMatrix();


}



int mainloop() {
	c = currentTime/1500.0;
	//glClearColor(0, 0, 0, 0.5);
	glClearColor(fogColor[0], fogColor[1], fogColor[2], fogColor[3]);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glColor4f(fogColor[0], fogColor[1], fogColor[2], fogColor[3]);


	

	if (currentTime>20000) {
		if (currentTime<24000) {
			bag_tekst = (currentTime-20000)*(-0.001625)+5.0f;
			//if (bag_tekst>-1.5) bag_tekst-=0.15;
		} else bag_tekst=-1.5f;

		putTransMaskImage(TEXTIMG, 0.25*sin(c/3), 0.25*sin(c), bag_tekst+0.5*cos(c/3), 1);
	}

	if (currentTime>30000 && currentTime<56000) intro(30000, 56000); // intro sekvens

	if (currentTime>52000 && currentTime<75000) {
		/*
		putTransImage(CIRKEL, 1, 1, -3, 0.5);
		for (int k=0; k<100; k++) {
			GLfloat pos = (PI2/10.0*k)+c;
			GLfloat x = sin(pos)*5;
			GLfloat y = cos(pos)*6;
			putTransImage(CIRKEL2, x+4, y+4, -15, 0.25);
		}
		
		putTransMaskImage(TEXTIMG, 0.25*sin(c/3), 0.25*sin(c), bag_tekst+0.5*cos(c/3), 1);
		*/

		//glClear(GL_DEPTH_BUFFER_BIT);
		
		GLfloat temp = 1;
	
		if (currentTime<54000) temp = 1.0f-((54000-currentTime)/2000.0);
		if (currentTime>73000) temp = (75000-currentTime)/2000.0;

		
		for (int i=0; i<10; i++) {
			putTransImage(CIRKEL2, 5+cirkelposx[i]*2, cirkelposy[i]*10, -20*(cirkelposx[i]*cirkelposx[i]), temp, 0);
			putTransImage(CIRKEL2, 5+cirkelposx[i]*2, cirkelposy[9-i]*12, -25, temp, 0);
			putTransImage(CIRKEL2, 2+cirkelposx[9-i]*2, cirkelposy[9-i]*12, -15, temp, 0);
			cirkelposy[i]-=(currentTime-lastTime)/2000.0f;
			if (cirkelposy[i]<-1.0) cirkelposy[i]+=2;
		}
		lastTime = currentTime;
		putTransMaskImage(TEXTIMG, 0.25*sin(c/3), 0.25*sin(c), bag_tekst+0.5*cos(c/3), 1);
		tunnel();

	}



	if (currentTime>74000 && currentTime<92000) {
		GLfloat temp = 1;
	
		if (currentTime<76000) temp = 1.0f-((76000-currentTime)/2000.0);
		if (currentTime>90000) temp = (92000-currentTime)/2000.0;

		for (int i=0; i<10; i++) {
			putTransImage(CIRKEL2, cirkelposy[i]*10, cirkelposx[i]*2, -20*(cirkelposx[i]*cirkelposx[i]), temp, 0);
			putTransImage(CIRKEL2, cirkelposy[i]*10, cirkelposx[9-i]*2, -25, temp, 0);
			putTransImage(CIRKEL2, cirkelposy[9-i]*10, cirkelposx[9-i]*2, -15, temp, 0);
			cirkelposy[i]-=(currentTime-lastTime)/2000.0f;
			if (cirkelposy[i]<-1.0) cirkelposy[i]+=2;
		}
		lastTime = currentTime;
		
		putTransMaskImage(TEXTIMG, 0.25*sin(c/3), 0.25*sin(c), bag_tekst+0.5*cos(c/3), 1);
		threedeetree();

	}

	if (currentTime>98000 && currentTime<119000) {
		GLfloat p = 0.5*sin((currentTime-92000)/500.0)+0.5;
		putTransImage(GREETS, -0.5, 0, -5, p, 0);
		putTransImage(GREETS2,  1.5, 0, -5, 1-p, 0);
	}


	if (currentTime>138000) {
		GLfloat kassefloat = 0.3f;

		if (currentTime>148000 && currentTime<151000) {
			kassefloat += sin(PI/3000.0f*(151000-currentTime));
		}

		if (currentTime>160000 && currentTime<162000) {
			kassefloat += sin(PI/2000.0f*(162000-currentTime));
		}

		if (currentTime>170000 && currentTime<181000) {
			kassefloat += sin((PID2/11000.0f*(181000-currentTime))+PID2);
		}

		if (currentTime<181000) kasser(kassefloat);

		if (currentTime>140000) {
			GLfloat a = fabs(sin(c));
			GLfloat b = fabs(cos(c));
		
			if (currentTime<142000) hoveder_trans=1.0f-(142000.0f-currentTime)/1000.0f;
			else hoveder_trans = 1;

			putTransImage(GROUPS1, 0.25, -.75, -5+a, a*hoveder_trans, 0);
			putTransImage(GROUPS2, 0.8, -1, -5+a,    b*hoveder_trans, 0);

			glPushMatrix();
				putTransImage(SLIDER1, -4, 0, -20+8*sin(c+1), hoveder_trans, 0);
				putTransImage(SLIDER2, -2, 0, -20+8*sin(c+2), hoveder_trans, 0);
				putTransImage(SLIDER3, 0, 0, -20+8*sin(c+3), hoveder_trans, 0);
				putTransImage(SLIDER4, 2, 0, -20+8*sin(c+4), hoveder_trans, 0);
				putTransImage(SLIDER5, 4, 0, -20+8*sin(c+5), hoveder_trans, 0);
			glPopMatrix();
		}
		
	}

	static GLfloat add = -5;
	if (currentTime>118000 && currentTime<138000) {
		putTransMaskImage(TEXTIMG, 0.25*sin(c/3), 0.25*sin(c), bag_tekst+0.5*cos(c/3), 1);
		GLfloat muller = 1;
		if (currentTime<120000) {
			muller = 1.0f-((120000-currentTime)/2000.0f);
		}

		if (currentTime-test>500) {
			add=-5;
			test=currentTime;
		} 
			
			
		add+=(currentTime-lastTime)/150.0f;

		static GLfloat dist = -5;
		switch (pattern) {
			case 22:
				if (row>=8) dist=-10;
				if (row>=24) dist=-5;
				if (row>=40) dist=-10;
				if (row>=56) dist=-5;
				break;

			case 23:
				if (row>=8) dist=-10;
				if (row>=24) dist=-5;
				if (row>=40) dist=-10;
				if (row>=56) dist=-5;
				break;

			case 24:
				if (row>=8) dist=-10;
				if (row>=24) dist=-5;
				if (row>=40) dist=-10;
				break;

			case 25 :
				if (row>=8) dist=-5;
				if (row>=24) dist=-10;
				if (row>=40) dist=-5;
				if (row>=56) dist=-10;
				break;
		};
		
		visKnuden(dist, muller);
		GLfloat p = 0.5*sin((currentTime-92000)/500.0)+0.5;
		glPushMatrix();
			glRotatef(360*sin(c), 0, 0, 1.5);
			putTransImage(SLIDER3, 0, -1.5, 10*add+1, 1-p, 0);
			putTransImage(SLIDER1, -1.5, 0, 10*add+1, 1-p, 0);
			putTransImage(SLIDER2, 1.5, 0, 10*add+1, p, 0);
			putTransImage(SLIDER4, 0, 1.5, 10*add+1, p, 0);
		glPopMatrix();

		GLfloat temp = 1.0f;		
		for (int i=0; i<10; i++) {
			putTransImage(CIRKEL2, cirkelposy[i]*10, cirkelposy[i]*10, -20-add, temp, 0);
			putTransImage(CIRKEL2, cirkelposy[i]*12, cirkelposy[9-i]*12, -25-add, temp, 0);
			putTransImage(CIRKEL2, cirkelposy[9-i]*12, cirkelposy[9-i]*12, -15-add, temp, 0);
			cirkelposy[i]-=(currentTime-lastTime)/2000.0f;
			if (cirkelposy[i]<-1.0) cirkelposy[i]+=2;
		}
		lastTime = currentTime;
	}
	if (currentTime>138000 && currentTime<140000) {
		add--;
		//dims((add+=0.25)*2);
		visKnuden((138000-currentTime)/10.0f,1);
		/*
		GLfloat p = 0.5*sin((currentTime-92000)/500.0)+0.5;
		glPushMatrix();
			glRotatef(360*sin(c), 0, 0, 1);
			putTransImage(GREETS, 0, 0, add+1, p, 0);
		glPopMatrix();
		*/
	}


	//visKnuden();

	if (currentTime<4000) { // fade hoveder ind
		hoveder_trans = currentTime/6000.0f;
	}

	if (currentTime>30000 && currentTime<34000) { // fade hoveder ud
		hoveder_trans = (34000-currentTime)/6000.0f;
	}
	
	if (currentTime>37000 && currentTime<39000) {
		hoveder_trans = sin(PI/2000.0f*(39000-currentTime))*0.5;
	}

	if (currentTime>90000 && currentTime<94000) {
		hoveder_trans = (currentTime-90000)/6000.0f;
	}
	
	if (currentTime>117000 && currentTime<121000) {
		hoveder_trans = (121000-currentTime)/6000.0f;
	}
	
	if (currentTime<39000 || (currentTime>90000 && currentTime<119000)) { // tegn hoveder
		for (int i=0; i<10; i++) {
			glPushMatrix();
				putTransImage(SLIDER1, 2*cos(c+i), 15+(-i*3), -20+5*sin(c+i), hoveder_trans, 0);
				putTransImage(SLIDER2, 5*cos(c+i), 15+(-i*3), -20+6*sin(c+i), hoveder_trans, 0);
				putTransImage(SLIDER3, 6*cos(c+i), 15+(-i*3), -20+7*sin(c+i), hoveder_trans, 0);
				putTransImage(SLIDER4, 8*cos(c+i), 15+(-i*3), -20+8*sin(c+i), hoveder_trans, 0);
				putTransImage(SLIDER5, 10*cos(c+i), 15+(-i*3), -20+9*sin(c+i), hoveder_trans, 0);
			glPopMatrix();
		}
	}

	if (currentTime>53000 && currentTime<53400) {
		GLfloat p = 1.0f-((currentTime-53000)/400.0f);
		putTransImage(SLIDER2, 0, 0, -2-p*5, p, 0);
	}

	if (currentTime>53400 && currentTime<53800) {
		GLfloat p = 1.0f-((currentTime-53400)/400.0f);
		putTransImage(SLIDER3, 0, 0, -2-p*5, p, 0);
	}

	if (currentTime>53800 && currentTime<54200) {
		GLfloat p = 1.0f-((currentTime-53800)/400.0f);
		putTransImage(SLIDER4, 0, 0, -2-p*5, p, 0);
	}

	if (currentTime>68000 && currentTime<68400) {
		GLfloat p = 1.0f-((currentTime-68000)/400.0f);
		putTransImage(SLIDER3, 0, 0, -2-p*5, p, 0);
	}


	if (currentTime>20000 && currentTime<30000) { // credits
		if (currentTime<25000) {
			GLfloat p = (currentTime-20000.0f);
			putTransImage(MACAW, 0, 0, -(currentTime-20000.0f)/500.0f, sin(PI/5000.0f*p), 0);
		}
		if (currentTime>25000) {
			GLfloat p = (currentTime-25000.0f);
			putTransImage(PRAT, 0, 0, -(currentTime-25000.0f)/500.0f, sin(PI/5000.0f*p), 0);
		}
	}

	
	putTransImage(TITLE, 1.6, -2.85, -5, 0.25*sin(c)+0.5, 0);

	return 1;
}
