//--------------------------------------------------------------------------//
// iq . 2003/2008 . code for 64 kb intros by RGBA                           //
//--------------------------------------------------------------------------//

#ifndef _INTRO_H_
#define _INTRO_H_

typedef struct
{
    void *obj;
    void (*func)( void *data, float n );  // n=[0..200]
}IntroProgressDelegate;

int  intro_init( int xres, int yres, int nomusic, IntroProgressDelegate *pd );
int  intro_do( void );
void intro_end( void );

#endif
