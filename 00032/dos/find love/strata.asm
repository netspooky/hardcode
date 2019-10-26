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
;   Name:    strata
; Author:    bitRAKE
; Thanks:    FASM and coders everywhere

	org 256
	mov al,19
	int 16
	lds bx,[bx]
main:
	imul bx,101

	sbb al,[bx+320-1]
	sbb al,[bx+320+1]
	mov [bx],al
	jge .1
	mov [bx],bh
.1:
	rcr byte [bx],1
	dec bx
	in al,60h
	dec ax
	jnz main
	retn

; keys effect display