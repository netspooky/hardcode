org 100h

start:
mov al,0x12			; switch to 640*480 ( 16 colors )
					; is best for projecting mouse
int 0x10

mloop:
mov ax,0x03 		; get mouse position
int 0x33
					; CX holds x
					; CY holds y
					; BX holds button states
					
xchg ax,bx			; use button states as color	

mov ah,0x0C 		; set pixel ( on CX, DX )
int 0x10

dw 0xF4EB			; a 2byte "jmp mloop"

