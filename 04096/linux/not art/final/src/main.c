#include <SDL.h>
#include <GL/gl.h>
#include <math.h>
#include <stdlib.h>

#include "dl_init.h"

#define DO_METABALLS
#define FOG
#define FRESNEL

#define FULLSCREEN

#define T_SCENE2 19.0f
#define TOTAL_TIME 80.0f

float flash, _flash;
float last_current_time;
float dtime;
float fade;

#include "synth.h"
extern float current_time;
extern SDL_AudioSpec desired;
//#include "play.c"

#define sin(x) __builtin_sinf(x)
#define cos(x) __builtin_cosf(x)
#define sqrt(x) __builtin_sqrtf(x)
//#define expf(x) __builtin_expf(x)

typedef unsigned char uchar;

SDL_Surface *screen;
int *buffer;


#define MAX_LEVEL 3

#define xres 320
#define yres 240

#define vxres 640
#define vyres 480

#define SQR(a) (a)*(a)

#define resetVector(vector) \
	(vector)->x=0.0f;(vector)->y=0.0f;(vector)->z=0.0f

#define copyVector(dst,src) \
	do{(dst)->x=(src)->x; (dst)->y=(src)->y; (dst)->z=(src)->z;} while (0)


//__attribute__((aligned(16))) 
struct Vector3D {
	float x, y, z;
};


void vecOp(struct Vector3D *a, struct Vector3D *b, float s, struct Vector3D *c)
{
#if 1
	a->x = b->x + s * c->x;
	a->y = b->y + s * c->y;
	a->z = b->z + s * c->z;
#else
	asm volatile(
	"movups (%0), %%xmm0\n"
	"movss (%1), %%xmm1\n"
	"movups (%2), %%xmm2\n"
	"shufps $0, %%xmm1, %%xmm1\n"
	"mulps %%xmm1, %%xmm0\n"
	"addps %%xmm2, %%xmm0\n"
	"movups %%xmm0, (%3)\n"
	:
	:"r"(c), "r"(&s), "r"(b), "r"(a)
	);
#endif
}


struct Ray {
	struct Vector3D position;
	struct Vector3D direction;
};

//__attribute__((aligned(16))) 
struct Sphere {
	float x, y, z;//, w;
	float r, g, b;//, a;
	float ref;
	float r2;
	float r_inv;
	union {
		int texture;
		struct Sphere *sphere;
	};
//	int nSpheres;
};

struct BSphere {
	struct Sphere bounding;
	int first, last;
	int intersected;
};

#define MetaBall BSphere

inline float intersectSphere(const struct Sphere *s, const struct Ray *ray)
{
	float b, c;
	float x2, y2, z2;
#if 1
	x2 = ray->position.x - s->x;
	y2 = ray->position.y - s->y;
	z2 = ray->position.z - s->z;
#else
	asm (
		"movups (%0), %%xmm0\n"
		"movups (%1), %%xmm1\n"
		"subps %%xmm1, %%xmm0\n"
		"movups %%xmm0, (%2)\n"
	:
	:"r"(&(ray->position)), "r"(&(s->x)), "r"(&x2)
	);
#endif

	b = x2 * ray->direction.x + y2 * ray->direction.y + z2 * ray->direction.z;
	c = x2 * x2 + y2 * y2 + z2 * z2 - s->r2;
	float aux = b * b - c;
	
	if(aux < 0) return 0.0f;
	aux = sqrtf(aux);

	float distance = -b - aux;
	if(distance < 0.1f)
	{
		distance = -b + aux;
		if(distance < 0.1f)
			return 0.0f;
	}

	return distance;
}


