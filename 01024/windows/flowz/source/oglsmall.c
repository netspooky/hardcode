// Flowz
// =====

// Framework by Auld
// Intro code by Optimus

#include <windows.h>
#include <GL/gl.h>
#include <math.h>

#define sn 128
double sx[sn], ss[sn];

int WINAPI WinMainCRTStartup()
{
   MSG m;                 
   PIXELFORMATDESCRIPTOR pfd;  
   PVOID hDC = CreateWindow("EDIT", 0, 
                        WS_POPUP|WS_VISIBLE, 
                        0, 0,
                        GetSystemMetrics(SM_CXSCREEN), 
                        GetSystemMetrics(SM_CYSCREEN),
                        0, 0, 0, 0);
   hDC = GetDC(hDC);
   ShowCursor(FALSE);           
   pfd.cColorBits = pfd.cDepthBits = 32; 

   pfd.dwFlags    = PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;			
   SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
   wglMakeCurrent ( hDC, wglCreateContext(hDC) );

    int i;
    for (i=0; i<sn; i++)
        ss[i] = (rand()%4096)/8192.0 -0.25;

    glBlendFunc(GL_SRC_ALPHA,GL_SRC_COLOR);
    glEnable(GL_BLEND);

   do {
       glClearColor(0.15, 0.0, 0.3, 1.0);
       glClear  (GL_DEPTH_BUFFER_BIT|GL_COLOR_BUFFER_BIT);

       // insert Breakpoint winning 4kdemo here

    for (i=0; i<sn; i++)
    {
        sx[i] -=  ss[i]/32.0;
        if (sx[i]<-1.5)
            sx[i] = 1.5;
        if (sx[i]>1.5)
            sx[i] = -1.5;
        glLoadIdentity();
        glTranslatef(sx[i], ((float)2*i / sn - 1.0), 0.0);

        glBegin(GL_TRIANGLE_FAN);
        glColor4f((float)i/sn, 0.75-sx[i], 0.5, 1.0);
        glVertex2f(0.0, 0.0);
        glColor4f(0.25, 0.0, 0.3, 0.5);

        int j;
        double r;
        for (j=0; j<=360; j+=2)
        {
            r = (sin(6.0*(j+GetTickCount()/8.0)/57.3)/9.0 + sin(8.0*(j+0.5*GetTickCount()/8.0)/57.3)/4.0 + 0.5)*ss[i];
            glVertex2f(sin(j/57.3)*r,cos(j/57.3)*r);
        }
        glEnd();
    }


    	SwapBuffers(hDC);
       PeekMessage(&m, 0, 0, 0, PM_REMOVE);     
    } while ( m.wParam ^ VK_ESCAPE);
}
