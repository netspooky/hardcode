//--------------------------------------------------------------------------//
// iq / rgba  .  tiny codes  .  2008                                        //
//--------------------------------------------------------------------------//

#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>
#include <GL/gl.h>
#include <math.h>
#include "config.h"
#include "ext.h"
#include "shaders/fsh_rayt.inl"
#include "shaders/vsh_2d.inl"
#include "fp.h"

#ifdef _DEBUG
#include <stdio.h>
#endif

//=================================================================================================================


static void initShader( int *pid, const char *vs, const char *fs )
{
    pid[0] = oglCreateProgram();                           
	const int vsId = oglCreateShader( GL_VERTEX_SHADER ); 
	const int fsId = oglCreateShader( GL_FRAGMENT_SHADER );
	oglShaderSource( vsId, 1, &vs, 0 );
	oglShaderSource( fsId, 1, &fs, 0 );
    oglCompileShader( vsId );
    oglCompileShader( fsId );
	oglAttachShader( pid[0], fsId );
	oglAttachShader( pid[0], vsId );
	oglLinkProgram( pid[0] );
    
    #ifdef _DEBUG
        int		result;
        char    info[1536];
        FILE *fp = fopen("debug.log","w");
        oglGetObjectParameteriv( vsId,   GL_OBJECT_COMPILE_STATUS_ARB, &result ); oglGetInfoLog( vsId,   1024, NULL, (char *)info );// if( !result ) DebugBreak();
        fprintf(fp,info);
        oglGetObjectParameteriv( fsId,   GL_OBJECT_COMPILE_STATUS_ARB, &result ); oglGetInfoLog( fsId,   1024, NULL, (char *)info );// if( !result ) DebugBreak();
        fprintf(fp,info);
        oglGetObjectParameteriv( pid[0], GL_OBJECT_LINK_STATUS_ARB,    &result ); oglGetInfoLog( pid[0], 1024, NULL, (char*)info );// if( !result ) DebugBreak();
        fprintf(fp,info);
        fclose(fp);
    #endif
}

//=================================================================================================================

static int   pid;
static float aspect = float(YRES)/float(XRES);
//=================================================================================================================

int intro_init( void )
{
    if( !EXT_Init() )
        return( 0 );
    initShader( &pid, vsh_2d, fsh_rayt );
    return 1;
}

//=================================================================================================================

float fparams[4*4]; // vec4 [4]
enum E_SHOTS {SHOT_A,SHOT_AB,SHOT_B,SHOT_C,SHOT_CD,SHOT_D,SHOT_E,SHOT_F,SHOT_G,SHOT_OUT,SHOT_NULL};
typedef struct shot_t {
    float time;
    enum E_SHOTS id;
} shot_t;
int current_shot = 0;
shot_t shots[] = {
{0.f,SHOT_A},
{17.f,SHOT_AB},
{20.f,SHOT_B},
{36.f,SHOT_C},
{47.f,SHOT_CD},
{52.f,SHOT_D},
{60.f,SHOT_E},
{92.f,SHOT_A},
{108.f,SHOT_F},
{124.f,SHOT_G},
{140.f,SHOT_OUT},
{152.f,SHOT_NULL},
{999.f,SHOT_NULL}
};

float clamp(float n, float min, float max){
    if(n<min){n=min;}
    if(n>max){n=max;}
    return n;
}


float bias(float a, float b, float x){
    return (x - a)/(b - a);
}

float smoothstep(float a, float b, float x)
{
    x = clamp(bias(a,b,x),0.f,1.f);
    return x*x*(3 - 2*x);
}


float lerp (float a, float b, float t){
    return (1.f-t)*a + t*b;
}

