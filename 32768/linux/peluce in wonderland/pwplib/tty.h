#include "pwplib.h"

#ifndef __TTY_C
  extern
#endif
struct
{
  int fd;
  int width,height;

  int att,cx,cy; /* getridoff? */

  char*prevbuf;
}pwp_tty;
