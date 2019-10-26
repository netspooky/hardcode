#define FULLSCREEN // its displayed fullscreen
#define VERTEXCOUNT 1000000

#define xres 1920
#define yres 1080
#define AUFLOESUNG "1920.,1080."

/*
#define xres 1280
#define yres 720
#define AUFLOESUNG "1280.,720."
*/

#define VOXELWIDTH 256
#define VOXELHEIGHT 256
#define VOXELDEPTH 256

#include <windows.h>
#include <math.h>
#include <gl\gl.h>		
#include <gl\glu.h>		
#include "glext.h"
#include "wglext.h"
#include "zeitmachine2.h"

typedef void (APIENTRYP PFNGLPROGRAMPARAMETERIEXTPROC)(GLuint program, GLenum pname, GLint value);
typedef void (APIENTRYP PFNGLFRAMEBUFFERTEXTURE)(GLenum target,  GLenum attachment,  GLuint texture,  GLint level);
typedef void (APIENTRYP PFNGLTRANSFORMFEEDBACKVARYINGS)(GLuint program, GLsizei count,const char **varyings, GLenum bufferMode);
typedef void (APIENTRYP PFNGLBEGINTRANSFORMFEEDBACK)(GLenum primitiveMode);
typedef void (APIENTRYP PFNGLENDTRANSFORMFEEDBACK)();
typedef void (APIENTRYP PFNGLBINDBUFFERBASE)(GLenum target,	GLuint index, GLuint buffer);

const static char *glFunctionNames[] = {
    "glCreateProgram",
    "glCreateShader",
    "glShaderSource",
    "glCompileShader",
    "glAttachShader",
    "glLinkProgram",
    "glUseProgram",
    "glGetUniformLocation",
    "glUniform4f",
	  "glUniform1i",
    "glBindFramebuffer", //EXT
    "glGenFramebuffers", //EXT
    "glTexImage3D",
    "glProgramParameteri", // EXT
    "glActiveTexture",
    "glFramebufferTexture",
    "glTransformFeedbackVaryings",
    "glBeginTransformFeedback",
    "glEndTransformFeedback",
    "glBindBufferBase",
    "glGenBuffers",
    "glBindBuffer",
    "glBufferData",
};

static void *glFunctionPointers[23];

#define oglCreateProgram ((PFNGLCREATEPROGRAMPROC)glFunctionPointers[0])
#define oglCreateShader  ((PFNGLCREATESHADERPROC)glFunctionPointers[1])
#define oglShaderSource  ((PFNGLSHADERSOURCEPROC)glFunctionPointers[2])
#define oglCompileShader ((PFNGLCOMPILESHADERPROC)glFunctionPointers[3])
#define oglAttachShader  ((PFNGLATTACHSHADERPROC)glFunctionPointers[4])
#define oglLinkProgram   ((PFNGLLINKPROGRAMPROC)glFunctionPointers[5])
#define oglUseProgram    ((PFNGLUSEPROGRAMPROC)glFunctionPointers[6])
#define oglGetUniformLocation ((PFNGLGETUNIFORMLOCATIONARBPROC)glFunctionPointers[7])
#define oglUniform4f	   ((PFNGLUNIFORM4FPROC)glFunctionPointers[8])
#define oglUniform1i	   ((PFNGLUNIFORM1IPROC)glFunctionPointers[9])
#define oglBindFramebufferEXT ((PFNGLBINDFRAMEBUFFEREXTPROC)glFunctionPointers[10])
#define oglGenFramebuffersEXT ((PFNGLGENFRAMEBUFFERSEXTPROC)glFunctionPointers[11])
#define oglTexImage3D ((PFNGLTEXIMAGE3DPROC)glFunctionPointers[12])
#define oglProgramParameteriEXT ((PFNGLPROGRAMPARAMETERIEXTPROC)glFunctionPointers[13])
#define oglActiveTexture ((PFNGLACTIVETEXTUREPROC)glFunctionPointers[14])
#define oglFramebufferTexture ((PFNGLFRAMEBUFFERTEXTURE)glFunctionPointers[15])
#define oglTransformFeedbackVaryings ((PFNGLTRANSFORMFEEDBACKVARYINGS)glFunctionPointers[16])
#define oglBeginTransformFeedback ((PFNGLBEGINTRANSFORMFEEDBACK)glFunctionPointers[17])
#define oglEndTransformFeedback ((PFNGLENDTRANSFORMFEEDBACK)glFunctionPointers[18])
#define oglBindBufferBase ((PFNGLBINDBUFFERBASE)glFunctionPointers[19])
#define oglGenBuffers ((PFNGLGENBUFFERSPROC)glFunctionPointers[20])
#define	oglBindBuffer ((PFNGLBINDBUFFERPROC)glFunctionPointers[21])
#define	oglBufferData ((PFNGLBUFFERDATAPROC)glFunctionPointers[22])


