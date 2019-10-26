#ifndef CHEAP
#include <stdio.h>
#endif
#include <GL/glut.h>
#include <stdlib.h>
#include <math.h>

#include "demo.h"
#include "scenes.h"
#include "effects.h"
#include "opengl.h"
#include "tekst.h"
#include "jpeg.h"
#include "gakk.h"
#include "kykkeli.h"

#if 0
void scene_countdown(void);
void scene_test(void);
void scene_basic(void);
void scene_bezier(void);
void scene_bezier_init(void);
#endif
void anim_scene(void);
void anim_scene2(void);
void anim_scene_init(void);
void scene_outro(void);
void scene_outro_init(void);
void scene_partikkel(void);
void anim_firkant(float x, float y, float frax, float fray, float tilx, float tily, float fratid, float tiltid);
void si_hei(void);
void star_bg(void);
void asteroid(void);
void kylling1(void);
void kylling2(void);
void kykkeliky(void);
void blod(void);

void CALLBACK moire_callback(GLenum errorCode);

#ifndef CHEAP
static int frames = 0;
#endif

double scene_start;

extern void FSOUND_Software_OutputThread(void);

static GLuint star_tex;
static GLuint rand_tex;
static GLuint kykkeli_tex;
static GLuint gakk_tex;

extern void scenes_init() {
#ifndef CHEAP
	printf("scene_init\n");
#endif

	star_tex = texture_upload(generate_star_field(256,256,200),GL_REPEAT);
	rand_tex = texture_upload(generate_rand_tex(256,256),GL_REPEAT);
	kykkeli_tex = texture_upload(read_jpeg(kykkeli_DATA, kykkeli_LEN),GL_CLAMP);
	gakk_tex = texture_upload(read_jpeg(gakk_DATA, gakk_LEN),GL_CLAMP);
	
	demo.cam[X] = 0;
	demo.cam[Y] = 0;
	demo.cam[Z] = 15;
	fn_add(&pre_scene);
	fn_add(&star_bg);
	fn_add(&flying_planes);
	fn_add(&asteroid); 
	
	scene_start=0;
}

#if 0
void scene_countdown() {
	double end_time = scene_start + 2.7;

	flying_planes();

	if (demo.time > end_time) {
		scene_start = end_time;
/*		demo_timer_sync();
		fn_replace(&scene_countdown,&anim_scene_init); */
		fn_replace(&scene_countdown,&scene_basic);
	}
}

void scene_basic() {
	double end_time = scene_start + 4;

	glTranslatef(-1.5f,0.0f,-6.0f);
	glRotated(demo.time*45, 0, 1, 0);
	glMatrixMode(GL_MODELVIEW);
	
	glBegin(GL_POLYGON); {
		glVertex3f( 0.0f, 1.0f, 0.0f);
		glVertex3f( 1.0f,-1.0f, 0.0f);
		glVertex3f(-1.0f,-1.0f, 0.0f);
	} glEnd();
	glBegin(GL_POLYGON); {
		glColor3f(1.0f,0.0f,0.0f);
		glVertex3f( 0.0f, 1.0f, 1.0f);
		glColor3f(0.0f,1.0f,0.0f);
		glVertex3f( 1.0f, 1.0f, 1.0f);
		glColor3f(0.0f,0.0f,1.0f);
		glVertex3f( 1.0f, 0.0f, 1.0f);
		glColor3f(1.0f,1.0f,1.0f);
		glVertex3f( 0.0f, 0.0f, 0.5f);
	} glEnd();

#ifndef CHEAP
	frames++;
#endif

	if (demo.time > end_time) {
/*		demo_timer_sync(); */
#ifndef CHEAP
		printf("scene_basic done; time %f, fps: %f\n",demo.time - scene_start,frames/(demo.time - scene_start));
		frames = 0;
#endif
		scene_start = demo.time;
		fn_replace(&scene_basic, &scene_test);
	}
}
#endif
void scene_partikkel(void) {
	int i;
	static double slutttid;
	double t = demo.time*2*M_PI;
	enum {
		moons = 5,
		depth = -10
	};

	if (!slutttid) {
		slutttid = demo.time + 5;
	}


	glDisable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	glPushMatrix();
		glTranslatef(0,0,depth);
		glutSolidSphere(0.3,15,15);
	glPopMatrix();

	glDepthMask(GL_FALSE);
	/* virker f.o.m. neste frame */
	demo.cam[X] = 0;
	demo.cam[Y] = 0;// sin(demo.time);
	demo.cam[Z] = 15; // demo.time-slutttid + 10; 
	glColor3f(0.3,0.3,0.8);
	for (i = 0; i < moons; i++) {
		glColor3f(0.3,0.8,0.3);
		partikkel(
				sin(t + 2*M_PI/moons*i),
				0,
				cos(t + 2*M_PI/moons*i) + depth,
				1);
		partikkel(
				0,
				cos(t + 2*M_PI/moons*i),
				-sin(t + 2*M_PI/moons*i) + depth,
				1);
		partikkel(
				0,
				-sin(t + 2*M_PI/moons*i),
				cos(t + 2*M_PI/moons*i) + depth,
				1); 
		partikkel(
				cos(t + 2*M_PI/moons*i),
				0,
				sin(t + 2*M_PI/moons*i) + depth,
				1);
	}
	glDepthMask(GL_TRUE);
	glEnable(GL_CULL_FACE);

	if (demo.time > slutttid) {
		fn_replace(&scene_partikkel,&scene_outro_init);
	}
}

