
;
; ÄÄÄ NASM pe-2-com (c) 2000 by franky@scene.at ÄÄÄ
;

	SECTION .text
	ORG	100h

%define PE_FILE         "cowmemory2.exe"

main:
	mov	ah, 4ah			;free some memory
        mov     bh, 10h
	int	21h

        mov     ax, cs                  ;DS,ES = CS
        mov     ds, ax
        mov     es, ax

	mov	ah, 3ch			;open file
	xor	cx, cx
	mov	dx, file
	push	dx
	int	21h
	xchg	bx, ax

	mov	ah, 40h			;write data
	mov	dx, pe_prog
	mov	cx, pe_proglen
	int	21h

	mov	ah, 3eh			;close file
	int	21h

        mov     ax, 4b00h               ;execute
	pop	dx
        mov     bx, eblock
;	mov	[ bx + 4 ], ds		;used to pass cmdline
	int	21h

	mov	ah, 4ch			;ret might cause problems
	int	21h

file  	db	"t.exe", 0

eblock  dw      0                       ;exe parameter block
	dd	0, 0, 0, 0, 0


pe_prog:				;win32 application

	INCBIN	PE_FILE

pe_proglen	EQU	$ - pe_prog



