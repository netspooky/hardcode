; Assumptions: DOSBox 0.74
;
;          AX BX = 0000
;             CX = 00FF
; DX CS DS ES SS = .... (same unknown value)
;             SI = 0100
;             DI = FFFE
;             BP = 09..
;             SP = FFFE
;             IP = 0100
;         [ds:0] = CD 20 FF 9F
;
;   Name:    pinkfire
; Author:    bitRAKE
; Thanks:    FASM and coders everywhere

	org 256
	mov al,19
	int 16
	lds bx,[bx]
main:
	imul bx,101

	sub al,[bx+640-1]
	sub al,[bx+640+1]
	mov [bx],al
	jge .1
	and [bx],bh
.1:
	sar byte [bx],1
	dec bx
	in al,60h
	dec ax
	jnz main
	retn