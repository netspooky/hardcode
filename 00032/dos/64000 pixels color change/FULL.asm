; 19 Byte Not Packed asm effect
; 64000 pixels color change
; 11 Lines of code by daemon^dhc
;----------------------------------------------
org 0x100 	; Start at 0x100
mov ax,13h 	; VGA-mode
int 10h 	; Interrupt
les bp,[bx] 	; "Draw"-mode
loop1:		; Loop
inc cx		; increase X
cmp cx,64000	; compare to pixel at 64000
stosb		; Store byte
jne loop1	; Jump if cx not equal to 64000
inc al		; Increase "Color-register"
jmp loop1	; Jump, no matter what
;----------------------------------------------
