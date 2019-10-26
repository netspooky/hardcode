;  Split Colors by Synok.
; ========================
org 0x100		; Start		
mov ax,13h     	; VGA
int 10h			; Interrupt
les bp,[bx]		; Let's get started!!	
loop1:			; Begin Loop
	add al,22	; Add 22 to AL
	inc cx		; Increase CX
	stosb		; Transfer 1 Byte
	jl loop1	; Jump if Less to Loop
	inc al		; Increase AL
	jmp loop1	; Jump Back 2 Loop
; =========================
;  Contact ; Synok@live.se