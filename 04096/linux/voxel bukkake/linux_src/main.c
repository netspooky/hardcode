/*
   Voxel Bukkake - A 4k intro for BCNparty'101.
   Copyright (C) 2005 Jorge Gorbe (aka slack/Necrostudios)

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License version 2
   as published by the Free Software Foundation.
*/

#include <SDL.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <math.h>
#include <stdlib.h>

#include "dl_init.h"

#include "synth.h"
#include "play.c"

#define sin(x) __builtin_sinf(x)
#define cos(x) __builtin_cosf(x)
#define sqrt(x) __builtin_sqrtf(x)
//#define expf(x) __builtin_expf(x)

// Codigo generado del caracter 65 al 90 ( 104 bytes).
static unsigned int fuente[]={0x1297a526, 0x0e949d27, 0x0c908526, 0x0e94a527, 0x1e10bc2f, 0x02109c2f, 0x1d1e862e, 0x1294bd29, 0x0e210847, 0x0c94a108, 0x12928ca5, 0x1e108421, 0x231ad771, 0x231cd671, 0x1d18c62e, 0x0213a527, 0x20e6a526, 0x12949d27, 0x0c920926, 0x0842109f, 0x0c94a529, 0x08a54631, 0x23bad631, 0x23151151, 0x08422a31, 0x1e11110f};

//static SDL_Surface *screen;

#define xres 800
#define yres 600

#define SQR(a) (a)*(a)

#define t (current_time)

#define GRIDSIZE 1500.0f
#define GRIDSTEP 50.0f

#define HALFARRAY (int)(GRIDSIZE/GRIDSTEP)
#define ARRAYSIZE 2*HALFARRAY

float grid_state[ARRAYSIZE][ARRAYSIZE][ARRAYSIZE];

#ifdef TEXTOS
float grid_text[ARRAYSIZE][ARRAYSIZE][ARRAYSIZE];
#endif

void fullscreenquad()
{
        fn.glBegin(GL_QUADS);
        fn.glVertex3f(-1.0f,-1.0f, 0.0f);
        fn.glVertex3f(1.0f,-1.0f, 0.0f);
        fn.glVertex3f(1.0f,1.0f, 0.0f);
        fn.glVertex3f(-1.0f,1.0f, 0.0f);
        fn.glEnd();

}


static void activa(int a, int b, int c, float val)
{
		grid_state[a][b][c] += val;
		if (grid_state[a][b][c] > 1.0f)
			grid_state[a][b][c]=1.0f;
		//printf("%f\n",grid_state[a][b][c]);
}

#ifdef TEXTOS
void draw_text(char *cad, int x, int y, int z)
{
	char ch;
	while ((ch=*cad++))
	{
		for (int f=0; f<6; ++f)
			for (int c=0; c<5; ++c)
			{
				//printf("x=%d, y=%d, z=%d\n", x+c, y-6+f, z);
				if (fuente[ch-'A']&(1<<(5*f+c)))
					grid_text[x+c][y-f][z]=1.0f;

			}

		x+=6;
	}
}
#endif


float cube_r, cube_g, cube_b;
Uint8 negativo;

float fade;

