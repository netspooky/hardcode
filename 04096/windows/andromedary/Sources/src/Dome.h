/*
    Andromedary
    Copyright (C) 2006 Jere Sanisalo, Jetro Lauha

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef __DOME_H
#define __DOME_H
#include "Native.h"
#include "Color.h"
#include "Verlet.h"

#define DOME_STEP (PI / 20.f)
#define DOME_SIZE 30
#define DOME_GRID_W 50
#define DOME_GRID_H 50

#define DOME_W 40
#define DOME_H 9

#define DOME_LIGHT_MUL  3

struct Panel
{
	float color[3];
	float grid;
};
Panel g_dome_panels[ DOME_W * DOME_W *2 ]; // *2 for lots of extra (there are some overwrites :)
Verlet g_dome_verlets[ DOME_W * DOME_H * 4 ];

void GetDomeCoord( float *dest, float x_ang, float y_ang )
{
	float ym = My_Cos( y_ang ) * DOME_SIZE;
	dest[1] = DOME_SIZE * My_Sin( y_ang );
	dest[0] = ym * My_Cos( x_ang );
	dest[2] = ym * My_Sin( x_ang );
}

int LightDomeSlot( float a, float b )
{
	float ang = My_Atan( a, b );
	if ( ang < 0 )
		ang += PI*2;
	return My_Ftoi( ang / DOME_STEP );
}

__forceinline void LightDomePosition( float *vec )
{
	// Get the y-position
	int y_slot = LightDomeSlot( vec[1], My_Sqrt(vec[0]*vec[0] + vec[2]*vec[2]) );

	// Get the x-position
	int x_slot = LightDomeSlot( vec[2], vec[0] );

//	float *f = &g_dome_grid[ x_slot + y_slot * DOME_GRID_W ];
//	if (*f < 1) *f = 1; else *f += 0.1f;
//	g_dome_grid[ x_slot + y_slot * DOME_GRID_W ] = 3;
	g_dome_panels[ x_slot + y_slot * DOME_W ].grid = DOME_LIGHT_MUL;
}

void InitDome( Panel *panels, Verlet *v, float x_mul, char colorScheme )
{
	const float step = DOME_STEP;
        //float x_mul = (float)(colorScheme + 1);

	int yi = colorScheme;

	float y = yi * step;
	for ( ; yi < DOME_H; ++yi, y += step )
	{
		for ( float x = 0.f; x < (PI*2); x += step*x_mul )
		{
			// Make the verlet coords
			GetDomeCoord( v->pos, x, y ); VerletReset( v, v->pos );
                        /*
			SetColor((unsigned char)((v->pos[0] + DOME_SIZE) / 4),
                                 (unsigned char)((v->pos[1] + DOME_SIZE) / 4,
                                 (unsigned char)((v->pos[2] + DOME_SIZE) / 4,
                                 panels->color );
                                 */
                        if (colorScheme)
                        {
                            // mirrors
                            panels->color[0] = 0.6f;
                            panels->color[1] = 0.3f;
                            panels->color[2] = 0;
                        }
                        else
                        {
                            // dome
                            /*
                            //float v0_1 = 0.0999999940395355220000000f;
                            float v = 0.2f;
                            panels->color[0] = (float)(My_Sin(x * 8) + 1) / 7 + v;
                            panels->color[1] = v;
                            panels->color[2] = (float)(My_Sin(x * 8) + 1) / 8 + v;
                            */
                            float v = 0.25f;
                            float m = (float)(My_Sin(x * 6) + 1) / 4 + 0.5f;
                            panels->color[0] = ((float)(My_Sin(x) + 1) / 8 + 0.125f) * m;
                            panels->color[1] = 0.125f * m;
                            panels->color[2] = v * m;
                        }
			++v;

			GetDomeCoord( v->pos, x + DOME_STEP, y ); VerletReset( v, v->pos ); ++v;
			GetDomeCoord( v->pos, x + DOME_STEP, y + DOME_STEP ); VerletReset( v, v->pos ); ++v;
			GetDomeCoord( v->pos, x, y + DOME_STEP ); VerletReset( v, v->pos ); ++v;

			panels->grid = 0;
			++panels;
		}
	}
}

float g_dome_light_col[] = { 0.2f, 0.15f, 0.05f };

void DrawDomePanels( Panel *panels, Verlet *v, int amt )
{
	float normal[3];
	float color[3];

	glBegin( GL_QUADS );
	while ( amt-- > 0 )
	{
		float g = (panels->grid *= 0.95f);

		Vec_Make_Normal( normal, v[0].pos, v[1].pos, v[2].pos );
//		Vec_Normalize( normal );
		glNormal3fv( normal );

		Vec_Add_Mul( color, panels->color, g_dome_light_col, g );
		glColor3fv( color );
		glVertex3fv( v[0].pos );
		glVertex3fv( v[1].pos );
		glVertex3fv( v[2].pos );
		glVertex3fv( v[3].pos );

		++panels;
		v += 4;
	}
	glEnd();
}

__forceinline void DrawDome()
{
	DrawDomePanels( g_dome_panels, g_dome_verlets, DOME_W * DOME_H );
}

#endif
