;254 byte procedural graphics by Kuemmel
org 100h
use16

max_bez_lines	  = 11	;number of bezier lines
max_bez_dots	  = 512 ;lines represented as dots, try different settings...no space for a line algo
background_colour = 0	;background colour

init:
  push 0a000h ;vga
  pop es
  mov al,13h  ;mode 13, 320x200
  int 10h

;clear screen to background colour
mov al,background_colour
not cx ;=> ff00 as init is 00ff
rep stosb

;copy routine to copy all the bezier data
;from byte to word data for FPU access
mov si,bez_b
mov cl,(max_bez_lines*8)
L0:
  mov al,byte[si]
  mov word[si+bx+(max_bez_lines*8)+2+max_bez_lines],ax ;ah is zero at start
  inc si
  inc bx		    ;bx is zero at start
loop L0

xor bp,bp		    ;clear line colour index
mov si,coord
mov bl,(max_bez_lines*16)

L1:
  mov al,byte[si+bp-max_bez_lines*8*2-4-11] ;get line colour
  mov word[si-2],cx	      ;zero counter, cx is always zero here
  mov dx,max_bez_dots+1   ;dx = max_dots

  L2:
    fninit
    fild  word[si-2]  ;get counter for fpu
    fidiv word[si-max_bez_lines*8*2-4] ;t = counter/max_dots
    fld1		      ;get 1.0
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
		      
    lea di,[si+bx-max_bez_lines*8*2-2-16] ; -16 for bx for zero check

    mov cl,4
    fldz
    fldz	       ;init ny | nx
    L3:
      fstp st6	       ;store latest nx,ny from iteration same position each time
      fstp st6	       ;b0     | b1	| b2 | b3     | ny     | nx
      fld  st0	       ;b0     | b0	| b1 | b2     | b3     | ny | nx
      fimul word[di+2] ;b0*sy  | b0	| b1 | b2     | b3     | ny | nx
      faddp st5,st0    ;b0     | b1	| b2 | b3     | ny_new | nx
      fimul word[di]   ;b0*sx  | b1	| b2 | b3     | ny_new | nx
      faddp st5,st0    ;b1     | b2	| b3 | ny_new | nx_new
      fld st4
      fld st4	       ;ny_new | nx_new | b1 | b2     | b3
      add di,4
    loop L3

    fistp word[si]	  ;get y
    imul di,word[si],320
    fadd st0,st0      ;x is x*2 as bezier data is byte size  
    fistp word[si]	  ;get x
    add di,word[si]	  ;screen address is x + y * 320
    stosb			  ;write to screen

    inc word[si-2]	  ;inc counter for FPU
    dec dx
  jnz L2

inc bp	  ;inc line colour index
sub bl,16
jnz L1

L4:
  mov ah,01h  ;wait for keyboard
  int 16h
jz L4
  three:
  mov ax,03h  ;value 3 also used as constant for fpu routine
  int 10h
ret	      ;exit

;line data format is: start x,y | end x,y | control point 1 x,y | control point 2 x,y

bez_b	 db  69, 60, 69, 60, 49, 35, 89, 35 ;left eye
		 db  89, 60, 89, 60, 69, 35,109, 35 ;right eye
		 db  89, 99, 69,101,  0,  0,159,  0 ;head
		 db  87, 66, 69, 70, 79, 82, 79, 82 ;mouth
		 db 119,199, 59,199, 20, 60,139, 70 ;body
		 db  54, 40, 51, 59, 35, 30, 50, 30 ;left ear
		 db 104, 40,107, 59,124, 45,109, 35 ;right ear
		 db 115,130,109,118,159,140,139,160 ;right arm
		 db   0,180, 55,185, 20,160, 40,190 ;left ground
		 db 121,180,159,170,140,160,150,180 ;right ground
		 db  52,130, 56,118, 30, 40, 15, 60 ;left arm
colours  db  64, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75; colours for each line
max_dots dw max_bez_dots
bez_w	 dw max_bez_lines*8 dup ?
counter  dw 1 dup ?
coord	 dw 1 dup ?