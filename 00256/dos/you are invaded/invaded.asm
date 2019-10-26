;- You are invaded - a 256 byte intro by Kuemmel Aug/2016 for Function 2016 demo party
;assembled with flat assembler 1.71.39
org 100h
use16

push 0a000h ;vga
pop es
push 08000h ;double buffering
pop fs
mov al,13h  ;mode 13, 320x200
int 10h

fninit				
fld1				;1				  

main_loop:
  mov si,all_data   

  mov cx,320
  xor dx,dx			
  mov ax,di   		;init divident with dx=0:ax=di
  div cx      		;div dx:ax by 320 =>  dx = x | ax = y
  
  mov cx,word[si]   ;movement counter for x and y and resize
  push cx			;backup for size => more smooth resize
  shr cx,4 			;speed adjust x/y movement
  adc dx,cx			;let it come in from the left
  ;adc ax,cx	    ;let it come in from the left top ...need the bytes...
  sub ax,100		;center y
  sub dx,160		;center x
  pop cx
  shl cx,5			;speed adjust resize
  add ch,0x18		;value defines final size of sphere
   
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
  fld   st0			;1-xx*xx+yy*yy |1-xx*xx+yy*yy |  x		   |	y	  |	  1
  fimul word[bx-6]	;mul by size of sphere helper to get some high signed integer
  fistp word[bx-8]	;save in dx for inside/outside check
  fabs				
  fsqrt
  fsubr st0,st3		;1-e			  | x		   |	y	  |   1
  fadd  st0,st3		;1+1-e			  | x		   |	y	  |   1
  fmul  st1,st0		;(2-e)			  |	x*(2-e)	   |    y	  |   1
  fmulp st2,st0		;x*(2-e)		  | y*(2-e)	   |    1	
  fistp word[bx-6]	;new x at cx
  fistp word[bx-4]	;new y at ay
  popa
  
  sub ax,bp				
  sub cx,bp			;x and y offset movement by counter
  
  and ax,11110b		;for 16 x 16 x 1 Bit Texture Mapper  1110b for double mapping adjust

  neg dx			;get sign => inside or outside sphere ?
  jns outside
    and cl,11110b
    shr cl,1		  			;double mapping size	
    mov dl,43		  			;"function" colour
    test word[si],1100110010b	;gives a flickerish transition to the evilboot
      jnz no_evilbot 			;texture change ?
      add si,32
	  mov dl,41                 ;"evilbot" colour
      dec dl
	no_evilbot:
	add si,ax      	  ;get ty 
	mov ax,word[si+2] 
	shr ax,cl		
	and al,1		  ;get tx
    mul dl			  ;finalize colour al = colour (dl) * 1 or * 0
	jmp done 
  outside:
  shr al,2  		
  add al,23	    	  ;or shr al,1 / adc al,15 ...but found it too darkish even it has double the greyscale levels...	
  done:
  mov byte[fs:di],al
  inc di			
jnz main_loop       ;doesn't hurt to do 65536 pixels instead of 64000

inc bp  			;inc global counter for rotation

cmp word[si],0
jz destination_reached
  dec word[si]
destination_reached:

;---vsync
mov dx,3dah	
vsync:
  in al,dx
  test al,8
jz vsync

;---double buffering
xor cx,cx
copy_screen_loop:
  mov al,byte[fs:di] 
  stosb
loop copy_screen_loop

;---check keyboard 
in al,0x60			  ;check for ESC
dec al
jnz main_loop
ret					  ;sorry, no bytes left for text mode init...	

all_data:
dw 800                ;animation counter
dw 0000010000000000b  ;"F"unction logo
dw 0000110000000000b
dw 0001111111111100b
dw 0001111111111100b
dw 0001111111111100b
dw 0000000001111000b
dw 0000000001111000b
dw 0011111111111000b
dw 0011111111111000b
dw 0011111111110000b
dw 0000000011110000b
dw 0000000011110000b
dw 0000000011110000b
dw 0000000111100000b
dw 0000000111100000b
dw 0000000111100000b
dw 0001000000010000b  ;evilbot logo
dw 0011111111111000b
dw 0110001110001100b
dw 0011000100011000b
dw 0001111111110000b
dw 0000111111100000b
dw 0001111111110000b
dw 0000111011100000b
dw 0001101010110000b
dw 0011101010111000b
dw 0110101010101100b
dw 1100101010101110b
dw 1100101010101010b
dw 0111101010111110b
dw 0001111111110000b
dw 0000000000000000b  
				  