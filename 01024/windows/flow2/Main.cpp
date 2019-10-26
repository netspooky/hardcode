// Chris Thornborrow (auld/sek/taj/copabars)
// If you use this code please credit...blahblah
// Example OGL + shaders in 1k
// Requires crinkler - magnificent tool
// VS2005 modifications by benny!weltenkonstrukteur.de from dbf
//    Greets!

// NOTE: DX will beat this no problem at all due to OpenGL forced
// to import shader calls as variables..nontheless we dont need
// d3dxblahblah to be loaded on users machine.

#include <windows.h>
#include <GL/gl.h>
#include "glext.h"

// NOTE: in glsl it is legal to have a fragment shader without a vertex shader
//  Infact ATi/AMD  drivers allow this but unwisely forget to set up variables for
// the fragment shader - thus all GLSL programs must have a vertex shader :-(
// Thanks ATI/AMD

// This is prtty dirty...note we do not transform the rectangle but we do use
// glRotatef to pass in a value we can use to animate...avoids one more getProcAddress later
const GLchar *vsh="\
varying vec4 p;\
void main(){\
p=sin(gl_ModelViewMatrix[1]*9.0);\
gl_Position=gl_Vertex;\
}";

// an iterative function for colour
const GLchar *fsh="\
varying vec4 p;\
void main(){\
float r,t,j;\
vec4 v=gl_FragCoord/400.0-1.0;\
r=v.x*p.r;\
for(int j=0;j<7;j++){\
t=v.x+p.r*p.g;\
v.x=t*t-v.y*v.y+r;\
v.y=p.g*3.0*t*v.y+v.y;\
}\
gl_FragColor=vec4(mix(p,vec4(t),max(t,v.x)));\
}";
//p.g*3.0*t*v.y+i;\

typedef void (*GenFP)(void); // any function ptr type would do
static GenFP glFP[7];

const static char* glnames[]={
      "glCreateShader", "glCreateProgram", "glShaderSource", "glCompileShader", 
      "glAttachShader", "glLinkProgram", "glUseProgram"
};

static void setShaders() {
int i;
   // 19. April 2007:	"(GenFP) cast" added by benny!weltenkonstrukteur.de
   for (i=0; i<7; i++) glFP[i] = (GenFP)wglGetProcAddress(glnames[i]);
	
		GLuint v = ((PFNGLCREATESHADERPROC)(glFP[0]))(GL_VERTEX_SHADER);
		GLuint f = ((PFNGLCREATESHADERPROC)(glFP[0]))(GL_FRAGMENT_SHADER);	
        GLuint p = ((PFNGLCREATEPROGRAMPROC)glFP[1])();
		
        ((PFNGLSHADERSOURCEPROC)glFP[2]) (v, 1, &vsh, NULL);
		((PFNGLCOMPILESHADERPROC)glFP[3])(v);
		((PFNGLSHADERSOURCEPROC)glFP[2]) (f, 1, &fsh, NULL);
		((PFNGLCOMPILESHADERPROC)glFP[3])(f);
			
		((PFNGLATTACHSHADERPROC)glFP[4])(p,v);
		((PFNGLATTACHSHADERPROC)glFP[4])(p,f);
	
		((PFNGLLINKPROGRAMPROC)glFP[5])(p);
		((PFNGLUSEPROGRAMPROC) glFP[6])(p);
}


// force them to set everything to zero by making them static
static PIXELFORMATDESCRIPTOR pfd;
static DEVMODE dmScreenSettings;

void WINAPI WinMainCRTStartup()
{
   dmScreenSettings.dmSize=sizeof(dmScreenSettings);		
   dmScreenSettings.dmPelsWidth	= 1024;
   dmScreenSettings.dmPelsHeight= 768;
// 	  dmScreenSettings.dmBitsPerPel	= 32;
// its risky to remove the flag and bits but probably safe on compo machine :-)
   dmScreenSettings.dmFields=DM_PELSWIDTH|DM_PELSHEIGHT;
   ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN);  
   
   // minimal windows setup code for opengl  
   pfd.cColorBits = pfd.cDepthBits = 32;
   pfd.dwFlags    = PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;	

	// "HDC hDC" changed 19. April 2007 by benny!weltenkonstrukteur.de
    HDC hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0) );

   SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
   wglMakeCurrent ( hDC, wglCreateContext(hDC) );

   setShaders();
   ShowCursor(FALSE); 

//**********************
// NOW THE MAIN LOOP...
//**********************

    // there is no depth test or clear screen...as we draw in order and cover
    // the whole area of the screen.
    do {
         //dodgy, no oglLoadIdentity- might break...
		 // change the first number to alter speed of intro...smaller is slower
		 // this is the fast version
         glRotatef(0.3f,1,1,1);
         // draw a single flat rectangle on screen...
		 glRecti(-1,-1,1,1);
         SwapBuffers(hDC);
    } while ( !GetAsyncKeyState(VK_ESCAPE) );   
}

