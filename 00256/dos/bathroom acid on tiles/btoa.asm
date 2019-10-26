;Bathroom Tiles on Acid
; by musk at qbparty 2016

org 100h

	mov al,13h
	int 10h
	
main:
	push 04000h
	pop es;
	;push 05000h
	;pop ds;
	
	push dx
		mov dx, 3c8h
        xor ax,ax
        out dx,al
        inc dx
        mov cx,ax
PAL:
        mov ax,cx
		out dx, al
		xor ax,33
        shl ax,1
		xor ax,33
      	out dx, al
        shr ax,2
		xor ax,33
        out dx, al
        
        inc cl
        jne PAL
	pop dx

	xor di,di
	
	mov bx,200
row:
	mov cx,320
pixel:

	%define mem eoc + 256
	%define x mem + 0*4
	%define y mem + 1*4
	%define t mem + 2*4
	
	mov [x],cx
	fild word [x]
	fstp dword[x]
	mov [y],bx
	fild word[y]
	fstp dword[y]
	mov [t],dx
	fild word[t];
	fstp dword[t];
	
	fld dword[x]
	fadd dword[x]
	fadd dword[y]
	fadd dword[t];
	fmul dword [cs:const0]
	fsin
	
	fld dword[y]
	fadd dword[y]
	fsub dword[x]
	fadd dword[t];
	fmul dword[cs:const0]
	fsin
	
	fadd
	
	fmul dword[cs:const1]
	fld dword[t];
	fmul dword[cs:const0];
	fsin
	fmul;
	fmul dword[t];
	fmul dword[t];
	fmul dword[cs:const2];
	
	
	%define r eoc + 3*4
	fistp word [r]
	mov ax,[r]
	add ax,bp
	
	
	stosb
	loop pixel
	dec bx
	jnz row
	
	;frame

	;;wait for retrace
	push dx
	    xor ax,ax
        mov dx,03DAh
    pmw1:
        in al,dx;
        and al,8
        jnz pmw1
    pmw2:
        in al,dx
        and al,8
        jz pmw2;
	pop dx
	
	push ds
	push es
	pop ds
	push 0a000h
	pop es
	xor di,di
	xor si,si
	mov cx,320*50
	rep movsd ;blit to video ram
	pop ds
	inc dx
	
	mov bp,dx
	shr bp,6
	imul bp,17
	
	in al,60h
	dec al
	jnz main
	
	ret;
const0: dd 0.05
const1: dd 16.0;
const2: dd 0.00000001;
eoc:

