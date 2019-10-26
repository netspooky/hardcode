//############################################################################
// Definet ###################################################################
//############################################################################

// Aika
#define TIMER_FPS	60
#define TIMER_MS	(Uint32)(1000.0f / (float)TIMER_FPS)

/*
 * Mahdolliset liput:
 */
//#define FLAG_ENABLE_GTK
//#define FLAG_ENABLE_SDL_IMAGE
//#define FLAG_FULLSCREEN
//#define FLAG_NOSTDLIB
//#define WIN32

//############################################################################
// Includet ##################################################################
//############################################################################

// Conffit
#ifndef FLAG_NOSTDLIB
#include "config.h"
#include "resource.h"
#endif

// Posix
#include <math.h>
#include <stdlib.h>
#include <string.h>

// Windows
#ifdef WIN32
#define WIN32_LEAN_AND_MEAN // Toimii ilman noita joten miksei?
#define random rand // Kun se on noin
#include "windows.h"
#endif

// 3rd party
#include "SDL.h"
#include "SDL_syswm.h"
#include "GL/gl.h"
#include "GL/glu.h"

#ifndef M_PI
#define M_PI	3.1415926535897932384626433f
#endif

/*
 * Konditionaalinen printf Tulostaa jotakin vain jos stdlib on mukana.
 */
#ifndef FLAG_NOSTDLIB
#define cond_printf printf
#else
#ifdef WIN32
#define cond_printf printf
#else
#define cond_printf(...) ;
#endif
#endif

/** This define intended for saving the intro to files. */
//#define RECORDING_MODE

//############################################################################
// Tyhmät makrot #############################################################
//############################################################################

#define memclr(op, bytes)	memset(op, 0, bytes)

//############################################################################
// Typedefit #################################################################
//############################################################################

/*
 * Katsomissuunnat.
 */

typedef struct
{
	int time;
	Sint16 data[6];
} LookAtUnit;

/*
 * Värit.
 */

typedef struct
{
	float f[4];
	Uint32 u;
} ColorUnit;

/*
 * Muodot.
 */

#define ARRAY_HEAP		10082

typedef struct
{
	float tex[2];
	Uint32 col;
	float ver[3];
} ShapeUnit;

typedef struct
{
	ShapeUnit data[ARRAY_HEAP];
	Uint16 index[ARRAY_HEAP];
	int ins_vertex, ins_index;
} ShapeDB; // Lähes täsmälleen 256 kiloa

/*
 * Väläykset.
 */
typedef struct
{
	Uint16 start, duration;
	Uint8 ca, cb, blendmode, tex1, tex2;
} FlashUnit;

/*
 * Merkit.
 */

#define CHAR_MAX_STROKES	10

typedef struct
{
	Sint8 stroke[CHAR_MAX_STROKES];
} Char2D;

/*
 * Bezier.
 */

#define BEZIER_HISTORY	5

typedef struct
{
	Sint16 pos[BEZIER_HISTORY * 3];
} BezierControl;

typedef struct
{
	int d[3], u[3];
} BezierLine;

/*
 * Valopilarit.
 */

typedef struct
{
	float height, width, radius;
	int lifetime, delay, col;
} LightPillarParams;

/*
 * Circles.
 */

typedef struct
{
	int radial, sector, stime, etime, dir;
} CirclesRunner;

/*
 * GitS.
 */

#define GITS_LINKSPER	5
#define GITS_PATH_LEN	2000

typedef struct
{
	float pos[3];
	int connections[GITS_LINKSPER], conncnt;
} GitsSphere;

// Polku
typedef struct
{
	float pos[3], dir[3], roll;
	float len_upto;
} PathUnit;

typedef struct
{
	Sint16 pos[3];
	Sint8 dir[3], roll;
} PathPacked;

typedef struct
{
	PathUnit unit[GITS_PATH_LEN];
	float len_total;
	int cnt;
} PathDB;

// Efektit
typedef struct
{
	int start, end;
	void (*func)(int);
} EffectData;

/*
 * Audio
 */
typedef struct
{
	Uint8 c1, c2;
} Channel8;

typedef union
{
	Sint16 chn;
	Channel8 c8;
} ChannelEndian;

//############################################################################
// Kontrolli #################################################################
//############################################################################

// Tämä on essentiaalinen kaikennäköiselle
#define MAX_EFFECT_TIME	15000

/*
 * Circles
 */
#define CIRCLES_START	0
#define PILLAR_START	2450
#define PILLAR_DUR	1100
#define WINGS_START	(PILLAR_START + 240)
#define WINGS_END	(WINGS_START + 740)
#define PILLAR_END	(PILLAR_START + PILLAR_DUR)
#define ORITEXT_START	(PILLAR_END + 80)
#define CIRCLES_END	(PILLAR_END + 350)
#define ORITEXT_END	CIRCLES_END
LookAtUnit lookat_circles[] =
{
	{ 0, { 10, 30, 0, 50, 30, 0 } },
	{ 300, { 5, 40, 20, -10, 30, -40 } },
	{ 550, { -5, 80, 10, -50, 50, 10 } },
	{ 800, { 5, 140, -20, 10, 40, 40 } },
	{ 1200, { -45, 160, -9, 40, 60, 5 } },
	{ 1500, { 5, 180, -9, -30, 10, -10 } },
	{ 1700, { 5, 180, -30, -10, 20, -20 } },
	{ 1900, { 10, 190, 40, 0, 20, 0 } },
	{ 2000, { -5, 190, 30, 15, 20, -10 } },
	{ PILLAR_START, { -40, 150, 190, 0, 50, 0 } },
	{ WINGS_START, { -60, 140, 220, 0, 80, 0 } },
	{ WINGS_END, { -120, 90, 350, 0, 130, 0 } },
	{ PILLAR_END, { -80, 150, 110, 0, 50, 0 } },
	{ CIRCLES_END, { -80, 130, 110, 0, 200, 0 } }
};

/*
 * City
 */
#define CITY_START		CIRCLES_END
#define CITY_HALT_1		325
#define CITY_TARGETING_1	(CITY_HALT_1 + 50)
#define CITY_FOLD_1		(CITY_TARGETING_1 + 110)
#define CITY_FOLD_1_END		(CITY_FOLD_1 + 330)
#define CITY_HALT_1_DUR		(CITY_FOLD_1_END - CITY_HALT_1)
#define CITY_HALT_2		(CITY_FOLD_1_END + 805)
#define CITY_TARGETING_2	(CITY_HALT_2 + 50)
#define CITY_FOLD_2		(CITY_TARGETING_2 + 110)
#define CITY_FOLD_2_END		(CITY_FOLD_2 + 550)
#define CITY_HALT_2_DUR		(CITY_FOLD_2_END - CITY_HALT_2)
#define CITY_HALT_3		(CITY_FOLD_2_END + 430)
#define CITY_TARGETING_3	(CITY_HALT_3 + 50)
#define CITY_FOLD_3		(CITY_TARGETING_3 + 110)
#define CITY_FOLD_3_END		(CITY_FOLD_3 + 450)
#define CITY_HALT_3_DUR		(CITY_FOLD_3_END - CITY_HALT_3)
#define CITY_XRAY		(7802 - CITY_START) //(CITY_FOLD_3_END + 640)
#define CITY_XRAY_DUR		80
#define CITY_XRAY_END		(CITY_XRAY + CITY_XRAY_DUR)
#define CITY_XRAY2		(8045 - CITY_START)
#define CITY_XRAY2_DUR		80
#define CITY_XRAY2_END		(CITY_XRAY2 + CITY_XRAY2_DUR)
#define CITY_HALT_TOTAL		(CITY_HALT_1_DUR + CITY_HALT_2_DUR + CITY_HALT_3_DUR)
#define CITY_END		(CITY_START + 3065 + CITY_HALT_TOTAL)
LookAtUnit lookat_city[] = 
{
	{ 0, { 7300, 15000, 7400, 7305, 100, 7400 }, },
	{ 155, { 7300, 3000, 7400, 10000, 100, 7400 }, },
	{ 200, { 7300, 2000, 7400, 10000, 1000, 8000 }, },
	{ 260, { 8200, 1500, 9600, 9000, 2000, 10000 }, },
	{ 335, { 8400, 2000, 9800, 9000, 2100, 10000 }, },
	{ 400, { 12000, 1800, 10500, 14000, 500, 11500 }, },
	{ 450, { 14000, 1800, 11500, 16000, 500, 20000 }, },
	{ 510, { 15500, 2600, 14500, 20000, 500, 18500 }, },
	{ 570, { 18500, 2000, 18000, 20000, 500, 18500 }, },
	{ 620, { 19000, 1700, 18100, 20000, 500, 20500 }, },
	{ 670, { 19500, 800, 19500, 20000, 500, 21500 }, },
	{ 720, { 20400, 610, 20600, 21000, 500, 21800 }, },
	{ 880, { 20300, 700, 20700, 23000, 650, 21800 }, },
	{ 930, { 19500, 650, 22400, 22000, 800, 23000 }, },
	{ 1080, { 19400, 750, 22600, 22050, 900, 23000 }, },
	{ 1130, { 20200, 700, 19600, 27600, 400, 18100 }, },
	{ 1180, { 18900, 1900, 17000, 19800, 300, 20600 }, },
	{ 1240, { 26500, 1700, 17600, 32100, 1200, 22600 }, },
	{ 1290, { 27100, 3900, 19400, 30100, 1500, 20600 }, },
	{ 1350, { 30000, 2800, 24200, 31000, 1900, 24300 }, },
	{ 1600, { 29900, 4100, 24640, 31000, 3600, 24300 }, },
	{ 1720, { 29100, 2200, 26400, 24000, 5100, 24600 }, },
	{ 1850, { 26100, 5200, 29000, 23000, 5200, 24600 }, },
	{ 2010, { 24100, 5200, 29300, 22500, 5100, 25000 }, },
	{ 2290, { 22400, 5100, 30000, 22400, 5200, 26600 }, },
	{ 2450, { 21000, 5800, 22100, 24000, 3600, 21700 }, },
	{ 2540, { 21900, 5600, 21800, 24000, 3600, 21700 }, },
	{ 2650, { 21400, 5800, 21400, 24000, 3600, 21600 }, },
	{ 2760, { 24100, 7200, 20800, 21000, 2600, 21600 }, },
	{ 2900, { 30200, 6200, 24800, 21000, 1600, 21600 }, },
	{ 3100, { 30900, 5300, 26100, 21000, 1600, 21600 }, }
};

/*
 * GitS
 */
#define GITS_START	CITY_END
#define GITS_END	(GITS_START + 4100)
LookAtUnit lookat_gits[] =
{
	{ 0, { -1020, 750, 7000, -1010, 750, -1000 } },
	{ 180, { -1020, 750, 1510, -1010, 750, -1000 } },
	{ 600, { -520, 750, 1510, -520, 750, -1000 } },
	{ 670, { -80, 1220, 330, 10000, 750, 0 } },
	{ 800, { -120, 580, 900, 1000, 450, 1400 } },
	{ 850, { 420, 480, 1430, 500, 700, 500 } },
	{ 920, { 430, 560, 1230, 1000, 700, 1000 } },
	{ 1040, { 450, 800, 1030, 1000, 700, 1000 } },
	{ 1240, { 640, 2000, 940, 1000, 1600, 700 } },
	{ 1420, { 940, 1100, 1200, 2000, 1000, 700 } },
	{ 1570, { 1520, 1250, 1180, 2000, 1500, 700 } },
	{ 1660, { 1520, 1350, 540, 3000, 1100, 1200 } },
	{ 2300, { 1530, 1150, 640, 3000, 1200, 1200 } },
	{ 2400, { 2000, 940, 1200, 3000, 1100, 1200 } },
	{ 2660, { 3000, 1150, 800, 4000, 800, 1100 } },
	{ 2770, { 3010, 1290, 880, 4000, 1200, 1200 } },
	{ 2890, { 2900, 750, 800, 12000, 900, 900 } },
	{ 3740, { 11000, 750, 700, 14000, 700, 750 } },
	{ 4100, { 3020, 750, 6700, 3020, 750, -1000 } }
};

/*
 * Fold
 */
LookAtUnit lookat_fold[] = {
	{ 0, { 2, 1, 2, 0, 0, 0 } },
	{ 250, { 2, 1, -2, 0, 0, 0 } },
	{ 500, { -2, 1, -2, 0, 0, 0 } },
	{ 750, { -2, 1, 2, 0, 0, 0 } },
	{ 1000, { 2, 1, 2, 0, 0, 0 } }
};

/*
 * Fractal
 */
LookAtUnit lookat_fractal[] = {
	{ 0, { 0, 0, 15, 0, 0, 0 } },
	{ MAX_EFFECT_TIME, { 0, 0, 15, 0, 0, 0 } }
};

// Poronkusema
#define TIME_END	GITS_END

//############################################################################
// Global variables for fun & profit #########################################
//############################################################################

#define TEXTURE_PLAYGROUND_SIZE	(1024 * 768) // Would require 512Mb
#define DEF_SCREEN_W		800
#define DEF_SCREEN_H		600
#define SDL_GFX_FLAGS		(SDL_HWSURFACE | SDL_OPENGL | SDL_DOUBLEBUF)
#define DEF_FRACTAL_W		512
#define DEF_FRACTAL_H		384

// Kokonaisluvut
int screen_w = DEF_SCREEN_W,
		screen_h = DEF_SCREEN_H,
		fractal_w = DEF_FRACTAL_W,
		fractal_h = DEF_FRACTAL_H,
		screen_b = 32;
Sint16 *audio_precalc; // jynk jynk
Uint8 debug_flag = 0;
Uint32 display_flags = SDL_GFX_FLAGS,
			 texture_playground[TEXTURE_PLAYGROUND_SIZE];
// Liukuluvut
float camera_position[6];

// Ajastin
int var_timer;

// Skippaus ja ikonit vain jos tarvis
#ifndef FLAG_NOSTDLIB
int var_timer_skip;
char path_icon[] = "../rel/origami_32x32.png",
		 path_banner[] = "../rel/origami_banner.png";
#endif

// Kaikki shapet
ShapeDB shape_use, // Yleisshape
				shape_crane, // Muodot
				shape_flare,
				shape_tachikoma,
				shape_unicorn,
				shape_varis,
				shape_circles[2], // Renkaat, tarvii 2, en tajua miksi
				shape_pillar_draw, shape_pillar_wings, // Pilarit
				shape_line_circle, // GitS
				shape_gits_grid,
				shape_gits_paths,
				shape_simpleplane[4], // Foldit
				shape_swan[4],
				shape_crow[4];

// Tiettyjä asioita tarvitaan niitten luonteen takia joka framelle. Ne tähän.
float var_pillar_shard[MAX_EFFECT_TIME * TIMER_MS];
int var_gits_path_start[MAX_EFFECT_TIME * TIMER_MS];

//############################################################################
// Predefine #################################################################
//############################################################################

void efu_progress_bar();

//############################################################################
// Ajastin ###################################################################
//############################################################################

Uint32 timer_callback(Uint32 interval, void *param)
{
	var_timer++;
	return interval;
}

//############################################################################
// Helper funcs ##############################################################
//############################################################################

/*
 * Laskee modulon.
 */
int modulo(int val, int base)
{
	if(val < 0)
		val += base;
	else if(val >= base)
		val -= base;
	return val;
}

/*
 * Laske vektorin pituus (neliöitynä).
 */
float veclen_sqr(float *op)
{
	return op[0] * op[0] + op[1] * op[1] + op[2] * op[2];
}

/*
 * Laske vektorin pituus (kolmiulotteinen).
 */
float veclen(float *op)
{
	return (float)sqrt(veclen_sqr(op));
}

/*
 * Yksiköi vektorin kohteeseen lähteestä.
 */
void vecunit(float *dst, float *src)
{
	float len = veclen(src);
	dst[0] = src[0] / len;
	dst[1] = src[1] / len;
	dst[2] = src[2] / len; 
}

/*
 * Laskee ristitulon kohteeseen lähteistä.
 */
void veccross(float *dst, float *a, float *b)
{
	dst[0] = a[1] * b[2] - b[1] * a[2];
	dst[1] = b[0] * a[2] - a[0] * b[2];
	dst[2] = a[0] * b[1] - b[0] * a[1];
}

/*
 * Laskee kahden vektorin erotuksen kohteeseen.
 */
void vecsub(float *dst, float *a, float *b)
{
	dst[0] = a[0] - b[0];
	dst[1] = a[1] - b[1];
	dst[2] = a[2] - b[2];
}

/*
 * Kahden pisteen etäisyys.
 */
float vecdist(float *a, float *b)
{
	float diff[3] =
	{
		a[0] - b[0],
		a[1] - b[1],
		a[2] - b[2]
	};
	return veclen(diff);
}

/*
 * Kaksiulotteinen etäisyys kokonaisluvuille.
 */
float dist_2d(int x1, int y1, int x2, int y2)
{
	int dx,dy;	
	dx = x2 - x1;
	dy = y2 - y1;

	return (float)sqrt((float)(dx * dx + dy * dy));
}

/*
 * Vaihtaa kaksi flotaria keskenään.
 */
void xchgf(float *a, float *b)
{
	float c = *a;
	*a = *b;
	*b = c;
}

/*
 * Rotatoi kolmen akselin yli.
 */
void glRotate3f(float x, float y, float z)
{
	glRotatef(y, 0.0f, 1.0f, 0.0f);
	glRotatef(x, 1.0f, 0.0f, 0.0f);
	glRotatef(z, 0.0f, 0.0f, 1.0f);
}

/*
 * Skaalaa 3 kerralla.
 */
void glScale1f(float op)
{
	glScalef(op, op, op);
}

/*
 * Rotate_quardrant palauttaa GL-käännöskulman kahden tasokoordinaatin
 * perusteella.
 */
float rotate_quardrant(float a, float b)
{
	if(b > 0.0f)
		return (float)atan(a / b) / M_PI * 180.0f;
	else if(b < 0.0f)
		return (float)atan(a / b) / M_PI * 180.0f + 180.0f;
	else if(a < 0.0f)
		return -90.0f;
	else
		return 90.0f;
}

/*
 * Rotatoi, ja katsoo annettuun suuntaan sekä pyörii annetun määrän.
 */
void glRotateTranslatefv(float *pos, float *dir, float roll)
{
	float dxz = (float)sqrt(dir[0] * dir[0] + dir[2] * dir[2]),
				xr, yr;

	//printf("Direction: %f, %f, %f\n", dir[0], dir[1], dir[2]);
	// Translaatio
	glTranslatef(pos[0], pos[1], pos[2]);

	// Eivätköhän negaatiot optimoidu
	xr = rotate_quardrant(-dir[0], -dir[2]);
	yr = rotate_quardrant(dir[1], dxz);

	//printf("Rotation: %f, %f, %f\n", yr, xr, roll);

	glRotate3f(yr, xr, roll);
}

/*
 * Nappaa tekstuuri.
 */
void texture_create(int *bind, int w, int h)
{
	// Tekstuurit päälle ja generoidaan
	glEnable(GL_TEXTURE_2D);
	glGenTextures(1, (GLuint*)bind);
	glBindTexture(GL_TEXTURE_2D, *bind);
	gluBuild2DMipmaps(GL_TEXTURE_2D, 4, w, h, GL_RGBA, GL_UNSIGNED_BYTE,
			texture_playground);
	// Jotta drawElements toimii oikein!
	(*bind)++;
}

/*
 * Tyhjennä tekstuuri
 */
void texture_clear()
{
	memclr(texture_playground, sizeof(Uint32) * TEXTURE_PLAYGROUND_SIZE);
}

/*
 * Vaihda tekstuurikoordinaattia.
 */
void texcoord_switch(float *op)
{
	if(*op == 0.0f)
		*op = 1.0f;
	else
		*op = 0.0f;
}

//############################################################################
// Kamera ####################################################################
//############################################################################

void camera_frustum(float fov, float backclip)
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(fov * (float)screen_h / (float)screen_w,
			(float)screen_w / (float)screen_h, 1.0, backclip);
	glMatrixMode(GL_MODELVIEW);
}

void camera_ortho(float fov)
{
	float ratio = (float)screen_h / (float)screen_w;
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(-fov, fov, -fov * ratio, fov * ratio);
	glMatrixMode(GL_MODELVIEW);
}

void blend_mode(int op)
{
	glDisable(GL_LIGHTING);
	glDisable(GL_COLOR_MATERIAL);
	glLineWidth(1.0f);

	// Blendfuncit
	if(op == 0)
		glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_ONE);
	else if(op == 1)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// Muut ominaisuudet
	if(op == 2)
	{
		glDepthFunc(GL_LEQUAL);
		glCullFace(GL_BACK);
		glDisable(GL_BLEND);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_CULL_FACE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
				GL_LINEAR_MIPMAP_LINEAR);
	}
	else
	{
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_CULL_FACE);
		glEnable(GL_BLEND);
	}
}

//############################################################################
// Interpolation #############################################################
//############################################################################

/*
 * All interpolation functions here.
 */

void interpolate_linear_ff(float* target, float* from, float* to, float pos,
		int count)
{
	do
	{
		target[count] = (to[count] - from[count]) * pos + from[count];
	} while(count--);
}

void interpolate_linear_i16f(float* target, Sint16* from, Sint16* to,
		float pos, int count)
{
	do
	{
		target[count] = ((float)(to[count] - from[count])) * pos +
			(float)(from[count]);
	} while(count--);
}

float interpolate_sine(float base, float var, float currtime, float speed)
{
	return base + var * (float)sin(currtime * speed);
}

/*
 * Lähennä välillä [0, 1] olevaa arvoa reunoihin.
 */
float interpolate_count_near(float op)
{
	float ret = 1.0f - (float)fabs(0.5f - op) * 2.0f;
	ret *= ret * 0.5f;
	if(op < 0.5f)
		return ret;
	return 1.0f - ret;
}

/*
 * Laske paikka alku- ja loppupisteen välillä.
 */
float interpolate_count_se(int freeze, int start, int end)
{
	float pos = (float)(freeze - start) / (float)(end - start);
	return interpolate_count_near(pos);
	/*float pos2 = 1.0f - (float)fabs(0.5f - pos) * 2.0f;
		pos2 *= pos2 * 0.5f;
		if(pos < 0.5f)
		return pos2;
		return 1.0f - pos2;*/
}

/*
 * Laske paikka alun ja kestoajan välillä.
 */
float interpolate_count_lt(int freeze, int start, int life)
{
	return (float)(freeze - start) / (float)life;
}

//############################################################################
// Random ####################################################################
//############################################################################

/*
 * Random number generator: x[n + 1] = a * x[n] mod m
 * Made according to source by Glenn C Rhoads.
 * http://remus.rutgers.edu/~rhoads/Code/code.html
 */

static uint32_t var_rand_seed = 93186752,
								var_rand_a = 1588635695,
								var_rand_q = 2,
								var_rand_r = 1117695901;

// Initialize random number generator
#define rand_seed(op) var_rand_seed = op

// Random natural number [0, param[
int32_t rand_int(int32_t op)
{
	var_rand_seed = var_rand_a * (var_rand_seed % var_rand_q) -
		var_rand_r * (var_rand_seed / var_rand_q);
	return var_rand_seed % op;
}

// Random real number [0, number]
float rand_float(float op)
{
	return (float)(rand_int(32768)) / 32767.0f * op;
}

// Random real number [-number, number]
float rand_float_neg(float op)
{
	return (float)(rand_int(65534) - 32767) / 32767.0f * op;
}

//############################################################################
// LookAt ####################################################################
//############################################################################

void look_at(LookAtUnit *op, int freezetime)
{
	LookAtUnit *to = op + 1, *from = op + 0;

	while(!((to->time > freezetime) && (freezetime >= from->time)))
	{
		to++;
		from++;
	}

	// Laske arvot
	interpolate_linear_i16f(camera_position, from->data, to->data,
			interpolate_count_se(freezetime, from->time, to->time), 5);

	// Katso
	gluLookAt(camera_position[0], camera_position[1], camera_position[2],
			camera_position[3], camera_position[4], camera_position[5],
			0.0, 1.0, 0.0);
}

//############################################################################
// Värit #####################################################################
//############################################################################

#define COLORDB_SIZE	58 // Tiukilla, älä muuta!
#define COLORDB_FLASH	37
#define COLORDB_FREE	38

ColorUnit var_colordb[COLORDB_SIZE] =
{
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0x00000000 }, // 00 = musta
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF003248 }, // 01 = gits-tausta
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0x00FFFFFF }, // 02 = valkea
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xF0FFFFFF }, // 03 = haalea valkea
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xF0888888 }, // 04 = haalea harmaa
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFFC05050 }, // 05 = iso valopilari
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0x995555FF }, // 06 = circles ala
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF00FFFF }, // 07 = circles ylä
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xA010C020 }, // 08 = 
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0x99A0C0FF }, // 09 = gits-pallo
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0x44FF4444 }, // 10 = gits-grid
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0x882222FF }, // 11 = gits-path
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0x80000000 }, // 12 = peittävä musta
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFFA08080 }, // 13 = city-taivas
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF409030 }, // 14 = terrain-lo
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF357050 }, // 15 = terrain-med
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF305070 }, // 16 = terrain-hi
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF205060 }, // 17 = puunrunko
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF307020 }, // 18 = puunlehti
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF807070 }, // 19 = katu
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFFA07070 }, // 20 = city-rakennus
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF906060 }, // 21 = city-rakennus
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF9090A0 }, // 22 = city-rakennus
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFFA090A0 }, // 23 = city-rakennus
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xB8000000 }, // 24 = ruututex-reuna
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF508060 }, // 25 = tosi matala maasto
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFFC0C0C0 }, // 26 = paperinvalkoinen
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF905040 }, // 27 = tachikoma-1
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF52C1C8 }, // 28 = tachikoma-2
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xA02070FF }, // 29 = targetointi
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFFC3D1F3 }, // 30 = yksisarvinen
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF5F6666 }, // 31 = varis
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xA0FFA080 }, // 32 = foldback-front
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF000000 }, // 33 = Häviävä musta
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFFFFFFFF }, // 34 = Puhdas valkoinen
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF5D1B24 }, // 35 = preloader-tausta
	{ { 0.0f, 0.0f, 0.0f, 0.0f }, 0xFF583EAE }, // 36 = preloader-palkki
};

// Vapaat värit
int var_colordb_free = COLORDB_FREE;

/*
 * Palauta väri (float)
 */
float* colordb_get_float(int op)
{
	return (var_colordb + op)->f;
}

/*
 * Palauta väri (uint).
 */
Uint32 colordb_get_uint(int op)
{
	return (var_colordb + op)->u;
}

/*
 * Konvertoi Uint-väri float-väriksi.
 */
void colordb_convert_u2f(int op)
{
	ColorUnit *cu = var_colordb + op;
	cu->f[0] = (float)(cu->u & 0x000000FF) / 255.0f;
	cu->f[1] = (float)((cu->u & 0x0000FF00) >> 8) / 255.0f;
	cu->f[2] = (float)((cu->u & 0x00FF0000) >> 16) / 255.0f;
	cu->f[3] = (float)((cu->u & 0xFF000000) >> 24) / 255.0f;
}

/*
 * Konvertoi float-väri Uint-väriksi.
 */
void colordb_convert_f2u(int op)
{
	ColorUnit *cu = var_colordb + op;
#if SDL_BYTEORDER == SDL_LIL_ENDIAN
	cu->u = (Uint32)(cu->f[0] * 255.0f) |
		(((Uint32)(cu->f[1] * 255.0f)) << 8) |
		(((Uint32)(cu->f[2] * 255.0f)) << 16) |
		(((Uint32)(cu->f[3] * 255.0f)) << 24);
#else
	cu->u = (Uint32)(cu->f[3] * 255.0f) |
		(((Uint32)(cu->f[2] * 255.0f)) << 8) |
		(((Uint32)(cu->f[1] * 255.0f)) << 16) |
		(((Uint32)(cu->f[0] * 255.0f)) << 24);
#endif
}

#if SDL_BYTEORDER == SDL_BIG_ENDIAN
void colordb_convert_lebe(int op)
{
	ColorUnit *cu = var_colordb + op;
	cu->u = (cu->u >> 24) | ((cu->u >> 8) & 0xFF00) |
		((cu->u << 8) & 0xFF0000) | ((cu->u << 24) & 0xFF000000);
}
#endif

/*
 * Tyhjennä GL-ruutu.
 */
void screen_clear(int op)
{
	float *col = colordb_get_float(op);

	glClearColor(col[0], col[1], col[2], col[3]);
	glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
}

//############################################################################
// Shapet ####################################################################
//############################################################################

/*
 * Muutama efekti tarvii tällaista funccia joka voidaan vaihtaa kesken.
 */
void (*shapedb_draw_safe)(ShapeDB *, int, GLint, int);

/*
 * Clear a shape database.
 */
void shapedb_clear(ShapeDB *op)
{
	op->ins_vertex = op->ins_index = 0;
}

/*
 * Kopioi tietyn verran ShapeDB:tä. Huomaa, että kopioitavan määrän on oltava
 * parillinen, tai toimivuutta ei taata.
 */
void shapedb_copy(ShapeDB *dst, ShapeDB *src)
{
	dst->ins_vertex = src->ins_vertex;
	dst->ins_index = src->ins_index;
	memcpy(dst->data, src->data, src->ins_vertex * sizeof(ShapeUnit));
	memcpy(dst->index, src->index, src->ins_index * sizeof(Uint16));
}

/*
 * Functions to select the array pointers in databases.
 */
void shapedb_draw_elements(ShapeDB *op, int t, GLint mode, int element)
{
	// Specify the interleaevd array
	glInterleavedArrays(GL_T2F_C4UB_V3F, 0, op->data);

	// Tekstuuri päälle / pois
	if(t != 0)
	{
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, mode);
		glBindTexture(GL_TEXTURE_2D, t - 1);
		glEnable(GL_TEXTURE_2D);
	}
	else
		glDisable(GL_TEXTURE_2D);

	// Draw the elements
	glDrawElements(element, op->ins_index, GL_UNSIGNED_SHORT, op->index);
}

/*
 * Add a vertex and a color to a shape.
 */
void shapedb_add_cv(ShapeDB *op, float x, float y, float z, int c)
{
	// Shift the arrays
	ShapeUnit *dst = op->data + (op->ins_vertex++);
	// Lisää
	dst->col = colordb_get_uint(c);
	dst->ver[0] = x;
	dst->ver[1] = y;
	dst->ver[2] = z;

#ifndef FLAG_NOSTDLIB
	if(op->ins_vertex >= ARRAY_HEAP)
		printf("ERROR: too large vertex.\n");
#endif
}

/*
 * Add a vertex and a texcoord to a shape.
 */
void shapedb_add_tv(ShapeDB *op, float x, float y, float z, float t, float u)
{
	// Shift the arrays
	ShapeUnit *dst = op->data + (op->ins_vertex++);
	// Lisää
	dst->tex[0] = t;
	dst->tex[1] = u;
	dst->ver[0] = x;
	dst->ver[1] = y;
	dst->ver[2] = z;

#ifndef FLAG_NOSTDLIB
	if(op->ins_vertex >= ARRAY_HEAP)
		printf("ERROR: too large vertex.\n");
#endif
}

/*
 * Add a vertex, texcoord and a color to a shape.
 */
void shapedb_add_tcv(ShapeDB *op, float x, float y, float z, float t, float u,
		int c)
{
	// Shift the arrays
	ShapeUnit *dst = op->data + (op->ins_vertex++);
	// Lisää
	dst->tex[0] = t;
	dst->tex[1] = u;
	dst->col = colordb_get_uint(c);
	dst->ver[0] = x;
	dst->ver[1] = y;
	dst->ver[2] = z;

#ifndef FLAG_NOSTDLIB
	if(op->ins_vertex >= ARRAY_HEAP)
		printf("ERROR: too large vertex.\n");
#endif
}

/*
 * Insert an index to the array.
 */
void shapedb_add_index(ShapeDB *op, Uint16 idx)
{
	op->index[op->ins_index++] = idx;

#ifndef FLAG_NOSTDLIB
	if(op->ins_index >= ARRAY_HEAP)
		printf("ERROR: too large index %i\n", op->ins_index);
#endif
}

/*
 * Aseta viimeinen verteksi miinus arvo.
 */
void shapedb_add_index_neg(ShapeDB *op, Uint16 idx)
{
	shapedb_add_index(op, op->ins_vertex - idx);
}

/*
 * Add a vertex that is an interpolation between two other vertices.
 */
void shapedb_interpolate_v(ShapeDB *op, int from, int to, float pos,
		Uint32 col)
{
	ShapeUnit *dst = op->data + op->ins_vertex;
	// Interpoloi
	interpolate_linear_ff(dst->ver, op->data[from].ver, op->data[to].ver, pos,
			2);
	// Color
	dst->col = colordb_get_uint(col);

	// Indeksi jo nyt
	shapedb_add_index(op, op->ins_vertex);
	// Inc
	op->ins_vertex++;
} 

/*
 * Return a certain vertex.
 */
float* shapedb_get_vertex(ShapeDB *op, int idx)
{
	return op->data[idx].ver;
}

/*
 * Extract a certain vertex (data too) from a ShapeDB.
 */
void shapedb_extract_vertex(ShapeDB *op, int idx, float *dst)
{
	memcpy(dst, op->data[idx].ver, 3 * sizeof(float));
}

/*
 * Korvaa tietty verteksi flotaridatalla, joka annetaan.
 */
void shapedb_replace_vertex(ShapeDB *op, int idx, float *ver)
{
	memcpy(op->data[idx].ver, ver, 3 * sizeof(float));
}

