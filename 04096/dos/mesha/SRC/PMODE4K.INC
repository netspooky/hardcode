MACRO MProtMain
ENDM
MACRO MRealInit
ENDM
MACRO MRealProcedures
ENDM

CONST_TIMER     EQU     (1193180/100)

STRUC tPMode
  GDT           dw 18h
                dd o tPMode + 8
                dw 0
  Null          dq 0
  Code32        db 0FFh,0FFh,0,0,0,9Ah,0CFh,0      ;Code32 offset Code32
  Data32        db 0FFh,0FFh,0,0,0,92h,0CFh,0      ;Data32 offset Code32
  Screen        dd ?
  IntMask       dw ?
  IntSave       dd 2 dup (?)
ENDS

segcode
GLOBAL C SelData:DWORD
GLOBAL C Int_Timer:NEAR
GLOBAL C PMode_Data:tPMode
GLOBAL C RealSwitch:DWORD
GLOBAL C stPleaseWait:BYTE
GLOBAL C Code16Seg:WORD
ends

GLOBAL C XMS_Exit:NEAR

Sel_Code32      equ            08h
Sel_Data32      equ            10h

MACRO PMODE_DATA
PMode_Data      tPMode <18h,o PMode_Data+8>   ;* must be the last static variable
RealSwitch      dd ?
ENDM

ifdef __DEBUG
global C BaseMem:dword
endif
