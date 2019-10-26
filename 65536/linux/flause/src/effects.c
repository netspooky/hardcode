#include <GL/glut.h>
#include <math.h> /* sin, cos 2*M_PI */
#include <string.h>
#include <stdlib.h>
#include <math.h>
#ifndef CHEAP
#include <stdio.h>
#endif
#include "demo.h"
#include "effects.h"
#include "scenes.h"
#include "fbfont.h" /* fb font sak */
#include "demo.h"

extern GLuint font;
void worm(void);
int fac(int n);
int bin(int n, int k);
extern void anim_scene_init(void);

void print(const char *string,double size) {

	int i;
	
	if(!string) return;
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glDisable(GL_LIGHTING);
	glColor4f(1,1,1,1);
	glBlendFunc(GL_ONE, GL_ONE);
	for(i = 0; i < strlen(string); i++) {
		
		glBindTexture(GL_TEXTURE_2D, letters[string[i]-'a']);
	
		if (string[i] != ' ') {
			glBegin(GL_POLYGON);
				glTexCoord2f(0, 1);
				glVertex2f(i*13.0*size, 0);
				glTexCoord2f(1, 1);
				glVertex2f(i*13.0*size+13.0*size, 0);
				glTexCoord2f(1, 0);
				glVertex2f(i*13.0*size+13.0*size, 16*size);
				glTexCoord2f(0, 0);
				glVertex2f(i*13.0*size, 16*size);
			glEnd();
		}
	}
	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_LIGHTING);
	
}

void scrollprint(const char *string, int startpos) {
	if(!string) return;
	if(strlen(string) < startpos)
		return;
	print(&string[startpos],1);
}

/*
void fade(int millisecs, GLclampf red, GLclampf green, GLclampf blue) {
	static double end_time;

	if (!end_time)
		end_time = demo.time + millisecs / 1000.0;
	
	if (demo.time < end_time) {
		printf("vi fader\n");
	}
		
}
*/


/*
 * 17:13 < Sirkel> [sin(vinkel), cos(vinkel) * cos(vinkel2), cos(vinkel2) * sin(vinkel2)] for kule
 * 17:16 < Sirkel> plante: for(size_t i = 0; i < slice_count; i++) { double vinkel = i * M_2_PI / slice_count; ... } 
 *                 er forresten bedre
 */
/*
void sphere(int slice_count) {
	int i, j;
	double angle1, angle2, radius = 1;
	float x,y,z;

	for (i = 0; i < slice_count; i++) {
		angle1 = (i * 2*M_PI) / slice_count;
		for (j = 0; j < (slice_count - (i - i/2)); j++) {
			angle2 = (j * 2*M_PI) / (slice_count - (i - i/2));
			if (j%2)
				radius = log((10-demo.time)/10);
			else
				radius = 1;
			x = radius*sin(angle1);
			y = radius*cos(angle1) * cos(angle2);
			z = radius*cos(angle2) * sin(angle2);
			glLoadIdentity();
			glMatrixMode(GL_MODELVIEW);
			glTranslatef(0,0,-3);
			glRotated(demo.time*10,0,1,0);
			glTranslatef(x,y,z);
			glutSolidSphere(0.1,3,3);
		}
	}
}
*/
void flying_planes() {
//	double x, y;

/*	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	    
#define W 0.9
	for (x = -W; x < W; x+=0.05) {
		for (y = -W; y < W; y+=0.2) {
			glLoadIdentity();
			glMatrixMode(GL_MODELVIEW);
			glTranslatef(x+sin(demo.time),(y),-1);
			glBegin(GL_QUADS);
			  glColor4f(1.0f,0.0f,0.0f,0.3);
			  glVertex3f( 0.0f, 0.1f, 0.0f);
			  glVertex3f( 0.1f, 0.1f, 0.0f);
			  glVertex3f( 0.1f, 0.0f, -1.0f);
			  glVertex3f( 0.0f, 0.0f, -1.0f);
			glEnd();
		}
		for (y = -W; y < W; y+=0.2) {
			glLoadIdentity();
			glMatrixMode(GL_MODELVIEW);
			glTranslatef(x-sin(demo.time),(y),-1);
			glBegin(GL_QUADS);
			  glColor4f(0.0f,1.0f,0.3f,0.3);
			  glVertex3f( 0.0f, 0.1f, -1.0f);
			  glVertex3f( 0.1f, 0.1f, -1.0f);
			  glVertex3f( 0.1f, 0.0f, 0.0f);
			  glVertex3f( 0.0f, 0.0f, 0.0f);
			glEnd();
		}
	}*/
	if(demo.time > 0.5) fn_replace(&flying_planes, &anim_scene_init);
}

