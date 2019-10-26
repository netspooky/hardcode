USE16
CPU P4
;; vars
OFFSET_UMUL equ 0			;; [bx+OFFSET_UMUL] = (word)umul
OFFSET_OINVALIDX equ 6		;; [bx+OFFSET_OINVALIDX] = (word)oinvalidx
OFFSET_PHASE equ 8			;; [bx+OFFSET_PHASE] = (word)phase
OFFSET_POS equ 10			;; [bx+OFFSET_POS] = (word)pos
OFFSET_XY_XY equ 14			;; [bx+OFFSET_XY_XY] = (word)xy*xy
OFFSET_DAMP equ 16			;; [bx+OFFSET_DAMP] = (word)damp = xy*xy + yx+yx + 8
OFFSET_U equ 18				;; [bx+OFFSET_U] = (word)u
OFFSET_COSTINT equ 20		;; [bx+OFFSET_COSTINT] = (word)costint((205 * u * (2*yx+1))>>9)
OFFSET_OUTXY equ 22			;; [bx+OFFSET_OUTXY] = (word)xy*xymul
OFFSET_OUTU equ 24			;; [bx+OFFSET_OUTU] = (word)u*umul

org 100h
	
	mov al,13h
	int 10h

%ifndef NOPAL
	xor eax,eax
	mov dx,03c8h
	out dx,al
	inc dx 
	dec eax
pal:
	mov cl,4
outer:
	ror eax,2
	mov ch,3
inner:
	out dx,al
	ror eax,8
	dec ch
	jnz inner
	ror eax,6
	loop outer
	sub eax,0x04010204
	jnc pal
%endif
nopal:
	mov dx,0x7000			; source segment
	mov es,dx
	
	xor cx,cx
;; fill 160x160 area with with random signed shorts in the range [-128..127] beginning from es:[0] 
fill:	
	mov bx,dx
	shl dx,1
	add dx,bx
	xchg dl,dh

	movsx ax,dl
	stosw
	loop fill
	
	mov word [bx+OFFSET_UMUL],160
	mov word [bx+OFFSET_PHASE],cx
	
anim:
	push 0x7000
	pop fs
	push 0x8000
	pop es

	test byte [bx+OFFSET_UMUL],1
	jz no_rowsegments	

	push es
	pop fs
%ifndef RELEASE
	push 0x9000
%else
	push 0xA000 + 20*320/16
%endif

	pop es
	
	add byte [bx+OFFSET_PHASE],9
	jnc nopos
	inc byte [bx+OFFSET_POS]
nopos:
	
no_rowsegments:

	mov cx,159
	mov gs,cx
xyloop:
	push cx
	
	mov ax,cx
	mov si,[bx+OFFSET_UMUL]
	xor si,161
	imul si				    ;; ax=xy*xymul
	mov [bx+OFFSET_OUTXY],ax
	
	mov ax,cx
	add ax,word [bx+OFFSET_POS]			;; ax=xy+pos
	test byte[bx+OFFSET_UMUL],1			;; rowmode=umul&1
	jz col_o
	mov ax,cx
	imul si			;; ax=xy*DATA_WIDTH
	
col_o:
	mov [bx+OFFSET_OINVALIDX],ax	;; original inval idx
	
	imul cx,cx
	mov [bx+OFFSET_XY_XY],cx		;; xy*xy

	mov cx,gs	
uloop:
	push cx

	mov word [bx+OFFSET_U],cx
	
	mov ax,[bx+OFFSET_UMUL]
	imul cx
	mov [bx+OFFSET_OUTU],ax			;; ax=u*umul
	
	xor si,si						;; z=0
	mov cx,gs
yxloop:
	push cx

	mov ax,cx
	shl ax,1
	inc ax
	imul ax,word 205
	mov bp,word [bx+OFFSET_U]
	imul bp
	shrd ax,dx,9					;; ax=(u * (2*yx+1))>>9
	
	shl al,1						;; GO HOME DCT, YOU'RE DRUNK
	jnc skip						;; do you even cosine?
	not al							;; this cat forgot how to take the cosine of things
skip:
	add al, 128						;; bad approximation, bad
	cbw								;; ax ~= cos(2/5 * u * (2*yx+1) * pi) * 128
	
costint_push:
	push ax							;; pop at costint_pop
	
	mov di,[bx+OFFSET_UMUL]
	imul di,cx						;; di=yx*umul
	add di,[bx+OFFSET_OINVALIDX]	;; di=oinvalidx + yx*umul

%ifndef NOPAL
	mov bp,1
%else
	mov bp,16						;; damp=0
%endif
	
	shl di,1
	fs mov ax,word [di]
	test byte [bx+OFFSET_UMUL],1
	jnz nolerp
	
	fs sub ax,word [di+2]
	neg ax
	imul word [bx+OFFSET_PHASE]

	shrd ax,dx,8

	fs add ax,word[di]				;; ax=inval
	
	imul cx,cx
	add cx,[bx+OFFSET_XY_XY]
	add bp,cx						;; damp=xy*xy + yx*yx + 15
%ifndef NOPAL
	add bp,15
%endif
nolerp:

costint_pop:
	pop cx							;; push at costint_push
	imul cx							;; dx:ax = outval = inval * costint((205 * u * (2*yx+1))>>9)
	mov cx,bp
	cwd
	idiv cx							;; ax /= damp
	
	add si,ax
	
	pop cx
	loop yxloop
	
	mov ax,si
	sar ax,5

	test byte[bx+OFFSET_UMUL],1
	jz norowputpixel
%ifndef NOPAL	
	dec dx							;; dx is now 0xffff
	test ah,ah
	cmovnz ax,dx
	cmovs ax,cx						;; cx is now 0
%else
	sar ah,8
	or al,ah
%endif

%ifndef NOPAL
	not al
%endif
%ifdef MONO
	add al,17
	and al,31
%endif
	mov ah,al
norowputpixel:

	mov di,[bx+OFFSET_OUTXY]
	add di,[bx+OFFSET_OUTU]
	shl di,1

	stosw

	pop cx
	dec cx
	jns uloop

	pop cx
	dec cx
	jns xyloop
	
	xor byte [bx+OFFSET_UMUL],161	;; umul = umul ^ (DATA_WIDTH + 1)
%ifndef RELEASE
	jns anim						;; jump if umul != 160

	push 0x9000
	pop fs
	push 0xa000 + 20*320/16;
	pop es
	xor di,di
	xor si,si
	mov cx,160*320
	fs rep movsb
	
	in al,60h
	dec al
	jnz anim

	mov ax,03h
	int 10h

	ret
%else
	jmp anim
%endif
