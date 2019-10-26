#include <stdio.h>
#include <stdlib.h>

#define _USE_MATH_DEFINES
#include <math.h>

#if defined(WIN32)
#define USE_LD
#include "windows.h"
#include "GL/glew.h"
#include "GL/gl.h"
#include "GL/glext.h"
#include "GL/wglext.h"
#elif !defined(MODE_REL)
#include "config.h"
#endif

#if defined(MODE_REL)
#define SFUNCTION __attribute__((regparm(3))) static
#define SCONST static
#else
#define SFUNCTION static
#define SCONST static const
#endif

#include "SDL.h"
#if !defined(WIN32)
#include "SDL_opengl.h"
#endif

//######################################
// Loader ##############################
//######################################

#if !defined(WIN32)
#include "dlfcn.h"
#endif

/** Dynamically loaded symbols in one segment. */
static char dnload_symbols[] =
"libGL.so\0"
"glAttachShader\0"
"glBlendFunc\0"
"glClear\0"
"glCompileShader\0"
"glCreateProgram\0"
"glCreateShader\0"
"glDrawElements\0"
"glEnable\0"
"glInterleavedArrays\0"
"glLinkProgram\0"
"glLoadIdentity\0"
"glMatrixMode\0"
"glShaderSource\0"
"glUniform4fv\0"
"glUseProgram\0\0"
"libGLU.so\0"
"gluLookAt\0"
"gluPerspective\0\0"
"libSDL.so\0"
"SDL_GL_SwapBuffers\0"
"SDL_Init\0"
"SDL_PollEvent\0"
"SDL_Quit\0"
"SDL_SetVideoMode\0\0";

#define dcosf cosf
#define dsinf sinf
#define dsqrtf sqrtf

#define dnload_pointer(offset) (*((void**)(dnload_symbols + offset)))

#if defined(USE_LD)

#define dlAttachShader glAttachShader
#define dlBlendFunc glBlendFunc
#define dlClear glClear
#define dlCompileShader glCompileShader
#define dlCreateProgram glCreateProgram
#define dlCreateShader glCreateShader
#define dlDrawElements glDrawElements
#define dlEnable glEnable
#define dlInterleavedArrays glInterleavedArrays
#define dlLinkProgram	glLinkProgram
#define dlLoadIdentity glLoadIdentity
#define dlMatrixMode glMatrixMode
#define dlShaderSource glShaderSource
#define dlUniform4fv glUniform4fv
#define dlUseProgram glUseProgram

#define dluLookAt gluLookAt
#define dluPerspective gluPerspective

#define DDL_GL_SwapBuffers SDL_GL_SwapBuffers
#define DDL_Init SDL_Init
#define DDL_PollEvent SDL_PollEvent
#define DDL_SetVideoMode SDL_SetVideoMode
#define DDL_Quit SDL_Quit

#else

#define dlAttachShader ((void (*)(GLuint, GLuint))(dnload_pointer(0)))
#define dlBlendFunc ((void (*)(GLenum, GLenum))(dnload_pointer(9)))
#define dlClear ((void (*)(GLbitfield))(dnload_pointer(24)))
#define dlCompileShader ((void (*)(GLuint))(dnload_pointer(36)))
#define dlCreateProgram ((GLuint (*)(void))(dnload_pointer(44)))
#define dlCreateShader ((GLuint (*)(GLenum))(dnload_pointer(60)))
#define dlDrawElements ((void (*)(GLenum, GLsizei, GLenum, const GLvoid*))(dnload_pointer(76)))
#define dlEnable ((void (*)(GLenum))(dnload_pointer(91)))
#define dlInterleavedArrays ((void (*)(GLenum, GLsizei, const GLvoid*))(dnload_pointer(106)))
#define dlLinkProgram ((void (*)(GLuint))(dnload_pointer(115)))
#define dlLoadIdentity ((void (*)(void))(dnload_pointer(135)))
#define dlMatrixMode ((void (*)(GLenum))(dnload_pointer(149)))
#define dlShaderSource ((void (*)(GLuint, GLsizei, const GLchar**, const GLint*))(dnload_pointer(164)))
#define dlUniform4fv ((void (*)(GLint, GLsizei, const GLfloat*))(dnload_pointer(177)))
#define dlUseProgram ((void (*)(GLuint))(dnload_pointer(192)))

#define dluLookAt ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble))(dnload_pointer(219)))
#define dluPerspective ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble))(dnload_pointer(229)))

#define DDL_GL_SwapBuffers ((void (*)())(dnload_pointer(255)))
#define DDL_Init ((int (*)(Uint32))(dnload_pointer(265)))
#define DDL_PollEvent ((int (*)(SDL_Event*))(dnload_pointer(284)))
#define DDL_Quit ((void (*)())(dnload_pointer(293)))
#define DDL_SetVideoMode ((SDL_Surface* (*)(int, int, int, Uint32))(dnload_pointer(307)))

#endif

//######################################
// Define ##############################
//######################################

#define SWAN_RADIUS 50.0f
#define TRIANGLE_SIZE 20.0f
#define INITIAL_R 24.0f
#define INITIAL_H 20.0f
#define SWAN_LAYER_ANGLE_STEP 8.0f

