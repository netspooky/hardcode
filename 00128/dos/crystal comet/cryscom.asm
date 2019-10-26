;- Crystal Comet - a 128 byte intro by Kuemmel Apr/2016 for Outline demo party
org 100h
use16

push 0a000h ;vga
pop es
mov al,13h  ;mode 13, 320x200
int 10h

;fninit				;sorry need the two bytes...
fld1				;1				  

main_loop:
  mov cx,320
  xor dx,dx			
  mov ax,di   		;init divident with dx=0:ax=di
  div cx      		;div dx:ax by 320 =>  dx = x | ax = y

  mov cx,si			;get global counter
  and cl,11b		
  add al,cl			;add some kind of unstable movement to the comet (modify y)

  mov ch,0x76		;f=176, so f*f=176*176=0x7600 so 0x760? is almost the same, saves a byte
					;values defines size of sphere					
  pusha
  fild  word[bx-4]	;ax = y		   |  1		   
  fild  word[bx-8]	;dx = x		   |  y		   |	1	  
  fld   st1			;y		       |  x		   |	y	  |	  1	  
  fmul  st0,st0		;y*y		   |  x		   |	y	  |	  1	  	
  fld   st1			;x			   | y*y	   |	x	  |	  y   |	1	
  fmul  st0,st0		;x*x	       | y*y	   |    x	  |	  y	  |	1
  faddp st1,st0		;x*x+y*y	   |  x	  	   |	y	  |	  1
  fidiv word[bx-6]	;(x*x+y*y)/f*f |  x	  	   |	y	  |	  1
  fsubr st0,st3		;1-xx*xx+yy*yy |  x		   |	y	  |	  1	
  fabs				
  fsqrt 			;two sqrt's give a kind of a ray effect outside the sphere
  fsqrt 			;e=sqsq(abs(1-d)) |	x		   |	y	  |   1
  fsubr st0,st3		;1-e			  | x		   |	y	  |   1
  fadd  st0,st3		;1+1-e			  | x		   |	y	  |   1
  fmul  st1,st0		;(2-e)			  |	x*(2-e)	   |    y	  |   1
  fmulp st2,st0		;x*(2-e)		  | y*(2-e)	   |    1	
  fistp word[bx-8]	;new x at dx
  fistp word[bx-4]	;new y at ay
  popa
  sub ax,si				
  sub dx,si
  sub dx,si			;x and y offset movement by counter			
  xor al,dl			;the magic xor texture
  shr al,1			;use number to affect texture size
  and al,11111b		
  add al,56			;default is 56 for pastel colour base  
  stosb		
  dec di
  inc di			;saves a byte over mov byte[es:di],al / inc di
jnz main_loop       ;doesn't hurt to do 65536 pixels instead of 64000

inc si
inc si  			;inc movement counter

push ax				;back up tone					
mov dx,0x331	
mov al,0x3F		
out dx,al			;change to UART mode
dec dx				;dec to data address
mov al,11000000b	;instrument change code
out dx,al
mov al,98			;crystal sound for crystal comet
out dx,al
mov al,10010000b	;play tone code
out dx,al
pop ax				;restore tone
out dx,al			;use al from graphics for tone 
out dx,al			;...and volume

;push ax			;backup al
;mov al,11100000b	;pitch bend for more weirdness of sound
;out dx,al
;pop ax				;restore al for pitch bend values
;out dx,al
;out dx,al			;didn't use it as vibrate sounds cooler to me...

mov al,10110000b	;use midi controller
out dx,al
mov al,1		  	;vibrato level controller for more weirdness of sound
out dx,al
mov al,01111111b	;maximum vibrato hast best impact...
out dx,al

;---vsync...
;mov dx,3dah		;...need the space and doesn't help too much
;vsync:
;  in al,dx
;  test al,8
;jz vsync

;---check keyboard 
in al,0x60			; check for ESC
dec al
jnz main_loop
ret	

