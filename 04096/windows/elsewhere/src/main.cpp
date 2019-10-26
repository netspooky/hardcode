#define FULLSCREEN // its displayed fullscreen

#define xres 1920
#define yres 1080
#define RESX "1920."
#define RESY "1080."

/*
#define xres 1280
#define yres 720
#define RESX "1280."
#define RESY "720."
*/

/*
#define xres 1024
#define yres 768
#define RESX "1024."
#define RESY "768."
*/

// this is used for the bluring we use the same ratio for all resolutions
#define MAXRAD ".05" // limit the morph to screensize*.1
// these values are used for the blur (thus not resolution dependent)
#define RESX2 "1920."
#define RESY2 "1080."

#define blurDownsampleRenderTargerX ((xres)/4)
#define blurDownsampleRenderTargerY ((yres)/4)

#include <windows.h>
#include <math.h>
#include <gl\gl.h>		
#include <gl\glu.h>		
#include "glext.h"
#include "wglext.h"
#include "thetaworld.h"
#include "fp.h"

const static char *glFunctionNames[] = {
    "glGenFramebuffersEXT",
    "glBindFramebufferEXT",
    "glFramebufferTexture2DEXT",
    "glCreateProgram",
    "glCreateShader",
    "glShaderSource",
    "glCompileShader",
    "glAttachShader",
    "glLinkProgram",
    "glUseProgram",
    "glGetUniformLocation",
    "glUniform1f",
    "glUniformMatrix4fv",
    "glUniform1i",

    "glGenRenderbuffersEXT",
    "glBindRenderbufferEXT",
	  "glRenderbufferStorageEXT",
    "glFramebufferRenderbufferEXT",
	"glActiveTexture",
};

#define oglGenFramebuffersEXT ((PFNGLGENFRAMEBUFFERSEXTPROC)glFunctionPointers[0])
#define oglBindFramebufferEXT ((PFNGLBINDFRAMEBUFFEREXTPROC)glFunctionPointers[1])
#define oglFramebufferTexture2DEXT ((PFNGLFRAMEBUFFERTEXTURE2DEXTPROC)glFunctionPointers[2])
#define oglCreateProgram ((PFNGLCREATEPROGRAMPROC)glFunctionPointers[3])
#define oglCreateShader  ((PFNGLCREATESHADERPROC)glFunctionPointers[4])
#define oglShaderSource  ((PFNGLSHADERSOURCEPROC)glFunctionPointers[5])
#define oglCompileShader ((PFNGLCOMPILESHADERPROC)glFunctionPointers[6])
#define oglAttachShader  ((PFNGLATTACHSHADERPROC)glFunctionPointers[7])
#define oglLinkProgram   ((PFNGLLINKPROGRAMPROC)glFunctionPointers[8])
#define oglUseProgram    ((PFNGLUSEPROGRAMPROC)glFunctionPointers[9])
#define oglGetUniformLocation ((PFNGLGETUNIFORMLOCATIONARBPROC)glFunctionPointers[10])
#define oglUniform1f	   ((PFNGLUNIFORM1FPROC)glFunctionPointers[11])
#define oglUniformMatrix4fv   ((PFNGLUNIFORMMATRIX4FVPROC)glFunctionPointers[12])
#define oglUniform1i	   ((PFNGLUNIFORM1IPROC)glFunctionPointers[13])
#define oglGenRenderbuffersEXT ((PFNGLGENRENDERBUFFERSEXTPROC)glFunctionPointers[14])
#define oglBindRenderbufferEXT ((PFNGLBINDRENDERBUFFEREXTPROC)glFunctionPointers[15])
#define oglRenderbufferStorageEXT ((PFNGLRENDERBUFFERSTORAGEEXTPROC)glFunctionPointers[16])
#define oglFramebufferRenderbufferEXT ((PFNGLFRAMEBUFFERRENDERBUFFEREXTPROC)glFunctionPointers[17])
#define oglActiveTexture ((PFNGLACTIVETEXTUREPROC)glFunctionPointers[18])

#define GL_RGBA16F                        0x881A
#define GL_RGBA32F                        0x8814

#define COLORFORMAT GL_RGBA16F

static void *glFunctionPointers[19];

static float currentFrameTime;
static float frameTimeMorphBefore;
static float frameTimeMorphAfter;
static float timeBetween;

#define FBO_COUNT 5
static int FBO_ColorBufferTextureHandles[FBO_COUNT];
static int FBO_Handles[FBO_COUNT];