/*
 * Tulosta shapedb.
 */
#ifndef FLAG_NOSTDLIB
void shapedb_print(ShapeDB *op)
{
	int i;
	for(i = 0; i < op->ins_vertex; i++)
	{
		ShapeUnit *dst = &(op->data[i]);
		printf("<%f, %f, %f> [%f, %f]: %x\n", dst->ver[0],
				dst->ver[1], dst->ver[2], dst->tex[0], dst->tex[1], dst->col);
	}
	for(i = 0; i < op->ins_index; i++)
		printf("%i, ", op->index[i]);
	printf("\r\r\n");
}
#endif

/*
 * Piirrä kuutio halutulla värillä muotoon.
 */
void shapedb_draw_cube(ShapeDB *op, float x1, float y1, float z1, float x2,
		float y2, float z2, float topscale, int floor, int roof, int col)
{
	float xadd = (x2 - x1) * topscale,
				zadd = (z2 - z1) * topscale;

	// Varakatto
	shapedb_add_tcv(op, x1 + xadd, y2, z1 + zadd, 1.0f, 0.0f, col);
	shapedb_add_tcv(op, x2 - xadd, y2, z1 + zadd, 0.0f, 0.0f, col);
	shapedb_add_tcv(op, x2 - xadd, y2, z2 - zadd, 0.0f, 1.0f, col);
	shapedb_add_tcv(op, x1 + xadd, y2, z2 - zadd, 1.0f, 1.0f, col);
	// Pohja
	shapedb_add_tcv(op, x1, y1, z1, 0.0f, 0.0f, col);
	shapedb_add_tcv(op, x2, y1, z1, 1.0f, 0.0f, col);
	shapedb_add_tcv(op, x2, y1, z2, 1.0f, 1.0f, col);
	shapedb_add_tcv(op, x1, y1, z2, 0.0f, 1.0f, col);
	// Katto
	shapedb_add_tcv(op, x1 + xadd, y2, z1 + zadd, 0.0f, 1.0f, col);
	shapedb_add_tcv(op, x2 - xadd, y2, z1 + zadd, 1.0f, 1.0f, col);
	shapedb_add_tcv(op, x2 - xadd, y2, z2 - zadd, 1.0f, 0.0f, col);
	shapedb_add_tcv(op, x1 + xadd, y2, z2 - zadd, 0.0f, 0.0f, col);

	// Vas
	shapedb_add_index_neg(op, 8);
	shapedb_add_index_neg(op, 5);
	shapedb_add_index_neg(op, 9);
	shapedb_add_index_neg(op, 12);
	// Tak
	shapedb_add_index_neg(op, 7);
	shapedb_add_index_neg(op, 8);
	shapedb_add_index_neg(op, 4);
	shapedb_add_index_neg(op, 3);
	// Oik
	shapedb_add_index_neg(op, 6);
	shapedb_add_index_neg(op, 7);
	shapedb_add_index_neg(op, 11);
	shapedb_add_index_neg(op, 10);
	// Etu
	shapedb_add_index_neg(op, 5);
	shapedb_add_index_neg(op, 6);
	shapedb_add_index_neg(op, 2);
	shapedb_add_index_neg(op, 1);
	// Pohja
	if(floor)
	{
		shapedb_add_index_neg(op, 8);
		shapedb_add_index_neg(op, 7);
		shapedb_add_index_neg(op, 6);
		shapedb_add_index_neg(op, 5);
	}
	// Katto
	if(roof)
	{
		shapedb_add_index_neg(op, 1);
		shapedb_add_index_neg(op, 2);
		shapedb_add_index_neg(op, 3);
		shapedb_add_index_neg(op, 4);
	}
}

/*
 * Piirrä laatta halutulla värillä muotoon.
 */
void shapedb_draw_flat(ShapeDB *op, float x1, float z1, float x2, float z2,
		float y, int col)
{
	shapedb_add_tcv(op, x1, y, z1, 0.0f, 0.0f, col); 
	shapedb_add_tcv(op, x2, y, z1, 1.0f, 0.0f, col); 
	shapedb_add_tcv(op, x2, y, z2, 1.0f, 1.0f, col); 
	shapedb_add_tcv(op, x1, y, z2, 0.0f, 1.0f, col);
	shapedb_add_index_neg(op, 4);
	shapedb_add_index_neg(op, 1);
	shapedb_add_index_neg(op, 2);
	shapedb_add_index_neg(op, 3);
}

/*
 * Lue flotari- ja verteksidataa.
 */
void shapedb_read_rdata(ShapeDB *shp, Uint8 *ref, int vcnt, int rcnt)
{
	int i;

	for(i = 0; i < rcnt; i++)
		shapedb_add_index_neg(shp, vcnt - ref[i]);
}

void shapedb_read_cvdata(ShapeDB *shp, Sint8 *cvbuf, Uint8 *ref, int vcnt,
		int rcnt)
{
	int i;

	for(i = 0; i < vcnt; i++, cvbuf += 4)
		shapedb_add_cv(shp, (float)cvbuf[0], (float)cvbuf[1], (float)cvbuf[2],
				cvbuf[3]);

	shapedb_read_rdata(shp, ref, vcnt, rcnt);
}

void shapedb_read_tcvdata(ShapeDB *shp, Sint8 *cvbuf, Uint8 *ref, int vcnt,
		int rcnt)
{
	int i;

	for(i = 0; i < vcnt; i++, cvbuf += 6)
		shapedb_add_tcv(shp, (float)cvbuf[0], (float)cvbuf[1], (float)cvbuf[2],
				(float)cvbuf[3] / 2.0f, (float)cvbuf[4] / 2.0f, cvbuf[5]);

	shapedb_read_rdata(shp, ref, vcnt, rcnt);
}

/*
 * Piirtää rautalangallistetun mallin. Käytännössä taittelua varten.
 */
void shapedb_draw_wire(ShapeDB *op, int tex, GLint texmode, int mode)
{
	int i;

	glLineWidth(4.0f);
	shapedb_draw_elements(op, tex, texmode, mode);
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	shapedb_copy(&shape_use, op);
	for(i = 0; i < shape_use.ins_vertex; i++)
	{
#if SDL_BYTEORDER == SDL_LIL_ENDIAN
		shape_use.data[i].col = 0xFF000000;
#else
		shape_use.data[i].col = 0x000000FF;
#endif
	}
	shapedb_draw_elements(&shape_use, 0, 0, mode);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
}

//############################################################################
// Taittelumuodot ############################################################
//############################################################################

// Taittelumallien väri on paperinvalkoinen
#define FOLDMODEL_COLOR	26

/*
 * Simple plane
 */
#define ZBUFCONSTANT 0.01
#define SQRT2 1.41421356237310
#define FORM_SIMPLEPLANE_VERTS	20
#define FORM_SIMPLEPLANE_INDEXES (12 * 4)
float form_simpleplane_tcv[] =
{
	0.0, 0.0, 0.0, FOLDMODEL_COLOR,
	-(float)(SQRT2*0.5), 0.0, 0.0, FOLDMODEL_COLOR,
	-(float)(SQRT2*0.5), 0.0, (float)(SQRT2*(1.0/14.0)), FOLDMODEL_COLOR,
	-(float)(SQRT2*0.5), 0.0, (float)(SQRT2*0.5), FOLDMODEL_COLOR,
	-(float)(SQRT2*0.5), 0.0, 1.0, FOLDMODEL_COLOR,
	-(float)(SQRT2*(1.0/14.0)), 0, 1.0, FOLDMODEL_COLOR,
	-(float)(SQRT2*(1.0/14.0)), 0.0, (float)(SQRT2*(1.0/14.0)), FOLDMODEL_COLOR,
	(float)(SQRT2*(1.0/14.0)), 0.0, (float)(SQRT2*(1.0/14.0)), FOLDMODEL_COLOR,
	(float)(SQRT2*(1.0/14.0)), 0.0, 1.0, FOLDMODEL_COLOR,
	(float)(SQRT2*0.5), 0.0, 0.0, FOLDMODEL_COLOR,
	(float)(SQRT2*0.5), 0.0, (float)(SQRT2*(1.0/14.0)), FOLDMODEL_COLOR,
	(float)(SQRT2*0.5), 0.0, (float)(SQRT2*0.5), FOLDMODEL_COLOR,
	(float)(SQRT2*0.5), 0.0, 1.0, FOLDMODEL_COLOR,
	0.0, 0.0, 1.0, FOLDMODEL_COLOR,
	-(float)ZBUFCONSTANT, 0.0, 0.0, FOLDMODEL_COLOR,
	-(float)(SQRT2*0.5), 0.0, (float)(SQRT2*0.5)-(float)ZBUFCONSTANT, FOLDMODEL_COLOR,
	(float)ZBUFCONSTANT, 0.0, 0.0, FOLDMODEL_COLOR,
	(float)(SQRT2*0.5), 0.0, (float)(SQRT2*0.5)-(float)ZBUFCONSTANT, FOLDMODEL_COLOR,
	-(float)(SQRT2*(1.0/14.0))-(float)ZBUFCONSTANT, 0.0, (float)(SQRT2*(1.0/14.0)), FOLDMODEL_COLOR,
	(float)(SQRT2*(1.0/14.0))+(float)ZBUFCONSTANT, 0.0, (float)(SQRT2*(1.0/14.0)), FOLDMODEL_COLOR
};
Uint8 form_simpleplane_ref[] =
{
	0, 14, 18, 6,
	14, 1, 2, 18,
	2, 15, 18, 2,
	15, 3, 6, 18,
	3, 4, 5, 6,
	0, 6, 5, 13,
	0, 13, 8, 7,
	7, 8, 12, 11,
	10, 19, 17, 10,
	7, 11, 17, 19,
	16, 19, 10, 9,
	0, 7, 19, 16
};

/*
 * Swan
 */
#define CONSTANT_1		0.14644660940673 //(sqrt(2-sqrt(2))*sqrt(5/2-sqrt(2)*7/4))/(2*(sqrt(2)-1))
#define CONSTANT_2		0.35355339059327 //(1/4)*sqrt(2+sqrt(2))*sqrt(2-sqrt(2))
#define CONSTANT_3		0.09763107293782 //(sqrt(2)*sin((22.5/180)*pi))/(6*sin((112.5/180)*pi))
#define FORM_SWAN_VERTS		35
#define FORM_SWAN_INDEXES	(32 * 4)
float form_swan_tcv[] =
{
	0, 0, 0, FOLDMODEL_COLOR,
	1, 0, 1, FOLDMODEL_COLOR,
	1, 0, -1, FOLDMODEL_COLOR,
	-1, 0, -1, FOLDMODEL_COLOR,
	-1, 0, 1, FOLDMODEL_COLOR,
	0, 0, 1, FOLDMODEL_COLOR,
	1, 0, 0, FOLDMODEL_COLOR,
	0, 0, -1, FOLDMODEL_COLOR,
	-1, 0, 0, FOLDMODEL_COLOR,
	0, 0, (float)(2.0-SQRT2), FOLDMODEL_COLOR,
	(float)(2.0-SQRT2), 0, 0, FOLDMODEL_COLOR,
	0, 0, -(float)(2.0-SQRT2), FOLDMODEL_COLOR,
	-(float)(2.0-SQRT2), 0, 0, FOLDMODEL_COLOR,
	(float)(1.0-1.0/SQRT2), 0, (float)(1.0-1.0/SQRT2), FOLDMODEL_COLOR,
	(float)(1.0-1.0/SQRT2), 0, -(float)(1.0-1.0/SQRT2), FOLDMODEL_COLOR,
	-(float)(1.0-1.0/SQRT2), 0, -(float)(1.0-1.0/SQRT2), FOLDMODEL_COLOR,
	-(float)(1.0-1.0/SQRT2), 0, (float)(1.0-1.0/SQRT2), FOLDMODEL_COLOR,
	(float)(CONSTANT_1), 0, (float)(1.0-CONSTANT_2), FOLDMODEL_COLOR,
	(float)(1.0-CONSTANT_2), 0, (float)(CONSTANT_1), FOLDMODEL_COLOR,
	-(float)(CONSTANT_1), 0, -(float)(1.0-CONSTANT_2), FOLDMODEL_COLOR,
	-(float)(1.0-CONSTANT_2), 0, -(float)(CONSTANT_1), FOLDMODEL_COLOR,
	(float)(5.0/6.0), 0, (float)(5.0/6.0), FOLDMODEL_COLOR,
	(float)(5.0/6.0), 0, (float)(5.0/6.0 + CONSTANT_3), FOLDMODEL_COLOR,
	(float)(5.0/6.0 + CONSTANT_3), 0, (float)(5.0/6.0), FOLDMODEL_COLOR,
	(float)(1.0-SQRT2*(1.0/6.0)), 0, 1, FOLDMODEL_COLOR,
	1, 0, (float)(1.0-SQRT2*(1.0/6.0)), FOLDMODEL_COLOR,
	-1, 0, (float)(2.0-SQRT2), FOLDMODEL_COLOR,
	-(float)(2.0-SQRT2), 0, 1, FOLDMODEL_COLOR,
	1, 0, -(float)(2.0-SQRT2), FOLDMODEL_COLOR,
	(float)(2.0-SQRT2), 0, -1, FOLDMODEL_COLOR,
	-(float)0.36243686707645, (float)0.05177669529664, (float)0.08210678118655, FOLDMODEL_COLOR,
	(float)0.08210678118655, (float)0.05177669529664, -(float)0.36243686707645, FOLDMODEL_COLOR,
	-(float)0.08210678118655, (float)0.05177669529664, (float)0.36243686707645, FOLDMODEL_COLOR,
	(float)0.36243686707645, (float)0.05177669529664, -(float)0.08210678118655, FOLDMODEL_COLOR,
	(float)(1.0 + 5.0/6.0), 0, -(float)(1.0/6.0), FOLDMODEL_COLOR
};
//huomaa että 8 viimeistä olivat apupisteitä - niiden kautta ei piirretä mitään
Uint8 form_swan_ref[] =
{
	// vartalo
	0, 9, 17, 13,
	0, 13, 18, 10,
	0, 10, 14, 14,
	0, 14, 11, 11,
	0, 11, 19, 15,
	0, 15, 20, 12,
	0, 12, 16, 16,
	0, 16, 9, 9,
	// kaulan apupala vasen
	9, 5, 17, 17,
	// kaula
	17, 5, 24, 22,
	13, 17, 22, 21,
	18, 13, 21, 23,
	18, 23, 25, 6,
	// kaulan apupala oikea
	10, 18, 6, 6,
	// oikea siipi
	10, 6, 2, 2,
	14, 10, 2, 2,
	11, 14, 2, 2,
	7, 11, 2, 2,
	// pyrstön apupala oikea
	19, 11, 7, 7,
	// pyrstö
	19, 7, 3, 3,
	15, 19, 3, 3,
	20, 15, 3, 3,
	8, 20, 3, 3,
	// pyrstön apupala vasen
	12, 20, 8, 8,
	// vasen siipi
	12, 8, 4, 4,
	16, 12, 4, 4,
	9, 16, 4, 4,
	5, 9, 4, 4,
	// pää
	22, 24, 1, 1,
	21, 22, 1, 1,
	23, 21, 1, 1,
	25, 23, 1, 1
};

/*
 * Crow
 */
#define FORM_CROW_VERTS	26
#define FORM_CROW_INDEXES	(32 * 4)
float form_crow_tcv[] =
{
	0, 0, 0, FOLDMODEL_COLOR,
	1, 0, 1, FOLDMODEL_COLOR,
	1, 0, -1, FOLDMODEL_COLOR,
	-1, 0, -1, FOLDMODEL_COLOR,
	-1, 0, 1, FOLDMODEL_COLOR,
	0, 0, 1, FOLDMODEL_COLOR,
	1, 0, 0, FOLDMODEL_COLOR,
	0, 0, -1, FOLDMODEL_COLOR,
	-1, 0, 0, FOLDMODEL_COLOR,
	(float)(1.0/2.0), 0, 1, FOLDMODEL_COLOR,
	1, 0, (float)(1.0/2.0), FOLDMODEL_COLOR,
	1, 0, -(float)(1.0/2.0), FOLDMODEL_COLOR,
	(float)(1.0/2.0), 0, -1, FOLDMODEL_COLOR,
	-(float)(1.0/2.0), 0, -1, FOLDMODEL_COLOR,
	-1, 0, -(float)(1.0/2.0), FOLDMODEL_COLOR,
	-1, 0, (float)(1.0/2.0), FOLDMODEL_COLOR,
	-(float)(1.0/2.0), 0, 1, FOLDMODEL_COLOR,
	0, 0, (float)(1.0/2.0), FOLDMODEL_COLOR,
	(float)(1.0/2.0), 0, (float)(1.0/2.0), FOLDMODEL_COLOR,
	(float)(1.0/2.0), 0, 0, FOLDMODEL_COLOR,
	(float)(1.0/2.0), 0, -(float)(1.0/2.0), FOLDMODEL_COLOR,
	0, 0, -(float)(1.0/2.0), FOLDMODEL_COLOR,
	-(float)(1.0/2.0), 0, -(float)(1.0/2.0), FOLDMODEL_COLOR,
	-(float)(1.0/2.0), 0, 0, FOLDMODEL_COLOR,
	-(float)(1.0/2.0), 0, (float)(1.0/2.0), FOLDMODEL_COLOR,
	-(float)(3.0/2.0), 0, -(float)(1.0/2.0), FOLDMODEL_COLOR
};
// viimeinen on apupiste
Uint8 form_crow_ref[] =
{
	// koko hössä
	0, 17, 18, 18,
	0, 18, 19, 19,
	0, 19, 20, 20,
	0, 20, 21, 21,
	0, 21, 22, 22,
	0, 22, 23, 23,
	0, 23, 24, 24,
	0, 24, 17, 17,
	18, 17, 5, 5,
	18, 5, 9, 9,
	18, 9, 1, 1,
	18, 1, 10, 10,
	18, 10, 6, 6,
	18, 6, 19, 19,
	20, 19, 6, 6,
	20, 6, 11, 11,
	20, 11, 2, 2,
	20, 2, 12, 12,
	20, 12, 7, 7,
	20, 7, 21, 21,
	22, 21, 7, 7,
	22, 7, 13, 13,
	22, 13, 3, 3,
	22, 3, 14, 14,
	22, 14, 8, 8,
	22, 8, 23, 23,
	24, 23, 8, 8,
	24, 8, 15, 15,
	24, 15, 4, 4,
	24, 4, 16, 16,
	24, 16, 5, 5,
	24, 5, 17,17
};

/*
 * Sitten taitto-ohjeet, yksi phase kerrallaan
 * Formaatti: Akseli mistä, akseli mihin, verteksi, asteita*10
 * (fixed point koska inttejä)
 */
Sint16 fold_guide_simpleplane[] =
{
	8,
	5, 40,
	3, 0, 1, 1350,
	3, 0, 2, 1350,
	3, 0, 14, 1350,
	3, 0, 15, 1350,
	3, 0, 18, 1350,
	2, 28,
	15, 14, 1, 450,
	15, 14, 2, 450,
	5, 40,
	0, 11, 9, 1350,
	0, 11, 10, 1350,
	0, 11, 16, 1350,
	0, 11, 17, 1350,
	0, 11, 19, 1350,
	2, 28,
	16, 17, 9, 450,
	16, 17, 10, 450,
	9, 40,
	13, 0, 1, 830,
	13, 0, 2, 830,
	13, 0, 3, 830,
	13, 0, 4, 830,
	13, 0, 5, 830,
	13, 0, 6, 830,
	13, 0, 14, 830,
	13, 0, 15, 830,
	13, 0, 18, 830,
	9, 40,
	0, 13, 7, 830,
	0, 13, 8, 830,
	0, 13, 9, 830,
	0, 13, 10, 830,
	0, 13, 11, 830,
	0, 13, 12, 830,
	0, 13, 16, 830,
	0, 13, 17, 830,
	0, 13, 19, 830,
	3, 40,
	5, 6, 3, -900,
	5, 6, 4, -900,
	5, 6, 15, -900,
	3, 40,
	7, 8, 11, -900,
	7, 8, 12, -900,
	7, 8, 17, -900
};

Sint16 fold_guide_swan[] =
{
	11,
	6, 60,
	17, 1, 24, -1800,
	1, 18, 25, -1800,
	26, 9, 5, -1350,
	10, 29, 6, -1350,
	28, 11, 7, -1350,
	12, 27, 8, -1350,
	26, 60,
	4, 2, 1, -880,
	4, 2, 13, -880,
	4, 2, 21, -880,
	4, 2, 34, -880,
	4, 2, 22, -880,
	4, 2, 23, -880,
	4, 2, 24, -880,
	4, 2, 25, -880,
	1, 3, 2, -880,
	1, 3, 14, -880,
	2, 4, 3, -880,
	2, 4, 15, -880,
	3, 1, 4, -880,
	3, 1, 16, -880,
	12, 10, 5, -450,
	12, 10, 9, -450,
	9, 11, 6, -450,
	9, 11, 10, -450,
	10, 12, 7, -450,
	10, 12, 11, -450,
	11, 9, 8, -450,
	11, 9, 12, -450,
	0, 33, 17, -578,
	32, 0, 18, -578,
	0, 30, 19, -578,
	31, 0, 20, -578,
	8, 50,
	0, 1, 10, 445,
	0, 1, 18, 445,
	0, 1, 9, -445,
	0, 1, 17, -445,
	0, 1, 12, 445,
	0, 1, 20, 445,
	0, 1, 11, -445,
	0, 1, 19, -445,
	8, 60,
	9, 10, 1, 1350,
	9, 10, 21, 1350,
	9, 10, 34, 1350,
	9, 10, 22, 1350,
	9, 10, 23, 1350,
	9, 10, 24, 1350,
	9, 10, 25, 1350,
	11, 12, 3, 1350,
	1, 50,
	21, 34, 1, -900,
	10, 50,
	0, 2, 10, -800,
	0, 2, 18, -880,
	0, 2, 9, 800,
	0, 2, 17, 880,
	0, 2, 11, 800,
	0, 2, 19, 880,
	0, 2, 12, -800,
	0, 2, 20, -880,
	13, 21, 22, -850,
	13, 21, 23, 850,
	2, 60,
	10, 11, 2, 1100,
	9, 12, 4, -1100,
	2, 40,
	10, 11, 2, -300,
	9, 12, 4, 300,
	2, 40,
	10, 11, 2, 300,
	9, 12, 4, -300,
	2, 40,
	10, 11, 2, -300,
	9, 12, 4, 300,
	2, 40,
	10, 11, 2, 300,
	9, 12, 4, -300
};
//real angle 57.76438968275467

Sint16 fold_guide_crow[] =
{
	9,
	12, 80,
	5, 6, 1, -1795,
	5, 6, 9, -1795,
	5, 6, 10, -1795,
	6, 7, 2, -1795,
	6, 7, 11, -1795,
	6, 7, 12, -1795,
	7, 8, 3, -1795,
	7, 8, 13, -1795,
	7, 8, 14, -1795,
	8, 5, 4, -1795,
	8, 5, 15, -1795,
	8, 5, 16, -1795,
	4, 80,
	24, 18, 5, 1770,
	18, 20, 6, 1770,
	20, 22, 7, 1770,
	22, 24, 8, 1770,
	12, 60,
	21, 17, 10, 440,
	21, 17, 11, 440,
	21, 17, 19, 440,
	23, 19, 12, 440,
	23, 19, 13, 440,
	23, 19, 21, 440,
	17, 21, 14, 440,
	17, 21, 15, 440,
	17, 21, 23, 440,
	19, 23, 16, 440,
	19, 23, 17, 440,
	19, 23, 9, 440,
	1, 50,
	24, 25, 4, -600,
	10, 60,
	0, 18, 16, -680,
	0, 18, 17, -680,
	0, 18, 9, -680,
	22, 0, 14, -680,
	22, 0, 15, -680,
	22, 0, 23, -680,
	22, 0, 24, -1150,
	22, 0, 4, -1150,
	11, 12, 1, -10,
	11, 12, 3, -10,
	// edelliset kaksi ovat APUTAITOKSIA koska muuten tapahtui polyjen
	// leikkautumista Jos Z-buffer ei ole ongelma, jätä ne tekemättä
	2, 40,
	0, 17, 22, 250,
	23, 0, 18, 250,
	2, 40,
	0, 17, 22, -500,
	23, 0, 18, -500,
	2, 40,
	0, 17, 22, 500,
	23, 0, 18, 500,
	2, 40,
	0, 17, 22, -500,
	23, 0, 18, -500
};

//############################################################################
// Staattiset muodot #########################################################
//############################################################################

/*
 * Flare
 */
#define FORM_FLARE_VERTS	4
#define FORM_FLARE_INDEXES	(3 * 3)
Sint8 form_flare_cv[] =
{
	0, 0, 0, 8,
	-15, 15, 0, 0,
	15, -15, 0, 0,
	0, 20, 0, 0
};
Uint8 form_flare_ref[] =
{
	0, 1, 2,
	0, 2, 3,
	0, 3, 1
};

/*
 * Flashin form.
 */
#define FORM_FLASH_VERTS	4
#define FORM_FLASH_INDEXES	4
Sint8 form_flash_tcv[] =
{
	-4, -3, 0, 0, 0, COLORDB_FLASH,
	4, -3, 0, 2, 0, COLORDB_FLASH,
	4, 3, 0, 2, 2, COLORDB_FLASH,
	-4, 3, 0, 0, 2, COLORDB_FLASH,
};
Uint8 form_flash_ref[] =
{
	0, 1, 2, 3
};

/*
 * Crane
 */
#define FORM_CRANE_VERTS	29
#define FORM_CRANE_INDEXES	(36 * 3)
Sint8 form_crane_tcv[] =
{
	-4, 0, -10,	0, 2, 30, // 0
	4, 0, -10,	2, 2, 30, // 1
	-6, 0, 10,	0, 0, 30, // 2
	6, 0, 10,	2, 0, 30, // 3
	0, 4, 0,	1, 1, 3,  // 4
	-8, 8, -10,	2, 2, 3,  // 5
	8, 8, -10,	0, 2, 3,  // 6
	-8, 9, 0,	2, 1, 3,  // 7
	8, 9, 0,	0, 1, 3,  // 8
	-8, 8, 10,	2, 0, 3,  // 9
	8, 8, 10,	0, 0, 3,  // 10
	-16, 16, -12,	1, 2, 3,  // 11
	0, 12, -8,	1, 2, 30, // 12
	16, 16, -12,	1, 2, 3,  // 13
	0, 12, 0,	1, 1, 30, // 14
	-16, 16, 11,	1, 0, 3,  // 15
	0, 12, 10,	1, 0, 30, // 16
	16, 16, 11,	1, 0, 3,  // 17
	0, 22, -30,	2, 2, 3,  // 18
	-3, 28, -26,	0, 0, 30, // 19
	3, 28, -26,	2, 0, 30, // 20
	0, 29, -24,	1, 1, 3,  // 21
	-30, 28, 0,	0, 1, 30, // 22
	30, 28, 0,	2, 1, 30, // 23
	0, 30, 26,	0, 2, 3,  // 24
	0, 4, 0,	0, 0, 3,  // 25 = 4
	0, 4, 0,	2, 0, 3,  // 26 = 4
	0, 22, -30,	0, 2, 3,  // 27 = 18
	0, 30, 26,	2, 2, 3   // 28 = 24
};
Uint8 form_crane_ref[] =
{
	// keskustan katto
	5, 12, 14,
	7, 14, 5,
	9, 16, 14,
	14, 7, 9,
	6, 12, 14,
	14, 8, 6,
	10, 16, 14,
	14, 8, 10,
	// siivet
	5, 7, 11,
	11, 22, 7,
	9, 7, 15,
	15, 22, 7,
	13, 6, 8,
	8, 23, 13,
	17, 10, 8,
	8, 23, 17,
	// pohja
	0, 5, 7,
	7, 4, 0,
	2, 9, 7,
	7, 4, 2,
	3, 10, 8,
	8, 4, 3,
	1, 6, 8,
	8, 4, 1,
	// etu ja taka
	5, 12, 4,
	6, 12, 4,
	9, 16, 4,
	10, 16, 4,
	// kaula ja pää
	0, 19, 21,
	21, 25, 0,
	1, 20, 21,
	21, 26, 1,
	20, 21, 18,
	19, 21, 27,
	// pyrstö
	2, 24, 4,
	3, 28, 4
};

/*
 * Tachikoma.
 */
#define FORM_TACHIKOMA_VERTS	((4 * 8) + (2 * 12 + 2) + 13)
#define FORM_TACHIKOMA_INDEXES	(((4 * 9) + (14 + 14 + 16) + 14) * 3)
Sint8 form_tachikoma_tcv[] =
{
	// Vas. etu
	-38, 0, -30, 1, 1, 27,
	-42, 30, -34, 0, 2, 28,
	-44, 30, -26, 0, 0, 28,
	-36, 24, -29, 2, 2, 27,
	-36, 24, -29, 2, 0, 27,
	-10, 20, -21, 2, 2, 27,
	-10, 14, -18, 1, 1, 27,
	-10, 20, -14, 2, 0, 27,
	// Oik. etu
	38, 0, -30, 1, 1, 27,
	42, 30, -34, 0, 2, 28,
	44, 30, -26, 0, 0, 28,
	36, 24, -29, 2, 2, 27,
	36, 24, -29, 2, 0, 27,
	10, 20, -21, 2, 2, 27,
	10, 14, -18, 1, 1, 27,
	10, 20, -14, 2, 0, 27,
	// Vas. taka
	-40, 0, 2, 1, 1, 27,
	-44, 30, -2, 0, 2, 28,
	-46, 30, 6, 0, 0, 28,
	-38, 24, 1, 2, 2, 27,
	-38, 24, 1, 2, 0, 27,
	-10, 20, -11, 2, 2, 27,
	-10, 14, -8, 1, 1, 27,
	-10, 20, -4, 2, 0, 27,
	// Oik. taka
	40, 0, 2, 1, 1, 27,
	44, 30, -2, 0, 2, 28,
	46, 30, 6, 0, 0, 28,
	38, 24, 1, 2, 2, 27,
	38, 24, 1, 2, 0, 27,
	10, 20, -11, 2, 2, 27,
	10, 14, -8, 1, 1, 27,
	10, 20, -4, 2, 0, 27,
	// Takapodi ala
	-12, 14, -2, 0, 2, 28,
	12, 14, -2, 2, 2, 28,
	-12, 14, 20, 0, 0, 27,
	12, 14, 20, 2, 0, 27,
	-12, 20, -6, 0, 0, 27,
	12, 20, -6, 2, 0, 27,
	-20, 20, -2, 2, 2, 27,
	20, 20, -2, 0, 2, 27,
	-20, 20, 20, 2, 0, 27,
	20, 20, 20, 0, 0, 27,
	-12, 20, 28, 0, 2, 28,
	12, 20, 28, 2, 2, 28,
	// Takapodi ylä
	-10, 42, 2, 0, 0, 28,
	10, 42, 2, 2, 0, 28,
	-10, 42, 18, 0, 2, 27,
	10, 42, 18, 2, 2, 27,
	-10, 34, -2, 0, 2, 27,
	10, 34, -2, 2, 2, 27,
	-16, 34, 2, 2, 0, 27,
	16, 34, 2, 0, 0, 27,
	-16, 34, 18, 2, 2, 28,
	16, 34, 18, 0, 2, 28,
	-10, 34, 24, 0, 0, 27,
	10, 34, 24, 2, 0, 27,
	-16, 34, 2, 1, 1, 27,
	16, 34, 2, 1, 1, 27,
	// Etupodi
	-12, 15, -32, 0, 2, 27,
	12, 15, -32, 2, 2, 27,
	-17, 15, -26, 1, 1, 28,
	17, 15, -26, 1, 1, 28,
	-18, 15, 2, 2, 2, 27,
	18, 15, 2, 0, 2, 27,
	-12, 28, -19, 0, 0, 28,
	12, 28, -19, 2, 0, 28,
	-12, 28, 2, 0, 2, 27,
	12, 28, 2, 2, 2, 27,
	18, 15, 2, 1, 1, 27,
	-18, 15, 2, 0, 2, 27,
	18, 15, 2, 2, 2, 27
};
Uint8 form_tachikoma_ref[] =
{
	// Vas. etu
	0, 2, 1,
	0, 4, 2,
	0, 1, 3,
	6, 2, 4,
	2, 6, 7,
	1, 6, 3,
	6, 1, 5,
	1, 7, 5,
	7, 1, 2,
	// Oik. etu
	8, 9, 10,
	8, 10, 12,
	8, 11, 9,
	14, 12, 10,
	10, 15, 14,
	9, 11, 14,
	14, 13, 9,
	9, 13, 15,
	15, 10, 9,
	// Vas. taka
	16, 18, 17,
	16, 20, 18,
	16, 17, 19,
	22, 18, 20,
	18, 22, 23,
	17, 22, 19,
	22, 17, 21,
	17, 23, 21,
	23, 17, 18,
	// Oik. etu
	24, 25, 26,
	24, 26, 28,
	24, 27, 25,
	30, 28, 26,
	26, 31, 30,
	25, 27, 30,
	30, 29, 25,
	25, 29, 31,
	31, 26, 25,
	// Takapodi ala
	32, 33, 35,
	35, 34, 32,
	32, 38, 36,
	33, 37, 39,
	35, 41, 43,
	34, 42, 40,
	32, 34, 40,
	40, 38, 32,
	33, 39, 41,
	41, 35, 33,
	32, 36, 37,
	37, 33, 32,
	34, 35, 43,
	43, 42, 34,
	// Takapodi ylä
	44, 46, 47,
	47, 45, 44,
	44, 48, 50,
	45, 51, 49,
	47, 55, 53,
	46, 52, 54,
	46, 44, 50,
	50, 52, 46,
	45, 47, 53,
	53, 51, 45,
	45, 49, 48,
	48, 44, 45,
	55, 47, 46,
	46, 54, 55,
	// Takapodi reunat
	38, 40, 56,
	40, 52, 56,
	40, 42, 54,
	54, 52, 40,
	42, 43, 55,
	55, 54, 42,
	43, 41, 53,
	53, 55, 43,
	41, 39, 57,
	57, 53, 41,
	39, 37, 49,
	49, 51, 39,
	37, 36, 48,
	48, 49, 37,
	36, 38, 50,
	50, 48, 36,
	// Etupodi
	58, 62, 60,
	59, 61, 63,
	58, 59, 68,
	68, 62, 58,
	64, 58, 60,
	65, 61, 59,
	70, 61, 65,
	65, 67, 63,
	62, 66, 64,
	64, 60, 69,
	64, 66, 67,
	67, 65, 64,
	64, 65, 59,
	59, 58, 64
};

