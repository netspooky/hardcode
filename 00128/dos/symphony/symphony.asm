org 100h
%define off -3
%define inst 11
		xor al,0x13
top:
		int 0x10
		sbb cx,dx
		sar cx,1
		rcr ebx,1
		adc dx,cx
		test bh,ah
		jnz F
		xchg cx,dx
		adc cx, byte 127
F:
		mov al,bl
		and al,15
		or ax,0x0c10
		pusha
		xor bx,bx
		mov dx,0x331
		mov al,0x3f
		out dx,al
		dec dx
		mov ax,[fs:0x46c]
		test al,3
		jnz skipsound
		inc word [fs:0x46c]
		mov cl,ah
		bsf ax,ax
		sub al,2
		and al,7
		mov bl,al	
		mov si,music2
		outsb
		outsb
		outsb
		add si,bx
		lodsb
		shr cl,1
		imul cx,byte 3
		and cl,7
		add al,cl
		out dx,al
		mov al,80
		out dx,al
		mov si,music
		outsb
		outsb
		outsb
		add si,bx
		outsb
		mov al,127
		out dx,al
skipsound:
		in al,0x60
		dec al
		popa
		jnz top
		ret
music:
		db 0xc9,25,0x99
		db 44,46,38,41,35,84,58,49
music2:
		db 0xc0,inst,0x90
		db 47-off,50-off,54-off,59-off,62-off,57-off,66-off,58-off+8
