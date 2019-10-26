#ifndef __ADDITION_H_
#define __ADDITION_H_

#include <stdio.h>
#include <windows.h>

typedef struct {
  int length;
  int pos;
  unsigned char *data;
} MEMFILE;

#ifdef _DEBUG
void ShowErrorCode(DWORD error);
void ShowLastError ();
#endif

unsigned int memopen(char *name);
void memclose(unsigned int handle);
int memread(void *buffer, int size, unsigned int handle);
void memseek(unsigned int handle, int pos, signed char mode);
int memtell(unsigned int handle);
#endif