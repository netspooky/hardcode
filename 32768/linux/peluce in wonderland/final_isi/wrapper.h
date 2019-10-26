#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#include "../pwplib/pwplib.h"

#define sqrt sqrt__
#define cprintf printf

#define DEBUG(a) fprintf(stderr,a "\n")

#define taimeri get_timerval()

/*extern inline int dummy(){}*/

/* taimeri => gettimer(); */

typedef unsigned char uchar;
typedef signed int sint;
#define uint unsigned int
typedef signed char schar;

/**/