// x,y,z -> esquina inf. izq.
// size -> lado
// alpha -> ...ejem...
static void draw_cube(float x, float y, float z, float size, float alpha)
{
	float Dy=y-size;
	float Dz=z-size;
	float Dx=x+size;

	fn.glColor4f(cube_r, cube_g, cube_b,alpha);

        fn.glBegin(GL_TRIANGLE_FAN);
        fn.glVertex3f(x,y,z);
        fn.glVertex3f(x,Dy,z);//y-tam,z);
        fn.glVertex3f(Dx,Dy,z);//x+tam,y-tam,z);
        fn.glVertex3f(Dx,y,z); //x+tam,y,z);               // Cara frontal
        fn.glVertex3f(Dx,y,Dz );//x+tam,y,z-tam);
        fn.glVertex3f(x,y,Dz);//z-tam);            // Cara superior
        fn.glVertex3f(x,Dy,Dz);//y-tam,z-tam);
        fn.glVertex3f(x,Dy,z);//y-tam,z);          // Cara izquierda
        fn.glEnd();

        fn.glBegin(GL_TRIANGLE_FAN);
        fn.glVertex3f(Dx,Dy,Dz);//x+tam,y-tam,z-tam);
        fn.glVertex3f(Dx,y,Dz);//x+tam,y,z-tam);
        fn.glVertex3f(x,y,Dz);//z-tam);
        fn.glVertex3f(x,Dy,Dz);//y-tam,z-tam);     // Cara trasera
        fn.glVertex3f(Dx,Dy,z); //x+tam,y-tam,z);
        fn.glVertex3f(Dx,Dy,z);//x+tam,y-tam,z);   // Cara inferior
        fn.glVertex3f(Dx,y,z);//x+tam,y,z);
        fn.glVertex3f(Dx,y,Dz);//x+tam,y,z-tam);   // Cara derecha
        fn.glEnd();

}

static float rotated_angle, rotated_x, rotated_y, rotated_z;

static void rotated_cube(int i, int j, int k)
{
	int l=1;
	int res_i, res_j, res_k, res_l;
	float rot[16];
	fn.glPushMatrix();
	fn.glLoadIdentity();
	fn.glRotatef(rotated_angle,rotated_x,rotated_y,rotated_z);
	fn.glGetFloatv(GL_MODELVIEW_MATRIX, rot);
	fn.glPopMatrix();
	res_i=i*rot[0]+j*rot[4]+k*rot[8]+l*rot[12];
	res_j=i*rot[1]+j*rot[5]+k*rot[9]+l*rot[13];
	res_k=i*rot[2]+j*rot[6]+k*rot[10]+l*rot[14];
	res_l=i*rot[3]+j*rot[7]+k*rot[11]+l*rot[15];

	grid_state[res_i+HALFARRAY]
		[res_j+HALFARRAY]
		[res_k+HALFARRAY]=0.5;

}

static void fill_ball(int x, int y, int z, int radio)
{
	int i,j,k;
	for (i=x-radio; i<=x+radio; ++i)
	{
		for (j=y-radio; j<=y+radio; ++j)
		{
			for (k=z-radio; k<=z+radio; ++k)
			{
				float dist=sqrt(SQR(i-x)+SQR(j-y)+SQR(k-z));
				float val=1.0f-dist/radio;
				if (val<0.0f) val=0.0f;
				activa(i+HALFARRAY,j+HALFARRAY,k+HALFARRAY,val/6.0f);
			}
		}
	}
}

static void do_metaballs()
{
	float sin_t=20.0f*sin(t);
	float sin_2t=20.0f*sin(2.1f*t);
	float sin_3t=20.0f*sin(0.4f*t);
	fill_ball(sin_t,	sin_2t,		sin_3t, 8);	
	fill_ball(sin_t,	sin_3t,		sin_2t, 8);	
	fill_ball(sin_2t,	sin_t,		sin_3t, 8);
	fill_ball(sin_2t,	sin_3t,		sin_t, 8);
	fill_ball(sin_3t, 	sin_t,		sin_2t, 8);	
	fill_ball(sin_3t, 	sin_2t,		sin_t, 8);	
}


static void do_snake()
{
	// "Shadebob"
	
	int a,b,c;

	a=HALFARRAY+(int)(20.0f*sin(2.0f*t));
	b=HALFARRAY+(int)(20.0f*sin(3.0f*t));
	c=HALFARRAY+(int)(20.0f*cos(4.0f*t));

	//activa(a,b,c,1.0);
	float factor=0.5f;
	float dist=5.0f;
	for (int i=-dist; i<dist; ++i)
		for (int j=-dist; j<dist;++j)
			for (int k=-dist; k<dist; ++k)
			{
				float x=sqrt(i*i+j*j+k*k);
				if (x!=0)
					activa(a+i,b+j,c+k,factor*whitenoise()/x);
			}

}

