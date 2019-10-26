	org 100h
	use16

	   mov	al,12h		      ; set mode to 640x480x16
	   int	10h

       mov [cs:level+1],bx;x1
       mov[cs:level+3],bx;y1
       mov[cs:level+5],bx;x2
       mov[cs:level+7],bx;y2
r1 equ 5
r2 equ 0
       mov si,r1*256+r2;si=r1.r2
       mov bl,7;;2+1
       call hilbert
;;wa:jmp wa
;; ret
linexy:
;AH = 0Ch
;BH = page number
;AL = pixel color
;if bit 7 set, value is XOR'ed onto screen except in 256-color modes
;CX = column
;DX = row
;; hlt
 pusha
  mov DX,[cs:level+3];y1
  mov CX,[cs:level+1];x1
linelp:
  mov ax,0C0Fh
  sub BH,BH
  int 10h

  cmp cx,[cs:level+5];x2
  jz next_y
  jl x_less
  dec cx
  dec cx
x_less:
 inc cx
next_y:
  cmp cx,[cs:level+5];x2
  jne linelp

  cmp dx,[cs:level+7];y2
  je quitline
  jl y_less
  dec dx
  dec dx;jmp linelp
y_less:
 inc dx
; cmp cx,[cs:level+5];x2
; jne linelp
; cmp dx,[cs:level+7];x2
;
; jne linelp
 jmp linelp



quitline:
 popa
 mov eax,[cs:level+5];x1=x2,y1=y2
 mov [cs:level+1],eax
 ret
 
 
 
 
 
 
 
 
 
 
 
 
 
hilbert:
; hlt

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
 and bl,bl
 jle endif1
 push si
 ;;mov si,r2*256+r1;r1.r2 for routine
 mov ax,si
 xchg ah,al
 mov si,ax
 call hilbert
 pop si
endif1:
 mov [cs:level+9],si
 movsx dx,byte [cs:level+9];r1
 movsx cx,byte [cs:level+10];r2
 add [cs:level+5],dx;x2 =x2+r1
 add [cs:level+7],cx;y2 =y2+r2
 call linexy
; mov eax,[cs:level+5];x1=x2,y1=y2
; mov [cs:level+1],eax

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
 push si
;; mov si,r1*256+r2;r1.r2 for routine
 call hilbert
 pop si
endif2:
 mov [cs:level+9],si
 movsx dx,byte [cs:level+9];r1
 movsx cx,byte [cs:level+10];r2

 add [cs:level+5],cx;x2 =x2+r2
 add [cs:level+7],dx;y2 =y2+r1
 call linexy
; mov eax,[cs:level+5];x1=x2,y1=y2
; mov [cs:level+1],eax

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
 push si
;; mov si,r1*256+r2;r1.r2 for routine
 call hilbert
 pop si
endif3:
 mov [cs:level+9],si
 movsx dx,byte [cs:level+9];r1
 movsx cx,byte [cs:level+10];r2

 sub [cs:level+5],dx;x2 =x2-r1
 sub [cs:level+7],cx;y2 =y2-r2
 call linexy
; mov eax,[cs:level+5];x1=x2,y1=y2
; mov [cs:level+1],eax

;cuad4
;If (level > 0)
;  Hilbert (-r2,-r1); // Si no nos están depurando
;EndIf
;  level=level+1
 and bl,bl
 jle endif4
 push si
; mov si,$00FB;;(-r2)*256-r1;r1.r2 for routine
 mov ax,si
 xchg ah,al
 neg ah
 neg al
 mov si,ax
 call hilbert
 pop si
endif4:
 inc bl;byte [cs:level]
 ret

;;int 20h
;-----------uservars:
level: ;db 0;minus optimization
;word x1;level+1
;word y1
;word x2
;word y2
;temp(+9)