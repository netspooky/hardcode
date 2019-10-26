;"there's an alien flying over my carpet!" a 256 byte intro for Function 2017 by Kuemmel
org 100h
use16
depth       =    4		;size of the thingy
add_y	    =    1		;=> only for background ! e.g. 1	...at the moment it's 1 and hardcoded to "inc bp"
add_y_jump  =   29		;=> only for background ! e.g. 30
f2_mult     =    6		;e.g. 15	 6	;defines twirlyness
f2_test     =   11b		;e.g. 11b  111b	;defines twirlyness

mov al,13h  	;mode 13, 320x200
int 10h
push 0a000h		;vga
pop fs
push 08000h 	;double buffer
pop es
;fninit			;keep it save...or not...					
mov si,constants

;---palette generation
palette:				;"borrowed" from kaleidoskop/3sc (2000)
    mov	dx,3c8h			;need only the two middle quarter sections
	mov	al,cl
	out	dx,al
	inc	dx
	shr	al,1
	out	dx,al
	mov	al,cl
	out	dx,al
	shr	al,2
	out	dx,al
loop palette

;---main intro loop
main_loop:
fldz               				;0				|u    		|t				|f2
fstp st3	       				;u   			|t 			|f2=0                                                     
mov ah,17*f2_mult  				;f2_loop counter		*6 => needs to fit later test ah,111b

	f2_loop:
	;---create_background
	push ax
	background_loop:		
	    mov ax,0xcccd		;rrrola's trick
		mul di				;=> dh = y | dl = x (range x = 0...255 ; y = 0...199)
		mov ax,bp
		shr al,2			;speed adjust
		add al,dh			;a = adjusted global counter + y
		xor al,dl			
		mul dl				;a = (y xor x) * x
		shr al,2			;affects size of squares
		and al,111b			;limit colours
		add al,64+25		;palette offset
		shr dl,3			
		shr dh,3
		add al,dl			;adjust colour from left to right
		sub al,dh			;adjust colour from top to down
		stosb
	loop background_loop
	pop ax

	;---floating point orgy jelly fish alien ;-)
								;st0			|st1		 |st2			|st3		 |st4|st5|st6
	fld dword[si]     			;pi/16			|u			 |t     		|f2
	fstp st2	        		;u    			|t=pi/16	 |f2  
	mov ch,16           		;=> 16 lines
	t_loop:                                                               
		fldz             	 	;0				|u 			 |t				|f2
		fstp st1	         	;u=0            |t			 |f2
		mov cl,255           	;=> 255 dots per line
		u_loop:
			pusha            	
			fld    st1		 	;t				|u     		 |t 			|f2
			fsincos				;cos(t)			|sin(t)		 |u				|t 			 |f2
			fld    st2			;u				|cos(t)		 |sin(t)		|u			 |t  |f2           
			fsqrt				;sq(u)			|cos(t)		 |sin(t)		|u			 |t  |f2
			fmul   st2,st0		;sq(u)			|cos(t)		 |sin(t)*sq(u)	|u			 |t  |f2
			fmulp  st1,st0		;cos(t)*sq(u)	|sin(t)*sq(u)|u				|t  		 |f2
			fld    st2			;u				|cos(t)*sq(u)|sin(t)*sq(u)	|u			 |t  |f2
			fmul   st0,st5		;u*f2			|cos(t)*sq(u)|sin(t)*sq(u)	|u			 |t  |f2  
			fsin				;sin(u*f2)		|cos(t)*sq(u)|sin(t)*sq(u)  |u			 |t  |f2 
			fidiv  word[si]		;sin(u*f2)/f1	|cos(t)*sq(u)|sin(t)*sq(u)	|u			 |t  |f2 
			fld1				;1				|sin(u*f2)/f1|cos(t)*sq(u)  |sin(t)*sq(u)|u	 |t  |f2 
			faddp  st1,st0		;1+sin(u*f2)/f1	|cos(t)*sq(u)|sin(t)*sq(u)	|u			 |t  |f2 
			fmulp  st1,st0		;x				|sin(t)*sq(u)|u				|t  		 |f2 
			fxch				;sin(t)*sq(u) 	|x  		 |u				|t  		 |f2 
			fiadd  word[si]		;z=z+z0			|x           |u				|t  		 |f2 	                                
			fidivr word[si+4]	;(d*f)/z 		|x           |u				|t  		 |f2                                     
			fist   word[bx-8]	;(d*f)/z		|x           |u				|t  		 |f2
			fld    st2			;u				|(d*f)/z	 |x           	|u			 |t  |f2
			fmul   st0,st1		;ys = u*(d*f)/z |(d*f)/z	 |x           	|u			 |t  |f2
			fistp  word[bx-18]	;(d*f)/z		|x           |u				|t  		 |f2
			fmulp  st1,st0		;xs = x*(d*f)/z |u			 |t  			|f2
			fistp  word[si+8]	;u				|t  		 |f2
			popa
			;store z in dx   	;with current constants z should be in the range of about 20...53 => * 4
			;store y in di
			;store x in mem as only bp is left and I need it for the offset 
			imul di,320					
			add  di,320*10+159					;add offset for positioning
			add  di,word[si+8]					;add x

			add  dl,128							;palette adjust
			mov  dh,dl							;dh=dl	;store two times => more fat!

			cmp byte[es:di],dl 					;check if pixel is already there with a higher colour (z)
			ja dont_draw
				mov word[es:di],dx		
			dont_draw:                                                  

			add di,-12+320*10					;shadow offset
			
			test word[es:di],128+128*256		;check if shadow is under
			jnz dont_draw_shadow
				sub word[es:di],0x0303			;fake shadow generation
			dont_draw_shadow:
				
			fadd dword[si+4]	;u+PI/256		|t			|f2
		dec cl
		jnz u_loop
                                              
		fld   dword[si]			;PI/16			|u			|t 				|f2
		fadd  st0,st0			;2*PI/16 ...better and saves a constant
		faddp st2,st0			;u				|t+PI/8  	|f2
 
	dec ch
	jnz t_loop
            
	test ah,f2_test
	jne skip_add
				
	fld dword[si]				;PI/16 			|u			|t				|f2           
	faddp st3,st0				;u				|t			|f2+PI/8
	skip_add:
	
	;---vsync
	mov dx,3dah
	vsync1:
	in al,dx
	test al,8
	jz vsync1

	;---copy screen
	xor di,di
	copy_screen:
		mov al,byte[es:di]
		mov byte[fs:di],al
		inc di
	jnz copy_screen

	dec bp				;offset for normal vertical movement
	
dec ah
jnz f2_loop

sub bp,add_y_jump		;different offset after f2_loop to do some kind of "jump"

;---check keyboard 
in al,0x60			  	;check for ESC
dec ax					;ah is zero
jnz main_loop
mov al,03h				;got the bytes left...ah is zero
int 10h
ret
               
constants	dw depth,0x3e49 ;0.19628906  = 0x3e490000 (almost PI/16)  and 0000 = z0 'depth') ...saves 2 bytes = 1 single + 1 word
			dw 120,  0x3c49 ;0.012268066 = 0x3c490000 (almost PI/256) and 0000 = d*f)        ...saves 2 bytes = 1 single + 1 word
