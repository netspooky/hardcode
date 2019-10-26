        NAME    c0
        PAGE    60,132
        LOCALS
;[]------------------------------------------------------------[]
;|      C0.ASM -- Start Up Code                                 |
;|                                                              |
;|      Turbo C++ Run Time Library                              |
;|                                                              |
;|      Copyright (c) 1987, 1991 by Borland International Inc.  |
;|      All Rights Reserved.                                    |
;[]------------------------------------------------------------[]

								__C0__ = 1
                                __TINY__ = 1
INCLUDE         C:\BORLANDC\LIB\STARTUP\RULES.ASI
dosseg
;       Segment and Group declarations

_TEXT           SEGMENT BYTE PUBLIC 'CODE'
                ENDS
_FARDATA        SEGMENT PARA PUBLIC 'FAR_DATA'
                ENDS
_FARBSS         SEGMENT PARA PUBLIC 'FAR_BSS'
                ENDS
IFNDEF __TINY__
_OVERLAY_       SEGMENT PARA PUBLIC 'OVRINFO'
		ENDS
_1STUB_ 	SEGMENT PARA PUBLIC 'STUBSEG'
		ENDS
ENDIF
_DATA           SEGMENT PARA PUBLIC 'DATA'
                ENDS
_INIT_          SEGMENT WORD PUBLIC 'INITDATA'
InitStart       label byte
                ENDS
_INITEND_       SEGMENT BYTE PUBLIC 'INITDATA'
InitEnd         label byte
                ENDS
_EXIT_          SEGMENT WORD PUBLIC 'EXITDATA'
ExitStart       label byte
                ENDS
_EXITEND_       SEGMENT BYTE PUBLIC 'EXITDATA'
ExitEnd         label byte
                ENDS
_CVTSEG         SEGMENT WORD PUBLIC 'DATA'
                ENDS
_SCNSEG         SEGMENT WORD PUBLIC 'DATA'
                ENDS
IFNDEF __HUGE__
  _BSS          SEGMENT WORD PUBLIC 'BSS'
                ENDS
  _BSSEND       SEGMENT BYTE PUBLIC 'BSSEND'
                ENDS
ENDIF
IFNDEF __TINY__
  _STACK        SEGMENT STACK 'STACK'
                ENDS
ENDIF

        ASSUME  CS:_TEXT, DS:DGROUP

;       External References

extrn           MAIN:DIST;_main:DIST
extrn		_exit:DIST
extrn		__exitbuf:DIST
extrn		__exitfopen:DIST
extrn		__exitopen:DIST
extrn		__setupio:near			;required!
extrn		__stklen:word
IF LDATA EQ false
extrn		__heaplen:word
ENDIF

        SUBTTL  Start Up Code
        PAGE
;/*                                                     */
;/*-----------------------------------------------------*/
;/*                                                     */
;/*     Start Up Code                                   */
;/*     -------------                                   */
;/*                                                     */
;/*-----------------------------------------------------*/
;/*                                                     */
PSPHigh         equ     00002h
PSPEnv          equ     0002ch
PSPCmd          equ     00080h

                public  __AHINCR
__AHINCR        equ     1000h
                public  __AHSHIFT
__AHSHIFT       equ     12

IFDEF	__NOFLOAT__
MINSTACK        equ     128     ; minimal stack size in words
ELSE
MINSTACK        equ     256     ; minimal stack size in words
ENDIF
;
;       At the start, DS and ES both point to the segment prefix.
;       SS points to the stack segment except in TINY model where
;       SS is equal to CS
;
_TEXT           SEGMENT
                ORG     100h
STARTX          PROC    NEAR
                mov     dx, cs;DGROUP      ; DX = GROUP Segment address
                mov     ds, dx
;;                mov oldss,ss
;;                mov oldsp,sp
                mov bx,0fffeh;;offset DGROUP:stack__end
                cli                     ; req'd for pre-1983 88/86s
                ;;mov dx,seg _STACK
                mov     ss, dx          ; Set the program stack
                mov     sp, bx;;offset DGROUP:stack__end-2
                sti
                call    MAIN;_main

;;                mov dx,oldss
;;                mov bx,oldsp
;;                cli
;;                mov ss,dx
;;                mov sp,bx
;;                sti
ExitToDOS       label   near
								mov     ax,4C00h
								int     21h                     ; Exit to DOS
STARTX          ENDP
;;oldss dw 0
;;oldsp dw 0


        SUBTTL  Vector save/restore & default Zero divide routines
        PAGE



; The DGROUP@ variable is used to reload DS with DGROUP

;PubSym@         DGROUP@, <dw    ?>, __PASCAL__

; __MMODEL is used to determine the memory model or the default
; pointer types at run time.

;                public __MMODEL
;__MMODEL        dw      MMODEL

_TEXT		ENDS

        	SUBTTL  Start Up Data Area
        	PAGE

_DATA		SEGMENT

;	Magic symbol used by the debug info to locate the data segment
		public DATASEG@
DATASEG@	label	byte


_DATA        	ENDS


_CVTSEG 	SEGMENT
PubSym@         _RealCvtVector, <label  word>,  __CDECL__
        	ENDS

_SCNSEG 	SEGMENT
PubSym@         _ScanTodVector,  <label word>,  __CDECL__
        	ENDS

_BSS		SEGMENT
bdata@          label   byte
		ENDS

_BSSEND		SEGMENT
edata@          label   byte
        	ENDS
;public stack__end
;_STACK          SEGMENT
;stack___           db      128 dup(?) ;;49152 dup(?)               ;minimum stack size
;stack__end         db ?
;                ENDS
        	END     STARTX