static float *cubeColor;
static float cubeColors[][4] = 
{
  {2.f,0.f,0.f,0.f},
  {1.f,1.f,1.f,1.f},
  {p0d80,p0d90,1.f,1.f}
};

//static  float predefVals[3] = {0.f,1.f,-1.f};

#define MAX_MORPH_OBJECTS 10000
static float morphNextFrameSave[MAX_MORPH_OBJECTS * 4 * 4];
static float *currentmorphNextFrameSaveReadWrite;

#define sin(x) sinf(x)
#define cos(x) cosf(x)

#ifndef _DEBUG
	extern "C" int _fltused = 1;
#endif

#define SHADER_COUNT 5

static const char *shaderCode[SHADER_COUNT]=
{
  // globaler vertex shader für die cubes
  "varying vec4 v,m;"
  "varying vec3 p,n;"
  "void main()"
	"{"
	  "gl_Position=ftransform();"
	  "m=gl_Color;"
    "v=gl_Vertex;"
    "n=gl_NormalMatrix*gl_Normal;"
	  "p=(gl_ModelViewMatrix*v).xyz;"
  "}",
  // globaler fragment shader für die cube colors
  "varying vec4 v,m;"
  "varying vec3 p,n;"
  "uniform float f;"
  "void main()"
  "{"
	  // z negative geht in den raum rein
	  "vec3 q,t;"
    "float d,s,r;"
    "q=normalize(-p);" // we had a wrong camera matrix here
	  "t=normalize(n);"
	  "d=max(.1,dot(q,t));"
	  "s=max(0.,max(0.,sin(p.x*p.y*p.z))*t.z)+pow(max(0.,dot(normalize(q-normalize(p)),t)),20.);" // inverse specular gives nice results (it should be a - instead of a +)
    "r=-cos(f*.25)*.5+.5;"
    "r=(1.-r*r*r*r)*2.+1.;"
    "gl_FragColor=max(m*(length(v)-r+length(sin(p*8.)*sin(p*3.)*sin(p))*.5)*d+s/r*2.,0.);"
  "}",
  // globaler fragment shader für die morph coordinaten
  "uniform mat4 n;"
  "varying vec4 v;"
  "void main()"
  "{"
    "vec4 w=gl_ProjectionMatrix*n*v;"
    "vec4 q=gl_ModelViewProjectionMatrix*v;"
    "gl_FragColor=w/w.w-q/q.w;"
  "}",
  // the morph shader 
  "uniform sampler2D t0,t1,t2,t3;"
  "uniform float i,t;"
  "varying vec4 v;"
  /*"vec2 w(sampler2D m,vec2 c)" // get morphto coordinate at pixel position
  "{"
	  //"return clamp(c+texture2D(m,c).xy*.5,0.,1.);" // clamp the morph to the given "frame"
    //"float r=pow(length(c-.5)*2.4-.5,9.);"
    "return mix(c+clamp(texture2D(m,c).xy*.5,-"MAXRAD","MAXRAD"),c,clamp(length(c-.5)*3.-.6,0.,1.));" // clamp the morph to the given "frame"
  "}"*/
  "vec4 k(sampler2D s,sampler2D m,vec2 c,float f)" // get color at screen pos for rendertarget s
  "{"
    //"return texture2D(m,c);"
    "float x,y,r;"
	  "vec2 p=mix(c,2.*c-mix(c+clamp(texture2D(m,c).xy*.5,-"MAXRAD","MAXRAD"),c,clamp(length(c-.5)*3.-.6,0.,1.)),1.-f);" // calculate morph coordinate (from c to morphto)
	  "r=-cos(t*.25)*.5+.5;" // thats for the little flickering
	  "vec4 z=vec4(0.);"
	  "for(y=-3.;y<=3.;y+=1.)"
	  "for(x=-3.;x<=3.;x+=1.)"
      "z+=texture2D(s,p+vec2((x+sin(p.y*"RESY"*(sin(t)+3.))*(1.-r*r*r*r)*3.)/"RESX2",y/"RESY2"));" // blur the texture and flicker
	  "return z/49.*f*clamp((t-1.5)*3.,0.,1.);" // divive by blur and multiply with fade factor
  "}"
  "void main()"
  "{"
	  "vec2 c=v.xy*.5+.5;"
	  "vec4 z=k(t0,t3,c,1.-i)+k(t1,t2,c,i);"
    //"float r=pow(length(c-.5)*2.4-.5,9.);"
    //"gl_FragColor = r;"
     "gl_FragColor=mix(vec4(dot(z,vec4(.333))),z,.7)*1.2;"
  "}",
  "uniform sampler2D t;"
  "uniform float m,n;"
  "varying vec4 v;"
  "float e(float x)"//http://www.musicdsp.org/showone.php?id=222 (fastexp)
  "{"
    "return(6.+x*(6.+x*(3.+x)))*.16666666;"
  "}"
  "void main()"
  "{"
	  "vec2 r,o=vec2(m/"RESX",n/"RESY"),c=v.xy*.5+.5;"
    "vec4 z=vec4(0.);"
    "float w,k,a=0.;"
    "for(k=0.;k<=5.;k+=1.)"
    "{"
      "w=.39895*e(k*k*-.02);"//( 1 / ( sqrt(2*pi) * sigma ) ) * exp( -(x*x) / (2*sigma*sigma) ); -> sigma = 1.0 and x = k / 5.
      "r=c+o*k;"
      "if(clamp(r,0.,1.)==r)"
      "{"
        "z+=texture2D(t,r)*w;"
        "a+=w;"
      "}"
      "r=c-o*k;"
      "if(clamp(r,0.,1.)==r)"
      "{"
        "z+=texture2D(t,r)*w;"
        "a+=w;"
      "}"
    "}"
    "gl_FragColor=z/a;"
  "}"
};

