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

    
    NOTE:
    This code is based on initialization code found in the IN4K site.
        http://in4k.untergrund.net
    Below is the original copyright notice from the base init code:
    // (c) Auld 2005
    // Re-use granted as long as long as you give credit in
    // either your demo or accompanying files please.    
*/

#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>

#include "Native.h"
#include "Ground.h"
#include "Dome.h"
#include "Mirrors.h"
#include "Ray.h"
#include "synth.h"
#include "glow.h"
#include "glow.cpp"

#define WIDTH 800
#define HEIGHT 600

#define FPS 30
#define MS_PER_FRAME (1000/FPS)
#define SECS_PER_FRAME (1.f/FPS)

#define GLOW_FACTOR 100

//#define NO_SOUND

static float g_light_pos[] = { 0, 0, 0, 1 };

//#pragma code_seg( "c1" )

void InitGL()
{
    // Set the projection matrix
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    gluPerspective( FLOAT_INT(75), (float)WIDTH/HEIGHT, 1, 1000 );
    
    // Set the default to modelview
    glMatrixMode( GL_MODELVIEW );
    glLoadIdentity();
    
    glLightfv( GL_LIGHT0, GL_POSITION, g_light_pos );
}

static float cam_rot = 0;
static float cam_dist = 25;
static float cam_height = 15;

static void UpdateNormal()
{
    // Camera update
    glLoadIdentity();
    gluLookAt( 0, cam_height, cam_dist, 0, /*My_Abs(My_Sin(cam_rot/20)*20)*/17, 0, 0, 1, 0 );
    glRotatef( cam_rot, 0, 1, 0 );
    cam_rot += 0.5f;
    
    DrawGround();
    DrawDome();
}

static void UpdateFadeIn()
{
    UpdateNormal();
    
    if ( g_color_table[3] < GLOW_FACTOR )
        g_color_table[3]++;
}

static bool g_mirror_show_flash = true;

static void UpdateMirrorsMove()
{
    if ( g_color_table[3] > GLOW_FACTOR )
        g_color_table[3] -= 2;
    if ( g_mirror_show_flash )
    {
        g_mirror_show_flash = false;
        g_color_table[3] = 206;
    }
    
    UpdateNormal();
    
    UpdateMirrors();
    DrawMirrors();
}

static float mirr_mode_time = 0;

static void UpdateMirrorsDrop()
{
    mirr_mode_time -= SECS_PER_FRAME;
    if ( mirr_mode_time <= 0 )
    {
        g_verlet_gravity = 10 - g_verlet_gravity;
        mirr_mode_time = 3;
    }
    UpdateMirrorsMove();
}

static bool g_mirror_show_flash2 = true;

static void UpdateMirrorsRays()
{
    if ( g_color_table[3] > GLOW_FACTOR )
        g_color_table[3] -= 2;
    if ( g_mirror_show_flash2 )
    {
        g_mirror_show_flash2 = false;
        g_color_table[3] = 206;
    }
    
    UpdateMirrorsDrop();
    CastAndDrawRays();
}

static void UpdateMoveAway()
{
    if ( cam_height < 30 )
    {
        cam_height += 0.15f;
        cam_dist += 0.1f;
    }
    
    UpdateMirrorsRays();
}

static void UpdateFadeOut()
{
    UpdateMoveAway();
    
    if ( g_color_table[3] > 0 )
        g_color_table[3]--;
}

//#pragma data_seg( "g1" )

// Sequences
typedef void (*SeqFunc)();
static unsigned char g_seq_times[] =
{
    21,	        // UpdateFadeIn
    70,         // UpdateMirrorsMove
    80,         // UpdateMirrorsDrop
    150,        // UpdateMirrorsRays
    180,        // UpdateMoveAway
    190,        // UpdateFadeOut
    190,
};

//#pragma data_seg( "g2" )

static SeqFunc g_seq_funcs[] =
{
    UpdateFadeIn,
    UpdateMirrorsMove,
    UpdateMirrorsDrop,
    UpdateMirrorsRays,
    UpdateMoveAway,
    UpdateFadeOut,
    0,
};

extern "C" int _fltused = true;

//#pragma code_seg( "c2" )


#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrev, LPSTR szCmdLine, int sw)
#else
void WINAPI WinMainCRTStartup()
#endif
{
    PIXELFORMATDESCRIPTOR pfd;
    pfd.cColorBits = pfd.cDepthBits = 32;
    pfd.dwFlags    = PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;

#ifdef NDEBUG
    DEVMODE deviceMode;
    deviceMode.dmSize = sizeof(deviceMode);
    deviceMode.dmPelsWidth = WIDTH;
    deviceMode.dmPelsHeight = HEIGHT;
    deviceMode.dmBitsPerPel = 32;
    deviceMode.dmFields = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT;
    
    ChangeDisplaySettings(&deviceMode, CDS_FULLSCREEN);
#endif
    
#ifdef NDEBUG
    HDC hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0) );
#else
    HDC hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE, 0, 0, 800, 600, 0, 0, 0, 0) );
#endif
    SetPixelFormat( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
    wglMakeCurrent( hDC, wglCreateContext(hDC) );
    
    ShowCursor(FALSE);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    SwapBuffers(hDC);
    
    // Init
    InitGL();
    glowInitTextures();
    InitDome( g_dome_panels, g_dome_verlets, 1, 0 );
    InitMirrors();
    
#ifndef NO_SOUND
    initAndStartSound();
#endif
    
    // Run
    DWORD start = GetTickCount();
    int run_time = 0;
    int cur_seq = 0;
    do
    {
        // Get frames to advance
        DWORD cur = GetTickCount();
        DWORD diff = cur - start;
        if ( diff > 10000 )
        {
            start = cur;
            continue;
        }
        
        int frames = diff / MS_PER_FRAME;
        if ( frames <= 0 )
            continue;
        
        int ms = frames * MS_PER_FRAME;
        run_time += ms;
        start += ms;
        
        // Advance the sequnce
        //int runtime_sec = run_time >> 10; // roughly /1000
        int runtime_sec = run_time >> 9;
        if ( runtime_sec > g_seq_times[ cur_seq ] )
            ++cur_seq;
        SeqFunc update_func = g_seq_funcs[ cur_seq ];
        if ( update_func == 0 )
            break;
        
        // Advance
        beginBaseTextureRender();
        while ( frames-- > 0 )
        {
            // Init the OpenGL
            glShadeModel( GL_SMOOTH );
            
            glEnable( GL_NORMALIZE );
            
            glEnable( GL_LIGHTING );
            glEnable( GL_LIGHT0 );
            glLightModeli( GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE );
            
            glEnable( GL_COLOR_MATERIAL );
            //glColorMaterial( GL_FRONT_AND_BACK, GL_DIFFUSE );
            
            glEnable( GL_DEPTH_TEST );
            glDisable( GL_CULL_FACE );
            
            glEnable( GL_BLEND );
            glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
            //glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
            
            glLineWidth( 7 );
            
            glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
            
            // Update & render
            update_func();
        }
        endBaseTextureRender();
        beginGlow();
        glowRender();
        endGlow();
        
        // Swap it
        SwapBuffers( hDC );
#ifndef NO_SOUND
        //updateSound();
#endif
        Sleep(1);
    } while ( !GetAsyncKeyState(VK_ESCAPE) );
    
#ifdef NDEBUG
    ChangeDisplaySettings( NULL, 0 );
#endif
    ExitProcess( 0 );

#ifdef _DEBUG
    return 0;
#endif
}
