;--------------------------------------------------------------------------
; File:   EFnet #asm Competition #9, entry therefor
; Author: Two9A, August 2004
; Use:    Assemble with NASM into a DOS .com file, have fun.
;--------------------------------------------------------------------------

[bits 16]                    ; 16 bit code, of course

	mov al,0x13          ; VGA Mode 0x13 (320x200x8) [assuming ah=0]
	int 0x10             ; Throw it over

	push 0xA000          ; Video buffer segment
	pop es               ; for output

lp:	mov cx,320           ; Write one line (320 pixels)
	in ax,0x40           ; Read a word from the timer [kinda-RNG]
 	and ax,191           ; Limit to ranges 0-63, 128-191
	mul cx               ; That's the y value. y*320=addr
	mov di,ax            ; That address will be the write point
	in al,0x40           ; Get a pseudorandom colour
	rep stosb            ; and write

	in al,0x60           ; Check keyboard port
	dec al               ; If we hit ESC (1), this will become 0
	jnz lp               ; hence we'd drop out of this loop
	ret                  ; and quit

;---EOF--------------------------------------------------------------------
