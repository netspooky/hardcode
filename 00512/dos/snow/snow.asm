; Code to a simple snow effy
;
; Written by Jomppa, no rights reserved.
;
; Coded in hurry not very nice nor optimized... (in other words: it sucks! :)

bits 16
org 0x154	; If you change something in entry.asm, this must be changed

start:
	MOV		AX, 0x13
	INT		0x10

	PUSH	WORD	0xA000
	POP		ES

snow:
	CALL		rand
	AAM		160
	XOR		AH, AH
	ADD		AX, AX
	XCHG		AX, DI
	MOV		AL, 15
	STOSB

	MOV		CX, 64000-320
	MOV		DI, CX
	DEC		DI
	STD
.loop:
	MOV		AL, [ES:DI]
	OR		AL, AL
	JZ		.cont

	CALL		rand
	AAM		3
	XOR		AH, AH
	XCHG		AX, BX
	ADD		BX, 319
	ADD		BX, DI
	MOV		AL, 15
	CMP		[ES:BX], AL
	JZ		.cont
	MOV		[ES:BX], AL
	XOR		AX, AX

.cont:
	STOSB
	LOOP		.loop

	MOV		AH, 1
	INT		0x16
	JZ		snow

end:
	MOV		AX, 3
	INT		0x10

	MOV		DX, winter_str
	MOV		AH, 9
	INT		0x21

	INT		0x20

rand:
	MOV		AX, 11233
	IMUL		AX, 117
	INC		AX
	MOV		[rand+1], AX
	RET

winter_str:
	DB		'Winter is coming :(', 13, 10, '$'
