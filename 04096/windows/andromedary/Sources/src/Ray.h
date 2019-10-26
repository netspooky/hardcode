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

#ifndef __RAY_H
#define __RAY_H
#include "Native.h"
#include "Dome.h"
#include "Mirrors.h"

#define DIST_NO_HIT 200
#define RAY_AMOUNT 200
#define RAY_BUNCH_RADIUS 3
#define RAY_BOUNCES 3

bool IsInside( float *pt, float *normal, float *v1, float *v2 )
{
    float vec[3];
    float dir[3];
    
    Vec_Add_Mul( dir, v2, v1, -1 );
    Vec_Cross( vec, normal, dir );
    Vec_Add_Mul( dir, pt, v1, -1 );
    return Vec_Dot( dir, vec ) > 0;
}

float CastRayToTriangle( float *ray_pos, float *ray_dir, float *v1, float *v2, float *v3, float *dest, float *dest_normal )
{
    // Create triangle normal
    Vec_Make_Normal( dest_normal, v1, v2, v3 );
    
    // Intersect with plane
    float w0[3];
    Vec_Add_Mul( w0, ray_pos, v1, -1.f );
    float a = -Vec_Dot( dest_normal, w0 );
    float b = Vec_Dot( dest_normal, ray_dir );
    if ( My_Abs(b) < 0.0001f )
        return DIST_NO_HIT;
    
    // Plane test and point creation
    float r = a / b;
    if ( r < 0 )
        return DIST_NO_HIT;
    
    Vec_Add_Mul( dest, ray_pos, ray_dir, r );
    
    if ( !IsInside( dest, dest_normal, v1, v2 ) ||
        !IsInside( dest, dest_normal, v2, v3 ) ||
        !IsInside( dest, dest_normal, v3, v1 ) )
    {
        return DIST_NO_HIT;
    }
    
    return r;
}

float LightRayToDome( float *ray_pos, float *ray_dir )
{
    float dest[3];
    float dist = 100;
    
    Vec_Normalize( ray_dir );
    dist *= 2;
    
    while ( true )
    {
        --dist;
        Vec_Add_Mul( dest, ray_pos, ray_dir, dist );
        float d = Vec_Len( dest );
        if ( d < DOME_SIZE )
            break;
    }
    
    LightDomePosition( dest );
    
    return dist;
}

bool CastRayToMirrors( float *ray_pos, float *ray_dir, float *dest_pos, float *dest_normal )
{
    float dest[3];
    float destn[3];
    float dist = DIST_NO_HIT;
    bool ret = false;

    Verlet *v = g_mirror_verlets;
    int left = MIRROR_COUNT;
    while ( left-- > 0 )
    {
        float d = CastRayToTriangle( ray_pos, ray_dir, v[0].pos, v[1].pos, v[2].pos, dest, destn );
//        if ( d < 0.1f || d >= dist )
//            d = CastRayToTriangle( ray_pos, ray_dir, v[0].pos, v[2].pos, v[3].pos, dest, destn );

        if ( d > 0.1f && d < dist )
        {
            dist = d;
            Vec_Copy( dest_pos, dest ); 
            Vec_Copy( dest_normal, destn );
            ret = true;
        }

        v += 4;
    }

    return ret;
}

void CastRay( float *from, float *dir )
{
    float dest[3];
    float destn[3];

    int left = RAY_BOUNCES;
    bool hits_to_dome = false;
    while ( left-- > 0 )
    {
        glVertex3fv( from );

        if ( CastRayToMirrors( from, dir, dest, destn ) ) 
        {
            Vec_Copy( from, dest );
            glVertex3fv( dest );

            // Mirror the direction
            Vec_Add_Mul( dir, dir, destn, -2 * Vec_Dot( destn, dir ) );
            hits_to_dome = true;
        }
        else
        {
//            if ( hits_to_dome )
//                d = CastRayToGroundDome( from, dir, dest, destn );
            float d = LightRayToDome( from, dir );
//            if ( d > 100 )
//                d = 100;

            Vec_Add_Mul( dest, from, dir, d );
            glVertex3fv( dest );
            return;
        }
    }
}

unsigned char g_ray_color[] = { 6, 20, 40 };


#define rand inlineRand
#define randf inlineRandf
static unsigned int randseed = 0;

static void inlineSrand(unsigned int seed)
{
    randseed = seed;
}

static unsigned int inlineRand()
{
    randseed = randseed * 0x343fd + 0x269ec3;
    return randseed >> 16;
}

static float inlineRandf(float scale)
{
    return scale * rand() / RAND_MAX;
}



void CastAndDrawRays()
{
    float from[3];
    float dir[3];

    glBlendFunc( GL_SRC_ALPHA, GL_ONE );
    glDisable( GL_LIGHTING );
    glBegin( GL_LINES );
    glColor3ubv(g_ray_color);

    for ( int i = 0; i < RAY_AMOUNT; ++i )
    {
        dir[0] = dir[2] = 0;
        dir[1] = -1;

        float ang = (float)(i>>1);
        float mul = (RAY_BUNCH_RADIUS/(float)RAY_AMOUNT) * ang ;
        from[0] = mul * My_Cos( ang );
        from[1] = 100;
        from[2] = mul * My_Sin( ang );

        CastRay( from, dir );
    }

    glEnd();
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glEnable( GL_LIGHTING );
}

#endif