/*
 * Blade Runner lives 4eva!
 */
#define FORM_UNICORN_VERTS	39
#define FORM_UNICORN_INDEXES	((4 * 3 + 6 + 16 + 4 + 9 + 3)* 3)
Sint8 form_unicorn_tcv[] =
{
	-15, 0, -15, 1, 1, 3, // 0
	15, 0, -15, 1, 1, 3, // 1
	-15, 0, 15, 1, 1, 3, // 2
	15, 0, 15, 1, 1, 3, // 3
	-10, 20, -15, 0, 2, 3, // 4
	0, 20, -15, 0, 2, 30, // 5
	9, 20, -15, 2, 2, 3, // 6
	-9, 20, -8, 0, 0, 30, // 7
	9, 20, -8, 2, 0, 30, // 8
	-9, 20, 8, 0, 2, 30, // 9
	9, 20, 8, 2, 2, 30, // 10
	-9, 20, 15, 0, 0, 3, // 11
	0, 20, 15, 0, 2, 30, // 12
	9, 20, 15, 2, 0, 3, // 13
	0, 35, -15, 1, 1, 3, // 14
	-5, 35, -11, 2, 0, 3, // 15
	5, 35, -11, 0, 0, 3, // 16
	-8, 35, 6, 2, 2, 3, // 17
	8, 35, 6, 0, 2, 3, // 18
	-5, 35, 14, 2, 0, 3, // 19
	5, 35, 14, 0, 0, 3, // 20
	0, 38, 20, 1, 1, 30, // 21
	0, 44, -32, 1, 1, 3, // 22
	-8, 50, -20, 2, 2, 30, // 23
	8, 50, -20, 0, 2, 30, // 24
	0, 42, -24, 1, 1, 3, // 25
	0, 20, -15, 2, 2, 30, // 26 = 5
	-9, 20, -15, 1, 1, 3, // 27 = 4
	9, 20, -15, 1, 1, 3, // 28 = 6
	0, 35, -15, 2, 2, 3, // 29 = 14
	0, 35, -15, 0, 2, 3, // 30 = 14
	0, 20, 15, 2, 2, 30, // 31 = 12
	0, 44, -32, 0, 2, 3, // 32 = 22
	0, 44, -32, 0, 0, 3, // 33 = 22
	-3, 49, -21, 0, 0, 16, // 34
	3, 49, -21, 2, 0, 16, // 35
	0, 47, -22, 2, 0, 16, // 36
	0, 47, -22, 0, 0, 16, // 37
	0, 60, -30, 1, 1, 30, // 38
};
Uint8 form_unicorn_ref[] =
{
	// vas etu
	0, 7, 4,
	0, 5, 7,
	0, 4, 26,
	// oik etu
	1, 5, 6,
	1, 8, 26,
	1, 6, 8,
	// vas taka
	2, 11, 9,
	2, 12, 11,
	2, 9, 31,
	// oik taka
	3, 13, 31,
	3, 10, 13,
	3, 12, 10,
	// ruho etu
	14, 26, 4,
	14, 6, 5,
	15, 29, 27,
	30, 16, 28,
	27, 7, 15,
	8, 28, 16,
	// ruho keski
	7, 17, 15,
	7, 9, 17,
	15, 17, 18,
	15, 18, 16,
	16, 18, 10,
	16, 10, 8,
	8, 10, 9,
	8, 9, 7,
	9, 11, 19,
	9, 19, 17,
	17, 19, 20,
	17, 20, 18,
	18, 20, 13,
	18, 13, 10,
	10, 13, 11,
	10, 11, 9,
	// ruho taka
	19, 11, 21,
	20, 19, 21,
	13, 20, 21,
	11, 13, 21,
	// kaula ja pää
	15, 23, 14,
	30, 23, 25,
	16, 14, 24,
	29, 25, 24,
	15, 16, 24,
	15, 24, 23,
	23, 24, 22,
	25, 23, 32,
	25, 33, 24,
	// sarvi
	34, 35, 38,
	34, 38, 36,
	37, 38, 35
};

/*
 * Varis.
 */
#define FORM_VARIS_VERTS	8
#define FORM_VARIS_INDEXES	(8 * 3)
Sint8 form_varis_tcv[] =
{
	0, -5, -15,	1, 1, 3,
	0, -9, -14,	1, 1, 3,
	0, 15, 0,	2, 2, 31,
	-15, 0, 8,	0, 2, 31,
	15, 0, 8,	2, 0, 31,
	-30, -15, 16,	1, 1, 3,
	0, -15, 16,	0, 0, 31,
	30, -15, 16,	1, 1, 3
};
Uint8 form_varis_ref[] =
{
	0, 2, 3,
	0, 4, 2,
	1, 3, 6,
	1, 6, 4,
	3, 2, 6,
	2, 4, 6,
	5, 3, 6,
	6, 4, 7
};

//############################################################################
// Polut #####################################################################
//############################################################################

/*
 * Lentsikka.
 */
#define TRAIL_PLANE_LEN		10
PathPacked trail_plane[] =
{
	{ { -3000, 0, -3000 }, { 0, 0, 0 }, 0 },
	{ { 11800, 3000, 12000 }, { 7, 0, 6 }, 10 },
	{ { 13500, 3000, 14500 }, { 1, 0, 1 }, 50 },
	{ { 20000, 3500, 32000 }, { 1, 0, 4 }, 0 },
	{ { 20000, 3500, 32000 }, { 1, 0, 4 }, 0 },
	{ { 26100, 7000, 27000 }, { -7, 0, 1 }, 0 },
	{ { 22800, 6500, 28000 }, { -7, 0, 1 }, 0 },
	{ { 23800, 4400, 27600 }, { 1, 0, -7 }, 0 },
	{ { 23680, 4010, 27450 }, { 100, 0, 0 }, 0 },
	{ { 23780, 4010, 27450 }, { 100, 0, 0 }, 0 },
	{ { 23780, 4010, 27450 }, { 100, 0, 0 }, 0 }
};
PathDB path_plane;

/*
 * Tachikoma
 */
#define TRAIL_TACHIKOMA_LEN		10
PathPacked trail_tachikoma[] =
{
	{ { 23260, 4950, 22800 }, { 0, 0, 0 }, 0 },
	{ { 23260, 4950, 22300 }, { 0, 0, 0 }, 0 },
	{ { 23260, 4950, 21800 }, { 0, 0, 0 }, 0 },
	{ { 23260, 4960, 21200 }, { 0, 0, 0 }, 0 },
	{ { 22760, 5030, 21380 }, { 0, 0, 0 }, 0 },
	{ { 22260, 5030, 21380 }, { 0, 0, 0 }, 0 },
	{ { 22100, 5030, 21380 }, { 0, 0, 0 }, 0 },
	{ { 22100, 5030, 21380 }, { 0, 0, 0 }, 0 },
	{ { 22100, 5030, 21380 }, { 0, 0, 0 }, 0 }
};
PathDB path_tachikoma;

//############################################################################
// Flare-gravitaatio #########################################################
//############################################################################

#define FLARE_W			100
#define FLARE_H			100
#define FLARE_AMOUNT		20
#define FLARE_MINIMUM_DISTANCE	0.01f
#define FLARE_INITIAL_SPEEDS	0.1f
#define FLARE_CENTRAL_FORCE	0.00001f
#define FLARE_FRICTION		0.999f
#define FLARE_GRAVITY_CONSTANT	0.05f

float flare_positions[FLARE_AMOUNT][3];
float flare_speeds[FLARE_AMOUNT][3];
float flare_masses[FLARE_AMOUNT];
float flare_forces[FLARE_AMOUNT][3];
float gravconst;

int texture_flare;

void flare_init()
{
	int i, j;
	float temp;

	for(j = 0; j < FLARE_H; j++)
	{
		for(i = 0; i < FLARE_W; i++)
		{
			temp = (float)sqrt(
					pow(((float)j - (float)FLARE_H / 2.0) / ((float)FLARE_H / 2.0), 2) +
					pow(((float)i - (float) FLARE_W / 2.0) / ((float)FLARE_W / 2.0), 2));
			if(temp > 1.0f) temp = 1.0f;
#if SDL_BYTEORDER == SDL_LIL_ENDIAN
			texture_playground[j * FLARE_W+i] = ((int)(0xFF * (1.0f - temp))) << 24;
			texture_playground[j * FLARE_W+i] |= 0xFF;
#else
			texture_playground[j * FLARE_W+i] = (int)(0xFF * (1.0f - temp));
			texture_playground[j * FLARE_W+i] |= 0xFF000000;
#endif
		}
	}
	texture_create(&texture_flare, FLARE_W, FLARE_H);

	for(i = 0; i < FLARE_AMOUNT * 3; i++)
	{
		flare_speeds[i][0] = rand_float_neg(FLARE_INITIAL_SPEEDS);
		flare_forces[i][0] = 0;
		flare_speeds[i][1] = rand_float_neg(FLARE_INITIAL_SPEEDS);
		flare_forces[i][1] = 0;
		flare_speeds[i][2] = rand_float_neg(FLARE_INITIAL_SPEEDS);
		flare_forces[i][2] = 0;
	}
	for(i=0; i<FLARE_AMOUNT; i++) {
		flare_positions[i][0] = rand_float_neg(10);
		flare_positions[i][1] = rand_float_neg(10);
		flare_positions[i][2] = rand_float_neg(10);
		flare_masses[i] = rand_float(1) + 0.01f;
	}
	gravconst = FLARE_GRAVITY_CONSTANT;
}

void flare_advance_frame()
{
	int i, j;
	float force;
	float dist;
	float dist2;
	float dx, dy, dz;
	float fx, fy, fz;

	for(i=0; i < FLARE_AMOUNT; i++) {
		flare_forces[i][0] = 0;
		flare_forces[i][1] = 0;
		flare_forces[i][2] = 0;
	}

	for(i = 0; i < FLARE_AMOUNT; i++)
		for(j = i; j < FLARE_AMOUNT; j++)
			if(i!=j)
			{
				dx = flare_positions[i][0] - flare_positions[j][0];
				dy = flare_positions[i][1] - flare_positions[j][1];
				dz = flare_positions[i][2] - flare_positions[j][2];
				dist2 = (float)(pow(dx, 2) + pow(dy, 2) + pow(dz, 2));
				if(dist2 < FLARE_MINIMUM_DISTANCE)
					dist2 = FLARE_MINIMUM_DISTANCE;
				dist = (float)sqrt(dist2);
				force = gravconst * flare_masses[i] * flare_masses[j] / dist2; //pow(dist,1.3);
				fx = (dx / dist) * force;
				fy = (dy / dist) * force;
				fz = (dz / dist) * force;
				flare_forces[i][0] -= fx;
				flare_forces[j][0] += fx;
				flare_forces[i][1] -= fy;
				flare_forces[j][1] += fy;
				flare_forces[i][2] -= fz;
				flare_forces[j][2] += fz;
				flare_forces[i][0] -= flare_positions[i][0] * FLARE_CENTRAL_FORCE;
				flare_forces[j][0] -= flare_positions[j][0] * FLARE_CENTRAL_FORCE;
				flare_forces[i][1] -= flare_positions[i][1] * FLARE_CENTRAL_FORCE;
				flare_forces[j][1] -= flare_positions[j][1] * FLARE_CENTRAL_FORCE;
				flare_forces[i][2] -= flare_positions[i][2] * FLARE_CENTRAL_FORCE;
				flare_forces[j][2] -= flare_positions[j][2] * FLARE_CENTRAL_FORCE;
			}

	for(i = 0; i < FLARE_AMOUNT; i++)
	{
		flare_speeds[i][0] += flare_forces[i][0] / flare_masses[i];
		flare_speeds[i][0] *= FLARE_FRICTION;
		flare_speeds[i][1] += flare_forces[i][1] / flare_masses[i];
		flare_speeds[i][1] *= FLARE_FRICTION;
		flare_speeds[i][2] += flare_forces[i][2] / flare_masses[i];
		flare_speeds[i][2] *= FLARE_FRICTION;
		flare_positions[i][0] += flare_speeds[i][0];
		flare_positions[i][1] += flare_speeds[i][1];
		flare_positions[i][2] += flare_speeds[i][2];
	}
}

void flare_display(int col)
{
	int i;
	float size;
	shapedb_clear(&shape_use);

	for(i=0; i<FLARE_AMOUNT; i++)
	{
		size = (float)pow(flare_masses[i], 1.0f / 3.0f);
		shapedb_add_tcv(&shape_use, flare_positions[i][0] - size,
				flare_positions[i][1] - size, flare_positions[i][2], 0.0f,
				0.0f, col);
		shapedb_add_tcv(&shape_use, flare_positions[i][0] + size,
				flare_positions[i][1] - size, flare_positions[i][2], 1.0f,
				0.0f, col);
		shapedb_add_tcv(&shape_use, flare_positions[i][0] + size,
				flare_positions[i][1] + size, flare_positions[i][2], 1.0f,
				1.0f, col);
		shapedb_add_tcv(&shape_use, flare_positions[i][0] - size,
				flare_positions[i][1] + size, flare_positions[i][2], 0.0f,
				1.0f, col);
	}

	for(i = 0; i < FLARE_AMOUNT * 4; i++) 
		shapedb_add_index(&shape_use, i);

	shapedb_draw_elements(&shape_use, texture_flare, GL_MODULATE, GL_QUADS);
}

//############################################################################
// Väläytykset ###############################################################
//############################################################################

// Fraktaalitekstuurit
#define JULIA_AMOUNT	47
#define VOLTERRO_AMOUNT	40
#define FRACTAL_AMOUNT	(JULIA_AMOUNT + VOLTERRO_AMOUNT)
#define VOLTERRO1	JULIA_AMOUNT
#define VOLTERRO2	(FRACTAL_AMOUNT - 1)
int texture_fractal[FRACTAL_AMOUNT];

// Väläykset
#define FLASH_COUNT	(22 + 8 + 13 + 3 + 3 + 11) // Normaalit plus fraktaalit
FlashUnit var_flash[] =
{
	// Circles basaria
	{ 330, 110, 34, 0, 1, 3, 3 }, // 1
	{ 455, 110, 34, 0, 1, 4, 4 },
	{ 570, 110, 34, 0, 1, 5, 5 },
	{ 695, 110, 34, 0, 1, 6, 6 },
	{ 810, 110, 34, 0, 1, 7, 7 }, // 5
	{ 935, 110, 34, 0, 1, 8, 8 },
	{ 1950, 50, 34, 0, 1, 1, 1 },
	{ 2000, 50, 34, 0, 1, 2, 2 },
	{ 2070, 50, 34, 0, 1, 13, 13 },
	{ 2130, 50, 34, 0, 1, 14, 14 }, // 10
	{ 2190, 50, 34, 0, 1, 9, 9 },
	{ 2250, 50, 34, 0, 1, 10, 10 },
	{ 2312, 50, 34, 0, 1, 11, 11 },
	{ 2375, 50, 34, 0, 1, 15, 15 }, 
	{ 2435, 50, 34, 0, 1, 16, 16 }, // 15
	{ 2500, 50, 34, 0, 1, 17, 17 },
	{ 2560, 50, 34, 0, 1, 18, 18 },
	{ 2615, 50, 34, 0, 1, 19, 19 },
	{ 2680, 50, 34, 0, 1, 20, 20 },
	{ 2740, 50, 34, 0, 1, 21, 21 }, // 20
	{ 2800, 50, 34, 0, 1, 22, 22 },
	{ 2865, 50, 34, 0, 1, 23, 23 },
	// Circles siivet ja vaihto
	{ WINGS_END, 110, 2, 0, 0, 0, 0 },
	{ CIRCLES_END - 100, 100, 0, 13, 1, 0, 0 },
	{ CIRCLES_END - 120, 30, 0, 34, 1, VOLTERRO2, VOLTERRO1 },
	{ CIRCLES_END - 120, 30, 0, 34, 1, VOLTERRO2, VOLTERRO1 },
	{ CIRCLES_END - 90, 90, 34, 34, 1, VOLTERRO1 + 2, VOLTERRO2 },
	{ CIRCLES_END - 90, 90, 34, 34, 1, VOLTERRO1 + 2, VOLTERRO2 },
	{ CITY_START, 90, 34, 0, 1, VOLTERRO2, VOLTERRO1 },
	{ CITY_START, 90, 34, 0, 1, VOLTERRO2, VOLTERRO1 },
	// Kaupungin ohjaus
	{ CITY_START + CITY_HALT_1, 200, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_FOLD_1, 40, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_FOLD_1_END, 100, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_HALT_2, 200, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_FOLD_2, 40, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_FOLD_2_END, 100, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_HALT_3, 200, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_FOLD_3, 40, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_FOLD_3_END, 100, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_XRAY, CITY_XRAY_DUR, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_XRAY_END, CITY_XRAY_DUR, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_XRAY2, CITY_XRAY2_DUR, 2, 0, 0, 0, 0 },
	{ CITY_START + CITY_XRAY2_END, CITY_XRAY2_DUR, 2, 0, 0, 0, 0 },
	// Kaupungin lopun väläytykset
	{ CITY_END - 200, 200, 0, 33, 1, 0, 0 },
	{ 8505, 60, 34, 0, 1, 15, 15 },
	{ 8625, 60, 34, 0, 1, 16, 16 },
	// Gitsin alun vaihto
	{ GITS_START - 30, 30, 0, 34, 1, VOLTERRO2, VOLTERRO1 },
	{ GITS_START, 90, 34, 34, 1, VOLTERRO1, VOLTERRO2 },
	{ GITS_START + 91, 90, 34, 0, 1, VOLTERRO2, VOLTERRO1 },
	// Greetsit
	{ 10330, 90, 26, 0, 1, 27, 27 }, // 1
	{ 10450, 90, 26, 0, 1, 28, 28 },
	{ 10570, 90, 26, 0, 1, 29, 29 },
	{ 10700, 90, 26, 0, 1, 30, 30 },
	{ 10820, 90, 26, 0, 1, 31, 31 }, // 5
	{ 10940, 90, 26, 0, 1, 32, 32 },
	{ 11065, 90, 26, 0, 1, 33, 33 },
	{ 11180, 90, 26, 0, 1, 34, 34 },
	{ 11305, 90, 26, 0, 1, 35, 35 },
	{ 11430, 90, 26, 0, 1, 36, 36 }, // 10
	{ 11550, 90, 26, 0, 1, 37, 37 }
};

/*
 * Tee ruudun väläytykseen käytettävä shape shape_use:een annetuilla väreillä.
 */

/*
 * Väläytä ruutu.
 */
void screen_flash(int freezetime)
{
	int i, tex;
	float pos;
	FlashUnit* unit;

	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

	for(i = 0; i < FLASH_COUNT; i++)
	{
		unit = &var_flash[i];
		if((freezetime >= unit->start) &&
				(freezetime < unit->start + unit->duration))
		{
			// Laske vaihe
			pos = interpolate_count_lt(freezetime, unit->start, unit->duration);
			// Interpoloi
			interpolate_linear_ff(colordb_get_float(COLORDB_FLASH),
					colordb_get_float(unit->ca), colordb_get_float(unit->cb), pos, 3);
			// Syötä väriksi
			colordb_convert_f2u(COLORDB_FLASH);
			// Tila, kamera ja tyhjennys
			camera_ortho(4.0f);
			glLoadIdentity();
			blend_mode(unit->blendmode);

			// Create the display surface for the fractal
			shapedb_clear(&shape_use);
			shapedb_read_tcvdata(&shape_use, form_flash_tcv, form_flash_ref,
					FORM_FLASH_VERTS, FORM_FLASH_INDEXES);
			// Then draw it
			if(unit->tex1)
			{
				// Laske vaihe
				tex = (Uint8)((pos * (float)(unit->tex2 - unit->tex1)) + unit->tex1);
				// Näytä fraktaali
				shapedb_draw_elements(&shape_use, texture_fractal[tex],
						GL_MODULATE, GL_QUADS);
				// Flaret vain julioille
				if(unit->tex1 == unit->tex2)
				{
					// Aseta kamera flarekatseluun
					camera_frustum(90.0f, 2000.0f);
					glLoadIdentity();
					look_at(lookat_fractal, freezetime);
					// Piirrä flaret
					flare_advance_frame();
					flare_display(COLORDB_FLASH);
				}
			}
			else
				shapedb_draw_elements(&shape_use, 0, 0, GL_QUADS);
		}
	}
}

//############################################################################
// Polut #####################################################################
//############################################################################

#define PATH_MODE_NORMAL	0
#define PATH_MODE_FWD		1
#define PATH_SPLINE_LOOKAHEAD	0.45f

/*
 * Tyhjentää polun.
 */
void path_clear(PathDB *pth)
{
	pth->cnt = 0;
	pth->len_total = 0.0f;
}

/*
 * Lisää polkuun seuraavan nurkkapisteen.
 */
void path_add_v(PathDB *pth, float x, float y, float z)
{
	PathUnit *unit = pth->unit + pth->cnt, *prev;

	unit->pos[0] = x;
	unit->pos[1] = y;
	unit->pos[2] = z;

	if(pth->cnt > 0)
	{
		prev = unit - 1;
		pth->len_total += vecdist(prev->pos, unit->pos);
		unit->len_upto = pth->len_total;
	}
	else
		unit->len_upto = 0.0f;

	// Pituus kasvoi
	pth->cnt++;
}

/*
 * Lisää polkuun seuraavan nurkkapisteen ja upvectorin
 */
void path_add_vd(PathDB *pth, float x, float y, float z, float dx, float dy,
		float dz, float roll)
{
	PathUnit *unit = pth->unit + pth->cnt;

	// Lisää normaalisti
	path_add_v(pth, x, y, z);

	// Upvector
	unit->dir[0] = dx;
	unit->dir[1] = dy;
	unit->dir[2] = dz;
	unit->roll = roll;
}

/*
 * Palauttaa viittauksen viimeiseen polun nurkkapisteeseen.
 */
float *path_get_last(PathDB *pth)
{
	return pth->unit[pth->cnt - 1].pos;
}

/*
 * Laske paikka polulla. Lineaarinen versio.
 */
int path_get_pos_linear(PathDB *pth, float *dst, float speed, int timeleft)
{
	float dist = (float)timeleft * speed,
				*dst1, *dst2;
	PathUnit *prev = pth->unit + 0, *next = pth->unit + 1;

	// Jos ei olla polulla lainkaan
	if((dist > pth->len_total) || (dist < 0.0f))
		return 0;

	// Kelataan
	while(!((prev->len_upto <= dist) && (dist < next->len_upto)))
	{
		prev++;
		next++;
	}

	// Ollaan oikeassa kohdassa
	dist = (dist - prev->len_upto) / (next->len_upto - prev->len_upto);
	dst1 = prev->pos;
	dst2 = next->pos;

	// Interpoloi kohteeseen ja palauta tosi
	interpolate_linear_ff(dst, dst1, dst2, dist, 2);
	return 1;
}

/*
 * Laske painotus flotaritaulukkoon. Palauta kokonaispaino.
 */
float path_count_spline_weight(PathDB *pth, float *dst, int first, float dist)
{
	int i, j;
	float diff, ret = 0.0f;

	// Lisäillään
	for(i = first, j = 0; j <= 3; i++, j++)
	{
		if((i >= 0) && (i < pth->cnt))
		{
			diff = 1.0f - 0.5f * (float)fabs((float)i - dist);
			dst[j] = diff * diff;
			ret += dst[j];
		}
		else
			dst[j] = 0.0f;
	}

	return ret;
}

/*
 * Laske paikka polulla painokerrointen ja kokonaispainon mukaan.
 */
float path_count_spline_pos(PathDB *pth, float *dst, float *wt, int first,
		float totwt, int mode)
{
	int i, j, k;
	float diff, roll = 0.0f;
	PathUnit *unit;

	for(i = first, j = 0; j <= 3; i++, j++)
		if(wt[j] > 0.0f)
		{
			// Painotus
			diff = wt[j] / totwt;
			// Yksikkö
			unit = pth->unit + i;
			// Lasketaan
			for(k = 0; k < 3; k++)
			{
				dst[k] += diff * unit->pos[k];
				if(mode == PATH_MODE_NORMAL)
					dst[3 + k] += diff * unit->dir[k];
			}
			roll += diff * unit->roll;
		}

	return roll;
}

/*
 * Laske paikka polulla. Käsittelee polkua b-splinenä. Tai jonakin vähän
 * sinne päin. Ei palauta kohdetta, vaan translatoi ja rotatoi valmiiksi.
 * Kannattanee muistaa Push/PopMatrix.
 */
int path_get_pos_spline(PathDB *pth, float dist, int mode)
{
	float dst[7] = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f },
				wt[4], totwt;
	int first = (int)floor(dist) - 1;

	// Kait me ollaan polulla?
	if((dist < 0.0f) || (dist >= pth->cnt))
		return 0;

	// Lisäillään
	totwt = path_count_spline_weight(pth, wt, first, dist);

	if(mode == PATH_MODE_NORMAL)
		dst[6] = path_count_spline_pos(pth, dst, wt, first, totwt, mode);
	else
	{
		dst[6] = path_count_spline_pos(pth, dst, wt, first, totwt, mode);
		dist += PATH_SPLINE_LOOKAHEAD;
		first = (int)floor(dist) - 1;
		totwt = path_count_spline_weight(pth, wt, first, dist);
		path_count_spline_pos(pth, dst + 3, wt, first, totwt, mode);
		vecsub(dst + 3, dst + 3, dst);
	}

	/*if(mode == PATH_MODE_NORMAL)
		{
		printf("Plane at: %f, %f, %f\n", dst[0], dst[1], dst[2]);
		}*/

	glRotateTranslatefv(dst, dst + 3, dst[6]);
	return 1;
}

/*
 * Olen laiska, joten tämä generoi spline-polkujen dst-kohdearvot katsomalla
 * seuraavaan koordinaattiin.
 */
/*void path_create_dst(PathDB *pth)
	{
	int i, j;
	PathUnit *prev = pth->unit + 0, *next = pth->unit + 1;

	for(i = 0; i < pth->cnt - 1; i++, prev++, next++)
	for(j = 0; j < 3; j++)
	prev->dir[j] = next->pos[j] - prev->pos[j];

	next = pth->unit + pth->cnt - 1;
	prev = pth->unit + pth->cnt - 2;

	for(j = 0; j < 3; j++)
	prev->dir[j] = prev->dir[j];
	}*/

/*
 * Lue pakattua polkudataa.
 */
void path_read_vddata(PathDB *pth, PathPacked *src, int cnt)
{
	int i;

	path_clear(pth);

	for(i = 0; i < cnt; i++, src++)
		path_add_vd(pth, (float)src->pos[0], (float)src->pos[1],
				(float)src->pos[2], (float)src->dir[0],	(float)src->dir[1],
				(float)src->dir[2], (float)src->roll);
}

/*
 * Ulkoinen funktio, joka tekee sööttiä pomppimista objekteille. Tallentaa
 * matriisin, joten sinun ei tarvitse!
 */
float path_hop(int freezetime, int waittime, float frac, int waitbig,
		int waitsml, float ht)
{
	int currtime;
	float pos, adv;

	// otetaan täydet jaksot
	pos = (float)(freezetime / waittime);

	// laske remainder
	currtime = freezetime % waittime;

	// lisää jaksojen neljännekset
	pos += frac * (float)(currtime / waitbig);

	// Jos ollaan liikkumisvaiheessa
	currtime = currtime % waitbig;
	if((currtime / waitsml) != 0)
	{
		adv = (float)(currtime - waitsml) / (float)waitsml;
		pos += adv * frac;
		glTranslatef(0.0f, (float)sin(adv * M_PI) * ht, 0.0f);
	}

	return pos;
}

//############################################################################
// Textout ###################################################################
//############################################################################

// Fontti
Char2D var_characters[50] =
{
	{ { 12, 103, 18, -1, 46, 50, -1, -1, -1, -1 } }, // A - 1
	{ { 100, 12, -1, 101, 82, 68, -1, 57, 38, 13 } }, // B - 2
	{ { 84, 104, 102, 78, 34, 14, 16, 40, -1, -1 } }, // C - 3
	{ { 100, 12, -1, 101, 60, 13, -1, -1, -1, -1 } }, // D - 4
	{ { 57, 59, 83, 103, 101, 89, 34, 14, 16, 28 } }, // E - 5
	{ { 100, 12, -1, 101, 104, -1, 57, 60, -1, -1 } }, // F - 6
	{ { 84, 104, 102, 78, 34, 14, 16, 40, 51, 49 } }, // G - 7
	{ { 100, 12, -1, 105, 17, -1, 57, 60, -1, -1 } }, // H - 8
	{ { 100, 102, -1, 90, 24, -1, 12, 14, -1, -1 } }, // I - 9
	{ { 103, 105, -1, 93, 38, 14, 34, -1, -1, -1 } }, // J - 10
	{ { 100, 12, -1, 57, 82, -1, 46, 16, -1, -1 } }, // K - 11
	{ { 100, 102, -1, 90, 24, -1, 12, 16, 27, -1 } }, // L - 12
	{ { 12, 100, 70, 106, 18, -1, -1, -1, -1, -1 } }, // M - 13
	{ { 12, 100, 17, 105, -1, -1, -1, -1, -1, -1 } }, // N - 14
	{ { 14, 34, 78, 102, 104, 84, 40, 16, 14, -1 } }, // O - 15
	{ { 100, 12, -1, 101, 82, 57, -1, -1, -1, -1 } }, // P - 16
	{ { 103, 67, 70, -1, 104, 16, -1, 37, 39, -1 } }, // Q - 17
	{ { 12, 100, 83, 57, 17, -1, -1, -1, -1, -1 } }, // R - 18
	{ { 83, 102, 78, 39, 15, 34, -1, -1, -1, -1 } }, // S - 19
	{ { 100, 105, -1, 91, 14, -1, -1, -1, -1, -1 } }, // T - 20
	{ { 100, 34, 13, 15, 38, 104, -1, -1, -1, -1 } }, // U - 21
	{ { 100, 15, 106, -1, -1, -1, -1, -1, -1, -1 } }, // V - 22
	{ { 100, 13, 37, 17, 106, -1, -1, -1, -1, -1 } }, // W - 23
	{ { 100, 69, 104, -1, 58, 14, -1, -1, -1, -1 } }, // Y - 24
	{ { 78, 102, 14, -1, -1, -1, -1, -1, -1, -1 } }, // 1 - 25
	{ { 78, 102, 82, 12, 16, -1, -1, -1, -1, -1 } }, // 2 - 26
	{ { 78, 102, 82, 58, 38, 14, 34, -1, -1, -1 } }, // 3 - 27
	{ { 100, 56, 60, -1, 103, 15, -1, -1, -1, -1 } }, // 4 - 28
	{ { 104, 101, 56, 60, 27, 15, 13, 23, -1, -1 } }, // 5 - 29
	{ { 104, 102, 78, 23, 13, 15, 27, 49, 59, 57 } }, // 6 - 30
	{ { 100, 104, 14, -1, 57, 60, -1, -1, -1, -1 } }, // 7 - 31
	{ { 78, 102, 82, 34, 14, 38, 78, -1, -1, -1 } }, // 8 - 32
	{ { 59, 57, 67, 89, 101, 103, 93, 38, 14, 12 } } // 9 - 33
};

// Stringit
char string_gfxcode[] = { 7, 18, 1, 16, 8, 9, 3, 19, 34, 3, 15, 4, 5, 0 };
char string_muscode[] = { 13, 21, 19, 9, 3, 34, 3, 15, 4, 5, 0 };
char string_other[] = { 15, 20, 8, 5, 18, 34, 3, 15, 4, 5, 0 };
char string_greets[] = { 7, 18, 5, 5, 20, 19, 0 };
char string_anakin[] = { 1, 14, 1, 11, 9, 14, 0 };
char string_blamstrain[] = { 2, 12, 1, 13, 19, 20, 18, 1, 9, 14, 0 };
char string_juippi[] = { 10, 21, 9, 16, 16, 9, 0 };
char string_ninave[] = { 14, 9, 14, 1, 22, 5, 0 };
char string_rmm[] = { 18, 13, 13, 0 };
char string_sihteeri[] = { 19, 9, 8, 20, 5, 5, 18, 9, 0 };
char string_smak[] = { 19, 13, 1, 11, 0 };
char string_theflash[] = { 20, 8, 5, 6, 12, 1, 19, 8, 0 };
char string_trilkk[] = { 20, 18, 9, 12, 11, 11, 0 };
char string_tuokku[] = { 20, 21, 15, 11, 11, 21, 0 };
char string_valquis[] = { 22, 1, 12, 17, 21, 9, 19, 0 };
char string_vv[] = { 22, 22, 0 };
char string_warma[] = { 23, 1, 18, 13, 1, 0 };
char string_thanks[] = { 20, 8, 1, 14, 11, 34, 24, 15, 21, 0 };
char string_watching[] = { 6, 15, 18, 34, 23, 1, 20, 3, 8, 9, 14, 7, 0 };
char string_origami[] = { 15, 18, 9, 7, 1, 13, 9, 0 };
char string_intro[] = { 1, 34, 26, 33, 27, 27, 27, 34, 2, 24, 20, 5, 34, 9, 14, 20, 18, 15, 0 };
char string_wait[] = { 16, 12, 5, 1, 19, 5, 34, 23, 1, 9, 20, 0 };

