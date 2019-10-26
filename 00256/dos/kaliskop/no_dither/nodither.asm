;"Kaliskop" - a Kaliset fractal 256 Byte intro by Kümmel / 2nd of Nov 2016
;> no dithering version <
;fractal formula by Kali based on http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns/
;x=abs(x)
;y=abs(y)
;m=x*x+y*y
;x=x/m+cx
;y=y/m+cy

org 100h
use16

init:
push 0a000h ;vga
pop es
push 08000h ;double buffering
pop fs
mov al,13h  ;mode 13, 320x200
int 10h

fninit
mov si,all_data
xor bp,bp		;clear global counter

;---palette
salc			;clear al (if no carry)
mov dx,0x3c8
out dx,al
inc dx
abs:
	mov al,cl
	and al,127	;0...127
	sub al,64	;-64...63
	cbw
	xor al,ah
	sub al,ah	;64...0...63 = calc abs
	cmp al,64			
	jne next
		dec ax	;capture overflow...no way to do that shorter !???
	next:
	out dx,al	; = 63...0...63	
	out dx,al
	shr al,1
	out dx,al
loop abs

;---main intro loop
main_loop:

;create_zoom_in_zoom_out_counter
mov ax,bp	;get global counter
and ax,511	;0...511
sub ax,256	;-256...0...255
cwd
xor ax,dx
sub ax,dx	; 256...0...255 = calc abs	
sub ax,256	; ax = 0...-256...-1	
push ax
fild word[bx-4]
fidiv word[si+6] ;cxy = 0...-254...0 (ax) / divcorrec
pop ax

;assume at init di=fffe, bx is zero
mov cx,320
xy_loop:
	xor  dx,dx			;'cwd' works also...if ax is not negative...
	mov  ax,di   		;init divident with dx=0:ax=di
	div  cx			  	;div dx:ax by 320 =>  dx = x | ax = y
	sub  dx,word[si+2]	;x...-160...+160		...skip this also looks cool
	sub  ax,word[si]	;y...-100...+100		...skip this also looks cool
	
						;st0			|st1			|	st2		|	st3		|	st4		|	st5		|	st6		|	st7
	pusha
	fild  word[si+4]	;mult			|cxy
	fldz				;c=0			|mult			|	cxy
	fild  word[bx-4]	;y				|c				|	mult	|	cxy			
	fidiv word[si]		;y/100			|c				|	mult	|	cxy
	fild  word[bx-8]	;x				|y				|	c		|	mult	|	cxy
	fidiv word[si+2]	;x/160			|y				|	c		|	mult	|	cxy

	mov ax,bp
	shr ax,9
	and al,7
	add al,3	;3...10
	iter_loop:
		fld	  st0		;x				|x				|	y		|	c		|	mult	|	cxy
		fmul  st0,st0	;x*x			|x				|	y		|	c		|	mult	|	cxy
		fld   st2		;y				|x*x			|	x		|	y		|	c		|	mult	|	cxy
		fmul  st0,st0	;y*y			|x*x			|	x		|	y		|	c		|	mult	|	cxy
		faddp st1,st0	;x*x+y*y		|x				|	y		|	c		|	mult	|	cxy
		fdiv  st1,st0	;m				|x/m			|	y		|	c		|	mult	|	cxy
		fdiv  st2,st0	;m				|x/m			|	y/m		|	c		|	mult	|	cxy
		faddp st3,st0	;x/m			|y/m			|	c=c+m	|	mult	|	cxy
		fabs  			;abs(x/m)		|y/m			|	c		|	mult	|	cxy
		fadd  st0,st4	;abs(x/m)+cxy	|y/m			|	c		|	mult	|	cxy
		fxch			;y/m			|abs(x/m)+cxy	|	c 		|	mult	|	cxy
		fabs  			;abs(y/m)		|abs(x/m)+cxy	|	c		|	mult	|	cxy
		fadd  st0,st4	;abs(y/m)+cxy	|abs(x/m)+cxy	|	c		|	mult	|	cxy
		;fxch			;abs(x/m)+cxy	|abs(y/m)+cxy	|	c		|	mult	|	cxy		=> can be skipped due to the algorithm !
	dec ax
	jnz iter_loop
	
	fcompp				;c			|	mult	|	cxy		=> no need for x,y any more...	
	fyl2x				;mult*ln(c)	|	cxy					=> colour adjust by ln2
	fistp	 word[bx-4]	;cxy								=> store colour in ax
	popa

	cmp ax,0xfe
	jbe	no_change
    	mov al,0xfe		;clamp colours to max (0xfe as it saves a byte in the palette generation...loop cx)
	no_change:
	mov byte[fs:di],al
	inc di				;high spec non dithering version
jnz xy_loop		 		;high spec non dithering version

fcomp	;delete cxy

;---vsync
mov dx,3dah	
vsync:
  in al,dx
  test al,8
jz vsync

;---double buffering
xor cx,cx
backbuffer:
  mov al,byte[fs:di] 
  stosb
loop backbuffer

;---sound
mov dx,0x331	
mov al,0x3F		
out dx,al			;change to UART mode
dec dx				;dec to data address

mov al,11000000b	;instrument change code
out dx,al
mov al,12			;Marimba
out dx,al

test bp,1111b		;base_tone_trigger
jnz dont_change_base_tone
mov cl,9
threesome:
	mov al,10010000b	;play tone code
	out dx,al
	mov al,byte[es:di+79]
	and al,111111b		;limit impact from pseudo random
	add al,33			;C1=36, C2=48 or C3=60 as base
	add al,cl			;threesome => +3 +6 +9
	out dx,al			 
	mov al,50			;not that loud...it's annoying anyway ;-)
	out dx,al
sub cl,3
jnz threesome

dont_change_base_tone:
mov al,10110000b	;...change vibrato level
out dx,al
mov al,1
out dx,al
mov al,01111111b
out dx,al

;---counter stuff
inc bp 	;inc global counter

;---check keyboard 
key_loop:
in al,60h
dec al
jnz main_loop
mov ax,03h		;skip if bytes needed
int 10h		
ret

all_data:
norm_y		dw	100				;+0
norm_x		dw	160				;+2
mult		dw	30				;+4		;makes everything "lighter" if higher
divcorrec	dw	180				;+6
