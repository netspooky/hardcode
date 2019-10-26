org 100h ; forgetting the h might cost you a few hours

%define ding_1
%define dirty

	mov al, 13h
	int 10h

	
	push 0a000h
	pop es
	
	mov bp, 80h
	xor di, di
	mov dx, 200
vertloop:
	mov cx, 320
horzloop:
	mov ax, cx    ; x
	;sub ax, 160
	add ax, 65536 - 160
	mov [bp+2], ax
	fild word[bp+2]
	fmul st0, st0

	mov ax, dx    ; y
	;sub ax, 100
	add ax, 65536 - 100
	mov [bp+4], ax
	fild word[bp+4]
	fmul st0, st0
	fadd
	fsqrt    ; dist
	
	;fimul word[tbla]
	;hier
	fimul word[tbla]
	;fimul word[bp+2]
	
	; 0x80 heeft dist
	; 0x82 heeft x
	; 0x84 heeft y
	
	; /////////////
	fild word[bp+2]
	fild word[bp+4]
	fpatan
	fimul word[t128]
	fadd
	; /////////////
	
	fistp word[bp]
	
	mov ax, [bp]
	shl ax, 1
	stosb
	loop horzloop
	dec dx
	jnz vertloop
;	jmp skipretrace
	
mainloop:
	mov dx, 3dah ; Load the port
h1:
    in al, dx    ; Input a byte
    and al, 08h  ; 'And' it with a set bit 4.
    jz h1       ; Continue looping while bit 4 = 0 (i.e. in retrace)
h2:
    in al, dx    ; Input a byte.
    and al, 08h  ; 'And' it with a set bit 4.
    jnz h2        ; Continue looping while bit 4 = 1 (i.e. not in retrace)



	
skipretrace:	
	;add bx, 2
	;inc bx
	;dec bx
%ifdef ding_1
	inc bx
%endif
%ifdef ding_2
	inc bx
%endif
%ifdef ding_3
	inc bx
%endif
	
	
	mov dx, 3c8h
	;mov al, 0
	xor ax, ax
	;mov cx, 256		
	mov ch, 1
	out dx, al
	inc dx
palloop:
	
%ifdef ding_1
	mov ax, cx
	shr ax, 2
	add ax, bx
	out dx, al
	neg ax
	out dx, al
	add ax, bx
	add ax, bx
	out dx, al
%endif

%ifdef ding_2
	mov ax, cx
	shr ax, 2
	add ax, bx
	out dx, al
	;neg ax
	add ax, bx
	inc ax
	;dec ax
	out dx, al
	inc ax
	add ax, bx
	
	;add ax, bx
	out dx, al
%endif

%ifdef ding_3
	mov ax, cx
	shr ax, 2
	add ax, bx
	out dx, al
	;neg ax
	add ax, bx
	;inc ax
	add ax, 4
	;dec ax
	out dx, al
	;inc ax
	;add ax, bx
	neg ax
	;add ax, bx
	out dx, al
%endif


	loop palloop
skippal:


	
	;jmp mainloop
	; done = 11 bytes
%ifdef dirty	
	ja mainloop
%else	
	mov ah, 1
	int 16h
	jz mainloop
	mov ax, 3
	int 10h
	ret
%endif
	;jg mainloop
	
;	jmp mainloop
	
t128 dw 20
tbla dw 3
;opzij dw 160
;richting dw sidespeed







	