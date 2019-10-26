/*
 * 
 * TinyPTC x11 v0.4 ported by Alessandro Gatti (a.gatti@tiscalinet.it)
 * Original Windows version by Glenn Fiedler (ptc@gaffer.org)
 * http://www.gaffer.org/tinyptc
 *
 * 0.4_8bit - 2000/09/25 by Kuno Woudt aka Warp <warp-tmt@dds.nl>
 * - mutilated tinyPTC to use 8bit palettized modes, 
 *   also available: TinyPTC-Windows-0.6_8bit :)
 *
 */

#ifndef __TINY_PTC_X11
#define __TINY_PTC_X11

typedef unsigned int int32;
typedef unsigned short int16;
typedef unsigned short short16;
typedef unsigned char char8;

extern int ptc_open(char *title, int width, int height);
extern int ptc_update(void *buffer);
extern int ptc_setpal(unsigned char *palette);
extern void ptc_close();
int ptc_process_events(void);

#define __PTC_XSHM__
#define __PTC_ENABLE_CONVERSIONS__
#define __PTC_BEST_VIDEOMODE__
/*
#define __PTC_WINDOWED__ 
#define __PTC_LITTLE_ENDIAN__ 
*/

#endif /* __TINY_PTC_X11 */
