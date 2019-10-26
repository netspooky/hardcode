//  
//  == Stochastic Lens Simulator == 
//
//   A 4k Intro for Instanssi 2011
//            Gzrrplox
//


#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <cstdio>
#include <stdint.h>
#include <cmath>
#include "SDL.h"
#include "settings.h"

//Uncomment to disable sample filtering
//#define DEBUG_SAMPLES

#ifdef DEBUG_SAMPLES
#define SCALE "1"
#endif

const size_t N = 1000; // number of points
unsigned int start_time;
static size_t pos = 0;

GLuint filter_prog, display_prog, sample_prog, sound_prog;
GLuint fbo_sample, depth_sample, sample_tex;
GLuint fbo_y, fbo_ytex;
GLuint fbo_x, fbo_xtex;
GLuint fbo_sound, sound_tex, pbo_sound;
GLuint vertices;

// Sound texture store
float sound_data[2200*10*3]; 


// Passtrough vertex shader
const GLchar *vertex_source="\
#version 150\n\
in vec4 vertex;\
void main(){\
    gl_Position = vertex;\
}";


// Fragment shader to display filtered texture, scale
// sample coordinates to match texture coordinates
const GLchar *display_source="\
#version 150\n\
#extension GL_ARB_texture_rectangle : enable\n\
uniform sampler2DRect tex;\
out vec4 color;\
\
void main(){\
    vec2 coord = gl_FragCoord.st;\
    color = texture2DRect(tex, coord * " SCALE ");\
}";

// I don't like single pixel wide box filters too much, so reduce image
// size with a separable ~3.3 pixels wide Gaussian filter. Hardcoded for 4x4
// samples per pixel like in everywhere else here
const GLchar *filter_source="\
#version 150\n\
#extension GL_ARB_texture_rectangle : enable\n\
uniform sampler2DRect tex;\
float w(float x) {\
    return (pow(2.718281828, -(x*x))) / 7.3;\
}\
out vec4 color;\
\
void main(){\
    vec2 coord = gl_FragCoord.st;\
    vec2 m;\
    if (textureSize(tex).x == " FB_W ") m = vec2(1,0);\
    else m = vec2(0,1);\
    coord *= m*3+1;\
    float x = -1.625;\
    for (int i = -8; i < 8; ++i) {\
        color += w(x) * texture2DRect(tex, coord + vec2(i,i) * m);\
        x += 0.25;\
    }\
}";

// "Sounds" are specified as 3-dimensional vertices where
//   x = temporal position in seconds
//   y = channel in range [0..9]
//   z = width in deciseconds
// This geometry shader extracts a line of correct size and
// position as hull for pixel shader to work on to generate sounds
const GLchar *sound_geom_source="\
#version 150\n\
\
layout(points) in;\
layout(line_strip, max_vertices = 4) out;\
\
void main() {\
   vec4 v = gl_in[0].gl_Position * vec4(2.0/102.0,2.0/10.0,1,1) - vec4(1,0.95,0,0);\
   gl_Position = v;\
   EmitVertex();\
   gl_Position = v + vec4(v.z,0,0,0);\
   EmitVertex();\
}";

// Generate random values for each line we get from last stage.
// Frequency is reduced as channel value increases. Stochastic sounds for
// stochastic demo. RNG from stackoverflow.
const GLchar *sound_source="\
#version 150\n\
out vec4 color;\
\
float rand(vec2 co){\
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);\
}\
void main(){\
    float r;\
    vec2 st = gl_FragCoord.st;\
    for (float i = 0; i < 10; i += 1) {\
        if (distance(st.t-0.5, i) < 0.5) r = rand(floor(gl_FragCoord.st/(i+1)));\
    }\
    color = vec4(r);\
}";

