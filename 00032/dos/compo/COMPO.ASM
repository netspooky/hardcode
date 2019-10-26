;===============================================================================
;                               compo.asm
; Submission for compo #9 at #asm at EFNET
;(C)I don't take any responsibility for the use of this program
;                          Zedr0n -- connection closed
;===============================================================================
;===============================================================================
; .Com declaration
;===============================================================================
.model tiny
.data
.code

.386
org 100h
;===============================================================================
; Code segment
;===============================================================================
Start: 
; << Set up direct access to video memory >>
  push 0B800h
  pop es
; << Set bx to 1, so that there is a bit to rotate >>  
  inc bx
; << Get random value >>
@@loop:
  in al,40h
; << Either filler character or nothing >>
  and al,bl
; << Attribute is from 0 to 15 >>
  inc dx
  and dl,1111b
  mov ah,dl
  
  stosw
; << If all segment filled, then change the filler character >>
  test di,di
  setz cl
  rol bl,cl
; << Check for keystroke >>
  mov ah,01h 
  int 16h
  jz @@loop
    
  ret  
  
end Start
