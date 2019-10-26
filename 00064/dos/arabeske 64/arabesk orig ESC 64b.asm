%define		width	320
%define		height	200
%define		states	65
org   		100h
			pop cx
			les di, [bx]
			mov al, 0x13
			int 0x10
			mov ds, di
			inc byte [height/2*width+width/2+16]
NextPixel:	xor al, al
			add al, [di]
			jnz NotCheck
Check:		mov dl,	[di+1]
			add dl,	[di-1]
			mov bx, width
Flip:		add dl, [bx+di]
			add dl, [bx+di-1]
			add dl, [bx+di+1]
			neg bx
			js Flip
			dec dl
			jnz CheckEnd
NotCheck: 	inc ax
CheckEnd:	cmp al,	states
			jl SetNext
			salc
SetNext:	stosb
			loop NextPixel
			push ds
			push es
			pop ds
			pop es
			in al,0x60
			dec ax
			jnz NextPixel
			int 0x20
			