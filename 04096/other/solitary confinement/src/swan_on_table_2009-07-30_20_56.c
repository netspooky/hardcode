#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define _USE_MATH_DEFINES
#include <math.h>

#ifdef WIN32
#include <windows.h>
#endif

#include <SDL.h>
#include <SDL_opengl.h>

// display functions
//#include "sdlfunctions.h"

//######################################
// Loader ##############################
//######################################

#if !defined(USE_LD)

/** Debug flag for determining correct addresses of dnload shit. */
//#define DNLOAD_DEBUG

#include "dlfcn.h"

/** Dynamically loaded symbols in one segment. */
static char dnload_symbols[] =
"libc.so\0"
"rand\0"
"srand\0\0"
"libm.so\0"
"sinf\0\0"
"libGL.so\0"
"glAttachShader\0"
"glBlendFunc\0"
"glClear\0"
"glCompileShader\0"
"glCreateProgram\0"
"glCreateShader\0"
"glDepthMask\0"
"glDrawElements\0"
"glEnable\0"
"glInterleavedArrays\0"
"glLinkProgram\0"
"glLoadIdentity\0"
"glMatrixMode\0"
"glShaderSource\0"
"glTexEnvi\0"
"glUniform4fv\0"
"glUseProgram\0\0"
"libGLU.so\0"
"gluLookAt\0"
"gluPerspective\0\0"
"libSDL.so\0"
"SDL_GetTicks\0"
"SDL_GL_SwapBuffers\0"
"SDL_Init\0"
"SDL_OpenAudio\0"
"SDL_PauseAudio\0"
"SDL_PollEvent\0"
"SDL_Quit\0"
"SDL_SetVideoMode\0"
"SDL_ShowCursor\0\0";

#define dnload_pointer(offset) (*((void**)(dnload_symbols + offset)))

#define drand ((int (*)(void))dnload_pointer(0))
#define dsrand ((void (*)(unsigned int))dnload_pointer(8))

#define dsinf ((float (*)(float))(dnload_pointer(20)))

#define dlAttachShader ((void (*)(GLuint, GLuint))(dnload_pointer(34)))
#define dlBlendFunc ((void (*)(GLenum, GLenum))(dnload_pointer(43)))
#define dlClear ((void (*)(GLbitfield))(dnload_pointer(58)))
#define dlCompileShader ((void (*)(GLuint))(dnload_pointer(70)))
#define dlCreateProgram ((GLuint (*)(void))(dnload_pointer(78)))
#define dlCreateShader ((GLuint (*)(GLenum))(dnload_pointer(94)))
#define dlDepthMask ((void (*)(GLboolean))(dnload_pointer(110)))
#define dlDrawElements ((void (*)(GLenum, GLsizei, GLenum, const GLvoid*))(dnload_pointer(125)))
#define dlEnable ((void (*)(GLenum))(dnload_pointer(137)))
#define dlInterleavedArrays ((void (*)(GLenum, GLsizei, const GLvoid*))(dnload_pointer(152)))
#define dlLinkProgram ((void (*)(GLuint))(dnload_pointer(161)))
#define dlLoadIdentity ((void (*)(void))(dnload_pointer(181)))
#define dlMatrixMode ((void (*)(GLenum))(dnload_pointer(195)))
#define dlShaderSource ((void (*)(GLuint, GLsizei, const GLchar**, const GLint*))(dnload_pointer(210)))
#define dlTexEnvi ((void (*)(GLenum, GLenum, GLint))(dnload_pointer(223)))
#define dlUniform4fv ((void (*)(GLint, GLsizei, const GLfloat*))(dnload_pointer(238)))
#define dlUseProgram ((void (*)(GLuint))(dnload_pointer(248)))

#define dluLookAt ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble))(dnload_pointer(275)))
#define dluPerspective ((void (*)(GLdouble, GLdouble, GLdouble, GLdouble))(dnload_pointer(285)))

#define DDL_GetTicks ((Uint32 (*)())(dnload_pointer(311)))
#define DDL_GL_SwapBuffers ((void (*)())(dnload_pointer(321)))
#define DDL_Init ((int (*)(Uint32))(dnload_pointer(334)))
#define DDL_OpenAudio ((int (*)(SDL_AudioSpec*, SDL_AudioSpec*))(dnload_pointer(353)))
#define DDL_PauseAudio ((void (*)(int))(dnload_pointer(362)))
#define DDL_PollEvent ((int (*)(SDL_Event*))(dnload_pointer(376)))
#define DDL_Quit ((void (*)())(dnload_pointer(391)))
#define DDL_SetVideoMode ((SDL_Surface* (*)(int, int, int, Uint32))(dnload_pointer(405)))
#define DDL_ShowCursor ((int (*)(int))(dnload_pointer(414)))

