//############################################################################
// Definet ###################################################################
//############################################################################

// Ruutu
#define	SCREEN_W	800
#define	SCREEN_H	600
#define	SCREEN_B	32

//#define FLAG_FULLSCREEN
#define SDL_GFX_FLAGS	(SDL_HWSURFACE | SDL_OPENGL | SDL_DOUBLEBUF)
#ifdef FLAG_FULLSCREEN
#define SDL_GFX_FLAGS	(SDL_GFX_FLAGS | SDL_FULLSCREEN)
#endif

/*
 * Mahdolliset liput:
 * 
 * FLAG_NOSTDLIB
 */

//############################################################################
// Includet ##################################################################
//############################################################################

// Conffit
//#ifndef FLAG_NOSTDLIB
//#include <config.h>
//#endif

// Posix
#include <math.h>
#include <stdlib.h>

// Windows
//#ifdef WIN32
//#include "windows.h"
//#endif

// 3rd party
#include "SDL.h"
#include "GL/gl.h"
#include "GL/glu.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846f
#endif

/*
 * Konditionaalinen printf Tulostaa jotakin vain jos stdlib on mukana.
 */
//#ifndef FLAG_NOSTDLIB
//#define cond_printf(...) printf(__VA_ARGS__)
//#else
//#define cond_printf(...) ;
//#endif


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
  int radial, sector, dir, stime, etime;
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

//############################################################################
// Global variables for fun & profit #########################################
//############################################################################

#define TEXTURE_PLAYGROUND_SIZE	(128 * 128)

float origo[3] = { 0.0f, 0.0f, 0.0f },
      camera_position[6];
ShapeDB shape_use;
Uint32 texture_playground[TEXTURE_PLAYGROUND_SIZE];

//############################################################################
// Timer #####################################################################
//############################################################################

// Aika
#define TIMER_FPS	60
#define TIMER_MS	(Uint32)(1000.0f / (float)TIMER_FPS)
#define TIMER_MUL	((double)TIMER_FPS / 1000.0)

Uint32 var_timer_offset;
int var_timer_skip, var_timer;

/*Uint32 timer_func(Uint32 interval)
{
  var_timer++;
  return interval;
}*/