#if 0
void scene_bezier_init() {
	glLineWidth(2);
	fn_replace(&scene_bezier_init, &scene_bezier);
}

void scene_bezier() {
	double end_time = scene_start + 40;
	double x,y,z;
	double t;
	int point;
#define points 5
/*                         XYZ N   */
	const double pointv[3][points] = {
/* X */		{ -1,	-0.5,	0,	0.5,	1 },
/* Y */		{ -1,	1,	-1,	0.5,	0 },
/* Z */		{ -1,	-1,	-1,	-1,	-1 }
	};

	for (t = 0; t < 0.9; t+= 0.1) {
		x = y = z = 0;
		for (point = 0; point < points; point++) {
#ifdef DEBUG
			printf("t er: %f\n", t);
#endif
			x += bezier(t, pointv[X][point], point, points);
			y += bezier(t, pointv[Y][point], point, points);
			z += bezier(t, pointv[Z][point], point, points);
		}
		glLoadIdentity();
		glMatrixMode(GL_MODELVIEW);
		glTranslatef(x,y,z);
#ifdef DEBUG
		printf("t = %f, x,y,z = %f,%f,%f\n",t,x,y,z);
#endif
		glutSolidSphere(0.1,3,3);
	}

#ifndef CHEAP
	frames++;
#endif


	if (demo.time > end_time) {
/*		demo_timer_sync(); */
#ifndef CHEAP
		printf("scene_bezier done; time %f, fps: %f\n",demo.time - scene_start,frames/(demo.time - scene_start));
		frames = 0;
#endif
		scene_start = demo.time;
		fn_replace(&scene_bezier, &anim_scene_init);
	}
}
#endif
static double anim_start_tid;

void anim_scene_init() {
	anim_start_tid = demo.time;
	anim_scene();
	fn_replace(&anim_scene_init, &anim_scene);
}

void anim_scene() {
	double end_time = anim_start_tid + 5.4;
	
	glPushMatrix();
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45.0f,(GLfloat)demo.win_size[X]/(GLfloat)demo.win_size[Y],0.1f,100.0f);
	glMatrixMode(GL_MODELVIEW);
	gluLookAt(0.0, 0.0, 15.0, 0.0, 0.0, 0.0, cos(demo.time*2.3), sin(demo.time*2.3), 0.0);

	demo.cam[X] = 0;
	demo.cam[Y] = 0;
	demo.cam[Z] = 15;
	
	glColor3f(1.0, 1.0, 1.0);

	anim_firkant(0.5, 2.0, -10.5, 0, -5.5, 0, anim_start_tid, anim_start_tid+1); 
	anim_firkant(1.5, 0.5, -10.5, 10, -5.5, 2.0, anim_start_tid, anim_start_tid+1);
	anim_firkant(1.5, 0.5, -10.5, -10, -5.5, 1.0, anim_start_tid, anim_start_tid+1);

	anim_firkant(0.5, 2.5, 15.5, 15.5, -3.5, 0, anim_start_tid+0.5, anim_start_tid+1.5);
	anim_firkant(1.5, 0.5, 15.5, -15.5, -3.5, 0, anim_start_tid+0.5, anim_start_tid+1.5);
	
	anim_firkant(0.5, 2.5, 15.5, -15.5, -1.5, 0, anim_start_tid+1, anim_start_tid+2);
	anim_firkant(0.5, 0.5, -15.5, -15.5, -1, 2.0, anim_start_tid+1, anim_start_tid+2);
	anim_firkant(0.5, 0.5, 0, -15.5, -1, 1.0, anim_start_tid+1, anim_start_tid+2);
	anim_firkant(0.5, 2.5, -15.5, 15.5, -0.5, 0, anim_start_tid+1, anim_start_tid+2);

	anim_firkant(0.5, 2.5, 0.5, 15, 0.5, 0, anim_start_tid+1.5, anim_start_tid+2.5);
	anim_firkant(0.5, 2.5, 1.5, -15, 1.5, 0, anim_start_tid+1.5, anim_start_tid+2.5);
	anim_firkant(0.5, 0.5, 15, 15, 1.0, 0, anim_start_tid+1.5, anim_start_tid+2.5);
	
	anim_firkant(1.5, 0.5, 1.5, 15.5, 2.5, 2.0, anim_start_tid+2, anim_start_tid+3);
	anim_firkant(1.5, 0.5, 15.5, 1.0, 2.5, 1.0, anim_start_tid+2, anim_start_tid+3);
	anim_firkant(1.5, 0.5, 1.5, -15.5, 2.5, 0.0, anim_start_tid+2, anim_start_tid+3);
	anim_firkant(0.5, 0.5, -15.5, 15.5, 2.5, 1.5, anim_start_tid+2, anim_start_tid+3);
	anim_firkant(0.5, 0.5, -15.5, -15.5, 3.5, 0.5, anim_start_tid+2, anim_start_tid+3);

	anim_firkant(0.5, 2.5, 10.5, -2.0, 4.5, 0.0, anim_start_tid+2.5, anim_start_tid+3.5);
	anim_firkant(1.5, 0.5, 7.5, 10.5, 5.0, 2.0, anim_start_tid+2.5, anim_start_tid+3.5);
	anim_firkant(1.5, 0.5, 7.5, 1.0, 5.0, 1.0, anim_start_tid+2.5, anim_start_tid+3.5);
	anim_firkant(1.5, 0.5, 7.5, -10.5, 5.0, 0.0, anim_start_tid+2.5, anim_start_tid+3.5);

	glPopMatrix();