#else

#define drand rand
#define dsrand srand

#define dsinf sinf

#define dlAttachShader glAttachShader
#define dlBlendFunc glBlendFunc
#define dlClear glClear
#define dlCompileShader glCompileShader
#define dlCreateProgram glCreateProgram
#define dlCreateShader glCreateShader
#define dlDepthMask glDepthMask
#define dlDrawElements glDrawElements
#define dlEnable glEnable
#define dlInterleavedArrays glInterleavedArrays
#define dlLinkProgram	glLinkProgram
#define dlLoadIdentity glLoadIdentity
#define dlMatrixMode glMatrixMode
#define dlShaderSource glShaderSource
#define dlTexEnvi glTexEnvi
#define dlUniform4fv glUniform4fv
#define dlUseProgram glUseProgram

#define dluLookAt gluLookAt
#define dluPerspective gluPerspective

#define DDL_GetTicks SDL_GetTicks
#define DDL_GL_SwapBuffers SDL_GL_SwapBuffers
#define DDL_Init SDL_Init
#define DDL_OpenAudio SDL_OpenAudio
#define DDL_PauseAudio SDL_PauseAudio
#define DDL_PollEvent SDL_PollEvent
#define DDL_SetVideoMode SDL_SetVideoMode
#define DDL_ShowCursor SDL_ShowCursor
#define DDL_Quit SDL_Quit

#endif

//######################################
// Define ##############################
//######################################

#define SWAN_RADIUS 50.0f
#define TRIANGLE_SIZE 20.0f
#define INITIAL_R 24.0f
#define INITIAL_H 20.0f
#define SWAN_LAYER_ANGLE_STEP 8.0f
#define SWAN_NECK_SCALE_X 1.0f
#define SWAN_NECK_SCALE_Z 1.0f
#define ANGLE_CORR -32.0f

#define FRAC_DIM	2048
#define ITERATIONS	128
#define SCALE	2.0
#define MUL_SCALE	2.0/FRAC_DIM
#define SUB_SCALE	-1.0
#define TEXTURE_ID	13
#define LACE_RADIUS 4*SWAN_RADIUS

//######################################
// Types ###############################
//######################################

typedef struct
{
	unsigned char data[FRAC_DIM*FRAC_DIM*4];
	int h,w;
} fractaldata;

typedef struct
{
	double r, i;
} comp;

typedef struct {
	double x,y,z;
} point;

struct {
	float radius, camz;
} camera;

fractaldata frac;

//######################################
// Complex math ########################
//######################################

comp Comp_Add(comp i1, comp i2)
{
	comp ret;
	ret.r = i1.r + i2.r;
	ret.i = i1.i + i2.i;
	return ret;
}

comp Comp_Add_Double(comp i1, double i2)
{
	comp ret;
	ret.r = i1.r+i2;
	ret.i = i1.i;
	return ret;
}

comp Comp_Div(comp i1, comp i2)
{
	comp ret;
	ret.r = (i1.r*i2.r + i1.i*i2.i) / (pow(i2.r, 2) + pow(i2.i, 2));
	ret.i = (i1.i*i2.r - i1.r*i2.i) / (pow(i2.r, 2) + pow(i2.i, 2));
	return ret;
}

comp Comp_Mul(comp i1, comp i2)
{
	comp ret;
	ret.r = i1.r*i2.r-i1.i*i2.i;
	ret.i = i1.r*i2.i+i1.i*i2.r;
	return ret;
}

comp Comp_Mul_Double(comp i1, double i2)
{
	comp ret;
	ret.r = i1.r*i2;
	ret.i = i1.i*i2;
	return ret;
}

comp Comp_Pow(comp i1, int i2)
{
	comp ret = i1;
	for(int i=1; i<i2; i++)
	{
		ret = Comp_Mul(ret,i1);
	}
	return ret;
}

comp Comp_Sub(comp i1, comp i2)
{
	comp ret;
	ret.r = i1.r - i2.r;
	ret.i = i1.i - i2.i;
	return ret;
}

