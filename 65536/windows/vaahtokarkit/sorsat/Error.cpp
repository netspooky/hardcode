#include "Error.h"
#include "Video.h"
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

void error(char *f,...)
{
  va_list args;
  va_start(args,f);
  videoDeinit();
  printf("Error: ");
  vprintf(f,args);
  printf("\n");
  exit(255);
}
/*
void warning(char *f,...)
{
  va_list args;
  va_start(args,f);
  printf("Warning: ");
  vprintf(f,args);
  printf("\n");
}
*/