inline void normalSphere(const struct Sphere *s, const struct Vector3D *point, struct Vector3D *result)
{
#if 1 // 44 bytes
	//asm("nop");
	result->x = s->r_inv * (point->x - s->x);
	result->y = s->r_inv * (point->y - s->y);
	result->z = s->r_inv * (point->z - s->z);
	//asm("nop");
#else // 36 bytes
	asm("nop");
	asm volatile(
		"movups (%0), %%xmm0\n"
		"movups (%1), %%xmm1\n"
		"subps %%xmm1, %%xmm0\n"
		//".set T_FLOAT,4"
		"movss (%2), %%xmm2\n"
		"shufps $0, %%xmm2, %%xmm2\n"
		"mulps %%xmm2, %%xmm0\n"
		"movups %%xmm0, (%3)\n"
	:
	:"r"(point), "r"(s), "r"(&(s->r_inv)), "r"(result)
	);
	asm("nop");
#endif
}

void initSphere(struct Sphere *s, float _x, float _y, float _z, float _r)
{
	s->x = _x;
	s->y = _y;
	s->z = _z;
	s->r2 = _r * _r;
	s->r_inv = 1.0f/_r;

	s->r = s->g = s->b = 1.0f;

	s->ref = 0.0f;
	s->texture = 0;
//	s->nSpheres = 0;
}


int nSpheres;
//int nBSpheres = 0;
#ifdef DO_METABALLS
int nMeta;
#endif//DO_METABALLS
struct Sphere s[60];// = Sphere(0, 0, 50, SQR(5));
//struct Sphere bs[10];
#ifdef DO_METABALLS
struct MetaBall meta;//[10];
#endif//DO_METABALLS
struct Vector3D l;// = Vector3D(0.2, -1, -0.5);

struct Vector3D bg_color = {0.6f, 0.6f, 0.8f};


inline 
void normalize(struct Vector3D *v)
{
	float d = v->x * v->x + v->y * v->y + v->z * v->z;
#if 1
	d = 1.0f / sqrt(d);

	v->x*=d;
	v->y*=d;
	v->z*=d;
#else
	asm (
		"movss (%0), %%xmm0\n"
		"movups (%1), %%xmm1\n"
		"rsqrtss %%xmm0, %%xmm0\n"
		"shufps $0, %%xmm0, %%xmm0\n"
		"mulps %%xmm1, %%xmm0\n"
		"movups %%xmm0, (%1)\n"
	:
	:"r"(&d), "r"(v));
#endif
}

#ifdef DO_METABALLS

inline float evaluate(const struct Sphere *s, const struct Vector3D *point)
{
	struct Vector3D a;
#ifdef copyVector
	copyVector(&a, point);
#else
	a = *point;
#endif
	a.x-= s->x;a.y-= s->y;a.z-= s->z;
	float d = a.x * a.x + a.y * a.y + a.z * a.z;

	if(d < s->r2)
	{
		d/= s->r2;
		float d2 = d * d;
		return 1.0f - 22.0f/9.0f * d + 17.0f/9.0f*(d2) - 4.0f/9.0f*(d2*d2);
	}
	else 
		return 0.0f;
}
	
void normalMetaBall(const struct Vector3D *point, struct Vector3D *result)
{
	int j;
	//float d;

	result->x = 0.0f;
	result->y = 0.0f;
	result->z = 0.0f;

	for(j = meta.first; j < meta.last; j++)
	{
		struct Vector3D a;
#ifdef copyVector
		copyVector(&a, point);
#else
		a = *point;
#endif
		float d;

		a.x-= s[j].x; a.y-= s[j].y; a.z-= s[j].z;
		normalize(&a);
		d = evaluate(&s[j], point);

		if(d != 0.0f)
			vecOp(result, result, d, &a);
	}

	normalize(result);
}

#define SAMPLES 90
#define PREC 0.075

