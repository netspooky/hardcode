#ifndef __CONFIG_H
#define __CONFIG_H

#ifdef _WIN32
#define WAVEOUT /* use windows waveOut in drv_dsp */
#else
#define LINUX /* assume linux if not on _WIN32 */
#endif

#define LOOP 1

/* #define HAVE_ULTRASOUND_H */

/*   don't play with these :D */
/*  #define AMIGAPERIODS 1 */
/*  #define EIGHTBITS 1 */
/* #define THREADS */
#define VERBOSE -1

#endif /* __CONFIG_H */
