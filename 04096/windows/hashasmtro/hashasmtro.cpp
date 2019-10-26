/* for asm compo 6 2002 
    compile with -
    cl /O1ityb2 /Gs /G6 /FAs /QIfist hashasmtro.cpp /link
        /nodefaultlib /entry:main kernel32.lib user32.lib gdi32.lib
        opengl32.lib glu32.lib /align:4096 /merge:.text=.data
        /merge:.rdata=.data /subsystem:windows
*/

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
//#include "glext.h"
//#include "wglext.h"
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define FULLSCREEN

typedef unsigned char u8;
typedef unsigned int u32;

static const char scrolltext[] =
    "                 * * * #asm compo 6 - greetz 2 : "
    "<3 DAL9000   Scali   kartz3h   brain   Spec-Chum   "
    "hex86   Kalms   mcarp   med   ACE1013   Advant   <3 vulture :D                   ";

inline __int64 rdtsc() { __asm rdtsc }

#define g_width 640
#define g_height 480
const float PI = 3.1415926535f;
extern "C" int _fltused = 0x1234;
GLuint font1, font2;
GLuint textures;
__int64 tickfreq, starttime;
unsigned int rand_seed;
inline void srand(u32 x) { rand_seed = x; }
inline int rand() { return (rand_seed = rand_seed * 0x343fd + 0x269ec3) & 0xffff; }
inline float rand2(float min, float max) { return ((rand() % 1000) / 1000.0f) * (max - min) + min; }
inline void hu() { glColor4f(1, 1, 1, 0.4); }

void scroller(GLuint font, float t, int lines)
{
    glListBase(font);
    int scx = int(t*3)%165;

    for (int i = 0; i < 22; i++)
    {
        float iscx = i+scx;
        glPushMatrix();
        glTranslatef((i-11-(t*3-int(t*3)))*0.3, -0.2+sin(t*0.9+iscx*5)*0.2, -1.5);
        glRotatef(sin(t+iscx)*30, 0, 1, 0);
        glRotatef(sin(t*1.3+iscx)*30, 1, 0, 0);
        if (lines) hu();
        else glColor4f(sin(iscx)*0.5+0.5, sin(iscx+2.08)*0.5+0.5, sin(iscx+4.19)*0.5+0.5, 0.2);
        glCallLists(1, GL_BYTE, scrolltext+int(iscx));
        glPopMatrix();                          
    }
}
        
void run()
{
    float t = double(rdtsc() - starttime) / double(tickfreq);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glEnable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_LIGHTING);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glBegin(GL_QUADS);
    glColor4f(0.4f, 0.5f, 0.6f, 0.2f);
    glVertex3f(-1.0f, 1.0f, 1.0f);
    glVertex3f(1.0f, 1.0f, 1.0f);
    glColor4f(0.0f, 0.1f, 0.2f, 0.2f);
    glVertex3f(1.0f, -1.0f, 1.0f);
    glVertex3f(-1.0f, -1.0f, 1.0f);
    glEnd();

    glMatrixMode(GL_PROJECTION);
    gluPerspective(70, 1.33, 0.01, 20);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    gluLookAt(0, 0, 0, 0, 0, -10, 0, 1, 0);
                                                    
    glEnable(GL_LIGHT0);
    glEnable(GL_COLOR_MATERIAL);
    glEnable(GL_LINE_SMOOTH);

    glRotatef(sin(t)*15, 0, 1, 0);
    glRotatef(sin(t*1.3)*15, 1, 0, 0);
    hu();

    glEnable(GL_TEXTURE_2D);

    srand(0);
    for (int fz = 0; fz < 20; fz++)
    {
        float s = 0.5;
        float z = (fz-(t-int(t)))*0.2;
        glPushMatrix();
        glRotatef((fz+int(t))*140, 0, 0, 1);
        glBegin(GL_QUADS);
        glTexCoord2i(0, 0); glVertex3f(-s, -s, -z);
        glTexCoord2i(1, 0); glVertex3f(s, -s, -z);
        glTexCoord2i(1, 1); glVertex3f(s, s, -z);
        glTexCoord2i(0, 1); glVertex3f(-s, s, -z);
        glEnd();
        glPopMatrix();
    }

    glDisable(GL_TEXTURE_2D);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glEnable(GL_LIGHTING);
    scroller(font1, t, 0);
    glDisable(GL_LIGHTING);
    scroller(font2, t, 1);
}