#define CAGE_RADIUS SWAN_RADIUS*2.5f
#define CAGE_DETAIL 200
#define CAGE_HEIGHT SWAN_RADIUS*1.5f
#define CAGE_BAR_THICKNESS 1.0f

#define TABLE_DETAIL 200
#define TABLE_HEIGHT 300.0f
#define TABLE_FOOT_RADIUS 40.0f

#define TABLE_RADIUS 200.0f
#define TABLE_SIDE_RADIUS 10.0f
#define TABLE_FLAT_PART_LEN 40.0f

#define NEWTON_DETAIL 1000

#define DRAW_HEAP 8*(NEWTON_DETAIL * NEWTON_DETAIL)

//######################################
// Types ###############################
//######################################

typedef struct {
	float x,y,z;
} point;

typedef struct iarray_struct
{
	float cr;
	float cg;
	float cb;
	float ca;
	float nx;
	float ny;
	float nz;
	float px;
	float py;
	float pz;
} interleaved_array;

static interleaved_array draw_array[DRAW_HEAP];
static GLuint index_array[DRAW_HEAP * 4];

static interleaved_array *diter = draw_array; 
static GLuint iiter = 0;

//######################################
// OpenGL draw #########################
//######################################

/* Cross Product */
SFUNCTION void CrossProduct(point *i1, point *i2, point *dst)
{
	dst->x = i1->y * i2->z - i1->z * i2->y;
	dst->y = i1->z * i2->x - i1->x * i2->z;
	dst->z = i1->x * i2->y - i1->y * i2->x;

	{
		float len = (float)dsqrtf(dst->x * dst->x + dst->y * dst->y + dst->z * dst->z);

		dst->x /= len;
		dst->y /= len;
		dst->z /= len;
	}
}

SFUNCTION void Draw_One_Triangle(point *p1, point *p2, point *p3)
{
	point p4, p5;

	diter[0].px = p1->x;
	diter[0].py = p1->y;
	diter[0].pz = p1->z;

	diter[1].px = p2->x;
	diter[1].py = p2->y;
	diter[1].pz = p2->z;

	diter[2].px = p3->x;
	diter[2].py = p3->y;
	diter[2].pz = p3->z;

	p4.x = p2->x - p1->x;
	p4.y = p2->y - p1->y;
	p4.z = p2->z - p1->z;
	
	p5.x = p3->x - p1->x;
	p5.y = p3->y - p1->y;
	p5.z = p3->z - p1->z;

	CrossProduct(&p4, &p5, (point*)(&(diter[0].nx)));
	diter[2].nx = diter[1].nx = diter[0].nx;
	diter[2].ny = diter[1].ny = diter[0].ny;
	diter[2].nz = diter[1].nz = diter[0].nz;

#if 0
	diter[0].nx = p4.y * p5.z - p4.z * p5.y;
	diter[0].ny = p4.z * p5.x - p4.x * p5.z;
	diter[0].nz = p4.x * p5.y - p4.y * p5.x;

	diter[2].nx = diter[1].nx = diter[0].nx;
	diter[2].ny = diter[1].ny = diter[0].ny;
	diter[2].nz = diter[1].nz = diter[0].nz;
#endif

	diter[0].cr = diter[1].cr = diter[2].cr = 1.0f;
	diter[0].cg = diter[1].cg = diter[2].cg = 1.0f;
	diter[0].cb = diter[1].cb = diter[2].cb = 1.0f;
	diter[0].ca = diter[1].ca = diter[2].ca = 1.0f;

	index_array[iiter] = iiter++;
	index_array[iiter] = iiter++;
	index_array[iiter] = iiter++;
	diter += 3;
}

/* Let's draw a paper triangle */
SFUNCTION void Draw_Paper_Triangle(point *head, point *base, point *flapL, point *flapR)
{
	Draw_One_Triangle(head, base, flapL);

	Draw_One_Triangle(head, flapR, base);

	Draw_One_Triangle(head, flapL, flapR);

	Draw_One_Triangle(base, flapR, flapL);
}

SFUNCTION void Draw_Flap_Circle(float r_base, float h_base, float r_head,
		float h_head, float r_flaps, float h_flaps, int flaps, float begin,
		float end)
{
	point base, head, flapL, flapR;
	float angle_unit;
	int i;
	begin = (float)(begin*M_PI/120.0);
	end = (float)(end*M_PI/120.0);
	//begin = (float)(begin*M_PI/180.0);
	//end = (float)(end*M_PI/180.0);

	// Katsotaanpa kuinka auki kukin paperikolmio on
	angle_unit = (end-begin) / (2*(float)flaps);

	for(i=0; i<flaps; i++)
	{
		base.x = r_base*(float)dcosf(begin+(i*2+1)*angle_unit);
		base.y = h_base;
		base.z = r_base*(float)dsinf(begin+(i*2+1)*angle_unit);
		head.x = r_head*(float)dcosf(begin+(i*2+1)*angle_unit);
		head.y = h_head;
		head.z = r_head*(float)dsinf(begin+(i*2+1)*angle_unit);
		flapL.x = r_flaps*(float)dcosf(begin+i*2*angle_unit);
		flapL.y = h_flaps;
		flapL.z = r_flaps*(float)dsinf(begin+i*2*angle_unit);
		flapR.x = r_flaps*(float)dcosf(begin+(i+1)*2*angle_unit);
		flapR.y = h_flaps;
		flapR.z = r_flaps*(float)dsinf(begin+(i+1)*2*angle_unit);
		Draw_Paper_Triangle(&head, &base, &flapL, &flapR);
	}
}