float intersectMetaBall(struct Ray *ray)
{
	struct Vector3D point;
	float min_d = 1e10;
//	float max_d = -1e10;
	float delta = PREC;
	int i; 
	int j;

	if(intersectSphere(&meta.bounding, ray) == 0.0f)
		return 0.0f;

	for(j = meta.first; j < meta.last; j++)
	{
		float d = intersectSphere(&s[j], ray);

		if(d != 0 && d < min_d)
		{
			min_d = d;
			meta.intersected = j;
		}

	}

	if(min_d == 1e10)
		return 0.0f;

	vecOp(&point, &ray->position, min_d, &ray->direction);

	for(i = 0; i < SAMPLES; i++)
	{
		float density = 0.0f;
		for(j = meta.first; j < meta.last; j++)
			density+= evaluate(&s[j], &point);

		if(density > 0.25f)
		{
			break;
		}

		vecOp(&point, &point, delta, &ray->direction);
	}

	if(i != SAMPLES)
		return min_d + (float)i * delta;
	
	return 0.0f;
}

#endif//DO_METABALLS

inline void trace(const struct Ray *ray, struct Vector3D *color, int level)
{
	float d;
	float min_d = 1e10;
	int intersected = -1;
	//int type = 0;
	int i = 0;

	resetVector(color);

	if(level >= MAX_LEVEL)
		return;

	for(i = 0; i < nSpheres; i++)
	{
		d = intersectSphere(&s[i], ray);
		if(d != 0.0f && d < min_d)
		{
			intersected = i;
			min_d = d;
		}
	}
#ifdef DO_METABALLS
	if(nMeta)
	{
		d = intersectMetaBall(ray);
		if(d != 0.0f && d < min_d)
		{
			intersected = meta.intersected;
			min_d = d;
			i = -1;
		}
	}
#endif//DO_METABALLS


	if(intersected == -1)
	{
#ifdef copyVector
		copyVector(color, &bg_color);
#else
		*color = bg_color;
#endif
	}
	else
	{
		float intensity = 0.2f;
		int shadow = 0;

		struct Vector3D point;
		float dif;
		struct Vector3D normal;
		struct Vector3D lightVector;

		vecOp(&point, &(ray->position), min_d, &(ray->direction));

		if(i != -1)
			normalSphere(&s[intersected], &point, &normal);
#ifdef DO_METABALLS
		else
		{
			normalMetaBall(&point, &normal);
		}
#endif//DO_METABALLS
		lightVector.x = 0.17609f;
		lightVector.y = 0.880451f;
		lightVector.z = -0.440225f;

		dif = lightVector.x * normal.x + lightVector.y * normal.y + lightVector.z * normal.z;

		if(dif > 0)
		{
			struct Ray shadow_ray;
			float d;
			int j;
#ifdef copyVector
			copyVector(&shadow_ray.position, &point);
			copyVector(&shadow_ray.direction, &lightVector);
#else
			shadow_ray.position = point;
			shadow_ray.direction = l;
#endif

			for(j = 0; j < nSpheres; j++)
			{
				d = intersectSphere(&s[j], &shadow_ray);

				if(d != 0.0f)
				{
					shadow = 1;
					break;
				}
			}
#ifdef DO_METABALLS
			if(nMeta)
			{
				if(intersectMetaBall(&shadow_ray) != 0.0f)
				{
					shadow = 1;
				}
			}
#endif//DO_METABALLS
		}
		else
			shadow = 1;

		if(!shadow)
			intensity+= dif;

		if(s[intersected].texture != 1)
		{
			vecOp(color, color, intensity, (struct Vector3D *)&s[intersected].r);
		}

		else
		{
			float blah = 0.1f * sin(point.x+current_time) * cos(point.z+current_time);
			struct Vector3D t;
			t.x = s[intersected].r + blah;
			t.y = s[intersected].g + blah;
			t.z = s[intersected].b + blah;

			vecOp(color, color, intensity, &t);
		}

		if(s[intersected].texture == 1)
		{
			normal.x+= 0.1f * fabs(sinf(point.x + current_time)) + 0.05f * fabs(sinf(2*point.x + current_time));
			normal.z+= 0.1f * fabs(sinf(point.z + current_time)) + 0.05f * fabs(sinf(2*point.z + current_time));
			normalize(&normal);
		}

		if(s[intersected].ref != 0.0f)
		{
			struct Ray ray_ref;
			struct Vector3D color_ref;
			float aux = (normal.x * ray->direction.x + normal.y * ray->direction.y + normal.z * ray->direction.z);
#ifdef FRESNEL
			float r =
			r = (1 - s[intersected].ref)*fn.powf(1+aux, 5);
#endif
			aux*= -2.0f;
#ifdef copyVector
			copyVector(&ray_ref.position, &point);
#else
			ray_ref.position = point;
#endif

			vecOp(&ray_ref.direction, &(ray->direction), aux, &normal);

			trace(&ray_ref, &color_ref, level+1);
#ifdef FRESNEL
			vecOp(color,color, s[intersected].ref + r, &color_ref);
#else
			vecOp(color,color, s[intersected].ref, &color_ref);
#endif
		}
		// niebla - fog
#ifdef FOG
{
	float fog_mix = fn.expf(-min_d * 0.05f);//(0.5f + 0.24f * sin(t)));

	color->x = (fog_mix) * color->x + bg_color.x * (1 - fog_mix);//- bg_color.x * fog_mix;
	color->y = (fog_mix) * color->y + bg_color.y * (1 - fog_mix);// - bg_color.y * fog_mix;
	color->z = (fog_mix) * color->z + bg_color.z * (1 - fog_mix);// - bg_color.z * fog_mix;
}
#endif
	}
}