#define GL_RASTERIZER_DISCARD 0x8C89
#define GL_INTERLEAVED_ATTRIBS 0x8C8C
#define GL_TRANSFORM_FEEDBACK_BUFFER 0x8C8E
#define GL_R16F 0x822D
#define GL_R32F 0x822E
#define GL_GEOMETRY_SHADER_EXT	0x8DD9
#define GL_GEOMETRY_VERTICES_OUT_EXT	0x8DDA
#define GL_GEOMETRY_INPUT_TYPE_EXT 0x8DDB
#define GL_GEOMETRY_OUTPUT_TYPE_EXT 0x8DDC

static float frameTime = 0.f;
static int flipper = 0;
static int flipping = 0;

static int seed = 0;
int __fastcall rand_4k(void) 
{
	__asm 
	{
		mov		eax, dword ptr [seed]
		imul	eax, 0x000343FD
		add		eax, 0x00269EC3
		mov		dword ptr [seed], eax
		sar		eax, 10
		//and		eax, 0x00007FFF
	};
}

#define sin(x) sinf(x)
#define cos(x) cosf(x)

#ifndef _DEBUG
	extern "C" int _fltused = 1;
#endif

#define V256 "128." // halve of 3d texture size
#define V256NORMALEPSILON "128."
#define SCALING ".25"
#define PARTICLESIZE "2."
#define NORMALMAPPOINTSIZE "6."

