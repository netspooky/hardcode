/* no comment */


#include <stdlib.h>
#include <math.h>
#include "SDL.h"
#include "SDL_opengl.h"
#include "SDL_audio.h"

#include "data.c"

#define MSEC_FRAMES 0 /* 60 FPS is enough, '0' will disable frame limiter */
#define PI 3.1415926535897f
#define startpos 0//30000

SDL_Surface *screen;
float ar; /* aspect ratio, width/height */
Uint32 w, h;
char quit = 0;

static Uint32 ct;
struct rgba { float r, g, b, a; };
struct xyz  { float x, y, z; };

void NextFrame();
void cubetunnel(Uint32);
void cubetext(Uint32);
void cuberings(Uint32);
void fadeout(Uint32);
void thecube(struct rgba, struct xyz, struct xyz, float);

int initsound();
void playsound();
void closesound();

int main(int argc, char **argv) {
  SDL_Event event;
  Uint32 frames = 0,
         tlast = 0,
         tcurrent, st, argn = 0;
  Uint32 flags = SDL_OPENGL | SDL_HWPALETTE | SDL_FULLSCREEN;
  char fr = 0;
  
  while(++argn < argc) {
    if(argv[argn][0] == '-' && argv[argn][1] == 'r' && ++argn < argc) {
      fr = 1;
      switch(argv[argn][0]) {
        case '1': w=800; h=600; break;
        case '2': w=1024;h=786; break;
        case '3': w=1280;h=960; break;
        default: fr=0; break;
      }
    } if(argv[argn][0] == '-' && argv[argn][1] == 'w')
      flags ^= SDL_FULLSCREEN;
  }


  SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO);
  if(initsound() != 0) return 1;
  
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
  
  if((fr == 1 && !(screen = SDL_SetVideoMode(w, h, 0, flags))) || 
     (fr == 0&& !((screen = SDL_SetVideoMode(1280, 960, 0, flags)) && (w=1280) && (h=960))
             && !((screen = SDL_SetVideoMode(1024, 768, 0, flags)) && (w=1024) && (h=768))
             && !((screen = SDL_SetVideoMode( 800, 600, 0, flags)) &&  (w=800) && (h=600)))) {
    printf("Error opening screen: %s\n", SDL_GetError()); 
    return 1;
  }
  ar = (float) w / (float) h;
  SDL_WM_SetCaption("Blue Cubes by YorHel", "Blue Cubes by YorHel");
  SDL_ShowCursor(0);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glClearColor(0.0f, 0.0f, 0.0f, 0.5f);
  glClearDepth(1.0);
  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_LEQUAL);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);

  glViewport(0, 0, w, h);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(45.0f, ar, 0.1f, 100.0f);
  glMatrixMode(GL_MODELVIEW);


  st = SDL_GetTicks();
  playsound();
  while(!quit) {
   /* exit on input */
    while(SDL_PollEvent(&event) > 0) {
      if(event.type == SDL_QUIT || (event.type == SDL_KEYUP && (event.key.keysym.sym == SDLK_ESCAPE || event.key.keysym.sym == SDLK_q))) {
        quit = 1;
        continue;
      }
    }
    tcurrent = SDL_GetTicks();
    if(tcurrent < tlast + MSEC_FRAMES)
      continue;
    ct = SDL_GetTicks() - st + startpos;
/*    if(++frames % 1000 == 0)
      printf("%d frames in %f seconds (%f FPS)\n", frames, ct/1000.0f, (float) frames / (ct/1000.0f));*/

    NextFrame();
    glFlush();
    SDL_GL_SwapBuffers();
    tlast = tcurrent;
  }
  closesound();
  SDL_Quit();
  return 0;
}

void NextFrame() { 
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glLoadIdentity();

  if(ct < 32000 || ct > 41600)
    cubetunnel(ct);
  if(ct > 32000)
    cuberings(ct);
  if(ct > 35200)
    cubetext(ct-35200);
  if(ct > 54000)
    fadeout(ct-54000);
  if(ct > 55000)
    quit = 1;
}