void makefont(HDC hdc, GLuint listbase, GLuint type)
{
    wglUseFontOutlines(hdc, 0, 255, listbase, 0.001f, 0.2f, type, 0);
}

void main()
{
    PIXELFORMATDESCRIPTOR pfd;
    HDC hdc;
    int pixelFormat;

#ifdef FULLSCREEN
    DEVMODE dmScreenSettings;
#endif

    memset(&pfd, 0, sizeof(PIXELFORMATDESCRIPTOR));
    pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 32;
    pfd.cDepthBits = 16;
    pfd.iLayerType = PFD_MAIN_PLANE;

#ifdef FULLSCREEN
    memset(&dmScreenSettings, 0, sizeof(dmScreenSettings));
    dmScreenSettings.dmSize = sizeof(dmScreenSettings);
    dmScreenSettings.dmPelsWidth = g_width;
    dmScreenSettings.dmPelsHeight = g_height;
    dmScreenSettings.dmBitsPerPel = 32;
    dmScreenSettings.dmFields = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT;

    if (ChangeDisplaySettings(&dmScreenSettings, CDS_FULLSCREEN) != DISP_CHANGE_SUCCESSFUL)
        return;
#endif

    hdc = GetDC(CreateWindow("STATIC", "",
        WS_POPUP | WS_CLIPSIBLINGS | WS_CLIPCHILDREN |
        WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
        0, 0, g_width, g_height, 0, 0, GetModuleHandle(0), 0));
    pixelFormat = ChoosePixelFormat(hdc, &pfd);
    SetPixelFormat(hdc, pixelFormat, &pfd);
    wglMakeCurrent(hdc, wglCreateContext(hdc));
//    SetCursor(0);

    // --------------------------------------------------------
    // INIT
    // --------------------------------------------------------

    HFONT font;
    font1 = glGenLists(256);
    font2 = glGenLists(256);

    font = CreateFont(-12, 0, 0, 0, 0, FALSE, FALSE, FALSE,
        ANSI_CHARSET, OUT_OUTLINE_PRECIS, CLIP_DEFAULT_PRECIS,
        ANTIALIASED_QUALITY, FF_DONTCARE, "tahoma");
    SelectObject(hdc, font);
    makefont(hdc, font1, WGL_FONT_POLYGONS);
    makefont(hdc, font2, WGL_FONT_LINES);

    glGenTextures(1, &textures);
    glBindTexture(GL_TEXTURE_2D, textures);
    u8 *texdata = (u8 *)HeapAlloc(GetProcessHeap(), 0, 256*256*4);
    {
        int x, y;
        u8 *t = texdata;
        float fx, fy;
        static const float float1o128 = 1.0f/128.0f;

        fy = -1.0f;
        for (y=0; y<256; y++)
        {
            fx = -1.0f;
            for (x=0; x<256; x++)
            {
                t[0] = t[1] = t[2] = ((rand()&0xff00)>>8);
                t[3] = ((rand()%10000)>9000)?((1-(sqrt(fx*fx+fy*fy)/(sqrt(2))))*255):0;
                t += 4;
                fx+=float1o128;
            }
            fy+=float1o128;
        }
    }

    gluBuild2DMipmaps(GL_TEXTURE_2D, 4, 256, 256, GL_RGBA, GL_UNSIGNED_BYTE, texdata);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // --------------------------------------------------------
    // RUN
    // --------------------------------------------------------

    starttime = rdtsc();
    Sleep(1000);
    tickfreq = rdtsc() - starttime;

    while (!GetAsyncKeyState(VK_ESCAPE))
    {
        run();
        SwapBuffers(hdc);
    } 

    // --------------------------------------------------------
    // CLEANUP
    // --------------------------------------------------------
  
    ExitProcess(0);
}