#define putPixel(x, y, color) buffer[x + y * xres] = color;
#define addPixel(x, y, color) buffer[x + y * xres]+= color;

#define RGB(r, g, b)  (b + (g<<8) + (r<<16))

//extern "C" void _start(void);

float frand(void)
{
	return (fn.rand()%100)*0.02f - 1;
}

struct Vector3D dir[32];

void genScene2(void)
{
	int i;

	if(flash > 0.0f)
	{
		nMeta = 0;
		nSpheres = 32;
		for(i = 0; i < 32; i++)
		{
			initSphere(&s[i], 15 * frand(), 15 * frand(), 15 * frand() + 15, 1);
			s[i].r = s[i].g = s[i].b = 0.0f;
			s[i].ref = 0.5f;
			dir[i].x = frand();
			dir[i].y = frand();
			dir[i].z = frand();
		}
	}

	for(i = 0; i < 32; i++)
	{
		vecOp(&s[i], &s[i], dtime, &dir[i]);
	}
}

void genScene1(void)
{
	int i, j;
	float y = (current_time - T_SCENE2 - 35);
	float y2 = 30.0f - (current_time - T_SCENE2);
	if(y > 0) y = 0;
	if(y2 < 2) y2 = 2;

	//nSpheres = nMeta = 0;
	for(i = 0; i < 2; i++)
	initSphere(&s[i], 0, y2, 0, 3);
	//nSpheres++;
	//initSphere(&s[1], -10, y2, 30, 3);
	//nSpheres++;
	initSphere(&s[2], 0, -1005, 30, 1000);
	//nSpheres++;
	nSpheres = 3;
	//s[0].texture = 1;
	s[2].r = 1.0f;
	s[2].g = 0.5f;
	s[2].b = 0.0f;
	s[2].texture = 1;
	s[2].ref = 0.3f;

	s[0].ref = 0.3f;

	for(i = 3; i < 10; i++)
	{
		s[i].ref = 0.2f;
		s[i].r = 0.25f;
		s[i].g = 0.25f;// + 0.4f * sinf(i);
		s[i].b = 0.25f;
	}
#ifdef DO_METABALLS
	nMeta = 1;
	meta.first = 3;
	meta.last = 10;
	initSphere(&meta.bounding, 0, y, 30, 6.5f);
#endif//DO_METABALLS
	
		float sini;
		float cosi;
		asm ("fsincos" : "=t" (cosi), "=u" (sini) : "0" (current_time));

		sini*=10; cosi*=10;
		s[0].x = sini;
		s[0].z = 30 + cosi;

		s[1].x = -sini;
		s[1].z = 30 - cosi;
#ifdef DO_METABALLS
		for(j = 3; j < 10; j++)
		{
			float a = (float)j * 0.1f;

			s[j].x = 2*sin(((float)a+1.33)*current_time) + a;
			s[j].y = y+2.5*sin(((float)a+2.20)*current_time);
			s[j].z = 3*cos(j+current_time)+30;

			s[j].r2 = 10 + 2 * sin(4*current_time+j);
		}
#endif//DO_METABALLS
}

