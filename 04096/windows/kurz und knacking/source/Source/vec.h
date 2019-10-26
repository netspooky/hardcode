#ifndef VEC_H
#define VEC_H

typedef struct vec_s {
	float x, y, z;
} vec;

void	vec_set(vec* dst, float a, float b, float c);
void	vec_cpy(vec* dst, vec* v);

float	vec_dot(vec* v0, vec* v1);
void	vec_cross(vec* dst, vec* v0, vec* v1);
float	vec_length(vec* v);
float	vec_length2(vec* v);
void	vec_normalize(vec* v);

void	vec_add(vec* dst, vec* v0, vec* v1);
void	vec_madd(vec* dst, vec* v0, vec* v1, float s);
void	vec_sub(vec* dst, vec* v0, vec* v1);
void	vec_mul(vec* dst, vec* v0, float s);

#endif