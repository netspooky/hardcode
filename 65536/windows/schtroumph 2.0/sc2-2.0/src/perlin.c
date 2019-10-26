/* Schtroumpf - the intro - (c) 2004 Gautier Portet < kassoulet @ no-log . org >
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include "introsystem.h"

/* from ken perlin himself */

Uint8 p[512];

static inline float grad(int hash, float x, float y, float z) 
{
        int h = hash & 15;                      // CONVERT LO 4 BITS OF HASH CODE
        float u = h<8 ? x : y,                 // INTO 12 GRADIENT DIRECTIONS.
        v = h<4 ? y : h==12||h==14 ? x : z;
        return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
}

float noise(float x, float y, float z) {
        int X,Y,Z;

        X = (int)floor(x) & 255,                  // FIND UNIT CUBE THAT
        Y = (int)floor(y) & 255,                  // CONTAINS POINT.
        Z = (int)floor(z) & 255;
        x -= floor(x);                                // FIND RELATIVE X,Y,Z
        y -= floor(y);                                // OF POINT IN CUBE.
        z -= floor(z);
        float u = fade(x),                                // COMPUTE FADE CURVES
        v = fade(y),                                // FOR EACH OF X,Y,Z.
        w = fade(z);
        int A = p[X  ]+Y, AA = p[A]+Z, AB = p[A+1]+Z,      // HASH COORDINATES OF
        B = p[X+1]+Y, BA = p[B]+Z, BB = p[B+1]+Z;      // THE 8 CUBE CORNERS,

        return lerp(w, lerp(v, lerp(u, grad(p[AA  ], x  , y  , z   ),  // AND ADD
                                        grad(p[BA  ], x-1, y  , z   )), // BLENDED
                                lerp(u, grad(p[AB  ], x  , y-1, z   ),  // RESULTS
                                        grad(p[BB  ], x-1, y-1, z   ))),// FROM  8
                        lerp(v, lerp(u, grad(p[AA+1], x  , y  , z-1 ),  // CORNERS
                                        grad(p[BA+1], x-1, y  , z-1 )), // OF CUBE
                                lerp(u, grad(p[AB+1], x  , y-1, z-1 ),
                                        grad(p[BB+1], x-1, y-1, z-1 ))));
}

void InitNoise()
{
        int i;
        for (i=0; i < 256 ; i++) {
                p[256+i] = p[i] = rand();
        }
}

void FillNoise(Surface * s, int octaves, float persistence, float period, float dx, float dy, float z)
{
        int x,y;
        int i;
	float multiplier[16];
	
        for (i=1;i<=octaves;i++) {
		multiplier[i] = pow(persistence,i-1);
	}

        for(y=0; y<s->width; y++) {

                Uint8 *dst = (Uint8*)(s->pixels)+y*s->width;

                for(x=0; x<s->height; x++) {
                        Uint8 c;
                        float n=0;

                        for (i=1;i<=octaves;i++) {
                                n += multiplier[i]*noise((x+dx)*period*i,(y+dy)*period*i,z*period*i);
                        }
                        n = CLAMP(n,-1.0f,1.0f);
                        c = 127.0f+127.0f*n;

                        *dst++ = c;
                }
        }

}

