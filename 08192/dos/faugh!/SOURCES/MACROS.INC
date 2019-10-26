MASM
COMMENT *
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Macros.inc - Standard Macros (just to be tidy)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Revision: 0.1a   Date: 07-March-1993        Copyright 1993 Phil Carlisle

  Description -- Just a bunch of macro's to save re-typing

  History

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*

set13 macro					; set mode 13h
	mov	ax,13h
	int	10h
endm
	
Textmode macro                                  ; set text mode back again
      mov     ax,03h
      int     10h
endm


Waitferescape macro                             ; waits for escape key
      local     waitferit                       ; not used in this code
waitferit:
      in    al,60h
      cmp   al,1
      jne   waitferit
endm

quittodos macro                                 ; quit back to dos
      mov   ah,4Ch                              ; MUST be called
      int   21h                                 ; gives back memory and
endm                                            ; control to dos


GiveUpMem macro                               ;expects amount of mem
      mov   ah,4ah                            ;required in bx
      int   21h                               ;use dos free mem func...
endm





IDEAL
