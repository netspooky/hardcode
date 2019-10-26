; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; **                Initialises mode X: 320*240, 256 colors.               ** 
; **                      Alain BROBECKER, aka Baah.                       ** 
; **                              July 1995.                               **  
; **                                                                       **
; ***************************************************************************
; ***************************************************************************

; ***************************************************************************
INC_INITMODX            SEGMENT USE16                     
                        Assume CS:INC_INITMODX

;==== Mode X initialisation =================================================
; This sets the screen to 320*240, 256 colors, in mode X.
; No parameters...
init_modeX              PROC FAR
  pusha 
  mov       ax,13h                  ; Switch to 320*200 linear mode.
  int       10h                     
; Disable chain4 mode, and reset sequencer.
  mov       dx,03c4h                ; Sequence controller index.
  mov       ax,0604h                ; Memory mode subregister.
  out       dx,ax                   ; Disable chain4 mode.
  mov       ax,0300h                ; Reset subregister.
  out       dx,ax                   ; Reset sequencer.
; Change crt subregisters in order to have a 320*240 screen.
; We must 'unprotect' subregisters 0-7 before accesing them.
  mov       dx,03d4h                ; Crt controller index.
  mov       al,11h                  ; Vertical retrace end subregister. 
  out       dx,al                   ; (It contains protection for regs 0-7).
  inc       dx                      ; CRT Controller Data register
  in        al,dx                   
  and       al,07fh                 ; Remove write protect on regs 0-7.
  out       dx,al                   
  dec       dx                      ; dx=crt controller index.
; Change crt subregisters.
  mov       cx,10                   ; 10 crt registers to update.
  mov       bx,offset cs:@@crt_modeX ; cs:[bx] points on datas for crt.
@@crt_loop_modeX:
  mov       ax,cs:[bx]              ; Get the next subregister and value.
  out       dx,ax                   ; Set it.
  add       bx,2                    ; cs:[bx] points on next data.
  loop      @@crt_loop_modeX
; Switch to 480 lines to have square pixels.
  mov       dx,3cch                 ; Miscellaneous output register.
  in        al,dx
  or        al,11000000b            ; Switch to 480 lines.
  mov       dx,3c2h                 ; Miscellaneous input register.
  out       dx,al
  popa
  ret

@@crt_modeX  dw      00d06h  ; vertical total
             dw      03e07h  ; overflow (bit 8 of vertical counts)
             dw      04109h  ; cell height (2 to double-scan)
             dw      0ea10h  ; v sync start
             dw      0ac11h  ; v sync end and protect cr0-cr7
             dw      0df12h  ; vertical displayed
             dw      00014h  ; turn off dword mode
             dw      0e715h  ; v blank start
             dw      00616h  ; v blank end
             dw      0e317h  ; turn on byte mode

init_modeX              ENDP
;============================================================================

INC_INITMODX            ENDS
; ***************************************************************************