// Nämä vain jos preloaderi on päällä
#ifndef FLAG_NOSTDLIB
#ifndef FLAG_ENABLE_GTK
#ifndef WIN32
char string_fullscreen[] = { 6, 21, 12, 12, 19, 3, 18, 5, 5, 14, 0 };
char string_options[] = { 15, 16, 20, 9, 15, 14, 19, 0 };
char string_arrows_change_resolutions[] = { 1, 18, 18, 15, 23, 19, 34, 3, 8, 1, 14, 7, 5, 34, 18, 5, 19, 15, 12, 21, 20, 9, 15, 14, 19, 0 };
char string_f_toggles_fullscreen[] = { 6, 34, 20, 15, 7, 7, 12, 5, 19, 34, 6, 21, 12, 12, 19, 3, 18, 5, 5, 14, 0 };
char string_d_toggles_debugkeys[] = { 4, 34, 20, 15, 7, 7, 12, 5, 19, 34, 4, 5, 2, 21, 7, 11, 5, 24, 19, 0 };
char string_enter_or_space_to_run[] = { 5, 14, 20, 5, 18, 34, 15, 18, 34, 19, 16, 1, 3, 5, 34, 20, 15, 34, 18, 21, 14, 0 };
char string_yea[] = {24, 5, 1, 0 };
char string_nay[] = {14, 1, 24, 0 };
char string_res[] = { 18, 5, 19, 15, 12, 21, 20, 9, 15, 14, 0 };
char string_fractal_res[] = { 6, 18, 1, 3, 20, 1, 12, 34, 18, 5, 19, 0 };
char string_debugkeys[] = { 4, 5, 2, 21, 7, 11, 5, 24, 19, 0 };
char string_1600x1200[] = { 25, 30, 15, 15, 25, 26, 15, 15, 0 };
char string_1280x960[] = { 25, 26, 32, 15, 33, 30, 15, 0 };
char string_1152x864[] = { 25, 25, 29, 26, 32, 30, 28, 0 };
char string_1024x768[] = { 25, 15, 26, 28, 31, 30, 32, 0 };
char string_960x720[] = { 33, 30, 15, 31, 26, 15, 0 };
char string_800x600[] = { 32, 15, 15, 30, 15, 15, 0 };
char string_640x480[] = { 30, 28, 15, 28, 32, 15, 0 };
char string_512x384[] = { 29, 25, 26, 27, 32, 28, 0 };
char string_400x300[] = { 28, 15, 15, 27, 15, 15, 0 };
char string_320x240[] = { 27, 26, 15, 26, 28, 15, 0 };
#endif
#endif
#endif

/*
 * Piirrä yksittäinen merkki.
 */
float text_draw_char(char op, float *pos, float x, float y, float scalex,
		float scaley, int col)
{
	int i, j, last;
	float lastcrd[2], maxx;
	Char2D *chr = var_characters + (op - 1);

	shapedb_clear(&shape_use);

	last = -1;
	maxx = 0.0f;
	for(i = 0; (i < CHAR_MAX_STROKES) && (*pos > 0.0f); i++)
	{
		Sint8 crd = chr->stroke[i];
		float newcrd[2];

		// Jos terminaattori
		if(crd < 0)
		{
			if(last < 0)
				break;
		}
		else
		{
			// Laske uudet pisteet
			newcrd[0] = (float)(crd % 11) / 10.0f * scalex;
			newcrd[1] = (float)(crd / 11) / 10.0f * scaley;
			if(newcrd[0] > maxx)
				maxx = newcrd[0];
			newcrd[0] += x;
			newcrd[1] += y;

			if(last >= 0)
			{
				if(*pos < 1.0f)
					interpolate_linear_ff(newcrd, lastcrd, newcrd, *pos, 1);

				j = 10;
				do
				{
					float xdev = rand_float_neg(scalex / 11.0f),
								ydev = rand_float_neg(scalex / 11.0f);
					shapedb_add_cv(&shape_use, newcrd[0] + xdev, newcrd[1] + ydev, 0.0f,
							col);
					shapedb_add_cv(&shape_use, lastcrd[0] + xdev, lastcrd[1] + ydev,
							0.0f, col);
					shapedb_add_index_neg(&shape_use, 2);
					shapedb_add_index_neg(&shape_use, 1);
				} while(--j);

				// Vähennä kuljettavaa matkaa
				*pos -= 1.0f;
				if(*pos <= 0.0f)
					break;
			}
		}

		last = crd;
		lastcrd[0] = newcrd[0];
		lastcrd[1] = newcrd[1];
	}

	shapedb_draw_elements(&shape_use, 0, 0, GL_LINES);
	return maxx + scalex * 0.3f;
}

/*
 * Piirrä kokonainen string.
 */
void text_draw_string(char *op, float x, float y, float scalex,
		float scaley, int col, float op_pos)
{
	float pos = op_pos;

	while(*op)
	{
		if(*op == 34) // space
			x += scalex;
		else
			x += text_draw_char(*op, &pos, x, y, scalex, scaley, col);
		op++;
	}
}

/*
 * Monimutkainen textout-utilisaatio.
 */
void textout_complex(char *string, int freeze, int dur, int appear,
		float speed, float x, float y1, float y2, float scale, int col)
{
	float base, offset, scalepad;
	// Jos ollaan ulkopuolella altogether
	if(freeze >= dur)
		return;

	// Tila
	camera_ortho(1.0f);
	glPushMatrix();
	glLoadIdentity();
	blend_mode(1);

	// Muuttujat
	base = -1.0f;
	if(x < 0)
		base = 1.0f;

	// Jos se on tulossa vasta
	offset = x;
	if(freeze < appear)
		offset *= interpolate_count_lt(freeze, 0, appear);
	else if(dur - freeze < appear)
		offset *= interpolate_count_lt(dur, freeze, appear);

	// Piirto
	shapedb_clear(&shape_use);
	shapedb_add_cv(&shape_use, base + offset, y2, 0.0f, 12);
	shapedb_add_cv(&shape_use, base + offset, y1, 0.0f, 12);
	shapedb_add_cv(&shape_use, base, y1, 0.0f, 12);
	shapedb_add_cv(&shape_use, base, y2, 0.0f, 12);
	shapedb_add_index(&shape_use, 0);
	shapedb_add_index(&shape_use, 1);
	shapedb_add_index(&shape_use, 2);
	shapedb_add_index(&shape_use, 3);
	shapedb_draw_elements(&shape_use, 0, 0, GL_QUADS);

	scalepad = scale / 5.0f;
	text_draw_string(string,
			(x > 0) ? (-1.0f + scalepad - x + offset) : (1.0f + offset + scalepad),
			y1 + scalepad, scale, scale, col, (freeze - appear) * speed);
	glPopMatrix();
}

//############################################################################
// Spline ####################################################################
//############################################################################

/*
 * Anna piste kolmen pisteen bezier-käyrältä, t:[0,1]
 */
void qbezier(float *dst, float *a, float *b, float *c, float t)
{
	float m = 1.0f - t;
	float m2 = m * m,
				t2 = t * t;

	int i = 2;
	do
	{
		dst[i] = m2 * a[i] + 2.0f * t * m * b[i] + t2 * c[i];
	} while(i--);
}

/*
 * Piirrä quadratic bezier -käyrä.
 */
void efu_qbezier(BezierControl *bc, BezierLine *bl, int *ba, int col,
		int freezetime)
{
	int i, from, to;
	float pos, d[3*3], u[3*3];

	from = 0;
	to = 1;

	while(1)
	{
		if((freezetime >= ba[from]) && (freezetime < ba[to]))
			break;
		from++;
		to++;
	}

	pos = interpolate_count_se(freezetime, ba[from], ba[to]);

	from *= 3;
	to *= 3;
	i = 2;
	do
	{
		Sint16 *dl = bc[bl->d[i]].pos,
					 *ul = bc[bl->u[i]].pos;
		interpolate_linear_i16f(d + i * 3, dl + from, dl + to, pos, 2);
		interpolate_linear_i16f(u + i * 3, ul + from, ul + to, pos, 2);
	} while(i--);

	shapedb_clear(&shape_use);
	i = 11;
	pos = 0.0f;
	do
	{
		float tgt[3];
		qbezier(tgt, d + 0, d + 3, d + 6, pos);
		shapedb_add_cv(&shape_use, tgt[0], tgt[1], tgt[2], col);
		qbezier(tgt, u + 0, u + 3, u + 6, pos);
		shapedb_add_cv(&shape_use, tgt[0], tgt[1], tgt[2], col);
		shapedb_add_index_neg(&shape_use, 2);
		shapedb_add_index_neg(&shape_use, 1);
		pos += 0.1f;
	} while(--i);

	// Piirrä
	shapedb_draw_elements(&shape_use, 0, 0, GL_TRIANGLE_STRIP);
}

//############################################################################
// Siivet ####################################################################
//############################################################################

/*
 * Siipien pisteet.
 */
BezierControl var_wingc[9] = 
{
	{ // 0
		{ 0, 0, 0,
			0, 0, 0,
			0, 0, 0,
			0, 0, 0,
			0, 0, 0
		}
	},
	{ // 1
		{
			0, 50, 0,
			5, 50, -10,
			10, 50, -10,
			15, 50, -5,
			50, 80, -0
		}
	},
	{ // 2
		{
			0, 100, 0,
			10, 100, 0,
			15, 110, 0,
			25, 115, 0,
			75, 140, 0
		}
	},
	{ // 3
		{
			0, 70, 0,
			30, 80, 10,
			40, 90, 10,
			60, 120, 5,
			160, 180, 0
		}
	},
	{ // 4
		{
			0, 20, 0,
			45, 30, 15,
			75, 40, 15,
			130, 180, 5,
			220, 220, 0
		}
	},
	{ // 5
		{
			0, 60, 0,
			55, 70, 10,
			70, 80, 10,
			90, 110, 5,
			230, 200, 0
		}
	},
	{ // 6
		{
			0, 90, 0,
			35, 90, 0,
			40, 125, -5,
			50, 105, 0,
			90, 110, 0
		}
	},
	{ // 7
		{
			0, 40, 0,
			30, 55, -10,
			35, 50, -10,
			40, 50, -5,
			60, 70, 0      
		}
	},
	{ // 8
		{
			0, 0, 0,
			10, 0, 0,
			10, 0, 0,
			10, 0, 0,
			10, 0, 0
		}
	}
};

/*
 * Siipien bezier-käyrät.
 */
BezierLine var_wingl[2] =
{
	{
		{ 0, 1, 2 },
		{ 8, 7, 6 }
	},
	{
		{ 2, 3, 4 },
		{ 6, 5, 4 }
	}
};

/*
 * Siipien ajoitus.
 */
int var_wingt[BEZIER_HISTORY] =
{
	0,
	100,
	300,
	500,
	800
};

/*
 * Piirrä siipi.
 */
void efu_wing(int freezetime, float x, float y, float z)
{
	int i;

	rand_seed(0xdeadbeef);
	i = 20;
	do
	{
		glPushMatrix();
		glScalef(x + rand_float_neg(1.0f) / 30.0f,
				y + rand_float_neg(1.0f) / 30.0f, z + rand_float_neg(1.0f) / 30.0f);
		efu_qbezier(var_wingc, var_wingl, var_wingt, 3, freezetime);
		efu_qbezier(var_wingc, var_wingl + 1, var_wingt, 3, freezetime);
		glPopMatrix();
	} while(--i);	
}

/*
 * Siipiefekti.
 */
void efu_wings(int freezetime)
{
	glPushMatrix();
	glRotate3f(0.0f, -20.0f, 0.0f);
	efu_wing(freezetime, 0.4f, 1.9f, 1.0f);
	efu_wing(freezetime, 1.0f, 1.2f, 1.0f);
	efu_wing(freezetime, 1.6f, 0.5f, 1.0f);
	efu_wing(freezetime, -0.4f, 1.9f, 1.0f);
	efu_wing(freezetime, -1.0f, 1.2f, 1.0f);
	efu_wing(freezetime, -1.6f, 0.5f, 1.0f);
	glPopMatrix();
}

//############################################################################
// Valopilari ################################################################
//############################################################################

#define LIGHTPILLAR_CNT		5
#define LIGHTPILLAR_WIDTH	5.0f
#define LIGHTPILLAR_HEIGHT	300.0f
#define LIGHTPILLAR_ROT		0.03
#define LIGHTPILLAR_SHARD_COMP	9
#define LIGHTPILLAR_SHARD_ARC	(M_PI / 1.8f)

// Valopilarien data
LightPillarParams pillar_draw = { 300.0f, 2.0f, 5.0f, 90, 5, 4 };
LightPillarParams pillar_wings = { 400.0f, 16.0f, 100.0f, 300, 2, 5 };

/*
 * Generoi valopilarin shard.
 */
void generate_light_pillar_shard(ShapeDB *shape, LightPillarParams *params)
{
	int i;
	float ang, percent,mul,ca,sa,brightness_mul;
	// Clear the shape
	shapedb_clear(shape);

	// Generoi verteksit
	i = LIGHTPILLAR_SHARD_COMP;
	do
	{
		// Common
		percent = (float)i / (float)LIGHTPILLAR_SHARD_COMP;
		// Arc and height
		ang = ((float)LIGHTPILLAR_SHARD_ARC / 2.0f) - (float)LIGHTPILLAR_SHARD_ARC *
			((float)i / (float)LIGHTPILLAR_SHARD_COMP);
		mul = (float)sin((float)(i + 1) / (float)(LIGHTPILLAR_SHARD_COMP + 2) * M_PI);
		ca = ((float)cos(ang) - 1.0f);
		sa = (float)sin(ang);
		// Color
		brightness_mul = (float)sin(percent * M_PI);

#ifndef FLAG_NOSTDLIB // Tarkistus jos riittää tila
		if(var_colordb_free >= COLORDB_SIZE)
			cond_printf("Out of colors!\n");
#endif

		interpolate_linear_ff(colordb_get_float(var_colordb_free),
				colordb_get_float(0), colordb_get_float(params->col), brightness_mul,
				3);
		colordb_convert_f2u(var_colordb_free);
		// Add
		shapedb_add_cv(shape, ca, 0.0f, sa, var_colordb_free);
		shapedb_add_cv(shape, ca, mul, sa, 0);
		var_colordb_free++;
	} while(i--);

	// Generoi quadit
	i = LIGHTPILLAR_SHARD_COMP - 1;
	do
	{
		shapedb_add_index(shape, i * 2 + 0);
		shapedb_add_index(shape, i * 2 + 1);
		shapedb_add_index(shape, i * 2 + 3);
		shapedb_add_index(shape, i * 2 + 2);
	} while(i--);
}

/*
 * Piirtää yhden valopilarin ennalta annetuilla asetuksilla.
 */
void efu_light_pillar(float *pos, int stime, int etime, int freezetime,
		ShapeDB *shape, LightPillarParams *params)
{
	int i = stime;

	// Perutaanko suoraan?
	if(freezetime > etime + params->lifetime)
		return;

	// Piirretään
	for(i = stime; (i <= freezetime); i += params->delay)
		if((i + params->lifetime >= freezetime) && (i < etime))
		{
			float mul = interpolate_count_lt(freezetime, i, params->lifetime),
						rad = mul * params->radius,
						ang = var_pillar_shard[i],
						dx = (float)cos(ang / 180.0f * M_PI) * rad,
						dz = (float)sin(ang / 180.0f * M_PI) * rad;
			// Piirrä matriisitempuilla
			glPushMatrix();
			glTranslatef(dx + pos[0], pos[1], dz + pos[2]);
			glRotate3f(0.0f, -ang, 0.0f);
			glScalef(params->width, (1.0f - mul) * params->height, params->width);
			shapedb_draw_elements(shape, 0, 0, GL_QUADS);
			glPopMatrix();
		}
}

//############################################################################
// Ympyrät ###################################################################
//############################################################################

#define CIRCLES_RADIALS		13
#define CIRCLES_SECTORS		48
#define CIRCLES_RADIUS		10.0f
#define CIRCLES_HEIGHT_BASE	30.0f
#define CIRCLES_HEIGHT_VAR	20.0f
#define CIRCLES_HEIGHT_SPEED	1.0f
#define CIRCLES_SPEED		20
#define CIRCLES_RUNNER_MAX	26 // Tiukilla, älä muuta!
#define CIRCLES_OFF		0
#define CIRCLES_CCW		1
#define CIRCLES_CW		2
#define CIRCLES_IN		3
#define CIRCLES_OUT		4
#define CIRCLESRUNNER_RCHANGE	2
#define CIRCLESRUNNER_NCHANGE	40
#define CIRCLESRUNNER_DIVIDE	25

/*
 * Variables of circle
 */
Uint8 var_circles[CIRCLES_RADIALS * CIRCLES_SECTORS];
CirclesRunner var_runner[CIRCLES_RUNNER_MAX];

/*
 * Generate one runner to draw the circle.
 */
void circles_create_runner(unsigned radial, unsigned sector, unsigned dir,
		int elapsed)
{
	int i = CIRCLES_RUNNER_MAX;
	CirclesRunner *runner = var_runner;

	do
	{
		if(runner->dir == 0)
		{
			runner->radial = radial;
			runner->sector = sector;
			runner->dir = dir;
			runner->stime = elapsed;
			return;
		}
		runner++;
	} while(--i);

	cond_printf("No room!\n");
}

/*
 * True/false for the direction to be unblocked.
 */
int circles_dir_ok(int idx)
{
	if((idx >= 0) && (idx < CIRCLES_SECTORS * CIRCLES_RADIALS))
		if(var_circles[idx] == 0)
			return 1;
	return 0;
}

/*
 * Calculate the index in the circle array of a given coordinate.
 */
int circles_idx(int radial, int sector)
{
	if(radial < 0)
		return -1;
	else if(radial >= CIRCLES_RADIALS)
		return -1;
	return radial * CIRCLES_SECTORS + modulo(sector, CIRCLES_SECTORS);
}

/*
 * Try to expire a runner after it has stopped drawing.
 */
void circles_expire_runner(CirclesRunner *op, ShapeDB *shp, int left,
		int freezetime)
{
	// If we're not in the end, let's quit
	if(left > CIRCLES_SPEED)
		return;
	// Otherwise try to expire
	efu_light_pillar(
			shapedb_get_vertex(shp, circles_idx(op->radial, op->sector) * 2),
			op->stime, op->etime, freezetime, &shape_pillar_draw, &pillar_draw);
}

/*
 * Draw a runner. Make some polygons while at it.
 */
void circles_runner(CirclesRunner* op, ShapeDB *shp, int left, int elapsed,
		int freezetime)
{
	int dir[4], i, j, curr, next;
	// Jos ei mitään niin ei tehdä
	if(op->dir == 0)
		return;
	// Jos enää pelkkä pilari
	else if(op->dir < 0)
	{
		circles_expire_runner(op, shp, left, freezetime);
		return;    
	}

	/*if(op == var_runner + 0)
		printf("Currently at %i, %i\n", op->radial, op->sector);*/

	// Muutoin voidaan jatkaa
	curr = circles_idx(op->radial, op->sector);
	dir[0] = circles_idx(op->radial, op->sector - 1);
	dir[1] = circles_idx(op->radial, op->sector + 1);
	dir[2] = circles_idx(op->radial - 1, op->sector);
	dir[3] = circles_idx(op->radial + 1, op->sector);

	// Jos kohde ei ole ok, vaihda suuntaa
	if(circles_dir_ok(dir[op->dir - 1]) == 0)
	{
		// Aseta päätös ja ajankohta
		op->dir = -1;
		op->etime = elapsed;
		// Anna uusi mahdollisuus vaihtaa suuntaa 5 kertaa
		i = 6;
		do
		{
			j = rand_int(4);
			if(circles_dir_ok(dir[j]))
			{
				op->dir = j + 1;
				break;
			}
		} while(--i);
	}
	// Jos kaikki vieläkin pielessä
	if(op->dir <= 0)
	{
		circles_expire_runner(op, shp, left, freezetime);
		return;
	}

	// Valitaan ja tehdään neliö
	next = dir[op->dir - 1];
	// Kohde on käytetty
	var_circles[next] = 1;
	// Indeksejä on 2 per paikka
	curr *= 2;
	next *= 2;

	// Insertoi
	shapedb_add_index(shp, curr);
	shapedb_add_index(shp, curr + 1);
	// Haku
	if(left > CIRCLES_SPEED)
	{
		shapedb_add_index(shp, next + 1);
		shapedb_add_index(shp, next);
	}
	// Interpoloi
	else
	{
		float len = (float)left / (float)CIRCLES_SPEED;
		shapedb_interpolate_v(shp, curr + 1, next + 1, len, 7);
		shapedb_interpolate_v(shp, curr, next, len, 6);
		efu_light_pillar(shapedb_get_vertex(shp, shp->ins_vertex - 1),
				op->stime, MAX_EFFECT_TIME, freezetime, &shape_pillar_draw,
				&pillar_draw);
	}

	// Jakaudu
	if(!rand_int(CIRCLESRUNNER_DIVIDE))
		circles_create_runner(op->radial, op->sector, rand_int(4) + 1, elapsed);

	// Jatkamme matkaa
	switch(op->dir)
	{
		case CIRCLES_CCW:
			op->sector -= 2;
		case CIRCLES_CW:
			op->sector++;
			op->sector = modulo(op->sector, CIRCLES_SECTORS);
			break;
		case CIRCLES_IN:
			op->radial -= 2;
		default: // CIRCLES_OUT
			op->radial++;
			break;
	}

	// Vaihda suuntaa
	if((rand_int(CIRCLESRUNNER_NCHANGE) == 0) ||
			((op->dir >= CIRCLES_IN) && (rand_int(2) != 0)))
		op->dir = rand_int(4) + 1;
}

/*
 * Ympyräefun init.
 */
void circles_init()
{
	float ang, rad, sr, cr;
	int i, j;

	shapedb_clear(shape_circles + 0);
	shapedb_clear(shape_circles + 1);

	// Generate the vertices
	for(i = 0; i < CIRCLES_RADIALS; i++)
		for(j = 0; j < CIRCLES_SECTORS; j++)
		{
			// Laske paikat
			ang = (float)j / (float)CIRCLES_SECTORS * M_PI * 2;
			rad = (i + 1) * CIRCLES_RADIUS;
			sr = (float)sin(ang) * rad;
			cr = (float)cos(ang) * rad;
			// Lisää
			shapedb_add_cv(shape_circles + 0, cr, 0.0f, sr, 6);
			shapedb_add_cv(shape_circles + 0, cr, 0.0f, sr, 7);
			shapedb_add_cv(shape_circles + 1, cr, 0.0f, sr, 6);
			shapedb_add_cv(shape_circles + 1, cr, 0.0f, sr, 7);
		}
}

/*
 * Ympyräefun ylihommeli.
 */
void efu_circles(int freezetime)
{
	int i, j, k;
	float height;

	// Tyhjennys ja random
	blend_mode(0);
	camera_frustum(90.0f, 2000.0f);
	glLoadIdentity();
	look_at(lookat_circles, freezetime);
	rand_seed(0x01);

	// Nollaus / palautus
	shape_circles[0].ins_vertex = shape_circles[1].ins_vertex =
		CIRCLES_RADIALS * CIRCLES_SECTORS * 2;
	shape_circles[0].ins_index = shape_circles[1].ins_index = 0;

	// Generate the vertices
	for(i = 0; i < CIRCLES_RADIALS; i++)
		for(j = 0; j < CIRCLES_SECTORS; j++)
		{
			k = (i * CIRCLES_SECTORS + j) * 2 + 1;
			height = interpolate_sine(CIRCLES_HEIGHT_BASE, CIRCLES_HEIGHT_VAR,
					(float)j + (float)freezetime / 100.0f, CIRCLES_HEIGHT_SPEED) +
				interpolate_sine(CIRCLES_HEIGHT_BASE, CIRCLES_HEIGHT_VAR,
						(float)j * 1.5f + (float)freezetime / 15.0f, -CIRCLES_HEIGHT_SPEED);
			// Add
			shape_circles[0].data[k].ver[1] = shape_circles[1].data[k].ver[1] =
				height;
		}

	// Piirretään
	memclr(var_circles, CIRCLES_RADIALS * CIRCLES_SECTORS);
	var_circles[0] = 1;
	memclr(var_runner, CIRCLES_RUNNER_MAX * sizeof(CirclesRunner));
	circles_create_runner(CIRCLES_RADIALS - 1, 0, CIRCLES_CCW, 0);
	for(i = freezetime, j = 0; i > 0; i -= CIRCLES_SPEED, j += CIRCLES_SPEED)
		for(k = 0; k < CIRCLES_RUNNER_MAX; k++)
			circles_runner(&var_runner[k],
					(k % 2) ? (shape_circles + 0) : (shape_circles + 1),
					i, j, freezetime);

	shapedb_draw_elements(shape_circles + 0, 0, 0, GL_QUADS);
	shapedb_draw_elements(shape_circles + 1, 0, 0, GL_QUADS);
}

/*
 * Ympyräefun pilarihommeli.
 */
void efu_pillar(int freezetime)
{
	// colordb:n eka väri on musta (nollaa), se voinee toimia origona!
	efu_light_pillar((float*)var_colordb, 0, PILLAR_DUR, freezetime,
			&shape_pillar_wings, &pillar_wings);
}

/*
 * Ympyräefun teksti.
 */
void efu_oritext(int freezetime)
{
	camera_ortho(1.0f);
	glLoadIdentity();
	text_draw_string(string_origami, -0.9f, 0.3f, 0.3f, 0.3f, 2,
			freezetime * 0.3f);
}

//############################################################################
// Flare #####################################################################
//############################################################################

#define FLARE_ROTSPEED	2.0f

/*
 * Draw a GL flare.
 */
void efu_flare(float *pos, int freezetime, float scale)
{
	float flare_rot;
	int i;
	rand_seed(0xdeadbeef);
	glPushMatrix();
	glTranslatef(pos[0], pos[1], pos[2]);

	flare_rot = FLARE_ROTSPEED * (float)freezetime;
	i = 8;
	do
	{
		glPushMatrix();
		glRotate3f(rand_float(360.0f) + flare_rot * rand_float_neg(1.0f),
				rand_float(360.0f) + flare_rot * rand_float_neg(1.0f),
				rand_float(360.0f) + flare_rot * rand_float_neg(1.0f));
		glScalef(scale, scale, scale);
		shapedb_draw_elements(&shape_flare, 0, 0, GL_TRIANGLES);
		glPopMatrix();
	} while(--i);
	glPopMatrix();
}

//############################################################################
// LineTextures ##############################################################
//############################################################################

#define LINETEXTURE_H		512
#define LINETEXTURE_W		32
#define LINETEXTURE_LINES	8
#define LINETEXTURE_CHANGE	20
#define LINECIRCLE_COMPLEXITY	32
#define LINECIRCLE_THICKNESS	0.025f

/*
 * Linetexture variables.
 */
int tex_line1_bind, tex_line2_bind, tex_line3_bind;

/*
 * Generate the texture.
 */
void tex_line_generate(int *bind, int col_op)
{
	Uint32 *bmp;
	Uint32 col = colordb_get_uint(col_op);
	int i, j, cw, h, ncw;

	// Tyhjennä tekstuuri alta
	texture_clear();

	for(i = 0; i < LINETEXTURE_LINES; i++)
	{
		cw = rand_int(LINETEXTURE_W - 2 + 1);
		h = LINETEXTURE_H;
		bmp = texture_playground;
		for(h = 0; h < LINETEXTURE_H; h++)
		{
			// Vaihdetaanko kolumnia?
			if(!rand_int(LINETEXTURE_CHANGE))
			{
				ncw = rand_int(LINETEXTURE_W - 2) + 1;
				j = ((ncw - cw) > 0) ? 1 : -1;
				for(; cw != ncw; cw += j)
					bmp[cw] = col;
				cw = ncw;
			}
			// Kolumniin väri
			bmp[cw] = col;
			// Eteenpäin
			bmp += LINETEXTURE_W;
		}
	}

	// Luo tekstuuri
	texture_create(bind, LINETEXTURE_W, LINETEXTURE_H);
}

//############################################################################
// RuutuTextures #############################################################
//############################################################################

#define CITY_RUUTUTEX_W		128
#define CITY_RUUTUTEX_H		128
#define CITY_RUUTUTEX_BORDER	24
#define CITY_RUUTUTEX_FILL	0

int tex_ruutu_bind_1, tex_ruutu_bind_2, tex_crane_bind, tex_clean_bind;
/*
 * Generoi ruudunmuotoinen tekstuuri.
 */
void tex_ruutu_generate(int *bind, int div, int halk)
{
	int i, j;
	Uint32 *bmp = texture_playground;

	for(i = 0; i < CITY_RUUTUTEX_H / div; i++)
		for(j = 0; j < CITY_RUUTUTEX_W / div; j++, bmp++)
		{
			if(((i == 0) || (j == 0) || (i == CITY_RUUTUTEX_H / div - 1) ||
						(j == CITY_RUUTUTEX_W / div - 1)) ||
					(halk && ((abs(j - i) <= 1) ||
										(abs(CITY_RUUTUTEX_W / div - j - i) <= 1))))
				*bmp = colordb_get_uint(CITY_RUUTUTEX_BORDER);
			else
			{
				*bmp = colordb_get_uint(CITY_RUUTUTEX_FILL);
#if SDL_BYTEORDER == SDL_LIL_ENDIAN
				*bmp |= rand_int(50) << 24;
#else
				*bmp |= rand_int(50);
#endif
			}
		}

	// Generoi tekstuuri
	texture_create(bind, CITY_RUUTUTEX_W / div, CITY_RUUTUTEX_H / div);
}

//############################################################################
// GitS -efu #################################################################
//############################################################################

#define GITS_BOUND_X		15000.0f
#define GITS_BOUND_YZ		1500.0f
#define GITS_GRIDSPACE		130
#define GITS_TEXWRAP		1000.0f
#define GITS_GRIDCNT_X		((int)(GITS_TEXWRAP / (float)GITS_GRIDSPACE))
#define GITS_GRIDCNT_YZ		((int)(GITS_BOUND_YZ / (float)GITS_GRIDSPACE))
#define GITS_GRIDLINE_W		5.0f
#define GITS_FOGDENSITY		0.0005f
#define GITS_SPHERES		40
#define GITS_PATH_RAND		500.0f
#define GITS_PATH_BASE		100.0f
#define GITS_PATH_MAX		(GITS_PATH_RAND + GITS_PATH_BASE)
#define GITS_PATH_NEAR		1039.23f // sqrt(((PATH_MAX ^ 2) * 3)
#define GITS_PATH_LINES		7
#define GITS_SPHERERAD		125.0f
#define GITS_BACKCLIP		5000.0f
#define GITS_HAERPAKE_COUNT	12
#define GITS_HAERPAKE_SCALEINC	(1.0f / (float)GITS_HAERPAKE_COUNT)


// Taulukko sphereille
GitsSphere var_gits_spheres[GITS_SPHERES];
PathDB var_gits_paths[GITS_SPHERES * GITS_LINKSPER];
int var_gits_pathcount;

/*
 * Generate line with a line texture from point a to point b.
 */
float efu_line_line(ShapeDB *shp, float start, float end, float other1,
		float other2, float radius, float texpos, float texwrap, int axis)
{
	float pos[3], ang, ca, sa,texend;
	int ax1, ax2, idx;

	ang = rand_float(M_PI * 2.0f);
	ca = (float)cos(ang) * radius;
	sa = (float)sin(ang) * radius;
	texend = (float)fabs(end - start) / texwrap + texpos;
	ax1 = (axis + 1) % 3;
	ax2 = (axis + 2) % 3;
	idx = shp->ins_vertex;

	// Indeksit
	shapedb_add_index(shp, idx);
	shapedb_add_index(shp, idx + 1);
	shapedb_add_index(shp, idx + 2);
	shapedb_add_index(shp, idx + 3);
	// Data
	pos[axis] = start;
	pos[ax1] = other1 + ca;
	pos[ax2] = other2 + sa;
	shapedb_add_tv(shp, pos[0], pos[1], pos[2], 0.0f, texpos);
	pos[ax1] = other1 - ca;
	pos[ax2] = other2 - sa;
	shapedb_add_tv(shp, pos[0], pos[1], pos[2], 1.0f, texpos);
	pos[axis] = end;
	shapedb_add_tv(shp, pos[0], pos[1], pos[2], 1.0f, texend);
	pos[ax1] = other1 + ca;
	pos[ax2] = other2 + sa;
	shapedb_add_tv(shp, pos[0], pos[1], pos[2], 0.0f, texend);

	return (float)fmod(texend, 1.0);
}

/*
 * Draw line circle
 */
