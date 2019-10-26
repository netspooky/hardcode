#include "pwplib.h"
#define USE_SINTAB

#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))

#ifndef USE_SINTAB
#define SIN(a) (sin((a)*3.1415926/128)*32767)
#define COS(a) ((3.1415926/2)+(cos((a)*3.1415926/128))*32767)
#else
#ifndef HAS_SINTAB
extern signed int sintab16[];
#endif
#define SIN(a) sintab16[(a)&255]
#define COS(a) sintab16[((a)+64)&255]
#endif