double Comp_Abs_Square(comp input)
{
	return input.r*input.r+input.i*input.i;
}

//######################################
// Fractal math ########################
//######################################

#if 0
void Calc_Julia(fractaldata *input, double r, double i, double bailout)
{
	comp temp, par;
	par.r = r;
	par.i = i;
	for(int y=0; y<FRAC_DIM; y++)
	{
		for(int x=0; x<FRAC_DIM; x++)
		{
			//input->data[4*(y*FRAC_DIM+x)+0] = (char)genrand_int31()%256;
			//input->data[4*(y*FRAC_DIM+x)+1] = (char)genrand_int31()%256;
			//input->data[4*(y*FRAC_DIM+x)+2] = (char)genrand_int31()%256;
			//input->data[4*(y*FRAC_DIM+x)+3] = (char)genrand_int31()%256;

			temp.r = (double)(MUL_SCALE)*((double)x)+(double)SUB_SCALE;
			temp.i = (double)(MUL_SCALE)*((double)y)+(double)SUB_SCALE;
			for(int i=0; i<ITERATIONS; i++)
			{
				input->data[4*(y*FRAC_DIM+x)+0] = 64;
				input->data[4*(y*FRAC_DIM+x)+1] = 64;
				input->data[4*(y*FRAC_DIM+x)+2] = 255;
				input->data[4*(y*FRAC_DIM+x)+3] = (char)i;
				temp = Comp_Mul(temp, temp);
				temp = Comp_Add(temp, par);
				if(sqrt(Comp_Abs_Square(temp))>bailout)
				{
					//printf("Bailing out at %i\n", i);
					break;
				}
			}
		}
	}
}
#endif

void Calc_Newton(fractaldata *input, int degree, float root, double bailout)
{
	comp temp, tempnew;
	for(int y=0; y<FRAC_DIM; y++)
	{
		for(int x=0; x<FRAC_DIM; x++)
		{
			temp.r = (float)(MUL_SCALE)*((float)x)+(float)SUB_SCALE;
			temp.i = (float)(MUL_SCALE)*((float)y)+(float)SUB_SCALE;
			input->data[4*(y*FRAC_DIM+x)+0] = 64;
			input->data[4*(y*FRAC_DIM+x)+1] = 64;
			input->data[4*(y*FRAC_DIM+x)+2] = 255;
			for(int i=0; i<ITERATIONS; i++)
			{
				tempnew = Comp_Div(Comp_Add_Double(Comp_Mul_Double(Comp_Pow(temp,degree), (double)degree-1.0), root), Comp_Mul_Double(Comp_Pow(temp,degree-1), (double)degree));
				double color = sqrt((double)i)/sqrt((double)ITERATIONS);
				input->data[4*(y*FRAC_DIM+x)+3] = (char)(color*255.0);

				if(sqrt(Comp_Abs_Square(Comp_Sub(temp,tempnew)))<bailout)
				{
					//printf("Bailing out at %i\n", i);
					break;
				}
				temp = tempnew;
			}
		}
	}
}

//######################################
// OpenGL draw #########################
//######################################

void Bind_Texture_Data(fractaldata *input)
{
	glBindTexture (GL_TEXTURE_2D, TEXTURE_ID);
	glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, FRAC_DIM, FRAC_DIM, 0, GL_RGBA, GL_UNSIGNED_BYTE, input->data);
}

void Draw_Lace()
{
	glEnable (GL_TEXTURE_2D); /* enable texture mapping */
	glBindTexture (GL_TEXTURE_2D, TEXTURE_ID); /* bind to our texture, has id of 13 */

	// Fresh start
	glPushMatrix();

	glBegin (GL_QUADS);
	glTexCoord2f (0.0f,0.0f); /* lower left corner of image */
	glVertex3f (-LACE_RADIUS, -LACE_RADIUS, 0.0f);
	glTexCoord2f (1.0f, 0.0f); /* lower right corner of image */
	glVertex3f (LACE_RADIUS, -LACE_RADIUS, 0.0f);
	glTexCoord2f (1.0f, 1.0f); /* upper right corner of image */
	glVertex3f (LACE_RADIUS, LACE_RADIUS, 0.0f);
	glTexCoord2f (0.0f, 1.0f); /* upper left corner of image */
	glVertex3f (-LACE_RADIUS, LACE_RADIUS, 0.0f);
	glEnd ();

	// Fresh start
	glPopMatrix();

	glDisable (GL_TEXTURE_2D); /* disable texture mapping */
}