#ifdef DEBUG
int main(int argc, char **argv)
#else
void _start(void)
#endif
{
	struct Ray ray;
	SDL_Event ev;
	int x, y;
	uchar r = 0, g = 0, b = 0;

	dl_init();

	//__builtin_memset(voices, 0, NUM_VOICES*sizeof(Voice));

	fn.SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
#ifndef FULLSCREEN
	screen = fn.SDL_SetVideoMode(xres, yres, 32, SDL_DOUBLEBUF);// | SDL_OPENGL);
#else
	screen = fn.SDL_SetVideoMode(xres, yres, 32, SDL_DOUBLEBUF | SDL_FULLSCREEN);
#endif

	buffer = (int *)screen->pixels;

	fn.SDL_OpenAudio(&desired, NULL);
	fn.SDL_PauseAudio(0);
	fn.SDL_ShowCursor(0);

	ray.position.x = 0.0f;
	ray.position.y = 0.0f;
	ray.position.z = 0.0f;

	while(1)
	{
		float pz = 0;
		_flash = flash;
		last_current_time = current_time;

		while (fn.SDL_PollEvent(&ev))
		{
			if (ev.type==SDL_KEYDOWN)
				goto fin;
		}

		if(current_time < T_SCENE2)
		{
			genScene2();
		}
		else
		{
			genScene1();
			if(current_time > T_SCENE2 + 30)
				pz = current_time - T_SCENE2 - 30;
			if(pz > 7) pz = 7;
		}
		
		// fades
		if(current_time < 5) fade = current_time / 5;
		if(current_time > T_SCENE2 - 5 && current_time < T_SCENE2)
			fade = (T_SCENE2 - current_time) / 5;
		if(current_time > T_SCENE2 && current_time < T_SCENE2 + 5)
			fade = 1 - (5 + T_SCENE2 - current_time) / 5;

		if(current_time > TOTAL_TIME - 5)
			fade = (TOTAL_TIME - current_time) / 5;
		if(current_time > TOTAL_TIME)
			break;

		//flash = rand()%2;
		//fn.glBegin(GL_POINTS);

	for(y = 30; y < yres-30; y++)
		for(x = 0; x < xres; x++)
		{
			ray.position.z = pz;
			if(_flash > 0.0f)
			{
				float a = frand()*_flash;
				ray.position.x= a;
				ray.position.y= a;
			}
			ray.direction.x = 2.0f * (x - xres/2) / xres;
			ray.direction.y = 0.75f * 2.0f * (yres/2 - y) / yres;
			ray.direction.z = 1;

			normalize(&ray.direction);

			struct Vector3D color;
			trace(&ray, &color, 0);

			if (fade >= 0.0f)
			{
				color.x*= fade;
				color.y*= fade;
				color.z*= fade;
			}


			unsigned char *s = screen->pixels;
			unsigned int offset = 4 * (x + y * xres);
			s[offset]>>=1;
			s[offset+1]>>=1;
			s[offset+2]>>=1;
//			s[offset+3]>>=1;

			if(color.x > 1.0f) color.x = 1.0f;
			if(color.y > 1.0f) color.y = 1.0f;
			if(color.z > 1.0f) color.z = 1.0f;

			r = color.x * 128;
			g = color.y * 128;
			b = color.z * 128;



			addPixel(x, y, RGB(r, g, b));
		}

		fn.SDL_Flip(screen);
		dtime = current_time - last_current_time;

	}
fin:

	fn.SDL_Quit();

#if 1
	asm("xorl %eax, %eax\n\t"
	    "incl %eax\n\t"
	    "int $0x80\n\t");
#else
	exit(0);
#endif
}
