;"AldeShul" - a 256 byte intro by Kuemmel for Function 2015
org 100h
use16

colour_start   = 44	;or 52	;or 95	31  44
colour_high    = 55	;   55	;   95	31  55
colour_low     = 32	;   32	;   56	16  32
colour_liss    = 42

init:
push 0a000h ;vga
pop fs
push 08000h ;second screen
pop ds
mov al,13h  ;mode 13, 320x200
int 10h

fninit					
fldz		;safety, crashes on freedos and xp without...

main_loop:

;---draw text and lissajou dependent on integer timer running via vsync...
mov bp,text_data
mov bx,word[bp+36]	     ;get pseudo timer
shr bx,4				 ;time extract in respect to vsync
and bx,0000000000011000b ;needed for different texts dependent on timer
mov dx,bx
shr dx,3
add dx,1
mov word[bp+32+14],dx	 ;preserve lissajou variation from 1...4

;---draw text
add bp,bx				 ;text int needs pointer in bp
mov ax,01300h			 ;al = attribute (cursor fix=0), ah = 13h = write string
mov bl,colour_start		 ;bl = foreground colour,	 	 bh = background colour (doesn't seem to work) !?
mov dx,(16+256*11)   	 ;dl = x,			         	 dh = y position of text
mov cx,8				 ;cx = length of string
int 10h 				 ;plot string, attention: ES needs to be = CS ! ...so don't use ES elsewhere or save it

;---draw lissajou order (1...4):(1)
mov bp,sin_inc
mov cx,255				
fild word[bp-199]        ; = 8 (attention when you change the code !!!)	
fldz					 ;          t=0 |	r=8	|	sin counter
lissajou:
  fld st0					 		
  fild word[bp+14]		 ;           li |   t   |  t	|	r	|	sin counter 
  fmul st0,st2			 ;         li*t |   t   |  t	|	r	|	sin counter 
  fadd st0,st4			 ;      li*t+tt |   t   |  t	|	r	|	sin counter
  fsin					 ;  SIN(li*t+tt)|   t   |  t	|	r	|	sin counter
  fmul	st0,st3			 ;r*SIN(li*t+tt)|   t   |  t	|	r	|	sin counter
  fistp word[bp+10]		 ;   		  t |   t	|  r	|	sin counter
  fcos					 ;	      COS(t)|	t	|  r	|	sin counter
  fmul	st0,st2			 ;      r*COS(t)|	t	|  r	|	sin counter
  fistp word[bp+12]		 ;            t	|   r	| sin counter
  fadd	dword[bp]		 ;      t+PI/16 |   r	| sin counter
  imul	bx,word[bp+10],320
  add	bx,word[bp+12]
  mov	byte[fs:bx+32160+320*8],colour_liss
loop lissajou
fcompp					 ; clear first two float's

;---get radius variation for zooming window
fadd dword[bp]			;sin inc
fld  st0				;sin counter	 | sin inc
fsincos 				;sin(i) 		 | cos(i)		| sin counter		
fild  word[bp]			;r			 	 | sin(i)		| cos(i)		| sin counter
fmul  st2,st0			;r				 | sin(i)		| cos(i)*r		| sin counter	
fmulp st1,st0			;sin(i)*r		 | cos(i)*r		| sin counter
fistp word[bp+6]		;cos(i)*r		 | sin counter
fistp word[bp+8]		;sin counter	 | sin inc	

;---sinus feedback zoomer
;assume di is zero
mov cx,320
xxyy_loop:
  xor  dx,dx			
  mov  ax,di   			;init divident with dx=0:ax=di
  div  cx      			;div dx:ax by 320 =>  dx = x | ax = y  slow but shorter overall...
  mov  bx,ax

  mov  si,word[bp+8]	  
  lea  si,[si+bx+12]	;12 or 6 is y-offset that fits to sub by shift 3 or 4
  shr  ax,3				    
  sbb  si,ax
  imul si,cx		    ;y calculation done (new y = (y-y>>3) + yoffset * 320)

  mov  bx,dx
  add  si,word[bp+6]
  lea  si,[si+bx+20]	;20 or 10 is x-offset that fits to sub by shift 3 or 4
  shr  dx,3			
  sbb  si,dx		    ;x calculation done (new x = (x-x>>3) + xoffset * 320)
  
  mov  al,byte[fs:si]   ;get old pixel
  
  dec  al				;colour range adjust from standard palette
  cmp  al,colour_low-1		
  jne  continue
    mov al,colour_high
  continue:
  
  mov  byte[ds:di],al	;plot new pixel to second screen
  inc  di
jnz xxyy_loop		    ;doesn't hurt to do 65536 pixels instead of 64000

;---vsync...
mov dx,3dah
vsync:
  in al,dx
  test al,8
jz vsync

inc word[bp+4]			;inc pseudo timer

;---copy second screen to vga...
;di is zero
copy_screen_loop:
  mov al,byte[ds:di]
  mov byte[fs:di],al
  inc di
jnz copy_screen_loop

;---check keyboard 
key_loop:
in al,60h
  cmp al,1  ;ESC ?
jne main_loop
  mov ax,03h
  int 10h
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

sin_inc      dd 3e480007h		;is close to PI/16 and contains '7' as a word for the radius => saves two bytes
								;radius of block offset: 6 or 7 look good, try others...
timer		 dw 0				;painful, but need an init to that counter for correct start of text display...
x_offset	 dw 1 dup ?
y_offset	 dw 1 dup ?
x_liss		 dw 1 dup ?
y_liss	     dw 1 dup ?
save_liss	 dw 1 dup ?