static void do_bigcube(int size, float rx, float ry, float rz, float angle)
{
	int i;
	rotated_x=rx;
	rotated_y=ry;
	rotated_z=rz;
	rotated_angle=angle;
	for (i=-size; i<=size; ++i)
	{
		rotated_cube(i,size,size);
		rotated_cube(i,-size,size);
		rotated_cube(i,-size,-size);
		rotated_cube(i,size,-size);
		rotated_cube(size,i,size);
		rotated_cube(-size,i,size);
		rotated_cube(-size,i,-size);
		rotated_cube(size,i,-size);
		rotated_cube(size,size,i);
		rotated_cube(-size,size,i);
		rotated_cube(-size,-size,i);
		rotated_cube(size,-size,i);
	}
	
	
}

#ifdef TEXTOS
struct text
{
	char *texto;
	int px,py,pz;
	float rx,ry,rz,angle;
};
#endif

#define NTEXTOS 6


float GRID_DECAY=0.1f;
float GRID_THRESHOLD=0.01f;
int cube_size=5;
int current_effect;

#ifdef TEXTOS
struct text textos[]={ 
	{"DELANTE", 10,20,0, 0,0,0,0}, 
	{"IZQUIERDA", 4,20,0,0,1,0,90},
	{"DETRAS", 10,20,0,0,1,0,180},
	{"DERECHA", 10,20,0,0,1,0,270},
	{"ARRIBA",10,20,0,1,0,0,90},
	{"ABAJO",10,20,0,1,0,0,270},
};
#endif

Uint8 end;