#define PROGRAM_COUNT 4

static int shaderCompiled[SHADER_COUNT];
static int programs[PROGRAM_COUNT];

#define colorDisplayProgram programs[0]
#define morphCalcProgram programs[1]
#define morphProgram programs[2]
#define blurProgram programs[3]

#define handle_cameraMatrix oglGetUniformLocation(colorDisplayProgram,"c")
#define handle_sceneTime oglGetUniformLocation(colorDisplayProgram,"f")
#define handle_nextMatrix oglGetUniformLocation(morphCalcProgram,"n")
#define handle_fade oglGetUniformLocation(morphProgram,"i")
#define handle_scratchTime oglGetUniformLocation(morphProgram,"t")
#define handle_texture0 oglGetUniformLocation(morphProgram,"t0")
#define handle_texture1 oglGetUniformLocation(morphProgram,"t1")
#define handle_texture2 oglGetUniformLocation(morphProgram,"t2")
#define handle_texture3 oglGetUniformLocation(morphProgram,"t3")
#define handle_kernelSizeX oglGetUniformLocation(blurProgram,"m")
#define handle_kernelSizeY oglGetUniformLocation(blurProgram,"n")
#define handle_blurTexture oglGetUniformLocation(blurProgram,"t") 

//static int bhandle_nextMatrix;
//static int bhandle_fade;
//static int bhandle_texture0;
//static int bhandle_texture1;
//static int bhandle_texture2;
//static int bhandle_texture3;
//static int bhandle_cameraMatrix;
//static int bhandle_sceneTime;
//static int bhandle_scratchTime;
//static int bhandle_kernelSizeX;
//static int bhandle_kernelSizeY;
//static int bhandle_blurTexture; 
//
//#define handle_cameraMatrix bhandle_cameraMatrix 
//#define handle_sceneTime bhandle_sceneTime 
//#define handle_nextMatrix bhandle_nextMatrix 
//#define handle_fade bhandle_fade 
//#define handle_scratchTime bhandle_scratchTime 
//#define handle_texture0 bhandle_texture0 
//#define handle_texture1 bhandle_texture1 
//#define handle_texture2 bhandle_texture2 
//#define handle_texture3 bhandle_texture3 
//#define handle_kernelSizeX bhandle_kernelSizeX 
//#define handle_kernelSizeY bhandle_kernelSizeY 
//#define handle_blurTexture bhandle_blurTexture 

static bool tiefenPass = false;