static const char *shaderCode[7]=
{
	// VolumeVertex
	"varying vec4 v;"
	"void main()"
	"{"
		"gl_Position=gl_Vertex*"SCALING";"
	  "v=gl_ModelViewMatrix*gl_Position;"
	"}"
  ,
	//VolumeFragment
	"void main()"
	"{"
	  "gl_FragColor=vec4(max(1.-length(gl_PointCoord*2.-1.),0.));"
	"}"
  ,
	// VolumeGeometry
	"#version 150\n"
	//"#extension GL_EXT_geometry_shader4 : enable\n"
	"varying in vec4 v[1];"
	"void main()"
	"{"
	  "gl_Position=vec4(v[0].xy,0.,1.);"
	  "gl_PointSize="NORMALMAPPOINTSIZE";"
	  "gl_Layer=int(v[0].z*"V256"+"V256");"
	  "EmitVertex();"
	  "gl_Layer++;"
	  "EmitVertex();"
	  "EndPrimitive();"
	"}"
  ,
	//ParticleDisplayVertex
	"uniform sampler3D t3D;"
	"uniform vec4 t;"
	"float l(vec3 p)"
	"{"
	  "return texture3D(t3D,p*.5+.5).x;"
	"}"
	"void main()"
	"{"
	  "vec4 q=ftransform();"
	  "vec3 p=(gl_ModelViewMatrix*gl_Vertex*"SCALING").xyz;"
	  "float s=l(p)*.0025;"
    "s*=s<.125?0.:1.;"
	  "gl_PointSize=min(20.,"PARTICLESIZE"/(q.z+.2)*s);"
	  "vec2 e=vec2(1./"V256NORMALEPSILON",0.);"
	  "vec3 n=normalize(vec3(l(p+e.xyy),l(p+e.yxy),l(p+e.yyx))-l(p));"
	  "gl_FrontColor=mix(vec4(.9,.8,.7,0.)*(n.y*.5+.5),vec4(.1,.2,.3,0.),q.z)+pow(max(0.,dot(vec3(0.,.71,-.71),n)),20.);"
	  "if(gl_VertexID<t.x)"
	  "{"
		"gl_FrontColor=mix(vec4(1.,.3,.1,0.)*(n.y*.5+.5),vec4(.3,.2,.1,0.),q.z)+pow(max(0.,dot(vec3(0.,.71,-.71),n)),20.);"
		"q.xy=q.yx;"
	  "}"
    "gl_Position=q;"
	"}"
  ,
    //ParticleDisplayFragment
	"void main()"
	"{"
	  "if (length(gl_PointCoord*2.-1.)>1.)"
		"discard;"
	  "gl_FragColor=gl_Color;"
	"}"
  ,
	//TransformFeedbackVertex1
	"#version 150\n"
	"uniform vec4 t;"
	"in vec3 i;"
	"out vec3 o;"
	"void main()"
	"{"
    "float a1=atan(i.y,i.x)*(cos(t.x*.05)*.3+.4);"
	  "float a2=atan(i.z,i.y);"
	  "float a3=atan(i.x,i.z);"
	  "float d1=dot(i.xy,i.xy)+sin(t.x)+1.;"
	  "float d2=length(i.yz);"
	  "float d3=length(i.zx);"
	  "o=vec3("
	  "sin(a1)*(d2-d1)+cos(a3)*(d1-d3)+sin(a2)*d3,"
	  "-sin(a2)*(d3-d2)-cos(a1)*(d2+d1),"
	  "-sin(a3)*(d1-d3)-cos(a2)*(d3+d2)-sin(a1)*d2);"
    "o.x=cos(o.x+o.y+t.x+sin(float(gl_VertexID))*.1);"
	  "o.y=cos(o.y+o.z+sin(o.x));"
	  "o.z=cos(o.z-o.x+o.y-t.x);"
  "}"
	,
	//BackgroundFragment
	"uniform vec4 t;"
	"float q(vec3 p)"
	"{"
    "return length(cos(p.xy+t.zx))+cos(p.x)+cos(p.z+p.y)+cos(p.x*4.)+cos(p.y*24.)*.04+dot(sin(p*12.),cos(p*12.))*.2*sin(t.x*.02);"
	"}"
	"void main()"
	"{"
		"vec2 s=gl_FragCoord.xy/vec2("AUFLOESUNG")*2.-1.,e=vec2(.1,.0);"
    "vec3 d=normalize(vec3(s.xy,cos(t.x*.03)*.45+.55)),p=vec3(0.,t.x*max(cos(t.x*.025),-.5),-t.x);"
		"float c=1.,f=0.;"
    "for(int i=0;i<150&&abs(c)>.0001;i++)"
    "{"
      "c=q(d*f+p)*.35;"
      "f+=c;"
    "}"
		"p+=d*f;"
		"d=normalize(vec3(q(p+e.xyy),q(p+e.yxy),q(p+e.yyx))-q(p));"
    "c=(d.y+1.-f*.02+sin(p.y*2.+t.x))*(-cos(t.x*.05+s.x)+1.)*(-s.y*.25+.25);"
    "gl_FragColor=(mix(vec4(.2,.3,.35,1.)*(clamp(c,.125,.5)+t.y*cos(s.y)),mix(vec4(1.),vec4(.1,.2,.3,1.),s.y)*clamp(c,.3,1.),cos(t.x*.01))+pow(max(0.,dot(d,vec3(0.,.71,-.71))),20.)*(-s.y*.25+.25))*min(1.,t.x*.5);" 
  "}"
};

static const int shaderType[7] =
{
  GL_VERTEX_SHADER,
  GL_FRAGMENT_SHADER,
  GL_GEOMETRY_SHADER_EXT,
  GL_VERTEX_SHADER,
  GL_FRAGMENT_SHADER,
  GL_VERTEX_SHADER,
  GL_FRAGMENT_SHADER,
};

