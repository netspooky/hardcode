#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <cstdio>
#include <stdint.h>
#include <cmath>
#include "SDL.h"

//#define DEBUG_SAMPLES

#ifdef DEBUG_SAMPLES
#define SCALE "1"
#endif

#define POINTS "1000.0"
const size_t num_points = 1000;

#define NOTES "1000.0"
const size_t num_notes = 1000;

#define RUNTIME "120.0"
const double runtime = 120;

#define TIMERES "20.0"
const double timeres = 20.0;

#define ASPECT "1.6"
const double aspect = 1.6;

const size_t anim_width = timeres * runtime;

#define CHANNELS "20.0"
const size_t anim_channels = 20;

#define KICK "0"
#define KOSH "1"
#define NOISE "2"
#define GREET "10"


#include "settings.h"
#include "shaders.h"

unsigned int start_time;
int pos = 0;

GLuint filter_prog, display_prog, sample_prog, sound_prog, sound_render_prog;
GLuint fbo_sample, depth_sample, sample_tex;
GLuint fbo_y, fbo_ytex;
GLuint fbo_x, fbo_xtex;
GLuint fbo_sound, sound_tex;
GLuint fbo_sound_render, sound_render_tex;
GLuint vbo_points, vbo_notes;

GLuint time_loc, offset_loc;

const int sample_batch = 4096; // Sample texture width
const int sample_buffers = 10;  // Maximum number of batches rendered in a frame, make sure total buffer size is higher than fps
int sample_current = 0;
int sample_render = 0;
int sample_head = 0;
Sint16 samples[sample_batch * sample_buffers];


////////////////////////////////////////////////////////////////////////////////
// Uninteresting OpenGL utilities
////////////////////////////////////////////////////////////////////////////////

// Debug flag is enabled from Makefile
static void printLog(GLuint obj) {
#ifdef DEBUG    
	int infologLength = 0;
	int maxLength;
 
	if (glIsShader(obj)) glGetShaderiv(obj,GL_INFO_LOG_LENGTH,&maxLength);
	else glGetProgramiv(obj,GL_INFO_LOG_LENGTH,&maxLength);
 
	char infoLog[maxLength];
 
	if (glIsShader(obj)) glGetShaderInfoLog(obj, maxLength, &infologLength, infoLog);
	else glGetProgramInfoLog(obj, maxLength, &infologLength, infoLog);
 
	if (infologLength > 0) printf("%s\n",infoLog);
#endif    
}

static void compile_shader(GLuint prog, GLenum type, const GLchar *src) {
    const char* strings[2] = {common_source, src};
    GLuint s = glCreateShader(type);
    glShaderSource(s, 2, strings, NULL);
    glCompileShader(s);
    glAttachShader(prog, s);

    printLog(s);
}

static void init_shader(const GLchar *vs, const GLchar *gs, const GLchar *fs, GLuint *p) {
    *p = glCreateProgram();
    
    compile_shader(*p, GL_VERTEX_SHADER, vs);
    compile_shader(*p, GL_FRAGMENT_SHADER, fs);
    if (gs) compile_shader(*p, GL_GEOMETRY_SHADER, gs);

    glLinkProgram(*p);

    printLog(*p);
}

static void init_tex(GLuint* tex, int w, int h, GLint filter) {
    glGenTextures(1, tex);
    glBindTexture(GL_TEXTURE_RECTANGLE, *tex);
    glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MAG_FILTER, filter);

    glTexImage2D(GL_TEXTURE_RECTANGLE, 0, GL_RGB16F, w, h, 0, GL_RGB, GL_FLOAT, NULL);
    glBindTexture(GL_TEXTURE_RECTANGLE, 0);
}

static void init_rbo(GLuint* rbo, GLuint fbo, int w, int h) {
    glGenRenderbuffers(1, rbo);
    glBindRenderbuffer(GL_RENDERBUFFER, *rbo);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, w, h);

    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, *rbo);
}

static void init_fbo(GLuint *fbo, GLuint *fbo_tex, int w, int h, GLint filter) {
    init_tex(fbo_tex, w, h, filter);

    glGenFramebuffers(1, fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, *fbo);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_RECTANGLE, *fbo_tex, 0);
#ifdef DEBUG    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        printf("could not init fb\n");
    }
#endif    
}

