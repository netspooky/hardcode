; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; **                          Puts the palette.                            ** 
; **                      Alain BROBECKER, aka Baah.                       ** 
; **                              July 1995.                               **  
; **                                                                       **
; ***************************************************************************
; ***************************************************************************

; ***************************************************************************
INC_PUT_PAL             SEGMENT USE16                     
                        Assume CS:INC_PUT_PAL

;==== Put Palette ===========================================================
; Not much to say about this.
; Parameters...
;    ds:si - points on palette compounds.
put_palette             PROC FAR
  pusha 
  mov       bl,0                    ; bl=color counter.
  mov       dx,03c8h                ; Palette write port.
@@put_palette_one:
  mov       al,bl                   ; Color number in al.
  out       dx,al                   ; Choose color to change.
  inc       dx
  lodsb                             ; al=red compound.
  out       dx,al
  lodsb                             ; al=green compound.
  out       dx,al
  lodsb                             ; al=blue compound.
  out       dx,al
  dec       dx
  inc       bl                      ; One color done.  
  jne       @@put_palette_one       ; If bl=256=0 then we have changed all colors.
  popa
  ret
put_palette             ENDP
;============================================================================

INC_PUT_PAL             ENDS
; ***************************************************************************