static int shaderCompiled[7];
static GLuint frameBuffer3D;
static GLuint texture3D;
static GLuint particleToVolumeProgram;
static GLuint particleDisplayProgram;
static GLuint handle_t3D;
static GLuint handle_tVertex;
static GLuint transformFeedbackProgram;
static GLuint handle_time;
static GLuint backgroundProgram;
static GLuint handle_time2;
static float vertices[VERTEXCOUNT][3];
static GLuint vboHandles[2];
static unsigned int VERTEXCOUNTANIMATED;
static unsigned int OBJECT2VERTEXCOUNT = 0;

void Paint3DTextureDots()
{
  //glEnable(GL_BLEND);
  oglUseProgram(particleDisplayProgram);
  oglUniform4f(handle_tVertex,OBJECT2VERTEXCOUNT,0.f,0.f,0.f);
  glEnable(GL_DEPTH_TEST);
  oglActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_3D, texture3D);
  oglUniform1i(handle_t3D, 0);
  //glEnableClientState(GL_VERTEX_ARRAY);
  oglBindBuffer(GL_ARRAY_BUFFER, vboHandles[flipper]);
  glVertexPointer(3,GL_FLOAT,0,0);
  glDrawArrays(GL_POINTS,0,VERTEXCOUNTANIMATED);
  //glDisableClientState(GL_VERTEX_ARRAY);
  //oglUseProgram(0);
}



static HDC		     hDC;

/////////////////////////////////////////////////////////////////////////////////
// initialized data
/////////////////////////////////////////////////////////////////////////////////
// MAX_SAMPLES gives you the number of samples for the whole song. we always produce stereo samples, so times 2 for the buffer
static SAMPLE_TYPE	lpSoundBuffer[MAX_SAMPLES*2];  
static HWAVEOUT	hWaveOut;
#define WAVE_FORMAT_IEEE_FLOAT 0x0003

static WAVEFORMATEX WaveFMT =
{
#ifdef FLOAT_32BIT	
	WAVE_FORMAT_IEEE_FLOAT,
#else
	WAVE_FORMAT_PCM,
#endif		
    2, // channels
    SAMPLE_RATE, // samples per sec
    SAMPLE_RATE*sizeof(SAMPLE_TYPE)*2, // bytes per sec
    sizeof(SAMPLE_TYPE)*2, // block alignment;
    sizeof(SAMPLE_TYPE)*8, // bits per sample
    0 // extension not needed
};

static WAVEHDR WaveHDR = 
{
	(LPSTR)lpSoundBuffer, 
	MAX_SAMPLES*sizeof(SAMPLE_TYPE)*2,			// MAX_SAMPLES*sizeof(float)*2(stereo)
	0, 
	0, 
	0, 
	0, 
	0, 
	0
};

static MMTIME MMTime = 
{ 
	TIME_SAMPLES,
	0
};

//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************

static DEVMODE dmScreenSettings;
PIXELFORMATDESCRIPTOR pfd = {
			sizeof(PIXELFORMATDESCRIPTOR),
			1,
			PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
			PFD_TYPE_RGBA,
			32,				// Colour buffer bit depth
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			32,				// Depth buffer bit depth
			0, 0,			// stencilbuffer bit detph, auxbuffer bit depth
			PFD_MAIN_PLANE, 
			0, 0, 0, 0 };

#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
#else
extern "C" __declspec(noreturn) void WinMainCRTStartup()
#endif
{
  CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);

  HWND	hWnd;
#ifdef FULLSCREEN
  dmScreenSettings.dmSize			=	sizeof(dmScreenSettings);
  dmScreenSettings.dmPelsWidth	=	xres;
  dmScreenSettings.dmPelsHeight	=	yres;
  dmScreenSettings.dmBitsPerPel	=	32;
  // enable this if you have a too fast computer
  //dmScreenSettings.dmDisplayFrequency = 60;
  dmScreenSettings.dmFields		=	DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;//|DM_DISPLAYFREQUENCY;

  // We set fullscreen mode
  ChangeDisplaySettings	(&dmScreenSettings,CDS_FULLSCREEN);

  // We hide the cursor
  ShowCursor(FALSE);
