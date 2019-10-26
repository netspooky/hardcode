#ifndef PARTICLESYSTEM_H
#define PARTICLESYSTEM_H

#include "spring.h"
#include "face.h"
#include "global.h"

#define MAX_PARTICLE_COUNT	50 * 50
#define MAX_FACE_COUNT		MAX_PARTICLE_COUNT
#define MAX_SPRING_COUNT	MAX_FACE_COUNT * 6

typedef struct particlesystem_s {

	particle			particles[MAX_PARTICLE_COUNT];
	spring				springs[MAX_SPRING_COUNT];
	face				faces[MAX_FACE_COUNT];

	int					particle_count;
	int					face_count;

	int					texture;	// default is 3 (set in ps_create_springs()) !
	//float				time;		

} particlesystem;


void	ps_calc_normals(particlesystem* ps);
void	ps_create_springs(particlesystem* ps);

void	ps_plane(particlesystem* ps, float sx, float sy,/*int subx, int suby, float tx, float ty,*/ float im);
void	ps_box(particlesystem* ps, float sx, float sy, float sz, float tx, float ty, float im);

void	ps_set_force(particlesystem* ps, float maskx, float masky, float maskz);
void	ps_translate(particlesystem* ps, float x, float y, float z);

void	ps_relax(particlesystem* ps, float radius2, float deform);
void	ps_integrate(particlesystem* ps, float delta);

void	ps_render(particlesystem* ps);
void	ps_render_range(particlesystem* ps, int count, int shadows);

#endif