/*
    Definitions for Syna

    - Marq
*/

extern int lastrig[];
extern int beat;
extern int counter;

/* Init the whole shit. Instruments etc. Call this first of all.
   freq=main frequency */
void syna_init(int freq);

#ifndef TINY
/* Loads a tune from a file. 0=OK, -1=error */
int syna_load(char *tune);
#endif

/* Gets a tune from memory */
int syna_get(void *tune);

/* Plays a fragment to destination */
void syna_play(short *dest,int len);