void efu_line_circle(float *pos, int texture, float radius, float xr,
		float yr, float zr)
{
	glPushMatrix();
	glTranslatef(pos[0], pos[1], pos[2]);
	glRotate3f(xr, yr, zr);
	glScalef(radius, radius * 10.0f, radius);
	shapedb_draw_elements(&shape_line_circle, texture, GL_REPLACE,
			GL_TRIANGLE_STRIP);
	glPopMatrix();
}

/*
 * Varmistaa ettei jossakin spheressä ole yhteyttä johonkin toiseen.
 */
int sphere_has_no_conn(GitsSphere *op, int conn)
{
	int i;
	for(i = 0; i < GITS_LINKSPER; i++)
		if(op->connections[i] == conn)
			return 0;
	return 1;
}

/*
 * Tämä on mielenkiintoinen tapaus. Havaitsin jossakin vaiheessa, että
 * riippuen otimointitasosta, GitS-efun polut olivat mitä sattuivat olemaan.
 * Tällainen epäkohta piti korjata, ja kävin tutkailemaan tilannetta printf:n
 * avulla. Ikävä kyllä en kyennyt löytämään eroja edes ppc32- ja ia32-
 * toteutusten välillä kunnes valkeni.
 * Nimittäin, bugi johtui ia32-suoritinten kehittyneempien versioitten SIMD-
 * käskyistä, joitten avulla yksinkertaiset matematiikkaoperaatiot
 * optimoitiin. Käyttäessäni printf:ää koodin tutkimiseen ks. operaatioita ei
 * kannattanut tehdä, jolloin toimitukset laskettiin yksinkertaisesti.
 * Täten tein tällaisen pienen funktion, jonka tarkoitus on (kuten printf:n)
 * hieman sekoittaa kääntäjää ja saada tämä unohtamaan vektorioperaatioitten
 * käyttö.
 * Anteeksi pälliratkaisu, mutta tässä vaiheessa ei enää oikein kiinnosta.
 * Kompoversiossa (käännetty GCC 3.3:lla) pelkkä typecastaus riitti
 * unhoittamaaan ongelman, mutta GCC 4 näki jotenkin sen läpi, ja minun piti
 * tapella koko paska uusiksi. Oikeastihan koko generointialgoritmi on täysin
 * perseestä ja kaikki tällainen olisi pitänyt tehdä jonkinlaisella
 * kokonaislukutasolla. Huoh.
 */
void simd_bug_preventer(float op1, float op2)
{
	static long double simd_bug_counter = 0.0;
	simd_bug_counter += op1;
	simd_bug_counter += op2;
	simd_bug_counter = sqrt(fabs(simd_bug_counter) + fabs(op1) + fabs(op2));
}

/*
 * Generoi polku kahden pisteen välille.
 */
void generate_gits_path(GitsSphere *src, GitsSphere *dst, PathDB *pth)
{
	float diff, diff2 = 0.0f, pos[3];
	int ax1, ax2, i, crd;

	path_clear(pth);
	pos[0] = src->pos[0] + rand_float(GITS_SPHERERAD / 2.0f);
	pos[1] = src->pos[1] + rand_float(GITS_SPHERERAD / 2.0f);
	pos[2] = src->pos[2] + rand_float(GITS_SPHERERAD / 2.0f);
	path_add_v(pth, pos[0], pos[1], pos[2]);

	// Loop forever
	while(1)
	{
		crd = rand_int(3);
		diff = dst->pos[crd] - pos[crd];

		if(diff != 0.0f)
		{
			simd_bug_preventer(diff, diff2);
			//diff = dst->pos[crd] - pos[crd];
			// Jos ollaan liian kaukana niin mennään randomilla
			if(vecdist(pos, dst->pos) > GITS_PATH_NEAR)
			{
				simd_bug_preventer(diff, diff2);
				diff2 = rand_float(GITS_PATH_RAND) + GITS_PATH_BASE;
				if(diff < 0.0f)
				{
					simd_bug_preventer(diff, diff2);
					diff = diff2 * -1.0f;
				}
				else
					diff = diff2;
			}

			// Mennään eteenpäin
			ax1 = (crd + 1) % 3;
			ax2 = (crd + 2) % 3;
			pos[crd] += diff;
			path_add_v(pth, pos[0], pos[1], pos[2]);

			// Lisää useampi linja, saadaan paksuutta!
			i = GITS_PATH_LINES;
			do
			{
				efu_line_line(&shape_gits_paths, pos[crd] - diff, pos[crd],
						pos[ax1] + rand_float_neg(GITS_GRIDLINE_W * 2.0f),
						pos[ax2] + rand_float_neg(GITS_GRIDLINE_W * 2.0f),
						GITS_GRIDLINE_W, 0.0f, GITS_TEXWRAP, crd);
			} while(--i);

			// Jos saavuttu niin end!
			if(vecdist(dst->pos, pos) < GITS_SPHERERAD / 2.0f)
				break;
		}
	}
}

/*
 * Generoi kaikki gits-efussa tarvittava tauhka.
 */
void generate_gits()
{
	int i, j, k, closestidx;
	float newdist, xpos, yzpos, yzpos2, boundmin, boundmax, closest, percent,
				ang, ca, sa;
	GitsSphere *sph, *tgt;

	// Ensin linjaympyrä
	i = LINECIRCLE_COMPLEXITY;
	do
	{
		percent = (float)i / (float)LINECIRCLE_COMPLEXITY;
		ang = percent * M_PI * 2;
		ca = (float)cos(ang);
		sa = (float)sin(ang);
		shapedb_add_tv(&shape_line_circle, ca, -LINECIRCLE_THICKNESS, sa,
				0.0f, percent);
		shapedb_add_tv(&shape_line_circle, ca, LINECIRCLE_THICKNESS, sa,
				1.0f, percent);
		shapedb_add_index(&shape_line_circle, i * 2);
		shapedb_add_index(&shape_line_circle, i * 2 + 1);
	} while(i--);

	// Yhteyksien data
	rand_seed(0x1FEB197E);

	// Arvo paikat
	i = GITS_SPHERES - 1;
	do
	{
		GitsSphere *sph = var_gits_spheres + i;
		sph->pos[0] = rand_float(GITS_BOUND_X);
		sph->pos[1] = rand_float(GITS_BOUND_YZ);
		sph->pos[2] = rand_float(GITS_BOUND_YZ);
		sph->conncnt = rand_int(GITS_LINKSPER) + 1;
		// Nollaa linkit
		j = GITS_LINKSPER - 1;
		do
		{
			sph->connections[j] = -1;
		} while(j--);
	} while(i--);

	// Grid
	shapedb_clear(&shape_gits_grid);
	i = GITS_GRIDCNT_X;
	do
	{
		xpos = (float)i / (float)GITS_GRIDCNT_X * GITS_TEXWRAP;
		j = GITS_GRIDCNT_YZ;
		do
		{
			yzpos = (float)j / (float)GITS_GRIDCNT_YZ * GITS_BOUND_YZ;
			boundmin = -1000.0f;
			boundmax = GITS_BOUND_YZ + 1000.0f;
			// Vaihdetaan randomilla
			if(rand_int(2))
				xchgf(&boundmin, &boundmax);
			efu_line_line(&shape_gits_grid, boundmin, boundmax, yzpos, xpos,
					GITS_GRIDLINE_W, rand_float(1.0f), GITS_TEXWRAP, 1);
			if(rand_int(2))
				xchgf(&boundmin, &boundmax);
			efu_line_line(&shape_gits_grid, boundmin, boundmax, xpos, yzpos,
					GITS_GRIDLINE_W, rand_float(1.0f), GITS_TEXWRAP, 2);
			// Viimeisellä kierroksella piirretään myös loput viivat
			if(i == GITS_GRIDCNT_X)
			{
				k = GITS_GRIDCNT_YZ;
				do
				{
					yzpos2 = (float)k / (float)GITS_GRIDCNT_YZ * GITS_BOUND_YZ;
					boundmin = 0.0f;
					boundmax = GITS_TEXWRAP;
					if(rand_int(2))
						xchgf(&boundmin, &boundmax);
					efu_line_line(&shape_gits_grid, boundmin, boundmax, yzpos, yzpos2,
							GITS_GRIDLINE_W, rand_float(1.0f), GITS_TEXWRAP, 0);
				} while(k--);
			}
		} while(j--);
	} while(--i);

	// Merkkaa yhteydet
	for(i = 0; i < GITS_SPHERES; i++)
	{
		sph = var_gits_spheres + i;
		//printf("%i has connections: %i\n", i, sph->conncnt);
		// Hae sovittu määrä lähimpiä
		while(sph->conncnt > 0)
		{
			closest = (float)sqrt(10000000.0f);
			closestidx = -1;
			for(j = i + 1; j < GITS_SPHERES; j++)
			{
				tgt = var_gits_spheres + j;
				newdist = vecdist(tgt->pos, sph->pos);
				if((newdist < closest) && (sphere_has_no_conn(sph, j)))
				{
					closestidx = j;
					closest = newdist;
				}
			}
			tgt = var_gits_spheres + closestidx;
			// Jos ei löydy niin quit
			if(closestidx < 0)
				break;
			// Jos kohteessa ei tilaa niin quit
			if(tgt->conncnt <= 0)
				break;
			// Muutoin kaikki ok
			sph->connections[--(sph->conncnt)] = closestidx;
			tgt->conncnt--;
			//printf("Found connection: %i\n", closestidx);
		}
	}

	// Generoi linkit, erikseen koska tämä voisi olla cool jos se tehtäisiin
	// joka frame!
	shapedb_clear(&shape_gits_paths);
	var_gits_pathcount = 0;
	i = GITS_SPHERES - 1;
	do
	{
		sph = var_gits_spheres + i;
		j = GITS_LINKSPER - 1;
		do
		{
			k = sph->connections[j];
			if(k >= 0)
			{
				tgt = var_gits_spheres + k;
				generate_gits_path(sph, tgt, var_gits_paths + var_gits_pathcount);
				var_gits_pathcount++;
			}
		} while(j--);
	} while(i--);

	//exit(1); // depuk
}

/*
 * Piirrä liikkuva härpäke polulle.
 */
void efu_gits_path_haerpake(PathDB *pth, int starttime, int currtime,
		float speed)
{
	float curr[3],
				scale = GITS_HAERPAKE_SCALEINC * GITS_HAERPAKE_COUNT;
	int i;

	// Piirretään härpäkkeet
	for(i = 0; (i < GITS_HAERPAKE_COUNT); i++)
	{
		if(!path_get_pos_linear(pth, curr, speed, currtime - starttime - i))
			return;
		efu_flare(curr, currtime, scale);
		scale -= GITS_HAERPAKE_SCALEINC;
	}
}

/*
 * Piirrä itse gits-efu.
 */
void efu_gits(int freezetime)
{
	int i;
	float gridcrd;

	// Tyhjennys ja random
	blend_mode(0);
	screen_clear(1);
	camera_frustum(90.0f, GITS_BACKCLIP);
	glLoadIdentity();
	look_at(lookat_gits, freezetime);
	rand_seed(0xdeadbeef);

	// Hyper draiv
	if((freezetime >= 50) && (freezetime <= 180))
		camera_frustum((float)(130 - (freezetime - 50)) / 130.0f * 80.0f + 90.0f,
				GITS_BACKCLIP);

	// This effect has fog
	glFogfv(GL_FOG_COLOR, colordb_get_float(0));
	glFogi(GL_FOG_MODE, GL_EXP2);
	glFogf(GL_FOG_DENSITY, GITS_FOGDENSITY);
	glEnable(GL_FOG);

	// Randomize a few circles
	glMatrixMode(GL_TEXTURE);
	glPushMatrix();
	glTranslatef(0.0f, 0.001f * freezetime, 0.0f);
	glMatrixMode(GL_MODELVIEW);

	i = GITS_SPHERES - 1;
	do
	{
		GitsSphere *sph = var_gits_spheres + i;
		int j = 10;
		do
		{
			efu_line_circle(sph->pos, tex_line1_bind,
					GITS_SPHERERAD + rand_float_neg(25.0f), rand_float(360.0f),
					rand_float(360.0f), rand_float(360.0f));
		} while(--j);
	} while(i--);

	// Texture matrix again
	glMatrixMode(GL_TEXTURE);
	glTranslatef(0.0f, - 0.0005f * freezetime, 0.0f);

	// Grid and paths
	glMatrixMode(GL_MODELVIEW);
	gridcrd = -GITS_BOUND_X;
	do
	{
		if(fabs(gridcrd - camera_position[0]) < GITS_BACKCLIP)
		{
			glPushMatrix();
			glTranslatef(gridcrd, 0.0f, 0.0f);
			shapedb_draw_elements(&shape_gits_grid, tex_line2_bind, GL_REPLACE,
					GL_QUADS);
			glPopMatrix();
		}
		gridcrd += GITS_TEXWRAP;
	} while(gridcrd < 2.0f * GITS_BOUND_X);

	// Paths
	shapedb_draw_elements(&shape_gits_paths, tex_line3_bind, GL_REPLACE,
			GL_QUADS);

	// Return to normal matrix mode
	glMatrixMode(GL_TEXTURE);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

	// Piirrä kaikki härpäkkeet
	for(i = 0; i < freezetime; i+= 10)
		efu_gits_path_haerpake(var_gits_paths + var_gits_path_start[i], i,
				freezetime, 5.0f);
}

#define GITSTEXT_APPEAR		50
#define GITSTEXT_DURATION	400
#define GITSTEXT_SPEED		0.55f
#define GITSTEXT_SCALE		0.1f
#define GITSTEXT_HEIGHT		0.14f
#define GITSTEXT_RANGE		0.65f

/*
 * Näyttää textoutit GitS-efussa.
 */
void efu_gits_text(char *str, float size, int freezetime)
{
	float y1 = rand_float(GITSTEXT_RANGE * 2.0f - GITSTEXT_HEIGHT) -
		GITSTEXT_RANGE;
	// Vaihto jos tarpeen
	if(rand_int(2))
		size = -size;
	// Paikka
	textout_complex(str, freezetime, GITSTEXT_DURATION, GITSTEXT_APPEAR,
			GITSTEXT_SPEED, size, y1, y1 + GITSTEXT_HEIGHT, GITSTEXT_SCALE, 3);
}

/*
 * Yksittäiset textoutit.
 */
void gits_text_gfxcode(int freezetime)
{
	rand_seed(2);
	efu_gits_text(string_gfxcode, 1.21f, freezetime);
}
void gits_text_trilkk(int freezetime)
{
	rand_seed(3);
	efu_gits_text(string_trilkk, 0.51f, freezetime);
}
void gits_text_muscode(int freezetime)
{
	rand_seed(4);
	efu_gits_text(string_muscode, 0.93f, freezetime);
}
void gits_text_juippi(int freezetime)
{
	rand_seed(5);
	efu_gits_text(string_juippi, 0.49f, freezetime);
}
void gits_text_other(int freezetime)
{
	rand_seed(6);
	efu_gits_text(string_other, 0.97f, freezetime);
}
void gits_text_warma(int freezetime)
{
	rand_seed(7);
	efu_gits_text(string_warma, 0.52f, freezetime);
}
void gits_text_greets(int freezetime)
{
	rand_seed(8);
	efu_gits_text(string_greets, 0.58f, freezetime);
}
void gits_text_anakin(int freezetime)
{
	rand_seed(9);
	efu_gits_text(string_anakin, 0.55f, freezetime);
}
void gits_text_blamstrain(int freezetime)
{
	rand_seed(10);
	efu_gits_text(string_blamstrain, 0.91f, freezetime);
}
void gits_text_ninave(int freezetime)
{
	rand_seed(11);
	efu_gits_text(string_ninave, 0.56f, freezetime);
}
void gits_text_rmm(int freezetime)
{
	rand_seed(12);
	efu_gits_text(string_rmm, 0.32f, freezetime);
}
void gits_text_sihteeri(int freezetime)
{
	rand_seed(13);
	efu_gits_text(string_sihteeri, 0.69f, freezetime);
}
void gits_text_smak(int freezetime)
{
	rand_seed(15);
	efu_gits_text(string_smak, 0.4f, freezetime);
}
void gits_text_theflash(int freezetime)
{
	rand_seed(16);
	efu_gits_text(string_theflash, 0.73f, freezetime);
}
void gits_text_tuokku(int freezetime)
{
	rand_seed(17);
	efu_gits_text(string_tuokku, 0.54f, freezetime);
}
void gits_text_valquis(int freezetime)
{
	rand_seed(19);
	efu_gits_text(string_valquis, 0.63f, freezetime);
}
void gits_text_vv(int freezetime)
{
	rand_seed(20);
	efu_gits_text(string_vv, 0.23f, freezetime);
}
void gits_text_thanks(int freezetime)
{
	rand_seed(26);
	efu_gits_text(string_thanks, 0.86f, freezetime);
}
void gits_text_watching(int freezetime)
{
	rand_seed(27);
	efu_gits_text(string_watching, 1.14f, freezetime);
}
void gits_text_origami(int freezetime)
{
	rand_seed(29);
	efu_gits_text(string_origami, 0.64f, freezetime);
}
void gits_text_intro(int freezetime)
{
	rand_seed(28);
	efu_gits_text(string_intro, 1.60f, freezetime);
}


//############################################################################
// Epäjärjestetty tausta #####################################################
//############################################################################

#define FOLDBACK_DURATION	120
#define FOLDBACK_WIDTH		0.4f

void efu_fold_background(int freezetime)
{
	int i, j;
	float pos, w;

	blend_mode(0);
	camera_ortho(1.0f);
	glLoadIdentity();

	for(i = freezetime - FOLDBACK_DURATION; i <= freezetime; i++)
		if((i >= 0) && (i % 5 == 0))
		{
			w = (float)sin((float)(freezetime - i) / (float)(FOLDBACK_DURATION) * M_PI) * FOLDBACK_WIDTH;
			// Shape tyhjäksi
			shapedb_clear(&shape_use);
			// Pieni huomio, käytämme tässä var_pillar_shardia koska se on aivan sama
			pos = var_pillar_shard[i];
			if(pos < 180.0f)
			{
				pos = pos / 90.0f - 1.0f;
				shapedb_add_cv(&shape_use, pos - w, -1.0f, 0.0f, 33);
				shapedb_add_cv(&shape_use, pos - w, 1.0f, 0.0f, 33);
				shapedb_add_cv(&shape_use, pos, -1.0f, 0.0f, 32);
				shapedb_add_cv(&shape_use, pos, 1.0f, 0.0f, 32);
				shapedb_add_cv(&shape_use, pos + w, -1.0f, 0.0f, 33);
				shapedb_add_cv(&shape_use, pos + w, 1.0f, 0.0f, 33);
			}
			else
			{
				pos = pos / 90.0f - 3.0f;
				shapedb_add_cv(&shape_use, -1.0f, pos - w, 0.0f, 33);
				shapedb_add_cv(&shape_use, 1.0f, pos - w, 0.0f, 33);
				shapedb_add_cv(&shape_use, -1.0f, pos, 0.0f, 32);
				shapedb_add_cv(&shape_use, 1.0f, pos, 0.0f, 32);
				shapedb_add_cv(&shape_use, -1.0f, pos + w, 0.0f, 33);
				shapedb_add_cv(&shape_use, 1.0f, pos + w, 0.0f, 33);
			}
			// Indeksit
			for(j = 0; j < 6; j++)
				shapedb_add_index(&shape_use, j);
			// Piirrä
			shapedb_draw_elements(&shape_use, 0, 0, GL_QUAD_STRIP);
		}
}

//############################################################################
// Fold ######################################################################
//############################################################################

/*
 * Sitten apufunktiot
 */

void fold_find_intersection(float *dst, float *line, float *r, float *a)
{
	float projection[3];
	float ratio;
	// projektio vektorista ja ynnätään alkupisteeseen, standarditouhua
	vecsub(projection, r, a);
	ratio = (line[0] * projection[0] + line[1] * projection[1] +
			line[2] * projection[2]) / veclen_sqr(line);
	dst[0] = a[0] + line[0] * ratio;
	dst[1] = a[1] + line[1] * ratio;
	dst[2] = a[2] + line[2] * ratio;
}

void fold_operate(float *dst, float *source, float *end, float *folded,
		float degrees)
{
	float intersection[3],radius[3],crossproduct[3],crossproduct_unit[3],foldline[3];
	float angle, radius_len;

	vecsub(foldline, end, source);
	fold_find_intersection(intersection, foldline, folded, source);
	vecsub(radius, folded, intersection);
	radius_len = veclen(radius);
	veccross(crossproduct, foldline, radius);
	vecunit(crossproduct_unit, crossproduct);
	angle = (float)(degrees / 180.0) * (float)M_PI;
	dst[0] = intersection[0] + radius[0] * (float)cos(angle) +
		crossproduct_unit[0] * (float)sin(angle) * radius_len;
	dst[1] = intersection[1] + radius[1] * (float)cos(angle) +
		crossproduct_unit[1] * (float)sin(angle) * radius_len;
	dst[2] = intersection[2] + radius[2] * (float)cos(angle) +
		crossproduct_unit[2] * (float)sin(angle) * radius_len;
}

void fold_generate_model(ShapeDB *shape, float *verts, int vertnum,
		Uint8 *polys, int indexnum)
{
	int i;
	for(i=0; i<vertnum; i++) {
		shapedb_add_cv(shape, verts[i*4 + 0], verts[i*4 + 1], verts[i*4 + 2], (int)verts[i*4 + 3]);
		//printf("\nAdded vertex %f, %f, %f, color %i.", verts[i*4 + 0], verts[i*4 + 1], verts[i*4 + 2], (int)verts[i*4 + 3]);
	}
	for(i=0; i<indexnum; i++) {
		shapedb_add_index(shape, polys[i]);
	}
}

void fold_generate_models()
{
	int i;

	for(i = 0; i < 4; i++)
	{
		shapedb_clear(shape_simpleplane + i);
		shapedb_clear(shape_swan + i);
		shapedb_clear(shape_crow + i);
	}

	fold_generate_model(&shape_simpleplane[0], form_simpleplane_tcv,
			FORM_SIMPLEPLANE_VERTS, form_simpleplane_ref, FORM_SIMPLEPLANE_INDEXES);
	fold_generate_model(&shape_swan[0], form_swan_tcv, FORM_SWAN_VERTS,
			form_swan_ref, FORM_SWAN_INDEXES);
	fold_generate_model(&shape_crow[0], form_crow_tcv, FORM_SWAN_VERTS,
			form_crow_ref, FORM_CROW_INDEXES);

	for(i = 1; i <= 2; i++)
	{
		shapedb_copy(shape_simpleplane + i, shape_simpleplane + 0);
		shapedb_copy(shape_swan + i, shape_swan + 0);
		shapedb_copy(shape_crow + i, shape_crow + 0);
	}

	//printf("\nGeneration ready.");
}

void fold_fold(ShapeDB *dest, ShapeDB *src, int linebeg, int lineend,
		int vertex, float amount)
{
	float newpos[3];

	fold_operate(newpos, shapedb_get_vertex(src, linebeg), shapedb_get_vertex(src, lineend), shapedb_get_vertex(src, vertex), amount);

	shapedb_replace_vertex(dest, vertex, newpos);
	//printf("\nVertex %i folded over %i to %i by amount %f", vertex, linebeg, lineend, amount);
}

/*
 * Taittoefun taittofunktiot
 */
void fold_guide_interpreter(ShapeDB *dst, ShapeDB *src, Sint16 *foldguide,
		float amount)
{
	int i, j;

	for(i = 0; i < foldguide[0]; i++)
	{
		j = i * 4;
		fold_fold(dst, src, foldguide[j + 2], foldguide[j + 3], foldguide[j + 4],
				amount * (float)foldguide[j + 5] * 0.1f);
	}
	if(amount >= 1.0f)
		shapedb_copy(src,dst);
}

void fold_master(ShapeDB *shp, Sint16 *guide, int freezetime)
{
	int i, j, k, l;
	float pos;

	shapedb_copy(shp + 1, shp + 0);
	shapedb_copy(shp + 2, shp + 0);

	for(i = 0, j = 0, k = 1; (i < freezetime) && (j < guide[0]);)
	{
		// Paikka
		l = guide[k + 1];
		pos = 1.0f;
		if(i + l > freezetime)
			pos = interpolate_count_se(freezetime, i, i + l);
		// Taittele
		fold_guide_interpreter(shp + 2, shp + 1, guide + k, pos);
		// Etene
		i += l;
		k += 2 + guide[k] * 4;
		j++;
	}

	shapedb_draw_wire(shp + 2, 0, 0, GL_QUADS);
}

/*
 * Taittoefun init.
 */
void fold_init() {
	// Generate models
	fold_generate_models();
	//shapedb_print(&shape_simpleplane[0]);
	//shapedb_print(&shape_simpleplane[1]);
	//shapedb_print(&shape_simpleplane[2]);
}

/*
 * Taittoefun ylihommeli.
 */
void efu_fold(int freezetime, ShapeDB *shp, Sint16 *guide, int flip, float my,
		float mz)
{
	// Muuta
	camera_frustum(90.0f, 2000.0f);
	glLoadIdentity();
	look_at(lookat_fold, freezetime);
	blend_mode(2);
	glDisable(GL_CULL_FACE);

	// Initialize random seed
	//rand_seed(freezetime);

	glTranslatef(0.0f, my, mz);
	// Kontrolli
	if(flip)
		glScalef(1.0f, -1.0f, -1.0f);
	fold_master(shp, guide, freezetime);
}

/*
 * Taittoefun abstraktiot.
 */
void efu_fold_plane(int freezetime)
{
	efu_fold(freezetime, shape_simpleplane, fold_guide_simpleplane, 0, 0.0f,
			-0.5f);
}
void efu_fold_crane(int freezetime)
{
	efu_fold(freezetime, shape_swan, fold_guide_swan, 1, 0.4f, 0.0f);
}
void efu_fold_crow(int freezetime)
{
	efu_fold(freezetime, shape_crow, fold_guide_crow, 0, 0.0f, 0.0f);
}

//############################################################################
// Perinteinen fraktaali #####################################################
//############################################################################

#define FLARE_W 100
#define FLARE_H 100
#define JULIA 0
#define VOLTERRO 1

/*
 * Julia sets
 */
float julia_sets[] =
{
	-0.03750f, 0.67500f,
	-0.05000f, 0.67500f,
	-0.01250f, 0.72500f,
	0.02500f, 0.75625f,
	-0.07500f, 0.8375f,
	-0.43750f, 0.98125f,
	-0.25000f, 0.81875f,
	-0.23750f, 0.74375f,
	-0.21250f, 0.68740f,
	-0.71875f, 0.33125f,
	-0.71250f, 0.41875f,
	-0.78750f, 0.20625f,
	-0.77500f, 0.13125f,
	-0.91250f, 0.28125f,
	-1.07500f, 0.29375f,
	-1.25625f, 0.36250f,
	-1.25000f, 0.13125f,
	-1.26875f, 0.08750f,
	-1.30000f, -0.13750f,
	-1.18125f, -0.23750f,
	-0.96875f, -0.30625f,
	-0.80625f, -0.20625f,
	-0.78750f, -0.23750f,
	-0.63750f, -0.51250f,
	-0.35000f, -0.70625f,
	-0.26250f, -0.76250f,
	-0.05625f, -0.91875f,
	0.13125f, -0.75000f,
	0.23125f, -0.62500f,
	0.33125f, -0.60000f,
	0.43125f, -0.32500f,
	0.45625f, -0.22500f,
	0.46875f, -0.19375f,
	0.36875f, -0.04375f,
	0.34375f, -0.00625f,
	0.39375f, 0.11875f,
	0.45625f, 0.20625f,
	0.40000f, 0.54375f,
	0.38750f, -0.38750f,
	0.38125f, 0.44375f,
	0.18125f, 0.69375f,
	0.14275f, 0.65000f,
	0.06875f, 0.66250f,
	0.42500f, -0.20000f,
	-0.05000f, 0.67500f,
	-1.16875f, -0.22500f,
	0.09000f, 0.61700f
};

/*
 * Volterro sets
 */
float volterro_sets[] =
{
	0.8f, 0.78f,	
	0.8f, 0.76f,
	0.8f, 0.74f,
	0.8f, 0.72f,
	0.8f, 0.70f,
	0.8f, 0.68f,
	0.8f, 0.66f,
	0.8f, 0.64f,
	0.8f, 0.62f,
	0.8f, 0.60f,
	0.8f, 0.58f,
	0.8f, 0.56f,
	0.8f, 0.54f,
	0.8f, 0.52f,
	0.8f, 0.50f,
	0.8f, 0.48f,
	0.8f, 0.46f,
	0.8f, 0.44f,
	0.8f, 0.42f,
	0.8f, 0.40f,
	0.8f, 0.38f,
	0.8f, 0.36f,
	0.8f, 0.34f,
	0.8f, 0.32f,
	0.8f, 0.30f,
	0.8f, 0.28f,
	0.8f, 0.26f,
	0.8f, 0.24f,
	0.8f, 0.22f,
	0.8f, 0.20f,
	0.8f, 0.18f,
	0.8f, 0.16f,
	0.8f, 0.14f,
	0.8f, 0.12f,
	0.8f, 0.10f,
	0.8f, 0.08f,
	0.8f, 0.06f,
	0.8f, 0.04f,
	0.8f, 0.02f,
	0.8f, 0.00f
};

typedef struct {
	float n, i;
} complex;

float comp_abs(complex *comp)
{
	return (float)sqrt(comp->n * comp->n + comp->i * comp->i);
}

/*
 * Kaikki fraktaalikoodi on lopulta inlinetetty...
 */
Uint32 iterate(complex Z, int type, int set_index) {
	int i, iterations;
	complex c;
	float x, y, f, g, x2, y2, h, p, bailout;
	float resultf;
	Uint32 resulti;
	//rand_seed(set_index);

	// JULIA
	if(type == JULIA)
	{
		c.n = julia_sets[set_index*2]; //(double)rand_float_neg((float)0.6);
		c.i = julia_sets[set_index*2+1]; //(double)rand_float_neg((float)0.6);
		iterations = 256;
		bailout = 4.0f;
		for(i = 0; (i < iterations) && (comp_abs(&Z) < bailout); i++)
		{
			x = Z.n * Z.n - Z.i * Z.i;
			y = Z.n * Z.i * 2.0f;
			Z.n = x + c.n;
			Z.i = y + c.i;
		}
		resultf = (float)sqrt(sqrt(((float)i + comp_abs(&Z) / bailout) /
					iterations));
		if(resultf > 1.0f) resultf = 1.0f;
	}
	// VOLTERRO
	else
	{
		x = Z.n;
		y = Z.i;
		f = g = x2 = y2 = 0;
		h = volterro_sets[set_index*2];
		p = volterro_sets[set_index*2+1];
		iterations = 256;
		bailout = 256.0f;
		for(i = 0; (i < iterations) && (comp_abs(&Z) < bailout); i++) {
			f = x - x*y;
			g = -y + x*y;
			x2 = x + p*f;
			y2 = y + p*g;
			x = x + (h/2)*(f+(x2-x2*y2));
			y = y + (h/2)*(g+(-y2+x2*y2));
			Z.n = x;
			Z.i = y;
		}
		resultf = comp_abs(&Z) / bailout;
		if(resultf > 1.0f) resultf = 1.0;
		resultf = (float)pow(((float)i + resultf) / iterations, 1.0f / 3.0f);
		if(resultf > 1.0f) resultf = 1.0;
	}
	// resultf on tiedossa, palauta resulti
#if SDL_BYTEORDER == SDL_LIL_ENDIAN
	resulti = (int)(0xFF) + (((int)(0xC0)) << 8);
	resulti |= (((int)(resultf * 255.0f)) << 24);
#else
	resulti = (int)(0xFF000000) + (((int)(0xC0)) << 16);
	resulti |= (int)(resultf * 255.0f);
#endif
	return resulti;
}

void fractal_calc(int texture, int type, float x, float y, float zoom)
{
	int i, j;
	complex pixel;

	for(j = 0; j < fractal_h; j++)
		for(i = 0; i < fractal_w; i++)
		{
			pixel.i = y + ((float)(j - fractal_h) / (float)fractal_h + 0.5f) *
				2.0f * 0.75f / zoom;
			pixel.n = x + ((float)(i - fractal_w) / (float)fractal_w + 0.5f) *
				2.0f / zoom;
			texture_playground[j * fractal_w + i] = iterate(pixel, type,
					(texture < JULIA_AMOUNT) ? texture : texture - JULIA_AMOUNT);
		}

	texture_create(&texture_fractal[texture], fractal_w, fractal_h);
}

/*
 * Initoi kaikki fraktaalit paitsi ensimmäisen, joka on precalcin taustalla.
 */
void fractal_init()
{
	int i;

	for(i = 0; i < FRACTAL_AMOUNT; i++)
	{
		efu_progress_bar();
		if(i < JULIA_AMOUNT)
			fractal_calc(i, JULIA, 0.0f, 0.0f, 0.75f);
		else
			fractal_calc(i, VOLTERRO, 3.3f, 2.45f, 0.3f);
	}
}

//############################################################################
// Kaupunki ##################################################################
//############################################################################

