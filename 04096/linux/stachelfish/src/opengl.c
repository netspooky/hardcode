#ifdef GLXEXT
#include <GL/glx.h>
#endif

#ifdef __APPLE__
#include <OpenGL/gl.h>
#else
#include <GL/gl.h>
#endif

#include <SDL/SDL.h>

//#include <stdlib.h> // this is in theory needed for random(). why comment it out?
#include <math.h>

#include "demo.vsh.h"
#include "demo.fsh.h"
#include "data.h" // hint: this is what stdint.h is for -> C99

#undef WITH_GL_ERROR

#ifdef WITH_GL_ERROR
#include <stdio.h>
#define CHECK_GL() { \
	GLenum err = glGetError();   \
	while (err != GL_NO_ERROR) { \
            fprintf(stderr, "glError: %s caught at %s:%u\n", (char *)gluErrorString(err), __FILE__, __LINE__); \
            err = glGetError(); \
	} \
}
#else
#define CHECK_GL()
#endif

#ifdef GLXEXT
PFNGLUNIFORM1FPROC glUniform1f;
PFNGLUNIFORM1IPROC glUniform1i;
PFNGLGETUNIFORMLOCATIONPROC glGetUniformLocation;
#endif

GLuint p;
GLuint tex;

SDL_AudioSpec sdlaudio;

inline void setTextures()
{
    unsigned char data[512];
    int i;
    for (i=0; i<512; ++i) {
        data[i] = (unsigned char)((random() / (float)RAND_MAX) * 255);
    }
    glGenTextures(1, &tex);
    CHECK_GL();
    glActiveTexture(GL_TEXTURE0);
    CHECK_GL();
    glBindTexture(GL_TEXTURE_1D, tex);
    CHECK_GL();
    glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    CHECK_GL();
    glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
    CHECK_GL();
    glTexImage1D(GL_TEXTURE_1D, 0, GL_INTENSITY8UI_EXT, 512, 0, GL_LUMINANCE_INTEGER_EXT, GL_UNSIGNED_BYTE, data);
    CHECK_GL();
}

static void setShaders() 
{
    GLuint v = glCreateShader(GL_VERTEX_SHADER);
    CHECK_GL();
    GLuint f = glCreateShader(GL_FRAGMENT_SHADER);	
    CHECK_GL();
    
    glShaderSource(v, 1, &vertexShader, NULL);
    CHECK_GL();
    glShaderSource(f, 1, &fragmentShader, NULL);
    CHECK_GL();
    
    glCompileShader(v);
    CHECK_GL();
    glCompileShader(f);
    CHECK_GL();
    
    p = glCreateProgram();
    CHECK_GL();
    
    glAttachShader(p,v);
    CHECK_GL();
    glAttachShader(p,f);
    CHECK_GL();
    
    glLinkProgram(p);
    CHECK_GL();
    glUseProgram(p);
    CHECK_GL();
}

float sval = 0;
long t = 0;

short notes[5] = {220, 262, 349, 262, 330};
int n = 0;
float lastton = 0.0;

void player_call(void *udata, int1u *stream, int4 len) {
    float freq = notes[n];
    float slope = freq / 44100.0;
    int i;
    for(i=0; i<len/2; ++i) {
        sval = sval + slope;
        if(sval > 2.0) sval -= 2.0;
        float ton = (sval > 1.0) ? 32767.0 : -32767.0;
        ton *= sinf(sval*5.0f); // FM for phatt sound!
        float hull = sinf( (float)t / 44100.0 );
        ton = 0.2 * ton + 0.8 * lastton; // Lowpass for less harsh sound
        ((int2*)stream)[i] = (short)(ton * hull);
        t++;
        if(t > 138544) { // PI * 44100
            t=0;
            n++;
            if(n==5)
                n = 0;
        }
        lastton = ton;
    }
}

#ifdef __APPLE__
int main(int argc, char **argv)
#else
int main()
#endif
{
    SDL_Init( SDL_INIT_VIDEO );

#ifdef GLXEXT
   glUniform1f = (PFNGLUNIFORM1FPROC) glXGetProcAddress("glUniform1f");
   glUniform1i = (PFNGLUNIFORM1IPROC) glXGetProcAddress("glUniform1i");
   glGetUniformLocation = (PFNGLGETUNIFORMLOCATIONPROC) glXGetProcAddress("glGetUniformLocation");
#endif

    SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
    //SDL_SetVideoMode( 1280, 720, 32, SDL_OPENGL | SDL_FULLSCREEN);
    SDL_SetVideoMode( 1280, 720, 32, SDL_OPENGL);
    SDL_ShowCursor(0);

    sdlaudio.freq = 44100;
    sdlaudio.format = AUDIO_S16; // 16 bit signed
    sdlaudio.channels = 1;
    sdlaudio.samples = 2048;
    sdlaudio.callback = player_call;
    sdlaudio.userdata = NULL;

    SDL_OpenAudio(&sdlaudio, NULL);

    SDL_PauseAudio(0);

    setShaders();
    setTextures();
    
    GLint my_time = glGetUniformLocation(p, "t");
    CHECK_GL();
    GLint my_tex = glGetUniformLocation(p, "p");
    CHECK_GL();
    glUniform1i(my_tex, 0);

    Uint32 ticks = 0;
    int quit = 0;
    while ((ticks < 1000*60) && (quit == 0))
    {
        SDL_Event event;

        while( SDL_PollEvent(&event) )
        {
            switch(event.type)
            {
            case SDL_KEYDOWN:
            case SDL_QUIT:
                quit = 1;
            default:
                break;
            }
        }

        ticks = SDL_GetTicks();
        glUniform1f(my_time, ticks / 1000.0);
        CHECK_GL();
        glRecti(-1, -1, 1, 1);
        CHECK_GL();

        SDL_GL_SwapBuffers();
    }

    SDL_CloseAudio();

    SDL_Quit();
}
