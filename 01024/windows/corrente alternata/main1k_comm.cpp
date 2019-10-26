/*
 Corrente Alternata - 1k intro
 by Zerothehero of Topopiccione
 24/07/2012 - Milan
 
 Compiled with Visual Studio C++ Express
 Linked with Crinkler (Thanks to Mentor and Blueberry!)
 Linked with standard library + opengl32.lib and winmm.lib
 
 Executable size: 1024 bytes
 GLSL fragment shader
 Midi drone soundtrack

 Compiled and tested on win xp x86 / Nvidia GTS450 / Pentium D
 */ 

#include <windows.h>
#include <GL/gl.h>
#include <GL/glext.h>

/*
// Uncompressed fragment shader
const GLchar *fragshd="\
	uniform float q;\
	const float di=0.7071067811865;\    //cos(45°) = sin(45°) = sqrt(2)/2 
	void main(){\
	float t=q/200.;\
	vec2 p=vec2(0.3,4.5)-gl_FragCoord.xy/100.;\
	float x=(p.x*di-p.y*di*0.9),y=(p.x*di*0.9+p.y*di);\ //plane rotation 45°
	float a,b,e,d,c;\
	for(int i=-4;i<3;i++){\
	c=sin(x+t*(float(i))/18.9)+b+y+4.;\   //sum of sines
	d=cos(y+t*(float(i))/20.0)+x+a+4.;\
	e=sin(y+t*(float(i))/17.5)+x-d+4.;\
	a-=.2/c;\
	b+=.4/d;\
	e+=.1/e;\
	}\
	gl_FragColor=vec4(sqrt(-e+a+b)/6.-0.1,sqrt(-e+a+b)/6.-0.1,sqrt(-e+a+b)/3.,1.);\
	}";
*/

const GLchar *fragshd="\
 uniform float f;\
 const float y=.707107;\
 void main(){\
 float x=f/200.;\
 vec2 s=vec2(.3,4.5)-gl_FragCoord.xy/100.;\
 float r=s.x*y-s.y*y*.9,i=s.x*y*.9+s.y*y,o,t,g,l,a;\
 for(int v=-4;v<3;v++)\
 a=sin(r+x*float(v)/18.9)+t+i+4.,l=cos(i+x*float(v)/20.)+r+o+4.,g=sin(i+x*float(v)/17.5)+r-l+4.,o-=.2/a,t+=.4/l,g+=.1/g;\
 gl_FragColor=vec4(sqrt(-g+o+t)/6.-.1,sqrt(-g+o+t)/6.-.1,sqrt(-g+o+t)/3.,1.);\
 }";


static PIXELFORMATDESCRIPTOR pfd;
static DEVMODE dmScreenSettings;

void WINAPI wMainCRTStartup()
{
	dmScreenSettings.dmSize=sizeof(dmScreenSettings);		
	dmScreenSettings.dmPelsWidth=1280;
	dmScreenSettings.dmPelsHeight=1024;
	dmScreenSettings.dmFields=DM_PELSWIDTH|DM_PELSHEIGHT;
	ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN);
	pfd.cColorBits = pfd.cDepthBits = 32;
	pfd.dwFlags    = PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
	HDC hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0) );
	SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
	wglMakeCurrent ( hDC, wglCreateContext(hDC) );

	GLuint p;
	p=((PFNGLCREATESHADERPROGRAMVPROC)wglGetProcAddress("glCreateShaderProgramv"))(GL_FRAGMENT_SHADER, 1, /*(const GLchar**)*/(&fragshd));
	((PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram"))(p);
	PFNGLUNIFORM1FPROC glUniform1f = ((PFNGLUNIFORM1FPROC)wglGetProcAddress("glUniform1f"));
	ShowCursor(FALSE);

	long t;
	long t0 = timeGetTime();

	HMIDIOUT hmidi;
	midiOutOpen(&hmidi,(UINT)-1,0,0,CALLBACK_NULL);  
	
	midiOutShortMsg(hmidi, 0x00005ac0); //channel 0, instrument 0x5a
	midiOutShortMsg(hmidi, 0x00005ac1); //channel 1, instrument 0x5a
	midiOutShortMsg(hmidi, 0x00542490); //channel 0, note on, freq 0x24 (C), vel 64
	midiOutShortMsg(hmidi, 0x00542b90); //channel 0, note on, freq 0x2b (F), vel 64
	midiOutShortMsg(hmidi, 0x00543090); //channel 0, note on, freq 0x30 (C), vel 64
	midiOutShortMsg(hmidi, 0x00642491); //channel 1, note on, freq 0x24 (C), vel 64
	midiOutShortMsg(hmidi, 0x00642b91); //channel 1, note on, freq 0x2b (F), vel 64
	midiOutShortMsg(hmidi, 0x00543091); //channel 1, note on, freq 0x30 (C), vel 64
	midiOutShortMsg(hmidi, 0x00543c91); //channel 1, note on, freq 0x3c (C), vel 64

	do {
		t= (long)timeGetTime() - t0;
		glUniform1f(0, (float)t);
		glRecti(-1,-1,1,1);
		SwapBuffers(hDC);
		midiOutShortMsg(hmidi, (0x000000E0) + (t/500)*0x10000); //slowly rise channel 0 pitch bend
	} while ( !GetAsyncKeyState(VK_ESCAPE) );
	ExitProcess(0);
	midiOutClose(hmidi);

}