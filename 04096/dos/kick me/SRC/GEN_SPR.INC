; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; **                        SPRITE CODE GENERATOR.                         ** 
; **                      Alain BROBECKER, aka Baah.                       ** 
; **                              July 1995.                               **  
; **                                                                       **
; ***************************************************************************
; ***************************************************************************

; ***************************************************************************
INC_GEN_SPR             SEGMENT USE16                     
                        assume CS:INC_GEN_SPR

; ###########################################################################
; ####                                                                   ####
; ####                 Generate code for sprite drawing.                 ####
; ####                                                                   ####
; ###########################################################################
; This routine will generate code which will draw a given sprite into
; video memory. This routine was created for sprites in modeX.
; ---------------------------------------------------------------------------
; Parameters for the generating routine:
;           ds:si = adress of sprite datas.
;           es:di = adress where to generate code.
; After the routine, di is set to the end of the generated code, and si
; points after the given sprite.
; Also note that the routine ends with a far return. (retf)
; Sprite datas must be organised like this...
;     1 byte = sprite width/4. (spr_w/4)
;     1 byte = sprite height. (spr_h)
;     spr_w/4*spr_h bytes = datas for plane 0. 
;     spr_w/4*spr_h bytes = datas for plane 1. 
;     spr_w/4*spr_h bytes = datas for plane 2. 
;     spr_w/4*spr_h bytes = datas for plane 3. 
; ---------------------------------------------------------------------------
; Parameters for the generated code:
;           dx = 03c4h (Sequence controller index)
;           al = 02h (Map mask subregister) 
;           ah = First map mask. (2^xmod4)
;           ds:bx = adress of sprite. (bx=y*320+x/4)
; ---------------------------------------------------------------------------
; Some explanations, remarks...  
;   * The generated code must be called with a first given map mask. 
;   Each time we have finished to draw a whole plane, we want to go on to
;   the next one, and this is performed by rotating left the current map mask.
;   If we are above the plane 3 (ie mapmask and &f=0), then we must go back
;   to plane 0, but one pixel on the right of previous planes. 
;   * No mask is asked for, I just consider that pixels with color 0
;   are not to be drawn, others are...

gen_sprite_drawing      PROC FAR
  push ax
  push bx
  push cx
  push dx
  lodsw                             ; al=spr_w/4 | ah=spr_h.
  mov       @@spr_w,al              ; Save them for later use.
  mov       @@spr_h,ah
  mov       ah,80
  sub       ah,al                   ; ah=offset between two lines.  
  mov       byte ptr @@offset,ah
  mov       cl,4                    ; Generate code for 4 planes.
@@gen_draw_one_plane:
  mov       byte ptr es:[di],0efh   ; Generate the 'out dx,ax'.
  inc       di
  mov       dx,0                    ; dx=offset of pixels.
  mov       bh,@@spr_h              ; bh=nb of lines to generate.
@@gen_draw_one_line:
  mov       bl,@@spr_w              ; bl=nb of pixels per line.
@@gen_draw_one_pixel:
  lodsb                             ; al=pixel to generate.
  cmp       al,0                    ; Pixel is null?
  jZ        @@gen_draw_null_pixel
; Pixel isn' t null, so we will have to draw it. But we must check if  
; the next pixel must be drawn too, in order to use a word move instead
; of a byte move. (It proves faster!) For this w must check if end of
; line was reached or not.
  dec       bl                      ; One pixel was loaded.                      
  jZ        @@gen_draw_line_end     ; It was the last of current line?
  mov       ah,ds:[si]              ; Load next pixel.
  inc       si
  cmp       ah,0                    ; The second pixel is null?
  jZ        @@gen_draw_one
; We have two pixels to draw! Generate code for the word move, and go on...
  mov       word ptr es:[di],087c7h ; Opcode for a mov.w [bx+imm16],imm16.
  mov       es:[di+2],dx            ; Save offset.
  mov       es:[di+4],ax            ; Save pixels value.
  add       di,6
  add       dx,2                    ; Offset to next pixel.
  dec       bl                      ; Count the second pixel loaded.
  jNZ       @@gen_draw_one_pixel    ; Pixels left in this line?
  add       dx,@@offset             ; Offset to next line.
  dec       bh                      ; One line processed.
  jNZ       @@gen_draw_one_line     ; Was it the last one?
  jmp       @@gen_draw_plane_end

; If we are here this means we have loaded two pixels, but only the first
; one must be drawn, so generate code for it and continue.
@@gen_draw_one:
  mov       word ptr es:[di],087c6h ; Opcode for a mov.b [bx+imm16],imm8.
  mov       es:[di+2],dx            ; Save offset.
  mov       es:[di+4],al            ; Save pixel value.
  add       di,5
  add       dx,2                    ; Offset to next pixel.
  dec       bl                      ; Count the second pixel loaded.
  jNZ       @@gen_draw_one_pixel    ; Pixels left in this line?
  add       dx,@@offset             ; Offset to next line.
  dec       bh                      ; One line processed.
  jNZ       @@gen_draw_one_line     ; Was it the last one?
  jmp       @@gen_draw_plane_end

; Hum, we have loaded one pixel, and it is the last one.
; Generate the mov.b and then make the offset point on next line.
@@gen_draw_line_end:
  mov       word ptr es:[di],087c6h ; Opcode for a mov.b [bx+imm16],imm8.
  mov       es:[di+2],dx            ; Save offset.
  mov       es:[di+4],al            ; Save pixel value.
  add       di,5
  add       dx,@@offset             ; Offset to next line.
  inc       dx                      ; We must count the loaded pixel too.
  dec       bh                      ; One line processed.
  jNZ       @@gen_draw_one_line     ; Was it the last one?
  jmp       @@gen_draw_plane_end

; Well, the loaded pixel is empty, so just increment the offset.
@@gen_draw_null_pixel:
  inc       dx                      ; Offset to next pixel.
  dec       bl                      ; Count the second pixel loaded.
  jNZ       @@gen_draw_one_pixel    ; Pixels left in this line?
  add       dx,@@offset             ; Offset to next line.
  dec       bh                      ; One line processed.
  jNZ       @@gen_draw_one_line     ; Was it the last one?

; One plane was processed, so create code which will change the map mask 
; and the register offset (bx) so that the datas wil then be written
; to the good plane. Then generate code for this plane.
@@gen_draw_plane_end:
  dec       cl                      ; One plane processed.
  jZ        @@gen_draw_end          ; Was it the last one?
; The following is the code for..  
;    shl ah,1     { Map mask for next plane. }
;    and ah,0fh   { Next plane is above the 3rd?}
;    jNZ +3       
;    mov ah,1     { Then back to plane 0. }
;    inc bx       { But one pixel on the right. }
  mov       dword ptr es:[di],0e480e4d0h      
  mov       dword ptr es:[di+4],0b403750fh
  mov       word ptr es:[di+8],4301h
  add       di,10
  jmp       @@gen_draw_one_plane    ; Process next plane.

; Well, everything is over, we just need to put the fatal 'retf'   
; at the end of the code and quit.
@@gen_draw_end:
  mov       byte ptr es:[di],0cbh   ; Opcode for 'retf'.
  inc       di
  pop dx
  pop cx
  pop bx
  pop ax
  ret

@@spr_w     db 0
@@spr_h     db 0
@@offset    dw 0

gen_sprite_drawing      ENDP
;============================================================================

INC_GEN_SPR             ENDS
; ***************************************************************************
