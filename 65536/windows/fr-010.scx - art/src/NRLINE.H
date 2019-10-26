#ifndef _NRLINE_H_
#define _NRLINE_H_

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#define _WIN32_WINNT 0x0400

#pragma warning (disable: 4035)

#include <windows.h>
#include <ddraw.h>
#include "TextureManager.h"
#include "rtlib2.h"

extern "C" double fabs(double a);

#pragma intrinsic (fabs)

void *__cdecl operator new(unsigned int size);
void __cdecl operator delete(void *p);

int __cdecl atexit(void (__cdecl *)());

extern "C"
{
int rand();
}

void ExitTheShit();
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);

extern int texcount;

extern LPDIRECTDRAW				    g_pDD;
extern LPDIRECTDRAWSURFACE		g_pDDSPrimary;
extern LPDIRECTDRAWSURFACE		g_pDDSBack;

extern BOOL							g_bActive;
extern TextureManager *texture;
extern int texnum;
extern int lPitch;


#endif //_NRLINE_H_