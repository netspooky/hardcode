#ifndef GFX_H
#define GFX_H

/*
 * Initializes the graphical aspects of SDL.
 */
void init_gfx();

void update_boid_position();

void intro(int t);
void greets(int t);
void boids(int t);
void boids2(int t);

#define N_BOIDS 300

typedef struct  {
	float x;
	float y;
	float z;
	float vx;
	float vy;
	float vz;
	float cx;
	float cy;
	float cz;
	float rx;
	float ry;
	float rz;
	float ra;
} boid;

static boid boid_array[N_BOIDS];

#endif