// The master vertex shader
// Input is a set of single dimensional points with values increasing
// from 0 to PI*2. The points are transformed according to samples
// from the sound texture at current time position. Points are transformed
// twice, once slightly before current frame and once after. Both values
// are passed forward for geometry shader to work on.
//
// Animation itself is a quick fisheye projection and a ring distorted
// with a sine function, not done in particularly many minutes. Color
// comes directly from coordinates
const GLchar *transform_source="\
#version 150\n\
#extension GL_ARB_texture_rectangle : enable\n\
uniform sampler2DRect tex;\
uniform float time;\
in float pos;\
\
out Vertex {\
    vec3 pos1;\
    vec3 pos2;\
    vec3 color;\
} vertex;\
float rand(vec2 co){\
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);\
}\
vec4 tr(vec4 p){\
    float r = length(p);\
    float i = acos(p.z/r) * 0.8;\
    float a = atan(p.x, p.y);\
    return vec4(sin(a)*i,cos(a)*i,pow(r/5000.0, 0.25),1);\
}\
\
vec4 animate(float p, float t){\
    float vals[10];\
    for (int i = 0; i < 10; i += 1) {\
        vals[i] = texture2DRect(tex, vec2(t * 21.5332, i)).x;\
    }\
    float ring = vals[0]+vals[1]+vals[2];\
    float haste = vals[3] + vals[4];\
    float box = vals[5] + vals[6];\
    mat4 m = mat4(cos(t), 0, sin(t), 0,   0, 1, 0, 0,  -sin(t), 0, cos(t), 0,  0, 0, 0, 1) * \
        mat4(1000, 0, 0, 0,  0, 1000, 0, 0, 0, 0, 1000, 1000, 0, 0, 0, 1);\
    vec3 p1 = vec3(0);\
    vec3 p2 = vec3(0);\
    vec3 p3 = vec3(0);\
    p1 = vec3(sin(p)*ring, cos(p)*ring, sin(pos*2)*0.2);\
    if (haste > 0.1) p2 = vec3(sin(p+haste*sin(t)*t), cos(p+haste*sin(t)*t), sin(pos*10)*sin(haste*t*10));\
    return tr((vec4(p1+p2+p3, 1)) * m);\
}\
\
void main(){\
    vec4 p1 = animate(pos, time);\
    vec4 p2 = animate(pos, time+1.0/20.0);\
    vec3 r = vec3(pos*1.1, pos*2.3, pos*4.7);\
    vertex.pos1 = p1.xyz;\
    vertex.pos2 = p2.xyz;\
    vertex.color = vec3(normalize(p1.xyz));\
}";  

// Micropolygon renderers greatly rely on ability to bound
// geometry efficiently. Fast moving and out of focus objects
// may overlap a lot of sample positions at different time and
// lens positions. This geometry shader creates a quad that
// is aligned to the point's linear motion path and has same width
// as the out of focus area.
const GLchar *bound_source="\
#version 150\n\
uniform float time;\
uniform vec2 focus;\
\
layout(points) in;\
layout(triangle_strip, max_vertices = 4) out;\
\
in Vertex {\
    vec3 pos1;\
    vec3 pos2;\
    vec3 color;\
} vertex[];\
\
out Fragment {\
    vec3 pos1;\
    vec3 pos2;\
    vec3 color;\
    float size;\
} frag;\
\
void main() {\
   vec4 p1 = vec4(vertex[0].pos1, 1.0);\
   vec4 p2 = vec4(vertex[0].pos2, 1.0);\
   vec4 d = vec4(normalize(p2.xy - p1.xy), 0, 0);\
   if (distance(p2.xy, p1.xy) < 0.0001) d = vec4(1,0,0,0);\
   vec4 n = vec4(-d.y, d.x, 0, 0);\
   float size = 0.1;\
   float z1 = distance(p1.z, focus.x)*focus.y + size * (1.0 - p1.z);\
   float z2 = distance(p2.z, focus.x)*focus.y + size * (1.0 - p2.z);\
   frag.pos1 = p1.xyz * vec3(1.6,1,1);\
   frag.pos2 = p2.xyz * vec3(1.6,1,1);\
   frag.color = vertex[0].color;\
   frag.size = size;\
   gl_Position = p1 - n*z1 - d*z1;\
   EmitVertex();\
   gl_Position = p1 + n*z1 - d*z1;\
   EmitVertex();\
   gl_Position = p2 - n*z2 + d*z2;\
   EmitVertex();\
   gl_Position = p2 + n*z2 + d*z2;\
   EmitVertex();\
}";