SCONST unsigned char neck_position_data[] =
{
	 8, 0,
	17, 5,
	26, 11,
	32, 18,
	36, 27,
	39, 35,
	40, 46,
	39, 54,
	37, 64,
	34, 73,
	29, 82,
	24, 89,
	18, 98,
	12, 105,
	 6, 113,
	 2, 122,
	 0, 132,
	 1, 142,
	 4, 150,
	10, 156,
	17, 160,
	25, 162,
	35, 161,
	45, 157
};

/*static const unsigned short int neck_angle_data[] =
{
	
   341,
     0,
     9,
    25,
    48,
    47,
    57,
    67,
    75,
    84,
    93,
    95,
    96,
    94,
    86,
    75,
    58,
    41,
    28,
    11,
   348,
   334,
   311,
   293
};*/

SCONST unsigned char neck_angle_data[] =
{
   227,
     0,
     6,
    17,
    32,
    35,
    39,
    45,
    50,
    56,
    62,
    63,
    64,
    63,
    57,
    50,
    39,
    27,
    19,
     7,
   232,
   223,
   207,
   195
};

SFUNCTION void Draw_Neck(float x, float y, float z)
{
	point base, head, flapL, flapR;
	double angle;
	int i;
	for(i=0; i<24; i++)
	{
		//angle = (float)(neck_angle_data[i]*M_PI/180.0);
		angle = (float)(neck_angle_data[i]*M_PI/120.0f);
		base.x = x + neck_position_data[i*2+0];
		base.y = y + neck_position_data[i*2+1];
		base.z = z;
		head.x = base.x + TRIANGLE_SIZE*(float)dsinf(angle);
		head.y = base.y - TRIANGLE_SIZE*(float)dcosf(angle);
		head.z = base.z;
		
		flapL.x = base.x + TRIANGLE_SIZE*(float)dcosf(angle);
		flapL.y = base.y + TRIANGLE_SIZE*(float)dsinf(angle);
		flapL.z = base.z - (0.4f - i/80.0f)*TRIANGLE_SIZE;
		
		flapR.x = flapL.x;
		flapR.y = flapL.y;
		flapR.z = base.z + (0.4f - i/80.0f)*TRIANGLE_SIZE;
		Draw_Paper_Triangle(&head, &base, &flapL, &flapR);
	}
}

/** Cylinder detail leve. */
#define CYLINDER_DETAIL 100

/** Cylinder step variable. */
#define CYLINDER_STEP (float)(2.0f*M_PI/(float)CYLINDER_DETAIL)

/* Draw a cylinder */
SFUNCTION void Draw_Cylinder(point *begin, point *end, float r1, float r2)
{
	// Calculate two normals for the vector
	point n1,n2,temp1,temp2,temp3,temp4;
	int i;
	temp1.x = end->x - begin->x;
	temp1.y = end->y - begin->y;
	temp1.z = end->z - begin->z;
	temp2.x = temp2.y = temp2.z = 128.0f;
	
	CrossProduct(&temp1, &temp2, &n1);
	CrossProduct(&temp1, &n1, &n2);

	for(i = 0; (i < CYLINDER_DETAIL); i++)
	{
		float	tmpi = i * CYLINDER_STEP,
					ci = dcosf(tmpi),
					si = dsinf(tmpi),
					ci1 = dcosf(tmpi + CYLINDER_STEP),
					si1 = dsinf(tmpi + CYLINDER_STEP);					
		temp1.x = begin->x + r1 * (n1.x * ci + n2.x * si);
		temp1.y = begin->y + r1 * (n1.y * ci + n2.y * si);
		temp1.z = begin->z + r1 * (n1.z * ci + n2.z * si);
		temp2.x = begin->x + r1 * (n1.x * ci1 + n2.x * si1);
		temp2.y = begin->y + r1 * (n1.y * ci1 + n2.y * si1);
		temp2.z = begin->z + r1 * (n1.z * ci1 + n2.z * si1);
		temp3.x = end->x + r2 * (n1.x * ci + n2.x * si);
		temp3.y = end->y + r2 * (n1.y * ci + n2.y * si);
		temp3.z = end->z + r2 * (n1.z * ci + n2.z * si);
		temp4.x = end->x + r2 * (n1.x * ci1 + n2.x * si1);
		temp4.y = end->y + r2 * (n1.y * ci1 + n2.y * si1);
		temp4.z = end->z + r2 * (n1.z * ci1 + n2.z * si1);

		//Muista tsekata tämä -> kaksi funktiokutsua veke
		Draw_One_Triangle(&temp1,&temp2,&temp3);
		Draw_One_Triangle(&temp2,&temp1,&temp3);

		Draw_One_Triangle(&temp2,&temp3,&temp4);
		Draw_One_Triangle(&temp2,&temp4,&temp3);
	}
}

