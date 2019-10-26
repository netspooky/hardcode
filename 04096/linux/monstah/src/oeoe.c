#define __USE_ISOC9X 1
#define __USE_ISOC99 1
#define __USE_EXTERN_INLINES 1

#define FULLSCREEN
#define USE_STDOUT_AUDIO
//#define NO_SOUND

#ifdef DEBUG
#define ASSERT(e) assert(e)
#else
#define ASSERT(e)
#endif

#include "SDL.h"
#include <assert.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "macros.h"

REGPARM static inline int ftoi(float f) {
  return lrintf(f);
}

REGPARM static inline float lerp(float a, float b, float t) {
  return a + (b - a) * t;
}

#if 0
/* f2xm1 is 2^x-1 */
REGPARM static inline float f2xm1(float x) {
  __asm__ __volatile__ (
      "f2xm1"
      : "=t" (x)
      : "0" (x));
  return x;
}

REGPARM static inline float pow2(float x) {
  return f2xm1(x) + 1;
}
#endif

static const unsigned char song[] = {
#include "song.h"
};

#define TEMPO (250 * 8)

#include "dynamic.c"
#include "zalloc.c"
#include "synth.c"
#include "vector3d.c"
#include "mesh.c"
//#include "font.c"
#include "script.c"
#include "intro.h"

#ifndef USE_STDOUT_AUDIO
static SDL_AudioSpec desired = {
  .freq = 8000,
  .format = AUDIO_U8,
  .channels = 1,
  .samples = 1024,
  .callback = music_fill,
};
#endif

/* The main function */

#ifdef DEBUG
int main() {
#else
STDCALL REGPARM NORETURN void _start() {
#endif
#ifndef DEBUG
  init_dynamic_functions();
#endif

  /* Extract music */
  {
    const unsigned char *p = song;

//    playlist_ptr2 = p;

#if 0
    for(unsigned int j=0; j<3; j++)
      for(unsigned int i=0; i<playlist_count; i++)
        playlist[i][j] = *p++;
#endif

    p = song + playlist_count*3;

    unsigned int i = 0;
    do {
      /* TODO: transpose, it would probably pack better, test which is better
       *       when Sanxion has made the song */
      unsigned int *t = &tab[i][0].type;
      for(unsigned int j=0; j<pattern_size; j++) {
#if 0
        tab[i][j].type = *p++;
        tab[i][j].arg1 = *p++;
        tab[i][j].arg2 = *p++;
#else
#if 0
        *t++ = *p++;
        *t++ = *p++;
        *t++ = *p++;
        t++;
#else
        *t++ = *p;
        *t++ = *(p + pattern_size);
        *t++ = *(p + 2*pattern_size);
        p++;
        t++;
#endif
#endif
      }
      p += pattern_size*2;

      i++;
    } while(i < pattern_count);
  }

#ifdef USE_STDOUT_AUDIO
  SDL_Init(SDL_INIT_VIDEO);
#else
  SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO
#ifndef FULLSCREEN
      | SDL_INIT_NOPARACHUTE
#endif
      );
#endif

  SDL_SetVideoMode(640, 480, 0, SDL_OPENGL
#ifdef FULLSCREEN
      | SDL_FULLSCREEN
#endif
      );
  SDL_ShowCursor(SDL_DISABLE);

  music_prepare();
#ifndef NO_SOUND
#ifdef USE_STDOUT_AUDIO
  {
#if 0
    unsigned int pid;

    /* Fork */
    __asm__ __volatile__
      ("int $0x80"
       :"a="(pid)
       :"a"(2));

    if(pid == 0) {
      music_fill_forever();
      __asm__ __volatile__ ("cli");
    }
#endif
    if(fork() == 0) {
      music_fill_forever();
    }
  }
#else
  SDL_OpenAudio(&desired, NULL);
  SDL_PauseAudio(0);
#endif
#endif

  script_run();
}