// The polygons generated at previous shader are now
// fairly tight bounds. Let the sampling begin. 
// For each sample position a random time and lens position
// is generated. Primitives (simply screen aligned discs)
// are moved at each sample position to their current 
// temporal position by interpolating between the startpoint
// and endpoint (generated at vertex shader) with the temporal
// coordinate of the sample. Then the disc is moved to the direction
// of the stochastically chosen lens sample position multiplied
// by the size of the out of focus area.
//
// Random number generator is of low quality and jittering 
// for better sample distribution is not currently used, so the
// end result is noisy. 
const GLchar *sample_source="\
#version 150\n\
uniform float time;\
uniform vec2 focus;\
uniform vec2 fb;\
\
in Fragment {\
    vec3 pos1;\
    vec3 pos2;\
    vec3 color;\
    float size;\
} frag;\
\
out vec4 color;\
\
float rand(vec2 co){\
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);\
}\
void main(){\
    vec2 xy = (gl_FragCoord.xy / fb * 2 - 1) * vec2(1.6,1);\
    float t = rand(xy + time);\
    float a = 6.3 * rand(xy * 1.1 + time);\
    float r = rand(xy * 1.2 + time);\
    vec2 lens = vec2(sin(a) * r, cos(a) * r);\
    vec3 pos = mix(frag.pos1, frag.pos2, t);\
    vec2 m = pos.st - xy + lens * distance(pos.z, focus.x) * focus.y;\
    float d = length(m);\
    if (d < frag.size * (1.0 - pos.z)) {\
        color = vec4(frag.color, 1);\
        gl_FragDepth = clamp(pos.z, 0.0, 0.99);\
    } else {\
        gl_FragDepth = 1.95;\
        color = vec4(0.05);\
    }\
}";      

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

void compile_shader(GLuint prog, GLenum type, GLsizei n, const GLchar **src) {
    GLuint s;
    s = glCreateShader(type);
    glShaderSource(s, n, src, NULL);
    glCompileShader(s);
    glAttachShader(prog, s);

    printLog(s);
}

void init_shader(const GLchar *vs, const GLchar *gs, const GLchar *fs, GLuint *p) {
    *p = glCreateProgram();
    
    compile_shader(*p, GL_VERTEX_SHADER, 1, &vs);
    compile_shader(*p, GL_FRAGMENT_SHADER, 1, &fs);
    if (gs) compile_shader(*p, GL_GEOMETRY_SHADER, 1, &gs);

    glLinkProgram(*p);

    printLog(*p);
}