#define CITY_SIZE		330
#define CITY_SQUARE		30
#define CITY_SQUARECNT		(CITY_SIZE / CITY_SQUARE)
#define CITY_SQUARETOT		(CITY_SQUARECNT * CITY_SQUARECNT)
#define CITY_CONTROL_DENSITY	15
#define CITY_CONTROL_SIZE	(CITY_SIZE / CITY_CONTROL_DENSITY)
#define CITY_STARTCRD		0.50f
#define CITY_ENDCRD		0.70f
#define CITY_HEIGHT		500.0f
#define CITY_TERRAIN_MAXHEIGHT	2700.0f
#define CITY_SQUARE_SIZE	3550.0f
#define CITY_TOTAL_SIZE		(CITY_SQUARE_SIZE * CITY_SQUARECNT)
#define CITY_DETAIL		22
#define CITY_BUILDING_PROB	3
#define CITY_BUILDING_MAXHT	16
#define CITY_LEVELS		9
#define CITY_STARTSQUARE	5
#define CITY_ENDSQUARE		7
#define CITY_SQUARESIZE		(CITY_ENDSQUARE - CITY_STARTSQUARE + 1)
#define CITY_BUILDING_HTSCALE	(1.0f / (float)CITY_BUILDING_MAXHT * 8000.0f)
#define CITY_CITYAREA_SIZE	(CITY_SQUARE_SIZE * CITY_SQUARESIZE)
#define CITY_BUILDING_SIZE	(CITY_CITYAREA_SIZE / (float)CITY_DETAIL)
#define CITY_BUILDING_START	(CITY_SQUARE_SIZE * CITY_STARTSQUARE)
#define CITY_RAKO_HEIGHT	200.0f
#define CITY_RAKO_IN		(CITY_BUILDING_SIZE * 0.2f)
#define CITY_BUILDING_SEGMENT	5
#define CITY_COL_TERRAIN_LO	14
#define CITY_COL_TERRAIN_MD	15
#define CITY_COL_TERRAIN_HI	16
#define CITY_COL_TREE_BARK	17
#define CITY_COL_TREE_LEAF	18
#define CITY_COL_STREET		19
#define CITY_COL_BUILDING	20
#define CITY_COLCNT_BUILDING	4
#define CITY_COL_TERRAIN_FLR	25
#define CITY_VIEW_DIST		1.5f
#define CITY_BACKCLIP		10030.0f
#define CITY_FOGSTART		8000.0f
#define CITY_FOGEND		10030.0f
#define CITY_TREE_RADIUS	20.0f
#define CITY_TREE_HEIGHT	900.0f
#define CITY_TREE_LEAVES	5
#define CITY_TREE_MAXLEAFHT	0.45f
#define CITY_TREE_MINLEAFHT	0.2f
#define CITY_CONNECT_DISP	100.0f
#define CITY_TREELINE		0.6f
#define CITY_TERRAIN_LOTOL	0.14f
#define CITY_TERRAIN_HITOL	0.45f
#define CITY_TERRAIN_PEAKTOL	0.85f
#define CITY_MORMOKKI_COUNT	92
#define CITY_MORMOKKI_PATHLEN	50
#define CITY_MORMOKKI_TRY	10
#define CITY_MORMOKKI_WAITTIME	((int)(1.0f / 0.005f))
#define CITY_MORMOKKI_WAITBIG	(CITY_MORMOKKI_WAITTIME / 4)
#define CITY_MORMOKKI_WAITSML	(CITY_MORMOKKI_WAITTIME / 8)
#define CITY_MORMOKKI_FRAC	0.25f
#define CITY_MOERMOKKI_HOPHT	50.0f
#define CITY_MOERMOKKI_SCALE	3.0f
#define CITY_LMORMOKKI_PLEN	500.0f
#define CITY_LMORMOKKI_SPEED	0.005f
#define CITY_LMORMOKKI_WAIT	((int)(1.0f / CITY_LMORMOKKI_SPEED))
#define CITY_FOLD_SCALE		500.0f

// Kaikki kaupungin data
float var_city_terraincontrol[CITY_CONTROL_SIZE * CITY_CONTROL_SIZE];
float var_city_terrain[CITY_SIZE * CITY_SIZE];
int var_city_cityarea[CITY_DETAIL * CITY_DETAIL],
		var_city_done[CITY_DETAIL * CITY_DETAIL],
		var_city_lists;
ShapeDB shape_city_normal[CITY_LEVELS];
PathDB var_city_mormokki_path[CITY_MORMOKKI_COUNT],
			 var_city_lentomormokki_path[CITY_MORMOKKI_COUNT];

/*
 * Piirrä suorakulmio jotakin korkeutta karttaan.
 */
void city_map_drawrect(int x1, int y1, int x2, int y2, float ht)
{
	int i, j;
	for(i = y1; i <= y2; i++)
		for(j = x1; j <= x2; j++)
			var_city_terraincontrol[i * CITY_CONTROL_SIZE + j] = ht;
}

/*
 * Kerro onko piirretty.
 */
int city_detail_drawn(int x, int z)
{
	return var_city_done[z * CITY_DETAIL + x];
}

/*
 * Merkkaa piirretyksi.
 */
void city_detail_mark(int x1, int z1, int x2, int z2, int ht)
{
	int i, j;

	for(i = z1; i <= z2; i++)
		for(j = x1; j <= x2; j++)
		{
			var_city_done[i * CITY_DETAIL + j] = 1;
			var_city_cityarea[i * CITY_DETAIL + j] = ht;
		}
}

/*
 * Hae kaupungin yksityiskohta.
 */
int city_get_detail(int x, int z)
{
	if((x < 0) || (x >= CITY_DETAIL) || (z < 0) || (z >= CITY_DETAIL))
		return -1;
	return var_city_cityarea[z * CITY_DETAIL + x];
}

/*
 * Hae pisteen paino.
 */
float get_control_point_weight(int x, int y, int rx, int ry)
{
	int mx = x % CITY_CONTROL_DENSITY,
			my = y % CITY_CONTROL_DENSITY;
	float dist = CITY_CONTROL_DENSITY - dist_2d(mx, my, rx, ry);
	if(dist <= 0.0f)
		return 0.0f;
	return dist;
}

/*
 * Hae kontrollipiste.
 */
float get_control_point_height(int cx, int cy, float weight, float total)
{
	return interpolate_count_near(weight / total) *
		var_city_terraincontrol[cy * CITY_CONTROL_SIZE + cx];
}

/*
 * Hae jonkin pisteen korkeus (suhteessa kontrollipisteisiin).
 */
float get_point_height(int x, int y)
{
	int minx = x / CITY_CONTROL_DENSITY,
			miny = y / CITY_CONTROL_DENSITY,
			maxx = (minx + 1) % CITY_CONTROL_SIZE,
			maxy = (miny + 1) % CITY_CONTROL_SIZE;
	float weight1 = get_control_point_weight(x, y, 0, 0),
				weight2 = get_control_point_weight(x, y, CITY_CONTROL_DENSITY, 0),
				weight3 = get_control_point_weight(x, y, 0, CITY_CONTROL_DENSITY),
				weight4 = get_control_point_weight(x, y, CITY_CONTROL_DENSITY,
						CITY_CONTROL_DENSITY),
				total = weight1 + weight2 + weight3 + weight4;
	return get_control_point_height(minx, miny, weight1, total) +
		get_control_point_height(maxx, miny, weight2, total) +
		get_control_point_height(minx, maxy, weight3, total) +
		get_control_point_height(maxx, maxy, weight4, total);
}

/*
 * Palauta maaston värit.
 */
int city_get_terraincolor_normal(float op)
{
	if(op <= CITY_TERRAIN_MAXHEIGHT * CITY_TERRAIN_LOTOL)
		return CITY_COL_TERRAIN_FLR;
	else if(op <= CITY_TERRAIN_MAXHEIGHT * CITY_TERRAIN_HITOL)
		return CITY_COL_TERRAIN_LO;
	else if(op <= CITY_TERRAIN_MAXHEIGHT * CITY_TERRAIN_PEAKTOL)
		return CITY_COL_TERRAIN_MD;
	return CITY_COL_TERRAIN_HI;
}

/*
 * Tee lehdet puuhun.
 */
void city_generate_tree_leaf(ShapeDB *shp, float angle, float x, float z,
		float y1, float y2, float totht)
{
	float ca, sa, len = (rand_float_neg(0.5f) + 1.0f) * totht / 10.0f; 
	sa = (float)(sin(angle) * len);
	ca = (float)(cos(angle) * len);
	shapedb_add_tcv(shp, x, y2, z, 0.0f, 0.0f, CITY_COL_TREE_LEAF);
	shapedb_add_tcv(shp, x + ca, y1, z + sa, 1.0f, 0.0f, CITY_COL_TREE_LEAF);
	shapedb_add_tcv(shp, x, y1, z, 1.0f, 1.0f, CITY_COL_TREE_LEAF);
	shapedb_add_tcv(shp, x - ca, y1, z - sa, 0.0f, 1.0f, CITY_COL_TREE_LEAF);
	shapedb_add_index_neg(shp, 4);
	shapedb_add_index_neg(shp, 3);
	shapedb_add_index_neg(shp, 2);
	shapedb_add_index_neg(shp, 1);
	shapedb_add_index_neg(shp, 4);
	shapedb_add_index_neg(shp, 1);
	shapedb_add_index_neg(shp, 2);
	shapedb_add_index_neg(shp, 3);
}

/*
 * Luo puu (kuusi)
 */
void city_create_tree(ShapeDB *shp, float x, float y, float z, float scale)
{
	int i;
	float rot, leaftop, leafbottom, totht;

	totht = scale * CITY_TREE_HEIGHT;

	shapedb_draw_cube(shp, x - CITY_TREE_RADIUS, y - 20.0f,
			z - CITY_TREE_RADIUS, x + CITY_TREE_RADIUS,
			y + scale * CITY_TREE_HEIGHT, z + CITY_TREE_RADIUS, 0.4f, 0, 1,
			CITY_COL_TREE_BARK);

	// Tee lehdet
	for(i = 0; i < CITY_TREE_LEAVES; i++)
	{
		leaftop = (rand_float(1.0f - CITY_TREE_MAXLEAFHT) + CITY_TREE_MAXLEAFHT) *
			totht + y;
		leafbottom = leaftop - (rand_float(CITY_TREE_MAXLEAFHT -
					CITY_TREE_MINLEAFHT) + CITY_TREE_MINLEAFHT) * totht;
		rot = rand_float(M_PI);
		city_generate_tree_leaf(shp, rot, x, z, leafbottom, leaftop, totht);
		city_generate_tree_leaf(shp, rot + M_PI / 2.0f, x, z, leafbottom,
				leaftop, totht);
	}
}

/*
 * Nappaa palan maastoa ja tekee siitä ruudun absoluuttisiin koordinaatteihin.
 */
void city_terrain_make_square(int sx, int sz, int ex, int ez, ShapeDB *shp,
		ShapeDB *tree)
{
	int i, j, scanline = ex - sx + 1, idxx, idxz;
	float x, y, z, t, u = 0.0f;

	for(i = sz, idxz = 0; i <= ez; i++, idxz += scanline)
	{
		t = 0.0f;
		for(j = sx, idxx = 0; j <= ex; j++, idxx++)
		{
			// Laske koordinaatit
			y = var_city_terrain[i * CITY_SIZE + j];
			x = (float)j / (float)CITY_SIZE * CITY_TOTAL_SIZE;
			z = (float)i / (float)CITY_SIZE * CITY_TOTAL_SIZE;
			// Lisää muotoon
			shapedb_add_tcv(shp, x, y, z, t, u, city_get_terraincolor_normal(y));
			// Tee primitiivit
			if((i != ez) && (j != ex))
			{
				// Data
				shapedb_add_index(shp, idxz + idxx);
				shapedb_add_index(shp, idxz + scanline + idxx);
				shapedb_add_index(shp, idxz + scanline + idxx + 1);
				shapedb_add_index(shp, idxz + idxx + 1);
			}

			// Tee puu jos hyvin käy
			if((y < CITY_TERRAIN_MAXHEIGHT * CITY_TREELINE) && (rand_int(28) == 0))
				city_create_tree(tree, x + rand_float_neg(20.0f), y,
						z + rand_float_neg(20.0f), 1.0f + rand_float_neg(0.3f));

			texcoord_switch(&t);
		}

		texcoord_switch(&u);
	}
}

/*
 * Piirretäänkö rakennus oikeasti?
 */
int city_layout_building(int x, int z)
{
	int lt = city_get_detail(x - 1, z),
			rt = city_get_detail(x + 1, z),
			bk = city_get_detail(x, z - 1),
			fw = city_get_detail(x, z + 1),
			tot;
	lt = (lt == -1) || (lt > 0);
	rt = (rt == -1) || (lt > 0);
	bk = (bk == -1) || (lt > 0);
	fw = (fw == -1) || (lt > 0);
	tot = lt + rt + bk + fw;
	// Jos paljon naapureita, ei missään nimessä taloa
	if(tot >= 3)
		return 0;
	// Jos 2 naapuria, joka kolmannella kerralla talo
	if(tot == 2)
		return (rand_int(3) == 0);
	// Muutoin joka toisella
	return rand_int(2);
}

/*
 * Muunna kokonaisluku kaupungin tasokoordinaatiksi.
 */
float city_detail_transform_xz(int op)
{
	return (float)op * CITY_BUILDING_SIZE + CITY_BUILDING_START;
}

/*
 * Muunna kokonaisluku kaupungin korkeuskoordinaatiksi.
 */
float city_detail_transform_y(int op)
{
	return (float)op * CITY_BUILDING_HTSCALE + CITY_HEIGHT;
}

/*
 * Lisää polun pituutta.
 */
void city_mormokki_path_inc(PathDB *pth, int x, int z)
{
	int detail = city_get_detail(x, z);
	float fx = city_detail_transform_xz(x) + rand_float(CITY_BUILDING_SIZE),
				fz = city_detail_transform_xz(z) + rand_float(CITY_BUILDING_SIZE),
				fy = city_detail_transform_y((detail <= 1) ? 0 : detail);
	path_add_vd(pth, fx, fy, fz, 0.0f, 0.0f, 0.0f, 0.0f);
}

/*
 * Lisää lentomörmökin polun pituutta.
 */
void city_lentomormokki_path_inc(PathDB *pth)
{
	float x, y, z, ax, az, *curr, ang;

	y = rand_float((1.5f + rand_float_neg(0.9f)) * CITY_TERRAIN_MAXHEIGHT);

	if(pth->cnt == 0)
	{
		x = rand_float(CITY_TOTAL_SIZE);
		z = rand_float(CITY_TOTAL_SIZE);
		path_add_vd(pth, x, y, z, 0.0f, 0.0f, 0.0f, 0.0f);
	}
	else
	{
		curr = path_get_last(pth);
		while(1)
		{
			ang = rand_float(M_PI * 2.0f);
			x = (float)cos(ang) * CITY_LMORMOKKI_PLEN;
			z = (float)sin(ang) * CITY_LMORMOKKI_PLEN;
			ax = curr[0] + x;
			az = curr[2] + z;
			if((ax >= 0.0f) && (az >= 0.0f) && (ax <= CITY_TOTAL_SIZE) &&
					(az <= CITY_TOTAL_SIZE))
				break;
		}
		path_add_vd(pth, ax, y, az, x, y - curr[1], z, rand_float_neg(45.0f));
	}
}

/*
 * Tarkista onko kävelykelpoinen.
 */
int city_mormokki_walkable(int x, int z, int cmp)
{
	int detail = city_get_detail(x, z);
	if((detail == cmp) || ((detail == 0) && (cmp == 1)) ||
			((detail == 1) && (cmp == 0)))
		return 1;
	return 0;
}

/*
 * Lisää polulle seuraava samalla korkeudella oleva square.
 */
void city_mormokki_next_block(PathDB *pth, int *x, int *z)
{
	int lt = city_get_detail((*x) - 1, (*z)),
			rt = city_get_detail((*x) + 1, (*z)),
			fw = city_get_detail((*x), (*z) - 1),
			bk = city_get_detail((*x), (*z) + 1),
			i;

	for(i = 0; i < CITY_MORMOKKI_TRY; i++) // Yritä 10 kertaa
	{
		// Arvo suunta ja katso voiko sinne mennä
		switch(rand_int(4))
		{
			case 0: // left
				if(city_mormokki_walkable(*x, *z, lt))
				{
					(*x)--;
					goto end;
				}
				break;
			case 1: // right
				if(city_mormokki_walkable(*x, *z, rt))
				{
					(*x)++;
					goto end;
				}
				break;
			case 2: // forward
				if(city_mormokki_walkable(*x, *z, fw))
				{
					(*z)--;
					goto end;
				}
				break;
			default: // back
				if(city_mormokki_walkable(*x, *z, bk))
				{
					(*z)++;
					goto end;
				}
				break;
		}
	}

	// Ei löytynyt mitään, joten hyrrätään samassa ruudussa
end: // GOTO CONSIDERED HARMFUL
	city_mormokki_path_inc(pth, *x, *z);
}

/*
 * Piirrä rakennus.
 */
void city_generate_block(int x, int z)
{
	float x1 = city_detail_transform_xz(x),
				x2 = city_detail_transform_xz(x + 1),
				z1 = city_detail_transform_xz(z),
				z2 = city_detail_transform_xz(z + 1),
				y1, y2, y3;
	int i, j, col,
			detail = city_get_detail(x, z);
	ShapeDB *shp;

	// Jos piirretty jo, pois
	if(city_detail_drawn(x, z))
		return;

	// Jos rakennus
	if(detail > 1)
	{

		// Väri
		col = CITY_COL_BUILDING + rand_int(CITY_COLCNT_BUILDING);

		// Laajennetaanko oikealle
		for(i = 1; (city_get_detail(x + i, z) == detail) &&
				(!city_detail_drawn(x + i, z)); i++)
			x2 += CITY_BUILDING_SIZE;
		// Laajennetaanko taakse
		for(j = 1; (city_get_detail(x, z + j) == detail) &&
				(!city_detail_drawn(x, z + j)); j++)
			z2 += CITY_BUILDING_SIZE;

		// Merkitään piirretyksi
		city_detail_mark(x, z, x + i - 1, z + j - 1, detail);

		// Hae muodot
		shp = shape_city_normal + 2;

		// Piirrä rakennus segmentteinä
		for(i = 0; i < detail;)
		{
			j = i + rand_int(CITY_BUILDING_SEGMENT) + 1;
			// Cap jos isompi
			if(i + j > detail)
				j = detail - i;
			if(i + j < 2)
				j = 2;

#ifndef FLAG_NOSTDLIB
			if(i + j < 2)
				cond_printf("Error: i = %i, j = %i, block = %i\n", i, j, detail);
#endif

			// Laske min ja max
			y1 = city_detail_transform_y(i);
			y2 = city_detail_transform_y(i + j);

			// Jos ei olla ykköskerroksessa, segmentti
			if(i != 0)
			{
				y3 = y1 + CITY_RAKO_HEIGHT;
				shapedb_draw_cube(shp, x1 + CITY_RAKO_IN, y1, z1 + CITY_RAKO_IN,
						x2 - CITY_RAKO_IN, y3, z2 - CITY_RAKO_IN, 0.0f, 0, 0, col);
				shapedb_draw_cube(shp, x1, y3, z1, x2, y2, z2, 0.0f, 1, 1, col);
			}
			// Muutoin ilman
			else
				shapedb_draw_cube(shp, x1, y1, z1, x2, y2, z2, 0.0f, 0, 1,
						col);
			// Korkeammalle
			i += j;
			// Vaihdetaan seuraavan korkeuden muotoon
			shp++;
		}
	}
	// Muutoin katsotaan halutaanko puisto
	else if(detail == 1)
	{
		shp = shape_city_normal + 1;
		shapedb_draw_flat(shp, x1, z1, x2, z2, CITY_HEIGHT, CITY_COL_TERRAIN_LO);
		// Tee pari puuta
		for(i = 0; i < rand_int(4); i++)
			city_create_tree(shp, x1 + rand_float(CITY_BUILDING_SIZE), CITY_HEIGHT,
					z1 + rand_float(CITY_BUILDING_SIZE), 1.0f + rand_float_neg(0.4f));
	}
	// Muutoin katu
	else
	{
		shp = shape_city_normal;
		shapedb_draw_flat(shp, x1, z1, x2, z2, CITY_HEIGHT, CITY_COL_STREET);
	}
}

/*
 * Luo x/z-suuntaisen yhteyden.
 */
void city_generate_connection(int a, int b, int c, float y1, float y2,
		int xaxis)
{
	ShapeDB *shp = shape_city_normal + CITY_LEVELS - 1;
	float conndisp = (0.8f + rand_float(0.6f)) * CITY_CONNECT_DISP,
				c1 = city_detail_transform_xz(c) + conndisp,
				c2 = city_detail_transform_xz(c + 1) - conndisp,
				fa = city_detail_transform_xz(a + 1),
				fb = city_detail_transform_xz(b);
	int col = CITY_COL_BUILDING + rand_int(CITY_COLCNT_BUILDING);
	if(xaxis)
		shapedb_draw_cube(shp, fa, y1, c1, fb, y2, c2, 0.0f, 1, 1, col);
	else
		shapedb_draw_cube(shp, c1, y1, fa, c2, y2, fb, 0.0f, 1, 1, col);
}

/*
 * Luo yhteyden kahden rakennuksen välille.
 */
void city_generate_connections(int x, int z)
{
	int i, j, curr;
	float y1, y2;

	// Pääloop
	for(i = city_get_detail(x, z); i >= 2; i--)
	{
		// Vain harvoin
		if(rand_int(8) == 0)
		{
			// Height
			y1 = city_detail_transform_y(i) - (1.5f + rand_float(1.0f)) *
				CITY_CONNECT_DISP;
			y2 = city_detail_transform_y(i) - (0.5f + rand_float(0.5f)) *
				CITY_CONNECT_DISP;

			// Vasen
			if(city_get_detail(x - 1, z) < i)
				for(j = x - 2; 1; j--)
				{
					curr = city_get_detail(j, z);
					if(curr >= i)
					{
						city_generate_connection(j, x, z, y1, y2, 1);
						break;
					}
					else if(curr < 0)
						break;
				}

			// Oikea
			if(city_get_detail(x + 1, z) < i)
				for(j = x + 2; 1; j++)
				{
					curr = city_get_detail(j, z);
					if(curr >= i)
					{
						city_generate_connection(x, j, z, y1, y2, 1);
						break;
					}
					else if(curr < 0)
						break;
				}

			// Etu
			if(city_get_detail(x, z - 1) < i)
				for(j = z - 2; 1; j--)
				{
					curr = city_get_detail(x, j);
					if(curr >= i)
					{
						city_generate_connection(j, z, x, y1, y2, 0);
						break;
					}
					else if(curr < 0)
						break;
				}

			// Taka
			if(city_get_detail(x, z + 1) < i)
				for(j = z + 2; 1; j++)
				{
					curr = city_get_detail(x, j);
					if(curr >= i)
					{
						city_generate_connection(z, j, x, y1, y2, 0);
						break;
					}
					else if(curr < 0)
						break;
				}
		}
	}
}

/*
 * Esilaske kaupunki.
 */
void generate_city()
{
	int i, j, k, l, maxht, *cityblock;
	float citystart, cityend, dist;
	PathDB *pth;

	// Tyhjennä muodot
	for(i = 0; i < CITY_LEVELS; i++)
		shapedb_clear(shape_city_normal + i);

	// Ensin maaston kontrollipisteet
	rand_seed(3);
	i = CITY_CONTROL_SIZE * CITY_CONTROL_SIZE - 1;
	do
	{
		var_city_terraincontrol[i] = interpolate_count_near(rand_float(1.0f)) *
			CITY_TERRAIN_MAXHEIGHT;
	} while(i--);

	// Tehdään liffa alue kaupunkia varten
	citystart = ((float)CITY_CONTROL_SIZE * CITY_STARTCRD) - 1;
	cityend = ((float)CITY_CONTROL_SIZE * CITY_ENDCRD) + 1;
	city_map_drawrect((int)citystart, (int)citystart, (int)cityend,
			(int)cityend, CITY_HEIGHT);

	// Generoidaan maaston pisteet
	for(i = 0; i < CITY_SIZE; i++)
		for(j = 0; j < CITY_SIZE; j++)
			var_city_terrain[i * CITY_SIZE + j] = get_point_height(i, j);

	// Luodaan display listit maastolle
	var_city_lists = glGenLists(CITY_SQUARETOT + CITY_LEVELS);

	// Maasto interpoloimalla pisteitten väliä Redundanssilla ei väliä, precalc
	// saa kestää.
	for(i = 0; i < CITY_SQUARECNT; i++)
		for(j = 0; j < CITY_SQUARECNT; j++)
		{
			k = i * CITY_SQUARECNT + j;
			// Seuraavat
			k = (i + 1) * CITY_SQUARE;
			l = (j + 1) * CITY_SQUARE;
			if(k >= CITY_SIZE)
				k = CITY_SIZE - 1;
			if(l >= CITY_SIZE)
				l = CITY_SIZE - 1;
			// Tee
			shapedb_clear(&shape_use);
			shapedb_clear(&shape_crane);
			city_terrain_make_square(j * CITY_SQUARE, i * CITY_SQUARE, l, k,
					&shape_use, &shape_crane);
			// Tee display listit
			k = i * CITY_SQUARECNT + j;
			glNewList(var_city_lists + k, GL_COMPILE);
			shapedb_draw_elements(&shape_use, tex_ruutu_bind_2, GL_DECAL,
					GL_QUADS);
			shapedb_draw_elements(&shape_crane, tex_ruutu_bind_2, GL_DECAL,
					GL_QUADS);
			glEndList();    
		}

	// Nollataan kaupunki
	i = CITY_DETAIL * CITY_DETAIL - 1;
	do
	{
		var_city_cityarea[i] = -2; // -2 on TÄRKEÄÄ
		var_city_done[i] = 0;
	} while(i--);

	// Generoidaan kaupungin asemakaava
	rand_seed(6);
	for(i = 0; i < CITY_DETAIL; i++)
	{
		for(j = 0; j < CITY_DETAIL; j++)
		{
			cityblock = var_city_cityarea + i * CITY_DETAIL + j;
			if(*cityblock < 0)
			{
				if(city_layout_building(j, i))
				{
					dist = dist_2d(j, i, CITY_DETAIL / 2, CITY_DETAIL / 2);
					maxht = (int)(cos((float)dist / ((float)CITY_DETAIL / 2.0f) * M_PI /
								2.0f) * CITY_BUILDING_MAXHT);
					// Jos ollaan kaukana niin sitten ollaan
					if(maxht < 0)
						maxht = 0;
					// Se oikea korkeus ja laitetaan
					maxht = rand_int(maxht + 3);
					*cityblock = maxht;
					// Joskus haluamme ison talon
					switch(rand_int(8))
					{
						case 1: // Oikealle
							if(j < CITY_DETAIL - 2)
								*(cityblock + 1) = maxht;
							break;
						case 2: // Taakse
							if(i < CITY_DETAIL - 2)
								*(cityblock + CITY_DETAIL) = maxht;
							break;
						case 3: // Molemmat
							if(j < CITY_DETAIL - 2)
								*(cityblock + 1) = maxht;
							if(i < CITY_DETAIL - 2)
								*(cityblock + CITY_DETAIL) = maxht;
							break;
						default:
							break;
					}
				}
				else
					*cityblock = 0; // 0 on puisto
			}
		}
	}

	// Generoidaan kaupungin talot
	rand_seed(11); // Yhteyksien data
	for(i = 0; i < CITY_DETAIL; i++)
		for(j = 0; j < CITY_DETAIL; j++)
		{
			city_generate_block(j, i);
			city_generate_connections(j, i);
		}

	// Kaupungin display listit
	for(i = 0; i < CITY_LEVELS; i++)
	{
		glNewList(var_city_lists + CITY_SQUARETOT + i, GL_COMPILE);
		shapedb_draw_elements(&shape_city_normal[i], tex_ruutu_bind_1, GL_DECAL,
				GL_QUADS);
		glEndList();
	}

	// Luodaan kaupunkimörmökkien polut
	rand_seed(0xEC2CDB03); // Mörmökkipolkujen data
	for(i = 0; i < CITY_MORMOKKI_COUNT; i++)
	{
		pth = var_city_mormokki_path + i;
		j = rand_int(CITY_DETAIL);
		k = rand_int(CITY_DETAIL);
		// Etsitään alkupiste
		while(city_get_detail(j, k) > 1)
		{
			j = rand_int(CITY_DETAIL);
			k = rand_int(CITY_DETAIL);
		}
		// Lisätään alkupiste
		city_mormokki_path_inc(pth, j, k);
		// Lisätään loput pisteet
		for(l = 0; l < CITY_MORMOKKI_PATHLEN; l++)
			city_mormokki_next_block(pth, &j, &k);
	}

	// Luodaan lentomormokkien polut
	rand_seed(0x8816D08D); // Lentomörmökkipolkujen data
	for(i = 0; i < CITY_MORMOKKI_COUNT; i++)
	{
		pth = var_city_lentomormokki_path + i;
		path_clear(pth);
		for(j = 0; j < CITY_MORMOKKI_PATHLEN; j++)
			city_lentomormokki_path_inc(pth);
	}

	// Luetaan lentsikan polku
	path_read_vddata(&path_plane, trail_plane, TRAIL_PLANE_LEN);
	path_read_vddata(&path_tachikoma, trail_tachikoma, TRAIL_TACHIKOMA_LEN);
}

/*
 * Piirrä ruutu.
 */
void city_draw_square(int x, int z)
{
	// Kielletyt ruudut
	if(((x >= CITY_STARTSQUARE) && (x <= CITY_ENDSQUARE) &&
				(z >= CITY_STARTSQUARE) && (z <= CITY_ENDSQUARE)) ||
			(x < 0) || (z < 0) || (x >= CITY_SQUARECNT) || (z >= CITY_SQUARECNT))
		return;

	// Muutoin piirto
	glCallList(var_city_lists + z * CITY_SQUARECNT + x);
}

/*
 * Kaupungin piirtotilat.
 */
void mode_city_normal(int op)
{
	blend_mode(2);
	screen_clear(13);
	glFogfv(GL_FOG_COLOR, colordb_get_float(13));
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	shapedb_draw_safe = shapedb_draw_wire;
}
void mode_city_wire(int op)
{
	blend_mode(1);
	glFogfv(GL_FOG_COLOR, colordb_get_float(0));
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	glLineWidth(3.0f);
	shapedb_draw_safe = shapedb_draw_elements;
}

/*
 * Piirrä kaupunki.
 */
void efu_city(int freezetime)
{
	int i, j, k, l;
	float moermokkipos;
	PathDB *pth;

	// Kamera
	camera_frustum(90.0f, CITY_BACKCLIP);
	glLoadIdentity();
	look_at(lookat_city, freezetime);

	// Fog
	glFogi(GL_FOG_MODE, GL_LINEAR);
	glFogf(GL_FOG_START, CITY_FOGSTART);
	glFogf(GL_FOG_END, CITY_FOGEND);
	glEnable(GL_FOG);

	i = (int)(camera_position[0] / CITY_SQUARE_SIZE);
	j = (int)(camera_position[2] / CITY_SQUARE_SIZE);

	// Piirretään paljon
	for(k = i - 3; k <= i + 3; k++)
		for(l = j - 3; l <= j + 3; l++)
			city_draw_square(k, l);
	for(k = -1; k <= 1; k++)
	{
		city_draw_square(i + k, j - 4);
		city_draw_square(i + k, j + 4);
		city_draw_square(i - 4, j + k);
		city_draw_square(i + 4, j + k);
	}

	// Piirrä koko kaupunki
	for(i = 0; i < CITY_LEVELS; i++)
		glCallList(var_city_lists + CITY_SQUARETOT + i);

	// Piirrä mörmökit
	rand_seed(1);
	glDisable(GL_CULL_FACE);
	for(i = 0; i < CITY_MORMOKKI_COUNT; i++)
		if(i != 18) // Tämä nimenomainen mörmökki on häiritsevä, emme halua häntä
		{
			// Ensin normaalit moermokit, matriisi talteen
			glPushMatrix();
			pth = var_city_mormokki_path + i;

			// Sitten hop-pos
			moermokkipos = path_hop(freezetime - rand_int(CITY_MORMOKKI_WAITTIME),
					CITY_MORMOKKI_WAITTIME, CITY_MORMOKKI_FRAC, CITY_MORMOKKI_WAITBIG,
					CITY_MORMOKKI_WAITSML, CITY_MOERMOKKI_HOPHT);

			// Polku ja liike
			path_get_pos_spline(pth, moermokkipos, PATH_MODE_FWD);
			glScale1f(CITY_MOERMOKKI_SCALE);
			if(rand_int(2))
				shapedb_draw_elements(&shape_crane, tex_crane_bind, GL_DECAL,
						GL_TRIANGLES);
			else
				shapedb_draw_elements(&shape_unicorn, tex_crane_bind, GL_DECAL,
						GL_TRIANGLES);

			// Popitetaan matriisi ja jatketaan lentomoermokilla
			glPopMatrix();
			glPushMatrix();
			pth = var_city_lentomormokki_path + i;

			// Lasketaan paikka
			moermokkipos = (freezetime - rand_int(CITY_LMORMOKKI_WAIT)) *
				CITY_LMORMOKKI_SPEED;
			path_get_pos_spline(pth, moermokkipos, PATH_MODE_FWD);
			glScale1f(CITY_MOERMOKKI_SCALE);
			shapedb_draw_elements(&shape_varis, tex_crane_bind, GL_DECAL,
					GL_TRIANGLES);

			// Looppi loppu
			glPopMatrix();
		}

	// Piirrä lentsikka
	moermokkipos = freezetime * 0.0032f;
	glPushMatrix();
	path_get_pos_spline(&path_plane, moermokkipos, PATH_MODE_NORMAL);
	glScale1f(CITY_FOLD_SCALE);
	shapedb_draw_safe(&shape_simpleplane[2], 0, 0, GL_QUADS);
	glPopMatrix();

	// Piirrä tachikoma
	glPushMatrix();
	if(freezetime > 1950)
		moermokkipos = path_hop(freezetime - 1950, CITY_MORMOKKI_WAITTIME,
				CITY_MORMOKKI_FRAC, CITY_MORMOKKI_WAITBIG, CITY_MORMOKKI_WAITSML,
				CITY_MOERMOKKI_HOPHT);
	path_get_pos_spline(&path_tachikoma, moermokkipos, PATH_MODE_FWD);
	glScale1f(3.0f);
	shapedb_draw_elements(&shape_tachikoma, tex_crane_bind, GL_DECAL,
			GL_TRIANGLES);
	glPopMatrix();
}