/* Let's draw a paper triangle */
void Draw_Paper_Triangle(point head, point base, point flapL, point flapR)
{
	// Fresh start
	glPushMatrix();

	// Rotate
	//glRotatef(angle, rx, ry, rz);

	// Translate
	//glTranslatef(x, y, z);

	// Draw
	glBegin(GL_TRIANGLE_STRIP);

	glVertex3d(flapL.x, flapL.y, flapL.z);
	glVertex3d(head.x, head.y, head.z);
	glVertex3d(base.x, base.y, base.z);
	glVertex3d(flapR.x, flapR.y, flapR.z);
	
	glEnd();

	glPopMatrix();

	return;
}

#define UP true
#define DOWN false

void Draw_Flap_Circle(double r_base, double h_base, double r_head, double h_head, double r_flaps, double h_flaps, int flaps, double begin, double end)
{
	begin = M_PI*begin / 180.0;
	end = M_PI*end / 180.0;
	
	point base, head, flapL, flapR;

	// Katsotaanpa kuinka auki kukin paperikolmio on
	double angle_unit = (end-begin) / (2*flaps);

	for(int i=0; i<flaps; i++)
	{
		base.z = h_base;
		base.x = r_base*cos(begin+(i*2+1)*angle_unit);
		base.y = r_base*sin(begin+(i*2+1)*angle_unit);
		head.z = h_head;
		head.x = r_head*cos(begin+(i*2+1)*angle_unit);
		head.y = r_head*sin(begin+(i*2+1)*angle_unit);
		flapR.z = h_flaps;
		flapR.x = r_flaps*cos(begin+i*2*angle_unit);
		flapR.y = r_flaps*sin(begin+i*2*angle_unit);
		flapL.z = h_flaps;
		flapL.x = r_flaps*cos(begin+(i+1)*2*angle_unit);
		flapL.y = r_flaps*sin(begin+(i+1)*2*angle_unit);
		Draw_Paper_Triangle(head, base, flapL, flapR);
	}
}

const float neck_position_data[] =
{
	 8.0, 0.0, 0.0,
	17.0, 0.0, 5.0,
	26.0, 0.0, 11.0,
	32.0, 0.0, 18.0,
	36.0, 0.0, 27.0,
	39.0, 0.0, 35.0,
	40.0, 0.0, 46.0,
	39.0, 0.0, 54.0,
	37.0, 0.0, 64.0,
	34.0, 0.0, 73.0,
	29.0, 0.0, 82.0,
	24.0, 0.0, 89.0,
	18.0, 0.0, 98.0,
	12.0, 0.0, 105.0,
	 6.0, 0.0, 113.0,
	 2.0, 0.0, 122.0,
	 0.0, 0.0, 132.0,
	 1.0, 0.0, 142.0,
	 4.0, 0.0, 150.0,
	10.0, 0.0, 156.0,
	17.0, 0.0, 160.0,
	25.0, 0.0, 162.0,
	35.0, 0.0, 161.0,
	45.0, 0.0, 157.0,
};

const float neck_angle_data[] =
{
	13.0,
	32.0,
	41.0,
	57.0,
	70.0,
	79.0,
	89.0,
	99.0,
	107.0,
	116.0,
	125.0,
	127.0,
	128.0,
	126.0,
	118.0,
	107.0,
	90.0,
	73.0,
	60.0,
	43.0,
	20.0,
	6.0,
	343.0,
	325.0
};

void Draw_Neck(float x, float y, float z)
{
	point base, head, flapL, flapR;
	for(int i=0; i<24; i++)
	{
		base.x = x + SWAN_NECK_SCALE_X*neck_position_data[i*3+0];
		base.y = y + SWAN_NECK_SCALE_X*neck_position_data[i*3+1];
		base.z = z + SWAN_NECK_SCALE_Z*neck_position_data[i*3+2];
		head.x = base.x + TRIANGLE_SIZE*(float)sin(M_PI*(neck_angle_data[i]+ANGLE_CORR)/180.0);
		head.y = base.y;
		head.z = base.z - TRIANGLE_SIZE*(float)cos(M_PI*(neck_angle_data[i]+ANGLE_CORR)/180.0);
		
		flapL.x = base.x + TRIANGLE_SIZE*(float)cos(M_PI*(neck_angle_data[i]+ANGLE_CORR)/180.0);
		flapL.y = base.y - (0.4f - i/80.0f)*TRIANGLE_SIZE;
		flapL.z = base.z + TRIANGLE_SIZE*(float)sin(M_PI*(neck_angle_data[i]+ANGLE_CORR)/180.0);
		
		flapR.x = flapL.x;
		flapR.y = base.y + (0.4f - i/80.0f)*TRIANGLE_SIZE;
		flapR.z = flapL.z;
		Draw_Paper_Triangle(head, base, flapL, flapR);
	}
}

