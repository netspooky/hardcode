;- Function 2017 Invitro by Kümmel -
;assembled with flat assembler 1.71.58
org 100h
use16

;---init screen 320x200x256c
mov al,13h
int 10h

;---plot_string
mov ah,09h              ;print string to vga
mov dx,text	
int 21h        

;---setup
mov ax,0x7000			;clears also al for palette loop
mov fs,ax
mov ah,0xa0				;shorter than push/pop
mov gs,ax
push 08000h				;text screen				
pop es		

;---greyscale_palette
palette_loop:			;greyscale 0...63 on all planes...
mov dx,0x3c8
out dx,al
inc dx
out dx,al
out dx,al
out dx,al
inc ax
jnz palette_loop

;---resize text once and copy to buffer
xor si,si
y_loop:
  mov cl,160
  x_loop:
    lods byte[gs:si]		
	mov ah,al
	stosw
	mov word[es:di+318],ax
  loop x_loop
  add di,320
  add si,160
jns y_loop

;---setup
xor si,si				;clear global counter for text change and fade
;xor bx,bx				;clear bx for pusha fp loop- not needed, bx isn't touched
;fninit	   				;keep it clean ...or not if you need the bytes ;-)

;---grid_loop start is also main_loop
grid_loop:
	mov cx,320
	cwd					;clear dx
	mov ax,di   		;init divident with dx=0:ax=di
	div cx	     		;div dx:ax by 320 =>  dx = x | ax = y
	sub ax,99			;y = ax =  (y- 99)
	sub dx,149			;x = dx =  (x-159)
	
	;---movement effect
	mov bp,si			;get pseudo timer
	shr bp,2			;adjust speed
	and bp,111111b		;mask range
	sub ax,bp			;add timer offset to y
	sub dx,bp			;add timer offset to x => diagonal movement
	
	mov cx,12			;s% = grid size factor...could be changed over time...but I like it like that...

	pusha
	fild  word[bx-8]	;x=dx
	fidiv word[bx-6]	;x=x/s%
	fild  word[bx-4]	;y=ax		|x
	fidiv word[bx-6]	;y=y/s%		|x
	fld st1				;x			|y			|x
	fptan				;1			|tan(x)		|y			|x		;fptan creates also an additional '1'
	fstp st0			;tan(x)		|y			|x					;for some historic reasons...
	fsubrp st2,st0		;y			|tan(x)-x
	fld st0				;y			|y			|tan(x)-x
	fptan				;1			|tan(y)		|y			|tan(x)-x
	fstp st0			;tan(y)		|y			|tan(x)-x
	fsubrp st1,st0		;tan(y)-y	|tan(x)-x
	fmul st0,st0		;ty^2		|tan(x)-x
	fxch st1			;tan(x)-x	|ty^2
	fmul st0,st0		;tx^2		|ty^2
	faddp st1,st0		;tx^2+ty^2
	fsqrt				;sqrt(tx^2+ty^2)
	fldpi				;3.14...
	fmulp st1,st0		;3.14*sqrt(tx^2+ty^2)			;scale...pi just fits...(0.05*63=3.14)
	fistp word[bx-4]	;store colour
	popa

	;---darken effect	
	add ax,bp			;add add timer offset to colour...

	;---clamp overflow
	cmp ax,63
	jb no_overflow
		mov al,63
	no_overflow:
	
	cmp di,(320*32)
	ja no_text
		mov bp,si				;get pseudo timer
		shr bp,2				;adjust speed
		and bp,11000000b		;mask the 4 text lines...0...3
		imul bp,160				;(320*32/2^6) ...depends on darken/lighten range
		cmp byte[es:di+bp],0	;check text screen
		je no_text
			shr al,1			;some combo of fore and background for the text
	no_text:
	not al						;invert...looks better I think...
	mov byte[fs:di],al			;plot to second screen
	inc di
jnz grid_loop

;---wait vor vsync
mov dx,3dah				
vsync:
 in al,dx
 test al,8
jz vsync

;---plot screen
copy_screen:
	mov al,byte[fs:di]
	mov byte[gs:di],al
	inc di
jnz copy_screen

;---global counter
inc si	

;---check keyboard 
check_key:
in al,0x60			  	;check for ESC
dec al	
jnz grid_loop
ret

text db 10,' FUNCTION',10,10,13,' 8-10/9/17',10,10,13,' Budapest',10,10,13,' Join!$'