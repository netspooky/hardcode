#ifndef CHEAP
#include <stdio.h> /* fprintf */
#endif

#include <stdint.h> /* uint64_t */
#include <stdlib.h> /* exit */
#include <unistd.h> /* usleep, close */
#include <GL/glut.h> /* glutXXXFunc */
#include <GL/glx.h> /* x font ting */

#include <sys/time.h> /* gettimeofday */
#include <time.h> /* gettimeofday */

#include <linux/soundcard.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


#include "demo.h"
#include "minifmod.h"
#include "minifmod/sound.h"
#include "opengl.h"
#include "scenes.h"
#include "effects.h"

#define MAXFUNC 8

void demo_init(int argc,char **argv);
void demo_shutdown(void);
void demo_timer_init(void);
double demo_timer_get(void);
void demo_idle(void);
void key_pressed(unsigned char key, int x, int y);
GLuint *letters;

func_t funcs[MAXFUNC];
demo_t demo;
double start_time;

void demo_init(int argc, char **argv) {
	int i;
	
#ifndef CHEAP
	fprintf(stderr,"demo_init\n");
#endif

	
	/* INIT FUNCTION ARRAY */
	for(i=0; i<MAXFUNC; i++) {
		funcs[i].func = NULL;
	}

	
	/* GRAPHICS */
	demo.window = graphics_init(argc, argv);

	/* DEMO */
	glutDisplayFunc(&demo_idle);  
	glutIdleFunc(&demo_idle);
	glutKeyboardFunc(&key_pressed);
	
	/* TIMER */
	demo_timer_init();


	/* POPULATE FUNCTION ARRAY */
	funcs[MAXFUNC-1].func = &post_scene;
	scenes_init();

	/* LOAD FONT */
	letters = make_font_textures();
	
	demo.module = fmod_init();
}

void demo_main_loop() {
#ifndef CHEAP
	fprintf(stderr,"demo_main_loop\n");
#endif
	glutMainLoop();
}


void demo_idle() {
	int funcnum;

	demo.time = demo_timer_get();

	for(funcnum = 0; funcnum < MAXFUNC; funcnum++) {
		if(funcs[funcnum].func)
			funcs[funcnum].func();
	}
		
}

void demo_shutdown() {
#ifndef CHEAP
	fprintf(stderr,"demo_shutdown\n");
#endif
	exit(0);
}


void key_pressed(unsigned char key, int x, int y) {
	usleep(100);

	if (key == 27) { 
		glutDestroyWindow(demo.window); 
		exit(0);                   
	}
}

void demo_timer_init() {
	/*
	struct timeval time_of_day;
#ifndef CHEAP
	fprintf(stderr,"demo_timer_init\n");
#endif
	gettimeofday(&time_of_day, NULL);
	start_time = (time_of_day.tv_sec + (time_of_day.tv_usec / 1000000.0));
	*/
//	demo_timer_sync();
}

/*
double demo_timer_dsp_get();

void demo_timer_sync() {
	struct timeval time_of_day;
#ifndef CHEAP
	double synced = start_time;
	fprintf(stderr,"demo_timer_sync");
#endif
	gettimeofday(&time_of_day, NULL);
	start_time = (time_of_day.tv_sec + (time_of_day.tv_usec / 1000000.0))
			- (double)FMUSIC_GetTime(demo.module)/1000; // 930
#ifndef CHEAP
	synced -= start_time;
	fprintf(stderr," %f\n", synced);
#endif
	
}
*/

/*
double demo_timer_get() {
	struct timeval time_of_day;

	gettimeofday(&time_of_day, NULL);
	printf("/dev/dsp: %f, sys: %f, fmod %f\n",
			demo_timer_dsp_get(),
			(time_of_day.tv_sec + (time_of_day.tv_usec / 1000000.0)) - start_time,
			(double)FMUSIC_GetTime(demo.module)/1000); 
			
	return (time_of_day.tv_sec + (time_of_day.tv_usec / 1000000.0)) - start_time;
}
*/
double demo_timer_get() {
	unsigned long delay = 0;
	enum {
		SAMPLERATE = 44100
	};
#ifdef DEBUG
	fprintf(stderr,"demo_timer_dsp_get\n");
#endif
	ioctl(FSOUND_FileDSP, SNDCTL_DSP_GETODELAY, &delay);
#ifdef DEBUG
//	printf("diff %f\n",(double)(written - delay) / (SAMPLERATE * 4)-demo.time);
#endif 
#ifndef CHEAP
	if (demo.time > (double)(written - delay) / (SAMPLERATE * 4)) {
//		printf("fscked-time\n");
		return demo.time;
	}
#endif
	return (double)(written - delay) / (SAMPLERATE * 4);
}
void fn_add(vfunc_t func) {
	int i = 0;
#ifndef CHEAP
	printf("fn_add\n");
#endif
	while (funcs[i].func)
		i++;
	funcs[i].func = func;
}

void fn_replace(vfunc_t old,vfunc_t new) {
	int i = 0;
#ifndef CHEAP
	printf("fn_replace");
#endif
	while (funcs[i].func != old)
		i++;
	funcs[i].func = new;
#ifndef CHEAP
	printf(" ok\n");
#endif
}

void fn_remove(vfunc_t func) {
	int i = 0;
#ifndef CHEAP
	printf("fn_remove\n");
#endif
	while (funcs[i].func != func)
		i++;
	funcs[i].func = NULL;
}