void Setup()
{
	camera.radius=6*SWAN_RADIUS;
	camera.camz=5*SWAN_RADIUS;
	//Calc_Julia(&frac, 0.28f, 0.01f, 16.0);
	Calc_Newton(&frac, 7, 0.05f, 0.000001);
	Bind_Texture_Data(&frac);
}

GLfloat LightAmbient[]= { 0.5f, 0.5f, 0.5f, 1.0f };		// Ambient Light Values ( NEW )
GLfloat LightDiffuse[]= { 1.0f, 1.0f, 1.0f, 1.0f };		// Diffuse Light Values ( NEW )
GLfloat LightPosition[]= { 10.0f, 10.0f, 140.0f, 1.0f };	// Light Position ( NEW )

/* Scene to screen */
void Draw_Scene(int frame)
{

	LightPosition[0] = 80.0f*(float)cos(2*M_PI*frame/120.0);
	LightPosition[1] = 80.0f*(float)sin(2*M_PI*frame/120.0);

	glLightfv(GL_LIGHT1, GL_AMBIENT, LightAmbient);				// Setup The Ambient Light
	glLightfv(GL_LIGHT1, GL_DIFFUSE, LightDiffuse);				// Setup The Diffuse Light
	glLightfv(GL_LIGHT1, GL_POSITION,LightPosition);			// Position The Light
	glEnable(GL_LIGHT1);										// Enable Light One

	// Clear screen
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

	// Clear transformation
	glLoadIdentity();

	// Set Camera
	gluLookAt(camera.radius*(float)cos(2*M_PI*frame/2500.0), camera.radius*(float)sin(2*M_PI*frame/2500.0), camera.camz, 0, 0, 1.2*SWAN_RADIUS, 0, 0, 1);

#if 0
	// Draw the body
	for(int i=0; i<17; i++)
	{
		float base_r, base_h, head_r, head_h, flaps_r, flaps_h;
		//base_r = INITIAL_R+SWAN_RADIUS*(float)sin(i*SWAN_LAYER_ANGLE_STEP*(2.0)*M_PI/180);
		//base_h = INITIAL_H+SWAN_RADIUS*(-(float)cos(i*SWAN_LAYER_ANGLE_STEP*M_PI/180)+1);
		if(i<8)
		{
			base_r = INITIAL_R+SWAN_RADIUS*(float)sin(M_PI*i/16.0);
			base_h = INITIAL_H+SWAN_RADIUS*(-(float)cos(M_PI*i/16.0)+1);
		}
		else
		{
			base_r = INITIAL_R+0.6f*SWAN_RADIUS + 0.4f*SWAN_RADIUS*(float)sin(M_PI/2 + M_PI*(i-8)/10.0);
			base_h = INITIAL_H+(((float)i-8.0f)/6.0f + 1.0f)*SWAN_RADIUS;
		}
		head_r = base_r + TRIANGLE_SIZE*(float)sin(i*M_PI*SWAN_LAYER_ANGLE_STEP/180);
		head_h = base_h - TRIANGLE_SIZE*(float)cos(i*M_PI*SWAN_LAYER_ANGLE_STEP/180);
		flaps_r = base_r + TRIANGLE_SIZE*(float)cos(i*M_PI*SWAN_LAYER_ANGLE_STEP/180);
		flaps_h = base_h + TRIANGLE_SIZE*(float)sin(i*M_PI*SWAN_LAYER_ANGLE_STEP/180);

		if(i<5)
		{
			Draw_Flap_Circle(base_r, base_h, head_r, head_h, flaps_r, flaps_h, 30, 6-(i%2)*6, 366-(i%2)*6);
		}
		else if((i>=5)&&(i<7))
		{
			Draw_Flap_Circle(base_r, base_h, head_r, head_h, flaps_r, flaps_h, 28-(i-4), 18+(i-4)*6, 354-(i-4)*6);
		}
		else if((i>=7)&&(i<10))
		{
			//vasen siipi
			Draw_Flap_Circle(base_r, base_h, head_r, head_h, flaps_r, flaps_h, 10-(i-7), 36+(i-7)*6, 156-(i-7)*6);
			//oikea siipi
			Draw_Flap_Circle(base_r, base_h, head_r, head_h, flaps_r, flaps_h, 10-(i-7), 216+(i-7)*6, 336-(i-7)*6);
			//pyrstö
			Draw_Flap_Circle(base_r, base_h, head_r, head_h, flaps_r, flaps_h, 3-(i-7), 168+(i-7)*6, 204-(i-7)*6);
		}
		else
		{
			//vasen siipi
			Draw_Flap_Circle(base_r, base_h, head_r, head_h, flaps_r, flaps_h, 7-(i-10), 54+(i-10)*6, 138-(i-10)*6);
			//oikea siipi
			Draw_Flap_Circle(base_r, base_h, head_r, head_h, flaps_r, flaps_h, 7-(i-10), 234+(i-10)*6, 318-(i-10)*6);
		}

	}
	// Draw the neck
	Draw_Neck(0.9f*SWAN_RADIUS, 0.0f, 0.65f*SWAN_RADIUS);
#endif
	// Draw lace
	Draw_Lace();

	// Blit to screen
	SDL_GL_SwapBuffers();
}

