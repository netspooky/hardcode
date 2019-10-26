#ifndef FACE_H
#define FACE_H

#include "vec.h"

typedef struct face_s {
	int idx[4];
	vec normal;
} face;

void face_set(face* t, int a, int b, int c, int d);

#endif