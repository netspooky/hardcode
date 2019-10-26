#include "main.h"

extern const int _fltused = 1;
extern const int _chkstk = 0;

extern int _cdecl _purecall(void)
{
	return 1;
}

extern int __cdecl _ftol(float num)
{
	static int tmp;
	__asm
	{
		mov eax,num
		mov tmp,eax
		fistp tmp
	}
	return tmp;
}











//static void __cdecl srand(unsigned int seed)
//{
//}



/*
static void* __cdecl operator new(unsigned int cb)
{
	return HeapAlloc(GetProcessHeap(),0,cb);
}

static void* __cdecl operator new [] (unsigned int cb)
{
	return HeapAlloc(GetProcessHeap(),0,cb);
}

static void __cdecl operator delete(void* pv)
{
	if(pv)
		HeapFree(GetProcessHeap(),0,pv);
}

static void __cdecl operator delete[](void* pv)
{
	if(pv)
		HeapFree(GetProcessHeap(),0,pv);
}*/

//extern "C" int _cdecl _purecall(void);

bool demoFinished=0;

void updateWindowsMessages(void)
{
}	




/*
  int __cdecl atexit(void (__cdecl *)())
  {
  return 0;
  }
  */
