// Crawlspace

// Thanks to Auld, Polaris, S-Tec, Benny, and many more for your work at in4k.untergrund.net.
//  This wouldn't be possible *at all* without you.

// (C) 2008 Ferris & Decipher / Youth Uprising

#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN

#include <windows.h>
#include <GL/gl.h>
#include <GL/glext.h>

// Shaders
const static char *shaders_vertex = "varying vec4 x;"
"void main(){"
"x=gl_ModelViewMatrix[0];"
"gl_Position=gl_Vertex;"
"}";
const static char *shaders_fragment = "varying vec4 x;"
"void main(){"
"vec3 y=normalize(vec3(gl_FragCoord.xy/400-1,1));"
//"x.xy=vec2(cos(x.y),sin(x.y));"
"y=vec3(y.x,y.y*x.x+y.z*x.y,y.z*x.x-y.y*x.y)*.2;"
//"y=vec3(y.x*x.x+y.z*x.y,y.y,y.z*x.x-y.x*x.y)*.2;"
//"y=vec3(y.x*x.x+y.y*x.y,y.y*x.x-y.x*x.y,y.z)*.2;"
"for(float i=0;i<50;i++){"
"x.x=abs(sin((x.z*30+y.z*i)*.3));"
"if(length(y.xy*i)>sin((x.z*30+y.z*i)*.4+atan(y.x,y.y)*3)+2)i=50;"
"}"
"x.z=abs(sin(x.z*2));"
"x.w=1-x.z;"
"gl_FragColor=vec4(x.x*x.x*x.x*x.z+x.x*x.w,x.x*x.x,x.x*x.z+x.x*x.x*x.x*x.w,1);"
"}";
static GLuint v,f,p;

PIXELFORMATDESCRIPTOR pfd = {0,0,PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,PFD_TYPE_RGBA,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
void WinMainCRTStartup() {
    HDC hDC = GetDC(CreateWindow("edit",0,WS_POPUP | WS_VISIBLE | WS_MAXIMIZE,0,0,0,0,0,0,0,0));
    SetPixelFormat(hDC,ChoosePixelFormat(hDC,&pfd),&pfd);
    wglMakeCurrent(hDC,wglCreateContext(hDC));
    ShowCursor(FALSE);
    v = ((PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader"))(GL_VERTEX_SHADER);
    f = ((PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader"))(GL_FRAGMENT_SHADER);
    p = ((PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram"))();
    ((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource"))(v,1,&shaders_vertex,NULL);
    ((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource"))(f,1,&shaders_fragment,NULL);
    ((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))(v);
    ((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))(f);
    ((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader"))(p,v);
    ((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader"))(p,f);
    ((PFNGLLINKPROGRAMPROC)wglGetProcAddress("glLinkProgram"))(p);
    ((PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram"))(p);
    do {
        glRotatef(1,1,1,1);
        glRecti(-1,-1,1,1);
        SwapBuffers(hDC);
    } while(!GetAsyncKeyState(VK_ESCAPE));
    ExitProcess(0);
}
