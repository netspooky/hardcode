; (less than) 512-byte thingy for asm compo #10
;
; Written by Joni Toivanen ('Jomppa'). No rights reserved, use
; (or don't use =) to whatever you wish...
;
; Before compiling this file you should compile 'snow.asm' to
; binary and that to file 'out', which should contain 'DW 0x????'
; lines (see 't.c' included in package). Then compile entry.asm
; (this file).

bits 16
org 0x100

start:
	PUSH	WORD	0x2020 + stuff
	POP		AX
	SUB		AX, 0x2020
	PUSH		AX
	POP		SP

; In 'trans', 'stuff' is translated to:
; a:	LODSW			: AD
; 	AND AX, 0x0F0F		: 25 0F 0F
; 	SHL AL, 4		: C0 E0 04
; 	OR AL, AH		: 08 E0
; 	STOSB			: AA
; 	LOOP a			: E2 F4

trans:
	POP		AX
	SUB		AX, 0x2073
	PUSH		AX
	INC		SP
	INC		SP
	POP		AX
	SUB		AX, 0x2121
	PUSH		AX
	INC		SP
	INC		SP
	POP		AX
	SUB		AX, 0x3F60
	PUSH		AX
	INC		SP
	INC		SP
	POP		AX
	SUB		AX, 0x282C
	PUSH		AX
	INC		SP
	INC		SP
	POP		AX
	SUB		AX, 0x7540
	PUSH		AX
	INC		SP
	INC		SP
	POP		AX
	SUB		AX, 0x2B3E
	PUSH		AX
	POP		SP

	PUSH	WORD	0x2020 + more_stuff
	POP		AX
	SUB		AX, 0x2020
	PUSH		AX
	POP		SI
	PUSH		AX
	POP		DI
	PUSH	WORD	0x2220
	POP		AX
	SUB		AX, 0x2020
	PUSH		AX
	POP		CX

stuff:
	DW		0x4620, 0x3030, '  ', 0x3030, '      '

more_stuff:
	%include	"out"
