.386p
.model tiny

SCREEN_WIDTH = 96            ; Width of the screen buffer
SCREEN_HEIGHT = 128           ; Height of the screen buffer

PROGRAM_SIZE = 0140H                      ; Size of the program
BUFFER_OFFSET = PROGRAM_SIZE+0100H        ; Offset of screen buffer
BUFFER_SIZE = SCREEN_WIDTH*SCREEN_HEIGHT  ; Size of screen buffer

_TEXT segment USE16
assume cs:_TEXT

org 0100H                     ; We have to make this a .COM executable

start_of_code:                ; Start line...

   ; Set up copy direction

   cld                        ; We're going to use MOVSx and STOSx

   ; Set video mode 13H

   mov   ax, 13H
   int   10H

   ; Set palette
   ; 0 - 31 = black -> red
   ; 32 - 63 = red -> yellow

palette_set:
   mov   dx,03c8H             ; Let's start from color 0...
   xor   ax,ax
   mov   gs, ax               ; Initialize GS now that we have a correct
                              ; value in AX (You have to save bytes :)
   out   dx,al
   mov   dx,03c9H             ; ...and set the palette we want

   ; Varit 0-31

   xor   ah,ah                ; AH is red component (G, B = 0)

   palette_loop1:
      mov   al,ah
      out   dx,al
      xor   al,al
      out   dx,al
      out   dx,al
      add   ah,2
      cmp   ah,64             ; Have we set red values already?
      jb    palette_loop1

   ; Varit 32-63 (punainen-keltainen)

   xor   ah,ah                ; AH is green component (R = 63, B = 0)

   palette_loop2:
      mov   al,63
      out   dx,al
      mov   al,ah
      out   dx,al
      xor   al,al
      out   dx,al
      add   ah,2
      cmp   ah,64             ; Have we set all the red->yellow values?
      jb    short palette_loop2

   ; Setup segment registers and clear buffer

setup_segments:
   mov   ax,cs                ; To clear buffer we set ES = CS
   mov   es,ax
   mov   ds,ax                ; We use DS as data pointer to CS
   mov   di,BUFFER_OFFSET     ; DI -> screen buffer
   xor   ax,ax                ; AX = 0
   mov   cx,BUFFER_SIZE/2     ; Let's clear buffer 2 bytes at time
   rep   stosw
   mov   ax,0a000H            ; ES -> VGA buffer
   mov   es,ax

   ; Set BP to be "random number" generator

   xor   bp, bp               ; We use CS:[BP] as a random number :)
                              ; (0100H <= BP < 0200H, but we start from
                              ; zero because it saves a byte)

   ; Update buffer

update_buffer:
   mov   cx, SCREEN_WIDTH*(SCREEN_HEIGHT-4)  ; Number of bytes to update
   mov   si, BUFFER_OFFSET+SCREEN_WIDTH      ; Offset of first byte
   update_loop:
      push  si
      mov   bx, cs:[bp]       ; BX = "random number"
      inc   bp                ; BP++
      cmp   bp, 501           ; if(BP>500) BP=0100H
                              ; We don't use 512 because it would be
                              ; divisible with screen width
      jb    short continue_update

      mov   bp, 0100h

   continue_update:
;      and   bx,514           ; If we uncomment these and comment next
;      sub   bx,257           ; two lines we have +-1 change in X-coordinate
                              ; _AND_ in Y-coordinate

      and   bx,2              ; We calculate the fire using the old
      sub   bx,1              ; add and divide method but we use "random"
      add   si,bx             ; +-1 change in X-coordinate
      mov   al,byte ptr ds:[si]
      add   al,byte ptr ds:[si+SCREEN_WIDTH-1]
      add   al,byte ptr ds:[si+SCREEN_WIDTH]
      add   al,byte ptr ds:[si+SCREEN_WIDTH+1]

      sub   al, 4             ; Let's make the flames a bit shorter
      jnc   divide_slot       ; Check that the value didn't underflow
      xor   al,al             ; If it did, let it be 0

   divide_slot:
      shr   al,2
      pop   si
      mov   ds:[si], al
      inc   si
      dec   cx
      jnz   update_loop

   ; Blit from memory to screen.
   ; Yeah... It would be faster to calculate the effect without
   ; any buffers in video memory but I coded this on my 386DX25 and
   ; it would have been too slow for that

blit_buffer:
   mov   di,(320-SCREEN_WIDTH)/2+(200-SCREEN_HEIGHT)/2*320
   mov   si,BUFFER_OFFSET
   mov   ax,SCREEN_HEIGHT

   blit_loop:
      mov   cx, SCREEN_WIDTH/4
      rep   movsd
      add   di, 320-SCREEN_WIDTH   ; We don't need this line if the width
                                    ; of the buffer is 320
      dec   ax
      jnz   short blit_loop

   ; Modify buffer

modify_buffer:

   ; Draw arrow to screen

   mov   di, SCREEN_WIDTH*28+BUFFER_OFFSET+SCREEN_WIDTH/2
   mov   cx, 42+54

   ; Calculate scaling factor

   mov   bx, gs               ; Increase scaling factor
   inc   bx
   and   bx, 127              ; if(BX == 128) BX=0
   mov   gs, bx

   cmp   bl, 64               ; if(BL >= 64) BL=127-BL
   jb    short draw_arrow_line

   mov   al, 127
   sub   al, bl
   mov   bl, al

   draw_arrow_line:
      push  di
      inc   bh
      mov   al, bh            ; AX = width of the figure on this line
      cmp   bh, 42
      jbe   short skip_arrow
      mov   al, 10

   skip_arrow:

      ; Scale width of the arrow

      mul   bl                ; Scale AL (AL = AL*BL/64)
      shr   ax, 6
      inc   ax                ; Make sure that AX > 0

      sub   di, ax            ; Calculate start offset of fill
      shl   ax, 1             ; Calculate width of fill

      ; Here we do the actual figure filling

      draw_arrow_loop:
         mov   byte ptr ds:[di], 63
         inc   di
         dec   ax
         jnz   short draw_arrow_loop

      pop   di
      add   di, SCREEN_WIDTH
      dec   cx
      jnz   short draw_arrow_line

   ; Loop until one tick passed

   mov   bx, dx
   modify_loop:
      xor   ah,ah
      int   1aH
      cmp   bx, dx
      je    short modify_loop

end_modify:

   ; Check for key press

check_keyboard:
   inc   ah
   int   16H
   jz    short update_buffer

   ; Set video mode 03H and exit proram

exit_fire:
   mov   ax, 03H
   int   10H
   mov   ax, 4c00H            ; Notice, CLEAN EXIT! :)
   int   21H

   ; Stack and data area

end_of_code:

_TEXT ends

end start_of_code