#ifndef CHEAP
	frames++;
#endif
	
	if(demo.time > end_time) {
/*		demo_timer_sync(); */
#ifndef CHEAP
		printf("anim_scene done; time %f, fps: %f\n",demo.time - scene_start,frames/(demo.time - scene_start));
		frames = 0;
#endif
		scene_start = demo.time;
		fn_replace(&anim_scene, &anim_scene2);
		anim_start_tid = demo.time;
	}
}

void anim_scene2() {
	double end_time = anim_start_tid + 5.8;
	
	glPushMatrix();
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45.0f,(GLfloat)demo.win_size[X]/(GLfloat)demo.win_size[Y],0.1f,100.0f);
	glMatrixMode(GL_MODELVIEW);

	gluLookAt((demo.time-anim_start_tid)*4, 0.0, 15.0, -(demo.time-anim_start_tid), 0.0, 0.0, cos(demo.time*2.3), sin(demo.time*2.3), 0.0);
	
	demo.cam[X] = (demo.time - anim_start_tid)*4;
	demo.cam[Y] = 0;
	demo.cam[Z] = 15;
	
	glColor3f(1.0, 1.0, 1.0);

	anim_firkant(0.5, 2.0, -5.5, 0, -5.5, 0, anim_start_tid, anim_start_tid); 
	anim_firkant(1.5, 0.5, -5.5, 2.0, -5.5, 2.0, anim_start_tid, anim_start_tid);
	anim_firkant(1.5, 0.5, -5.5, 1.0, -5.5, 1.0,  anim_start_tid, anim_start_tid);

	anim_firkant(0.5, 2.5, -3.5, 0, -3.5, 0, anim_start_tid, anim_start_tid);
	anim_firkant(1.5, 0.5, -3.5, 0, -3.5, 0, anim_start_tid, anim_start_tid);
	
	anim_firkant(0.5, 2.5,  -1.5, 0, -1.5, 0, anim_start_tid, anim_start_tid);
	anim_firkant(0.5, 0.5,  -1, 2.0, -1, 2.0, anim_start_tid, anim_start_tid);
	anim_firkant(0.5, 0.5,  -1, 1.0, -1, 1.0, anim_start_tid, anim_start_tid);
	anim_firkant(0.5, 2.5,  -0.5, 0, -0.5, 0, anim_start_tid, anim_start_tid);

	
	
	anim_firkant(0.5, 0.5, 0.5, 0, -15, -15, anim_start_tid, anim_start_tid+4);
	anim_firkant(0.5, 0.5, 0.5, 0.5, -12, -15, anim_start_tid, anim_start_tid+4);
	anim_firkant(0.5, 0.5, 0.5, 1.0, -9, -15, anim_start_tid, anim_start_tid+4);
	anim_firkant(0.5, 0.5, 0.5, 1.5, -6, -15, anim_start_tid, anim_start_tid+4);
	anim_firkant(0.5, 0.5, 0.5, 2.0, -3, -15, anim_start_tid, anim_start_tid+4);
	anim_firkant(0.5, 0.5, 1.5, 0, 0, -15, anim_start_tid, anim_start_tid+4);
	anim_firkant(0.5, 0.5, 1.5, 0.5, 3, -15, anim_start_tid, anim_start_tid+3);
	anim_firkant(0.5, 0.5, 1.5, 1.0, 6, -15, anim_start_tid, anim_start_tid+3);
	anim_firkant(0.5, 0.5, 1.5, 1.5, 9, -15, anim_start_tid, anim_start_tid+3);
	anim_firkant(0.5, 0.5, 1.5, 2.0, 12, -15, anim_start_tid, anim_start_tid+3);
	anim_firkant(0.5, 0.5, 1.0, 0, 15, -15, anim_start_tid, anim_start_tid+3);
	
	anim_firkant(1.5, 0.5, 2.5, 2.0, 2.5, 2.0, anim_start_tid, anim_start_tid);
	anim_firkant(1.5, 0.5, 2.5, 1.0, 2.5, 1.0, anim_start_tid, anim_start_tid);
	anim_firkant(1.5, 0.5, 2.5, 0.0, 2.5, 0.0, anim_start_tid, anim_start_tid);
	anim_firkant(0.5, 0.5, 2.5, 1.5, 2.5, 1.5, anim_start_tid, anim_start_tid);
	anim_firkant(0.5, 0.5, 3.5, 0.5, 3.5, 0.5,  anim_start_tid, anim_start_tid);

	anim_firkant(0.5, 2.5, 4.5, 0.0, 4.5, 0.0, anim_start_tid, anim_start_tid);
	anim_firkant(1.5, 0.5, 5.0, 2.0, 5.0, 2.0, anim_start_tid, anim_start_tid);
	anim_firkant(1.5, 0.5, 5.0, 1.0, 5.0, 1.0, anim_start_tid, anim_start_tid);
	anim_firkant(1.5, 0.5, 5.0, 0.0, 5.0, 0.0, anim_start_tid, anim_start_tid);

	glPopMatrix();

