segdata
global LANG SelOfs:dword
global LANG PSP:dword
ends
macro p2o reg,phyaddr
ifdif <&reg>,<&phyaddr>
                mov     &reg,&phyaddr
endif
ifndef __PMODEW
ifndef __DOS4G
                sub     &reg,[SelOfs]
endif
endif
endm
macro o2p reg,reg2
ifdif <&reg>,<&reg2>
                mov     &reg,&reg2
endif
ifndef __PMODEW
ifndef __DOS4G
                add     &reg,[SelOfs]
endif
endif
endm

global LANG LowToPtr:near   ; ushort,ushort -> void*
global LANG PtrToPhy:near   ; void* -> ulong

CFLAG EQU 1

struc REG386
  _edi     dd @0
  _esi     dd @0
  _ebp     dd @0
  null     dd @0
  _ebx     dd @0
  _edx     dd @0
  _ecx     dd @0
  _eax     dd @0
  flags    dw @0
  _es      dw @0
  _ds      dw @0
  _fs      dw @0
  _gs      dw @0
  _ip      dw @0
  _cs      dw @0
  _sp      dw @0
  _ss      dw @0
ends

segdata
global LANG Reg386:REG386
ends

segcode
global LANG ZeroReg386:near    ; void

global LANG Int386:near        ; int, REG386*
global LANG Int386X:near       ; int, REG386*

global LANG GetEnv:near        ; void -> void*

global LANG DosAlloc:near         ; tSize -> void*
global LANG DosFree:near          ; void*
global LANG DosReAlloc:near       ; void*, tSize -> void*

ends