static void init_tex(GLuint* tex, int w, int h) {
    glGenTextures(1, tex);
    glBindTexture(GL_TEXTURE_RECTANGLE, *tex);
    glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

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

static void init_fbo(GLuint *fbo, GLuint *fbo_tex, int w, int h) {
    init_tex(fbo_tex, w, h);

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

    GLuint pos = glGetAttribLocation(sample_prog, "pos");
    glVertexAttribPointer(pos, 1, GL_FLOAT, GL_FALSE, sizeof(float), 0);
    glEnableVertexAttribArray(pos);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


// Audio callback sums up the values at sound texture
// at every 1/2048th of second and renders two overlapping
// sine waveforms with a triangle window. Sum of samples
// at endpoints is used as frequency. Might not sound
// quite right if implementation does not support 2048 samples

static void audio_callback(void* /*user*/, Uint8 *_stream, int _length)
{
    Sint16 *stream = (Sint16*) _stream;
    size_t length = _length / 2;

    double a = 0;
    double b = 0;
    for (size_t i = 0; i < 10; ++i) {
        size_t row = i*2200*3;
        size_t off = pos * 3 / 2048;
        a += sound_data[row+off];
        b += sound_data[row+off+3];
    }

    for (size_t i = 0; i < length; ++i) {
        double t = double(i+pos) / 44100.0 * M_PI * 2.0;

        double ratio = double((i+pos) % 2048) / 2048.0;
        double sample = sin(t * 30 * (1.0 + a*10)) * (1.0 - ratio) + sin(t * 30 * (1.0 + b*10)) * ratio;
        stream[i] = 16000 * sample;
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
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glUseProgram(sample_prog);

    GLuint time_loc = glGetUniformLocation(sample_prog, "time");
    GLuint focus_loc = glGetUniformLocation(sample_prog, "focus");
    GLuint fb_loc = glGetUniformLocation(sample_prog, "fb");
    
    glUniform1f(time_loc, float(SDL_GetTicks() - start_time) / 1000.0f);

    // This would control depth of field, however there wasn't enough
    // time for a effect to show it (see you at Stream Eight)
    glUniform2f(focus_loc, 0.7f, 0.0f); 
    
    glUniform2f(fb_loc, fb_w, fb_h);
    
    glBindTexture(GL_TEXTURE_RECTANGLE, sound_tex);
    glBindBuffer(GL_ARRAY_BUFFER, vertices);
    glDrawArrays(GL_POINTS, 0, N);
   
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
    if (pos / 2048 > 1500) return 0;

    while (SDL_PollEvent(&ev)) {
        if (ev.type == SDL_KEYDOWN) {
            if(ev.key.keysym.sym == SDLK_ESCAPE) return 0;
        }
        if (ev.type == SDL_QUIT) return 0;
    }
    return 1;
}


// Vertices are used as a source for generating sound
static void some_sound(unsigned char time, unsigned char channel, unsigned char l) {
    glVertex3f(float(time), float(channel), float(l)  / (10.0f * 102.0f * 0.5f) );
}

int main() {
    SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
    SDL_SetVideoMode(window_w, window_h, 24, SDL_OPENGL);
    SDL_ShowCursor(0);

    // Initialize framebuffer objects
    init_fbo(&fbo_sound, &sound_tex, 2200, 10);
    init_fbo(&fbo_x, &fbo_xtex, image_w, fb_h);
    init_fbo(&fbo_y, &fbo_ytex, image_w, image_h);
    init_fbo(&fbo_sample, &sample_tex, fb_w, fb_h);
    init_rbo(&depth_sample, fbo_sample, fb_w, fb_h);

    // Initialize shaders
    init_shader(vertex_source, sound_geom_source, sound_source, &sound_prog);
    init_shader(vertex_source, NULL, filter_source, &filter_prog);
    init_shader(vertex_source, NULL, display_source, &display_prog);
    init_shader(transform_source, bound_source, sample_source, &sample_prog);

    // Single vbo of dummy float values is used to generate geometry
    init_vbo(&vertices, N, NULL);
    glBindBuffer(GL_ARRAY_BUFFER, vertices);
    static float v[N];
    for (int i = 0; i < N; ++i) {
        v[i] = float(i) / float(N) * M_PI * 2;
    }
    glBufferSubData(GL_ARRAY_BUFFER, 0, N*sizeof(float), v);


    // Clamping occurs without these even with floating point textures
    glClampColor(GL_CLAMP_FRAGMENT_COLOR, GL_FALSE);
    glClampColor(GL_CLAMP_VERTEX_COLOR, GL_FALSE);
    glClampColor(GL_CLAMP_READ_COLOR, GL_FALSE);

    //Prepare for generating sound
    glBindFramebuffer(GL_FRAMEBUFFER, fbo_sound);
    glBindBuffer(GL_ARRAY_BUFFER, vertices);    
    glUseProgram(sound_prog);

    static unsigned char sounds[21*3] = { 
        4, 0, 5,
        6, 0, 5,
        8, 0, 18,
        11, 1, 30,
        14, 2, 10,
        16, 2, 20,
        20, 3, 100,
        30, 4, 50,
        35, 3, 50,
        40, 4, 200,
        42, 0, 10,
        43, 2, 10,
        45, 1, 5,
        46, 2, 5,
        50, 2, 50,
        53, 1, 20,
        56, 0, 35,
        62, 0, 10,
        63, 1, 10,
        65, 2, 10,
        67, 2, 2
    };
    
    //Render
    glViewport(0,0,2200,10);
    glClear(GL_COLOR_BUFFER_BIT);
    glBegin(GL_POINTS);
    for (int i = 0; i < 21*3; i += 3) {
        some_sound(sounds[i], sounds[i+1], sounds[i+2]);
    }
    glEnd();

    //And copy to memory space accessible by SDL audio thread
    glReadPixels(0, 0, 2200, 10, GL_RGB, GL_FLOAT, (GLvoid*)sound_data);
    
    // Initialize points

    init_audio();
    SDL_PauseAudio(0);
    start_time = SDL_GetTicks();

    // All set, let's go
    do {
        draw();
        SDL_GL_SwapBuffers();
    } while (do_stuff());


    SDL_PauseAudio(1);
    SDL_CloseAudio();
    SDL_Quit();

    return 0;
}