#ifndef CHEAP
	frames++;
#endif
	
	if(demo.time > end_time) {
	/*	demo_timer_sync(); */
#ifndef CHEAP
		printf("anim_scene done3; time %f, fps: %f\n",demo.time - scene_start,frames/(demo.time - scene_start));
		frames = 0;
#endif
		scene_start = demo.time;
		fn_replace(&anim_scene2, &kylling1);
		fn_remove(&asteroid);
	}
}

void star_bg() {
/*	double end_time = scene_start + 70; */
	GLUquadricObj* hest = gluNewQuadric();
	enum {
		repeat = 8
	};

	glPushMatrix();
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
		glDisable(GL_LIGHTING);
		glBlendFunc(GL_SRC_ALPHA,GL_ONE);
		glBindTexture(GL_TEXTURE_2D, star_tex);

		glRotated(90, 1,0,0);
		glRotated(demo.time, 0,1,0);
	
		glColor3f(1,1,1);

		glPushMatrix();
			glMatrixMode(GL_TEXTURE);
			glScalef(repeat,repeat,repeat);

			gluQuadricDrawStyle(hest, GLU_FILL);
			gluQuadricNormals(hest, GLU_SMOOTH);
			gluQuadricOrientation(hest, GLU_INSIDE);
			gluQuadricTexture(hest, GLU_TRUE);

			gluSphere(hest,50,40,40);

			glLoadIdentity();
	
			glMatrixMode(GL_MODELVIEW);
			glDisable(GL_TEXTURE_2D);
			glDisable(GL_BLEND);
			glEnable(GL_LIGHTING);

		glPopMatrix();
	glPopMatrix();
	
/*
	if (demo.time > end_time) {
		fn_remove(&star_bg);
	}
	*/
}

#ifndef CALLBACK
#define CALLBACK
#endif

void CALLBACK moire_callback(GLenum errorCode) {
	const GLubyte *estring;

	estring = gluErrorString(errorCode);
#ifndef CHEAP
	fprintf(stderr, "quadric error: %s\n", estring);
#endif
	exit(0);
}

GLuint sirkel_liste;

GLUquadricObj *sirkel;

void scene_outro_init(void) {
	int i = 0;
	fn_remove(&star_bg);

	scene_start = demo.time;

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
/*	gluLookAt(0.0, 0.0, -15.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0); */
	gluOrtho2D(0.0, demo.win_size[X], 0.0, demo.win_size[Y]);
	glMatrixMode(GL_MODELVIEW);
	
	sirkel = gluNewQuadric();
	gluQuadricCallback(sirkel, GLU_ERROR, (GLvoid (*) (void)) &moire_callback);
/*	gluQuadricDrawStyle(sirkel, GLU_SILHOUETTE); */
	gluQuadricDrawStyle(sirkel, GLU_FILL);
	gluQuadricNormals(sirkel, GLU_SMOOTH);

	sirkel_liste = glGenLists(1);
	glNewList(sirkel_liste, GL_COMPILE); {
		for(i = 0; i < 80; i += 1) 
			gluDisk(sirkel, i*10, i*10+3, 50, 1);
	} glEndList();
	
	fn_replace(&scene_outro_init, &scene_outro);
}	
	