/*
 * Wrappereita
 */
void efu_city_hlt1(int op)
{
	efu_city(CITY_HALT_1);
}
void efu_city_hlt2(int op)
{
	efu_city(CITY_HALT_2 - CITY_HALT_1_DUR);
}
void efu_city_hlt3(int op)
{
	efu_city(CITY_HALT_3 - CITY_HALT_2_DUR - CITY_HALT_1_DUR);
}
void efu_city_ph2(int op)
{
	efu_city(op + CITY_HALT_1);
}
void efu_city_ph3(int op)
{
	efu_city(op + CITY_HALT_2 - CITY_HALT_1_DUR);
}
void efu_city_ph4(int op)
{
	efu_city(op + CITY_HALT_3 - CITY_HALT_1_DUR - CITY_HALT_2_DUR);
}

//############################################################################
// Targetointi ###############################################################
//############################################################################

#define TARGETING_W	0.01f
#define TARGETING_W2	(1.2f * TARGETING_W)
#define TARGETING_W3	(2.4f * TARGETING_W)
#define TARGETING_DELAY	20
#define TARGETING_COLOR	29

/*
 * Fold tarvitsee joskus 'targetointia'. Tässä ne
 */
void targeting_main(float x1, float y1, float x2, float y2, int freezetime,
		int len)
{
	float pos = (1.0f - (float)freezetime / (float)len);
	int i;

	if(pos < 0.0f)
		pos = 0.0f;

	x1 += pos * (-1.0f - x1);
	y1 += pos * (-0.75f - y1);
	x2 += pos * (1.0f - x2);
	y2 += pos * (0.75f - y2);

	blend_mode(3);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

	shapedb_clear(&shape_use);
	// vas ylh
	shapedb_add_cv(&shape_use, x1 - TARGETING_W, y1 - TARGETING_W, 0.0f,
			TARGETING_COLOR);
	shapedb_add_cv(&shape_use, x1, y1, 0.0f,
			TARGETING_COLOR);
	// oik ylh
	shapedb_add_cv(&shape_use, x2 + TARGETING_W, y1 - TARGETING_W, 0.0f,
			TARGETING_COLOR);
	shapedb_add_cv(&shape_use, x2, y1, 0.0f,
			TARGETING_COLOR);
	// oik alh
	shapedb_add_cv(&shape_use, x2 + TARGETING_W, y2 + TARGETING_W, 0.0f,
			TARGETING_COLOR);
	shapedb_add_cv(&shape_use, x2, y2, 0.0f,
			TARGETING_COLOR);
	// vas alh
	shapedb_add_cv(&shape_use, x1 - TARGETING_W, y2 + TARGETING_W, 0.0f,
			TARGETING_COLOR);
	shapedb_add_cv(&shape_use, x1, y2, 0.0f,
			TARGETING_COLOR);
	// Lisätään referenssit
	for(i = 0; i < 8; i++)
		shapedb_add_index(&shape_use, i);
	shapedb_add_index(&shape_use, 0);
	shapedb_add_index(&shape_use, 1);

	// Piirto
	camera_ortho(1.0f);
	glLoadIdentity();
	shapedb_draw_elements(&shape_use, 0, 0, GL_TRIANGLE_STRIP);
}

/*
 * Tripletarget.
 */
void targeting_triple(float x1, float y1, float x2, float y2, int op, int len)
{
	targeting_main(x1, y1, x2, y2, op, len);
	targeting_main(x1 - TARGETING_W2, y1 - TARGETING_W2, x2 + TARGETING_W2,
			y2 + TARGETING_W2, op - TARGETING_DELAY, len);
	targeting_main(x1 - TARGETING_W3, y1 - TARGETING_W3, x2 + TARGETING_W3,
			y2 + TARGETING_W3, op - TARGETING_DELAY * 2, len);
}

/*
 * Targetointikutsut. Huomaa, että tähän on turha kirjoitella vakioita, koska
 * targetointikutsut ovat itsessään melkeinpä makroja.
 */
void targeting_plane(int op)
{
	targeting_triple(-0.67f, 0.10f, 0.15f, 0.62f, op, 55);
}
void targeting_crane(int op)
{
	targeting_triple(-0.29f, -0.39f, 0.18f, -0.08f, op, 55);
}
void targeting_crow(int op)
{
	targeting_triple(0.02f, -0.45f, 0.27f, -0.21f, op, 55);
}

// Tachikoma-target oli tarkemmin ajatellen tylsä idea
/*void targeting_tachikoma(int op)
	{
	targeting_triple(0.07f, -0.08f, 0.18f, 0.02f, op, 40);
	}*/

//############################################################################
// Efektit ###################################################################
//############################################################################

#define EFU_COUNT	(4 + 5 + 2 + 5 + 2 + 5 + 2 + 6 + 22)

/*
 * Alustetaan kaikkien efektien ajat.
 */
EffectData var_efu[] =
{
	// Circles
	{ CIRCLES_START, CIRCLES_END, efu_circles },
	{ CIRCLES_START + PILLAR_START, CIRCLES_END, efu_pillar },
	{ CIRCLES_START + WINGS_START, CIRCLES_START + WINGS_END, efu_wings },
	{ CIRCLES_START + ORITEXT_START, CIRCLES_END, efu_oritext },
	// City phase 1
	{ CITY_START, CITY_START + CITY_HALT_1, mode_city_normal },
	{ CITY_START + CITY_HALT_1, CITY_START + CITY_FOLD_1, mode_city_wire },
	{ CITY_START, CITY_START + CITY_HALT_1, efu_city },
	{ CITY_START + CITY_HALT_1, CITY_START + CITY_FOLD_1, efu_city_hlt1 },
	{ CITY_START + CITY_TARGETING_1, CITY_START + CITY_FOLD_1, targeting_plane },
	// Lentokoneen taittelu
	{ CITY_START + CITY_FOLD_1 - FOLDBACK_DURATION / 2, CITY_START + CITY_FOLD_1_END, efu_fold_background },
	{ CITY_START + CITY_FOLD_1, CITY_START + CITY_FOLD_1_END, efu_fold_plane },
	// City phase 2
	{ CITY_START + CITY_FOLD_1_END, CITY_START + CITY_HALT_2, mode_city_normal },
	{ CITY_START + CITY_HALT_2, CITY_START + CITY_FOLD_2, mode_city_wire },
	{ CITY_START + CITY_FOLD_1_END, CITY_START + CITY_HALT_2, efu_city_ph2 },
	{ CITY_START + CITY_HALT_2, CITY_START + CITY_FOLD_2, efu_city_hlt2 },
	{ CITY_START + CITY_TARGETING_2, CITY_START + CITY_FOLD_2, targeting_crane },
	// Kurjen taittelu
	{ CITY_START + CITY_FOLD_2 - FOLDBACK_DURATION / 2, CITY_START + CITY_FOLD_2_END, efu_fold_background },
	{ CITY_START + CITY_FOLD_2, CITY_START + CITY_FOLD_2_END, efu_fold_crane },
	// City phase 3
	{ CITY_START + CITY_FOLD_2_END, CITY_START + CITY_HALT_3, mode_city_normal },
	{ CITY_START + CITY_HALT_3, CITY_START + CITY_FOLD_3, mode_city_wire },
	{ CITY_START + CITY_FOLD_2_END, CITY_START + CITY_HALT_3, efu_city_ph3 },
	{ CITY_START + CITY_HALT_3, CITY_START + CITY_FOLD_3, efu_city_hlt3 },
	{ CITY_START + CITY_TARGETING_3, CITY_START + CITY_FOLD_3, targeting_crow },
	// Variksen taittelu
	{ CITY_START + CITY_FOLD_3 - FOLDBACK_DURATION / 2, CITY_START + CITY_FOLD_3_END, efu_fold_background },
	{ CITY_START + CITY_FOLD_3, CITY_START + CITY_FOLD_3_END, efu_fold_crow },
	// City phase 4
	{ CITY_START + CITY_FOLD_3_END, CITY_START + CITY_XRAY, mode_city_normal },
	{ CITY_START + CITY_XRAY, CITY_START + CITY_XRAY_END, mode_city_wire },
	{ CITY_START + CITY_XRAY_END, CITY_START + CITY_XRAY2, mode_city_normal },
	{ CITY_START + CITY_XRAY2, CITY_START + CITY_XRAY2_END, mode_city_wire },
	{ CITY_START + CITY_XRAY2_END, CITY_END, mode_city_normal },
	{ CITY_START + CITY_FOLD_3_END, CITY_END, efu_city_ph4 },
	//{ CITY_START + CITY_XRAY, CITY_START + CITY_XRAY_END, targeting_tachikoma },
	// GitS
	{ GITS_START, GITS_END, efu_gits },
	{ GITS_START + 300, GITS_START + 700, gits_text_gfxcode },
	{ GITS_START + 400, GITS_START + 800, gits_text_trilkk },
	{ GITS_START + 700, GITS_START + 1100, gits_text_muscode },
	{ GITS_START + 800, GITS_START + 1200, gits_text_juippi },
	{ GITS_START + 1100, GITS_START + 1500, gits_text_other },
	{ GITS_START + 1200, GITS_START + 1600, gits_text_warma },
	{ GITS_START + 1500, GITS_START + 1900, gits_text_greets },
	{ GITS_START + 1600, GITS_START + 2000, gits_text_anakin },
	{ GITS_START + 1700, GITS_START + 2100, gits_text_blamstrain },
	{ GITS_START + 1800, GITS_START + 2200, gits_text_ninave },
	{ GITS_START + 1900, GITS_START + 2300, gits_text_rmm },
	{ GITS_START + 2000, GITS_START + 2400, gits_text_sihteeri },
	{ GITS_START + 2100, GITS_START + 2500, gits_text_smak },
	{ GITS_START + 2200, GITS_START + 2600, gits_text_theflash },
	{ GITS_START + 2300, GITS_START + 2700, gits_text_tuokku },
	{ GITS_START + 2400, GITS_START + 2800, gits_text_valquis },
	{ GITS_START + 2500, GITS_START + 2900, gits_text_vv },
	{ GITS_START + 3200, GITS_START + 3600, gits_text_thanks },
	{ GITS_START + 3300, GITS_START + 3700, gits_text_watching },
	{ GITS_START + 3400, GITS_START + 3800, gits_text_origami },
	{ GITS_START + 3500, GITS_START + 3900, gits_text_intro }
};

//############################################################################
// Progress bar ##############################################################
//############################################################################

// Pakko definoida tässä, jos hukkuu niin meh :(
#define MUSIC_PRECALC_TIME	220
// Ei haittaa jos ei käytetä
#define TOTAL_PROGRESS		(MUSIC_PRECALC_TIME + FRACTAL_AMOUNT)

/*
 * Tausta.
 */
void progress_bar_background()
{
	// Tyhjennä
	screen_clear(35);

	// Näytä teksti
	text_draw_string(string_wait, -3.0f, 1.0f, 0.65f, 0.65f, 3, 50000);
}

/*
 * Init.
 */
void progress_bar_init()
{
	blend_mode(1);
	camera_ortho(4.0f);
	glLoadIdentity();

	// Näytä tausta
	progress_bar_background();

	// Ruudulle
	SDL_GL_SwapBuffers();
}

/*
 * Etene yksi askel.
 */
void efu_progress_bar()
{
	SDL_Event event;
	float r;
	static int progress = 0;

	// Edistys
	progress++;
	r = (float)progress / (float)TOTAL_PROGRESS * 4.0f * 2.0f - 4.0f;

	// Tausta
	progress_bar_background();

	// Generoi progress bar ja näytä se.
	shapedb_clear(&shape_use);
	shapedb_add_tcv(&shape_use, -4.0f, -1.0f, 0.0, 0.0, 0.0, 36);
	shapedb_add_tcv(&shape_use, r, -1.0f, 0.0, 1.0, 0.0, 36);
	shapedb_add_tcv(&shape_use, r, -2.0f, 0.0, 1.0, 1.0, 36);
	shapedb_add_tcv(&shape_use, -4.0f, -2.0f, 0.0, 0.0, 1.0, 36);
	shapedb_add_index(&shape_use, 0);
	shapedb_add_index(&shape_use, 1);
	shapedb_add_index(&shape_use, 2);
	shapedb_add_index(&shape_use, 3);
	shapedb_draw_elements(&shape_use, 0, 0, GL_QUADS);

	// Ruudulle
	SDL_GL_SwapBuffers();

	// Kuuntele eventit ja quit pyydettäessä
	if(SDL_PollEvent(&event))
		if((event.type == SDL_QUIT) || ((event.type == SDL_KEYDOWN) &&
					(event.key.keysym.sym == SDLK_ESCAPE)))
		{
			SDL_Quit();
			exit(1);
		}
}

//############################################################################
// Juipin softasyna, vuosimalli 2005 #########################################
//############################################################################

#include "syn_types.h"

#include "connect.h"
#include "sequencer.h"
#include "constant.h"
#include "oscillator.h"
#include "envelope.h"
#include "filter.h"
#include "filter2.h"
#include "mixer.h"
#include "delay.h"
#include "multiplier.h"
#include "adder.h"
#include "overdrive.h"

#include "song.h"

// Globaalit
Mixer *master_mix;
int audio_total_freqs = 0;

/*
 * Synan callback.
 */
void audio_callback(void *userdata, Uint8 *stream, int len)
{
	ChannelEndian l, r;
	static size_t samples_written = 0;
	Sint16 *stream_frm = (Sint16*)stream;
	int i;

	audio_total_freqs += len / (sizeof(Sint16) * 2);
	var_timer = (int)((double)audio_total_freqs * ((double)TIMER_FPS / (double)SRATE));

	//return; // Remove me

	for(i = 0; i < len; i += sizeof(Sint16) * 2)
	{
#ifndef FLAG_NOSTDLIB
		int audioskip = (int)((float)var_timer_skip / 60.0f * (float)SRATE * 2);
		l.chn = audio_precalc[audioskip + samples_written++];
		r.chn = audio_precalc[audioskip + samples_written++];
#else
		l.chn = audio_precalc[samples_written++];
		r.chn = audio_precalc[samples_written++];
#endif

#if SDL_BYTEORDER == SDL_LIL_ENDIAN
		stream_frm[0] = l.chn;
		stream_frm[1] = r.chn;
#else
		{
			Uint8 *stream8 = (Uint8*)stream_frm;
			stream8[0] = l.c8.c2;
			stream8[1] = l.c8.c1;
			stream8[2] = l.c8.c2;
			stream8[3] = l.c8.c1;
		}
#endif
		stream_frm += 2;
	}
}

/*
 * Generointifunkkarit.
 */
void process()
{
	int i;

	for (i=0; i<n_sequencers; i++){
		process_sequencer(sequencers[i]);
	}
	for (i=0; i<n_envelopes; i++){
		process_envelope(envelopes[i]);
	}
	for (i=0; i<n_oscillators; i++){
		process_oscillator(oscillators[i]);
	}
	for (i=0; i<n_filters; i++){
		process_filter(filters[i]);
	}
	for (i=0; i<n_mixers; i++){
		process_mixer(mixers[i]);
	}
	for (i=0; i<n_multipliers; i++){
		process_multiplier(multipliers[i]);
	}
	for (i=0; i<n_adders; i++){
		process_adder(adders[i]);
	}
	for (i=0; i<n_delays; i++){
		process_delay(delays[i]);
	}    
	for (i=0; i<n_overdrives; i++){
		process_overdrive(overdrives[i]);
	}    
}

// bassokone

void bassmachine(Mixer *mix, int port)
{
	Sequencer *seq1;
	Oscillator *osc1, *osc2;
	Filter *fil1;
	Envelope *env1, *env2;
	Adder *add1;

	seq1 = new_sequencer(1, 0, 1, basspatterns, bassorder);
	osc1 = new_oscillator(SAW, 1.0f, 0.5f);
	osc2 = new_oscillator(SAW, 2.005f, 1.0f);
	fil1 = new_filter(LP, 0.12f, 0.30f);
	env1 = new_envelope(0.01f, 0.5f, 0.1f, 0.5f);
	env2 = new_envelope(0.02f, 1.0f, 0.0f, 0.1f);
	add1 = new_adder(2);

	// oscillators & envelopes
	conn(seq1, 0, osc1, 0);
	conn(env2, 0, osc1, 1);
	conn(seq1, 0, osc2, 0);
	conn(env2, 0, osc2, 1);

	conn(seq1, 1, env1, 0);
	constant(1.0f, env1, 1);
	conn(seq1, 1, env2, 0);
	constant(1.0f, env2, 1);

	// add together & feed to filter
	conn(osc1, 0, add1, 0);
	conn(osc2, 0, add1, 1);
	conn(add1, 0, fil1, 0);
	conn(env1, 0, fil1, 1);
	constant(1.0f, fil1, 2);

	// to mix
	conn(fil1, 0, mix, port);
}

void stringmachine(Mixer *mix, int port) // uses 4 output ports!
{
	int i;
	Sequencer *seq1;

	seq1 = new_sequencer(4, 1, 8, stringpatterns, stringorder);

	for (i=0; i<4; i++)
	{
		Oscillator *osc1, *osc2, *lfo;
		Envelope *env1, *env2;
		Filter *fil1, *fil2;
		Adder *add1, *add2, *add3;
		Delay *del1;

		osc1 = new_oscillator(SAW, 1.0f, 1.0f);
		osc2 = new_oscillator(SAW, 1.01f, 1.0f);
		env1 = new_envelope(0.9f, 0.1f, 1.0f, 1.2f);
		env2 = new_envelope(1.0f, 0.8f, 0.8f, 1.8f);
		fil1 = new_filter(HP, 0.08f, 0.60f);
		fil2 = new_filter(LP, 0.14f, 0.60f);
		add1 = new_adder(2);
		del1 = new_delay(1.0f, TRUE);
		add2 = new_adder(2);
		add3 = new_adder(2);
		lfo = new_oscillator(TRIANGLE, 1.0f + i*0.02f, 1.0f);

		//constant(1.0f, env1, ENV_IN_AMP);
		conn(seq1, 8, env1, ENV_IN_AMP);
		conn(seq1, i*2 + 1, env1, ENV_IN_TRIG);
		constant(1.0f, env2, ENV_IN_AMP);
		conn(seq1, i*2 + 1, env2, ENV_IN_TRIG);

		// oscillators
		conn(seq1, i*2, osc1, OSC_MOD_FREQ);
		conn(env1, ENV_OUT_SIGNAL, osc1, OSC_MOD_AMP);
		conn(osc1, OSC_OUT_SIGNAL, add1, 0);

		conn(seq1, i*2, osc2, OSC_MOD_FREQ);
		conn(env1, ENV_OUT_SIGNAL, osc2, OSC_MOD_AMP);
		conn(osc2, OSC_OUT_SIGNAL, add1, 1);

		// filters
		conn(add1, OSC_OUT_SIGNAL, fil1, 0);
		constant(1.0f, fil1, 1);
		conn(env2, ENV_OUT_SIGNAL, fil2, 1);
		conn(fil1, 0, fil2, 0);

		// flanger
		conn(fil2, 0, del1, 0);
		constant(0.2f, lfo, OSC_MOD_FREQ);
		constant(0.010f, lfo, OSC_MOD_AMP);

		conn(lfo, 0, add2, 0);
		constant(0.015f, add2, 1);

		conn(add2, 0, del1, 1);

		// mix dry & wet
		conn(fil2, 0, add3, 0);
		conn(del1, 0, add3, 1);

		conn(add3, 0, mix, port + i*3);
	}    
}

void dingmachine(Mixer *mix, int port) // uses 3 output ports
{
	int i;
	Sequencer *seq1;

	seq1 = new_sequencer(3, 0, 4, dingpatterns, dingorder);

	for (i=0; i<3; i++)
	{
		Oscillator *osc1, *osc2;
		Envelope *env1, *env2, *env3;
		Filter *fil1, *fil2;
		Adder *add1;

		osc1 = new_oscillator(SAW, 1.0f, 1.0f);
		osc2 = new_oscillator(SQUARE, 2.01f, 0.5f);
		env1 = new_envelope(0.01f, 0.4f, 0.2f, 1.0f); // osc
		env2 = new_envelope(0.05f, 1.5f, 0.3f, 1.0f); // fil
		env3 = new_envelope(0.03f, 0.6f, 0.3f, 1.0f); // fil2
		fil1 = new_filter(HP, 0.35f, 0.3f);
		fil2 = new_filter(LP, 0.25f, 1.6f);
		add1 = new_adder(2);

		conn(seq1, 0 + i*2, osc1, OSC_MOD_FREQ);
		conn(seq1, 0 + i*2, osc2, OSC_MOD_FREQ);

		conn(osc1, OSC_OUT_SIGNAL, add1, 0);
		conn(osc2, OSC_OUT_SIGNAL, add1, 1);

		conn(seq1, 1 + i*2, env1, ENV_IN_TRIG);
		conn(seq1, 1 + i*2, env2, ENV_IN_TRIG);
		conn(seq1, 1 + i*2, env3, ENV_IN_TRIG);
		constant(1.0f, env1, ENV_IN_AMP);
		constant(1.0f, env2, ENV_IN_AMP);
		constant(1.0f, env3, ENV_IN_AMP);

		conn(env1, 0, osc1, OSC_MOD_AMP);
		conn(env1, 0, osc2, OSC_MOD_AMP);
		conn(env2, ENV_OUT_SIGNAL, fil1, FILTER_MOD_CUTOFF);
		conn(env3, ENV_OUT_SIGNAL, fil2, FILTER_MOD_CUTOFF);
		conn(add1, 0, fil1, FILTER_IN_SIGNAL);

		constant(1.0f, fil2, FILTER_MOD_CUTOFF);
		conn(fil1, FILTER_OUT_SIGNAL, fil2, FILTER_IN_SIGNAL);

		conn(fil2, FILTER_OUT_SIGNAL, mix, port + i*3);
	}
}

void drummachine(Mixer *mix, int port)
{
	Sequencer *seq1;
	Oscillator *osc1, *osc2, *osc3, *osc4;
	Envelope *env1, *env3, *env4, *env5, *env6;
	Filter *fil1, *fil2, *fil3;

	seq1 = new_sequencer(4, 0, 2, drumpatterns, drumorder);

	// bd
	osc1 = new_oscillator(TRIANGLE, 200.0f, 1.0f);
	env1 = new_envelope(0.001f, 0.15f, 0.0f, 0.1f);
	//  Envelope *env2 = new_envelope(0.001f, 0.03f, 0.2f, 0.3f);

	// sd
	osc2 = new_oscillator(NOISE, 1.0f, 1.0f);
	fil1 = new_filter(BP, 0.30f, 0.30f);
	env3 = new_envelope(0.001f, 0.8f, 0.0f, 1.0f);
	env4 = new_envelope(0.001f, 0.2f, 0.5f, 1.0f);

	//hh1
	osc3 = new_oscillator(NOISE, 1.0f, 1.0f);
	fil2 = new_filter(HP, 0.60f, 0.20f);
	env5 = new_envelope(0.001f, 0.05f, 0.0f, 0.1f);

	//hh2
	osc4 = new_oscillator(NOISE, 1.0f, 1.0f);
	fil3 = new_filter(HP, 0.60f, 0.10f);
	env6 = new_envelope(0.001f, 0.10f, 0.05f, 0.5f);

	// bd
	conn(seq1, 1, env1, ENV_IN_TRIG);
	constant(1.0f, env1, ENV_IN_AMP);
	conn(env1, ENV_OUT_SIGNAL, osc1, OSC_MOD_AMP);

	constant(1.0f, env1, ENV_IN_AMP);
	conn(env1, 0, osc1, OSC_MOD_FREQ);

	conn(osc1, 0, mix, port);

	// sd
	conn(seq1, 3, env3, ENV_IN_TRIG);
	conn(seq1, 3, env4, ENV_IN_TRIG);
	constant(1.0f, env4, ENV_IN_AMP);
	conn(env4, ENV_OUT_SIGNAL, env3, ENV_IN_AMP);

	constant(1.0f, osc2, OSC_MOD_FREQ);
	conn(env3, ENV_OUT_SIGNAL, osc2, OSC_MOD_AMP);

	conn(osc2, OSC_OUT_SIGNAL, fil1, 0);
	constant(1.0f, fil1, FILTER_MOD_CUTOFF);

	conn(fil1, 0, mix, port + 3);

	// hh1
	conn(seq1, 5, env5, ENV_IN_TRIG);
	constant(1.0f, env5, ENV_IN_AMP);

	constant(1.0f, osc3, OSC_MOD_FREQ);
	conn(env5, ENV_OUT_SIGNAL, osc3, OSC_MOD_AMP);

	constant(1.0f, fil2, 1);
	conn(osc3, 0, fil2, 0);

	conn(fil2, 0, mix, port + 6);

	// hh 2
	conn(seq1, 7, env6, ENV_IN_TRIG);
	constant(1.0f, env6, ENV_IN_AMP);

	constant(1.0f, osc4, OSC_MOD_FREQ);
	conn(env6, ENV_OUT_SIGNAL, osc4, OSC_MOD_AMP);

	constant(1.0f, fil3, 1);
	conn(osc4, 0, fil3, 0);

	conn(fil3, 0, mix, port + 9);
}

void resomachine(Mixer *mix, int port)
{
	Sequencer *seq1;
	Oscillator *osc1;
	Envelope *env1;
	Filter *fil1;
	Delay *del1;

	seq1 = new_sequencer(1, 1, 2, resopatterns, resoorder);

	osc1 = new_oscillator(SAW, 1.0f, 1.0f);
	env1 = new_envelope(0.01f, 0.01f, 1.0f, 0.01f);
	fil1 = new_filter(LP, 0.30f, 0.07f);
	del1 = new_delay(1.0f, FALSE);

	conn(seq1, 1, env1, ENV_IN_TRIG);
	constant(1.0f, env1, ENV_IN_AMP);

	conn(env1, 0, osc1, OSC_MOD_AMP);
	conn(seq1, 0, osc1, OSC_MOD_FREQ);

	conn(osc1, 0, fil1, 0);
	conn(seq1, 2, fil1, 1);

	conn(fil1, 0, del1, 0);
	constant(0.2f, del1, 1);

	conn(fil1, 0, mix, port);
	conn(del1, 0, mix, port + 3);
}

/*
 * Itse biisi koostetaan tässä.
 */

void juipin_biisi_init()
{
	SDL_AudioSpec spec, ret;
	Mixer *string_bus;
	Delay *string_del1, *string_del2;
	Sint16 l, r;
	float fl, fr;
	int i;

	// Varataan tämä mainjuttu
	audio_precalc = (Sint16 *)malloc(MUSIC_PRECALC_TIME * 2 * 44100 *
			sizeof(Sint16));

	master_mix = new_mixer(16);

	string_bus = new_mixer(4);
	string_del1 = new_delay(1.0f, FALSE);
	string_del2 = new_delay(1.0f, FALSE);

	bassmachine(master_mix, 0);
	constant(0.17f, master_mix, 1);
	constant(0.0f, master_mix, 2);

	resomachine(master_mix, 3);
	constant(0.08f, master_mix, 4);
	constant(0.8f, master_mix, 5);

	// 6
	constant(0.03f, master_mix, 7);
	constant(-1.0f, master_mix, 8);

	dingmachine(master_mix, 9);
	constant(0.25f, master_mix, 10);
	constant(-0.4f, master_mix, 11);
	constant(0.25f, master_mix, 13);
	constant(0.0f, master_mix, 14);
	constant(0.25f, master_mix, 16);
	constant(-0.2f, master_mix, 17);

	stringmachine(string_bus, 0);
	constant(0.1f, string_bus, 1);
	constant(-0.5f, string_bus, 2); 
	constant(0.13f, string_bus, 4);
	constant(0.4f, string_bus, 5);
	constant(0.1f, string_bus, 7);
	constant(-0.4f, string_bus, 8);
	constant(0.13f, string_bus, 10);
	constant(0.5f, string_bus, 11);

	// to master mix with stereo delay
	conn(string_bus, 0, string_del1, 0);
	conn(string_bus, 1, string_del2, 0);
	constant(0.3f, string_del1, DELAY_IN_LEN);
	constant(0.5f, string_del1, DELAY_IN_LEN);

	conn(string_bus, 0, master_mix, 18);
	constant(0.4f, master_mix, 19);
	constant(-1.0f, master_mix, 20);
	conn(string_bus, 0, master_mix, 21);
	constant(0.4f, master_mix, 22);
	constant(1.0f, master_mix, 23);
	conn(string_del1, 0, master_mix, 24);
	constant(0.15f, master_mix, 25);
	constant(1.0f, master_mix, 26);
	conn(string_del2, 0, master_mix, 27);
	constant(0.15f, master_mix, 28);
	constant(-1.0f, master_mix, 29);

	drummachine(master_mix, 30); // 4 ports
	constant(0.8f, master_mix, 31);
	constant(0.0f, master_mix, 32);
	constant(0.35f, master_mix, 34);
	constant(0.0f, master_mix, 35);
	constant(0.04f, master_mix, 37);
	constant(-0.7f, master_mix, 38);
	constant(0.04f, master_mix, 40);
	constant(-0.7f, master_mix, 41);

	for(i = 0; i < MUSIC_PRECALC_TIME * SRATE; i++)
	{
		// Tiedotetaan tilanne
		if((i % SRATE == 0) || (i == MUSIC_PRECALC_TIME * SRATE - 1))
			efu_progress_bar();

		process();
		// LSB 16b signed stereo vittu sovitaan että menee vaikka näin
		fl = OUT(master_mix, 0);
		fr = OUT(master_mix, 1);

		if (fl > 1.5f)
			fl = 1.5f;
		else if (fl < -1.5f)
			fl = -1.5f;
		if (fr > 1.5f)
			fr = 1.5f;
		else if (fr < -1.5f)
			fr = -1.5f;

		l = (int)(fl * 20000);
		r = (int)(fr * 20000);
		/* 	unsigned char l_l = l % 255; */
		/* 	unsigned char l_h = l >> 8; */
		/* 	unsigned char r_l = r % 255; */
		/* 	unsigned char r_h = r >> 8; */

		/* 	fwrite(&l_l, 1, 1, f); */
		/* 	fwrite(&l_h, 1, 1, f); */
		/* 	fwrite(&r_l, 1, 1, f); */
		/* 	fwrite(&r_h, 1, 1, f); */
		//stream_frm[0] = l;
		//stream_frm[1] = r;
		//stream_frm += 2;

		audio_precalc[i * 2] = l;
		audio_precalc[i * 2 + 1] = r;
	}

	// Sitten initialisoidaan äänilaite, ensin parametrit
	spec.freq = SRATE;
	spec.format = AUDIO_S16LSB;
	spec.channels = 2;
	spec.callback = audio_callback;
	spec.userdata = NULL;

	// Samples riippuu käyttiksestä. Windowsilla threadit eivät toimi kivasti.
#ifdef WIN32
	spec.samples = 2048;
#else // UNIX
	spec.samples = 512;
#endif

#ifdef RECORDING_MODE
	{
		FILE *filu = fopen("origami_audio.raw", "w");
		fwrite(audio_precalc,
				sizeof(int16_t),
				MUSIC_PRECALC_TIME * SRATE * 2,
				filu);
		fclose(filu);
	}
#else
	// Avataan audio device
	if(SDL_OpenAudio(&spec, &ret) < 0)
	{
		cond_printf("Error: %s\n", SDL_GetError());
		return;
	}
#endif
}

//############################################################################
// Preloader ################################################################
//############################################################################

#ifndef FLAG_NOSTDLIB // Jos minimikoko niin ei mitään preloadereita

#include "config.h" // Tarvitaan preloaderin valintaan

//############################################################################
// GTK-preloader #############################################################
//############################################################################

#ifdef FLAG_ENABLE_GTK

// Headeri
#include "gtk/gtk.h"

// Definet
#define ORIGAMI_PADDING	2

// Näistä tarvitaan dataa callbackeissa
GtkWidget *combo_res, *combo_fres, *check_debug, *check_fs, *window;
int preloader_run = 1;

/*
 * Lukee datan.
 */
void preloader_read(gpointer data)
{
	// Lue resoluutiot
	sscanf(gtk_entry_get_text(
				GTK_ENTRY(GTK_COMBO(combo_res)->entry)), "%ix%i",
			&screen_w, &screen_h);
	sscanf(gtk_entry_get_text(
				GTK_ENTRY(GTK_COMBO(combo_fres)->entry)), "%ix%i",
			&fractal_w, &fractal_h);
	// Flagit
	debug_flag = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(check_debug));
	if(gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(check_fs)))
		display_flags |= SDL_FULLSCREEN;

	// Lopeta GTK
	preloader_run = 0;
	gtk_widget_destroy(window);
}

/*
 * Lopettaa GTK-härsmäkkeen.
 */
void preloader_exit(gpointer data)
{
	// Jos pitää poistua kunnolla
	if(preloader_run == 1)
		exit(1);
}