void DrawCube()
{
/*
  glBegin(GL_QUADS);		// Draw The Cube Using quads
  //glColor4fv(cubeColor);
  // first face
  glNormal3f(0.f,1.f,0.f);
  glVertex3f( 1.0f, 1.0f,-1.0f);	// Top Right Of The Quad (Top)
  glVertex3f(-1.0f, 1.0f,-1.0f);	// Top Left Of The Quad (Top)
  glVertex3f(-1.0f, 1.0f, 1.0f);	// Bottom Left Of The Quad (Top)
  glVertex3f( 1.0f, 1.0f, 1.0f);	// Bottom Right Of The Quad (Top)
  // second face
  glNormal3f(0.f,-1.f,0.f);
  glVertex3f( 1.0f,-1.0f, 1.0f);	// Top Right Of The Quad (Bottom)
  glVertex3f(-1.0f,-1.0f, 1.0f);	// Top Left Of The Quad (Bottom)
  glVertex3f(-1.0f,-1.0f,-1.0f);	// Bottom Left Of The Quad (Bottom)
  glVertex3f( 1.0f,-1.0f,-1.0f);	// Bottom Right Of The Quad (Bottom)
  // third face
  glNormal3f(0.f,0.f,1.f);
  glVertex3f( 1.0f, 1.0f, 1.0f);	// Top Right Of The Quad (Front)
  glVertex3f(-1.0f, 1.0f, 1.0f);	// Top Left Of The Quad (Front)
  glVertex3f(-1.0f,-1.0f, 1.0f);	// Bottom Left Of The Quad (Front)
  glVertex3f( 1.0f,-1.0f, 1.0f);	// Bottom Right Of The Quad (Front)
  // fourth face
  glNormal3f(0.f,0.f,-1.f);
  glVertex3f( 1.0f,-1.0f,-1.0f);	// Top Right Of The Quad (Back)
  glVertex3f(-1.0f,-1.0f,-1.0f);	// Top Left Of The Quad (Back)
  glVertex3f(-1.0f, 1.0f,-1.0f);	// Bottom Left Of The Quad (Back)
  glVertex3f( 1.0f, 1.0f,-1.0f);	// Bottom Right Of The Quad (Back)
  // fifth face
  glNormal3f(-1.f,0.f,0.f);
  glVertex3f(-1.0f, 1.0f, 1.0f);	// Top Right Of The Quad (Left)
  glVertex3f(-1.0f, 1.0f,-1.0f);	// Top Left Of The Quad (Left)
  glVertex3f(-1.0f,-1.0f,-1.0f);	// Bottom Left Of The Quad (Left)
  glVertex3f(-1.0f,-1.0f, 1.0f);	// Bottom Right Of The Quad (Left)
  // sixth face
  glNormal3f(1.f,0.f,0.f);
  glVertex3f( 1.0f, 1.0f,-1.0f);	// Top Right Of The Quad (Right)
  glVertex3f( 1.0f, 1.0f, 1.0f);	// Top Left Of The Quad (Right)
  glVertex3f( 1.0f,-1.0f, 1.0f);	// Bottom Left Of The Quad (Right)
  glVertex3f( 1.0f,-1.0f,-1.0f);	// Bottom Right Of The Quad (Right)
  glEnd();			// End Drawing The Cube
  return;
*/
  if (tiefenPass)
    oglUniformMatrix4fv(handle_nextMatrix,1,GL_FALSE,currentmorphNextFrameSaveReadWrite);
  glGetFloatv(GL_MODELVIEW_MATRIX, currentmorphNextFrameSaveReadWrite);
  currentmorphNextFrameSaveReadWrite += 4*4;
  glBegin(GL_QUADS);		// Draw The Cube Using quads
  glColor4fv(cubeColor);
/*
 __asm
{
    push        dword ptr [cubeColor]

   	push        GL_QUADS

    push        dword ptr [currentmorphNextFrameSaveReadWrite]
   	push        GL_MODELVIEW_MATRIX

    push        dword ptr [currentmorphNextFrameSaveReadWrite]
    push        GL_FALSE
   	push        0x1
   	push        dword ptr [handle_nextMatrix]

   	call        dword ptr [glFunctionPointers+12*4] // oglUniformMatrix4fv
   	call        dword ptr [glGetFloatv]
   	call        dword ptr [glBegin]
    call        dword ptr [glColor4fv]
}
*/

/*
  // first face
  glNormal3f(0.f,1.f,0.f);
  glVertex3f( 1.0f, 1.0f,-1.0f);	// Top Right Of The Quad (Top)
  glVertex3f(-1.0f, 1.0f,-1.0f);	// Top Left Of The Quad (Top)
  glVertex3f(-1.0f, 1.0f, 1.0f);	// Bottom Left Of The Quad (Top)
  glVertex3f( 1.0f, 1.0f, 1.0f);	// Bottom Right Of The Quad (Top)
  // second face
  glNormal3f(0.f,-1.f,0.f);
  glVertex3f( 1.0f,-1.0f, 1.0f);	// Top Right Of The Quad (Bottom)
  glVertex3f(-1.0f,-1.0f, 1.0f);	// Top Left Of The Quad (Bottom)
  glVertex3f(-1.0f,-1.0f,-1.0f);	// Bottom Left Of The Quad (Bottom)
  glVertex3f( 1.0f,-1.0f,-1.0f);	// Bottom Right Of The Quad (Bottom)
  // third face
  glNormal3f(0.f,0.f,1.f);
  glVertex3f( 1.0f, 1.0f, 1.0f);	// Top Right Of The Quad (Front)
  glVertex3f(-1.0f, 1.0f, 1.0f);	// Top Left Of The Quad (Front)
  glVertex3f(-1.0f,-1.0f, 1.0f);	// Bottom Left Of The Quad (Front)
  glVertex3f( 1.0f,-1.0f, 1.0f);	// Bottom Right Of The Quad (Front)
  // fourth face
  glNormal3f(0.f,0.f,-1.f);
  glVertex3f( 1.0f,-1.0f,-1.0f);	// Top Right Of The Quad (Back)
  glVertex3f(-1.0f,-1.0f,-1.0f);	// Top Left Of The Quad (Back)
  glVertex3f(-1.0f, 1.0f,-1.0f);	// Bottom Left Of The Quad (Back)
  glVertex3f( 1.0f, 1.0f,-1.0f);	// Bottom Right Of The Quad (Back)
  // fifth face
  glNormal3f(-1.f,0.f,0.f);
  glVertex3f(-1.0f, 1.0f, 1.0f);	// Top Right Of The Quad (Left)
  glVertex3f(-1.0f, 1.0f,-1.0f);	// Top Left Of The Quad (Left)
  glVertex3f(-1.0f,-1.0f,-1.0f);	// Bottom Left Of The Quad (Left)
  glVertex3f(-1.0f,-1.0f, 1.0f);	// Bottom Right Of The Quad (Left)
  // sixth face
  glNormal3f(1.f,0.f,0.f);
  glVertex3f( 1.0f, 1.0f,-1.0f);	// Top Right Of The Quad (Right)
  glVertex3f( 1.0f, 1.0f, 1.0f);	// Top Left Of The Quad (Right)
  glVertex3f( 1.0f,-1.0f, 1.0f);	// Bottom Left Of The Quad (Right)
  glVertex3f( 1.0f,-1.0f,-1.0f);	// Bottom Right Of The Quad (Right)
*/
  __asm
  {
    mov esi,dword ptr [glVertex3f]
    mov edi,dword ptr [glNormal3f]
    mov eax,0 // 0.f
    mov ebx,0x3f800000 //1.f
    mov ecx,0xbf800000 //-1.f

  // sixth face
  //glNormal3f(1.f,0.f,0.f);
  //glVertex3f( 1.0f, 1.0f,-1.0f);	// Top Right Of The Quad (Right)
  //glVertex3f( 1.0f, 1.0f, 1.0f);	// Top Left Of The Quad (Right)
  //glVertex3f( 1.0f,-1.0f, 1.0f);	// Bottom Left Of The Quad (Right)
  //glVertex3f( 1.0f,-1.0f,-1.0f);	// Bottom Right Of The Quad (Right)

    push ecx
    push ecx
    push ebx

    push ebx
    push ecx
    push ebx

    push ebx
    push ebx
    push ebx

    push ecx
    push ebx
    push ebx

    push eax
    push eax
    push ebx

  // fifth face
  //glNormal3f(-1.f,0.f,0.f);
  //glVertex3f(-1.0f, 1.0f, 1.0f);	// Top Right Of The Quad (Left)
  //glVertex3f(-1.0f, 1.0f,-1.0f);	// Top Left Of The Quad (Left)
  //glVertex3f(-1.0f,-1.0f,-1.0f);	// Bottom Left Of The Quad (Left)
  //glVertex3f(-1.0f,-1.0f, 1.0f);	// Bottom Right Of The Quad (Left)

    push ebx
    push ecx
    push ecx
   
    push ecx
    push ecx
    push ecx

    push ecx
    push ebx
    push ecx

    push ebx
    push ebx
    push ecx

    push eax
    push eax
    push ecx

  // fourth face
  //glNormal3f(0.f,0.f,-1.f);
  //glVertex3f( 1.0f,-1.0f,-1.0f);	// Top Right Of The Quad (Back)
  //glVertex3f(-1.0f,-1.0f,-1.0f);	// Top Left Of The Quad (Back)
  //glVertex3f(-1.0f, 1.0f,-1.0f);	// Bottom Left Of The Quad (Back)
  //glVertex3f( 1.0f, 1.0f,-1.0f);	// Bottom Right Of The Quad (Back)

    push ecx
    push ebx
    push ebx

    push ecx
    push ebx
    push ecx

    push ecx
    push ecx
    push ecx

    push ecx
    push ecx
    push ebx

    push ecx
    push eax
    push eax

  // third face
  //glNormal3f(0.f,0.f,1.f);
  //glVertex3f( 1.0f, 1.0f, 1.0f);	// Top Right Of The Quad (Front)
  //glVertex3f(-1.0f, 1.0f, 1.0f);	// Top Left Of The Quad (Front)
  //glVertex3f(-1.0f,-1.0f, 1.0f);	// Bottom Left Of The Quad (Front)
  //glVertex3f( 1.0f,-1.0f, 1.0f);	// Bottom Right Of The Quad (Front)

    push ebx
    push ecx
    push ebx

    push ebx
    push ecx
    push ecx
    
    push ebx
    push ebx
    push ecx

    push ebx
    push ebx
    push ebx

    push ebx
    push eax
    push eax

  // second face
  //glNormal3f(0.f,-1.f,0.f);
  //glVertex3f( 1.0f,-1.0f, 1.0f);	// Top Right Of The Quad (Bottom)
  //glVertex3f(-1.0f,-1.0f, 1.0f);	// Top Left Of The Quad (Bottom)
  //glVertex3f(-1.0f,-1.0f,-1.0f);	// Bottom Left Of The Quad (Bottom)
  //glVertex3f( 1.0f,-1.0f,-1.0f);	// Bottom Right Of The Quad (Bottom)

    push ecx
    push ecx
    push ebx

    push ecx
    push ecx
    push ecx

    push ebx
    push ecx
    push ecx

    push ebx
    push ecx
    push ebx

    push eax
    push ecx
    push eax

  // first face
  //glNormal3f(0.f,1.f,0.f);
  //glVertex3f( 1.0f, 1.0f,-1.0f);	// Top Right Of The Quad (Top)
  //glVertex3f(-1.0f, 1.0f,-1.0f);	// Top Left Of The Quad (Top)
  //glVertex3f(-1.0f, 1.0f, 1.0f);	// Bottom Left Of The Quad (Top)
  //glVertex3f( 1.0f, 1.0f, 1.0f);	// Bottom Right Of The Quad (Top)

    push ebx
    push ebx
    push ebx

    push ebx
    push ebx
    push ecx

    push ecx
    push ebx
    push ecx
    
    push ecx
    push ebx
    push ebx

    push eax
    push ebx
    push eax

    // call the faces
    // 1
    call edi
    call esi
    call esi
    call esi
    call esi
    // 2
    call edi
    call esi
    call esi
    call esi
    call esi
    // 3
    call edi
    call esi
    call esi
    call esi
    call esi
    // 4
    call edi
    call esi
    call esi
    call esi
    call esi
    // 5
    call edi
    call esi
    call esi
    call esi
    call esi
    // 6
    call edi
    call esi
    call esi
    call esi
    call esi
  }
  glEnd();			// End Drawing The Cube
}

