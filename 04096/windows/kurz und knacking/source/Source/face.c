#include "face.h"

// set face structure
void face_set(face* t, int a, int b, int c, int d) {

	t->idx[0] = a;
	t->idx[1] = b;
	t->idx[2] = c;
	t->idx[3] = d;
}