#define BUFFER_SIZE 1024

//static float buffer_variable[BUFFER_SIZE];

/* Draw the Cage */
/*static void Draw_Cage(int sectionsx, int sectionsy)
{
	point temp[BUFFER_SIZE];
	float temporary1, temporary2;
	int i,j;
	//Pillars up
	for(j=0; j<=sectionsy; j++)
	{
		for(i=0; i<=sectionsx; i++)
		{
			temporary1 = (float)(i*2*M_PI/(float)sectionsx);
			temp[j*sectionsx+i].x = CAGE_RADIUS*(float)dcosf(temporary1);
			temp[j*sectionsx+i].z = CAGE_RADIUS*(float)dsinf(temporary1);
			temp[j*sectionsx+i].y = j*CAGE_HEIGHT;
			if(i>0)
			{
				Draw_Cylinder(&temp[j*sectionsx+i],&temp[j*sectionsx+i-1],CAGE_BAR_THICKNESS,CAGE_BAR_THICKNESS);
			}
			if(j>0)
			{
				Draw_Cylinder(&temp[(j-1)*sectionsx+i],&temp[j*sectionsx+i],CAGE_BAR_THICKNESS,CAGE_BAR_THICKNESS);
			}
			else
			{
				temp[i+1].x = temp[i+1].y = temp[i+1].z = 0.0;
				Draw_Cylinder(&temp[i],&temp[i+1],CAGE_BAR_THICKNESS,CAGE_BAR_THICKNESS);
			}
		}
	}
	//Round roof
	for(j=0; j<=CAGE_DETAIL; j++)
	{
		for(i=0; i<sectionsx; i++)
		{
			temporary1 = (float)(i*2*M_PI/(float)sectionsx);
			temporary2 = (float)(j*(M_PI/2.0)/CAGE_DETAIL);
			temp[j*sectionsx+i].x = CAGE_RADIUS*(float)(dcosf(temporary2)*dcosf(temporary1));
			temp[j*sectionsx+i].z = CAGE_RADIUS*(float)(dcosf(temporary2)*dsinf(temporary1));
			temp[j*sectionsx+i].y = (sectionsy+(float)dsinf(temporary2))*CAGE_HEIGHT;
			if(j>0)
			{
				Draw_Cylinder(&temp[(j-1)*sectionsx+i],&temp[j*sectionsx+i],CAGE_BAR_THICKNESS,CAGE_BAR_THICKNESS);
			}
		}
	}
}*/

/* Draw the Cage */
SFUNCTION void Draw_Cage(int sectionsx, int sectionsy)
{
	point temp1,temp2;
	int i,j;
	//Pillars up
	for(j=0; j<sectionsy; j++)
	{
		for(i=0; i<sectionsx; i++)
		{
			temp1.x = CAGE_RADIUS*(float)dcosf(i*2*M_PI/(float)sectionsx);
			temp1.z = CAGE_RADIUS*(float)dsinf(i*2*M_PI/(float)sectionsx);
			temp1.y = j*CAGE_HEIGHT;
			temp2.x = temp2.y = temp2.z = 0.0;
			if(j==0)
			{
				Draw_Cylinder(&temp1,&temp2,CAGE_BAR_THICKNESS,CAGE_BAR_THICKNESS);
			}
			temp2.x = temp1.x;
			temp2.z = temp1.z;
			temp2.y = (j+1)*CAGE_HEIGHT;
			Draw_Cylinder(&temp1,&temp2,CAGE_BAR_THICKNESS,CAGE_BAR_THICKNESS);
			temp1.x = CAGE_RADIUS*(float)dcosf((i+1)*2*M_PI/(float)sectionsx);
			temp1.z = CAGE_RADIUS*(float)dsinf((i+1)*2*M_PI/(float)sectionsx);
			temp1.y = (j+1)*CAGE_HEIGHT;
			Draw_Cylinder(&temp1,&temp2,CAGE_BAR_THICKNESS,CAGE_BAR_THICKNESS);
			if(j==0)
			{
				temp1.y=temp2.y=0;
				Draw_Cylinder(&temp1,&temp2,CAGE_BAR_THICKNESS,CAGE_BAR_THICKNESS);
			}
		}
	}
	//Round roof
	for(j=0; j<CAGE_DETAIL; j++)
	{
		for(i=0; i<sectionsx; i++)
		{
			temp1.x = (float)dcosf(j*(M_PI/2.0)/CAGE_DETAIL)*CAGE_RADIUS*(float)dcosf(i*2*M_PI/(float)sectionsx);
			temp1.z = (float)dcosf(j*(M_PI/2.0)/CAGE_DETAIL)*CAGE_RADIUS*(float)dsinf(i*2*M_PI/(float)sectionsx);
			temp1.y = (sectionsy+(float)dsinf(j*(M_PI/2.0)/CAGE_DETAIL))*CAGE_HEIGHT;
			temp2.x = (float)dcosf((j+1)*(M_PI/2.0)/CAGE_DETAIL)*CAGE_RADIUS*(float)dcosf(i*2*M_PI/(float)sectionsx);
			temp2.z = (float)dcosf((j+1)*(M_PI/2.0)/CAGE_DETAIL)*CAGE_RADIUS*(float)dsinf(i*2*M_PI/(float)sectionsx);
			temp2.y = (sectionsy+(float)dsinf((j+1)*(M_PI/2.0)/CAGE_DETAIL))*CAGE_HEIGHT;
			Draw_Cylinder(&temp1,&temp2,CAGE_BAR_THICKNESS,CAGE_BAR_THICKNESS);
		}
	}
}