void DrawScene(float time, int shader)
{
  tiefenPass = shader == morphCalcProgram;
  currentmorphNextFrameSaveReadWrite = morphNextFrameSave;

  oglUseProgram(shader);
  if (!tiefenPass)
    oglUniform1f(handle_sceneTime,time);

  // setup camera
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  // draw background
  glClear(GL_DEPTH_BUFFER_BIT);
  glTranslatef(0.f,0.f,-1.5f);
  cubeColor = cubeColors[0];
  DrawCube();
  glClear(GL_DEPTH_BUFFER_BIT);

  // generate camera matrix
  glTranslatef(0.f,0.f,-10.f);
  glRotatef(time*20.f,0.f,1.f,0.f);
  glRotatef(sin(time*0.5f)*50.f,1.f,0.f,0.f);

  glPushMatrix();
  cubeColor = cubeColors[2];
  glTranslatef(0.f,-20.f,0.f);
  glScalef(1000.f,1.f,1000.f);
  DrawCube();
  glPopMatrix();

  for (int x = 0; x < 250; ++x)
  {
    float t = (float)x + time*p0d10;
    glPushMatrix();
    cubeColor = cubeColors[1];
    glTranslatef(sin(t*4.123f)*18.f,sin(t*1.5f)*10.f,cos(t)*10.f);
    glRotatef(time*20.f+t*55.f,1.f,1.f,0.f);
    glScalef(sin(t)*1.5f,cos(t)*1.5f,1.f);
	  DrawCube();
    glPopMatrix(); 
  }
} 

