#include <windows.h>
#include <GL/gl.h>
#include <GL/glext.h>


///////////////////////////////////////////////////////////////////
// WINDOWING
#define SCREENX 640	
#define SCREENY 480

#pragma comment(linker, "/OPT:NOWIN98")


#pragma data_seg(".pfd")
PIXELFORMATDESCRIPTOR pfd=
{
	0,
	1, PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER, 32, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0 
};

#pragma data_seg(".dms")
DEVMODE dmScreenSettings=
{
	"",0,0,sizeof(dmScreenSettings),0,DM_PELSWIDTH|DM_PELSHEIGHT,
	0,0,0,0,0,0,0,0,0,0,0,0,0,"",0,0,SCREENX,SCREENY,0,0,0,0,0,0,0,0
};


/////////////////////////////////////////////////////////////////
// SHADERS 
#pragma data_seg(".shad")
char *fsh="\
vec4 s(float z,float w)\
{\
float x,y,k,u,v,t,q,c,r,P=3.14159265;\
t=(gl_Color.r+gl_Color.g*256+gl_Color.b*65536)*.2*w;\
x=(gl_FragCoord.x-320)*z*.0065;\
y=(gl_FragCoord.y-240)*z*.006;\
c=sqrt(x*x+y*y);\
if(c>1) return vec4(0,0,0,0);\
r=.4*w+sin(-t*.05);\
k=y*sin(r)-sqrt(1-x*x-y*y)*cos(r);\
y=y*cos(r)+sqrt(1-x*x-y*y)*sin(r);\
v=acos(y);\
u=acos(x/(sin(v)))/(2*P)*120*sign(k)-t;\
v=v*60/P;\
q=cos((float)int(v/P));\
c=pow(abs(cos(u)*sin(v)),0.2)*.1/(q+sin(int((u+P/2)/P)+t*.6+cos(q*25)))*pow(1-c,.9);\
if(c<0)\
 return vec4(-c/2*abs(cos(t)),0,-c*2*abs(sin(t)),1);\
else\
 return vec4(c,c*2,c*2,1);\
}\
void main(){\
vec4 c,d;\
for(int i=80;i>0;i--)\
{\
c+=s(1-i/80.0,1)*(.008-i*.00005);\
}\
d=s(1,1);\
gl_FragColor=s(.2,-1)*(1-d.a)*.02+(d*d.a)+sqrt(c);\
}";


#pragma code_seg(".compile")
__forceinline void compileShader()
{	
	GLuint s,p;
	p = ((PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram"))();	

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
	unsigned int t,oldt;	
	HDC hDC;

	ChangeDisplaySettings (&dmScreenSettings,CDS_FULLSCREEN);
	hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0) );
	SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
	wglMakeCurrent ( hDC, wglCreateContext(hDC) );
	ShowCursor(FALSE);
	compileShader();


	oldt=GetTickCount();
	loop:

		t=GetTickCount()-oldt;

		glClear(GL_COLOR_BUFFER_BIT);				
		glColor4ubv((unsigned char*)&t);
		//glColor4uiv(&t);
		glRecti(-1,-1,1,1);
		SwapBuffers(hDC);
		if (GetAsyncKeyState(VK_ESCAPE)) ExitProcess(0);
	goto loop;
}