/*
 * Preloaderi tekee GTK-ikkunan.
 */
void preloader(int argc, char **args)
{
	GtkWidget *table_res, *hbox_buttons, *button_read, *button_exit, *vbox_main,
						*vbox_opt, *label_res, *label_fres, *frame_opt, *image_banner,
						*tmpwidget;
	GdkPixbuf *pixbuf_banner, *pixbuf_icon;
	GList *resolutions = NULL;

	// GTK-init
	gtk_init(&argc, &args);

	// Resoluutiot
	resolutions = g_list_append(resolutions, "320x240");
	resolutions = g_list_append(resolutions, "400x300");
	resolutions = g_list_append(resolutions, "512x384");
	resolutions = g_list_append(resolutions, "640x480");
	resolutions = g_list_append(resolutions, "800x600");
	resolutions = g_list_append(resolutions, "960x720");
	resolutions = g_list_append(resolutions, "1024x768");
	resolutions = g_list_append(resolutions, "1152x864");
	resolutions = g_list_append(resolutions, "1280x960");
	resolutions = g_list_append(resolutions, "1600x1200");

	// Tee ikkuna
	window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
	gtk_window_set_title(GTK_WINDOW(window), "Origami");
	pixbuf_icon = gdk_pixbuf_new_from_file(path_icon, NULL);
	if(pixbuf_icon == NULL)
		pixbuf_icon = gdk_pixbuf_new_from_file(path_icon + 3, NULL);
	if(pixbuf_icon == NULL)
		pixbuf_icon = gdk_pixbuf_new_from_file(path_icon + 7, NULL);
	gtk_window_set_icon(GTK_WINDOW(window), pixbuf_icon);
	gtk_window_set_resizable(GTK_WINDOW(window), FALSE);

	// Eventit ikkunaan
	g_signal_connect_swapped(G_OBJECT(window), "destroy",
			G_CALLBACK(preloader_exit), (gpointer)NULL);
	g_signal_connect_swapped(G_OBJECT(window), "delete_event",
			G_CALLBACK(gtk_widget_destroy), G_OBJECT(window));

	// Tee banner
	pixbuf_banner = gdk_pixbuf_new_from_file(path_banner, NULL);
	if(pixbuf_banner == NULL)
		pixbuf_banner = gdk_pixbuf_new_from_file(path_banner + 3, NULL);
	if(pixbuf_banner == NULL)
		pixbuf_banner = gdk_pixbuf_new_from_file(path_banner + 7, NULL);
	image_banner = gtk_image_new_from_pixbuf(pixbuf_banner);

	// Tee dropboxit
	table_res = gtk_table_new(2, 2, FALSE);
	gtk_table_set_col_spacing (GTK_TABLE(table_res), 1, ORIGAMI_PADDING);
	label_res = gtk_label_new("Resolution:");
	label_fres = gtk_label_new("Fractal resolution:");
	combo_res = gtk_combo_new(); 
	combo_fres = gtk_combo_new();
	gtk_combo_set_popdown_strings(GTK_COMBO(combo_res), resolutions);
	gtk_combo_set_popdown_strings(GTK_COMBO(combo_fres), resolutions);
	gtk_entry_set_text(GTK_ENTRY(GTK_COMBO(combo_res)->entry), "800x600");
	gtk_entry_set_text(GTK_ENTRY(GTK_COMBO(combo_fres)->entry), "512x384");
	//gtk_combo_set_value_in_list(GTK_COMBO(combo_res), TRUE, FALSE);
	//gtk_combo_set_value_in_list(GTK_COMBO(combo_fres), TRUE, FALSE);
	tmpwidget = gtk_hbox_new(FALSE, 0);
	gtk_box_pack_start(GTK_BOX(tmpwidget), label_res, FALSE, FALSE, 0);
	gtk_table_attach(GTK_TABLE(table_res), tmpwidget, 0, 1, 0, 1, GTK_FILL,
			GTK_FILL, ORIGAMI_PADDING, 0);
	gtk_table_attach(GTK_TABLE(table_res), combo_res, 1, 2, 0, 1, GTK_FILL,
			GTK_FILL, ORIGAMI_PADDING, 0);
	tmpwidget = gtk_hbox_new(FALSE, 0);
	gtk_box_pack_start(GTK_BOX(tmpwidget), label_fres, FALSE, FALSE, 0);
	gtk_table_attach(GTK_TABLE(table_res), tmpwidget, 0, 1, 1, 2, GTK_FILL,
			GTK_FILL, ORIGAMI_PADDING, 0);
	gtk_table_attach(GTK_TABLE(table_res), combo_fres, 1, 2, 1, 2, GTK_FILL,
			GTK_FILL, ORIGAMI_PADDING, 0);

	// Tee checkboxit
	check_debug = gtk_check_button_new_with_label("Enable debug keys?");
	check_fs = gtk_check_button_new_with_label("Fullscreen?");
	gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(check_fs), TRUE);

	// Options -frame
	frame_opt = gtk_frame_new("Options");
	gtk_frame_set_label_align(GTK_FRAME(frame_opt), 0.0, 0.0);
	vbox_opt = gtk_vbox_new(0, 0);
	gtk_box_pack_start(GTK_BOX(vbox_opt), table_res, 0, 0, 0);
	gtk_box_pack_start(GTK_BOX(vbox_opt), check_debug, 0, 0, 0);
	gtk_box_pack_start(GTK_BOX(vbox_opt), check_fs, 0, 0, 0);
	gtk_container_set_border_width (GTK_CONTAINER(frame_opt),
			ORIGAMI_PADDING);
	gtk_container_add(GTK_CONTAINER(frame_opt), vbox_opt);

	// Napit
	hbox_buttons = gtk_hbox_new(0, 0);
	button_read = gtk_button_new_with_label("Start");
	button_exit = gtk_button_new_with_label("Exit");
	g_signal_connect_swapped(G_OBJECT(button_read), "clicked",
			G_CALLBACK(preloader_read), (gpointer)NULL);
	g_signal_connect_swapped(G_OBJECT(button_exit), "clicked",
			G_CALLBACK(gtk_widget_destroy), G_OBJECT(window));
	gtk_box_pack_start(GTK_BOX(hbox_buttons), button_read, TRUE, FALSE, 0);
	gtk_box_pack_start(GTK_BOX(hbox_buttons), button_exit, TRUE, FALSE, 0);

	// Loppu
	vbox_main = gtk_vbox_new(0, 0);
	gtk_box_pack_start(GTK_BOX(vbox_main), image_banner, TRUE, TRUE, 0);
	gtk_box_pack_start(GTK_BOX(vbox_main), frame_opt, FALSE, FALSE,
			ORIGAMI_PADDING * 2);
	gtk_box_pack_start(GTK_BOX(vbox_main), hbox_buttons, TRUE, TRUE, 0);
	gtk_container_set_border_width (GTK_CONTAINER(window), ORIGAMI_PADDING * 2);
	gtk_container_add(GTK_CONTAINER(window), vbox_main);
	gtk_widget_show_all(window);

	// Rullaa
	while(preloader_run)
		gtk_main_iteration();
	// Hoida ne loput eventit mitä jäi
	while(gtk_events_pending())
		gtk_main_iteration();
}

//############################################################################
// Windows-preloader #########################################################
//############################################################################

#else
#ifdef WIN32

//#include "Resource.h" evvk

#define BANNER                          2
#define CFGWINDOW                       102
#define SRESCOMBO                       1000
#define FRESCOMBO                       1001
#define DEBUGCHK                        1002
#define FULLCHK                         1003
#define STARTBTN                        1004
#define EXITBTN                         1005
#define BANNERBOX                       1006

#define RESCOUNT 9

char *reslist[RESCOUNT] = {
	"320x240","400x300","512x384","640x480","800x600","960x720","1024x768",
	"1152x864","1280x960","1600x1200"
};

BOOL CALLBACK preloader_dlgproc (HWND dlg, UINT msg, WPARAM wpm, LPARAM lpm)
{
	switch (msg)
	{
		case WM_INITDIALOG:
			{
				// alustaa comboboxit
				HWND combo; DWORD i,idx;

				// nayttoresoluutio
				combo = GetDlgItem(dlg,MAKEINTRESOURCE(SRESCOMBO));
				for (i=0; i<RESCOUNT; i++) {
					idx = SendMessage(combo,CB_ADDSTRING,0,(LPARAM)(LPCSTR)reslist[i]);
					SendMessage(combo,CB_SETITEMDATA,idx,i);
				}
				SendMessage(combo,CB_SETCURSEL,4,0); // def = 800x600

				// fraktaaliresoluutio
				combo = GetDlgItem(dlg,MAKEINTRESOURCE(FRESCOMBO));
				for (i=0; i<RESCOUNT; i++) {
					idx = SendMessage(combo,CB_ADDSTRING,0,(LPARAM)(LPCSTR)reslist[i]);
					SendMessage(combo,CB_SETITEMDATA,idx,i);
				}
				SendMessage(combo,CB_SETCURSEL,2,0); // def = 512x384

				// fullscreen oletuksena paalle
				CheckDlgButton(dlg,MAKEINTRESOURCE(FULLCHK),BST_CHECKED);
			}
			return 0;

		case WM_COMMAND:
			// kaynnistysnappi
			if (LOWORD(wpm)==STARTBTN)
			{
				HWND combo; DWORD i; char x[10];

				debug_flag = IsDlgButtonChecked(dlg,MAKEINTRESOURCE(DEBUGCHK));
				if (IsDlgButtonChecked(dlg,MAKEINTRESOURCE(FULLCHK)))
					display_flags |= SDL_FULLSCREEN;

				combo = GetDlgItem(dlg,MAKEINTRESOURCE(SRESCOMBO));
				i = SendMessage(combo, CB_GETCURSEL, 0,0);
				SendMessage(combo, CB_GETLBTEXT, i, x);
				sscanf (x,"%ix%i",&screen_w,&screen_h);

				combo = GetDlgItem(dlg,MAKEINTRESOURCE(FRESCOMBO));
				i = SendMessage(combo, CB_GETCURSEL, 0,0);
				SendMessage(combo, CB_GETLBTEXT, i, x);
				sscanf (x,"%ix%i",&fractal_w,&fractal_h);

				EndDialog(dlg,0);
				return 0;
			}
			// poistumisnappi
			else if (LOWORD(wpm)==EXITBTN)
			{
				EndDialog(dlg,-1);
				return 0;
			}
			return 0;

		case WM_CLOSE:
			EndDialog(dlg,-1);
			return 0;

		default:
			return 0;
	}

	return 0;
}

void preloader (int argc, char **args)
{
	if (DialogBox (GetModuleHandle(NULL), MAKEINTRESOURCE(CFGWINDOW),
				0, (DLGPROC)preloader_dlgproc)==-1) exit(1); // poistumisnappi tahi virhe
}

//############################################################################
// SDL-preloader #############################################################
//############################################################################

#else

/*
 * Vaihtoehtoisten resoluutioitten määrä.
 */
#define RES_AMOUNT 7
int resolutions[] =
{
	320, 240,
	400, 300,
	512, 384,
	640, 480,
	800, 600,
	960, 720,
	1024, 768,
	1152, 864,
	1280, 960,
	1600, 1200,
};

/*
 * Palauttaa resoluutiostringin indeksin mukaan.
 */
char *preloader_return_resolution_string(int index)
{
	switch(index)
	{
		case 0:
			return string_320x240;
		case 1:
			return string_400x300;
		case 2:
			return string_512x384;
		case 3:
			return string_640x480;
		case 4:
			return string_800x600;
		case 5:
			return string_960x720;
		case 6:
			return string_1024x768;
		case 7:
			return string_1152x864;
		case 8:
			return string_1280x960;
		case 9:
			return string_1600x1200;
		default:
			return string_800x600;
	}
}

/*
 * Piirrä preloaderin tausta.
 */
void preloader_background()
{
	// Tyhjennä
	screen_clear(35); 

	// Näytä teksti
	text_draw_string(string_options, -2.5f, 2.0f, 0.8f, 0.8f, 3, 50000);
	text_draw_string(string_arrows_change_resolutions, -3.3f, 1.4f, 0.25f,
			0.25f, 3, 50000);
	text_draw_string(string_f_toggles_fullscreen, -3.3f, 1.0f, 0.25f, 0.25f, 3,
			50000);
	text_draw_string(string_d_toggles_debugkeys, -3.3f, 0.6f, 0.25f, 0.25f, 3,
			50000);
	text_draw_string(string_enter_or_space_to_run, -3.3f, 0.2f, 0.25f, 0.25f, 3,
			50000);
}

/*
 * Pleroaderin optiot.
 */
void preloader_options(int full, int keys, int res, int fractal)
{
	text_draw_string(string_fullscreen, -3.5f, -0.7f, 0.4f, 0.5f, 3, 50000);

	// Fullscreen?
	if(full)
		text_draw_string(string_yea, 1.0f, -0.7f, 0.4f, 0.5f, 3, 50000);
	else
		text_draw_string(string_nay, 1.0f, -0.7f, 0.4f, 0.5f, 3, 50000);

	// Debugkeys?
	text_draw_string(string_debugkeys, -3.5f, -1.4f, 0.4f, 0.5f, 3, 50000);
	if(keys)
		text_draw_string(string_yea, 1.0f, -1.4f, 0.4f, 0.5f, 3, 50000);
	else
		text_draw_string(string_nay, 1.0f, -1.4f, 0.4f, 0.5f, 3, 50000);

	// Reso
	text_draw_string(string_res, -3.5f, -2.1f, 0.4f, 0.5f, 3, 50000);
	text_draw_string(preloader_return_resolution_string(res), 1.0f, -2.1f, 0.4f,
			0.5f, 3, 50000);

	// Fractal reso
	text_draw_string(string_fractal_res, -3.5f, -2.8f, 0.4f, 0.5f, 3, 50000);
	text_draw_string(preloader_return_resolution_string(fractal), 1.0f, -2.8f,
			0.4f, 0.5f, 3, 50000);
}

/*
 * Itse SDL-preloader.
 */
void preloader()
{
	int advance;
	int sel_res, sel_fractal_res, sel_fullscreen, sel_debugkeys;
	SDL_Surface *screen;
	SDL_Event event;

	// Arvot
	advance = FALSE;
	sel_fullscreen = TRUE;
	sel_debugkeys = FALSE;
	sel_res = 4;
	sel_fractal_res = 2;

	screen = SDL_SetVideoMode(640, 480, screen_b, SDL_GFX_FLAGS);
	SDL_WM_SetCaption("Origami options", NULL);

	blend_mode(1);
	camera_ortho(4.0f);

	while(!advance)
	{
		// puhtaaksi
		glLoadIdentity();

		// Näytä tausta
		preloader_background();

		// Näytä optiot
		preloader_options(sel_fullscreen, sel_debugkeys, sel_res,
				sel_fractal_res);

		// Ruudulle
		SDL_GL_SwapBuffers();

		// Kuuntele eventit
		if(SDL_PollEvent(&event))
		{
			if(event.type == SDL_QUIT) 
			{
				SDL_Quit();
				exit(0);
			}
			else if(event.type == SDL_KEYDOWN)
			{
				switch(event.key.keysym.sym)
				{
					case SDLK_ESCAPE:
						SDL_Quit();
						exit(0);
						break;
					case SDLK_f:
						if(sel_fullscreen == FALSE)
							sel_fullscreen = TRUE;
						else
							sel_fullscreen = FALSE;
						break;
					case SDLK_d:
						if(sel_debugkeys == FALSE)
							sel_debugkeys = TRUE;
						else
							sel_debugkeys = FALSE;
						break;
					case SDLK_LEFT:
						sel_res--;
						if(sel_res < 0) sel_res = 0;
						break;
					case SDLK_RIGHT:
						sel_res++;
						if(sel_res >= RES_AMOUNT) sel_res = RES_AMOUNT - 1;
						break;
					case SDLK_DOWN:
						sel_fractal_res--;
						if(sel_fractal_res < 0) sel_fractal_res = 0;
						break;
					case SDLK_UP:
						sel_fractal_res++;
						break;					
					case SDLK_SPACE:
						advance=TRUE;
						break;
					case SDLK_RETURN:
						advance=TRUE;
						break;
					default:
						break;
				}
			}
		}
		if(sel_fractal_res > sel_res)
			sel_fractal_res = sel_res;
	}

	// Jätä arvot
	screen_w = resolutions[sel_res * 2];
	screen_h = resolutions[sel_res * 2 + 1];
	fractal_w = resolutions[sel_fractal_res * 2];
	fractal_h = resolutions[sel_fractal_res * 2 + 1];
	if(sel_fullscreen)
		display_flags |= SDL_FULLSCREEN;
	if(sel_debugkeys)
		debug_flag = TRUE;

	// Vapauta tämä pinta ennen kuin jatkamme
	SDL_FreeSurface(screen);
}

#endif // GTK
#endif // WIN32
#endif // NOSTDLIB

//############################################################################
// Asettaa ikonin ############################################################
//############################################################################

#ifndef FLAG_NOSTDLIB
#ifdef FLAG_ENABLE_SDL_IMAGE

// SDL_Image
#include "SDL_image.h"

void sdl_set_icon()
{
	SDL_Surface *icon = NULL;
	icon = IMG_Load(path_icon);
	if(icon == NULL)
		icon = IMG_Load(path_icon + 3);
	if(icon == NULL)
		icon = IMG_Load(path_icon + 7);
	if(icon != NULL)
		SDL_WM_SetIcon(icon, NULL);
}

#endif
#endif

//############################################################################
// Exportattava main #########################################################
//############################################################################

#ifdef FLAG_NOSTDLIB
void c_main()
#else
int main(int argc, char **args)
#endif
{
	int i,
			loop = 1,
			lasttime = -1;
	SDL_Event event;
	SDL_Surface *screen;

#ifndef FLAG_NOSTDLIB // Tarvitaan vain kun ei tehdä kokoihmettä
	int lastskip = 0;
#endif

	/*
	 * Värit pitää muuntaa jo tässä vaiheessa, koska niitä tarvitaan
	 * potentiaalisesti ennen preloadereita.
	 */
	for(i = 0; i < COLORDB_SIZE; i++)
	{
		colordb_convert_u2f(i);
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
		colordb_convert_lebe(i);
#endif
	}

	/*
	 * Preloaderi tässä vaiheessa jos ei tehdä tilaihmettä.
	 */
#ifndef FLAG_NOSTDLIB
	// Jos ei parametreja, anna käyttäjän valita
	if(argc <= 1)
	{
#ifndef WIN32
		cond_printf("Origami by Juippi, Trilkk and Warma. Combined 64k for Assembly 2005.\n  -f, --fullscreen\t(off) Fullscreen mode\n  -d, --debugkeys\t(off) Enable debug keys.\n  -r, --resolution\t(%ix%i) Specify resolution as WIDTHxHEIGHT\n  -fr, --fresolution\t(%ix%i) Specify fractal resolution as WIDTHxHEIGHT\n",
				screen_w, screen_h, fractal_w, fractal_h);
#endif
		preloader(argc, args);
	}
	// Muutoin käydään parametrit läpi
	else
		for(i = 1; i < argc; i++)
		{
			// Fullscreen?
			if((strcmp(args[i], "-f") == 0) ||
					(strcmp(args[i], "--fullscreen") == 0))
				display_flags |= SDL_FULLSCREEN;
			if((strcmp(args[i], "-d") == 0) ||
					(strcmp(args[i], "--debugkeys") == 0))
				debug_flag = 1;
			if((strcmp(args[i], "-r") == 0) ||
					(strcmp(args[i], "--resolution") == 0))
				if(i + 1 < argc)
					sscanf(args[i + 1], "%ix%i", &screen_w, &screen_h);
			if((strcmp(args[i], "-fr") == 0) ||
					(strcmp(args[i], "--fresolution") == 0))
				if(i + 1 < argc)
					sscanf(args[i + 1], "%ix%i", &fractal_w, &fractal_h);
		}

	// Tarkistetaan että ovat ok
	if((screen_w < 160) || (screen_w > 1600) || (screen_h < 120) ||
			(screen_h > 1200))
	{
		screen_w = DEF_SCREEN_W;
		screen_h = DEF_SCREEN_H;
	}
	if((fractal_w < 160) || (fractal_w > 1600) || (fractal_h < 120) ||
			(fractal_h > 1200))
	{
		fractal_w = DEF_FRACTAL_W;
		fractal_h = DEF_FRACTAL_H;
	}
	// Cap fraktaaleille
	if(fractal_w > screen_w)
		fractal_w = screen_w;
	if(fractal_h > screen_h)
		fractal_h = screen_h;
#endif

	/*
	 * Init.
	 */

	// SDL
	SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_AUDIO);
#ifndef FLAG_NOSTDLIB
#ifndef WIN32 // Jos ei win32 ja SDL-image päällä,
#ifdef FLAG_ENABLE_SDL_IMAGE // Laitetaan 16x16 -kuvake
	sdl_set_icon();
#endif
#endif
	screen = SDL_SetVideoMode(screen_w, screen_h, screen_b, display_flags);
	if(display_flags & SDL_FULLSCREEN)
		SDL_ShowCursor(SDL_DISABLE);
	SDL_WM_SetCaption("Origami", NULL);
#else
#ifdef FLAG_FULLSCREEN
	screen = SDL_SetVideoMode(screen_w, screen_h, screen_b,
			SDL_GFX_FLAGS | SDL_FULLSCREEN);
	SDL_ShowCursor(SDL_DISABLE);
#endif
#endif
	// OpenGL
	glViewport(0, 0, screen_w, screen_h);
	glClearDepth(1.0);
	glDepthFunc(GL_LEQUAL);
	//glShadeModel(GL_SMOOTH);

#ifndef RECORDING_MODE
	// Ajastin
	SDL_AddTimer(TIMER_MS, timer_callback, NULL);
#endif

#ifdef WIN32 // Ikoni Windowsissa
	{
#include <SDL_syswm.h>
#define ICON1 135
		SDL_SysWMinfo i;
		if (SDL_GetWMInfo(&i)) {
			HWND hdl=i.window;
			HICON c=LoadIcon(GetWindowLong(hdl,GWL_HINSTANCE),MAKEINTRESOURCE(ICON1));
			SetClassLong(hdl,GCL_HICON,(LONG)c);
		}
	}
#endif

	/*
	 * Precalc.
	 */

	// Tarttee näyttää missä ollaan
	progress_bar_init();

	// Tekstuurit
	tex_line_generate(&tex_line1_bind, 9);
	tex_line_generate(&tex_line2_bind, 10);
	tex_line_generate(&tex_line3_bind, 11);
	tex_ruutu_generate(&tex_ruutu_bind_1, 1, 0);
	tex_ruutu_generate(&tex_ruutu_bind_2, 4, 0);
	tex_ruutu_generate(&tex_crane_bind, 2, 1);

	// Rinkulat
	circles_init();

	// Pilarit
	generate_light_pillar_shard(&shape_pillar_draw, &pillar_draw);
	generate_light_pillar_shard(&shape_pillar_wings, &pillar_wings);

	// GitS-efun yhteydet
	generate_gits();

	// Asiat joita tarvii joka framelle
	rand_seed(0x7060DFDB); // Tärkeää koska kusin jossakin vaiheessa
	i = MAX_EFFECT_TIME * TIMER_MS - 1;
	do
	{
		var_pillar_shard[i] = rand_float(360.0f);
		var_gits_path_start[i] = rand_int(var_gits_pathcount); // Gits-generaation JÄLKEEN
	} while(i--);

	// Kaupunki
	generate_city();

	// Fold
	fold_init();

	// Juipin biisi
	juipin_biisi_init();

	// Fractal
	fractal_init();

	// Flaret
	flare_init();

	// Luetaan mallit, viimeisenä koska tällöin shapet alla ovat vapaata
	// riistaa genuille aiemmin!
	shapedb_clear(&shape_crane);
	shapedb_clear(&shape_flare);
	shapedb_clear(&shape_tachikoma);
	shapedb_clear(&shape_unicorn);
	shapedb_clear(&shape_varis);
	shapedb_read_tcvdata(&shape_crane, form_crane_tcv, form_crane_ref,
			FORM_CRANE_VERTS, FORM_CRANE_INDEXES);
	shapedb_read_cvdata(&shape_flare, form_flare_cv, form_flare_ref,
			FORM_FLARE_VERTS, FORM_FLARE_INDEXES);
	shapedb_read_tcvdata(&shape_tachikoma, form_tachikoma_tcv,
			form_tachikoma_ref, FORM_TACHIKOMA_VERTS, FORM_TACHIKOMA_INDEXES);
	shapedb_read_tcvdata(&shape_unicorn, form_unicorn_tcv,
			form_unicorn_ref, FORM_UNICORN_VERTS, FORM_UNICORN_INDEXES);
	shapedb_read_tcvdata(&shape_varis, form_varis_tcv, form_varis_ref,
			FORM_VARIS_VERTS, FORM_VARIS_INDEXES);

#ifndef FLAG_NOSTDLIB
	// Ajastin
	//var_timer_skip = CITY_START/* + CITY_FOLD_1_END*/;
	//var_timer_skip = GITS_START;
	//var_timer_skip = FRACTAL_START;
	var_timer_skip = 0;
#endif

	var_timer = 0;

	// Musaa tuutista
	SDL_PauseAudio(0);

	// Loop
	while(loop)
	{
		//var_timer++;
		// Hae uusi aika
		//timer_get_ticks();

		// Pirrä vain jos tarpeen
#ifndef FLAG_NOSTDLIB
		if(lasttime - lastskip < var_timer)
		{
			lastskip = var_timer_skip;
			lasttime = var_timer + var_timer_skip;
#if 0 // For indent purposes.
		}
#endif
#else
		if(lasttime < var_timer)
		{
			lasttime = var_timer;
#endif

			// Useimmat haluavat että tausta nollataan, jos halutaan jotakin muuta,
			// niin erikseen ne.
			screen_clear(0);

			// Kelataan efut läpi
			for(i = 0; i < EFU_COUNT; i++)
			{
				EffectData *efu = var_efu + i;
				if((lasttime >= efu->start) && (lasttime < efu->end))
					efu->func(lasttime - efu->start);
			}

			// Flash before flipping.
			screen_flash(lasttime);

#ifdef RECORDING_MODE
			// If recording is on, screens must be saved here, before the flips.
			{
				uint8_t *pxdata =
					(uint8_t*)malloc(sizeof(uint8_t) * screen_w * screen_h * 3);
				glReadPixels(0, 0, screen_w, screen_h, GL_RGB, GL_UNSIGNED_BYTE,
						pxdata);
				char filename[8 + 5 + 4 + 1];
				sprintf(filename, "origami_%05i.raw", var_timer);
				FILE *filu = fopen(filename, "w");
				fwrite(pxdata, sizeof(uint8_t), screen_w * screen_h * 3, filu);
				fclose(filu);
				free(pxdata);
			}
#endif

			// Actual flip.
			SDL_GL_SwapBuffers();
		}

		// Kuuntele eventit
		if(SDL_PollEvent(&event))
		{
			if(event.type == SDL_QUIT)
				loop = 0;
			else if(event.type == SDL_KEYDOWN)
			{
				if(event.key.keysym.sym == SDLK_ESCAPE)
					loop = 0;
#ifndef FLAG_NOSTDLIB // De puk komentooerwweouew
				else if(debug_flag)
					switch(event.key.keysym.sym)
					{
						case SDLK_LEFT:
							var_timer_skip -= 600;
						case SDLK_RIGHT:
							var_timer_skip += 300;
							break;
						case SDLK_SPACE:
							printf("%i\n", var_timer + var_timer_skip);
							break;
						default:
							break;
					}
#endif
			}
		}

#ifdef RECORDING_MODE
		// If recording mode is on, advance with one tick at a time, this forces
		// the 1000 / 17 -framerate.
		++var_timer;
#endif

		// Pois jos aika loppu
#ifndef FLAG_NOSTDLIB
		if(var_timer + var_timer_skip >= TIME_END)
#else
			if(var_timer >= TIME_END)
#endif
				loop = 0;
	}

	// Pois
	SDL_Quit();
#ifndef FLAG_NOSTDLIB
	return 0;
#endif
}

//############################################################################
// Unused code ###############################################################
//############################################################################

/*void vecadd(float *dst, float *a, float *b)
	{
	dst[0] = a[0] + b[0];
	dst[1] = a[1] + b[1];
	dst[2] = a[2] + b[2];
	}*/

/*void comp_add(complex *dst, complex *comp1, complex *comp2)
	{
	dst->n = comp1->n + comp2->n;
	dst->i = comp1->i + comp2->i;
	}

	void comp_pow2(complex *dst, complex *comp)
	{
	dst->n = comp->n * comp->n - comp->i * comp->i;
	dst->i = comp->n * comp->i * 2.0f;
	}*/

/*void comp_sub(complex *dst, complex *comp1, complex *comp2)
	{
	dst->n = comp1->n - comp2->n;
	dst->i = comp1->i - comp2->i;
	}*/

/*void comp_flip(complex *dst, complex *comp)
	{
	result->n = comp->i;
	result->i = comp->n;
	}*/

/*void comp_mul(complex *dst, complex *comp1, complex *comp2)
	{
	dst->n = comp1->n * comp2->n - comp1->i * comp2->i;
	dst->i = comp1->n * comp2->i + comp2->n * comp1->i;
	}

	void comp_mulf(complex *dst, complex *comp, double multiplier) {
	dst->n = comp->n * multiplier;
	dst->i = comp->i * multiplier;
	}

	void comp_div(complex *dst, complex *comp1, complex *comp2) {
	complex z2, ret;
	z2.n = comp2->n;
	z2.i = -comp2->i;
	comp_mul(&ret, &comp1, &z2);
	comp_mulf(&ret, &ret, 1.0 / (comp2->n * comp2->n + comp2->i * comp2->i));
	}*/

/*Uint32 color_transfer_function(double color) {
	Uint32 result;
	result = (int)sin(color*2.2*M_PI+0.8)*0x80+0x80;
	result |= ((int)(sin(color*3*M_PI+0.4)*0x80+0x80))<<8;
	result |= ((int)(cos(color*4*M_PI+1.2)*0x80+0x80))<<16;
	return result;
	}*/

//############################################################################
// Unused models #############################################################
//############################################################################

/*
 * Varis.
 */
/*#define FORM_VARIS_VERTS	(2 * 3 + 2 + 10)
#define FORM_VARIS_INDEXES	((2 * 3 + 2 * 4 + 8) * 3)
Sint8 form_varis_tcv[] =
{
// vas siipi
-30, 0, 1, 1, 1, 3,
-18, 5, -10, 0, 2, 31,
-16, 5, 0, 0, 0, 31,
// oik siipi
30, 0, 1, 1, 1, 3,
18, 5, -10, 0, 2, 31,
16, 5, 0, 0, 0, 31,
// siipiväli
0, 0, -5, 2, 2, 3,
0, 0, 5, 2, 0, 3,
// ruho
0, 0, -15, 1, 1, 3,
-5, -5, -6, 0, 2, 31,
5, -5, -6, 2, 2, 31,
-5, -5, 6, 0, 0, 31,
5, -5, 4, 2, 0, 31,
0, 0, 12, 1, 1, 3,
-5, 5, -6, 2, 2, 31,
5, 5, -6, 0, 2, 31,
-5, 5, 6, 2, 0, 31,
5, 5, 6, 0, 0, 31
};
Uint8 form_varis_ref[] =
{
// siivet
0, 1, 2,
1, 6, 7,
1, 7, 2,
3, 5, 4,
4, 7, 6,
4, 5, 7,
// ruho etu
9, 14, 8,
14, 15, 8,
15, 10, 8,
10, 9, 8,
// ruho keski
9, 11, 16,
9, 16, 14,
14, 16, 17,
14, 17, 15,
15, 17, 12,
15, 12, 10,
10, 12, 11,
10, 11, 9,
// ruho taka
11, 13, 16,
16, 13, 17,
17, 13, 12,
12, 13, 11
};*/

//############################################################################
// Fraktaaliefu ##############################################################
//############################################################################

/*void efu_fractal(int freezetime)
	{
// Tyhjennys
//screen_clear(0);

// Säätö
camera_frustum(90.0f, 2000.0f);
glLoadIdentity();
look_at(lookat_fractal, freezetime);
blend_mode(1);
glDisable(GL_CULL_FACE);

// Näytä jotaan plz
//display_fractal(0);
flare_advance_frame();
flare_display(34); // Hyvä olla kirkas väri
}*/

//############################################################################
// Vanha fold_master #########################################################
//############################################################################

/*int folds, starttime, endtime, i, j, k;
	Sint16 foldguide[256];
	folds = guide[0];
	endtime=i=0;
	j=1;

//printf("\nAttempting to parse at frame %i", freezetime);
for(starttime=endtime, endtime=starttime + guide[j+1];
(endtime<freezetime)&&(i<folds);
j+=guide[j]*4+2,
starttime=endtime,
endtime=starttime + guide[j+1]) {
i++;
}
//printf("\nTimes %i -> %i, phase %i", starttime, endtime, i);

if(i!=folds) {
foldguide[0] = guide[j];
for(i=2; i<guide[j]*4+2; i++) {
foldguide[i-1] = guide[i+j];
//printf("\n Guideblock = %i", guide[i+j]);
}

//printf("\nExecuting fold_interpreter with amount %f", ((float)freezetime-(float)starttime)/((float)endtime-(float)starttime));
fold_guide_interpreter(dst, src, foldguide,
interpolate_count_se(freezetime, starttime, endtime));
}*/

//############################################################################
// Loppu #####################################################################
//############################################################################

