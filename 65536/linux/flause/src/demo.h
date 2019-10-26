#ifndef __demo_h_
#define __demo_h_

#include "minifmod.h"
#include <GL/glut.h>

extern void demo_init(int argc, char **argv);
extern void demo_main_loop(void);
extern void demo_shutdown(void);

extern void demo_timer_sync(void);
extern double demo_timer_get(void);

typedef  void (*vfunc_t)(void);
extern void fn_replace(vfunc_t,vfunc_t);
extern void fn_add(vfunc_t);
extern void fn_remove(vfunc_t);

enum {
	X,
	Y,
	Z
};

typedef struct {
	int window;
	FMUSIC_MODULE *module;
	int win_size[2]; /* x, y */
	double time;
	double cam[3];
} demo_t;

typedef struct {
	vfunc_t func;
} func_t;

typedef struct {
	unsigned char *data;
	unsigned short height;
	unsigned short width;
} image_t;

extern demo_t demo;

extern GLuint *letters;
#endif
