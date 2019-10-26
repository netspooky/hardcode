#ifndef FYLL_H
#define FYLL_H

#include "window.h"

// config

const int XRES = 640;
const int YRES = 480;
const char WINDOWTITLE[] = "Poem to a boy";
const bool FULLSCREEN = true;

// not config

const int SCENES = 4;

const int X = 0;
const int Y = 1;
const int Z = 2;
const int W = 3;

const int R = 0;
const int G = 1;
const int B = 2;
const int A = 3;

extern window *w;

typedef float vector[3];
typedef float vertex[3];

#ifdef DEBUG
#include <iostream>
#define dprint(arg) std::cout << arg;
#else
#define dprint(arg)
#endif

#endif
