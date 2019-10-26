#include <windows.h>
#include <GL/gl.h>
#include <GL/glext.h>

// /CRINKLER /COMPMODE:SLOW /HASHSIZE:200 /HASHTRIES:50 /ORDERTRIES:6000
// /UNSAFEIMPORT
// 1024 bytes 

///////////////////////////////////////////////////////////////////
// WINDOWING
#define SCREENX 1024
#define SCREENY 768

#pragma data_seg(".pfd")
PIXELFORMATDESCRIPTOR pfd={
0, // Size Of This Pixel Format Descriptor... BAD coding, nothing new, saves 6 bytes
1, PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER, 32, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0 
};
#pragma data_seg(".dms")
DEVMODE dmScreenSettings={
"",0,0,sizeof(dmScreenSettings),0,DM_PELSWIDTH|DM_PELSHEIGHT,
0,0,0,0,0,0,0,0,0,0,0,0,0,"",0,0,SCREENX,SCREENY,0,0,0,0,0,0,0,0,0,0
};
 
/////////////////////////////////////////////////////////////////
// SHADERS 
#pragma data_seg(".shad1")
char *vsh="\
varying vec3 s[4];\
void main(){\
gl_Position=gl_Vertex;\
s[0]=vec3(0);\
s[3]=vec3(sin(abs(gl_Vertex.x*.0001)),cos(abs(gl_Vertex.x*.0001)),0);\
s[1]=s[3].zxy;\
s[2]=s[3].zzx;\
}"; 

#pragma data_seg(".shad2")
char *fsh="\
varying vec3 s[4];\
void main(){\
float t,b,c,h=0;\
vec3 m,n,p=vec3(.2),d=normalize(.001*gl_FragCoord.rgb-p);\
for(int i=0;i<4;i++){\
t=2;\
for(int i=0;i<4;i++){\
b=dot(d,n=s[i]-p);\
c=b*b+.2-dot(n,n);\
if(b-c<t)if(c>0){m=s[i];t=b-c;}\
}\
p+=t*d;\
d=reflect(d,n=normalize(p-m));\
h+=pow(n.x*n.x,44.)+n.x*n.x*.2;\
}\
gl_FragColor=vec4(h,h*h,h*h*h*h,h);\
}"; 

#pragma code_seg(".compile")
__forceinline void compileShader() {
GLuint s,p;
	    
        p = ((PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram"))();
		
		s = ((PFNGLCREATESHADERPROC)(wglGetProcAddress("glCreateShader")))(GL_VERTEX_SHADER);
		((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource")) (s, 1, (const GLchar**)(&vsh), NULL);
	    ((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))(s);
	    ((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader")) (p,s);
		
         s = ((PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader"))(GL_FRAGMENT_SHADER);	
		((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource")) (s, 1, (const GLchar**)(&fsh), NULL);
		((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))(s);
		((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader")) (p,s);

		((PFNGLLINKPROGRAMPROC)wglGetProcAddress("glLinkProgram"))(p);
		((PFNGLUSEPROGRAMPROC) wglGetProcAddress("glUseProgram"))(p);
}

//////////////////////////////////////////////////////////////////
//  MAIN ROUTINE

#pragma code_seg(".main")
void WINAPI WinMainCRTStartup()
{
int t;
   ChangeDisplaySettings (&dmScreenSettings,CDS_FULLSCREEN); 
   HDC hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0) );
   SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
   wglMakeCurrent ( hDC, wglCreateContext(hDC) );
   ShowCursor(FALSE); 
   compileShader();
loop: 
    t=GetTickCount();
	glRecti(t,t,-t,-t);
	SwapBuffers(hDC);
	if (GetAsyncKeyState(VK_ESCAPE)) ExitProcess(0);
	goto loop;  
}
