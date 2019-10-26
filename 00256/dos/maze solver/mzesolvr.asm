; xorlissj.asm - 2016.10.23 - ern0@linkbroker.hu
; Maze Solver
; 256 byte intro for MS-DOS (compiler: fasm)
; Released at Function 2017 sceneparty
;
; Not the best 256b intro yet, but it was still
; fun to coding something for 8086


	org 100H
;----------------------------------------------------------------------
; draw maze

	mov ax,13H
	int 10H

	mov si,100H
	mov bl,7
	mov ah,0eH

.xbyte:
	mov dl,[si]
	mov cl,8
.xbit:
	mov al,'/'
	shr dl,1
	jc .print
	mov al,'\'

.print:
	int 10H
	loop .xbit

	inc si
	cmp si,(24*40 + 39)/8+100H
	jne .xbyte

;----------------------------------------------------------------------
; Info
;
; There're some words on how the path selection works.
; The coordinate system is rotated by 45˚
;
;     left    up
;         \  /
;         (X)
;        /  \
;    down   right
;
; The next position of a dot is based on collision
; checking. The prg checks the four possible
; directions, stops on first success attempt:
; - attempt 1: keep the actual direction,
; - attempt 2-3: turn +/- 90˚ (relative right/left),
; - attempt 4: turn 180˚ (turn back).

;----------------------------------------------------------------------
; Constants

; Offsets for checking collision (base is the upper
; left corner of the 2x2 dot)
;
CUP	equ -320*1 +3
CDN	equ +320*3 -1
CLT 	equ -320*1 -1
CRT	equ +320*3 +3

; Values for directions
;
DUP	equ -320 +1
DDN	equ +320 -1
DLT	equ -320 -1
DRT	equ +320 +1

; Field offsets
;
COLL	equ 0
DIR	equ (2 + COLL)
TAB	equ (2 + DIR)
ITEMLEN	equ (2 + TAB)

; Table index offsets for attempts
;
AT1	equ (0 * ITEMLEN)
AT2	equ (1 * ITEMLEN)
AT3	equ (3 * ITEMLEN)
AT4	equ (6 * ITEMLEN)

;----------------------------------------------------------------------
; Preparing

	mov ax,0a000H
	lea di,[snakedata]
	mov ch,3
	rep stosw
	mov es,ax

nextround:
;----------------------------------------------------------------------
; Choose direction
;
; BP: Current dot position (screen offset)
; BX: Starts as pointer to current t_lt/t_up/t_rt/t_dn
;     increased by AT1/AT2/AT3/AT4 on attempts
;     [COLL+BX] points to a collision offset (CLT, ...)
;     [DIR+BX] points to a direction offset (DRT, ...)
; DI: Used for accessing the screen (with ES)

	mov bp,[dotposition]
	mov bx,[dottableptr]

	mov di,[COLL + bx]
	add di,bp
	cmp byte [es:di],0
	jz .found

	add bx,(AT2 - AT1)

	mov di,[COLL + bx]
	add di,bp
	cmp byte [es:di],0
	jz .found

	add bx,(AT3 - AT2)

	mov di,[COLL + bx]
	add di,bp
	cmp byte [es:di],0
	jz .found

	add bx,(AT4 - AT3)

.found:
	; store new table position
	mov di,[TAB + bx]
	mov [dottableptr],di

	; calc new position
	mov di,[dotposition]
	add di,[DIR + bx]
	mov [dotposition],di

	mov bx,[snakeptr]
	mov [bx + snakedata],di
	inc bx
	inc bx
	mov bh,0
	mov [snakeptr],bx

	mov al,bl
	shr al,2
	add al,20H
	call plot

	add bl,2
	mov bh,0
	mov di,[bx + snakedata]
	mov al,0
	call plot

;----------------------------------------------------------------------
	mov cl,2
vb:
	mov dx,3daH
	in al,dx
	test al,8
	jz vb
wb:
	in al,dx
	test al,8
	jnz wb

	loop vb

	in al,60H
	cmp al,1
	jne nextround
qapp:
	retn
;----------------------------------------------------------------------
; Plot

plot:
	mov ah,al
	mov cl,3

.xpixlin:
	stosw
	stosb
	add di,320-3
	loop .xpixlin

	retn
;----------------------------------------------------------------------
; Tables for collision check and path selection
; Usage: check elems at index 0, 1, 3, 6
; (see ATx constants)
;
;	                     left  up right down
t_lt: dw CLT,DLT,t_lt  ;    X
t_up: dw CUP,DUP,t_up  ;    X    X
t_rt: dw CRT,DRT,t_rt  ;    -    X    X
t_dn: dw CDN,DDN,t_dn  ;    X    -    X    X
      dw CLT,DLT,t_lt  ;    -    X    -    X
      dw CUP,DUP,t_up  ;    -    -    X    -
      dw CRT,DRT,t_rt  ;    X    -    -    X
      dw CDN,DDN,t_dn  ;         X    -    -
      dw CLT,DLT,t_lt  ;              X    -
      dw CUP,DUP,t_up  ;                   X
;----------------------------------------------------------------------
; Dot data

dottableptr:
	dw t_up

snakeptr:
	dw snakedata

dotposition:
	dw 320*   196 + 132

snakedata:
