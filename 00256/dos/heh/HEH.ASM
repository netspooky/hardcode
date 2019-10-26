     ;**********************************;   
     ;*-'Heh' 256b demo, By: ]AnimaL] -*; 
     ;*-Tested with Masm 6.11 & Tasm 5-*; 
     ;*-Email: animal@techie.com      -*;       
     ;*-IRC: Efnet, #asm              -*; 
     ;*-Source is freely distributable-*; 
     ;**********************************;  

    code segment                   ;
    assume cs:code,ds:code,es:code ;Start a 64k segment.
    org 100h                       ;
start:
     mov  al,13h                   ;
     int  10h                      ;Switch to 320x200.
     mov  ax,0a000h                ;
     mov  es,ax
     mov  di,320+20
MainLoop:
     push di                       ;Save position.
     mov  si,offset bitmap         ;Point si to bitmap.
     mov  dl,10                    ;Bitmap Height loop.
BitmapLoop:
     mov  cl,8                     ;Bitmap Width. (in bytes)
   This8times:
     mov  bh,10000000b             ;Bitmask. 
     mov  bl,8                     ;Byte width (in bits)
   for_byte:
     mov  ah,byte ptr [si]         ;Grab bits 1 by 1 and
     and  ah,bh                    ;..test them.
     jnz  ItsNotZero               ;if not 0 then RED
     add  di,3                     ;Compensate for lossage.
   backhere:
     ror  bh,1                     ;Get the next bit in position.
     dec  bl                       ;For rotate bits loop.
     jnz  for_byte                 
     jmp  skipbelow
ItsNotZero:                        
     mov  al,04                    ; If the bit isn't 0 then
     stosb                         ;..it's red.. 3 horizontal
     stosb                         ;..red pixels.
     stosb                         
     jmp  backhere
skipbelow:                        
     inc  si                       ;For Bitmap Width.
     loop this8times               

     add  di,320-64*3              ;Next line. 
     dec  dl                       
     jnz  BitmapLoop               ;For Bitmap Height.
     pop  di                       ;Restore position.
     call WaitVrt                  ;Wait for vsync.

     cmp  di,320*100               ;Test bitmap coord.
     jg   NoMoreRaise              ;If at middle, scroll vertical.
     sub  di,640*2+3               ;Else scroll up and right.

   NoMoreRaise:
     inc  di                       
                                   
     call FreakScreen              ;Do something rather strange.

     mov  ah,1        
     int  16h
     jz   MainLoop                 ;wait for keypress
     dec  ah                        
     int  16h         

     xor  di,di                    
     mov  ah,100                   ; 
   exiting:                        ;Clear the screen red on 
     mov  al,04h                   ;ESC.
     mov  cx,640                   ;
     rep  stosb                    
     call waitvrt                  
     dec  ah                       
     jnz  exiting                  
                                   ;
     mov  al,03h                   ;Switch back to textmode.
     int  10h                      ;
     xor  di,di
     mov  ax,0b803h                ;
     mov  es,ax                    ;Say something important.
     mov  si,offset Wuzzup         ;

     mov  cl,22
   blahblah:
     movsb                         ;
     mov  al,04h                   ;Make the color weird.
     stosb                         ;
     loop blahblah

exit:     ret


WaitVrt proc near
     mov   dx,3dah                 ;
    vrt:                           ;
     in    al,dx                   ;vsync routine
     test  al,8                    ;
     jnz   vrt                     ;
    novrt:
     in    al,dx
     test  al,8
     jz    novrt
    ret                         
WaitVrt endp

Wuzzup db 176,177,178," ]AnimaL]: Heh. ",178,177,176 ;VERY IMPORTANT!

FreakScreen proc near
     push  di                       
     xor   di,di                   ;
     in    al,40h                  ;A routine to make the
     mov   cx,320*200              ;screen look like it's on
     rep   stosb                   ;drugs.
     pop   di                      ;
     ret
FreakScreen endp


    ;Byte#    1         2         3         4         5         6         7         8         
bitmap db 01010011b,11011110b,10001000b,11101000b,10100010b,11110000b,01011101b,11010101b   
       db 01010010b,01010010b,11011000b,10101000b,10110010b,10010000b,01010101b,01010101b
       db 01010010b,01010010b,11111000b,10101000b,10110010b,10010000b,00010101b,01010101b
       db 11111010b,01010000b,10101000b,10101000b,10101010b,00100000b,01010101b,01010101b
       db 11111011b,11011110b,10101000b,10101000b,10101010b,00100000b,01010101b,01010101b
       db 01010011b,11001110b,10001000b,10101010b,10101010b,01000000b,01010101b,01010101b
       db 11111010b,01000010b,10001000b,10101010b,10101010b,01000000b,01010101b,01010101b
       db 11111010b,01010010b,10001000b,10101111b,10100110b,10010001b,01010101b,01000000b
       db 01010010b,01011110b,10001000b,11101101b,10100110b,11110001b,01011101b,11010101b
       db 01010010b,01011110b,10001000b,11101000b,10100010b,11110001b,11011101b,11010101b
code ends
end start




