; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; **                 Routines for Mode 0: text mode 80*25.                 ** 
; **                      Alain BROBECKER, aka Baah.                       ** 
; **                              June 1995.                               **  
; **                                                                       **
; ***************************************************************************
; ***************************************************************************

  include   rincbin.inc

; ***************************************************************************
MODE0LIB                SEGMENT USE16                     
                        Assume CS:MODE0LIB


;==== Mode 0 initialisation =================================================
init_mode0              PROC FAR
  push ax 
  mov       ax,03h                  ; Switch to mode 03h.
  int       10h
  pop       ax
  ret
init_mode0              ENDP
;============================================================================



;==== Hide cursor ===========================================================
hide_cursor0            PROC FAR
  push      ax
  push      bx
  push      dx
  mov       ah,02h                  
  mov       bh,00h
  mov       dx,194fh                
  int       10h
  pop       dx
  pop       bx
  pop       ax
  ret
hide_cursor0            ENDP
;============================================================================



;==== Centered Text Printing ================================================
; es=segment of screen.
; ds:[si] points on text which is formatted like the following...
;    db  line(0->24),'The dumb text...',0
; The last line must end with ,0,0.
; After the routine, ds:[si] points just after the 0.
; The direction flag is cleared.
print_text0             PROC FAR
  push      ax  
  push      cx
  push      di
  push      si
  cld                               ; Clear the direction flag.
  lodsb                             ; al=line where to print text.
@@print_one_string:
  xor       ah,ah                   ; ax=line.
  mov       cx,ax                   ; A multiplication by 80.         
  shl       ax,2        
  add       ax,cx       
  shl       ax,5                    ; ax=line*(4+1)*16*2.
  mov       di,ax                   ; es:[di] points on the good line.
; Now we count the nb of chars in this line.
  mov       ah,0        
  mov       cx,si                   ; si will be changed, so...
@@count_one_char:
  lodsb                             ; al=current char.
  cmp       al,00h                  ; If al=null we have reached the end.
  jZ        @@text_length_known     
  inc       ah                      ; Else one char of more.
  jmp       @@count_one_char       
@@text_length_known:
  mov       si,cx                   ; ds:[si] points anew on string.
  mov       cx,80  
  sub       cl,ah                   ; cx=80-length.
  shr       cx,1                    ; cx=int((80-length)/2).
  add       cx,cx                   ; cx=2*int((80-length)/2).
  add       di,cx                   ; es:[di] points on first char on screen.
  mov       cl,ah
@@print_one_char:
  movsb                             ; Copy one char.
  inc       di                      ; One word per char on screen.
  loop      @@print_one_char
  inc       si                      ; Point just after the zero.
  lodsb                             ; al=next char.
  cmp       al,00h
  jNZ       @@print_one_string
  pop       si
  pop       di
  pop       cx
  pop       ax
  ret
print_text0             ENDP
;============================================================================



;==== Baah Logo Printing ====================================================
; es=segment of screen.
; This routine changes the attributes of the characters which are in the
; logo and left all other characters unaffected.
baah_text_logo          PROC FAR
  push      ax
  push      bx
  push      cx
  push      di
  push      si
  mov       si,offset cs:@@baah_logo ; cs:[si] points on the logo.
  mov       di,9*80*2+1             ; Pass 9 lines to center logo.   
  mov       al,1fh                  ; Background=blue | foreground=white. 
  mov       cx,35                   ; 35 bytes for logo.
@@logo_one_byte:
  mov       ah,cs:[si]              ; Load one byte=8 pixels.
  inc       si
  mov       bx,8                    
@@logo_one_pixel:
  shl       ah,1                    ; Put value of first pixie in carry flag.
  jNC       @@logo_pixel_clear
  mov       es:[di],al              ; If carry is set, then put attribute
  mov       es:[di+2],al            ; in two consecutive char.  
@@logo_pixel_clear:
  add       di,4                    ; One bit in logo for 2 chars.
  dec       bx                      ; One pixel done.
  jNZ       @@logo_one_pixel      
  loop      @@logo_one_byte
  pop       si
  pop       di
  pop       cx
  pop       bx
  pop       ax
  ret

@@baah_logo:
  incbin 'baah.xxx',35

baah_text_logo          ENDP
;============================================================================



;==== ClearScreen Routine ===================================================
; es=segment of screen.
; Seems to go at the same speed when using bytes, words or longs. 
clear_screen0            PROC FAR
  push ax 
  push cx 
  push di
  cld                               ; Clear the direction flag.
  xor       di,di                   ; es:[di] points on beginning of screen.
  mov       ax,0720h                ; Fill with space, normal colors.
  mov       cx,80*25                    
  rep       stosw                   ; Clear 80*25 words. 
  pop di 
  pop cx 
  pop ax
  ret
clear_screen0            ENDP
;============================================================================


MODE0LIB                ENDS
; ***************************************************************************
