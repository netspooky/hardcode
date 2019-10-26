org 100h
use16

mov al,13h
int 10h

mov bh,0A0h

mov di,bx
	push	cs
	pop es

	mov bp, 5F5h

gens:
	mov ax, dx
	sar ax, 0Bh
	sub bp, ax
	shl ax, 2
	sub bp, ax
	add dx, bp
	mov al, dh
	sar al,2
	add al,31
	stosb
	mov ax, bp
	sar ax, 9
	add al, dh
	sar al,2
	add al,31
	stosb
	inc bl
	jnz short gens

mov es,bx
 push 08000h
 pop ds
tlp3:
 xor di,di
 push cx
 push dx
 push si
tlp2:

 push cx;mov cx,si
 mov bl,cl
 mov al,[cs:bx]
 mov bl,ch
 add al,[cs:bx]
; mov ax,si
 and al,63
 mov [cs:huj],al

 mov cx,320
 xor bl,bl
 
 push dx
tlp1:
;red
 xor bp,bp
 mov al,[cs:bx]

 push bx
 mov bl,cl
 call swap
; mov ah,[cs:bx]
; cmp ah,al;ah>al?
; jb no_swap_r
; xchg ah,al
;no_swap_r:
 xor bp,bp
 cmp al,bl;[cs:huj]
 jb no_red
 cmp ah,bl;[cs:huj]
 jg no_red
put_red:
 or bp,4;+8
no_red:

;green
 mov bl,dl
 mov al,[cs:bx]
 mov bl,dh

 call swap
; mov ah,[cs:bx]
; cmp ah,al
; jb no_swap_g
; xchg ah,al
;no_swap_g:
 cmp al,bl;[cs:huj]
 jb no_g
 cmp ah,bl;[cs:huj]
 jg no_g
 or bp,2;+8
no_g:

;blue
 mov bl,cl
 mov al,[cs:bx]
 neg bl
 
 call swap
; mov ah,[cs:bx]
; cmp ah,al;ah>al?
; jb no_swap_b
; xchg ah,al
;no_swap_b:
 cmp al,bl;[cs:huj]
 jb no_b
 cmp ah,bl;[cs:huj]
 jg no_b
 or bp,1
no_b:

;-put value
; mov ax,bp
; stosb
mov al,[cs:bp+ctab]
mov [ds:di],al
inc di
 pop bx
 inc bl

 inc dl

 inc dh

 loop tlp1
 pop dx

 inc dl
 dec dh

 pop cx
 inc cl
 inc ch
 cmp di,64000
 jne tlp2
 
 mov dx, 3dah
@wait1:
in al, dx
test al, 8
jz @wait1

 xor si,si
 xor di,di
; mov cx,64000
 mov ch,0FAh
 rep movsb

 pop si
 pop dx
 pop cx
; inc cl
 add cl,2*2;inc cl
 add ch,3+4;dec ch
 
 in al,60h
 dec al
 jne tlp3
; ret
swap:
 mov ah,[cs:bx]
 cmp ah,al;ah>al?
 jb no_swap
 xchg ah,al
no_swap:
 mov bl,[cs:huj]
 ret
ctab:
 db 0
 db 1
 db 2
 db 3
 db 4
 db 5
 db 6+8
 db 7+8

huj:;db 0