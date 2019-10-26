;   .."Disappearing Into the Spotlight"..
;   .. (C) 2006 Ferris / Youth Uprising..

;       ..Coded to 'M. Shepard' by..
;          ..the band 'Thursday'..

[org 100h]
[section .text]
		mov al,13h
		int 10h
		
		push 0a000h
		pop es
		
		mov dx,3c8h
		xor ax,ax
		out dx,al
		inc dx
PAL		push ax
		shr al,2
		out dx,al
		shl al,1
		cmp al,byte 63
		jg PAL2
		xor ax,ax
PAL2	sub al,63
		out dx,al
		out dx,al
		pop ax
		inc al
		jnz PAL
		
		mov [si + 18],word 80
		
MAIN	fninit
		
		mov [si],bx
		fild word [si]
		fild word [si]
		mov [si],word 127
		call ANGLE
		fstp qword [si + 2]
		fstp qword [si + 10]
		mov [si],word 64
		call ANGLE
		mov [si],word 2
		fimul word [si]
		fstp qword [si + 26]
		
		mov di,6400
		mov dx,-80
YLOOP	mov bp,-160
XLOOP	fninit
		
		mov [si],dx
		fild word [si]
		fidiv word [si + 18]
		mov [si],bp
		fild word [si]
		fidiv word [si + 18]
		
		fld st1
		fmul qword [si + 2]
		fld st1
		fmul qword [si + 10]
		fsubp st1
		fld st1
		fmul qword [si + 2]
		fld st3
		fmul qword [si + 10]
		faddp st1
		fstp st2
		fstp st2
		
		mov [si],word 20
		fild word [si]
		fldz
		mov al,184
RAYC	fadd st2
		fld st3
		faddp st2,st0
		fld st0
		fmul st0
		fld st2
		fadd qword [si + 26]
		fmul st0
		faddp st1
		fsqrt
		mov [si],ax
		fild word [si]
		fadd st0
		mov [si],bx
		fiadd word [si]
		mov [si],word 32
		fidiv word [si]
		fldpi
		fmulp st1
		fsin
		fadd st0
		fadd st1
		fistp word [si]
		mov cx,[si]
		cmp cx,byte 16
		jbe RAYH
		fistp word [si]
		mov cx,[si]
		cmp cx,byte 24
		jge RAYH
		dec al
		jnz RAYC
		
RAYH	mov ah,al
		mov al,255
		sub al,ah
		stosb
		
		inc bp
		cmp bp,160
		jnz XLOOP
		inc dx
		cmp dx,byte 80
		jnz YLOOP
		
		inc bx
		mov ah,01
		int 16h
		jz MAIN
		
		retn
		
ANGLE	fidiv word [si]
		fldpi
		fmulp st1
		fsincos
		ret
		
EXTR	db ";)"