#endif
  // We create a window with the "EDIT" trick
  hWnd = CreateWindow("STATIC","STATIC",WS_POPUP|WS_VISIBLE, 0,0, xres, yres,0,0,0,0);
  hDC = GetDC(hWnd);
  SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);

  // Opengl context bind
  wglMakeCurrent(hDC,wglCreateContext(hDC));

  // INITGLSTART
  for( int i=0; i<(sizeof(glFunctionPointers)/sizeof(void*)); i++ )
			glFunctionPointers[i] = wglGetProcAddress( glFunctionNames[i] );

  for (int i = 0; i < 7; ++i)
  {
    int k = oglCreateShader(shaderType[i]);
    oglShaderSource(k,1,&shaderCode[i],0);
    oglCompileShader(k);
    shaderCompiled[i]=k;
  }


  glEnable(GL_POINT_SPRITE);
  glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
  glEnableClientState(GL_VERTEX_ARRAY);

  // generate 3d texture framebuffer object
  oglGenFramebuffersEXT(1, &frameBuffer3D);
  glGenTextures(1, &texture3D);
  oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, frameBuffer3D);
  glBindTexture(GL_TEXTURE_3D, texture3D);
  oglTexImage3D(GL_TEXTURE_3D, 0, GL_R16F, VOXELWIDTH, VOXELHEIGHT, VOXELDEPTH, 0, GL_RED, GL_FLOAT, NULL);
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
  glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
  oglFramebufferTexture(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, texture3D, 0);

  // VertexToVolumeShader
  particleToVolumeProgram = oglCreateProgram();
  oglAttachShader(particleToVolumeProgram,shaderCompiled[0]);
  oglAttachShader(particleToVolumeProgram,shaderCompiled[1]);
  oglAttachShader(particleToVolumeProgram,shaderCompiled[2]);
  oglProgramParameteriEXT(particleToVolumeProgram,GL_GEOMETRY_INPUT_TYPE_EXT ,GL_POINTS);
  oglProgramParameteriEXT(particleToVolumeProgram,GL_GEOMETRY_OUTPUT_TYPE_EXT ,GL_POINTS);
  oglProgramParameteriEXT(particleToVolumeProgram,GL_GEOMETRY_VERTICES_OUT_EXT,4);
  oglLinkProgram(particleToVolumeProgram);

  // Particle Display Shader
  particleDisplayProgram = oglCreateProgram();
  oglAttachShader(particleDisplayProgram,shaderCompiled[3]);
  oglAttachShader(particleDisplayProgram,shaderCompiled[4]);
  oglLinkProgram(particleDisplayProgram);
  handle_t3D = oglGetUniformLocation(particleDisplayProgram,"t3D");
  handle_tVertex = oglGetUniformLocation(particleDisplayProgram,"t");

  // Transform feedback shader
  transformFeedbackProgram = oglCreateProgram();
  oglAttachShader(transformFeedbackProgram,shaderCompiled[5]);
  const char* varyings[1] = { "o" };
  oglTransformFeedbackVaryings(transformFeedbackProgram, 1, varyings, GL_INTERLEAVED_ATTRIBS);
  oglLinkProgram(transformFeedbackProgram);
  handle_time = oglGetUniformLocation(transformFeedbackProgram,"t");

  // Background Shader
  backgroundProgram = oglCreateProgram();
  oglAttachShader(backgroundProgram,shaderCompiled[6]);
  oglLinkProgram(backgroundProgram);
  handle_time2 = oglGetUniformLocation(backgroundProgram,"t");

  // Generate DisplayList
  float *put = &vertices[0][0];
  for (int x = 0; x < VERTEXCOUNT * 3; ++x)
    *put++ = (float)rand_4k()/16384.f;

  oglGenBuffers(2, vboHandles);
  oglBindBuffer(GL_ARRAY_BUFFER, vboHandles[0]);
  oglBufferData(GL_ARRAY_BUFFER, VERTEXCOUNT * sizeof(float) * 3, vertices,  GL_STATIC_DRAW);
  oglBindBuffer(GL_ARRAY_BUFFER, vboHandles[1]);
  oglBufferData(GL_ARRAY_BUFFER, VERTEXCOUNT * sizeof(float) * 3, vertices,  GL_STATIC_DRAW);
  // INITGLEND

  waveOutOpen	( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
  waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
  waveOutWrite( hWaveOut, &WaveHDR, sizeof(WaveHDR) );	

  do
  {		
    waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
    frameTime = (float)((double)MMTime.u.sample / 44100.0);
    int k = ((MMTime.u.sample >> 8) << 5);

    float ez = (&_4klang_envelope_buffer)[k + 2*6+0] + (&_4klang_envelope_buffer)[k + 2*6+1];
    static float lez = 0.f;
    if (ez - lez > 0.002f)
      OBJECT2VERTEXCOUNT ^= VERTEXCOUNT;
    lez = ez;

    float lz = (&_4klang_envelope_buffer)[k + 2*3+0]*.2f+(&_4klang_envelope_buffer)[k + 2*4+0]+.2f;
    if (lz>1.) lz = 1.;
    VERTEXCOUNTANIMATED = (int)((float)VERTEXCOUNT*lz);

    // drawBackground start
    glClear(GL_DEPTH_BUFFER_BIT);
    glDisable(GL_DEPTH_TEST);
    oglUseProgram(backgroundProgram);
    oglUniform4f(handle_time2,frameTime,(&_4klang_envelope_buffer)[k + 1],0.f,0.f);
    glRects(-1,-1,1,1);
    // drawBackground end

    // DoTransformFeedback start
    oglUseProgram(transformFeedbackProgram);
    oglUniform4f(handle_time,frameTime,0.f,0.f,0.f);
    glEnable(GL_RASTERIZER_DISCARD);
    oglBindBuffer(GL_ARRAY_BUFFER, vboHandles[flipper]);
    glVertexPointer(3,GL_FLOAT,0,0);
    oglBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, vboHandles[flipper ^ 1]);
    oglBeginTransformFeedback(GL_POINTS);
    glDrawArrays(GL_POINTS,0, VERTEXCOUNT);
	  oglEndTransformFeedback();
    glDisable(GL_RASTERIZER_DISCARD);
    flipper ^= 1;
    // DoTransformFeedback end

    float scy = 7.f - frameTime/2.f;
    if (scy > 0.f)
      glTranslatef(0.f,0.f,scy); 
    scy = frameTime/4.f - 154.f/4.f;
    if (scy > 0.f)
      glTranslatef(0.f,0.f,scy); 

    glScalef(1.f,1.f,.5f);
    glRotatef(frameTime*3.f,1.f,1.f,1.f);

    glMatrixMode(GL_PROJECTION);
    gluPerspective(160.0f, (float)xres/(float)yres, 0.001f, 10.0f);
    glTranslatef(0.f,0.f,-1.1f-cos(frameTime*0.2f)*0.75f);

    // fill volume texture start
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, frameBuffer3D);
    glViewport(0,0,VOXELWIDTH,VOXELHEIGHT);
    glClear(GL_COLOR_BUFFER_BIT);
    oglUseProgram(particleToVolumeProgram);
    glVertexPointer(3,GL_FLOAT,0,0);
    glDrawArrays(GL_POINTS,0,VERTEXCOUNTANIMATED);
    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, NULL);
    glViewport(0,0,xres,yres);
    glDisable(GL_BLEND);
    // fill volume texture end

    Paint3DTextureDots();

    glScalef(1.5f,.5f,.5f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_DST_COLOR,GL_SRC_COLOR);
    Paint3DTextureDots();
    glDisable(GL_BLEND);
    
    glScalef(8.f,4.f,8.f);
    Paint3DTextureDots();

    glLoadIdentity();
	  glMatrixMode(GL_MODELVIEW);
	  glLoadIdentity();
    oglUseProgram(0);

    SwapBuffers(hDC);
  } while(!GetAsyncKeyState(VK_ESCAPE) && (MMTime.u.sample < MAX_SAMPLES));
  glDisable(GL_DEPTH_TEST);
  glEnable(GL_BLEND);
  for (int i = 0;i < 64; ++i)
  {
    glColor4ub(110,110,110,110);
    glRects(-1,-1,1,1); 
    SwapBuffers(hDC);
  }
  ExitProcess(0);
}