void camPos(float* par,float t){
    switch (shots[current_shot].id){
        case SHOT_A:
        default:
            par[0] = 0.f;
            par[1] = 0.f;
            par[2] = -160.f;
            break;
        case SHOT_AB:
            par[0] = 0.f;
            par[1] = lerp(0.f,8.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            par[2] = -160.f;
            break;
        case SHOT_B:
            par[0] = 0.f;
            par[1] = 8.f;
            par[2] = -160.f;
            break;
        case SHOT_C:
            par[0] = 0.f;
            par[1] = 8.f;
            par[2] = -88.f;
            break;
        case SHOT_CD:
            par[0] = 0.f;
            par[1] = lerp(8.f,16.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            par[2] = lerp(-88.f,-95.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            break;
        case SHOT_D:
            par[0] = 16.f*sin((t-shots[current_shot].time)*smoothstep(shots[current_shot].time,shots[current_shot].time+6.f,t));
            par[1] = 16.f*cos((t-shots[current_shot].time)*smoothstep(shots[current_shot].time,shots[current_shot].time+6.f,t));
            par[2] = -95.f;
            break;
        case SHOT_E:
            par[0] = sin(t*p0d10)*lerp(88.f,8.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            par[1] = cos(t*p0d10)*lerp(88.f,8.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            par[2] = lerp(-80.f,-150.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            break;
        case SHOT_F:
            par[0] = 0.f;
            par[1] = lerp(88.f,32.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            par[2] = lerp(0.f,180.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            break;
        case SHOT_G:
            par[0] = cos(t*p0d50)*8.f;
            par[1] = sin(t*p0d50)*8.f;
            par[2] = lerp(80.f,88.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            break;
        case SHOT_OUT:
            par[0] = lerp(82.f,180.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            par[1] = 0.f;
            par[2] = 80.f;
            break;
        
    }   
}

void camTarg(float* par,float t){
    switch (shots[current_shot].id){
        default:
        case SHOT_A:
            par[0] = 0.f;
            par[1] = 0.f;
            par[2] = -152.f;
            break;
        case SHOT_AB:
            par[0] = 0.f;
            par[1] = lerp(0.f,-50.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            par[2] = -152.f;
            break;
        case SHOT_B:
            par[0] = 0.f;
            par[1] = lerp(-50.f,0.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            par[2] = lerp(-152.f,-100.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            break;
        case SHOT_C:
        case SHOT_CD:
        case SHOT_D:
            par[0] = 0.f;
            par[1] = 0.f;
            par[2] = -80.f;
            break;
        case SHOT_E:
            par[0] = 0.f;
            par[1] = 0.f;
            par[2] = lerp(-80.f,-180.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            break;
        case SHOT_F:
            par[0] = 0.f;
            par[1] = 0.f;
            par[2] = lerp(180.f,80.f,smoothstep(shots[current_shot].time,shots[current_shot+1].time,t));
            break;
        case SHOT_G:
            par[0] = 0.f;
            par[1] = 0.f;
            par[2] = 80.f;
            break;
        case SHOT_OUT:
            par[0] = 0.f;
            par[1] = 0.f;
            par[2] = 80.f;
            break;
    }   
}

void camUp(float* par,float t){
    switch (shots[current_shot].id){
        case SHOT_A:
        case SHOT_AB:
        case SHOT_B:
        default:
            par[0] = 0.f;
            par[1] = 1.f;
            par[2] = 0.f;
            break;
        case SHOT_C:
        case SHOT_CD:
        case SHOT_D:
        case SHOT_E:
        case SHOT_F:
        case SHOT_OUT:
            par[0] = 0.f;
            par[1] = 0.f;
            par[2] = 1.f;
            break;
        case SHOT_G:
            par[0] = 0.f;
            par[1] = 0.5f;
            par[2] = 1.f;
            break;
    }   

}

void camFade(float* par,float t){
    par[0] = smoothstep(3.95f,4.1f,t)*(1-smoothstep(140.f,150.f,t));

}

float pulsef(float t){
    switch(shots[current_shot].id){
        case SHOT_E:
        case SHOT_F:
        case SHOT_G:
        case SHOT_OUT:
            return 2.0;
        default:
            return 0.5;
            
    }
}

void intro_do( float t )
{
    /*  PARAMATER TABLE
            x/0     y/1     z/2     w/3
    0/0     aspect  time    fade    pulsef
    1/4     CAMPOSX CAMPOSY CAMPOSZ NONE
    2/8     CAMTX   CAMTY   CAMTZ   NONE
    3/12    CAMUPX  CAMUPY  CAMUPZ  NONE
    */

    // uniforms

    if(t>shots[current_shot+1].time){
        current_shot++;
    }

    fparams[ 0] = aspect;
    fparams[ 1] = t;
    camFade(&fparams[2],t);
    fparams[3] = pulsef(t);
    camPos(&fparams[1*4],t);
    camTarg(&fparams[2*4],t);
    camUp(&fparams[3*4],t);
    
    //--- render -----------------------------------------

    oglUseProgram( pid );
    oglUniform4fv( oglGetUniformLocation( pid, "fpar" ),  4, fparams );
    glRects( -1, -1, 1, 1 );
}