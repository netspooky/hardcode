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


extern "C"
{
	int _fltused = 0;
}



#pragma data_seg(".pfd")
PIXELFORMATDESCRIPTOR pfd=
{
	0, // Size Of This Pixel Format Descriptor... BAD coding, nothing new, saves 6 bytes
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
#pragma data_seg(".shad1")
char *vsh="\
varying vec4 p;\
varying vec4 n;\
void main(){\
	gl_Position = ftransform();\
	p=gl_Vertex;\
	n=gl_Color;\
}";

#pragma data_seg(".shad2")
char *fsh="\
varying vec4 p;\
varying vec4 n;\
void main(){\
	float x,y,z,u,v,PI,uu,vv,a,c,t,q1,q2,l1,d;\
	PI=3.14;\
	t=n.x;\
	x=p.x*1.6*n.y;\
	y=p.y*n.y;\
	if(sqrt(x*x+y*y)>1) return;\
	d=pow(1-sqrt(x*x+y*y),0.9);\
	y=y*cos(0.15*n.a)+sqrt(1-x*x-y*y)*sin(0.15*n.a);\
	v = acos(y)/PI;\
	u = acos(x/(sin(v*PI)))/(2*PI);\
	vv=v*100*0.6;\
	q1=int(vv/PI);\
	uu=u*200*0.6+mod(t,50*PI);\
	q2=int((uu+PI/2)/PI);\
	q1=cos(q1);\
	l1=q1+sin(q2+t*0.6+cos(q1*25));\
	a=cos(uu)*sin(vv);\
	c=pow(abs(a),0.2)*0.1/l1*d;\
	if(c<0)\
		gl_FragColor=vec4(-(c*1)/2,0,-(c*2),n.z);\
	else\
		gl_FragColor=vec4(c,c*2,c*2,n.z);\
}";

//0.8 => 0.5    	x=p.x*1.6*n.y;\
//gl_FragColor=vec4(-(c*2)/2,-(c/2)/2,0,n.z);




#pragma code_seg(".compile")
__forceinline void compileShader()
{	
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
	int i;
	float t;

	ChangeDisplaySettings (&dmScreenSettings,CDS_FULLSCREEN);
	HDC hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0) );
	SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
	wglMakeCurrent ( hDC, wglCreateContext(hDC) );
	ShowCursor(FALSE);
	compileShader();

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


	//PlaySound(s,NULL,SND_MEMORY | SND_LOOP );
	loop:

		//t=GetTickCount();
		t=GetTickCount()*0.001f;


		glClear(GL_COLOR_BUFFER_BIT);


		glColor4f(-t,0.5f,0.05f,-1);
		glRecti(-1,-1,1,1); 

		for(i=40;i>=0;i--)
		{
			float a;
			if(i==40) a=1.0f; else a=0.002f+i*0.0005f;
			glColor4f(t,(i/200.0f)*6.0f+0.4f,a,1);
			glRecti(-1,-1,1,1);
		}

		SwapBuffers(hDC);
		if (GetAsyncKeyState(VK_ESCAPE)) ExitProcess(0);
	goto loop;
}
