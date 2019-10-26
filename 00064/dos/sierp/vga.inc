%macro vga_clrscr 0
; 32 bit Version
;	xor di,di
;	xor eax,eax
;	mov cx,16000
;	rep stosd

; 16 bit Version
	xor di,di
	xor ax,ax
	mov cx,32000
	rep stosw

; Die 16 bit Version ist 2 bytes kleiner.
%endmacro

%macro vga_init 0
	push 0A000h	; Videoadresse laden
	pop es
	vga_start	; 320x200x8 aktivieren
%endmacro

%macro vga_start 0	; 5 bytes
	mov ax,19
	int 10h
%endmacro

%macro vga_end 0	; 5 bytes
	mov ax,3
	int 10h
%endmacro

%macro vga_waitrefresh 0	; Diese Routine wird nicht benutzt
	mov dx,3DAh
NoVrt:
	in al,dx
	test al,8
	jz NoVrt
%endmacro
