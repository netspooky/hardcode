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

// NOTE: This source is unusually #included by Main.cpp due to some quick hacking.
//       So this file shouldn't be compiled individually at all!

#include <windows.h>
#include <GL/GL.h>
#include <GL/GLU.h>
#include "glow.h"


// screen resolution
#define WIDTH  800
#define HEIGHT 600

#define GLOW_BASE 0.2f
#define GLOW_GLOW 0.3f

// set to 512,512 if the screen resolution is at least 800x600,
// set to 256,256 if you are using 640x480
//static const int glowBaseTextureWidth = 512, glowBaseTextureHeight = 512;
#define glowBaseTextureWidth 512
//#define glowBaseTextureHeight 512
#define glowBaseTextureHeight glowBaseTextureWidth

static GLuint texture[16];
#define textures 8

char g_static_texture_memory[2000*2000*4];

unsigned char g_color_table[] = { 255, 255, 255, 0 };


void glowInitTextures()
{
    int wh = glowBaseTextureWidth;
    
    void *texmem = g_static_texture_memory;
    
    int t;
    for (t = 0; t < textures; ++t)
    {
        glGenTextures(1, &texture[t]);
        glBindTexture(GL_TEXTURE_2D, texture[t]);
        glTexImage2D(GL_TEXTURE_2D, 0, 3, wh, wh, 0, GL_RGB, GL_UNSIGNED_BYTE, texmem);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);//GL_CLAMP_TO_EDGE);
        wh >>= 1;
    }
}

extern void InitGL();

void beginBaseTextureRender()
{
    InitGL();
    glViewport(0, 0, glowBaseTextureWidth, glowBaseTextureHeight);
}


void endBaseTextureRender()
{
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, glowBaseTextureWidth, glowBaseTextureHeight, 0);
    glViewport(0, 0, WIDTH, HEIGHT);
}


void beginGlow()
{
    glPushAttrib(GL_ENABLE_BIT);
    glDisable(GL_LIGHTING);

    /* Note, there may be other things you need to change,
    depending on how you have your OpenGL state set up.
    */
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glEnable(GL_TEXTURE_2D);

    /* This allows alpha blending of 2D textures with the scene */
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();

    glOrtho(0.0, (GLdouble)WIDTH, (GLdouble)HEIGHT, 0.0, 0.0, 1.0);
//    gluOrtho2D(0, WIDTH, HEIGHT, 0);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

//    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
//    glColor4fv( g_color_white );
    glColor3ubv(g_color_table); // note - 3ubv => not reading the fourth (alpha)

//    glViewport(0, 0, WIDTH, HEIGHT);

    // Begin the glow
    //glColor4fv( g_color_white );
    int w = glowBaseTextureWidth / 2, h = glowBaseTextureHeight / 2;
    for (int a = 1; a < textures; ++a)
    {
        glViewport(0, 0, w, h);
        glBindTexture(GL_TEXTURE_2D, texture[a - 1]);
        glBegin(GL_QUADS);
        glTexCoord2f(0, 1); glVertex3f(0, 0, 0);
        glTexCoord2f(1, 1); glVertex3f(WIDTH, 0, 0);
        glTexCoord2f(1, 0); glVertex3f(WIDTH, HEIGHT, 0);
        glTexCoord2f(0, 0); glVertex3f(0, HEIGHT, 0);
        glEnd();
        glBindTexture(GL_TEXTURE_2D, texture[a]);
        glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, w, h, 0);
        w /= 2;
        h /= 2;
    }

//    glClearColor(0, 0, 0, 1);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
}


void endGlow()
{
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();

    glMatrixMode(GL_PROJECTION);
    glPopMatrix();

    glPopAttrib();
}


void glowRender()
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glViewport(0, 0, WIDTH, HEIGHT);
    unsigned char o = g_color_table[3];
    for (int a = textures - 1; a >= 0; --a)
    {
        glBindTexture(GL_TEXTURE_2D, texture[a]);
        glColor4ubv(g_color_table);
        g_color_table[3] = (unsigned char)(g_color_table[3] * 15 / 16);
        glBegin(GL_QUADS);
        glTexCoord2f(0, 1); glVertex2f(0, 0);
        glTexCoord2f(1, 1); glVertex2f(WIDTH, 0);
        glTexCoord2f(1, 0); glVertex2f(WIDTH, HEIGHT);
        glTexCoord2f(0, 0); glVertex2f(0, HEIGHT);
        glEnd();
    }
    g_color_table[3] = o;
}