void anim_firkant(float x, float y, float frax, float fray, float tilx, float tily, float fratid, float tiltid) {
	float xfaktor, yfaktor, flyttetid, flyttetx, flyttety;
	flyttetid = tiltid - fratid;
	xfaktor = (tilx - frax) / flyttetid;
	yfaktor = (tily - fray) / flyttetid;
	flyttetx = xfaktor * (demo.time - fratid);
	flyttety = yfaktor * (demo.time - fratid);
	if(demo.time < fratid)
		glRectf(frax, fray, frax+x, fray+y);
	else if(demo.time > fratid && demo.time < tiltid)
		glRectf(frax+flyttetx, fray+flyttety, frax+x+flyttetx, fray+y+flyttety);
	else
		glRectf(tilx, tily, tilx+x, tily+y);
}


void worm() {
/*	static float z[640][480]; */
	static char not_init;

	if (not_init) {
		
		
		not_init = 1;
	}
	
}

/* SKRIIIIK!
 * optimiser meg!
 */

/*
 * Factorial
 * 
 * n! = 1 * 2 * 3 * ... * (n - 1) * n
 *
 */
int fac(int n) {
	int ret = n;
	if (n > 1)
		while (--n)
			ret *= n;
	else
		return 1;
#ifdef DEBUG
/*	printf("fac(%d) = %d\n",n,ret); */
#endif
	return ret;
}

/* 
 * Binomial
 *
 * / n \         n!
 * |   |  = ------------
 * \ k /     k!(n - k)!
 *
 */
int bin(int n, int k) {
#ifdef DEBUG
/*	printf("bin(n = %d, k = %d) = %d\n",n,k,
		fac(k) / (fac(n) * fac(k-n))); */
#endif
	return fac(k) / (fac(n) * fac(k-n));
}

/* 
 * Bezier
 * 
 * n+1 points
 *            n     /   \ 
 *          \----\  | n | /       \ n - k  k
 * P(t) =    \      |   | | 1 - t |       t  P
 *           /      | k | \       /           k
 *          /----/  \   /
 *            k=0
 */
double bezier(double t, double pointv, int point, int points) {
#ifdef DEBUG
	printf("bezier(t = %f, v = %f, p = %d, pn = %d) = %f\n",t,pointv,point,points,
			bin(point,points)*pow(1 - t,point - points)*pow(t,point)*pointv);
#endif
	return bin(point,points)*pow(1 - t,point - points)*pow(t,point)*pointv;
}

/* fscked! */


enum {
	RED,
	GREEN,
	BLUE
};

#include "jpeg.h"
/*
 * high n = few stars
 */
image_t *generate_star_field(int x,int y,int n) {
#define COLORS 3
	int i;
	image_t *img;
	unsigned char *field;
#ifndef CHEAP
	printf("generate_star_field(%d,%d)\n",x,y);
#endif
	img = (image_t*)malloc(sizeof(image_t));
	field = img->data = malloc(x * y * COLORS * sizeof(char));
	img->width = x;
	img->height = y;
	
	
	if (!img->data)
		return NULL;

	srand(3240970714ul);
	for (i = 0; i < x*y*COLORS; i += COLORS) {
		field[i+RED] = field[i+GREEN] = field[i+BLUE] = (unsigned char)(255*pow(((double)rand()/RAND_MAX),n));
	}
#ifndef CHEAP
	printf("generate_star_field done\n");
#endif
//	img = read_jpeg(FONT_DATA, FONT_LEN);
	return img;
}

