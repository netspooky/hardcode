; 32-byte scrolling colors effect for DOS
; /Mic, 2004

; tasm /m mic-0x20.asm
; tlink /t mic-0x20.obj


 
.model tiny		
.386				
code segment use16	
assume cs:code, ds:code	
org 0100h		


start:	
mov al,13h
int 10h

push 0a000h
pop ds


@@mainloop:
	mov cx,63998
	@@draw:
		mov si,cx
		lodsb
		mov ah,al
		lodsb
		sub al,dl
		or al,ah
		xor al,cl
		mov [si],al
	loop @@draw
 	inc dx

jmp short @@mainloop

dw 1337

code ends	
END start	


;/Mic, stabmaster_@hotmail.com
