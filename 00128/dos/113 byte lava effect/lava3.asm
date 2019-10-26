; 113 byte lava effect (standard VGA palette) 
; /mic, 2007 | micol972@gmail.com | http://badc0de.jiggawatt.org
;
; Press [ESC] to exit the program.
;
; How to compile:
;  nasm -o lava3.com lava3.asm
;


factor1	EQU 0x200 

[org 0x100]		

start:
mov 	al,0x13	
int 	0x10
push	0xa000
pop	es

mov 	bh,0xFA
mov 	si,factor1+4
mov 	dword [si-4],0x3CD14444
mov 	dword [si],0x41FB3333 
mov 	cx,0x100
@@1:
	mov 	word [si+8],cx
	fild 	word [si+8]
	fmul 	dword [si-4]
	fcos
	fmul 	dword [si]
	fadd 	dword [si]
	fistp 	word [bx]
	inc 	bx
	loop 	@@1
dec bx


@@mainloop:
	mov 	dx,[si-2] 
	mov 	cx,200
	xor 	di,di
	@@yloop:
		inc 	dx
		add 	dh,2
		push 	cx
		mov 	cx,[si-2]
		mov 	bp,320
		@@xloop:
			inc 	cx
			mov 	bl,cl 
			mov 	al,[bx]
			mov 	bl,ch 
			add 	bl,dh
			add 	bl,cl
			add 	bl,al
			add 	al,[bx]
			add 	bl,dh
			add 	al,[bx]
			and 	al,0x3C
			stosb
			dec 	bp
			jnz 	short @@xloop
		pop 	cx
		loop 	@@yloop
	add 	word [si-2],0x1FE
	dec 	byte [si]
	in 	al,60h
	dec 	al
	jnz 	@@mainloop

ret

; The end


