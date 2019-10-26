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
;   Name:    wait4it
; Author:    bitRAKE
; Thanks:    FASM and coders everywhere

	org 256
	mov al,19
	int 16
	lds bx,[bx]
main:
	imul bx,53

	mov al,[bx]
	aaa

	sbb ah,[bx+320+1]
	sub ah,[bx+320-2]
	aad 2

	add [bx],al
	dec bx

	in al,60h
	dec ax
	jnz main
	retn