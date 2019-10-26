#include "pwplib.h"

#ifndef __TTY_C
  extern
#endif
struct
{
  int fd;
  int width; int height;

  int type,minor;
  long int vtcap;

  int att,cx,cy; /* getridoff */

  u8*prevbuf;

#ifdef __POSIX__
  struct termios setup;
#endif

  int maxframedata;
  int framedelay;
}pwp_tty;

/* major types */
enum
{
  TTY_DUMB=0,

  TTY_XVT_MONO,
  TTY_XVT_COLOR,

  TTY_VT_COLOR_IBM,
  TTY_VT_COLOR,
  TTY_VT1XX,         /* vt100, vt102 etc */

  TTY_ANSISYS,       /* ansi, ansi-bbs etc */
  TTY_LINUX,         /* linux */
 
  TTY_VT2XX          /* vtnnn where nnn>=200 */
};