image_t *generate_rand_tex(int x,int y) {
#define COLORS 3
	int i;
	enum {
		RED,
		GREEN,
		BLUE
	};
	image_t *img;
	unsigned char *field;
#ifndef CHEAP
	printf("generate_rand_tex(%d,%d)\n",x,y);
#endif
	img = (image_t*)malloc(sizeof(image_t));
	field = img->data = malloc(x * y * COLORS * sizeof(char));
	img->width = x;
	img->height = y;
	
	
	if (!img->data)
		return NULL;

	srand(3240970714ul);
	for (i = 0; i < x*y*COLORS; i += COLORS) {
		field[i+BLUE] = field[i+RED] = field[i+GREEN] = 153 + (unsigned char)(60*((double)rand()/RAND_MAX));
	}
#ifndef CHEAP
	printf("generate_rand_tex done\n");
#endif
	return img;
}

image_t *bw_to_rgb(char* data) {
	int i,bit,j = 0;
	unsigned char *rgb;
	image_t *img;
	img = (image_t *)malloc(sizeof(image_t));
	img->height = img->width = 8;
	img->data = rgb = calloc(3*img->height*img->width,sizeof(char));
//	j += img->width;
	for  (i = 0; i < 8; i++) {
//		j++;
		for (bit = 128; bit >= 1; bit /= 2) {
			rgb[j+RED] = rgb[j+GREEN] = rgb[j+BLUE] = (data[i] & bit) ? 255 : 0;
#ifdef DEBUG
			if (rgb[j])
				printf("#");
			else
				printf(" ");
#endif
			j+=3;
		}
#ifdef DEBUG
		printf("|\n");
#endif
	}
#ifdef DEBUG
	printf("-\n");
#endif
	return img;
}	

GLuint *make_font_textures() {
	GLuint *tex_arr;
	int i;

	tex_arr = (GLuint *)malloc(sizeof(GLuint)*'z');

	for (i = 'a'; i <= 'z';i++)
		tex_arr[i-'a'] = texture_upload( bw_to_rgb( fbfont[i-'a']),GL_CLAMP);

	return tex_arr;
}

image_t *generate_particle_tex(int x,int y) {
#define COLORS 3
	int i,xv,yv;
	image_t *img;
	unsigned char *field;
#ifndef CHEAP
	printf("generate_particle_tex(%d,%d)\n",x,y);
#endif
	img = (image_t*)malloc(sizeof(image_t));
	field = img->data = malloc(x * y * COLORS * sizeof(char));
	img->width = x;
	img->height = y;
	
	
	if (!img->data)
		return NULL;

	for (i = 0; i < x*y*COLORS; i += COLORS) {
		yv = (i/3) / x;
		xv = (i/3) - yv*x;
		field[i+RED] = field[i+GREEN] = field[i+BLUE] = 255*pow((sin(M_PI*(double)xv/x) + sin(M_PI*(double)yv/y)) * 0.5, 9);
	}
#ifndef CHEAP
	printf("generate_particle_tex done\n");
#endif
	return img;
}

#if 0
void tunnel() {
	double x[2],y[2],z[2], t, a;
	double nx[2],ny[2];

#define slices 16
#define parts 8
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glTranslatef(0,0,-10);
	glRotated(10*demo.time,1,0,0);
	for (t = 0; t < 2*M_PI; t += M_PI/slices) {
		z[0] = sin(t)*3;
		z[1] = sin(t+M_PI/slices)*3;
		for (a = 0; a < 2*M_PI; a += M_PI/parts) {
			x[0] = sin(a)+cos(t)*3;
			y[0] = cos(a);
			x[1] = sin(a+M_PI/parts)+cos(t+M_PI/slices)*3;
			y[1] = cos(a+M_PI/parts);
/*
ny x = cos(vinkel)*gammel x + sin(vinkel) * gammel y
ny y = cos(vinkel)*gammel y - sin(vinkel) * gammel x
*/			
			nx[0] = cos(a)*x[0] + sin(a) * y[0];
			nx[1] = cos(a)*x[1] + sin(a) * y[1];
			ny[0] = cos(a)*y[0] - sin(a) * x[0];
			ny[1] = cos(a)*y[1] - sin(a) * x[1];
			
			partikkel(nx[0],ny[0],z[0],1);

			glColor3f(1,0,1);
			glPushMatrix();
			glBegin(GL_LINE_STRIP);
			glVertex3f(nx[0],ny[0],z[0]);
			glVertex3f(nx[1],ny[1],z[0]);
			glVertex3f(nx[1],ny[1],z[1]);
			glVertex3f(nx[0],ny[0],z[1]);
			glVertex3f(nx[0],ny[0],z[0]);
			glEnd();
			glPopMatrix();
		}
	}
}

