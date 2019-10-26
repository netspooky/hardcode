org 100h

use16

mov al,13h
int 10h


;palette
genp:
	mov dx,03c8h
	mov al,bl
	out dx,al
	inc dx
	mov al,bl
	sar al,1
	test al,64
	jle no_inv
	xor al,255
no_inv:
	and al,63
	mov ah,al

;	cmp bl,128
;	jc noc
	xor al,al
noc:
	out dx,al

	mov al,ah
	out dx,al
	out dx,al
	inc bl
	jne genp
;

;push 0a000h
;pop es

lp2:
	mov ax,cs
	mov ds,ax
	add ah,10h
	mov es,ax
	
	xor di,di
lp3:
lp:
	mov si,dots
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; move dots
;       mov si,dots
;md:
;       mov ax,[cs:si]
;       mov cx,[cs:si+2]
;       mov bx,[cs:si+4]
;
;       movsx dx,bl
;       add ax,dx
;       cmp ax,320
;       je chx
;       or ax,ax
;       jne tsty
;chx: neg bl
;tsty:
;       movsx dx,bh
;       add cx,dx
;       cmp cx,200
;       je chy
;       or cx,cx
;       jne tstx
;chy: neg bh
;tstx:
;       mov [cs:si],ax
;       mov [cs:si+2],cx
;       mov [cs:si+4],bx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call calc
	push ax
	call calc
	push ax
	call calc
	pop bx
	add al,bl
	pop dx
	add al,dl

	stosb
	or di,di
	jne lp

; move dots
	mov si,dots
md:
	mov ax,[cs:si]
	mov cx,[cs:si+2]
	mov bx,[cs:si+4]

	movsx dx,bl
	add ax,dx
	cmp ax,320
	je chx
	or ax,ax
	jne tsty
chx: neg bl
tsty:
	movsx dx,bh
	add cx,dx
	cmp cx,200
	je chy
	or cx,cx
	jne tstx
chy: neg bh
tstx:
	mov [cs:si],ax
	mov [cs:si+2],cx
	mov [cs:si+4],bx
	add si,6
	cmp si,endd
    jne md;lp


	push es
	pop ds

	push 0a000h
	pop es

	       mov     dx, 3DAh
waitvr:
	       in      al, dx
	       test    al, 8
	       jnz     short waitvr
loc_448:
	       in      al, dx
	       and     al, 8
	       jz      short loc_448
;
	xor di,di
	xor si,si
	mov cx,64000
	rep movsb
;;;;;;;;;;;;;;;;;;;;;;;;;;
	in al,60h
	dec al
	jne lp2
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;calc data
calc:
;Y^2/(x^2+Y^2)
	mov ax,di
	cdq
	mov bx,320
	div bx;dx=X,ax=Y
	sub dx,word[cs:si];160
	mov word [bp],dx;X

;       mov cx,dx;Y

	sub ax,word[cs:si+2];100
	mov word [bp+2],ax;Y

	fild word [bp];X
	fmul st0,st0;X^2
	fild word [bp+2];Y
	fmul st0,st0;Y^2
	fadd st1,st0
	fdiv st0,st1
	fimul word [cs:shnyaga]
	fistp word [bp]

	mov al,[bp]
	add si,6
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;
shnyaga: dw 255
;;;
dots:
	dw 160,100,0404h
	dw 160,100,0FEFEh
	dw 80,40,04FCh
endd:
