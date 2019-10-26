
// you didn't really think that you would get this, did you?

#include "types.h"
#include "soundsys.h"

#define WIN32_LEAN_AND_MEAN
#include "windows.h"

static LARGE_INTEGER starttime;
static LARGE_INTEGER freq;


void __stdcall ssInit(sU8 *data, void *hWnd) {}
void __stdcall ssClose() {}
void __stdcall ssStop() {}
void __stdcall ssFadeOut(sU32 time) {};
void __stdcall ssDoTick() {};


void __stdcall ssPlay()
{
  QueryPerformanceFrequency(&freq);
  freq.LowPart/=TIMER_TICKS_PER_SEC;
  QueryPerformanceCounter(&starttime);
}

sS32 __stdcall ssGetTime() 
{
  LARGE_INTEGER time;
	sS32 rv;
  QueryPerformanceCounter(&time);
  
  __asm {
    mov eax, dword ptr [time]
    sub eax, dword ptr [starttime]
    mov edx, dword ptr [time+4]
    sbb edx, dword ptr [starttime+4]
    mov ebx, dword ptr [freq]
    div ebx
		mov [rv], eax
  }
	return rv;
}
