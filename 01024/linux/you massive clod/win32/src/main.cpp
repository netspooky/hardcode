#include <windows.h>
#include <GL/gl.h>
#include <GL/glext.h>


///////////////////////////////////////////////////////////////////
// WINDOWING
#define SCREENX 1024	
#define SCREENY 768


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
varying vec4 c;\
float f(vec3 o){\
	float a=(sin(o.x)+o.y*.25)*.35;\
	o=vec3(cos(a)*o.x-sin(a)*o.y,sin(a)*o.x+cos(a)*o.y,o.z);\
	return dot(cos(o)*cos(o),vec3(1))-1.2;\
}\
vec3 s(vec3 o,vec3 d){\
	float t=0.,a,b;\
	for(int i=0;i<75;i++){\
		if(f(o+d*t)<0){\
			a=t-.125;b=t;\
			for(int i=0; i<10;i++){\
				t=(a+b)*.5;\
				if(f(o+d*t)<0)b=t;else a=t;\
			}\
		vec3 e=vec3(.1,0,0),\
		p=o+d*t,\
		n=-normalize(vec3(f(p+e),f(p+e.yxy),f(p+e.yyx))+vec3((sin(p*75.)))*.01);\
		return vec3(\
				mix( ((max(-dot(n,vec3(.577)),0.) + 0.125*max(-dot(n,vec3(-.707,-.707,0)),0.)))*(mod(length(p.xy)*20.,2.)<1.0?vec3(.71,.85,.25):vec3(.79,.93,.4))\
				,vec3(.93,.94,.85),\
				vec3(pow(t/9.,5.))\
				)\
			);\
		}\
		t+=.125;\
	}\
	return vec3(.93,.94,.85);\
}\
void main(){\
	float t=dot(gl_Color.xyz,vec3(1,256,65536))*.5;\
	gl_FragColor=vec4(s(vec3(sin(t*1.5)*.5,cos(t)*.5,t), normalize(vec3((gl_FragCoord.xy-vec2(512,384))/vec2(512),1))),1);\
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
	unsigned int t;	

	ChangeDisplaySettings (&dmScreenSettings,CDS_FULLSCREEN);
	HDC hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0) );
	SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
	wglMakeCurrent ( hDC, wglCreateContext(hDC) );
	ShowCursor(FALSE);
	compileShader();
	
	loop:

		t=GetTickCount();

		glClear(GL_COLOR_BUFFER_BIT);

		glColor4ubv((unsigned char*)&t);
		glRecti(-1,-1,1,1);
		SwapBuffers(hDC);
		if (GetAsyncKeyState(VK_ESCAPE)) ExitProcess(0);
	goto loop;
}
