;	still todo:
;	- muzax + samples
;	  - resonator
;	- dezign effects
;	- starfield background

;	- new writer?

;	- speech synth

;	check if works
;	- sbdriver  [enhance with BLASTER checker]
;	- ifs

;;; palette data interpreter

;set_regular_palette:




set_palette:

	mov di,palette_temp
	xor ax,ax
	mov cx,768
	rep stosw

.l2	mov cl,[si]
	mov ch,0
	jcxz .o0

.l1	mov bx,3

.l0	mov al,[di-3]
	add al,[si+bx]
	stosb
	dec bx
	jne .l0
	loop .l1
	add si,4
	jmp .l2
.o0	ret

blit_it:

	; ds=image

	push word 0xa000
	pop es
	
	xor esi,esi
	xor edi,edi
	xor ecx,ecx

	mov si,28*256
	mov cx,199
	mov di,32
.l0	push cx
	mov cx,64
	rep movsd
	pop cx
	add di,320-256
	loop .l0

	ret

;;; unused

;calc_bumplights:
;
;        xor cx,cx
;        xor di,di
;
;        .l0:
;        mov al,cl
;        cbw
;        imul al
;        mov bx,ax
;        mov al,ch
;        cbw
;        imul al
;        add bx,ax
;        rcr bx,1
;        inc bx
;        call sqrt
;        mov ax,64
;        sub ax,bp
;        jnc .p0
;                mov al,0
;        .p0:
;        stosb
;        loop .l0
;
;        ret

;;; texture routines

;texture_smooth:  ;ds
;
;        mov cx,255*256
;        xor si,si
;.l0     lodsb
;        add al,[si]
;        rcr al,1
;        add al,[si+256]
;        rcr al,1
;        mov [si-1],al
;        loop .l0
;        ret

;texture_bumpen:  ;ds
;
;        mov cx,65535
;        xor si,si
;.l0     lodsb
;        sub al,[si]
;        sar al,1
;        mov [si-1],al
;        loop .l0
;        ret

calc_texture:

	xor cx,cx
	xor di,di

.l0	mov dx,cx
	add dl,dh
	shl dx,1
	sub dx,cx

	mov al,dh
	imul dh
	mov bx,ax
	mov al,dl
	imul dl
	add bx,ax
	call sqrt

	mov ax,bp
	xor al,dl
	cbw
	xor al,ah
	inc ax
	stosb

	loop .l0

	ret

;calc_texture_1:
;
;        ; es=output_segment
;
;        push es
;        pop ds
;
;        xor cx,cx
;        xor di,di
;        mov si,0xff01
;        mov dx,si
;
;.l0     mov ax,cx
;        add ax,dx
;        and al,ah
;        xor dx,cx
;        and bh,31
;
;        cbw
;        xor al,ah
;        stosb
;
;        loop .l0
;        ret


;;; precalcs

calc_sin_table:

	push cs
	pop es
	mov cx,256+256
	xor si,si
	mov bx,32767
	mov di,sin_table
.l0	mov ax,si
	stosw
	call roto2d
	loop .l0
	ret

calc_random_table:

.l0:	sub ax,cx
	xor ah,al
	ror ax,3
	stosw
	loop .l0

;;; realcalcs

sqrt:			; fixed point sqrt  bp=sqrt(bx)
	push cx
	mov cx,7	; # of iterations
	mov bp,1
.l0:	mov ax,bx
	push dx
	cwd
	
	test bp,bp
	je .l1
	
	div bp
.l1	pop dx
	add bp,ax
	sar bp,1
	loop .l0
	pop cx
	ret

