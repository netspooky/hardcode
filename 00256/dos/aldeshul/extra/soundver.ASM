;256 byte intro by Kuemmel
org 100h
use16

colour_start   = 44	;or 52	;or 95	31  44
colour_high    = 55	;   55	;   95	31  55
colour_low     = 32	;   32	;   56	16  32
colour_switch1 = 32 ;                   32 
colour_switch2 = colour_start 

init:
push 0a000h ;vga
pop fs
push 08000h ;second screen
pop ds
mov al,13h  ;mode 13, 320x200
int 10h

fninit					
fldz					 ;safety, crashes on freedos and xp without...

main_loop:
mov bp,text_data
mov bx,word[bp+36]	     ;get pseudo timer
shr bx,4				 ;time extract, okay in respect to vsync and cycles
and bx,0000000000011000b ;needed for different texts dependent on timer
add bp,bx			

mov ah,13h				; al = attribute (cursor fix=0), ah = 13h = write string
mov bl,byte[cs:colour]	; bl = foreground colour,	 bh = background colour (doesn't seem to work) !?
mov dx,(16 + 256*11)	; dl = x,			 dh = y position of text
mov cx,8				; cx = length of string
int 10h 				; plot string, attention: ES needs to be = CS ! ...so don't use ES elsewhere

;---get radius variation for zooming window
mov bp,sin_inc
fadd dword[bp]			;sin counter
fld  st0				;sin counter	 | sin counter
fsincos 				;sin(i) 		 | cos(i)			| sin counter		
fild  word[bp]			;r			 	 | sin(i)		| cos(i)		| sin counter
fmul  st2,st0			;r				 | sin(i)		| cos(i)*r		| sin counter	
fmulp st1,st0			;sin(i)*r		 | cos(i)*r			| sin counter
fistp word[bp+7]		;cos(i)*r		 | sin counter
fistp word[bp+9]		;sin counter	 | sin inc	

;assume di is zero
;---sin_zoomer
mov cx,320
xxyy_loop:
  xor  dx,dx			
  mov  ax,di   ;init divident with dx=0:ax=di
  div  cx      ;div dx:ax by 320 =>  dx = x | ax = y  slow but shorter overall...
  mov  bx,ax

  mov  si,word[bp+9]	  
  lea  si,[si+bx+12]	;6 (12) is y-offset that fits to sub by shift 4 (3)
  shr  ax,3				    
  sbb  si,ax
  imul si,cx		    ;y calculation done (new y = (y-y>>4) + yoffset * 320)

  mov  bx,dx
  add  si,word[bp+7]
  lea  si,[si+bx+20]	;10 (20) is x-offset that fits to sub by shift 4 (3)
  shr  dx,3			
  sbb  si,dx		    ;x calculation done (new x = (x-x>>4) + xoffset * 320)
  
  mov  al,byte[fs:si]
  
  dec  al				;colour range adjust from standard palette
  cmp  al,colour_low-1		
  jne  continue
    mov al,colour_high
  continue:
  
  mov  byte[ds:di],al		;plot
  inc  di
jnz xxyy_loop		    ;doesn't hurt to do 65536 pixels instead of 64000

;---init sound system
mov dx,0x331	
mov al,0x3F		
out dx,al					;change to UART mode
dec dx						;dec to data address
;---music
mov bl,byte[bp+4]
and bl,00011000b			;four to the floor :-)
cmp bl,byte[bp+11]			;timer increased ?
je dont_play_anything
  ;piano (initial instrument) melody
  mov al,10010000b	    	;Status byte 1001cccc | cccc = channel = 0
  out dx,al
    
  ;more like a happy melody kind of 
  ;shrd ax,bx,18 			;saves a byte, replaces mov al,bl / shr al,2
  ;add al,0x40				;adjust timer to a kind of melody

  ;some kind of a dark house techno tune using the offset counters as an input 
  mov al,byte[bp+10]		
  shl al,1				;shl al,2 sounds better
  add al,0x18			;or 0x20

  ;same dark house, bit more boring...
  ;shrd ax,bx,20
  ;add al,0x18
  
  out dx,al					;pitch = frequency, e.g. middle C is 60 (0...127)
  mov al,01111111b			;velocity, louder or softer...
  out dx,al
  ;drumset
  test bl,00001000b		;check beat step 0 and 2 
  jnz no_bass_drum
       mov byte[bp+6],colour_switch1	;adjsut colour on each bass drum
    mov al,0x99 	    
    out dx,al	
    mov al,35
    jmp finish_bass_drum	;saves 2 bytes
  no_bass_drum:
  jz no_clap			;check beat step 1 and 3 
       mov byte[bp+6],colour_switch2	;adjsut colour on each clap
    mov al,0x99 	    ;above 3 times...check later...
    out dx,al	
    mov al,39			;play clap on 1 and 3	
    finish_bass_drum:	
    out dx,al	
    mov al,01111111b	;velocity, louder or softer...
    out dx,al		    ;play bass drum on 0 and 2
  no_clap:
mov byte[bp+11],bl		;store counter for check if increased
dont_play_anything:

;vsync...
mov dx,3dah
vsync:
  in al,dx
  test al,8
jz vsync

inc word[bp+4]	 		;inc pseudo timer

;di is zero
copy_screen_loop:
  mov al,byte[ds:di]
  mov byte[fs:di],al
  inc di
jnz copy_screen_loop

;check keyboard 
key_loop:
in al,60h
  cmp al,1  ;ESC ?
jne main_loop
  ;mov ax,03h
  ;int 10h				;sorry, need the space
ret

text_data db '256 Byte'
		  db 0xfe,'is all',0xfe
		  db 'you need'
		  db 4 dup 0x02
		  db ' ;-)'

;"0xb1 = checkerboard pattern
;"0x0f = circular pattern
;"0xcd = double horizontal line
;"0xb3 = single horizontal line
;"0xba = double vertical line
;"0xfe = big central dot
;"0xdb = big block, also looks quite cool


sin_inc      dd 3e480006h		;is close to PI/16 and contains '6' as a word for the radius => saves two bytes
								;radius of block offset: 6 looks good, try others...
timer		 dw 0				;painful, but need an init to that counter for right start of text display...
colour		 db colour_start
x_offset	 dw 1 dup ?
y_offset	 dw 1 dup ?
timer_save	 dw 1 dup ?
