#include <GL/glut.h>
#include <GL/glx.h>
#include <stdlib.h>

#ifndef CHEAP
#include <stdio.h> /* fprintf */
#endif

#include <math.h> /* sin, cos 2*M_PI */

#include "demo.h" /* demo struct */

#include "effects.h"

#define FULLSCREEN 1
#define XRES 640
#define YRES 480

extern int start_time;
extern GLuint font;
void resize_scene(int Width, int Height);
void pre_scene(void);
void post_scene(void);
int graphics_init(int argc, char **argv);
GLvoid lag_font(GLvoid);

int window; 
//int i, j;

void resize_scene(int Width, int Height) {
	if (Height==0)
		Height=1;

	glViewport(0, 0, Width, Height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	gluPerspective(45.0f,(GLfloat)Width/(GLfloat)Height,0.1f,100.0f);
	glMatrixMode(GL_MODELVIEW);

	demo.win_size[X] = Width;
	demo.win_size[Y] = Height;
}

void pre_scene() {
#ifdef DEBUG
	int i, j, k;
#endif
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt(demo.cam[X],demo.cam[Y],demo.cam[Z], 0,0,0, 0,1,0);
#ifdef DEBUG
	glColor4f(1,0,0,0.2);
	for (i = -1;i < 2;i++) {
		for (j = -1;j < 2;j++) {
			for (k = -1;k < 2;k++) {
				glPushMatrix();
					glTranslatef(i,j,k);
					glutSolidSphere(0.1,10,10);
				glPopMatrix();
			}
		}
	}
#endif
	glColor4f(1,1,1,1);
}

void post_scene() {
	glutSwapBuffers();
}


int graphics_init(int argc, char **argv) {
	GLfloat mat_specular[] = { 0.2, 0.2, 0.2, 0.2 };
	GLfloat mat_shininess[] = { 10.0 };
	GLfloat light_position[] = { 1.0, 1.0, 1.0, 1.0 };

#ifdef DEBUG
	GLboolean bool;
	GLint i[2];
#endif
#ifndef CHEAP
	fprintf(stderr,"graphics_init\n");
#endif

	demo.win_size[X] = XRES;
	demo.win_size[Y] = YRES;
	
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
	/*  RGBA */
	glutInitWindowSize(XRES, YRES);  
	glutInitWindowPosition(0, 0);  
	window = glutCreateWindow("Flause by Plante / Algefaen 2002");  
	if (FULLSCREEN)
		glutFullScreen();
	glutReshapeFunc(&resize_scene);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClearDepth(1.0);
	glDepthFunc(GL_LESS);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_COLOR_MATERIAL);
	glShadeModel(GL_SMOOTH);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45.0f,(GLfloat)XRES/(GLfloat)YRES,0.1f,100.0f);
	glMatrixMode(GL_MODELVIEW);


	glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
	glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);
	glLightfv(GL_LIGHT0, GL_POSITION, light_position);

	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_DEPTH_TEST); 

	partikkel_init();

	glEnable(GL_CULL_FACE);
#ifdef DEBUG
	glGetBooleanv(GL_DOUBLEBUFFER, &bool);
	printf("Vi har %sdoublebuffer.\n", bool ? "" : "ikke ");
	glGetBooleanv(GL_STEREO, &bool);
	printf("Vi har %sstereo.\n", bool ? "" : "ikke ");
	glGetIntegerv(GL_AUX_BUFFERS, i);
	printf("Vi har %i aux buffre.\n", i[0]);

	printf("BITS\n");
	glGetIntegerv(GL_RED_BITS,i);
	printf("RED %i\n",i[0]);
	glGetIntegerv(GL_GREEN_BITS,i);
	printf("GREEN %i\n",i[0]);
	glGetIntegerv(GL_BLUE_BITS,i);
	printf("BLUE %i\n",i[0]);
	glGetIntegerv(GL_ALPHA_BITS,i);
	printf("ALPHA %i\n",i[0]);
	glGetIntegerv(GL_INDEX_BITS,i);
	printf("INDEX %i\n",i[0]);
	
	if (glIsEnabled(GL_CULL_FACE))
		printf("Culling enabled\n");
	else
		printf("Culling disabled\n");
	printf("graphics_init done\n");
#endif
	return window;
}