static void init_vbo(GLuint *vbo, int n, void *data) {
    glGenBuffers(1, vbo);
    glBindBuffer(GL_ARRAY_BUFFER, *vbo);
    glBufferData(GL_ARRAY_BUFFER, n*sizeof(float), data, GL_DYNAMIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


static void audio_callback(void* /*user*/, Uint8 *_stream, int _length)
{
    sample_current = pos / sample_batch;

    Sint16 *stream = (Sint16*) _stream;
    int length = _length / 2;
    
    int begin = pos % (sample_batch * sample_buffers);

    for (int i = 0; i < length; ++i) {
        stream[i] = samples[(i+begin) % (sample_batch * sample_buffers)];
    }

    pos += length;
}

static void init_audio() {
    SDL_AudioSpec spec, real_spec;
    spec.freq = 44100;
    spec.format = AUDIO_S16SYS;
    spec.channels = 1;
    spec.samples = 1024;
    spec.callback = audio_callback;

    int r = SDL_OpenAudio(&spec, &real_spec);
#ifdef DEBUG
    if (r == -1) {
        printf("could not init audio\n");
    }
    if (spec.freq != real_spec.freq) {
        printf("warning: expected %dHz, got %d\n", spec.freq, real_spec.freq);
    }
    if (spec.samples != real_spec.samples) {
        printf("warning: expected %d samples, got %d\n", spec.samples, real_spec.samples);
    }
#endif
}


// Draw a texture to a fbo fullscreen
static void draw_part(GLuint framebuffer, GLuint w, GLuint h, GLuint texture, GLuint program) {
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glViewport(0, 0, w, h);
    glBindTexture(GL_TEXTURE_RECTANGLE, texture);
    glUseProgram(program);
    glRecti(-1,-1, 1, 1);
}


// Drawing occurs here
// Raw samples are rendered to a huge framebuffer (3840x2400 with 4x4 
// pixelsamples and 960x600 image size). Image is then reduced in two
// passed to final size with a separable Gaussian filter, and final
// texture is finally scaled to display resolution and displayed.
static void draw() {
    glEnable(GL_DEPTH_TEST);

#ifndef DEBUG_SAMPLES    
    glBindFramebuffer(GL_FRAMEBUFFER, fbo_sample);
#else
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
#endif    
    glViewport(0, 0, fb_w, fb_h);
    glClearColor(1,1,1,1);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glUseProgram(sample_prog);

    glUniform1f(time_loc, float(SDL_GetTicks() - start_time) / 1000.0f);

    glBindTexture(GL_TEXTURE_RECTANGLE, sound_tex);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_points);
    glDrawArrays(GL_POINTS, 0, num_points);
   
    glDisable(GL_DEPTH_TEST);

#ifndef DEBUG_SAMPLES
    // Filtering in X-domain
    draw_part(fbo_x, image_w, fb_h, sample_tex, filter_prog);

    // Filtering in Y-domain
    draw_part(fbo_y, image_w, image_h, fbo_xtex, filter_prog);
    
    // Draw downsampled image on screen
    draw_part(0, window_w, window_h, fbo_ytex, display_prog);
#endif
}


static int do_stuff() {
    SDL_Event ev;
    if (pos / 44100 > 46) return 0;

    while (SDL_PollEvent(&ev)) {
        if (ev.type == SDL_KEYDOWN) {
            if(ev.key.keysym.sym == SDLK_ESCAPE) return 0;
        }
        if (ev.type == SDL_QUIT) return 0;
    }
    return 1;
}

static void draw_sound() {
    while (sample_head - sample_current < 10) {
        glBindFramebuffer(GL_FRAMEBUFFER, fbo_sound_render);
        glViewport(0, 0, sample_batch, 1);
        glBindTexture(GL_TEXTURE_RECTANGLE, sound_tex);
        
        glUseProgram(sound_render_prog);
        glUniform1f(offset_loc, float(sample_head));
        glRecti(-1,-1, 1, 1);
        
        glReadPixels(0, 0, sample_batch, 1, GL_RED, GL_SHORT, (GLvoid*)&samples[(sample_head % sample_buffers)*sample_batch]);
        sample_head += 1;
    }
};

int main() {
    SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
    SDL_SetVideoMode(window_w, window_h, 24, SDL_OPENGL);
    SDL_ShowCursor(0);

    init_fbo(&fbo_sound, &sound_tex, anim_width, anim_channels, GL_NEAREST);
    init_fbo(&fbo_sound_render, &sound_render_tex, sample_batch, 1, GL_NEAREST);
    init_fbo(&fbo_x, &fbo_xtex, image_w, fb_h, GL_NEAREST);
    init_fbo(&fbo_y, &fbo_ytex, image_w, image_h, GL_NEAREST);
    init_fbo(&fbo_sample, &sample_tex, fb_w, fb_h, GL_NEAREST);
    init_rbo(&depth_sample, fbo_sample, fb_w, fb_h);

    init_shader(id_source, sound_geom_source, sound_source, &sound_prog);
    init_shader(vertex_source, NULL, filter_source, &filter_prog);
    init_shader(vertex_source, NULL, display_source, &display_prog);
    init_shader(transform_source, bound_source, sample_source, &sample_prog);
    init_shader(vertex_source, NULL, sound_render_source, &sound_render_prog);

    time_loc = glGetUniformLocation(sample_prog, "time");
    offset_loc = glGetUniformLocation(sound_render_prog, "time");

    init_vbo(&vbo_points, num_points, NULL);
    init_vbo(&vbo_notes, num_notes, NULL);

    // Clamping occurs without these even with floating point textures
    glClampColor(GL_CLAMP_FRAGMENT_COLOR, GL_FALSE);
    glClampColor(GL_CLAMP_VERTEX_COLOR, GL_FALSE);
    glClampColor(GL_CLAMP_READ_COLOR, GL_FALSE);

    //Prepare for generating sound
    glBindFramebuffer(GL_FRAMEBUFFER, fbo_sound);
    glUseProgram(sound_prog);

    //Render
    glViewport(0,0,anim_width,anim_channels);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindBuffer(GL_ARRAY_BUFFER, vbo_notes);
    glDrawArrays(GL_POINTS, 0, num_notes);

    init_audio();
    SDL_PauseAudio(0);
    start_time = SDL_GetTicks();

    // All set, let's go
    do {
        draw_sound();
        draw();
        SDL_GL_SwapBuffers();
    } while (do_stuff());


    SDL_PauseAudio(1);
    SDL_CloseAudio();
    SDL_Quit();

    return 0;
}
