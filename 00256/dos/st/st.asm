org 100h
section .text
	mov ax,13h
	int 10h

	xor ax,ax
	mov dx,3c8h
	out dx,al
	inc dx
	xor cx,cx
	xor bx,bx
pal1:
	mov bl,1					; red slope
	call palset
	mov bl,2					; green slope
	call palset
	mov bl,3					; blue slope
	call palset
	inc bh
	jnz pal1
	
	push 0xa000
	pop es

gen_vetices:
	mov cx,(n+1)*2*4
	mov si,30
	mov di,s
gen_vertices_loop:
	call rand
	test di,3
	jnz skipmask
	and bl, 80h
	or bl, 3eh
skipmask:
	mov [di],bl
	inc di
	loop gen_vertices_loop
	
;	mov word[w],cx				; not really needed (w ~= 0 is good enough)
	mov word[w+2],cx
clearloop:
	salc
	dec cx
	rep stosb
	
drawloop:
	call rand
	
	and bx,(n-1)<<3				; p=random(n),bx=p*8
	add bx,s
	mov bp,x
	fld dword [bx]				; st0=px=xs[p]
	fld dword [bp+x-x]				; st0=x, st1=px
	fsubp st1,st0				; st0=x-px
	fmul st0,st0				; st0=(x-px)^2
	fld dword [bx+4]			; st0=py=ys[p], st1=(x-px)^2
	fld dword [bp+y-x]				; st0=y, st1=py=ys[p], st2=(x-px)^2
	fsubp st1,st0				; st0=y-py, st1=(x-px)^2
	fmul st0,st0				; st0=(y-py)^2, st1=(x-px)^2
	faddp st1,st0				; st0=(x-px)^2+(y-py)^2)
	fsqrt						; st0 = sqrt((x-px)^2+(y-py)^2)
	fsin						; st0 = sin(sqrt((x-px)^2+(y-py)^2))
	fadd dword [bp+w-x]				; st0 = d = sin(sqrt((x-px)^2+(y-py)^2)) + w
	
	fld dword[bx]				; st0 = px, st1 = d
	fadd dword[bp+x-x]				; st0 = px+x, st1 = d
	fmul st0,st1				; st0 = (px+x)*d, st1=d
	fst dword [bp+x-x]
	fmul dword[half]			; st0 = (px+x)*d*.5, st1=d
	fadd dword[half]			; st0 = (px+x)*d*.5+.5, st1=d
	fimul word [screen_width]	; st0 = ((px+x)*d*.5+.5)*320, st1=d
	fistp word [screen_x]		; st0 = d
	
	fld dword[bx+4]				; st0 = py, st1 = d
	fadd dword[bp+y-x]				; st0 = py+y, st1 = d
	fmulp st1,st0				; st0 = (py+y)*d
	fst dword[bp+y-x]
	fmul dword[half]			; st0 = (py+y)*d*.5
	fadd dword[half]			; st0 = (py+y)*d*.5+.5
	fimul word [screen_height]	; st0 = ((py+y)*d*.5+.5)*200
	fistp word [bp+screen_y-x]		; ---

	mov di,word [bp+screen_y-x]
	imul di,di,320
	add di,word[bp+screen_x-x]
	es inc byte [di]
	jnz nodec
	es sub byte [di],120
nodec:
	in al,60h
	dec al
	jz exit
;	dec al						; uncomment for skip to next set of vertices
;	jz gen_vetices
	
	loop drawloop
	
drawend:
	fld dword[w]				; st0=w
	fadd dword[wstep]			; st0=w+wstep
	fstp dword[w]				; ---
	
	;; if (w>1.28) { goto gen_vertices; }
	dec si
	jz gen_vetices

	jmp drawloop

exit:
	mov ax,3h
	int 10h
	
palset:
	add ah,bl
	salc
	or al,ah
	mov ah,al
	shr al,2
	out dx,al
	
	xchg ah,ch
	xchg cl,ch
	ret
	
rand:
	mov bx,dx
	shl bx,1
	add dx,bx
	xchg dl,dh
	ret
	
	screen_width: dw 320
	screen_height: dw 200
	half: dd 0.5
	 db 3ch
wstep equ half+1
;	wstep: dd 0.01
	

section .bss align=16
	n equ 8
	dummy:
		resb 1
	s:
		resd n*2
	x:
		resd 1
	y:
		resd 1
	w:
		resd 1
	screen_x:
		resw 1
	screen_y:
		resw 1
	cnt:
		resb 1