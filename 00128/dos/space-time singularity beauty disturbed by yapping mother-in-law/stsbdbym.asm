;- 'space-time singularity beauty disturbed by yapping mother-in-law' - a 128 byte intro by Kuemmel May/2017 for Outline demo party
org 100h
use16

push 0a000h ;vga
pop es
mov al,13h  ;mode 13, 320x200
int 10h

;---palette
ploop:
mov dx,0x3c8
out dx,al
inc dx
push ax
 shl al,1
 cmp al,63
 jb skip
   mov al,63
 skip:
 out dx,al
pop ax
out dx,al
out dx,al
inc ax
jnz ploop

;---constant_setup
mov bp,cons
mov cx,320
;fninit				;keep it clean ...or not...need the bytes ;-)
fld dword[bp]		;1/63

;---main_frame_loop
main_loop:
  cwd				;clear dx
  mov ax,di   		;init divident with dx=0:ax=di
  div cx      		;div dx:ax by 320 =>  dx = x | ax = y
  sub ax,100
  sub dx,160		;...so expensive...must be a shorter ay
  ; r = sqrt(x*x+y*y)/63
  ; a = atan(y/x) 
  ; s = sin(timer/63)*4+sin(12*a)
  ; colour = abs(sin(r*s))*63
  pusha
  fild  word[bx-4]	; ax = y			| 1/63
  fild  word[bx-8]	; dx = x	   		|  y	| 1/63
  fld	st0			; x					|  x	|	y	| 1/63
  fmul  st0,st0		; x*x				|  x	|	y	| 1/63
  fld	st2			; y					| x*x	|	y	| 1/63
  fmul  st0,st0		; y*y				| x*x	|   x	|	y	| 1/63
  faddp st1,st0		; x*x+y*y			|  x	|	y	| 1/63
  fsqrt				; r=sqrt(x*x+y*y)	|  x	|	y	| 1/63
  fmul  st0,st3		; r/63			    |  x    |   y	| 1/63
  fxch st2			; y					|  x    |   r	| 1/63
  fpatan			; a=atan(y/x)		|  r    | 1/63
  fimul word[bp]	; 12*a				|  r    | 1/63
  fsin				; s=sin(12*a)		|  r    | 1/63
  fild	word[bx-16]	; t=timer=si		|  s	|   r   | 1/63
  fmul  st0,st3		; t=t/63			|  s	|   r	| 1/63
  fsin 				; sin(t)			|  s	|   r	| 1/63
  fimul word[bp+4]	; sin(t)*4			|  s	|   r 	| 1/63
  faddp st1,st0		; s=s+sin(t)*4		|  r	| 1/63
  fmulp st1,st0		; r*s				| 1/63
  fsin				; cos(r*s) 			| 1/63
  fabs				; abs(cos(r*s))		| 1/63
  fdiv  st0,st1		; abs(cos(r*s))*63  | 1/63
  fistp word[bx-4]	; store colour at ax| 1/63
  popa
  stosb		
  dec di
  inc di			;saves a byte over mov byte[es:di],al / inc di
jnz main_loop       ;doesn't hurt to do 65536 pixels instead of 64000

inc si  			;inc 'timer'

out 42h,al			;pc speaker sound...try and error ;-)

;---check_keyboard 
in al,0x60			;check for ESC
dec al
out 61h,al		    ;pc speaker sound...try and error ;-)
jnz main_loop
nop 				;keep the 128 spirit ;-)
ret	

cons dd 3c82000ch	;is close to 1/63 and includes 0c = 12
	 dw 4			
			