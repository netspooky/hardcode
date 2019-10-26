;                    ILLUSORY WORLD
;       128-bytes intro by Agent Orange // tRX
;
;    Greets: CodeRipper, Dogar&Kazon, √≈AX, Solar Designer,
;            Street Raider, Tangerine, X.P.E.h.
;
 IDEAL
 XSize equ 26
 YSize equ 26
 Diff equ 0
model tiny
p386
CODEseg

org 100h

Intro128:
 mov al,13h
 int 10h
 push 0a000h
 pop es

;first loop -------------------------------------------------------------------
 mov dx,3c8h
 xor al,al
 out dx,al
 inc dx
 mov cl,128
 push cx
pal:
 mov al,cl
 neg al
 add al,40h
 jc black
 xor al,al
black:
 out dx,al
 mov al,cl
 dec ax
 test al,40h
 je notnot
 not al
notnot:
 out dx,al
 xor al,al
 out dx,al
 loop pal

;second loop ------------------------------------------------------------------
 pop cx
pal2:
 mov al,cl
 sub al,41h
 jnc black2
 xor al,al
black2:
 out dx,al
 xor ax,ax
 out dx,al
 mov al,cl
 dec ax
 test al,40h
 je notnot2
 not al
notnot2:
 out dx,al
 loop pal2

main:
; mov ax,[seed1]
 db 0B8h
Seed1 dw 0A000h
; mov bx,[seed2]
 db 0BBh
Seed2 dw 00001h
 add bx,ax
 mov [seed1],bx
 mov [seed2],ax
 xchg ah,bl

 mov di,bx
 mov cx,YSize
l2:
 push cx
 mov cx,XSize
l1:
 add [byte ptr es:di],1
 inc di
 loop l1
 add di,320-XSize+diff
 pop cx
 loop l2

 mov ah,1
 int 16h
 jz Main
;Exit ------------------------------------------------------------------------
 mov ax,3
 int 10h
 ret

;PROC Random
;ENDP Random
End Intro128