#endif
int texture_upload(image_t *image,int repeat) {
	int texid;
	glEnable(GL_TEXTURE_2D);
	glGenTextures(1, &texid);
	glBindTexture(GL_TEXTURE_2D, texid);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, repeat);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, repeat);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, image->width, image->height, 0, GL_RGB, GL_UNSIGNED_BYTE, image->data);
	glDisable(GL_TEXTURE_2D);
	return texid;
}	

static GLuint particle_tex;
void partikkel_init() {
#ifndef CHEAP
	printf("partikkel_init\n");
#endif
	particle_tex = texture_upload(generate_particle_tex(32,32),GL_CLAMP);
}

void partikkel(double x, double y,double z, double size) {
	double direction[3];
	static double up[3];
	static double right[3];
	static double last_time;
	double len;

	/*
	demo.cam[Z] = cos(demo.time)*20;
	demo.cam[X] = sin(demo.time)*20;
	*/
	/*
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	*/
	/*
	gluLookAt(demo.cam[X],demo.cam[Y],demo.cam[Z], 0,0,0, 0,1,0);
*/
//	glPushMatrix();
	/*
	glPushMatrix();
	glTranslatef(x,y,z);
	glutSolidSphere(0.1,10,10);
	glPopMatrix();
	glTranslatef(x,y,z);
	glutSolidSphere(0.1,10,10);
	glPopMatrix();
	*/
	glPushMatrix();
	
	if (demo.time != last_time) {
		direction[X] = demo.cam[X] - x;
		direction[Y] = demo.cam[Y] - y;
		direction[Z] = demo.cam[Z] - z;

		/*norm*/
		len = sqrt(pow(direction[X],2) + pow(direction[Y],2) + pow(direction[Z],2));
		direction[X] /= len;
		direction[Y] /= len;
		direction[Z] /= len;

		up[X] = 0;
		up[Y] = direction[Z];
		up[Z] = direction[Y];

		/*norm*/
		len = sqrt(pow(up[Y],2) + pow(up[Z],2));
		up[Y] /= len;
		up[Z] /= len;
	
		/* kryss */
		right[X] = up[Y] * direction[Z] - direction[Y] * up[Z];
		right[Y] = up[Z] * direction[X] - direction[Z] * up[X];
		right[Z] = up[X] * direction[Y] - direction[X] * up[Y];

		right[X] *= size;
		right[Y] *= size;
		right[Z] *= size;
		
		up[X] *= size;
		up[Y] *= size;
		up[Z] *= size;

		last_time = demo.time;
	}

	glDisable(GL_LIGHTING);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D,particle_tex);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE,GL_ONE);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	

	glBegin(GL_QUADS);

	glTexCoord2f(0.0, 0.0);
	glVertex3f( x+up[X]+right[X], y+up[Y]+right[Y], z+up[Z]+right[Z]);

	glTexCoord2f(0.0, 1.0);
	glVertex3f( x-up[X]+right[X], y-up[Y]+right[Y], z-up[Z]+right[Z]);
	
	glTexCoord2f(1.0, 1.0);
	glVertex3f( x-up[X]-right[X], y-up[Y]-right[Y], z-up[Z]-right[Z]);

	glTexCoord2f(1.0, 0.0);
	glVertex3f( x+up[X]-right[X], y+up[Y]-right[Y], z+up[Z]-right[Z]);

	glEnd();
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_LIGHTING);
	glPopMatrix();
}