void scene_outro(void) {
	int i,y = 0;

	glClearColor(sin(M_PI+demo.time)/2,0.4,0.4,1);
	glLoadIdentity();
	glPushMatrix();
	glColor3f((-sin(demo.time+1)), sin(demo.time), cos(demo.time));
	glTranslatef(200.0+sin(demo.time*0.2)*50+sin(demo.time*0.3)*40, 200.0, 0.0);
	glCallList(sirkel_liste);
	glTranslatef(cos(demo.time)*70 + cos(demo.time)*60, sin(demo.time*0.5)*70 + sin(demo.time*0.4)*50, 0);
	glCallList(sirkel_liste);
	glPopMatrix();
	
	glColor3f(1.0, 1.0, 1.0);
	y = 70.0*(demo.time - scene_start)-50*(sizeof(strings)/sizeof(char*)+1);

	//glTranslatef(0.0, -demo.win_size[Y]/2, 0.0);
	
	
	glPushMatrix();
	glTranslatef(0.0, y, 0.1);
	for (i = sizeof(strings)/sizeof(char *) -1; i > -1; i--) {
			y += 50;
			glTranslatef(0.0, 50.0, 0.0);
			glutSolidSphere(0.4,10,10);
			print( strings[i] , 2 );
#ifdef DEBUG
			printf("string %s %d\n",strings[i],i);
#endif
	}
	glPopMatrix();
	if (y > 0 && y > (demo.win_size[Y]+50*(sizeof(strings)/sizeof(char*)))) { 
#ifdef DEBUG
		printf("exit y %d, demo %d\n",y,demo.win_size[Y]+50*(sizeof(strings)/sizeof(char*)+1));
#endif
		/* do sexy stuff here */
		// vent til vi kommer paa en beat foer vi avslutter saken
		demo_shutdown();
	} 
}

GLuint kylling, hane, gress, boble;

