#ifndef _MAIN_H_
#define _MAIN_H_

#define PI    3.141592654
#define TWOPI 6.283185308

//#define LENGTH (16*5088*33/441/10)
#define LENGTH (60918+20)
#define SOUND
#define FULLSCREEN

typedef unsigned char uint8;
typedef char int8;
typedef unsigned short uint16;
typedef short int16;
typedef unsigned int uint32;
typedef int int32;

void synth_init();
void synth_render(int16 *buf,  int len);

void intro_init();
void intro_run(int32 time);

#endif