void cuberings(Uint32 t) {
  float an;
  int i, j;
  
  gluLookAt(10.0,
            sin(PI/1800.0f*t)*10.0f,
            cos(PI/1800.0f*t)*10.0f,
            0.0, 0.0, 0.0, 0.0, 1.0, 0.0);

  an = t/1000.0f*90;
  for(i=0; i<3600; i+=180) {
    j = (int) (i+((int) t/1.0f)) % 3600;
    thecube(
      (struct rgba) { 0.0f, 0.0f, 1.0f, 0.3f },
      (struct xyz)  { cos(PI/1800.0f*j)*2.0f - 1.0f,
                      sin(PI/1800.0f*j)*2.0f,
                      0.0f },
      (struct xyz)  { an, 0.0f, -an },
      0.15f
    );
    thecube(
      (struct rgba) { 0.0f, 0.0f, 1.0f, 0.3f },
      (struct xyz)  { cos(PI/1800.0f*j)*2.0f + 1.0f,
                      0.0f,
                      sin(PI/1800.0f*j)*2.0f },
      (struct xyz)  { an, an, 0.0f },
      0.15f
    );
  }
  glLoadIdentity(); // reset the gluLookAt
}


void cubetext(Uint32 t) {
  int i, j, x, inc;
  static int lastinc = 0,
             w = 0;
  static struct rgba blue  = { 0.0f, 0.0f, 1.0f, 0.7f },
                     white = { 1.0f, 1.0f, 1.0f, 0.7f };
 
  if(w < sizeof(text)) {
    inc = (int) (t/0.5f) % 100;
    if(lastinc > inc) w++;
  } else
    inc = 0;

  for(i=0; i <= 55; i++) {
    x = (-i+28)*100 - inc;
    for(j=-2; j <= 7; j++) {
      thecube(
        (j>=0&&j<7 && w-i < sizeof(text) && text[w-i] & (int)pow(2.0, j))
          || j==-2||j==7 ? white : blue,
        (struct xyz)  { x/1000.0f, -1.5f + (float) (j-3)/10.0f, -5.0f },
        (struct xyz)  { 45.0f, 45.0f, 0.0f },
        0.03f
      );
    }
  }
  lastinc = inc;
}

void cubetunnel(Uint32 t) {
  float an = 0.0f, inc = 0.0f, al;
  int i, j, x, y, now;
  char clr;

  al = t/1000.0f*0.3f;
  if(al > 1.0f) al = 1.0f;
  if(t > 41600)
    al = 0.5f;

  an = -45.0f*t/1000.0f;
  inc = 100.0f * t / 1000.0f;

  now = t / 200;
  for(x=0; x < 140; x+=10) {
    y = x*10 + (int) inc % 100;
    for(i=0; i < 3600; i+=180) {
      j = (int) (i+((int) t/5.0f)) % 3600;
      clr = (t < 41600 && now % 2 == 0 && tunneldat[now/2][x/10] & (int)pow(2.0, i/180)) 
        || (t > 41600 && t/200 % 2 == 0 && tunneldat[t/400%2==0?77:78][x/10] & (int)pow(2.0, i/180)) ? 1 : 0;
      thecube(
        (struct rgba) { clr?1.0f:0.0f, clr?1.0f:0.0f, 1.0f, 0.0f+(float)y/2000.0f * al, },
        (struct xyz)  { cos(PI/1800.0f*j)*10.0f,                 // x
                        sin(PI/1800.0f*j)*10.0f,                 // y
                        -120.0f + sqrt((float)y/10.0f*85.0f) },  // z
        (struct xyz)  { 0.0f, 0.0f, an },
        0.8f);
    }
  }
}

void fadeout(Uint32 t) {
  glPushMatrix();
  glBegin(GL_QUADS);
    glColor4f(0.0f, 0.0f, 0.0f, 0.0f + (float)t/1000.0f);
    glVertex3f( 1.0f, 1.0f, -1.0f);
    glVertex3f(-1.0f, 1.0f, -1.0f);
    glVertex3f(-1.0f,-1.0f, -1.0f); 
    glVertex3f( 1.0f,-1.0f, -1.0f);
  glEnd();
  glPopMatrix();
}

