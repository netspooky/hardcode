;255 byte intro by Kuemmel for Outline 2015
org 100h
use16

max_bez_lines = 6   ;6 bezier lines
max_bez_dots  = 350 ;represented as dots per line...no space for a line algo
water_colour  = 55
;sand_colour   = 67  ;sand would cost extra 8 bytes...

init:
  push 0a000h ;vga
  pop es
  push 09000h ;vscreen
  pop fs
  mov al,13h  ;mode 13, 320x200
  int 10h

main_loop:

;copy routine for all bezier data
;from byte to word data for FPU access, saves some data bytes
mov di,bez_b
mov cl,(max_bez_lines*8)
L0:
  movzx ax,byte[di]				     ;get byte data and extend to word
  mov word[di+bx+(max_bez_lines*8)+4],ax ;save word data
  inc di
  inc bx ;bx is zero at start
loop L0

;init line dot stuff
mov di,coord		     ;could be replaced by add offset, but not shorter
mov bl,(max_bez_lines*16)

;animate tail and fin
fild  word[di-max_bez_lines*8*2-4]   ;get movement counter
fidiv word[di-max_bez_lines*8*2-2+4] ;reuse constants, div by 12
fsin							     ;sin animation
fimul word[di-max_bez_lines*8*2-2]   ;reuse constants, mul by 5 => proper animation
fistp word[di]
mov ax,word[di]
add word[di-max_bez_lines*8*2-2],ax			;line 1 x0
add word[di-max_bez_lines*8*2-2+ 4],ax		;line 1 x1
add word[di-max_bez_lines*8*2-2+16],ax		;line 2 x0
add word[di-max_bez_lines*8*2-2+32],ax		;line 3 x0
sal ax,1								;for fin multiply by 2
add word[di-max_bez_lines*8*2-2+64+10],ax	;line 5 y2
add word[di-max_bez_lines*8*2-2+64+14],ax	;line 5 y3

;bezier dot loops
L1:
  mov word[di-2],cx	    ;zero counter, cx is always zero here
  mov dx,max_bez_dots+1 ;dx = max_dots

  L2:
    fninit	          ;clear stack due to 'dirty' L3 loop, causes error on XP without
    fild  word[di-2]  ;get counter for fpu
    fidiv word[di-max_bez_lines*8*2-6]	;t = counter/max_dots
    fld1			  ;get 1.0
    fsub st0,st1	  ;at=1.0-t | t
    fld  st0		  ;at		| at | t
    fmul st0,st0	  ;at*at    | at | t
    fmul st0,st1	  ;at*at*at | at | t
    fld  st2		  ;t		| at*at*at | at | t
    fmul st0,st0	  ;t*t	    | at*at*at | at | t
    fmul st0,st3	  ;t*t*t    | at*at*at | at | t
    fild word[three+1];3	    | t*t*t    | at*at*at  | at | t
    fmul st0,st3	  ;3*at     ...
    fmul st0,st4	  ;3*at*t   ...
    fmul st3,st0	  ;3*at*t   | t*t*t    | at*at*at  | 3*at*at*t | t
    fmulp st4,st0	  ;t*t*t    | at*at*at | 3*at*at*t | 3*at*t*t
		      
    lea si,[di+bx-max_bez_lines*8*2-2-16] ; -16 for bx for zero check

    mov cl,4
    fldz
    fldz	       ;init ny | nx
    L3:
      fstp st6	       ;store latest nx,ny from iteration same position each time
      fstp st6	       ;b0     | b1	| b2 | b3     | ny     | nx
      fld  st0	       ;b0     | b0	| b1 | b2     | b3     | ny | nx
      fimul word[si+2] ;b0*sy  | b0	| b1 | b2     | b3     | ny | nx
      faddp st5,st0    ;b0     | b1	| b2 | b3     | ny_new | nx
      fimul word[si]   ;b0*sx  | b1	| b2 | b3     | ny_new | nx
      faddp st5,st0    ;b1     | b2	| b3 | ny_new | nx_new
      fld st4
      fld st4	       ;ny_new | nx_new | b1 | b2 | b3
      add si,4
    loop L3

    fistp word[di]	  ;get y
    imul si,word[di],320
    fadd st0,st0      ;two times x as base is byte data
    fistp word[di]	  ;get x

    add si,word[di]
    add si,word[di-max_bez_lines*8*2-4] ;add counter for x movement

    xor al,1	      ;fish colour animation
    mov byte[fs:si],al
	
    inc word[di-2]	  ;inc counter for FPU loop
	
    dec dx
  jnz L2

sub bl,16
jnz L1

inc word[di-max_bez_lines*8*2-4]  ;inc x movement counter
	
;no vsync this time to have more space for animation...
;mov dx,3dah
;vsync:
;  in al,dx
;  test al,8
;jz vsync

;screen switch and background colouring
xor di,di
switch_and_clear_screen:
  mov al,water_colour
  ;cmp di,(320*170)
  ;jb no_sand
  ;mov al,sand_colour
  ;no_sand:		 ;either have sand or a mouth, both 8 bytes ;-)
  xchg al,byte[fs:di]
  stosb
  cmp di,cx
jne switch_and_clear_screen

;check keyboard 
in al,60h
  cmp al,1  ;ESC ?
jne main_loop
  three:
  mov ax,03h  ;value 3 also used as constant for FPU routine
  int 10h
ret

bez_b	 db   5, 62, 12,135, 16,115, 14, 75 ;tail left side
	     db   5, 62, 92, 88, 30,  0, 60,148 ;body upper part
	     db  12,135, 92, 88, 30,198, 55, 28 ;body lower part
	     db  70, 75, 70, 75, 60, 65, 80, 65 ;eye
	     db  50, 95, 65, 95, 45,135, 30,135 ;fin
	     db  92, 88, 81, 90, 87, 93, 87, 93 ;mouth
max_dots dw max_bez_dots
movement dw 0 
bez_w	 dw max_bez_lines*8 dup ?
counter  dw 1 dup ?
coord	 dw 1 dup ?
