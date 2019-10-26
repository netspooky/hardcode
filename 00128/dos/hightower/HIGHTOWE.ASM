; Created by: HighTower of Miranda
; E-mail      hightower@antisocial.com
; Date:       97-08-27
; Size:       113 Bytes
; Compiler:   TASM 3.2, TLINK 5.1
;                tasm /m2 blob
;                tlink /t blob
;
.286
CODE     SEGMENT
			ASSUME   CS:CODE, DS:CODE
			org 100h
			_size equ 31
Start:
   mov   al,13h
	int   10h

   xor   ax,ax
	mov   dx,3c8h
   out   dx,al
	inc   dx

palette:
   mov   al,bl
   shr   al,1
	out   dx,al
	out   dx,al
	out   dx,al

   inc   bx
   cmp   bl,127
   jne   palette
palette2:
   mov   al,bl
   shr   al,1
   out   dx,al
	out   dx,al
	out   dx,al

   dec   bx
   jnz   palette2

   push  0a000h
   pop   es

   inc   bx       ;y
   mov   si,bx    ;x
   mov   bp,bx    ;y

restart:
;---------------- X ----------------

	add   cx,si
   jnz   x1
	neg   si
x1:
	cmp   cx,312-_size
   jl    x2
	neg   si
x2:
;---------------- Y ----------------
	add   bx,bp
   jnz   y1
	neg   bp
y1:
	cmp   bx,199-_size
   jl    y2
	neg   bp
y2:
;-----------------------------------
	mov   ax,320
   mul   bx
	add   ax,cx
	mov   di,ax

	mov   dh,_size
   yp:
	mov   dl,_size
      xp:
      mov   al,es:[di]
      inc   ax
      stosb
      dec   dl
      jnz   xp
	add   di,320-_size
	dec   dh
	jnz   yp

;-----------------------------------
	mov   ah,1
	int   16h
	jz    restart

mov      ax,3
int      10h
ret
CODE    ENDS
END     Start
