#ifndef _STUFF_HPP_
#define _STUFF_HPP_

#ifndef OS_X
#include <GL/gl.h>
#include <GL/glu.h>
#else
#include <gl.h>
#include <glu.h>
#endif

#include "win32.hpp"
#include "vector.hpp"
#include "matrix.hpp"
#include "matikka.h"
#include "primitives.hpp"
#include "spline.hpp"
#include "texture.hpp"
#include "font.hpp"
#include "hermitecurve.hpp"
#include "beziercurve.hpp"
#include "sync.hpp"

extern Window win;
extern Texture *pallura;
extern Texture *pallura2;
extern Texture *render512_0;
extern Texture *render512_1;
extern Texture *render512_2;
extern Texture *kasvot;
extern Texture *kasvot2;
extern Texture *planeetantekstuuri;

extern int OPENGL_XRES;
extern int OPENGL_YRES;
extern bool OPENGL_FULLSCREEN;
extern bool runflag;
extern bool musicflag;
extern bool spookyflag;

extern Vector clearcolor;
extern int originalaika;

//interpoloi, palauttaa 0 jos value1 < limit1, palauttaa 0..1 jos välissä, 1 jos menee yli
float calcPosInt(int value1, int limit1, int limit2);

//interpoloi, palauttaa 0 jos value1 < limit1, palauttaa 0..1 jos välissä, 1 jos menee yli
float calcPosFloat(float value1, float limit1, float limit2);

//saa maksimin puolivälissä (limit1+limit2)/2, multiplyllä kerrotaan, paluuarvo klipataan [0..1]
float calcSaturate(float value, float limit1, float limit2, float multiply);

const bool testaaPos(const int aika, const int ajat[]);
const float laskePos(const int aika, const int ajat[]);

void perspective2D(float width, float height);
void perspective3D();

void textures_init();
void textures_free();
void unpack(unsigned char *source, unsigned long *dest);


#endif
