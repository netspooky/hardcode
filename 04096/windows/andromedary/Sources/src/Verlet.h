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

#ifndef __VERLET_H
#define __VERLET_H
#include "Native.h"
//#include "Dome.h"

#define DOME_SIZE 30 // DEFINED REALLY IN DOME.H

struct Verlet
{
    float pos[3];
    float old_pos[3];
};

float g_verlet_gravity = 0;
 float g_verlet_grav_center[] = { 0, 15, 0 };

void VerletReset( Verlet *v, float *pos )
{
    Vec_Copy( v->pos, pos );
    Vec_Copy( v->old_pos, pos );
}


/*void VerletGravitation( float *accel, float *pos, float mass )
{
    Vec_Add_Mul( accel, g_verlet_grav_center, pos, -1.f );
    float delta_len = Vec_Len( accel );

    float force = mass / (delta_len * delta_len);
    Vec_Scale( accel, force );
}*/

 void VerletDistanceConstraint( Verlet *v1, Verlet *v2, float rest_len )
{
    float delta[3];

    Vec_Add_Mul( delta, v2->pos, v1->pos, -1.f );
    float delta_len = Vec_Len( delta );
//    if ( delta_len < 0.001f )
//        return;
    float diff = ( delta_len - rest_len ) / delta_len;

    Vec_Add_Mul( v1->pos, v1->pos, delta, 0.5f * diff );
    Vec_Add_Mul( v2->pos, v2->pos, delta, -0.5f * diff );
}

/*void VerletGroundConstraint( Verlet *v )
{
    if ( v->pos[1] < 1 )
    {
        v->pos[1] = 1;
        // Total friction along x/z axis
        v->old_pos[0] = v->pos[0];
        v->old_pos[2] = v->pos[2];
    }
}

void VerletDomeConstraint( Verlet *v, float dome_size )
{
    float dist = Vec_Len( v->pos );
    if ( dist <= dome_size )
        return;

    Vec_Scale( v->pos, dome_size/dist );
}*/

void VerletIntegrate( Verlet *v, int amount )
{
    float accel[3];
    float old[3];
    float time2 = ((1.f/30.f) * (1.f/30.f)); //time_step * time_step;

    while ( amount-- > 0 )
    {
        // Solve wall contacts
//        VerletDomeConstraint( v, DOME_SIZE );
        {
            float dist = Vec_Len( v->pos );
            if ( dist > DOME_SIZE )
                Vec_Scale( v->pos, DOME_SIZE/dist );
        }

//        VerletGroundConstraint( v );
        if ( v->pos[1] < 1 )
        {
            v->pos[1] = 1;
            // Total friction along x/z axis
            v->old_pos[0] = v->pos[0];
            v->old_pos[2] = v->pos[2];
        }

        // Get the gravitation force
//        VerletGravitation( accel, v->pos, 30 );
        {
            Vec_Add_Mul( accel, g_verlet_grav_center, v->pos, -1.f );

            float force = 30 / Vec_Dot( accel, accel );
            Vec_Scale( accel, force );
        }

//        Gravity
        accel[1] -= g_verlet_gravity;

        // Integerate
        Vec_Copy( old, v->old_pos );
        Vec_Copy( v->old_pos, v->pos );
        Vec_Add_Mul( v->pos, v->pos, v->pos, 1 );
        Vec_Add_Mul( v->pos, v->pos, old, -1 );
        Vec_Add_Mul( v->pos, v->pos, accel, time2 );

        ++v;
    }
}

#endif
