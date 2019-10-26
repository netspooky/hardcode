; 99 byte lava effect (standard VGA palette) 
; /mic, 2008 | micol972@gmail.com | http://badc0de.jiggawatt.org
;
; Press [ESC] to exit the program.
;
; How to compile:
;  nasm -o lava4.com lava4.asm
;



[org 0x100]		

start:
mov 	al,0x13	
int 	0x10
push	0xa000
pop	es

mov 	bh,0xFA
mov 	si,factor1+2
mov 	cx,0x100
@@1:
	mov 	word [si+8],cx
	fild 	word [si+8]
	fmul 	dword [si-2]
	fcos
	fmul 	dword [si]
	fadd 	dword [si]
	fistp 	word [bx]
	inc 	bx
	loop 	@@1
dec bx



@@mainloop:
	mov 	dx,[si] 
	mov 	cl,200
	xor 	di,di
	@@yloop:
		inc 	dx
		add 	dh,2
		push 	cx
		mov 	cx,[si]
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
			stosb
			dec 	bp
			jnz 	short @@xloop
		pop 	cx
		loop 	@@yloop
	add 	word [si],0x1FE
	dec 	byte [si+2]
	in 	al,60h
	dec 	al
	jnz 	@@mainloop

ret

factor1:
dd 0x3CD14444
dw 0x41FB 

; The end