#ifdef DEBUG
int main(int argc, char **argv)
#else
void _start(void)
#endif
{
	SDL_Event ev;
	dl_init();
	//int i=0;	
	//__builtin_memset(voices, 0, NUM_VOICES*sizeof(Voice));
	
#ifdef OUTFILE
	fout = fopen(OUTFILE, "wb");
#endif
	
	fn.SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
//	fn.SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	fn.SDL_SetVideoMode(xres, yres, 32, SDL_OPENGL | SDL_FULLSCREEN);


	fn.SDL_OpenAudio(&desired, NULL);
	fn.SDL_PauseAudio(0);
	fn.SDL_ShowCursor(0);


	while(!end)
	{
		while (fn.SDL_PollEvent(&ev))
		{
			if (ev.type==SDL_KEYDOWN)
				goto fin;
		}

		
		//cube_r=0.1f+0.05*sin(0.25f*t);
		//cube_g=0.5f+0.5*sin(t);
		//cube_b=0.5f+0.5*cos(0.5f*t);
		cube_r=cube_g=cube_b=0.20f;
		
		if (negativo)
		{
			cube_r=cube_g=cube_b=1.0f;
		}
		
		//fn.glMatrixMode(GL_PROJECTION);
		//fn.glLoadIdentity();
		if (negativo)
			fn.gluPerspective(70.0f, 1.33f, 0.1f,10000.0f);
		else
			fn.gluPerspective(115.0f+5.0f*sin(current_time),1.33f,0.1f,10000.0f);
		
		fn.glMatrixMode(GL_MODELVIEW);
		//fn.glLoadIdentity();
		fn.gluLookAt(2000.0f*cos(0.5f*t)*sin(0.2f*t), 2000.0f*sin(0.5f*t)*sin(0.2f*t), 2000.0f*cos(0.2f*t), 0.0f,0.0f,0.0f,0.2f*sin(2.0f*t), 1.0f, 0.0f);
		
		if (negativo)
			fn.glClearColor(0.1f,0.2f,0.3f,0.0f);
		else
			fn.glClearColor(1.0f,1.0f,1.0f,1.0f);
		
		fn.glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		if (negativo)
			fn.glColor4f(1.0f,1.0f,1.0f,0.01f);
		else
			fn.glColor4f(0.0f,0.0f,0.0f,0.01f);
		
		fn.glDisable(GL_DEPTH_TEST);
		fn.glEnable(GL_BLEND);
		fn.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		//fn.glEnable(GL_LINE_SMOOTH);
		fn.glBegin(GL_LINES);
		for (float j=-GRIDSIZE; j<GRIDSIZE; j+=GRIDSTEP)
			for (float i=-GRIDSIZE; i<GRIDSIZE; i+=GRIDSTEP)
			{
					fn.glVertex3f(i, j, -GRIDSIZE);
					fn.glVertex3f(i, j, GRIDSIZE);
					fn.glVertex3f(-GRIDSIZE, j, i);
					fn.glVertex3f(GRIDSIZE, j, i);
					fn.glVertex3f(j, -GRIDSIZE, i);
					fn.glVertex3f(j, GRIDSIZE, i);
			}

			fn.glVertex3f(-10.0f,0.0f,0.0f);
			fn.glVertex3f(10.0f,0.0f,0.0f);
		fn.glEnd();

		
		
		if (current_effect==0)
		{
			GRID_DECAY=0.01f;
			GRID_THRESHOLD=0.01f;
			do_snake();
		}
		else if (current_effect==1)
		{
			GRID_DECAY=0.18f;
			GRID_THRESHOLD=0.01f;
			do_bigcube(12,sin(t),cos(t),sin(t)*cos(t),50.0f*t);
			do_bigcube(cube_size,cos(t),sin(t),sin(2*t)*cos(t),50.0f*t);
		}
		else
		
		{
			GRID_DECAY=0.1f;
			GRID_THRESHOLD=0.05f;
			do_metaballs();
		}	
		
#ifdef TEXTOS	
		if (cur_row == 0)
		{
			i=cur_pos%NTEXTOS;
			draw_text(textos[i].texto,
				textos[i].px, textos[i].py, textos[i].pz);
		}
#endif	
		
		for (int x=0; x<ARRAYSIZE; ++x)
			for (int y=0; y<ARRAYSIZE; ++y)
				for (int z=0; z<ARRAYSIZE; ++z)
				{
					float alpha=grid_state[x][y][z];
					if (alpha > GRID_THRESHOLD)
					{
						draw_cube(GRIDSTEP*(x-HALFARRAY),
								GRIDSTEP*(y-HALFARRAY),
								GRIDSTEP*(z-HALFARRAY), 
								GRIDSTEP, alpha);
					}
					grid_state[x][y][z] -= GRID_DECAY;
					if (grid_state[x][y][z] < 0.0f) grid_state[x][y][z]=0.0f;
				}

#ifdef TEXTOS
		fn.glRotatef(textos[i].angle, textos[i].rx, textos[i].ry, textos[i].rz);
		for (int x=0; x<ARRAYSIZE; ++x)
			for (int y=0; y<ARRAYSIZE; ++y)
				for (int z=0; z<ARRAYSIZE; ++z)
				{
					float alpha=grid_text[x][y][z];
					if (alpha > 0.01f)
					{
						grid_text[x][y][z] -= 0.1f;
						draw_cube(GRIDSTEP*(x-HALFARRAY),
								GRIDSTEP*(y-HALFARRAY),
								GRIDSTEP*(z-HALFARRAY), 
								GRIDSTEP, alpha);
					}
				}
#endif
		fn.glColor4f(0,0,0,fade);
		fn.glMatrixMode(GL_MODELVIEW);
		fn.glLoadIdentity();
		fn.glMatrixMode(GL_PROJECTION);
		fn.glLoadIdentity();		
		fullscreenquad();
		fn.SDL_GL_SwapBuffers();
	}
fin:

	fn.SDL_Quit();

#ifdef OUTFILE
	fclose(fout);
#endif

	
#if 1
	__asm__("xorl %eax, %eax\n\t"
	    "incl %eax\n\t"
	    "int $0x80\n\t");
#else
	exit(0);
#endif
}