//######################################
// Main ################################
//######################################

int main(int argc, char* argv[])
{
#if !defined(USE_LD)
	// Load some symbols.
	{
		char *iter = (char*)dnload_symbols;

#if defined(DNLOAD_DEBUG)
		do {
			for(;;)
			{
				void **olditer = (void**)iter;
				while(*(iter++));
				if(!*(iter))
				{
					break;
				}
				printf("DNLOAD_DEBUG: %s: %i\n", iter, (int)(((char*)olditer) - dnload_symbols));
			}
		} while(*(++iter));
		exit(0);
#endif

		do {
			void *handle = dlopen(iter, RTLD_LAZY);

#if defined(USE_LD) || defined(MODE_DEBUG)
			printf("Opened %s for %p\n", iter, handle);
#endif

			for(;;)
			{
				void **olditer = (void**)iter;

				while(*(iter++));
				if(!*(iter))
				{
					break;
				}

				*olditer = dlsym(handle, iter);			

#if defined(USE_LD) || defined(MODE_DEBUG)
				printf("  Loading symbol %s: %p", iter, olditer);
#endif
			}
		} while(*(++iter));
	}
#endif

	//init_Graphics();
	DDL_Init(SDL_INIT_VIDEO);
	DDL_SetVideoMode(1280, 720, 32, SDL_OPENGL);
	DDL_ShowCursor(0);
	
	{
		/* Height / width ration */
		GLfloat ratio;

		/* Setup our viewport. */
		//glViewport(0, 0, (GLint)width, (GLint)height);

		/* change to the projection matrix and set our viewing volume. */
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(45.0f, 1280.0f / 720.0f, 1.0f, 1000.0f);

		/* Make sure we're chaning the model view and not the projection */
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity( );
	}

	{
    /* Enable smooth shading */
    glShadeModel( GL_SMOOTH );

    /* Set the background black */
    glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );

    /* Depth buffer setup */
    glClearDepth( 1.0f );

    /* Enables Depth Testing */
    glEnable( GL_DEPTH_TEST );

    /* The Type Of Depth Test To Do */
    glDepthFunc( GL_LEQUAL );

    /* Really Nice Perspective Calculations */
    glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );

		// antialiased lines
		glEnable(GL_LINE_SMOOTH);

		// Blend function
		glBlendFunc(GL_SRC_ALPHA,	GL_ONE_MINUS_SRC_ALPHA);
		
		// Turn Blending On
		glEnable(GL_BLEND);
		//glDisable(GL_DEPTH_TEST);

		// Lighting
		glEnable(GL_LIGHTING);
	}

	//Initial stuff
	int frame = 0;

	Setup();

	/* wait for events */
	for(;;)
	{
		SDL_Event event;
		if(DDL_PollEvent(&event) && (event.type == SDL_KEYDOWN))
		{
			break;
		}

		Draw_Scene(frame);
		printf("Frame %04i\n", frame);
		//frame++;
	}

	return 0;
}

//######################################
// End #################################
//######################################

