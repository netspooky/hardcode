/*
 * Derivations
 * by zipola
 * Functions regarding the graphics.
 */

#include <SDL/SDL.h>
#include <SDL/SDL_opengl.h>

#include "gfx.h"

float randf()
{
	return (float)rand()/(float)RAND_MAX - 0.5;
}

void intro(int t)
{
	glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);

	int N_POLYS = 10;

	int i = 0;
	for (i = 0; i < N_POLYS; i++) {
		glBegin(GL_POLYGON);
		glColor3f(1.0, 0.0, i*0.1);	
		glNormal3f(0.0, 1.0, 0.0);
		glVertex3f(i*0.5, 1.0, i*0.1);
		glVertex3f(-1.0, i*0.5, i*0.1);
		glVertex3f(-i*0.5, -1.0, i*0.1);
		glVertex3f(1.0, -i*0.5, i*0.1);
		glEnd();
	}

	glBegin(GL_POLYGON);
	glColor3f(0.2, 0.3, 1.0);	
	glNormal3f(0.0, 1.0, 0.0);
	glVertex3f(0.5, 1.0, 1.8);
	glVertex3f(-1.0, 0.5, 1.8);
	glVertex3f(0.5, -1.0, 1.8);
	glVertex3f(-0.6, -0.2, 1.8);
	glEnd();

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glScalef(0.3,0.3,0.3);
	glRotatef(t/60.0, 0.5, 0.2, 0.0);
}

void boids(int t)
{
	glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);

	float red = randf();
	float green = randf();
	float blue = randf();

	int i = 0;
	for (i = 0; i < N_BOIDS; i++) {
		glBegin(GL_POLYGON);
			glColor3f(red, green, blue);
			glNormal3f(0.0, 1.0, -0.1);	
			glVertex3f(-0.2, 0.0, 0.0);
			glVertex3f(0.2, 0.2, 0.0);
			glVertex3f(0.2, 0.2, 0.2);
		glEnd();

		//update_boid_position();

		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		//glScalef(0.2,0.2,0.2);
		float x = boid_array[i].x;
		float y = boid_array[i].y;
		float z = boid_array[i].z;
		glTranslatef(x, y, z);
		float rx = boid_array[i].rx;
		float ry = boid_array[i].ry;
		float rz = boid_array[i].rz;
		float ra = boid_array[i].ra;
		glRotatef(ra*t/60.0, rx, ry, rz);
	}
}

void boids2(int t)
{
	glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);

	float red = randf();
	float green = randf();
	float blue = randf();

	int i = 0;
	for (i = 0; i < N_BOIDS; i++) {
		glBegin(GL_POLYGON);
			glColor3f(red, green, blue);
			glNormal3f(0.0, 1.0, -0.1);	
			glVertex3f(-0.2, 0.0, 0.0);
			glVertex3f(0.2, 0.2, 0.0);
			glVertex3f(0.2, 0.2, 0.2);
			glVertex3f(0.3, -0.2, 0.4);
		glEnd();

		//update_boid_position();

		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		//glScalef(0.2,0.2,0.2);
		float x = boid_array[i].x;
		float y = boid_array[i].y;
		float z = boid_array[i].z;
		glTranslatef(x, y, z);
		float rx = boid_array[i].rx;
		float ry = boid_array[i].ry;
		float rz = boid_array[i].rz;
		float ra = boid_array[i].ra;
		glRotatef(ra*2*t/60.0, rx, ry, rz);
	}
}

float text_x = -0.5;
void greets(int t)
{
	glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);

	draw_text("derivations", 11, -0.8, 0.7, 0.1, 0.1);
	draw_text("by", 2, -0.8, 0.5, 0.1, 0.1);
	draw_text("zipola", 6, -0.8, 0.3, 0.1, 0.1);
	draw_text("fourkilobytes", 13, -0.6, 0.9, 0.1, 0.1);

	draw_text("greetz", 6, -0.3, 0.0, 0.1, 0.1);
	
	draw_text("teistiz", 7,  0.0, -0.2, 0.1, 0.1);
	draw_text("rageinen", 8, 0.0, -0.4, 0.1, 0.1);
	draw_text("turol", 5,    0.0, -0.6, 0.1, 0.1);
	draw_text("eladith", 7, -0.8, -0.2, 0.1, 0.1);
	draw_text("ntz", 3,     -0.6, -0.4, 0.1, 0.1);
	draw_text("jypa", 4,    -0.6, -0.6, 0.1, 0.1);
}

