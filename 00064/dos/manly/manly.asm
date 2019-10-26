bits	16
org  	0x100

;
;           M       MANLY       M
;        ZMN          ^          DMO
;       MM8    A torotonnato's    +MM,
;     7MMM        production       MMMO
;     MMMMN           ^           OMMMM
;     MMMMMMMMN8MMMMMMMMMMMMM8NMMMMMMMM
;     NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
;       MM MMMMMMMMMMMMMMMMMMMMMMM~NM
;          OMM MMM8MMM?MMMNMMM MM8      IFS  stolen from  an old  computer
;              MM  MMMMMMM  MM          magazine, if you know the original
;             +MMMM=MMMMM?MMMMM         source & / | want to chat, contact
;              MMMMMMMMMMMMMMM          me at torotonnato@gmail.com
;                MMM$MMM~MNM7
;                 IMMMMMMMM             preconditions:
;                 M,MMM7M M             	ah = 0
;                  NZ M IM                  bx = 0
;                   MMMMM                   far ptr cs:[0] = 0x9FFF:0x20CD
;
;******************************************************************************

%define INTERLEAVED 1

%if 	INTERLEAVED
		bitmask equ 0xc0
%elif
		bitmask equ 0xe0
%endif

		mov al, 0x13					;
		int 0x10						;
		lds ax, [ bx ]					;
										; bx <- x = 0
		aam 0x55						; ax <- y = 547 (long & manly orbit :)
		mov dx, 0x03C9					;
L : 	dec si							; frame--
		xchg ax, bx						; x' = y,			  y' = x
		neg bx							; x' = - y, 		  y' = x
		mov di, ax						;
.1:		neg di							;
		js .1							;
		lea bx, [ bx + di + 512 ]		; x' = 512 - y + |x|, y' = x
		pusha							;
		and al, bitmask					;
		imul di, ax, byte 10			; di = 320 * y
		shrd ax, si, 18					; ax = frame >> 2, sharper: mov ax, si
		out dx, al						;
		out dx, al						;
		out dx, al						; set_palette( ~frame, al, al, al )
		sar bx, 5						; bx = x >> 5
		inc byte [ bx + di + 0x4B92 ]	; pixels[ bx + di + align ]++
		in ax, 0x60						;
		dec ax							;
		popa							;
		jnz L							;
		ret								;
