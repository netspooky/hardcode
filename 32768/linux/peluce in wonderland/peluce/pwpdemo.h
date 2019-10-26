#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <malloc.h>

#include "../pwplib/pwplib.h"

#define SIN(a) (sin((a)*3.1415926/128)*32767)
#define COS(a) ((3.1415926/2)+(cos((a)*3.1415926/128))*32767)

#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))