void BlurRenderTarget(int id)
{
  float kernelSize = 32.f;

  for (int pass = 0; pass < 5; ++pass)
  {
    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO_Handles[4]);
    glViewport(0,0,blurDownsampleRenderTargerX,blurDownsampleRenderTargerY);
    glBindTexture(GL_TEXTURE_2D, FBO_ColorBufferTextureHandles[id]);
    oglUniform1f(handle_kernelSizeX,kernelSize);
    oglUniform1f(handle_kernelSizeY,0.f);
    glClear(GL_DEPTH_BUFFER_BIT);
	  glRecti(-1,-1,1,1);

    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO_Handles[id]);
    glViewport(0,0,xres,yres);
    glBindTexture(GL_TEXTURE_2D, FBO_ColorBufferTextureHandles[4]);
    oglUniform1f(handle_kernelSizeX,0.f);
    oglUniform1f(handle_kernelSizeY,kernelSize);
    glClear(GL_DEPTH_BUFFER_BIT);
	  glRecti(-1,-1,1,1);
  
    kernelSize *= p0d66;
  }
}

__forceinline static
__declspec( naked ) float __fastcall
_floorf2( float )
{
  __asm {
    fld     dword ptr [esp+4]     ; float-Parameter (4 Bytes) nach st0 laden
    fstcw   word ptr [esp+4]      ; FPU ControlWord abspeichern (2 Bytes)
    mov     ax, word ptr [esp+4]  ; ControlWord nach ax
    or      ah, 0Ch               ; ControlWord ändern
    mov     word ptr [esp+6], ax  ; geändertes ControlWord abspeichern
    fldcw   word ptr [esp+6]      ; geändertes ControlWord laden
    frndint                       ; st0 abrunden
    //fldcw   word ptr [esp+4]      ; altes ControlWord wiedererstellen
    ret     4                     ; zurückgehen
  }
}