/* Draw s foot of the table */
SFUNCTION void Draw_Table_Foot(float x, float z)
{
	int i;
	point begin, end;
	float tableprofile[TABLE_DETAIL];
	for(i=0; i<TABLE_DETAIL; i++)
	{
		float t = (float)(2*M_PI*i/TABLE_DETAIL);
		tableprofile[i] = 0.4f+0.2f*dcosf(t) + 0.02f*dcosf(M_PI/2+t*5);
	}
	for(i=0; i<TABLE_DETAIL-1; i++)
	{
		begin.x = end.x = x;
		begin.z = end.z = z;
		begin.y = -TABLE_HEIGHT*(1-i/(float)TABLE_DETAIL);
		end.y = -TABLE_HEIGHT*(1-(i+1)/(float)TABLE_DETAIL);
		Draw_Cylinder(&begin, &end, TABLE_FOOT_RADIUS*tableprofile[i], TABLE_FOOT_RADIUS*tableprofile[i+1]);
	}
}

/* Draw the round table */
SFUNCTION void Draw_Table()
{
	int i;
	point begin, end;
	float tempy[BUFFER_SIZE];
	float tempr[BUFFER_SIZE];
	for(i=0; i<5; i++)
	{
		Draw_Table_Foot((TABLE_RADIUS + (TABLE_SIDE_RADIUS+TABLE_FLAT_PART_LEN)/2)*(float)dcosf(-0.2+i*2*M_PI/5), (TABLE_RADIUS + (TABLE_SIDE_RADIUS+TABLE_FLAT_PART_LEN)/2)*(float)dsinf(-0.2+i*2*M_PI/5));
	}
	for(i=0; i<=TABLE_DETAIL; i++)
	{
		float temporary = (float)(i*2*M_PI/TABLE_DETAIL);
		tempy[i] = -2.0f + TABLE_SIDE_RADIUS*(float)dsinf(temporary);
		tempr[i] = TABLE_RADIUS + TABLE_SIDE_RADIUS*(float)dcosf(temporary);
		if((i<=TABLE_DETAIL/4)||(i>3*TABLE_DETAIL/4))
		{
			tempr[i]+=TABLE_FLAT_PART_LEN;
		}
		if(i>0)
		{
			begin.x = end.x = 0.0;
			begin.z = end.z = 0.0;
			begin.y = tempy[i-1];
			end.y = tempy[i];
			Draw_Cylinder(&begin, &end, tempr[i-1], tempr[i]);
		}
	}
}

SCONST unsigned char section_amount_data[] =
{
	30, 0, 0,
	30, 0, 0,
	30, 0, 0,
	30, 0, 0,
	30, 0, 0,
	27, 0, 0,
	26, 0, 0,
	10, 10, 3,
	9, 9, 2,
	8, 8, 1,
	7, 7, 0,
	6, 6, 0,
	5, 5, 0,
	4, 4, 0,
	3, 3, 0,
	2, 2, 0,
	1, 1, 0
};

/*static const unsigned short int section_angle_data[] =
{
	6, 0, 0, 366, 0, 0,
	0, 0, 0, 360, 0, 0,
	6, 0, 0, 366, 0, 0,
	0, 0, 0, 360, 0, 0,
	6, 0, 0, 366, 0, 0,
	24, 0, 0, 348, 0, 0,
	30, 0, 0, 342, 0, 0,
	36, 216, 168, 156, 336, 204,
	42, 222, 174, 150, 330, 198,
	48, 228, 180, 144, 324, 192,
	54, 234, 0, 138, 318, 0,
	60, 240, 0, 132, 312, 0,
	66, 246, 0, 126, 306, 0,
	72, 252, 0, 120, 300, 0,
	78, 258, 0, 114, 294, 0,
	84, 264, 0, 108, 288, 0,
	90, 270, 0, 102, 282, 0
};*/

SCONST unsigned char section_angle_data[] =
{
     4,     0,     0,   244,     0,     0,
     0,     0,     0,   240,     0,     0,
     4,     0,     0,   244,     0,     0,
     0,     0,     0,   240,     0,     0,
     4,     0,     0,   244,     0,     0,
    16,     0,     0,   232,     0,     0,
    20,     0,     0,   228,     0,     0,
    24,   144,   112,   104,   224,   136,
    28,   148,   116,   100,   220,   132,
    32,   152,   120,    96,   216,   128,
    36,   156,     0,    92,   212,     0,
    40,   160,     0,    88,   208,     0,
    44,   164,     0,    84,   204,     0,
    48,   168,     0,    80,   200,     0,
    52,   172,     0,    76,   196,     0,
    56,   176,     0,    72,   192,     0,
    60,   180,     0,    68,   188,     0
};