void kylling1 () { // kylling init, mao.
	GLUquadricObj *hals;
	float f;
	
	GLUquadricObj *oval;

	//fn_remove(&star_bg);
	//fn_remove(&asteroid);
	glLoadIdentity();
	gluLookAt(0.0, 0.0, -5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0);
	fn_replace(&kylling1, &kylling2);	
	kylling = glGenLists(1);
	gress = glGenLists(1);
	hane = glGenLists(1);
	boble = glGenLists(1);
	
	hals = gluNewQuadric();
	oval = gluNewQuadric();
	gluQuadricCallback(hals, GLU_ERROR, (GLvoid (*) (void)) &moire_callback);
	gluQuadricCallback(oval, GLU_ERROR, (GLvoid (*) (void)) &moire_callback);
	
	glNewList(kylling, GL_COMPILE); {
		glPushMatrix();
			glColor3f(0.8, 0.8, 0.0);

//			glEnable(GL_TEXTURE_2D);
//			glBindTexture(GL_TEXTURE_2D, rand_tex);

			glutSolidSphere(1.0, 20, 20);
			glPushMatrix();
				glTranslatef(1.5, 1.5, 0.0);
				glutSolidSphere(0.7, 20, 20);
				glRotatef(90, 0.0, -1.0, 0.0);
				glRotatef(45, 1.0, 0.0, 0.0);
				gluCylinder(hals, 0.2, 0.2, 2.0, 5, 5);
			glPopMatrix();

//			glDisable(GL_TEXTURE_2D);

			glColor3f(1.0, 0.5, 0.0);
			glTranslatef(0.0, -2.0, 0.0);
			glRotatef(90, -1.0, 0.0, 0.0);
			glRotatef(90, 0.0, 0.0, -1.0);
			glTranslatef(0.5, 0.0, 0.0);
			glPushMatrix();
				gluCylinder(hals, 0.1, 0.1, 2.0, 5, 5);
				glTranslatef(0.0, 0.0, 0.05);
				glRotatef(90, -1.0, 0.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
				glRotatef(20, 0.0, 1.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
				glRotatef(40, 0.0, -1.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
			glPopMatrix();
			glTranslatef(-1.0, 0.0, 0.0);

			glPushMatrix();
				gluCylinder(hals, 0.1, 0.1, 2.0, 5, 5);
				glTranslatef(0.0, 0.0, 0.05);
				glRotatef(90, -1.0, 0.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
				glRotatef(20, 0.0, 1.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
				glRotatef(40, 0.0, -1.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
			glPopMatrix();
		glPopMatrix();	
	} glEndList();

	glNewList(gress, GL_COMPILE); {
		glPushMatrix();
			glColor3f(0.0, 0.8, 0.0);
			glTranslatef(0.0, -2.0, 0.0);

			glEnable(GL_TEXTURE_2D);
			glBindTexture(GL_TEXTURE_2D, rand_tex); 
			
			glBegin(GL_POLYGON); 
			glNormal3f(0.0, 1.0, 0.0);
			for(f=0; f < 2*M_PI; f += 0.1) {
				glTexCoord2f(sin(f), cos(f));
				glVertex3f(sin(f)*15, 0.0, cos(f)*15);
			}
			glEnd();

			glDisable(GL_TEXTURE_2D);

		glPopMatrix();
	} glEndList();
	

	glNewList(hane, GL_COMPILE); {
		glPushMatrix();
			glColor3f(1.0, 1.0, 1.0);
			glutSolidSphere(1.5, 20, 20);
			glPushMatrix();
				glTranslatef(2.0, 2.0, 0.0);
				glutSolidSphere(1.0, 20, 20);
				glColor3f(1.0, 0.0, 0.0);
				glDisable(GL_CULL_FACE);

				glBegin(GL_POLYGON);
					glVertex3f(0.5, 0.7, 0.0);
					glVertex3f(0.0, 2.0, 0.0);
					glVertex3f(0.0, 0.7, 0.0);
				glEnd();
				glBegin(GL_POLYGON);
					glVertex3f(0.0, 0.5, 0.0);
					glVertex3f(-0.5, 1.8, 0.0);
					glVertex3f(-0.5, 0.5, 0.0);
				glEnd();
				glBegin(GL_POLYGON);
					glVertex3f(-0.5, 0.3, 0.0);
					glVertex3f(-1.0, 1.6, 0.0);
					glVertex3f(-1.0, 0.3, 0.0);
				glEnd();
				glEnable(GL_CULL_FACE);
				glColor3f(1.0, 1.0, 1.0);
				glRotatef(90, 0.0, -1.0, 0.0);
				glRotatef(45, 1.0, 0.0, 0.0);
				gluCylinder(hals, 0.4, 0.5, 2.0, 10, 5);
			glPopMatrix();

			glColor3f(1.0, 0.5, 0.0);
			glTranslatef(0.0, -2.0, 0.0);
			glRotatef(90, -1.0, 0.0, 0.0);
			glRotatef(90, 0.0, 0.0, -1.0);
			glTranslatef(0.5, 0.0, 0.0);
			glPushMatrix();
				gluCylinder(hals, 0.1, 0.1, 2.0, 5, 5);
				glTranslatef(0.0, 0.0, 0.05);
				glRotatef(90, -1.0, 0.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
				glRotatef(20, 0.0, 1.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
				glRotatef(40, 0.0, -1.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
			glPopMatrix();
			glTranslatef(-1.0, 0.0, 0.0);

			glPushMatrix();
				gluCylinder(hals, 0.1, 0.1, 2.0, 5, 5);
				glTranslatef(0.0, 0.0, 0.05);
				glRotatef(90, -1.0, 0.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
				glRotatef(20, 0.0, 1.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
				glRotatef(40, 0.0, -1.0, 0.0);
				gluCylinder(hals, 0.1, 0.1, 1.0, 5, 5);
			glPopMatrix();
		glPopMatrix();	
	} glEndList();

	glNewList(boble, GL_COMPILE); {
		glPushMatrix();
		glTranslatef(1.0, 0.5, -0.2);
		glScalef(2.0, 0.7, 1.0);
		glColor3f(0.0, 0.0, 0.0);
		gluDisk(oval, 0.0, 1.0, 40, 4);
		glTranslatef(0.0, 0.0, 0.1);
		glColor3f(1.0, 1.0, 1.0);
		gluDisk(oval, 0.0, 0.95, 40, 4);
		glPopMatrix();
		glTranslatef(0.0, 0.0, 0.1);
	} glEndList();

	glClearColor(0.0, 0.0, 1.0, 0.0);
}

void kylling2 () {
	float kyllingtid;

	kyllingtid = demo.time - scene_start;
	glLoadIdentity();
	glTranslatef(0.0, 0.0, -15.0);
	glPushMatrix();
		glRotatef(kyllingtid*45, 0.0, 1.0, 0.0);
		glCallList(gress);
		glTranslatef(-4.5, 0.0, 0.0);
		glCallList(kylling);
		glTranslatef(0.0, 0.0, -5.0);
		glRotatef(-45, 0.0, 1.0, 0.0);
		glCallList(kylling);
		glRotatef(45, 0.0, 1.0, 0.0);
		glTranslatef(10.0, 0.0, 5.0);
		glRotatef(180, 0.0, 1.0, 0.0);
		glCallList(hane);
	glPopMatrix();


	if(((kyllingtid > 4) && (kyllingtid < 5)) || ((kyllingtid > 12) && (kyllingtid < 13))){
		glColor3f(1.0, 1.0, 1.0);
		glTranslatef(-3.4, 2.8, 5.0);
		glNormal3f(0.0, 0.0, 1.0);
		glCallList(boble); 
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, kykkeli_tex);
		glBegin(GL_POLYGON);  // KYKKELiKY
			glTexCoord2f(1,0);
			glVertex3f(2.0, 1.0, 0.0);
			
			glTexCoord2f(0,0);
			glVertex3f(0.0, 1.0, 0.0);

			glTexCoord2f(0,1);
			glVertex3f(0.0, 0.0, 0.0);

			glTexCoord2f(1,1);
			glVertex3f(2.0, 0.0, 0.0);
		glEnd();
		glDisable(GL_TEXTURE_2D);
	}
	
	if(((kyllingtid > 8) && (kyllingtid < 9)) || ((kyllingtid > 16) && (kyllingtid < 17))){
		glColor3f(1.0, 1.0, 1.0);
		glTranslatef(-2.0, 2.8, 5.0);
		glCallList(boble);
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, gakk_tex);
		glBegin(GL_POLYGON);  // GAKK
			glNormal3f(0.0, 0.0, 1.0);
			glTexCoord2f(0,0);
			glVertex3f(0.0, 1.0, 0.0);
			glTexCoord2f(0,1);
			glVertex3f(0.0, 0.0, 0.0);
			glTexCoord2f(1,1);
			glVertex3f(2.0, 0.0, 0.0);
			glTexCoord2f(1,0);
			glVertex3f(2.0, 1.0, 0.0);
		glEnd();
		glTranslatef(-3.0, 0.0, 0.0);
		glCallList(boble);
		glBegin(GL_POLYGON);  // GAKK
			glNormal3f(0.0, 0.0, 1.0);
			glTexCoord2f(0,0);
			glVertex3f(0.0, 1.0, 0.0);
			glTexCoord2f(0, 1);
			glVertex3f(0.0, 0.0, 0.0);
			glTexCoord2f(1, 1);
			glVertex3f(2.0, 0.0, 0.0);
			glTexCoord2f(1, 0);
			glVertex3f(2.0, 1.0, 0.0);
		glEnd();
	}
	
	glColor3f(0.0, 0.0, 0.0);

	if(kyllingtid > 20) {
		scene_start = demo.time;
		fn_replace(&kylling2, &kykkeliky);
		glClearColor(0.0, 0.0, 0.0, 0.0);
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
		gluOrtho2D(0, 100, 0, 100);
		glMatrixMode(GL_MODELVIEW);
	}

}

void kykkeliky() {
	float kykketid;

	kykketid = demo.time - scene_start;
	glDisable(GL_CULL_FACE);
	glLoadIdentity();

	if(kykketid < 2.0) {
		glColor3f(1.0, 1.0, 1.0);
		glNormal3f(0.0, 0.0, 1.0);
		glRectf(5.0, 10.0, 10.0, 90.0);
		glBegin(GL_POLYGON);
			glVertex2f(5.0, 40.0);
			glVertex2f(15.0, 90.0);
			glVertex2f(20.0, 90.0);
			glVertex2f(10.0, 40.0);
		glEnd()	;
		glBegin(GL_POLYGON);
			glVertex2f(5.0, 50.0);
			glVertex2f(15.0, 10.0);
			glVertex2f(20.0, 10.0);
			glVertex2f(10.0, 50.0);
		glEnd();
		glBegin(GL_POLYGON);
			glVertex2f(20.0, 90.0);
			glVertex2f(25.0, 50.0);
			glVertex2f(30.0, 50.0);
			glVertex2f(25.0, 90.0);
		glEnd();
		glBegin(GL_POLYGON);
			glVertex2f(30.0, 90.0);
			glVertex2f(20.0, 10.0);
			glVertex2f(25.0, 10.0);
			glVertex2f(35.0, 90.0);
		glEnd();
	
		glRectf(35.0, 10.0, 40.0, 90.0);
		glBegin(GL_POLYGON);
			glVertex2f(35.0, 40.0);
			glVertex2f(45.0, 90.0);
			glVertex2f(50.0, 90.0);
			glVertex2f(40.0, 40.0);
		glEnd();
		glBegin(GL_POLYGON);
			glVertex2f(35.0, 50.0);
			glVertex2f(45.0, 10.0);
			glVertex2f(50.0, 10.0);
			glVertex2f(40.0, 50.0);
		glEnd();
	
		glRectf(50.0, 10.0, 55.0, 90.0);
		glBegin(GL_POLYGON);
			glVertex2f(50.0, 40.0);
			glVertex2f(60.0, 90.0);
			glVertex2f(65.0, 90.0);
			glVertex2f(55.0, 40.0);
		glEnd();
		glBegin(GL_POLYGON);
			glVertex2f(50.0, 50.0);
			glVertex2f(60.0, 10.0);
			glVertex2f(65.0, 10.0);
			glVertex2f(55.0, 50.0);
		glEnd();
		glRectf(65.0, 10.0, 70.0, 90.0);
		glRectf(70.0, 90.0, 75.0, 85.0);
		glRectf(70.0, 50.0, 75.0, 45.0);
		glRectf(70.0, 10.0, 75.0, 15.0);
	
		glRectf(76.0, 10.0, 80.0, 90.0);
		glRectf(80.0, 10.0, 85.0, 15.0);
	
		glRectf(86.0, 10.0, 90.0, 90.0);

	} else if (kykketid < 4) {
		glClearColor(1.0, 1.0, 1.0, 0.0);
		glColor3f(0.0, 0.0, 0.0);
		
		glRectf(5.0, 10.0, 10.0, 90.0);
		glRectf(10.0, 90.0, 15.0, 85.0);
		glRectf(10.0, 55.0, 15.0, 50.0);
	
		glRectf(16.0, 90.0, 20.0, 15.0);
		glRectf(25.0, 90.0, 30.0, 15.0);
		glRectf(16.0, 10.0, 30.0, 15.0);
		
		glRectf(31.0, 10.0, 35.0, 90.0);
		glRectf(35.0, 90.0, 40.0, 85.0);
		glRectf(35.0, 10.0, 40.0, 15.0);
		
		glRectf(41.0, 10.0, 45.0, 90.0);
		glBegin(GL_POLYGON);
			glVertex2f(41.0, 40.0);
			glVertex2f(50.0, 90.0);
			glVertex2f(55.0, 90.0);
			glVertex2f(45.0, 40.0);
		glEnd();
		glBegin(GL_POLYGON);
			glVertex2f(41.0, 50.0);
			glVertex2f(50.0, 10.0);
			glVertex2f(55.0, 10.0);
			glVertex2f(45.0, 50.0);
		glEnd();

		glRectf(55.0, 10.0, 60.0, 90.0);

		glRectf(61.0, 10.0, 65.0, 90.0);
		glRectf(70.0, 10.0, 75.0, 90.0);
		glBegin(GL_POLYGON);
			glVertex2f(61.0, 90.0);
			glVertex2f(70.0, 10.0);
			glVertex2f(75.0, 10.0);
			glVertex2f(65.0, 90.0);
		glEnd();

		glRectf(76.0, 10.0, 80.0, 90.0);
		glRectf(80.0, 90.0, 90.0, 85.0);
		glRectf(80.0, 10.0, 90.0, 15.0);
		glRectf(85.0, 15.0, 90.0, 40.0);
		glRectf(81.0, 40.0, 90.0, 45.0);
	} else if (kykketid < 6) {
		glClearColor(0.0, 0.0, 0.0, 0.0);
		glColor3f(1.0, 1.0, 1.0);

		glRectf(35.0, 10.0, 40.0, 90.0);
		glBegin(GL_POLYGON);
			glVertex2f(35.0, 40.0);
			glVertex2f(45.0, 90.0);
			glVertex2f(50.0, 90.0);
			glVertex2f(40.0, 40.0);
		glEnd();
		glBegin(GL_POLYGON);
			glVertex2f(35.0, 50.0);
			glVertex2f(45.0, 10.0);
			glVertex2f(50.0, 10.0);
			glVertex2f(40.0, 50.0);
		glEnd();
		glBegin(GL_POLYGON);
			glVertex2f(55.0, 90.0);
			glVertex2f(60.0, 50.0);
			glVertex2f(65.0, 50.0);
			glVertex2f(60.0, 90.0);
		glEnd();
		glBegin(GL_POLYGON);
			glVertex2f(65.0, 90.0);
			glVertex2f(55.0, 10.0);
			glVertex2f(60.0, 10.0);
			glVertex2f(70.0, 90.0);
		glEnd();			

	} else if ( kykketid < 7) {
		scene_start = demo.time;
		fn_replace(&kykkeliky, &blod);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glPopMatrix();
//		gluLookAt(0.0, 0.0, -5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0);
//		gluPerspective(45.0f,(GLfloat)demo.win_size[X]/(GLfloat)demo.win_size[Y],-50.0f,100.0f);
		demo.cam[X] = 0;
		demo.cam[Y] = 0;
		demo.cam[Z] = 15;
		glMatrixMode(GL_MODELVIEW);
		glClearColor(0.0, 0.0, 0.7, 0.0);

	}
		
		
	glEnable(GL_CULL_FACE);

}

void blod() {
	double tidforblod = demo.time - scene_start;
	tidforblod *= 2;
	// snurr kamera her
	//glTranslatef(0.0, 0.0,-15);
	demo.cam[Z] = tidforblod*4+15;
	glColor4f(1.0, 1.0, 1.0, 1.0);
	glPushMatrix();
		glCallList(gress);
		glPushMatrix();
		glTranslatef(-4.5-tidforblod*2, 0.0, 0.0);
		glRotatef(tidforblod*90,-1,0,0);
		glCallList(kylling);
		glPopMatrix();
		glPushMatrix();
		glTranslatef(tidforblod*2, tidforblod*2, -5.0);
		glRotatef(-45, 0.0, 1.0, 0.0);
		glRotatef(tidforblod*90,1,0,0);
		glCallList(kylling);
		glPopMatrix();
		glColor3f(1.0, 1.0, 1.0);
		partikkel(0,0,0,tidforblod*9);
		glPushMatrix();
		glTranslatef(5.0, 0.0, 0.0);
		glRotatef(180, 0.0, 1.0, 0.0);
		glCallList(hane);
	glPopMatrix();

	if(tidforblod > 7) fn_replace(&blod, &scene_outro_init);
}

void asteroid() {
#define CRASH 5.4
	enum {
		SPEED = 6,
		CRASHPOINT = -18
	};

	glPushMatrix();
		glColor4f(0.4,0.1,0.1,0.3);
		partikkel(1.2, 0.513423, demo.time*SPEED - CRASH*SPEED + CRASHPOINT,3);
		glColor4f(0.8,0.2,0.2,0.4);
		glTranslatef( 1.2, 0.513423, demo.time*SPEED - CRASH*SPEED + CRASHPOINT);
		glutSolidSphere(0.8,16,16);
	glPopMatrix(); 
}