void timer_get_ticks()
{
  Uint32 ret = SDL_GetTicks() - var_timer_offset;
  var_timer = (int)((double)ret * TIMER_MUL) + var_timer_skip;
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
 * Memort clear.
 */
void memclr(void *op, size_t bytes)
{
  Uint32 *dst = (Uint32*)op;
  for(; bytes; bytes -= 4, dst++)
    *dst = 0;
}

/*
 * Memory copy.
 */
void memcpy32(void *dst, void *src, size_t bytes)
{
  Uint32 *dst32 = (Uint32*)dst,
	 *src32 = (Uint32*)src;
  for(; bytes; bytes -= 4, dst32++, src32++)
    *dst32 = *src32;
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
  dst[1] = -(a[0] * b[2] - b[0] * a[2]);
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
 * Laskee kahden vektorin summan kohteeseen.
 */
void vecadd(float *dst, float *a, float *b)
{
  dst[0] = a[0] + b[0];
  dst[1] = a[1] + b[1];
  dst[2] = a[2] + b[2];
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
  yr = -rotate_quardrant(dir[1], dxz);

  //printf("Rotation: %f, %f, %f\n", yr, xr, roll);

  glRotate3f(yr, xr, roll);
}

/*
 * Nappaa tekstuuri.
 */
void texture_create(int *bind, Uint32 *data, int w, int h)
{
  // Tekstuurit päälle ja generoidaan
  glEnable(GL_TEXTURE_2D);
  glGenTextures(1, bind);
  glBindTexture(GL_TEXTURE_2D, *bind);
  gluBuild2DMipmaps(GL_TEXTURE_2D, 4, w, h, GL_RGBA, GL_UNSIGNED_BYTE, data);
  // Jotta drawElements toimii oikein!
  (*bind)++;
}

/*
 * Tyhjennä tekstuuri ja palauta pointteri.
 */
Uint32* texture_clear()
{
  memclr(texture_playground, sizeof(Uint32) * TEXTURE_PLAYGROUND_SIZE);
  return texture_playground;
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
  gluPerspective(fov * (float)SCREEN_H / (float)SCREEN_W,
      (float)SCREEN_W / (float)SCREEN_H, 1.0, backclip);
  glMatrixMode(GL_MODELVIEW);
}

void camera_ortho(float fov)
{
  float ratio = (float)SCREEN_H / (float)SCREEN_W;
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

static Uint32 var_rand_seed = 93186752, var_rand_a = 1588635695,
	      var_rand_q = 2, var_rand_r = 1117695901;

// Initialize random number generator
void rand_seed(int op)
{
  var_rand_seed = op;
}

// Random natural number [0, param[
int rand_int(int op)
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
// Kontrolli #################################################################
//############################################################################

/*
 * Circles
 */
#define CIRCLES_START	0
#define PILLAR_START	3000
#define PILLAR_DUR	1900
#define WINGS_START	(PILLAR_START + 600)
#define WINGS_END	(WINGS_START + 1000)
#define PILLAR_END	(PILLAR_START + PILLAR_DUR)
#define ORITEXT_START	(PILLAR_END + 100)
#define CIRCLES_END	5300
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
  { 2200, { 10, 190, 40, 0, 20, 0 } },
  { 2400, { -5, 190, 30, 15, 20, -10 } },
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
#define CITY_HALT_1		600
#define CITY_TARGETING_1	650
#define CITY_HALT_2		6000
#define CITY_FOLD_1		800
#define CITY_FOLD_1_END		4000 //2000
#define CITY_HALT_1_DUR		(CITY_FOLD_1_END - CITY_HALT_1)
#define CITY_HALT_2_DUR		1000
#define CITY_END		(CITY_START + 5000)
LookAtUnit lookat_city[] = 
{
  { 0, { 7000, 15000, 7000, 7005, 100, 7000 }, },
  { 180, { 7000, 3000, 7000, 10000, 100, 7000 }, },
  { 300, { 7000, 2500, 7000, 8000, 1000, 10000 }, },
  { 400, { 8200, 1500, 9600, 9000, 2000, 10000 }, },
  { 700, { 8400, 2000, 9800, 9000, 2100, 10000 }, },
  { 800, { 12000, 1800, 10500, 14000, 500, 11500 }, },
  { 850, { 14000, 1800, 11500, 16000, 500, 20000 }, },
  { 950, { 15000, 1800, 14000, 20000, 500, 15500 }, },
  { 3000, { 27000, 7000, 27000, 28000, 20, 28000 } }
  /*{ 0, { 10000, 3500, 10000, 0, 100, 0 }, },
  { 480, { 18000, 3000, 7000, 1000, 90, 19000 } },
  { 880, { 24000, 4000, 24000, 11000, 90, 11000 } },
  { 1280, { 10000, 4000, 24000, 11000, 90, 11000 } },
  { 1680, { 18000, 3500, 7000, 10000, 2000, 24000 } },
  { 3000, { 17000, 7000, 17000, 14000, 20, 14000 } }*/
};

/*
 * GitS
 */
#define GITS_START	CITY_END
#define GITS_END	(GITS_START + 4700)
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
  { 3900, { 12000, 750, 700, 14000, 700, 750 } },
  { 4700, { -1020, 750, 7000, -1010, 750, -1000 } }
};

/*
 * Fold
 */
#define FOLD_START	GITS_END
#define FOLD_END	(FOLD_START+3000)

LookAtUnit lookat_fold[] = {
  { 0, { 2, 1, 2, 0, 0, 0 } },
  { 500, { 2, 1, -2, 0, 0, 0 } },
  { 1000, { -2, 1, -2, 0, 0, 0 } },
  { 1500, { -2, 1, 2, 0, 0, 0 } },
  { 2000, { 2, 1, 2, 0, 0, 0 } }
};

// Poronkusema
#define MAX_EFFECT_TIME	15000
#define TIME_END	FOLD_END

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

#define COLORDB_SIZE	150
#define COLORDB_FLASH	39
#define COLORDB_FREE	40

ColorUnit var_colordb[COLORDB_SIZE] =
{
  { { 0.0f, 0.0f, 0.0f, 0.0f }, 0x00000000 }, // 00 = musta
  { { 0.0f, 0.0f, 0.0f, 0.0f }, 0x00003248 }, // 01 = gits-tausta
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
  { { 0.0f, 0.0f, 0.0f, 0.0f }, 0x00A08080 }, // 13 = city-taivas
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
  { { 0.0f, 0.0f, 0.0f, 0.0f }, 0xA02070FF }  // 29 = targetointi
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
  memcpy32(dst->data, src->data, src->ins_vertex * sizeof(ShapeUnit));
  memcpy32(dst->index, src->index, src->ins_index * sizeof(Uint16));
}

/*
 * Functions to select the array pointers in databases.
 */
void shapedb_draw_elements(ShapeDB *op, int t, int element)
{
  // Specify the interleaevd array
  glInterleavedArrays(GL_T2F_C4UB_V3F, 0, op->data);

  // Tekstuuri päälle / pois
  if(t != 0)
  {
    if(t > 0)
    {
      glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
      glBindTexture(GL_TEXTURE_2D, t - 1);
    }
    else
    {
      glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
      glBindTexture(GL_TEXTURE_2D, -1 * t - 1);
    }
    glEnable(GL_TEXTURE_2D);
    //glDisableClientState(GL_COLOR_ARRAY);
  }
  else
  {
    glDisable(GL_TEXTURE_2D);
  }

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
 * Add a vertex that is an interpolation between two other vertices.
 */
void shapedb_interpolate_v(ShapeDB *op, int from, int to, float pos,
    Uint32 col)
{
  ShapeUnit *dst = op->data + (op->ins_vertex++);
  // Interpoloi
  interpolate_linear_ff(dst->ver, op->data[from].ver, op->data[to].ver, pos,
      3);
  // Color
  dst->col = colordb_get_uint(col);
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
  memcpy32(dst, op->data[idx].ver, 3 * sizeof(float));
}

/*
 * Korvaa tietty verteksi flotaridatalla, joka annetaan.
 */
void shapedb_replace_vertex(ShapeDB *op, int idx, float *ver)
{
  memcpy32(op->data[idx].ver, ver, 3 * sizeof(float));
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

//############################################################################
// Muodot ####################################################################
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
ShapeDB shape_flare;

/*
 * Simple plane
 */
#define ZBUFCONSTANT 0.01
#define SQRT2 1.41421356237310
#define FORM_SIMPLEPLANE_VERTS	20
#define FORM_SIMPLEPLANE_INDEXES (12 * 4)
#define SIMPLEPLANE_COLOR_1 26
#define SIMPLEPLANE_COLOR_2 25
float form_simpleplane_tcv[] =
{
  0.0, 0.0, 0.0, SIMPLEPLANE_COLOR_1,
  -(float)(SQRT2*0.5), 0.0, 0.0, SIMPLEPLANE_COLOR_2,
  -(float)(SQRT2*0.5), 0.0, (float)(SQRT2*(1.0/14.0)), SIMPLEPLANE_COLOR_2,
  -(float)(SQRT2*0.5), 0.0, (float)(SQRT2*0.5), SIMPLEPLANE_COLOR_1,
  -(float)(SQRT2*0.5), 0.0, 1.0, SIMPLEPLANE_COLOR_1,
  -(float)(SQRT2*(1.0/14.0)), 0, 1.0, SIMPLEPLANE_COLOR_1,
  -(float)(SQRT2*(1.0/14.0)), 0.0, (float)(SQRT2*(1.0/14.0)), SIMPLEPLANE_COLOR_1,
  (float)(SQRT2*(1.0/14.0)), 0.0, (float)(SQRT2*(1.0/14.0)), SIMPLEPLANE_COLOR_1,
  (float)(SQRT2*(1.0/14.0)), 0.0, 1.0, SIMPLEPLANE_COLOR_1,
  (float)(SQRT2*0.5), 0.0, 0.0, SIMPLEPLANE_COLOR_2,
  (float)(SQRT2*0.5), 0.0, (float)(SQRT2*(1.0/14.0)), SIMPLEPLANE_COLOR_2,
  (float)(SQRT2*0.5), 0.0, (float)(SQRT2*0.5), SIMPLEPLANE_COLOR_1,
  (float)(SQRT2*0.5), 0.0, 1.0, SIMPLEPLANE_COLOR_1,
  0.0, 0.0, 1.0, SIMPLEPLANE_COLOR_1,
	-(float)ZBUFCONSTANT, 0.0, 0.0, 9,
	-(float)(SQRT2*0.5), 0.0, (float)(SQRT2*0.5)-(float)ZBUFCONSTANT, 9,
	(float)ZBUFCONSTANT, 0.0, 0.0, 9,
	(float)(SQRT2*0.5), 0.0, (float)(SQRT2*0.5)-(float)ZBUFCONSTANT, 9,
	-(float)(SQRT2*(1.0/14.0))-(float)ZBUFCONSTANT, 0.0, (float)(SQRT2*(1.0/14.0)), 9,
	(float)(SQRT2*(1.0/14.0))+(float)ZBUFCONSTANT, 0.0, (float)(SQRT2*(1.0/14.0)), 9
};
Uint16 form_simpleplane_ref[] =
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
#define CONSTANT_1 0.14644660940673 //(sqrt(2-sqrt(2))*sqrt(5/2-sqrt(2)*7/4))/(2*(sqrt(2)-1))
#define CONSTANT_2 0.35355339059327 //(1/4)*sqrt(2+sqrt(2))*sqrt(2-sqrt(2))
#define CONSTANT_3 0.09763107293782 //(sqrt(2)*sin((22.5/180)*pi))/(6*sin((112.5/180)*pi))
#define FORM_SWAN_VERTS	35
#define FORM_SWAN_INDEXES	(32 * 4)
#define SWAN_COLOR_1 26
#define SWAN_COLOR_2 25
float form_swan_tcv[] =
{
  0, 0, 0, SWAN_COLOR_1,
  1, 0, 1, SWAN_COLOR_2,
  1, 0, -1, 9,
  -1, 0, -1, SWAN_COLOR_1,
  -1, 0, 1, SWAN_COLOR_2,
  0, 0, 1, 9,
  1, 0, 0, SWAN_COLOR_1,
  0, 0, -1, SWAN_COLOR_2,
  -1, 0, 0, 9,
  0, 0, (float)(2.0-SQRT2), SWAN_COLOR_1,
  (float)(2.0-SQRT2), 0, 0, SWAN_COLOR_2,
  0, 0, -(float)(2.0-SQRT2), 9,
  -(float)(2.0-SQRT2), 0, 0, SWAN_COLOR_1,
  (float)(1.0-1.0/SQRT2), 0, (float)(1.0-1.0/SQRT2), SWAN_COLOR_2,
  (float)(1.0-1.0/SQRT2), 0, -(float)(1.0-1.0/SQRT2), 9,
  -(float)(1.0-1.0/SQRT2), 0, -(float)(1.0-1.0/SQRT2), SWAN_COLOR_1,
  -(float)(1.0-1.0/SQRT2), 0, (float)(1.0-1.0/SQRT2), SWAN_COLOR_2,
  (float)(CONSTANT_1), 0, (float)(1.0-CONSTANT_2), 9,
  (float)(1.0-CONSTANT_2), 0, (float)(CONSTANT_1), SWAN_COLOR_1,
  -(float)(CONSTANT_1), 0, -(float)(1.0-CONSTANT_2), SWAN_COLOR_2,
  -(float)(1.0-CONSTANT_2), 0, -(float)(CONSTANT_1), 9,
  (float)(5.0/6.0), 0, (float)(5.0/6.0), SWAN_COLOR_1,
  (float)(5.0/6.0), 0, (float)(5.0/6.0 + CONSTANT_3), SWAN_COLOR_2,
  (float)(5.0/6.0 + CONSTANT_3), 0, (float)(5.0/6.0), 9,
  (float)(1.0-SQRT2*(1.0/6.0)), 0, 1, SWAN_COLOR_1,
  1, 0, (float)(1.0-SQRT2*(1.0/6.0)), SWAN_COLOR_2,
	-1, 0, (float)(2.0-SQRT2), SWAN_COLOR_1,
	-(float)(2.0-SQRT2), 0, 1, SWAN_COLOR_1,
	1, 0, -(float)(2.0-SQRT2), SWAN_COLOR_1,
	(float)(2.0-SQRT2), 0, -1, SWAN_COLOR_1,
	-(float)0.36243686707645, (float)0.05177669529664, (float)0.08210678118655, SWAN_COLOR_1,
	(float)0.08210678118655, (float)0.05177669529664, -(float)0.36243686707645, SWAN_COLOR_1,
	-(float)0.08210678118655, (float)0.05177669529664, (float)0.36243686707645, SWAN_COLOR_1,
	(float)0.36243686707645, (float)0.05177669529664, -(float)0.08210678118655, SWAN_COLOR_1,
	(float)(1.0 + 5.0/6.0), 0, -(float)(1.0/6.0), SWAN_COLOR_1
};
//huomaa että 8 viimeistä olivat apupisteitä - niiden kautta ei piirretä mitään
Uint16 form_swan_ref[] =
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
#define CROW_COLOR_1 26
#define CROW_COLOR_2 25
float form_crow_tcv[] =
{
  0, 0, 0, CROW_COLOR_1,
  1, 0, 1, CROW_COLOR_2,
  1, 0, -1, 9,
  -1, 0, -1, CROW_COLOR_1,
  -1, 0, 1, CROW_COLOR_2,
  0, 0, 1, 9,
  1, 0, 0, CROW_COLOR_1,
  0, 0, -1, CROW_COLOR_2,
  -1, 0, 0, 9,
  (float)(1.0/2.0), 0, 1, CROW_COLOR_1,
  1, 0, (float)(1.0/2.0), CROW_COLOR_2,
  1, 0, -(float)(1.0/2.0), 9,
  (float)(1.0/2.0), 0, -1, CROW_COLOR_1,
  -(float)(1.0/2.0), 0, -1, CROW_COLOR_2,
  -1, 0, -(float)(1.0/2.0), 9,
  -1, 0, (float)(1.0/2.0), CROW_COLOR_1,
  -(float)(1.0/2.0), 0, 1, CROW_COLOR_2,
  0, 0, (float)(1.0/2.0), 9,
  (float)(1.0/2.0), 0, (float)(1.0/2.0), CROW_COLOR_1,
  (float)(1.0/2.0), 0, 0, CROW_COLOR_2,
  (float)(1.0/2.0), 0, -(float)(1.0/2.0), 9,
  0, 0, -(float)(1.0/2.0), CROW_COLOR_1,
  -(float)(1.0/2.0), 0, -(float)(1.0/2.0), CROW_COLOR_2,
  -(float)(1.0/2.0), 0, 0, 9,
  -(float)(1.0/2.0), 0, (float)(1.0/2.0), CROW_COLOR_1,
  -(float)(3.0/2.0), 0, -(float)(1.0/2.0), CROW_COLOR_2
};
  // viimeinen on apupiste
Uint16 form_crow_ref[] =
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
 * Crane
 */
#define FORM_CRANE_VERTS	25
#define FORM_CRANE_INDEXES	(36 * 3)
Sint8 form_crane_tcv[] =
{
  -4, 0, -10,	0, 2, 3,
  4, 0, -10,	2, 2, 3,
  -6, 0, 10,	0, 0, 3,
  6, 0, 10,	2, 0, 3,
  0, 4, 0,	1, 1, 3,
  -8, 8, -10,	2, 2, 3,
  8, 8, -10,	0, 2, 3,
  -8, 9, 0,	1, 1, 3,
  8, 9, 0,	1, 1, 3,
  -8, 8, 10,	2, 0, 3,
  8, 8, 10,	0, 0, 3,
  -16, 16, -12,	0, 2, 3,
  0, 12, -8,	1, 2, 3,
  16, 16, -12,	2, 2, 3,
  0, 12, 0,	1, 1, 3,
  -16, 16, 11,	0, 2, 3,
  0, 12, 10,	1, 0, 3,
  16, 16, 11,	0, 2, 3,
  0, 22, -30,	2, 2, 3
  -3, 28, -26,	0, 0, 3,
  3, 28, -26,	2, 0, 3,
  0, 29, -24,	1, 1, 3,
  -22, 28, 0,	1, 1, 3,
  22, 28, 0,	1, 1, 3,
  0, 30, 20,	1, 1, 3
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
  21, 4, 0,
  1, 20, 21,
  21, 4, 1,
  20, 21, 18,
  19, 21, 18,
  // pyrstö
  2, 24, 4,
  3, 24, 4
};
ShapeDB shape_crane;

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
ShapeDB shape_tachikoma;

/*
 * Flash
 */
#define FORM_FLASH_VERTS	4
#define FORM_FLASH_INDEXES	4
Sint8 form_flash_cv[] =
{
  -1, -1, 0, COLORDB_FLASH,
  1, -1, 0, COLORDB_FLASH,
  1, 1, 0, COLORDB_FLASH,
  -1, 1, 0, COLORDB_FLASH
};
Uint8 form_flash_ref[] =
{
  0, 1, 2, 3
};

/*
 * Varis tai lokki tai whateva.
 */
#define FORM_VARIS_VERTS	4
#define FORM_VARIS_INDEXES	4
//Sint8

/*
 * Lentsikka.
 */
#define TRAIL_PLANE_LEN		8
PathPacked trail_plane[] =
{
  { { -2000, 0, -2000 }, { 0, 0, 0 }, 0 },
  { { 11800, 3000, 12000 }, { 7, 0, 6 }, 10 },
  { { 13500, 3000, 14500 }, { 1, 0, 1 }, 50 },
  { { 20000, 0, 20000 }, { 1, 0, 4 }, 0 },
  { { -10000, 0, 0 }, { 0, 0, 0 }, 0 },
  { { -10000, 0, 0 }, { 0, 0, 0 }, 0 },
};
PathDB path_plane;

//############################################################################
// Väläytykset ###############################################################
//############################################################################

#define FLASH_COUNT	3

// Väläykset
Uint16 var_flash[] =
{
  WINGS_END, 110, 2, 0,
  CITY_START + CITY_HALT_1, 200, 2, 0,
  CITY_START + CITY_FOLD_1_END, 100, 2, 0
};

/*
 * Väläytä ruutu.
 */
void screen_flash()
{
  int i, freezetime = var_timer;
  Uint16 *flash;
  float pos;

  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
  
  for(i = 0; i < FLASH_COUNT; i++)
  {
    flash = var_flash + i * 4;
    if((freezetime >= *flash) && (freezetime < *flash + *(flash + 1)))
    {
      // Laske vaihe
      pos = interpolate_count_lt(freezetime, *flash, *(flash + 1));
      // Interpoloi
      interpolate_linear_ff(colordb_get_float(COLORDB_FLASH),
	  colordb_get_float(*(flash + 2)), colordb_get_float(*(flash + 3)),
	  pos, 3);
      // Syötä väriksi
      colordb_convert_f2u(COLORDB_FLASH);
      // Tila, kamera ja tyhjennys
      camera_ortho(1.0f);
      glLoadIdentity();
      blend_mode(0);
      shapedb_clear(&shape_use);
      shapedb_read_cvdata(&shape_use, form_flash_cv, form_flash_ref, 4, 4);
      shapedb_draw_elements(&shape_use, 0, GL_QUADS);
      return;
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

//############################################################################
// Textout ###################################################################
//############################################################################

// Fontti
Char2D var_characters[50] =
{
  { { 12, 103, 18, -1, 46, 50, -1, -1, -1, -1 } }, // A
  { { 100, 12, -1, 101, 82, 68, -1, 57, 38, 13 } }, // B
  { { 84, 104, 102, 78, 34, 14, 16, 40, -1, -1 } }, // C
  { { 100, 12, -1, 101, 60, 13, -1, -1, -1, -1 } }, // D
  { { 57, 59, 83, 103, 101, 89, 34, 14, 16, 28 } }, // E
  { { 100, 12, -1, 101, 104, -1, 57, 60, -1, -1 } }, // F
  { { 84, 104, 102, 78, 34, 14, 16, 40, 51, 49 } }, // G
  { { 100, 12, -1, 105, 17, -1, 57, 60, -1, -1 } }, // H
  { { 100, 102, -1, 90, 24, -1, 12, 14, -1, -1 } }, // I
  { { 103, 105, -1, 93, 38, 14, 34, -1, -1, -1 } }, // J
  { { 100, 12, -1, 57, 82, -1, 46, 16, -1, -1 } }, // K
  { { 100, 102, -1, 90, 24, -1, 12, 16, 27, -1 } }, // L
  { { 12, 100, 70, 106, 18, -1, -1, -1, -1, -1 } }, // M
  { { 12, 100, 17, 105, -1, -1, -1, -1, -1, -1 } }, // N
  { { 14, 34, 78, 102, 104, 84, 40, 16, 14, -1 } }, // O
  { { 100, 12, -1, 101, 82, 57, -1, -1, -1, -1 } }, // P
  { { 103, 67, 70, -1, 104, 16, -1, 37, 39, -1 } }, // Q
  { { 12, 100, 83, 57, 17, -1, -1, -1, -1, -1 } }, // R
  { { 83, 102, 78, 39, 15, 34, -1, -1, -1, -1 } }, // S
  { { 100, 105, -1, 91, 14, -1, -1, -1, -1, -1 } }, // T
  { { 100, 34, 13, 15, 38, 104, -1, -1, -1, -1 } }, // U
  { { 100, 15, 106, -1, -1, -1, -1, -1, -1, -1 } }, // V
  { { 100, 13, 37, 17, 106, -1, -1, -1, -1, -1 } }, // W
};

// Stringit
char string_gfxcode[14] = { 7, 18, 1, 16, 8, 9, 3, 19, 24, 3, 15, 4, 5, 0 };
char string_muscode[11] = { 13, 21, 19, 9, 3, 24, 3, 15, 4, 5, 0 };
char string_other[11] = { 15, 20, 8, 5, 18, 24, 3, 15, 4, 5, 0 };
char string_greets[7] = { 7, 18, 5, 5, 20, 19, 0 };
char string_juippi[7] = { 10, 21, 9, 16, 16, 9, 0 };
char string_trilkk[7] = { 20, 18, 9, 12, 11, 11, 0 };
char string_warma[6] = { 23, 1, 18, 13, 1, 0 };
char string_vv[3] = { 22, 22, 0 };

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

  shapedb_draw_elements(&shape_use, 0, GL_LINES);
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
    if(*op == 24) // space
      x += scalex;
    else
      x += text_draw_char(*op, &pos, x, y, scalex, scaley, col);
    op++;
  }
}

/*
 * Monimutkainen textout-utilisaatio.
 */
void textout_complex(char *string, int start, int end, int freeze, int appear,
    float speed, float x, float y1, float y2, float scale, int col)
{
  float base, offset, scalepad;
  // Jos ollaan ulkopuolella altogether
  if((freeze <= start) || (freeze >= end))
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
  if(freeze - start < appear)
    offset *= interpolate_count_lt(freeze, start, appear);
  else if(end - freeze < appear)
    offset *= interpolate_count_lt(end, freeze, appear);

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
  shapedb_draw_elements(&shape_use, 0, GL_QUADS);

  scalepad = scale / 5.0f;
  text_draw_string(string,
      (x > 0) ? (-1.0f + scalepad - x + offset) : (1.0f + offset + scalepad),
      y1 + scalepad, scale, scale, col, (freeze - start - appear) * speed);
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
  shapedb_draw_elements(&shape_use, 0, GL_TRIANGLE_STRIP);
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
ShapeDB shape_pillar_draw, shape_pillar_wings;
LightPillarParams pillar_draw = { 300.0f, 2.0f, 5.0f, 90, 5, 4 };
LightPillarParams pillar_wings = { 400.0f, 16.0f, 100.0f, 300, 2, 5 };

// Paskat muistista, generoidaan yksi joka framelle!
float var_pillar_shard[MAX_EFFECT_TIME * TIMER_MS];

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
    interpolate_linear_ff(colordb_get_float(var_colordb_free),
	colordb_get_float(0), colordb_get_float(params->col), brightness_mul,3);
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
	    dx = (float)cos(ang) * rad,
	    dz = (float)sin(ang) * rad;
      // Piirrä matriisitempuilla
      glPushMatrix();
      glTranslatef(dx + pos[0], pos[1], dz + pos[2]);
      glRotate3f(0.0f, ang / M_PI * -180.0f, 0.0f);
      glScalef(params->width, (1.0f - mul) * params->height, params->width);
      shapedb_draw_elements(shape, 0, GL_QUADS);
      glPopMatrix();
    }
}

//############################################################################
// Ympyrät ###################################################################
//############################################################################

#define CIRCLES_RADIALS		13
#define CIRCLES_SECTORS		48
#define CIRCLES_RADIUS		10.0f
#define CIRCLES_HEIGHT_BASE	60.0f
#define CIRCLES_HEIGHT_VAR	40.0f
#define CIRCLES_HEIGHT_SPEED	1.0f
#define CIRCLES_SPEED		20
#define CIRCLES_RUNNER_MAX	100
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
char var_circles[CIRCLES_RADIALS * CIRCLES_SECTORS];
ShapeDB shape_circles;
CirclesRunner var_runner[CIRCLES_RUNNER_MAX];

/*
 * Generate one runner to draw the circle.
 */
void efu_circles_create_runner(unsigned radial, unsigned sector, unsigned dir,
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

  //cond_printf("No room!\n");
}

/*
 * True/false for the direction to be unblocked.
 */
int efu_circles_dir_ok(int idx)
{
  if((idx >= 0) && (idx < CIRCLES_SECTORS * CIRCLES_RADIALS))
    if(var_circles[idx] == 0)
      return 1;
  return 0;
}

/*
 * Calculate the index in the circle array of a given coordinate.
 */
int efu_circles_idx(int radial, int sector)
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
void efu_circles_expire_runner(CirclesRunner *op, int left, int freezetime)
{
  // If we're not in the end, let's quit
  if(left > CIRCLES_SPEED)
    return;
  // Otherwise try to expire
  efu_light_pillar(shapedb_get_vertex(&shape_circles,
	(op->radial * CIRCLES_SECTORS + op->sector) * 2), op->stime,
      op->etime, freezetime, &shape_pillar_draw, &pillar_draw);
}

/*
 * Draw a runner. Make some polygons while at it.
 */
void efu_circles_runner(CirclesRunner* op, int left, int elapsed,
    int freezetime)
{
  int dir[4],i,curr,next;
  // Jos ei mitään niin ei tehdä
  if(op->dir == 0)
    return;
  // Jos enää pelkkä pilari
  else if(op->dir == -1)
  {
    efu_circles_expire_runner(op, left, freezetime);
    return;    
  }

  // Muutoin voidaan jatkaa
  dir[0] = efu_circles_idx(op->radial, op->sector - 1);
  dir[1] = efu_circles_idx(op->radial, op->sector + 1);
  dir[2] = efu_circles_idx(op->radial - 1, op->sector);
  dir[3] = efu_circles_idx(op->radial + 1, op->sector);

  // Jos kohde ei ole ok, vaihda suuntaa
  if(efu_circles_dir_ok(dir[op->dir - 1]) == 0)
  {
    // Aseta päätös ja ajankohta
    op->dir = -1;
    op->etime = elapsed;
    // Anna uusi mahdollisuus vaihtaa suuntaa 5 kertaa
    i = 6;
    do
    {
      int j = rand_int(4);
      if(efu_circles_dir_ok(dir[j]))
      {
	op->dir = j + 1;
	break;
      }
    } while(--i);
  }
  // Jos kaikki vieläkin pielessä
  if(op->dir <= 0)
  {
    efu_circles_expire_runner(op, left, freezetime);
    return;
  }

  // Valitaan ja tehdään neliö
  curr = (op->radial * CIRCLES_SECTORS + op->sector) * 2;
  next = dir[op->dir - 1];
  // Kohde on käytetty
  var_circles[next] = 1;
  next *= 2;

  // Insertoi
  shapedb_add_index(&shape_circles, curr);
  shapedb_add_index(&shape_circles, curr + 1);
  // Haku
  if(left > CIRCLES_SPEED)
  {
    shapedb_add_index(&shape_circles, next + 1);
    shapedb_add_index(&shape_circles, next);
  }
  // Interpoloi
  else
  {
    float len = (float)left / (float)CIRCLES_SPEED;
    shapedb_interpolate_v(&shape_circles, curr, next, len, 6);
    shapedb_interpolate_v(&shape_circles, curr + 1, next + 1, len, 7);
    shapedb_add_index_neg(&shape_circles, 1);
    shapedb_add_index_neg(&shape_circles, 2);
    efu_light_pillar(shapedb_get_vertex(&shape_circles,
	  shape_circles.ins_vertex - 2), op->stime, MAX_EFFECT_TIME,
	freezetime, &shape_pillar_draw, &pillar_draw);
  }

  // Jakaudu
  if(!rand_int(CIRCLESRUNNER_DIVIDE))
    efu_circles_create_runner(op->radial, op->sector, rand_int(4) + 1,
	elapsed);

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
    case CIRCLES_OUT:
      op->radial++;
      break;
  }

  // Vaihda suuntaa
  if(!rand_int(CIRCLESRUNNER_NCHANGE) ||
      ((op->dir >= CIRCLES_IN) && rand_int(2)))
    op->dir = rand_int(4) + 1;
}

/*
 * Ympyräefun ylihommeli.
 */
void efu_circles(int freezetime)
{
  int i, j, k;

  // Tyhjennys ja random
  blend_mode(0);
  screen_clear(0);
  camera_frustum(90.0f, 2000.0f);
  glLoadIdentity();
  look_at(lookat_circles, freezetime);
  rand_seed(0x01);

  // Clear the shape
  shapedb_clear(&shape_circles);

  // Generate the vertices
  for(i = 0; i < CIRCLES_RADIALS; i++)
    for(j = 0; j < CIRCLES_SECTORS; j++)
    {
      float ang = (float)j / (float)CIRCLES_SECTORS * M_PI * 2;
      float rad = (i + 1) * CIRCLES_RADIUS;
      // Korkeus on monimutk.
      float height = interpolate_sine(CIRCLES_HEIGHT_BASE / 2.0f,
	CIRCLES_HEIGHT_VAR / 2.0f, (float)j + (float)freezetime / 100.0f,
	CIRCLES_HEIGHT_SPEED) + interpolate_sine(CIRCLES_HEIGHT_BASE / 2.0f,
	  CIRCLES_HEIGHT_VAR / 2.0f,
	  (float)j * 1.5f + (float)freezetime / 15.0f, -CIRCLES_HEIGHT_SPEED);
      // Add
      shapedb_add_cv(&shape_circles, (float)cos(ang) * rad, 0.0f, (float)sin(ang) * rad, 6);
      shapedb_add_cv(&shape_circles, (float)cos(ang) * rad, height, (float)sin(ang) * rad,
	  7);
    }

  // Piirretään
  memclr(var_circles, CIRCLES_RADIALS * CIRCLES_SECTORS);
  var_circles[0] = 1;
  memclr(var_runner, CIRCLES_RUNNER_MAX * sizeof(CirclesRunner));
  efu_circles_create_runner(CIRCLES_RADIALS - 1, 0, CIRCLES_CCW, CIRCLES_START);
  for(i = freezetime, j = CIRCLES_START; i > 0;
      i -= CIRCLES_SPEED, j += CIRCLES_SPEED)
    for(k = 0; k < CIRCLES_RUNNER_MAX; k++)
      efu_circles_runner(&var_runner[k], i, j, freezetime);

  shapedb_draw_elements(&shape_circles, 0, GL_QUADS);
}

/*
 * Ympyräefun pilarihommeli.
 */
void efu_pillar(int freezetime)
{
  efu_light_pillar(origo, 0, PILLAR_DUR, freezetime,
      &shape_pillar_wings, &pillar_wings);
}

/*
 * Ympyräefun teksti.
 */
void efu_oritext(int freezetime)
{
  char string[4] = { 1, 2, 3, 0 };
  camera_ortho(1.0f);
  glLoadIdentity();
  text_draw_string(string, -0.9f, 0.3f, 0.3f, 0.3f, 2, freezetime * 0.01f);
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
    shapedb_draw_elements(&shape_flare, 0, GL_TRIANGLES);
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
int linetexture1_bind, linetexture2_bind, linetexture3_bind;
ShapeDB shape_line_circle;

/*
 * Generate the texture.
 */
void generate_line_texture(int *bind, int col_op)
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
  texture_create(bind, texture_playground, LINETEXTURE_W, LINETEXTURE_H);
}

/*
 * Generate line with a line texture from point a to point b.
 */
float efu_line_line(ShapeDB *shp, float start, float end, float other1,
    float other2, float radius, float texpos, float texwrap, int axis)
{
  float pos[3],ang,ca,sa,texend;
	int ax1,ax2,idx;
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
  shapedb_draw_elements(&shape_line_circle, texture, GL_TRIANGLE_STRIP);
  glPopMatrix();
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
#define GITS_PATH_LINES		7
#define GITS_SPHERERAD		125.0f
#define GITS_BACKCLIP		5000.0f
#define GITS_HAERPAKE_COUNT	12
#define GITS_HAERPAKE_SCALEINC	(1.0f / (float)GITS_HAERPAKE_COUNT)


// Taulukko sphereille
GitsSphere var_gits_spheres[GITS_SPHERES];
PathDB var_gits_paths[GITS_SPHERES * GITS_LINKSPER];
ShapeDB shape_gits_paths, shape_gits_grid;
int var_gits_path_start[MAX_EFFECT_TIME];
int var_gits_pathcount;

/*
 * Varmistaa ettei jossakin spheressä ole yhteyttä johonkin toiseen.
 */
int sphere_has_no_conn(GitsSphere *op, int conn)
{
  int i = GITS_LINKSPER - 1;
  do
  {
    if(op->connections[i] == conn)
      return 0;
  } while(i--);
  return 1;
}

/*
 * Generoi polku kahden pisteen välille.
 */
void generate_gits_path(GitsSphere *src, GitsSphere *dst, PathDB *pth)
{
  float pos[3], diff;
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
    diff = (float)((double)dst->pos[crd] - (double)pos[crd]);

    if(diff != 0.0f)
    {
      //diff = dst->pos[crd] - pos[crd];
      // Jos ollaan liian kaukana niin mennään randomilla
      if(vecdist(pos, dst->pos) > sqrt(GITS_PATH_MAX * GITS_PATH_MAX * 3.0f))
	diff = (rand_float(GITS_PATH_RAND) + GITS_PATH_BASE) *
	  ((diff < 0.0f) ? -1.0f : 1.0f);
      
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
 * Generoi yhteydet renkaitten välille.
 */
void generate_gits_connections()
{
  int i, j, k, closestidx;
  float newdist, xpos, yzpos, yzpos2, boundmin, boundmax, closest;
  GitsSphere *sph, *tgt;

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

#define GITSTEXT_APPEAR		50
#define GITSTEXT_DURATION	400
#define GITSTEXT_SPEED		0.55f
#define GITSTEXT_SCALE		0.1f
#define GITSTEXT_HEIGHT		0.14f
#define GITSTEXT_RANGE		0.65f

/*
 * Näyttää textoutit / krediitit.
 */
void efu_gits_text(char *str, int stime, float size, int freezetime)
{
  float y1 = rand_float(GITSTEXT_RANGE * 2.0f - GITSTEXT_HEIGHT) -
    GITSTEXT_RANGE;
  // Vaihto jos tarpeen
  if(rand_int(2))
    size = -size;
  // Paikka
  textout_complex(str, stime, stime + GITSTEXT_DURATION, freezetime,
      GITSTEXT_APPEAR, GITSTEXT_SPEED, size, y1, y1 + GITSTEXT_HEIGHT,
      GITSTEXT_SCALE, 3);
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
      efu_line_circle(sph->pos, linetexture1_bind,
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
      shapedb_draw_elements(&shape_gits_grid, linetexture2_bind, GL_QUADS);
      glPopMatrix();
    }
    gridcrd += GITS_TEXWRAP;
  } while(gridcrd < 2.0f * GITS_BOUND_X);

  // Paths
  shapedb_draw_elements(&shape_gits_paths, linetexture3_bind, GL_QUADS);

  // Return to normal matrix mode
  glMatrixMode(GL_TEXTURE);
  glPopMatrix();
  glMatrixMode(GL_MODELVIEW);

  // Piirrä kaikki härpäkkeet
  for(i = 0; i < freezetime; i+= 10)
    efu_gits_path_haerpake(var_gits_paths + var_gits_path_start[i], i,
	freezetime, 5.0f);

  // Kaikki teksti
  rand_seed(2);
  efu_gits_text(string_gfxcode, 300, 1.3f, freezetime);
  rand_seed(3);
  efu_gits_text(string_trilkk, 380, 0.7f, freezetime);
  rand_seed(4);
  efu_gits_text(string_muscode, 600, 1.1f, freezetime);
  rand_seed(5);
  efu_gits_text(string_juippi, 680, 0.7f, freezetime);
  rand_seed(6);
  efu_gits_text(string_other, 900, 1.2f, freezetime);
  rand_seed(7);
  efu_gits_text(string_warma, 980, 0.6f, freezetime);
  rand_seed(8);
  efu_gits_text(string_greets, 1200, 0.6f, freezetime);
  rand_seed(9);
  efu_gits_text(string_vv, 1280, 0.4f, freezetime);
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
#define CITY_RUUTUTEX_W		128
#define CITY_RUUTUTEX_H		128
#define CITY_RUUTUTEX_BORDER	24
#define CITY_RUUTUTEX_FILL	0
#define CITY_TREELINE		0.6f
#define CITY_TERRAIN_LOTOL	0.14f
#define CITY_TERRAIN_HITOL	0.45f
#define CITY_TERRAIN_PEAKTOL	0.85f
#define CITY_MORMOKKI_COUNT	100
#define CITY_MORMOKKI_PATHLEN	50
#define CITY_MORMOKKI_TRY	10
#define CITY_MORMOKKI_WAITTIME	((int)(1.0f / 0.005f))
#define CITY_MORMOKKI_WAITBIG	(CITY_MORMOKKI_WAITTIME / 4)
#define CITY_MORMOKKI_WAITSML	(CITY_MORMOKKI_WAITTIME / 8)
#define CITY_MORMOKKI_FRAC	0.25f
#define CITY_MOERMOKKI_HOPHT	50.0f
#define CITY_MOERMOKKI_SCALE	3.0f

// Kaikki kaupungin data
float var_city_terraincontrol[CITY_CONTROL_SIZE * CITY_CONTROL_SIZE];
float var_city_terrain[CITY_SIZE * CITY_SIZE];
int var_city_cityarea[CITY_DETAIL * CITY_DETAIL],
    var_city_done[CITY_DETAIL * CITY_DETAIL],
    var_city_lists, tex_ruutu_bind_1, tex_ruutu_bind_2, tex_crane_bind,
    tex_clean_bind;
ShapeDB shape_city_terrain_normal[CITY_SQUARETOT],
	shape_city_tree[CITY_SQUARETOT],
	shape_city_normal[CITY_LEVELS];
PathDB var_city_mormokki_path[CITY_MORMOKKI_COUNT];

/*
 * Generoi ruudunmuotoinen tekstuuri.
 */
void city_generate_ruututex(int *bind, int div, int halk)
{
  int i, j;
  Uint32 *bmp = texture_clear();

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
  texture_create(bind, texture_playground, CITY_RUUTUTEX_W / div,
      CITY_RUUTUTEX_H / div);
  // Värit mukaan
  (*bind) *= -1;
}


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
  //cond_printf("Path: %f, %f, %f\n", fx, fy, fz);
  path_add_vd(pth, fx, fy, fz, 0.0f, 0.0f, 0.0f, 0.0f);
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

      /*if(i + j < 2)
	printf("Error: i = %i, j = %i, block = %i\n", i, j, detail);*/

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
  float conndisp = (1.0f + rand_float_neg(0.2f)) * CITY_CONNECT_DISP,
	c1 = city_detail_transform_xz(c) + conndisp,
	c2 = city_detail_transform_xz(c + 1) - conndisp,
	fa = city_detail_transform_xz(a + 1),
	fb = city_detail_transform_xz(b);
  int col = CITY_COL_BUILDING + rand_int(CITY_COLCNT_BUILDING);
  if(xaxis)
    shapedb_draw_cube(shp, fa, y1, c1, fb, y2, c2, 0.0f, 1, 1, col);
  else
    shapedb_draw_cube(shp, c1, y1, fa, c2, y2, fb, 0.0f, 1, 1, col);

  /*printf("Made connection!: %5.1f, %5.1f, %5.1f, %5.1f, %5.1f, %5.1f\n", fx1,
      y1, z1, fx2, y2, z2);*/
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
  ShapeDB *shp, *tree;
  PathDB *pth;

  // Tee tekstuuri
  city_generate_ruututex(&tex_ruutu_bind_1, 1, 0);
  city_generate_ruututex(&tex_ruutu_bind_2, 4, 0);
  city_generate_ruututex(&tex_crane_bind, 2, 1);

  // Tyhjennä muodot
  for(i = 0; i < CITY_SQUARETOT; i++)
    shapedb_clear(shape_city_terrain_normal + i);
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

  // Maasto interpoloimalla pisteitten väliä Redundanssilla ei väliä, precalc
  // saa kestää.
  for(i = 0; i < CITY_SQUARECNT; i++)
    for(j = 0; j < CITY_SQUARECNT; j++)
    {
      k = i * CITY_SQUARECNT + j;
      // Muodot
      shp = shape_city_terrain_normal + k;
      tree = shape_city_tree + k;
      // Seuraavat
      k = (i + 1) * CITY_SQUARE;
      l = (j + 1) * CITY_SQUARE;
      if(k >= CITY_SIZE)
	k = CITY_SIZE - 1;
      if(l >= CITY_SIZE)
	l = CITY_SIZE - 1;
      // Tee
      city_terrain_make_square(j * CITY_SQUARE, i * CITY_SQUARE, l, k,
	  shp, tree);
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
  for(i = 0; i < CITY_DETAIL; i++)
    for(j = 0; j < CITY_DETAIL; j++)
    {
      city_generate_block(j, i);
      city_generate_connections(j, i);
    }

  // Luodaan display listit
  var_city_lists = glGenLists(CITY_SQUARETOT + CITY_LEVELS);
  for(i = 0; i < CITY_SQUARETOT; i++)
  {
    glNewList(var_city_lists + i, GL_COMPILE);
    shapedb_draw_elements(shape_city_terrain_normal + i, tex_ruutu_bind_2,
	GL_QUADS);
    shapedb_draw_elements(shape_city_tree + i, tex_ruutu_bind_2, GL_QUADS);
    glEndList();    
  }
  for(i = 0; i < CITY_LEVELS; i++)
  {
    glNewList(var_city_lists + CITY_SQUARETOT + i, GL_COMPILE);
    shapedb_draw_elements(&shape_city_normal[i], tex_ruutu_bind_1, GL_QUADS);
    glEndList();
  }

  // Luodaan mörmökkien polut
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

  // Luetaan lentsikan polku
  path_read_vddata(&path_plane, trail_plane, TRAIL_PLANE_LEN);
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
}
void mode_city_wire(int op)
{
  blend_mode(1);
  screen_clear(0);
  glFogfv(GL_FOG_COLOR, colordb_get_float(0));
  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  glLineWidth(3.0f);
}

/*
 * Piirrä kaupunki.
 */
void efu_city(int freezetime)
{
  int i, j, k, l;
  float moermokkipos, moermokkiadv;
  PathDB *pth;

  /*
   * Kaupunkiefekti keskeytetään monasti, tämän takia on essentiaalista, että
   * efekti osataan 'pysäyttää' tarvittaessa.
   */
  if(freezetime >= CITY_HALT_1)
  {
    freezetime -= CITY_HALT_1_DUR;
    if(freezetime < CITY_HALT_1)
      freezetime = CITY_HALT_1;
  }
  if(freezetime >= CITY_HALT_2)
  {
    freezetime -= CITY_HALT_2_DUR;
    if(freezetime < CITY_HALT_2)
      freezetime = CITY_HALT_2;
  }

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
  /*for(k = -2; k <= 2; k++)
  {
    city_draw_square(i + k, j - 3);
    city_draw_square(i + k, j + 3);
    city_draw_square(i - 3, j + k);
    city_draw_square(i + 3, j + k);
  }*/
  for(k = -1; k <= 1; k++)
  {
    city_draw_square(i + k, j - 4);
    city_draw_square(i + k, j + 4);
    city_draw_square(i - 4, j + k);
    city_draw_square(i + 4, j + k);
  }
  //glFlush();

  // Piirrä koko kaupunki
  for(i = 0; i < CITY_LEVELS; i++)
    glCallList(var_city_lists + CITY_SQUARETOT + i);

  // Piirrä mörmökit
  rand_seed(1);
  //glDisable(GL_CULL_FACE);
  for(i = 0; i < CITY_MORMOKKI_COUNT; i++)
  {
    // Matriisi talteen
    glPushMatrix();

    pth = var_city_mormokki_path + i;

    // Otetaan satunnainen kohta
    j = freezetime - rand_int(CITY_MORMOKKI_WAITTIME);
    // täydet jaksot sisään
    moermokkipos = (float)(j / CITY_MORMOKKI_WAITTIME);
    // laske remainder
    k = j % CITY_MORMOKKI_WAITTIME;
    // lisää jaksojen neljännekset
    moermokkipos += CITY_MORMOKKI_FRAC * (float)(k / CITY_MORMOKKI_WAITBIG);
    // Jos ollaan liikkumisvaiheessa
    l = k % CITY_MORMOKKI_WAITBIG;
    if((l / CITY_MORMOKKI_WAITSML) != 0)
    {
      moermokkiadv = (float)(l - CITY_MORMOKKI_WAITSML) /
	(float)CITY_MORMOKKI_WAITSML;
      moermokkipos += moermokkiadv * CITY_MORMOKKI_FRAC;
      glTranslatef(0.0f, (float)sin(moermokkiadv * M_PI) *
	  CITY_MOERMOKKI_HOPHT, 0.0f);
    }

    // Polku ja liike
    path_get_pos_spline(pth, moermokkipos, PATH_MODE_FWD);
    glScale1f(CITY_MOERMOKKI_SCALE);
    shapedb_draw_elements(&shape_tachikoma, tex_crane_bind, GL_TRIANGLES);

    // Popitetaan matriisi
    glPopMatrix();
  }

  // Piirrä lentsikka
  moermokkipos = freezetime * 0.00166f;
  glPushMatrix();
  path_get_pos_spline(&path_plane, moermokkipos, PATH_MODE_NORMAL);
  glScale1f(10.0f);
  shapedb_draw_elements(&shape_tachikoma, tex_crane_bind, GL_TRIANGLES);
  glPopMatrix();
}

/*
 * Wrappereita
 */
void efu_city_ph2(int op)
{
  efu_city(op + CITY_FOLD_1_END);
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
  y1 += pos * (-1.0f - y1);
  x2 += pos * (1.0f - x2);
  y2 += pos * (1.0f - y2);

  blend_mode(3);
  //printf("%f, %f, %f, %f\n", x1, y1, x2, y2);
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
  shapedb_draw_elements(&shape_use, 0, GL_TRIANGLE_STRIP);
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
  targeting_triple(-0.8f, -0.2f, 0.3f, 0.5f, op, 60);
}

//############################################################################
// Fold ######################################################################
//############################################################################

/*
 * Ensin muuttujat.
 */
ShapeDB shape_simpleplane[4];
ShapeDB shape_swan[4];
ShapeDB shape_crow[4];
ShapeDB shape_random;

/*
 * Sitten taitto-ohjeet, yksi phase kerrallaan
 * Formaatti: Akseli mistä, akseli mihin, verteksi, asteita*10 (fixed point koska inttejä)
 */
int fold_guide_simpleplane[] =
{
	8,
	5, 10,
	3, 0, 1, 1350,
	3, 0, 2, 1350,
	3, 0, 14, 1350,
	3, 0, 15, 1350,
	3, 0, 18, 1350,
	2, 100,
	15, 14, 1, 450,
	15, 14, 2, 450,
	5, 10,
	0, 11, 9, 1350,
	0, 11, 10, 1350,
	0, 11, 16, 1350,
	0, 11, 17, 1350,
	0, 11, 19, 1350,
	2, 100,
	16, 17, 9, 450,
	16, 17, 10, 450,
	9, 10,
	13, 0, 1, 830,
	13, 0, 2, 830,
	13, 0, 3, 830,
	13, 0, 4, 830,
	13, 0, 5, 830,
	13, 0, 6, 830,
	13, 0, 14, 830,
	13, 0, 15, 830,
	13, 0, 18, 830,
	9, 100,
	0, 13, 7, 830,
	0, 13, 8, 830,
	0, 13, 9, 830,
	0, 13, 10, 830,
	0, 13, 11, 830,
	0, 13, 12, 830,
	0, 13, 16, 830,
	0, 13, 17, 830,
	0, 13, 19, 830,
	3, 10,
	5, 6, 3, -900,
	5, 6, 4, -900,
	5, 6, 15, -900,
	3, 100,
	7, 8, 11, -900,
	7, 8, 12, -900,
	7, 8, 17, -900
};

int fold_guide_swan[] =
{
	11,
	6, 135,
	17, 1, 24, -1800,
	1, 18, 25, -1800,
	26, 9, 5, -1350,
	10, 29, 6, -1350,
	28, 11, 7, -1350,
	12, 27, 8, -1350,
	26, 90,
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
	8, 45,
	0, 1, 10, 445,
	0, 1, 18, 445,
	0, 1, 9, -445,
	0, 1, 17, -445,
	0, 1, 12, 445,
	0, 1, 20, 445,
	0, 1, 11, -445,
	0, 1, 19, -445,
	8, 135,
	9, 10, 1, 1350,
	9, 10, 21, 1350,
	9, 10, 34, 1350,
	9, 10, 22, 1350,
	9, 10, 23, 1350,
	9, 10, 24, 1350,
	9, 10, 25, 1350,
	11, 12, 3, 1350,
	1, 90,
	21, 34, 1, -900,
	10, 90,
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
	2, 110,
	10, 11, 2, 1100,
	9, 12, 4, -1100,
	2, 50,
	10, 11, 2, -300,
	9, 12, 4, 300,
	2, 50,
	10, 11, 2, 300,
	9, 12, 4, -300,
	2, 50,
	10, 11, 2, -300,
	9, 12, 4, 300,
	2, 50,
	10, 11, 2, 300,
	9, 12, 4, -300
};
//real angle 57.76438968275467

int fold_guide_crow[] =
{
	9,
	12, 180,
	5, 6, 1, -1800,
	5, 6, 9, -1800,
	5, 6, 10, -1800,
	6, 7, 2, -1800,
	6, 7, 11, -1800,
	6, 7, 12, -1800,
	7, 8, 3, -1800,
	7, 8, 13, -1800,
	7, 8, 14, -1800,
	8, 5, 4, -1800,
	8, 5, 15, -1800,
	8, 5, 16, -1800,
	4, 180,
	24, 18, 5, 1800,
	18, 20, 6, 1800,
	20, 22, 7, 1800,
	22, 24, 8, 1800,
	12, 45,
	21, 17, 10, 450,
	21, 17, 11, 450,
	21, 17, 19, 450,
	23, 19, 12, 450,
	23, 19, 13, 450,
	23, 19, 21, 450,
	17, 21, 14, 450,
	17, 21, 15, 450,
	17, 21, 23, 450,
	19, 23, 16, 450,
	19, 23, 17, 450,
	19, 23, 9, 450,
	1, 60,
	24, 25, 4, -600,
	8, 70,
	0, 18, 16, -700,
	0, 18, 17, -700,
	0, 18, 9, -700,
	22, 0, 14, -700,
	22, 0, 15, -700,
	22, 0, 23, -700,
	22, 0, 24, -1150,
	22, 0, 4, -1150,
	2, 25,
	0, 17, 22, 250,
	23, 0, 18, 250,
	2, 50,
	0, 17, 22, -500,
	23, 0, 18, -500,
	2, 50,
	0, 17, 22, 500,
	23, 0, 18, 500,
	2, 50,
	0, 17, 22, -500,
	23, 0, 18, -500
};

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

void fold_generate_model(ShapeDB *shape, float *verts, int vertnum, Uint16 *polys, int indexnum) {
	int i;
	for(i=0; i<vertnum; i++) {
		shapedb_add_cv(shape, verts[i*4 + 0], verts[i*4 + 1], verts[i*4 + 2], (int)verts[i*4 + 3]);
		//printf("\nAdded vertex %f, %f, %f, color %i.", verts[i*4 + 0], verts[i*4 + 1], verts[i*4 + 2], (int)verts[i*4 + 3]);
	}
	for(i=0; i<indexnum; i++) {
		shapedb_add_index(shape,polys[i]);
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
  fold_generate_model(&shape_crow[0], form_crow_tcv, FORM_CROW_VERTS,
      form_crow_ref, FORM_CROW_INDEXES);

  for(i = 1; i < 2; i++)
  {
    shapedb_copy(&shape_simpleplane[i], &shape_simpleplane[0]);
    shapedb_copy(&shape_swan[i], &shape_swan[0]);
    shapedb_copy(&shape_crow[i], &shape_crow[0]);
  }

  //printf("\nGeneration ready.");
}

void fold_fold(ShapeDB *dest, ShapeDB *src, int linebeg, int lineend, int vertex, float amount)
{
  float newpos[3];

  fold_operate(newpos, shapedb_get_vertex(src, linebeg), shapedb_get_vertex(src, lineend), shapedb_get_vertex(src, vertex), amount);
  
  shapedb_replace_vertex(dest, vertex, newpos);
	//printf("\nVertex %i folded over %i to %i by amount %f", vertex, linebeg, lineend, amount);
}

/*
 * Taittoefun taittofunktiot
 */
void fold_guide_interpreter(ShapeDB *dst, ShapeDB *src, int *foldguide, float amount) {
	int i;

	for(i=0; i<foldguide[0]; i++) {
		//printf("\nTrying to fold %i over %i to %i by amount %f", foldguide[i*4+3], foldguide[i*4+1], foldguide[i*4+2], (float)amount*(float)foldguide[i*4+4]);
		fold_fold(dst, src, foldguide[i*4+1], foldguide[i*4+2], foldguide[i*4+3], (float)amount*(float)foldguide[i*4+4]*(float)0.1);
	}
	if((int)amount == 1) {
		shapedb_copy(src,dst);
	}
}

void fold_master(ShapeDB *dst, ShapeDB *src, int *guide, int freezetime)
{
	int folds, starttime, endtime, i, j;
	int foldguide[256];
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
		fold_guide_interpreter(dst, src, foldguide, ((float)freezetime-(float)starttime)/((float)endtime-(float)starttime));
	}
	//if(freezetime%2==0)
		shapedb_draw_elements(dst, -1, GL_QUADS);
	//else
		//shapedb_draw_elements(src, -1, GL_QUADS);
}

/*
 * Taittoefun kontrolli
 */
void fold_control(int freezetime, ShapeDB *shp, int *guide) {
	/*while(freezetime<1600) {
		fold_master(&shape_simpleplane[2], &shape_simpleplane[1], fold_guide_simpleplane, freezetime);
		break;
	}*/
	/*while(freezetime<3000) {
		fold_master(&shape_swan[2], &shape_swan[1], fold_guide_swan, freezetime);
		//shapedb_draw_elements(&shape_swan[0],-1,GL_QUADS);
		break;
	}*/
	while(freezetime < 2000) {
		fold_master(shp + 2, shp + 1, guide, freezetime);
		//shapedb_draw_elements(&shape_crow[0],-1,GL_QUADS);
		break;
	}
}

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
void efu_fold(int freezetime, ShapeDB *shp, int *guide)
{
  // Tyhjennys ja random
  screen_clear(0);
  camera_frustum(90.0f, 5000.0f);
  glLoadIdentity();
  look_at(lookat_fold, freezetime);
  blend_mode(2);
  glDisable(GL_CULL_FACE);

  // Initialize random seed
  //rand_seed(freezetime);

  // Kontrolli
  fold_control(freezetime, shp, guide);
}

/*
 * Taittoefun abstraktiot.
 */
void efu_fold_crow(int freezetime)
{
  efu_fold(freezetime, shape_crow, fold_guide_crow);
}
void efu_fold_swan(int freezetime)
{
  efu_fold(freezetime, shape_swan, fold_guide_swan);
}
void efu_fold_plane(int freezetime)
{
  efu_fold(freezetime, shape_simpleplane, fold_guide_simpleplane);
}

//############################################################################
// Efektit ###################################################################
//############################################################################

#define EFU_COUNT	12

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
  { CITY_START, CITY_START + CITY_FOLD_1, efu_city },
  { CITY_START + CITY_TARGETING_1, CITY_START + CITY_FOLD_1, targeting_plane },
  // Lentokoneen taittelu
  { CITY_START + CITY_FOLD_1, CITY_START + CITY_FOLD_1_END, efu_fold_plane },
  // City phase 2
  { CITY_START + CITY_FOLD_1_END, CITY_END, mode_city_normal },
  { CITY_START + CITY_FOLD_1_END, CITY_END, efu_city_ph2 },
  // GitS
  { GITS_START, GITS_END, efu_gits }
};

//############################################################################
// Exportattava main #########################################################
//############################################################################

#ifdef FLAG_NOSTDLIB
void c_main()
#else
int main(int argc, char **args)
#endif
{
  int i, loop = 1, lasttime;
  SDL_Event event;
  SDL_Surface *screen;
  
  /*
   * Init.
   */
  
  // SDL
  SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_AUDIO);
  screen = SDL_SetVideoMode(SCREEN_W, SCREEN_H, SCREEN_B, SDL_GFX_FLAGS);
  // OpenGL
  glViewport(0, 0, SCREEN_W, SCREEN_H);
  glClearDepth(1.0);
  glDepthFunc(GL_LEQUAL);
  //glShadeModel(GL_SMOOTH);

  /*
   * Precalc.
   */
  
  // Värit
  i = COLORDB_SIZE - 1;
  do
  {
    colordb_convert_u2f(i);
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
    colordb_convert_lebe(i);
#endif
  } while(i--);

  // Tekstuurit
  generate_line_texture(&linetexture1_bind, 9);
  generate_line_texture(&linetexture2_bind, 10);
  generate_line_texture(&linetexture3_bind, 11);

  // Linjaympyrä
  i = LINECIRCLE_COMPLEXITY;
  do
  {
    float percent = (float)i / (float)LINECIRCLE_COMPLEXITY,
	  ang = percent * M_PI * 2,
	  ca = (float)cos(ang),
	  sa = (float)sin(ang); 
    shapedb_add_tv(&shape_line_circle, ca, -LINECIRCLE_THICKNESS, sa,
	0.0f, percent);
    shapedb_add_tv(&shape_line_circle, ca, LINECIRCLE_THICKNESS, sa,
	1.0f, percent);
    shapedb_add_index(&shape_line_circle, i * 2);
    shapedb_add_index(&shape_line_circle, i * 2 + 1);
  } while(i--);

  // GitS-efun yhteydet
  generate_gits_connections();

  // Asiat joita tarvii joka framelle
  var_rand_seed = 0x7060dfdb; // Tärkeää koska kusin jossakin vaiheessa
  i = MAX_EFFECT_TIME * TIMER_MS - 1;
  do
  {
    var_pillar_shard[i] = rand_float(M_PI * 2.0f);
    var_gits_path_start[i] = rand_int(var_gits_pathcount);
  } while(i--);

  // Luetaan mallit
  shapedb_clear(&shape_flare);
  shapedb_clear(&shape_crane);
  shapedb_clear(&shape_tachikoma);
  shapedb_read_cvdata(&shape_flare, form_flare_cv, form_flare_ref,
      FORM_FLARE_VERTS, FORM_FLARE_INDEXES);
  shapedb_read_tcvdata(&shape_crane, form_crane_tcv, form_crane_ref,
      FORM_CRANE_VERTS, FORM_CRANE_INDEXES);
  shapedb_read_tcvdata(&shape_tachikoma, form_tachikoma_tcv,
      form_tachikoma_ref, FORM_TACHIKOMA_VERTS, FORM_TACHIKOMA_INDEXES);

  // Pilarit
  generate_light_pillar_shard(&shape_pillar_draw, &pillar_draw);
  generate_light_pillar_shard(&shape_pillar_wings, &pillar_wings);

  // Kaupunki
  generate_city();

  // Fold
  fold_init();

  // Ajastin
  var_timer_offset = SDL_GetTicks();
  var_timer_skip = CITY_START+700/* + CITY_FOLD_1_END*/;

  // Loop
  for(lasttime = -1; loop;)
  {
    // Hae uusi aika
    timer_get_ticks();

    // Pirrä vain jos tarpeen
    if(lasttime != var_timer)
    {
      
      lasttime = var_timer;

      // Kelataan efut läpi
      for(i = 0; i < EFU_COUNT; i++)
      {
	EffectData *efu = var_efu + i;
	if((lasttime >= efu->start) && (lasttime < efu->end))
	  efu->func(lasttime - efu->start);
      }

      //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
      blend_mode(2);
      glScalef(-2.0f, 2.0f, -2.0f);
      shapedb_draw_elements(&shape_tachikoma, tex_crane_bind, GL_TRIANGLES);
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

      // Ruudulle
      screen_flash();
      SDL_GL_SwapBuffers();
    }

    // Kuuntele eventit
    if((SDL_PollEvent(&event)) && (event.type == SDL_KEYDOWN))
      switch(event.key.keysym.sym)
      {
	case SDLK_ESCAPE:
	  loop = 0;
	  break;
	case SDLK_LEFT:
	  var_timer_skip -= 600;
	case SDLK_RIGHT:
	  var_timer_skip += 300;
	  break;
	default:
	  break;
      }
    // Pois jos aika loppu
    if(var_timer >= TIME_END)
      loop = 0;
  }

  // Pois
  //glDeleteLists(var_city_lists, CITY_SQUARECNT * CITY_SQUARECNT + 1);
  SDL_Quit();
#ifndef FLAG_NOSTDLIB
  return 0;
#endif
}

//############################################################################
// Loppu #####################################################################
//############################################################################