/* Scene to screen */
SFUNCTION void Draw_Swan()
{
	int i,j;
	float base_r, base_h, head_r, head_h, flaps_r, flaps_h;
	// Draw the body
	for(i=0; i<17; i++)
	{
		
		if(i<8)
		{
			base_r = INITIAL_R+SWAN_RADIUS*(float)dsinf(M_PI*i/16.0);
			base_h = INITIAL_H+SWAN_RADIUS*(-(float)dcosf(M_PI*i/16.0)+1);
		}
		else
		{
			base_r = INITIAL_R+0.6f*SWAN_RADIUS + 0.4f*SWAN_RADIUS*(float)dsinf(M_PI/2 + M_PI*(i-8)/10.0);
			base_h = INITIAL_H+(((float)i-8.0f)/6.0f + 1.0f)*SWAN_RADIUS;
		}
		head_r = base_r + TRIANGLE_SIZE*(float)dsinf(i*M_PI*SWAN_LAYER_ANGLE_STEP/180);
		head_h = base_h - TRIANGLE_SIZE*(float)dcosf(i*M_PI*SWAN_LAYER_ANGLE_STEP/180);
		flaps_r = base_r + TRIANGLE_SIZE*(float)dcosf(i*M_PI*SWAN_LAYER_ANGLE_STEP/180);
		flaps_h = base_h + TRIANGLE_SIZE*(float)dsinf(i*M_PI*SWAN_LAYER_ANGLE_STEP/180);

		for(j=0; j<3; j++)
		{
			Draw_Flap_Circle(base_r, base_h, head_r, head_h, flaps_r, flaps_h, section_amount_data[i*3+j], section_angle_data[i*6+j], section_angle_data[i*6+j+3]);
		}
	}
	// Draw the neck
	Draw_Neck(0.9f*SWAN_RADIUS, 0.65f*SWAN_RADIUS, 0.0f);
}

//######################################
// GLSL ################################
//######################################

SCONST char shader_vars[] =
"varying vec3 a;"
"varying vec3 p;"
"varying vec4 c;"
"varying vec3 l;"
"varying vec3 n;"
"varying vec3 r;"
"varying vec3 v;"
"vec2 m(vec2 i1, vec2 i2){"
"return vec2(i1.x*i2.x-i1.y*i2.y,i1.x*i2.y+i1.y*i2.x);}"
"vec2 w(vec2 i1){"
"int i=0;"
"vec2 i2;"
"while(i<64){"
"i2=m(i1,i1);"
"i2=m(i2,i2);"
"i2=m(i2,i2);"
"i1=i2+i1;"
"float c=i/64.0;"
"if(length(i1)>4)return vec2(float(i),c);"
"++i;}}"
"vec3 f(float s,float t){";

SCONST char shader_funcs_newton[] =
"vec2 i;"
"i.x=(s-500)/400;"
"i.y=(t-500)/400;"
"i=w(i)-w(i*1.2)+w(i*1.4)-w(i*1.6)+w(i*1.8);"
"c.r=c.g=0.4*i.y;"
"c.b=0.5*i.y;"
"c.a=i.y*16;"
"return vec3((s-500)*0.375,2*sqrt(i.x)/8.0-2.0,(t-500)*0.375);}"
"vec4 e(vec4 c){"
"return c*0.5";
/*
static const char shader_funcs_table[] =
"c.r=0.9;"
"c.g=0.85;"
"c.b=0.8;"
"return vec3(s-790,-52.0+50*sin((1.0+clamp((abs(s-500.0)-450.0)/50.0,0.0,1.0)+clamp((abs(t-500.0)-450.0)/50.0,0.0,1.0))*3.1492/2.0),t*0.75-530)";
*/
SCONST char shader_funcs_cage[] =
"return a.xyz;}"
"vec4 e(vec4 c){"
"c.r=0.93;"
"c.g=0.91;"
"c.b=0.82;"
"return c";

SCONST char shader_funcs_glass[] =
"return a.xyz;}"
"vec4 e(vec4 c){"
"c.r=0.8;"
"c.g=0.8;"
"c.b=1.0;"
"c.a=0.15;"
"return c";

SCONST char shader_funcs_neutral[] =
"return a.xyz;}"
"vec4 e(vec4 c){"
"return c";

SCONST char shader_funcs_table[] =
"return a.xyz;}"
"vec4 e(vec4 c){"
"c.r=0.63;"
"c.g=0.60;"
"c.b=0.52;"
"return c";

SCONST char shader_front[] =
";}void main(){";

SCONST char shader_vertex[] =
"a=gl_Vertex.xyz;"
"n=gl_Normal;"
"c=gl_Color;"

