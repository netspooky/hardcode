%define		width	320
%define		height	200
%define		states	65
org   		100h
			pop cx
			les di,[bx]
			mov al,0x13
			int 0x10
			mov ds,di
			inc byte [height / 2 * width + width / 2 + 16]
NextPixel:	salc
			or al,[di]
			jnz NotCheck
Check:		mov dl,	[di+1]
			add dl,	[di-1]
			mov bx,width-1
Flip:		add dl,[bx+di]
			inc bx
			add dl,[bx+di]
			inc bx
			add dl,[bx+di]
			neg bx
			js Flip
			dec dl
			jnz CheckEnd
NotCheck: 	inc ax
CheckEnd:	and al,0x3f	
SetNext:	stosb
			loop NextPixel
			push ds
			push es
			pop ds
			pop es
			jmp short NextPixel