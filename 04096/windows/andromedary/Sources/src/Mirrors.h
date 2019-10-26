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

#ifndef __MIRRORS_H
#define __MIRRORS_H
#include "Native.h"
#include "Color.h"
#include "Dome.h"
#include "Verlet.h"

#define MIRROR_COUNT (DOME_W*(DOME_H-1)/2)

Panel g_mirrors[ MIRROR_COUNT ];
Verlet g_mirror_verlets[ MIRROR_COUNT*4 ];

void InitMirrors()
{
    InitDome( g_mirrors, g_mirror_verlets, 2, 1 );
}

void DrawMirrors()
{
    DrawDomePanels( g_mirrors, g_mirror_verlets, MIRROR_COUNT );
}

void UpdateMirrors()
{
    VerletIntegrate( g_mirror_verlets, MIRROR_COUNT*4 );
    
    // Do the mirror distance constraints
    int left = MIRROR_COUNT;
    Verlet *v = g_mirror_verlets;
    while ( left-- > 0 )
    {
        VerletDistanceConstraint( &v[0], &v[2], 5/*m->dist_across*/ );
        VerletDistanceConstraint( &v[1], &v[3], 5/*m->dist_across*/ );
        VerletDistanceConstraint( &v[0], &v[1], 3/*m->dist_top*/ );
        VerletDistanceConstraint( &v[2], &v[3], 3/*m->dist_top*/ );
        VerletDistanceConstraint( &v[1], &v[2], 4.2f/*m->dist_side*/ );
        VerletDistanceConstraint( &v[0], &v[3], 4/*m->dist_side*/ );
        
        v += 4;
    }
}

#endif