"if(length(n)<=0){"
"r=f(a.x,a.y);"
"vec3 s=normalize(f(a.x+1.0,a.y)-r);"
"vec3 t=normalize(f(a.x,a.y+1.0)-r);"
"vec3 u=normalize(f(a.x-1.0,a.y)-r);"
"vec3 v=normalize(f(a.x,a.y-1.0)-r);"
"n=normalize(cross(s,v)+cross(v,u)+cross(u,t)+cross(t,s));}"
"else n=normalize(n);"

"a=r;"
"vec4 q=gl_ModelViewProjectionMatrix*vec4(a, 1.0);"
"gl_Position=q;"
"p=q.xyz;"

"l=vec3(75,250,20)-a.xyz;"
//"l=vec3(100.0,250.0,-50.0)-a.xyz;"
"v=vec3(300,300,200)-a.xyz;"
"r=normalize(l);"
"r=2.0*n*dot(r,n)-r;"

"gl_TexCoord[0]=gl_MultiTexCoord0;"
"}";

SCONST char shader_fragment[] =
"vec4 g=e(c);"
"g.xyz*=clamp(dot(normalize(l),normalize(n)),0.0,1.0);"
"float h=clamp(dot(normalize(v),normalize(r)),0.0,1.0);"
"g.xyz+=h*h*h*h;"
"gl_FragColor=g;"
"}";

static char *shader_parts[] =
{
	shader_vars,
	NULL,
	shader_front,
	NULL
};

SFUNCTION unsigned shader_create(const char *sf, const char *ss, GLenum st)
{
	unsigned ret = dlCreateShader(st);

	shader_parts[1] = (char*)sf;
	shader_parts[3] = (char*)ss;

	dlShaderSource(ret, 4, (const GLchar**)shader_parts, NULL);
	dlCompileShader(ret);
#if defined(USE_LD)
	{
		GLint status;
		glGetShaderiv(ret, GL_COMPILE_STATUS, &status);
		if(status != GL_TRUE)
		{
			char slog[4096];
			GLsizei len;
			glGetShaderInfoLog(ret, 4096, &len, slog);
			puts(slog);
			exit(1);
		}
	}
	printf("GLSL shader with %p and %p: %u\n", sf, ss, ret);
#endif
	return ret;
}

#if defined(USE_LD)
SFUNCTION unsigned program_create(const char *vf)
#else
SFUNCTION void program_create(const char *vf)
#endif
{
	unsigned vi = shader_create(vf, shader_vertex, GL_VERTEX_SHADER),
					 fi = shader_create(vf, shader_fragment, GL_FRAGMENT_SHADER);

	unsigned ret = dlCreateProgram();
	dlAttachShader(ret, vi);
	dlAttachShader(ret, fi);
	dlLinkProgram(ret);
#if defined(USE_LD)
	{
		GLint status;
		glGetProgramiv(ret, GL_LINK_STATUS, &status);
		if(status != GL_TRUE)
		{
			char slog[4096];
			GLsizei len;
			glGetProgramInfoLog(ret, 4096, &len, slog);
			puts(slog);
			exit(1);
		}
	}
	printf("GLSL program with %p compiles to: %u\n", vf, ret);
	return ret;
#endif
}

#if defined(USE_LD)
unsigned program_newton;
unsigned program_cage;
unsigned program_glass;
unsigned program_neutral;
unsigned program_table;
#else
#define program_newton 3
#define program_cage 6
#define program_glass 9
#define program_neutral 12
#define program_table 15
#endif

//######################################
// Draw ################################
//######################################

SFUNCTION void map_grid(unsigned xsize, unsigned ysize)
{
	GLuint *iter = index_array;
	unsigned ii,jj;
	for(ii = 0; (ii < xsize); ++ii)
	{
		for(jj = 0; (jj < ysize); ++jj)
		{
			unsigned idx = ii * ysize + jj;
			interleaved_array *aa = draw_array + idx;

			aa->cr = aa->cg = aa->cb = aa->ca = 1.0f;
			aa->px = (float)ii;
			aa->py = (float)jj;
			aa->nx = aa->ny = aa->nz = 0.0f;
			aa->pz = 0.0f;

			if((ii < xsize - 1) && (jj < ysize - 1))
			{
				iter[0] = idx;
				iter[1] = idx + 1;
				iter[2] = idx + ysize + 1;
				iter[3] = idx + ysize;
				iter += 4;
			}
		}
	}
	dlDrawElements(GL_QUADS, (xsize - 1) * (ysize - 1) * 4, GL_UNSIGNED_INT, index_array);
}

