;BITDRAW8 - The little (1bit->8bit) picture display in 2^8 Bytes
; Released for the Function 2005 party held in Budapest, Hungary!
; By: -=thE /P.A.P.+O./ (BraiN)KiLLeR=-
; [[other aliases: B_KiLLeR, KiLLeR, --> bkil <--, kil, k]]
; http://en.wikipedia.org/wiki/User:Bkil
; Killer gszi et net posta ditt net.
;
; ANONYMOUS PARTY VERSION IS _.com!
;
; INSPIRATION
; Carlos is possible by Carlos/Downtown ;-D
;
; GREETINGS
; robigszi, TomBucZman, "LamXtra :-) UnDeCoder", Carlos/Downtown
;
;History:
; 2004.06.14. 12:00+2H	start
; 2004.06.19. 19:30+2H	... working
; 2004.06.19. 21:30+1H	... symmetrical
; 2004.06.19. 22:30+1H	... double
;
; The source of the code is in NBASM 00.24.00 beta (free) Run make to make.
; http://www.frontiernet.net/~fys/newbasic.htm
;
.optof
.186
.model tiny
w	equ	3	; width in 8 rows
h	equ	64	; height in columns
c	equ	100	; color of "1" pixels
s	equ	(h*640)	; start
b	equ	(s-320)	; bottom
l	equ	(w*32)	; length*simm*zoom
d	equ	(640+l)	; decrement
.code
 org 100h
; ah=0; ch=0; bx=0
 mov al,13h
 int 10h
; les bp,[bx]	; this suxx! on wnt!
 push 0a000h
 pop es
 inc bx
 mov di,s
loop0
 mov si,(data-1)
loop1
 mov cl,w
loop2
 add si,bx
 mov dl,[si]
 stc
 rcl dl,1
proc
 salc
 rcr byte [si],1
 and al,c
 stosb
 stosb
 shl dl,1
 jnz proc
 loop loop2
 inc si
 neg bx
 js loop1
; add si,(w-2)
 inc si ; !! w=3 !!
 sub di,d
 ja loop1
 mov di,b
 jz loop0
 mov ah,7
 int 21h
 mov ax,3
 int 10h
 ret
data
.end
; example:
;	db 10101010b, 00100011b
;	db 11000010b, 00100011b
;	db 10101010b, 00100000b
;	db 10101011b, 10111011b
