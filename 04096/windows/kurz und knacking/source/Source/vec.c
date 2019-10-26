#include "vec.h"
#include "utility.h"

void vec_set(vec* dst, float a, float b, float c) {
	dst->x = a;
	dst->y = b;
	dst->z = c;
}

void vec_cpy(vec* dst, vec* v) {
	//vec_set(dst, v->x, v->y, v->z);
	dst->x = v->x;
	dst->y = v->y;
	dst->z = v->z;
}

float vec_dot(vec* v0, vec* v1) {
	return v0->x * v1->x + v0->y * v1->y + v0->z * v1->z;
}

void vec_cross(vec* dst, vec* v0, vec* v1) {
	dst->x = v0->y * v1->z - v0->z * v1->y;
	dst->y = -v0->x * v1->z + v0->z * v1->x;
	dst->z = v0->x * v1->y - v0->y * v1->x;
}

float vec_length(vec* v) {
	return (float)sqrt(vec_dot(v, v));
}

float vec_length2(vec* v) {
	return vec_dot(v, v);
}

void vec_normalize(vec* v) {	
	float len = 1.0f / vec_length(v);
	vec_mul(v, v, len);
}

void vec_add(vec* dst, vec* v0, vec* v1) {
	dst->x = v0->x + v1->x;
	dst->y = v0->y + v1->y;
	dst->z = v0->z + v1->z;
}

void vec_madd(vec* dst, vec* v0, vec* v1, float s) {
	dst->x = v0->x + v1->x * s;
	dst->y = v0->y + v1->y * s;
	dst->z = v0->z + v1->z * s;
}

void vec_sub(vec* dst, vec* v0, vec* v1) {
	dst->x = v0->x - v1->x;
	dst->y = v0->y - v1->y;
	dst->z = v0->z - v1->z;
}

void vec_mul(vec* dst, vec* v0, float s) {
	dst->x = v0->x * s;
	dst->y = v0->y * s;
	dst->z = v0->z * s;
}