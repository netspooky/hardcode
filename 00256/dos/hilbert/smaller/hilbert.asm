	org 100h
	use16

	   mov	al,12h		      ; set mode to 640x480x16
	   int	10h

;       mov [level+1],bx;x1
;       mov[level+3],bx;y1
;       mov[bp+4],bx;x2
;       mov[bp+6],bx;y2
r1 equ 5
r2 equ 0
       mov ax,r1*256+r2;si=r1.r2
       mov bl,7
;;       call hilbert

hilbert:
push si
 mov si,ax

;cuad 1
;If (level > 0)
;  Hilbert (r2,r1);
;EndIf
;  x2 =x2+r1
;  y2 =y2+r2;     // Nos desplazamos hacia la derecha (r1>0, r2=0)
;  LineXY(x1,y1,x2,y2,RGB(255,0,0));DIBClipLine (x1, y1, x2, y2, 0x0000FF, pMainDIB);  // Azul
;  x1 = x2
;  y1 = y2;
 dec bl
 jle endif1
 mov ax,si
 xchg ah,al
 call hilbert
endif1:
; mov [level+9],si
; movsx dx,byte [level+9];r1
; movsx cx,byte [level+10];r2

 call split_r1r2
 
 add [bp+4],dx;x2 =x2+r1
 add [bp+6],cx;y2 =y2+r2
 call linexy
; mov eax,[bp+4];x1=x2,y1=y2
; mov [level+1],eax

;cuad2
;If (level > 0)
;  Hilbert (r1,r2);
;EndIf
;  x2 =x2+ r2
;  y2 =y2+ r1;     // Nos desplazamos hacia abajo (r1>0, r2=0)
;  LineXY(x1,y1,x2,y2,RGB(255,0,0));DIBClipLine (x1, y1, x2, y2, 0x00FF00, pMainDIB);  // Verde
;  x1 = x2
;  y1 = y2;
 and bl,bl
 jle endif2
;; push si
;; mov si,r1*256+r2;r1.r2 for routine
 mov ax,si
 call hilbert
;; pop si
endif2:

 call split_r1r2
; mov [level+9],si
; movsx dx,byte [level+9];r1
; movsx cx,byte [level+10];r2

 add [bp+4],cx;x2 =x2+r2
 add [bp+6],dx;y2 =y2+r1
 call linexy
; mov eax,[bp+4];x1=x2,y1=y2
; mov [level+1],eax

;cuad3
;If (level > 0)
;  Hilbert (r1,r2);
;EndIf
;  x2 =x2- r1
;  y2 =y2- r2;     // Nos desplazamos hacia la izquierda (r1>0, r2=0)
;  LineXY(x1,y1,x2,y2,RGB(255,0,0));DIBClipLine (x1, y1, x2, y2, 0xFF0000, pMainDIB);  // Rojo
;  x1 = x2
;  y1 = y2;
 and bl,bl
 jle endif3
;; push si
;; mov si,r1*256+r2;r1.r2 for routine
 mov ax,si
 call hilbert
;; pop si
endif3:
; mov [level+9],si
; movsx dx,byte [level+9];r1
; movsx cx,byte [level+10];r2

 call split_r1r2
 sub [bp+4],dx;x2 =x2-r1
 sub [bp+6],cx;y2 =y2-r2
 call linexy
; mov eax,[bp+4];x1=x2,y1=y2
; mov [level+1],eax

;cuad4
;If (level > 0)
;  Hilbert (-r2,-r1); // Si no nos están depurando
;EndIf
;  level=level+1
 and bl,bl
 jle endif4
 mov ax,si
 xchg ah,al
 neg ah
 neg al
 call hilbert
endif4:
 inc bl;byte [level]
 pop si
split_r1r2:
 mov [bp+8],si;[level+9],si
 movsx dx,byte [bp+8];[level+9];r1
 movsx cx,byte [bp+9];[level+10];r2
 ret

linexy:
;AH = 0Ch
;BH = page number
;AL = pixel color
;if bit 7 set, value is XOR'ed onto screen except in 256-color modes
;CX = column
;DX = row

;x1=[bp]
;y1=[bp+2]
;x2=[bp+4]
;y2=[bp+6]
  mov DX,[bp+2];[level+3];y1
  mov CX,[bp];[level+1];x1
linelp:
  mov ax,0C0Fh
  sub BH,BH
  int 10h

  cmp cx,[bp+4];x2
  jz next_y
  jl x_less
  dec cx
  dec cx
x_less:
 inc cx
next_y:
  cmp cx,[bp+4];x2
  jne linelp

  cmp dx,[bp+6];y2
  je quitline
  jl y_less
  dec dx
  dec dx;jmp linelp
y_less:
 inc dx
 jmp linelp



quitline:
 mov eax,[bp+4];x1=x2,y1=y2
 mov [bp],eax;;[level+1],eax
 ret


;;int 20h
;-----------uservars:
;level: ;db 0;minus optimization
;word x1;level+1
;word y1
;word x2
;word y2
;temp(+9)