SFUNCTION void draw()
{
	point begin, end;
	dlMatrixMode(GL_MODELVIEW);
	dlLoadIdentity();

	dluLookAt(300.0, 300.0, 200.0,
			0.0, 70.0, 0.0,
			0.0, 1.0, 0.0);

	/*glColor4f(1.0, 1.0, 1.0, 1.0);
	glBegin(GL_QUADS);
	glVertex3f(-100.0f, 0.0, -100.0f);
	glVertex3f(100.0f, 0.0, -100.0f);
	glVertex3f(100.0f, 0.0, 100.0f);
	glVertex3f(-100.0f, 0.0, 100.0f);
	glEnd();*/

	//glUseProgram(program_table);
	//map_grid(NEWTON_DETAIL, NEWTON_DETAIL);

	dlUseProgram(program_table);
	Draw_Table();
	dlDrawElements(GL_TRIANGLES, iiter, GL_UNSIGNED_INT, index_array);

	//Draw the goddamn glass
	dlUseProgram(program_glass);
	begin.x = begin.z = end.x = end.z = 0.0;
	begin.y = -2.01f;
	end.y = -2.00f;
	Draw_Cylinder(&begin, &end, TABLE_RADIUS, 0);
	dlDrawElements(GL_TRIANGLES, iiter, GL_UNSIGNED_INT, index_array);

	dlUseProgram(program_newton);
	map_grid(NEWTON_DETAIL, NEWTON_DETAIL);

	// Non-rectangular stuff
	dlUseProgram(program_neutral);
	Draw_Swan();
	dlDrawElements(GL_TRIANGLES, iiter, GL_UNSIGNED_INT, index_array);

	dlUseProgram(program_cage);
	Draw_Cage(20,2);
	dlDrawElements(GL_TRIANGLES, iiter, GL_UNSIGNED_INT, index_array);
}

//######################################
// Main ################################
//######################################

#if defined(__APPLE__)
#define MAINPROG SDL_main
#else
#define MAINPROG main
#endif

#if defined(USE_LD)
/** \brief GNU main function.
 *
 * @param argc Not used.
 * @param argv Not used.
 */
int MAINPROG(int argc_not_in_use, char *argv_not_in_use[])
{
#else
/** Required ELF symbol. */
void *environ;
/** Required ELF symbol. */
void *__progname;
/** \brief Object file starting point.
 */
void _start()
{
#endif

#if !defined(WIN32)
#if defined(USE_LD)
	// This is a replica of the loader to determine function addresses.
	{
		char *iter = (char*)dnload_symbols;
		do {
			for(;;)
			{
				void **olditer = (void**)iter;
				while(*(iter++));
				if(!*(iter))
				{
					break;
				}
				printf("dlfcn symbol offset %s: %i\n", iter, (int)(((char*)olditer) - dnload_symbols));
			}
		} while(*(++iter));
	}
#else
	// Load some symbols.
	{
		char *iter = (char*)dnload_symbols;
		do {
			void *handle = dlopen(iter, RTLD_LAZY);

			for(;;)
			{
				void **olditer = (void**)iter;

				while(*(iter++));
				if(!*(iter))
				{
					break;
				}

				*olditer = dlsym(handle, iter);			
			}
		} while(*(++iter));
	}
#endif
#endif

	//init_Graphics();
	DDL_Init(SDL_INIT_VIDEO);
	DDL_SetVideoMode(1280, 720, 32, SDL_OPENGL);
#if defined(WIN32)
	{
		GLenum err = glewInit();
		if(err != GLEW_OK)
		{
			//problem: glewInit failed, something is seriously wrong
			//sprintf(ErrorMessage, "Error: %s\n", glewGetErrorString(err));
			return -1;
		}
	}
#endif
	
	{
		/* change to the projection matrix and set our viewing volume. */
		dlMatrixMode(GL_PROJECTION);
		dlLoadIdentity();
		dluPerspective(45.0, 1280.0 / 720.0, 1.0, 8192.0);
	}

	{
		dlEnable(GL_CULL_FACE);
		dlEnable(GL_DEPTH_TEST);
		dlEnable(GL_BLEND);
		dlBlendFunc(GL_SRC_ALPHA,	GL_ONE_MINUS_SRC_ALPHA);
		dlInterleavedArrays(GL_C4F_N3F_V3F, 0, draw_array);
	}

#if defined(USE_LD)
	program_newton = program_create(shader_funcs_newton);
	program_cage = program_create(shader_funcs_cage);
	program_glass = program_create(shader_funcs_glass);
	program_neutral = program_create(shader_funcs_neutral);
	program_table = program_create(shader_funcs_table);
#else
	program_create(shader_funcs_newton);
	program_create(shader_funcs_cage);
	program_create(shader_funcs_glass);
	program_create(shader_funcs_neutral);
	program_create(shader_funcs_table);
#endif

	/* wait for events */
	for(;;)
	{
		SDL_Event event;
		if(DDL_PollEvent(&event) && (event.type == SDL_KEYDOWN))
		{
#if defined(USE_LD)
			if(event.key.keysym.sym == SDLK_ESCAPE)
			{
#endif
				break;
#if defined(USE_LD)
			}
#endif
		}

		{
			static unsigned int drawn = 0;
			if(!drawn)
			{
				dlClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
				draw();
				drawn = 1;
			}
		}

		DDL_GL_SwapBuffers();
#if defined(USE_LD)
		SDL_Delay(10);
#endif
	}

	DDL_Quit();
#if !defined(USE_LD)
	asm("movl $1,%eax\nxor %ebx,%ebx\nint $128\n");
#else
	return 0;
#endif
}

//######################################
// End #################################
//######################################

