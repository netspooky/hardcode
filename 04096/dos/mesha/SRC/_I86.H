#ifndef __I86_H
#define __I86_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __DPMI__
extern ulong SelOfs;
extern void* PSP;
#endif

void* GetEnv();

/* Special memory managment */
void* LowToPtr( ushort seg, ushort ofs );
ulong PtrToPhy( void* );

struct REG386w {
  ushort di,edi,si,esi,bp,ebp,null,enull,bx,ebx,dx,edx,cx,ecx,ax,eax,flags;
};
struct REG386wx {
  ushort di,edi,si,esi,bp,ebp,null,enull,bx,ebx,dx,edx,cx,ecx,ax,eax,flags,es,ds,fs,gs,ip,cs,sp,ss;
};
struct REG386b {
  ulong edi,esi,ebp,enull;
  uchar bl,bh,ebl,ebh,dl,dh,edl,edh,cl,ch,ecl,ech,al,ah,eal,eah;
};
struct REG386d {
  ulong di,si,bp,null,bx,dx,cx,ax;
};
union REG386 {
  struct REG386b b;
  struct REG386w w;
  struct REG386d d;
};
union REG386S {
  struct REG386b b;
  struct REG386wx w;
  struct REG386d d;
};

extern union REG386S Reg386;          /* default register pack for ints */
void ZeroReg386();

void Int386( int No, union REG386* );
void Int386X( int No, union REG386S* );

void *DosAlloc( tSize );
void DosFree( void* );
void *DosReAlloc( void*, tSize );

#ifdef __WATCOMC__
#pragma aux (GetPSP,AuxASM)
#pragma aux (GetEnv,AuxASM)
#pragma aux (PtrToPhy,AuxASM)
#pragma aux (LowToPtr,AuxASM)
#pragma aux (ZeroReg386,AuxASM)
#pragma aux (Int386,AuxASM)
#pragma aux (Int386X,AuxASM)
#pragma aux (DosAlloc,AuxASM)
#pragma aux (DosFree,AuxASM)
#pragma aux (DosReAlloc,AuxASM)
#endif

#ifdef __cplusplus
}
#endif

#endif