static HDC		     hDC;

/////////////////////////////////////////////////////////////////////////////////
// initialized data
/////////////////////////////////////////////////////////////////////////////////
// MAX_SAMPLES gives you the number of samples for the whole song. we always produce stereo samples, so times 2 for the buffer
static SAMPLE_TYPE	lpSoundBuffer[MAX_SAMPLES*2*2*2];  //(*2 because of a bug) // the other *2 is a safety area (sorry theres some bug!)
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
  MAX_SAMPLES*2*sizeof(SAMPLE_TYPE)*2,			// MAX_SAMPLES*sizeof(float)*2(stereo) (*2 because of a bug)
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

#endif
  // We create a window with the "EDIT" trick
  hWnd = CreateWindow("STATIC",0,WS_POPUP|WS_VISIBLE, 0,0, xres, yres,0,0,0,0);
  hDC = GetDC(hWnd);
  SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);

  // Opengl context bind
  wglMakeCurrent(hDC,wglCreateContext(hDC));

  // INITGLSTART
  for( int i=0; i<(sizeof(glFunctionPointers)/sizeof(void*)); i++ )
    glFunctionPointers[i] = wglGetProcAddress( glFunctionNames[i] );

  for (int i = 0; i < SHADER_COUNT; ++i)
  {
    int k = oglCreateShader(i == 0 ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER);
    oglShaderSource(k,1,&shaderCode[i],0);
    oglCompileShader(k);
    shaderCompiled[i]=k;
  }

  for (int i = 0; i < PROGRAM_COUNT; ++i)
  {
	int k = oglCreateProgram();
    oglAttachShader(k,shaderCompiled[0]);
    oglAttachShader(k,shaderCompiled[i+1]);
    oglLinkProgram(k);
	programs[i] = k;
  }
  
  glEnable(GL_DEPTH_TEST);

  // build fbo for the next frame
  oglGenFramebuffersEXT(FBO_COUNT, ((GLuint*)&FBO_Handles));
  glGenTextures(FBO_COUNT, ((GLuint*)&FBO_ColorBufferTextureHandles));
  int txres = xres;
  int tyres = yres;
  for (int i = 0; i < FBO_COUNT; ++i)
  {
    if (i == 4)
    {
      txres=blurDownsampleRenderTargerX;
      tyres=blurDownsampleRenderTargerY;
    }
    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO_Handles[i]);
    glBindTexture(GL_TEXTURE_2D, FBO_ColorBufferTextureHandles[i]);
    glTexImage2D(GL_TEXTURE_2D, 0, COLORFORMAT, txres, tyres, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    oglFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, FBO_ColorBufferTextureHandles[i], 0);
    // with depthbuffer
    GLuint depthBuffer;
    oglGenRenderbuffersEXT(1, &depthBuffer);
    oglBindRenderbufferEXT(GL_RENDERBUFFER_EXT, depthBuffer);
    oglRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT32, txres, tyres);
    oglFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, depthBuffer);
  }

  // INITGLEND

  //WaveHDR.lpData = (LPSTR)lpSoundBuffer;
  waveOutOpen	( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
  waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
  waveOutWrite( hWaveOut, &WaveHDR, sizeof(WaveHDR) );	

  //bhandle_cameraMatrix = oglGetUniformLocation(colorDisplayProgram,"c");
  //bhandle_sceneTime = oglGetUniformLocation(colorDisplayProgram,"f");
  //bhandle_nextMatrix = oglGetUniformLocation(morphCalcProgram,"n");
  //bhandle_fade = oglGetUniformLocation(morphProgram,"i");
  //bhandle_scratchTime = oglGetUniformLocation(morphProgram,"t");
  //bhandle_texture0 = oglGetUniformLocation(morphProgram,"t0");
  //bhandle_texture1 = oglGetUniformLocation(morphProgram,"t1");
  //bhandle_texture2 = oglGetUniformLocation(morphProgram,"t2");
  //bhandle_texture3 = oglGetUniformLocation(morphProgram,"t3");
  //bhandle_kernelSizeX = oglGetUniformLocation(blurProgram,"m");
  //bhandle_kernelSizeY = oglGetUniformLocation(blurProgram,"n");
  //bhandle_blurTexture = oglGetUniformLocation(blurProgram,"t"); 

  // We hide the cursor
  ShowCursor(FALSE);

  do
  {		
    waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
    currentFrameTime = (float)((float)MMTime.u.sample / 44100.0f);

    currentFrameTime += 15.f/0.75f;
    currentFrameTime *= 0.075f;

    float currentMorphDelta = .5f;
    if ((((int)(currentFrameTime / currentMorphDelta)+2) % 14) > 11)
      currentMorphDelta = .001f;
    frameTimeMorphBefore = _floorf2(currentFrameTime / currentMorphDelta) * currentMorphDelta;
    frameTimeMorphAfter = frameTimeMorphBefore + currentMorphDelta;
    timeBetween = (currentFrameTime - frameTimeMorphBefore) / currentMorphDelta;

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(90.f,(float)xres/(float)yres,p0d10,1000.f);

    // draws the source color scene
    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO_Handles[0]);
    DrawScene(frameTimeMorphBefore, colorDisplayProgram);

    // bind normal frameBuffer
    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO_Handles[2]);
    // draws the morph dest coordinates into normal frameBuffer
    DrawScene(frameTimeMorphAfter, morphCalcProgram);

    // draws the dest color scene
    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO_Handles[1]);
    DrawScene(frameTimeMorphAfter, colorDisplayProgram);
    // bind normal frameBuffer
    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, FBO_Handles[3]);
    // draws the morph dest coordinates into normal frameBuffer
    DrawScene(frameTimeMorphBefore, morphCalcProgram);

    //glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    oglUseProgram(blurProgram);
    oglUniform1i(handle_blurTexture,0);
    BlurRenderTarget(2);
    BlurRenderTarget(3);

	  // paint the morph
    oglBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    oglUseProgram(morphProgram);
    
	  oglActiveTexture(GL_TEXTURE0_ARB); 
    glBindTexture(GL_TEXTURE_2D, FBO_ColorBufferTextureHandles[0]);
    oglActiveTexture(GL_TEXTURE1_ARB); 
    glBindTexture(GL_TEXTURE_2D, FBO_ColorBufferTextureHandles[1]);
    oglActiveTexture(GL_TEXTURE2_ARB); 
    glBindTexture(GL_TEXTURE_2D, FBO_ColorBufferTextureHandles[2]);
    oglActiveTexture(GL_TEXTURE3_ARB); 
    glBindTexture(GL_TEXTURE_2D, FBO_ColorBufferTextureHandles[3]);
	  oglActiveTexture(GL_TEXTURE0_ARB); 

	  oglUniform1i(handle_texture0,0);
	  oglUniform1i(handle_texture1,1);
	  oglUniform1i(handle_texture2,2);
	  oglUniform1i(handle_texture3,3);

    oglUniform1f(handle_scratchTime,currentFrameTime);
    oglUniform1f(handle_fade,timeBetween); 

	  glClear(GL_DEPTH_BUFFER_BIT);
	  glRecti(-1,-1,1,1);

    oglUseProgram(0);
    SwapBuffers(hDC);
    
    MSG		msg;
	PeekMessage(&msg, hWnd, 0,0, PM_REMOVE); // prevent the hourglass
	//{
	//	TranslateMessage(&msg);
	//	DispatchMessage(&msg);
	//}
  } while(!GetAsyncKeyState(VK_ESCAPE) && (MMTime.u.sample < MAX_SAMPLES*2));//(*2 because of a bug)

  ExitProcess(0);
}
