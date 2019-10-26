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

#ifndef __GROUND_H
#define __GROUND_H
#include "Native.h"
#include "Color.h"

void DrawGround()
{
    unsigned char color[3];
    
    const int blocks = 50/2;
    const float block_size = 5.f;
    glBegin( GL_QUADS );
    glNormal3f( 0, -1, 0 );
    for ( int y = -blocks; y <= blocks; ++y )
    {
        for ( int x = -blocks; x <= blocks; ++x )
        {
            float fx = x * block_size - block_size / 2;
            float fy = y * block_size - block_size / 2;
            //SetColor( fx, 0, fy, color );
            int v = My_Ftoi(My_Cos(My_Sqrt((float)(x * x + y * y)) / 3) * 35 + 40);
            color[0] = v;
            color[1] = v;
            color[2] = v;
            
            glColor3ubv(color);
            glVertex3f( fx, 0, fy );
            glVertex3f( fx + block_size, 0, fy );
            glVertex3f( fx + block_size, 0, fy + block_size );
            glVertex3f( fx, 0, fy + block_size );
        }
    }
    glEnd();
}

#endif
