/**
 * Common defines etc.
 *
 * @author Timo Wirén
 * @version 2008-02-27
 * @licence GNU GPL
 */
#include <math.h>
#include <SDL/SDL.h>

#ifndef M_PI
#define M_PI 3.1415926535f
#endif

#define WIDTH 512
#define HEIGHT 384

#define PRIMARY_RAY 0
#define SECONDARY_RAY 1

#define WAMMA_COUNT 71
#define SPHERE_FLAKE_COUNT 9
#define ROOM_COUNT 8
#define LIGHT_COUNT 1

#define SPHERE 0
#define PLANE 1
#define CYLINDER 2

#define AXEL_F 0
#define AXEL_XP 1
#define AXEL_XN 2
#define AXEL_YP 3
#define AXEL_YN 4
#define AXEL_ZP 5
#define AXEL_ZN 6

#define TEXTURE_XOR 0
#define TEXTURE_GRID 1
#define TEXTURE_NOISE 2
#define TEXTURE_NOISEBW 3
#define TEXTURE_AMIGA 4

Vector viewing_point;
Vector ray_directions[WIDTH * HEIGHT];

Object wAMMA[WAMMA_COUNT];
Object sphere_flake[SPHERE_FLAKE_COUNT];
Object room[ROOM_COUNT];

Vector lights[LIGHT_COUNT];