void thecube(struct rgba clr, struct xyz pos, struct xyz rot, float size) {
  glPushMatrix();
  glTranslatef(pos.x, pos.y, pos.z);
  glRotatef(rot.x, 1.0f, 0.0f, 0.0f);
  glRotatef(rot.y, 0.0f, 1.0f, 0.0f);
  glRotatef(rot.z, 0.0f, 0.0f, 1.0f);
  glScalef(size, size, size);
  glBegin(GL_QUADS);
    glColor4f(clr.r, clr.g, clr.b, clr.a);
    glVertex3f( 1.0f, 1.0f,-1.0f); // top
    glVertex3f(-1.0f, 1.0f,-1.0f);
    glVertex3f(-1.0f, 1.0f, 1.0f);
    glVertex3f( 1.0f, 1.0f, 1.0f);

    glVertex3f( 1.0f,-1.0f, 1.0f); // bottom
    glVertex3f(-1.0f,-1.0f, 1.0f); 
    glVertex3f(-1.0f,-1.0f,-1.0f);
    glVertex3f( 1.0f,-1.0f,-1.0f);

    glVertex3f( 1.0f, 1.0f, 1.0f); // front
    glVertex3f(-1.0f, 1.0f, 1.0f);
    glVertex3f(-1.0f,-1.0f, 1.0f); 
    glVertex3f( 1.0f,-1.0f, 1.0f); 

    glVertex3f( 1.0f,-1.0f,-1.0f); // back
    glVertex3f(-1.0f,-1.0f,-1.0f);
    glVertex3f(-1.0f, 1.0f,-1.0f);
    glVertex3f( 1.0f, 1.0f,-1.0f);

    glVertex3f(-1.0f, 1.0f, 1.0f); // left
    glVertex3f(-1.0f, 1.0f,-1.0f);
    glVertex3f(-1.0f,-1.0f,-1.0f);
    glVertex3f(-1.0f,-1.0f, 1.0f);

    glVertex3f( 1.0f, 1.0f,-1.0f); // right
    glVertex3f( 1.0f, 1.0f, 1.0f);
    glVertex3f( 1.0f,-1.0f, 1.0f);
    glVertex3f( 1.0f,-1.0f,-1.0f);
  glEnd();
  glBegin(GL_LINE_STRIP); 
    glColor4f(0.0f, 0.0f, 0.0f, 0.8f);
    glVertex3f( 1.0f, 1.0f,-1.0f);
    glVertex3f(-1.0f, 1.0f,-1.0f);
    glVertex3f(-1.0f, 1.0f, 1.0f);
    glVertex3f( 1.0f, 1.0f, 1.0f);
    glVertex3f( 1.0f, 1.0f,-1.0f);
    glVertex3f( 1.0f,-1.0f,-1.0f);
    glVertex3f(-1.0f,-1.0f,-1.0f);
    glVertex3f(-1.0f,-1.0f, 1.0f);
    glVertex3f( 1.0f,-1.0f, 1.0f);
    glVertex3f( 1.0f,-1.0f,-1.0f);
    glVertex3f(-1.0f,-1.0f,-1.0f);
    glVertex3f(-1.0f, 1.0f,-1.0f);
    glVertex3f(-1.0f, 1.0f, 1.0f);
    glVertex3f(-1.0f,-1.0f, 1.0f);
    glVertex3f( 1.0f,-1.0f, 1.0f);
    glVertex3f( 1.0f, 1.0f, 1.0f);
  glEnd();
  glPopMatrix();
}


/***************************************************
 ******************** synth ************************/

#define AFREQ 44100 
#define AMAX 32767 
unsigned int acnt = startpos/1000 * AFREQ;

void wtfsynth(void *, Uint8 *, int);

int initsound() {
  SDL_AudioSpec fmt;
  fmt.freq = AFREQ;
  fmt.format = AUDIO_S16SYS;
  fmt.channels = 1;
  fmt.samples = 4096;
  fmt.callback = wtfsynth;
  fmt.userdata = NULL;
  if(SDL_OpenAudio(&fmt, NULL) < 0) {
    printf("Unable to open audio: %s\n", SDL_GetError());
    return 1;
  }
 
  return 0;
}

void playsound() {
  SDL_PauseAudio(0);
}
void closesound() {
  SDL_CloseAudio();
}

void wtfsynth(void *unused, Uint8 *stream, int len) {
  static int lastc = 0, lasti = -1;
  static char lastw = 0;
  float s;
  int i, l = len/2;
  short *dest = (short *) stream;
  
  for(i=0;i<l;i++,acnt++) {
    s = (float) acnt / (float) AFREQ;
    if(lasti != (int)floorf(s/0.2f)) {
      lastw = sounddat[(int)floorf(s/0.2)];
      lastc = 0;
      lasti = (int)floorf(s/0.2f);
    }
    if(lastw > 0 && lastw < 4 && lastc < musicsizes[lastw-1]) {
      dest[i] = (musicdata[lastw-1])[lastc++];
    } else {
      dest[i] = 0;
    }
  }
}