void init_boids()
{
	int i = 0;
	for (i = 0; i < N_BOIDS; i++) {
		boid_array[i].x = 0.5*randf();
		boid_array[i].y = 0.5*randf();
		boid_array[i].z = 0.5*randf();
		boid_array[i].vx = 0.0001*randf();
		boid_array[i].vy = 0.0001*randf();
		boid_array[i].vz = 0.0001*randf();
		boid_array[i].rx = 0.01*randf();
		boid_array[i].ry = 0.01*randf();
		boid_array[i].rz = 0.01*randf();
		boid_array[i].ra = 2*randf();
	}
}

float avg_heading();

void update_boid_position()
{
	// Average position
	int i = 0;
	float avg_x = 0;
	float avg_y = 0;
	float avg_z = 0;
	for (i = 0; i < N_BOIDS; i++) {
		avg_x = boid_array[i].x;
		avg_y = boid_array[i].y;
		avg_z = boid_array[i].z;
	}
	avg_x = avg_x / N_BOIDS;
	avg_y = avg_y / N_BOIDS;
	avg_z = avg_z / N_BOIDS;

	// Average heading
	i = 0;
	float avg_vx = 0;
	float avg_vy = 0;
	float avg_vz = 0;
	for (i = 0; i < N_BOIDS; i++) {
		avg_vx = boid_array[i].vx;
		avg_vy = boid_array[i].vy;
		avg_vz = boid_array[i].vz;
	}
	avg_vx = avg_vx / N_BOIDS;
	avg_vy = avg_vy / N_BOIDS;
	avg_vz = avg_vz / N_BOIDS;

	// Vector to closest
	i = 0;
	for (i = 0; i < N_BOIDS; i++) {
		int j = 0;
		float min_dist = 100;
		for (j = 0; j < N_BOIDS; j++) {
			float dx = (boid_array[i].x - boid_array[j].x);
			float dy = (boid_array[i].y - boid_array[j].y);
			float dz = (boid_array[i].z - boid_array[j].z);
			float curr_dist = sqrt(dx*dx + dy*dy + dz*dz);
			if (curr_dist < min_dist) {
				min_dist = curr_dist;
				boid_array[i].cx = dx;
				boid_array[i].cy = dy;
				boid_array[i].cz = dz;
			}
		}
		avg_vx = boid_array[i].vx;
		avg_vy = boid_array[i].vy;
		avg_vz = boid_array[i].vz;
	}


	// Update boids' speed
	i = 0;
	for (i = 0; i < N_BOIDS; i++) {
		boid_array[i].vx += 0.0001*avg_x + 0.0001*avg_vx + 0.001*boid_array[i].cx;
		boid_array[i].vy += 0.0001*avg_y + 0.0001*avg_vy + 0.001*boid_array[i].cy;
		boid_array[i].vz += 0.0001*avg_z + 0.0001*avg_vz + 0.001*boid_array[i].cz;
	}

	// Update boids' positions
	i = 0;
	for (i = 0; i < N_BOIDS; i++) {
		boid_array[i].x += boid_array[i].vx;
		boid_array[i].y += boid_array[i].vy;
		//boid_array[i].z += boid_array[i].vz;
	}
}


/*
 * Initialize SDL graphics and OpenGL.
 */
void init_gfx()
{
	SDL_ShowCursor(SDL_DISABLE);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_WM_SetCaption("derivations", NULL);
	SDL_SetVideoMode(1024, 768, 24, SDL_OPENGL | SDL_FULLSCREEN);
	//SDL_SetVideoMode(1024, 768, 24, SDL_OPENGL);
	
	glEnable(GL_DEPTH_TEST);
	glHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
	
	glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE) ;
	glEnable(GL_COLOR_MATERIAL);
	
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);

	float ambientLight[] = { 0.2f, 0.2f, 0.2f, 1.0f };
	float diffuseLight[] = { 0.5f, 0.5f, 0.5f, 1.0f };
	float specularLight[] = { 0.5f, 0.5f, 0.5f, 1.0f };
	float position[] = { -2.5f, 1.0f, -8.0f, 1.0f };

	glLightfv(GL_LIGHT0, GL_AMBIENT, ambientLight);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuseLight);
	glLightfv(GL_LIGHT0, GL_SPECULAR, specularLight);
	glLightfv(GL_LIGHT0, GL_POSITION, position);
	
	init_boids();
}

