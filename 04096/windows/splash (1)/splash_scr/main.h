#ifndef _MAIN_H_
#define _MAIN_H_

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
//#include <mmsystem.h>

#define bool int
typedef char			i8;
typedef unsigned char	u8;
typedef short			i16;
typedef unsigned short	u16;
typedef int				i32;
typedef unsigned int	u32;
typedef float			f32;
typedef double			f64;

extern void updateWindowsMessages(void);
extern bool demoFinished;


extern u32 findNextPower2(u32 num);
extern unsigned int __cdecl strlen(const char *str);
extern void* __cdecl ALLOC(unsigned int cb);
extern void __cdecl DEALLOC(void* pv);
extern int __cdecl rand(void);
extern float __cdecl cosf(float ang);
extern float __cdecl sinf(float ang);
extern int __cdecl abs(int n);
//extern void * __cdecl memcpy(void *src,const void *dst,unsigned int size);
//extern void * __cdecl memset(void *src,int data,unsigned int sizey);

static void * __cdecl memset(void *src,int data,unsigned int sizey)
{
/*	__asm
	{
		mov eax,dword ptr[data]
		mov edi,dword ptr[src]
		mov ecx,dword ptr[sizey]
		rep stosb
	}*/
	int i=0;
	char *p=(char*)src;
	while (i<sizey)
		p[i++]=data;
	return NULL;
}

static void * __cdecl memcpy(void *src,void *dst,unsigned int size)
{
	int i=0;
	char *p=(char*)src;
	char *pd=(char*)dst;
	while (i<size)
		p[i++]=pd[i++];
	return NULL;
}
static float __cdecl sinf(float ang)
{
	__asm
	{
		FLD [ang]
		FSIN
	}
}
static float __cdecl cosf(float ang)
{
	__asm
	{
		FLD [ang]
		FCOS
	}
}
static short seed=0x3749;
static int __cdecl rand(void)
{
	__asm
	{
			mov ax,[seed]
			mov dx,0x8405
			mul dx
			inc ax
			mov [seed],ax
	}
	return seed;
}
static void* __cdecl ALLOC(unsigned int cb)
{
	return HeapAlloc(GetProcessHeap(),0,cb);
}
static void __cdecl DEALLOC(void* pv)
{
	if(pv)
		HeapFree(GetProcessHeap(),0,pv);
}
static unsigned int __cdecl strlen(const char *str)
{
	unsigned int i=0;
	while (str[i]!=0)
		i++;
	return i;
}
static u32 findNextPower2(u32 num)
{
	u32 highest=0;
	u32 count=0;
	u32 i=1;
	while (count<31)
	{
		if (num&i) highest=i+i;
		i+=i;
		count++;
	}
	return highest;
}
static int __cdecl abs(int n)
{
	if (n<0) n*=-1;
	return n;
}
//extern "C" int _cdecl _ftol(float num);
//extern int _cdecl _purecall(void);
#endif