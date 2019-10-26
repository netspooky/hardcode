/*
    Lego brick definitions
*/

#ifndef PALIKKA_H
#define PALIKKA_H

#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif

#define NRAD 0.3
#define PRAD 0.35
#define NHEIGHT 0.25
#define LHEIGHT 1.2
#define LTHICK 0.12

/* Sets correct GL parameters */
void lego_init(void);

/* Brick of xs*zs, centered (0/1), accuracy in steps (0->no details), color */
void lego(int xs,int zs,int center,int nsteps,int psteps,
          GLfloat r,GLfloat g,GLfloat b);

#endif
