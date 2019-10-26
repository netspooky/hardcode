p586

ifndef __16BIT__
@ax         EQU eax
@bx         EQU ebx
@cx         EQU ecx
@dx         EQU edx
@si         EQU esi
@di         EQU edi
@bp         EQU ebp
@sp         EQU esp
else
@ax         EQU ax
@bx         EQU bx
@cx         EQU cx
@dx         EQU dx
@si         EQU si
@di         EQU di
@bp         EQU bp
@sp         EQU sp
endif

ifdef  __LANG
LANG    EQU __LANG
else
LANG    EQU c
endif

s       EQU small
l       EQU large
sh      EQU short
b       EQU byte ptr
w       EQU word ptr
d       EQU dword ptr
o       EQU offset
f       EQU fword ptr
q       EQU qword ptr

ifndef __DEBUG
_s      EQU small
else
_s      EQU
endif

macro calls n
ifndef __DEBUG
        call    s &n
else
        call    &n
endif
endm

macro rets
ifndef __DEBUG
        db      66h
endif
        ret
endm
ifndef __DEBUG
_s      EQU small
else
_s      EQU
endif

NULL    EQU 0
DPMIDOS = 0
@0      EQU ?
ifdef __DOS4G
@0      EQU 0
DPMIDOS = 1
endif
ifdef __PMODEW
@0      EQU 0
DPMIDOS = 1
endif

ifdef __PMODE
OWNPMODE  EQU 1
endif
ifndef __RMODE__
ifdef __DOS
OWNPMODE  EQU 1
endif
endif

ifdef OWNPMODE
aliascode     EQU _text
aliasdata     EQU _text
segment PMODE_TEXT byte public use16 'CODE'
ends
macro segcode
segment _text byte public use32 'CODE'
assume cs:aliascode,ds:aliasdata,es:aliasdata
endm
macro segdata
segment _text byte public use32 'CODE'
endm
macro segconst
segment _text byte public use32 'CODE'
endm
else
ifdef __16BIT__
model large,c
aliascode     EQU @code
aliasdata     EQU @data
macro segcode
codeseg
assume cs:aliascode,ds:aliasdata,es:aliasdata
endm
macro segdata
dataseg
endm
macro segconst
const
endm
else
model flat,c
aliascode     EQU @code
aliasdata     EQU @data
macro segcode
segment _TEXT public use32 'CODE'
assume cs:aliascode,ds:aliasdata,es:aliasdata,ss:aliasdata
endm
macro segdata
segment _DATA public use32 'DATA'
endm
macro segconst
segment CONST2 public use32 'DATA'
endm
endif
endif

macro segstack i
segment _STACK para stack use32 'STACK'
group DGROUP _STACK
 db &i dup (@0)
ends
endm
; set segment order
segcode
ends
segconst
ends
segdata
ends

global LANG Main:near

macro DUMP a
                local @@Loop,@@Ok
                pushad
                mov     ebx,&a
                mov     ecx,8
@@Loop:         rol     ebx,4
                mov     ah,2
                mov     dl,bl
                and     dl,0fh
                add     dl,'0'
                cmp     dl,'9'
                jbe     @@Ok
                add     dl,'@'-'9'
@@Ok:           int     21h
                loop    @@Loop
                mov     ah,2
                mov     dl,' '
                int     21h
                popad
endm
