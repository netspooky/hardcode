org 100h
use16

 mov ax,13h
 int 10h
;gensin
		push	cs
		pop	es

;		mov	di, $A000;sint
		mov	di, sint
;		push di
		xor cl,cl;mov   cl, 0A0h
		mov	bx, 5F5h
		xor	dx, dx
genl:
		mov	ax, dx
		sar	ax, 0Bh
		sub	bx, ax
		shl	ax, 2
		sub	bx, ax
		add	dx, bx
		mov	al, dh
		stosb
		mov	ax, bx
		sar	ax, 9
		add	al, dh
		stosb
		dec	cl
		jnz	short genl

;		push 0A000h
;		pop es
;------------------------------
;pop bx
 xor bx,bx
;   zx:=sin_tab[angle mod 64];
;   zy:=cos_tab[angle mod 64];
ch_lp:
	mov ax,cs
	add ah,$10
	mov es,ax

 push bx
;; movsx si,byte [cs:bx];zx
 movsx si,byte [cs:sint+bx];zx
 add bl,40;+16
;; movsx bx,byte [cs:bx];zy
 movsx bx,byte [cs:sint+bx];zy

;
;  { centrowanie }
;  fx_:=65536-((xmax div 2)*(zx+zy));
;  fy_:=65536-((ymax div 2)*(zx-zy));

	mov ax,si
	add ax,bx
	cwd
	mov cx, 160
	imul cx
	neg ax
;;	mov [cs:fx_],ax
	push ax
;fy_
	mov ax,si
	sub ax,bx
	cwd
	mov cx, 100
	imul cx
	neg ax
;;	mov [cs:fy_],ax
	mov bp,ax
	pop dx
 xor di,di
;   for j:=0 to ymax-1 do begin
;mov dx,[cs:fx_]
;mov bp,[cs:fy_]
ylp:
;      fx:=fx_; fy:=fy_;
;mov dx,[cs:fx_]
;mov bp,[cs:fy_]

push bp
push dx

mov cx,320
;      for i := 0 to xmax-1 do begin
xlp:
;bx=zy,si=zx,di,bp,cx,ax


;       if (fx xor fy) shr 8 and $10=0 then
;        bmp.Canvas.Pixels[i,j]:=clWhite
;       else
;        bmp.Canvas.Pixels[i,j]:=clBlack;

mov ax,bp
xor ax,dx
and ah,$10
mov al,ah
je putt
dec al
putt:
stosb

;       if not(form1.Zoom1.Checked) then
;        fx:=fx+zx;    // zoomer

add dx,si;(2) SI=zx,BP=fy_,DX=fx_,;BX=_zy
;       fy:=fy-zy;
sub bp,bx
loop xlp


;      if not(form1.Stretch1.checked) then
;       fx_:=fx_+zy;   // stretch 
pop dx
add dx,bx

;      if not(form1.Zoom1.Checked) then
;       fy_:=fy_+zx;   // zoomer
pop bp
add bp,si;(1)

;   end;
cmp di,64000
jne ylp
;------------copy to screen---------

		mov	dx, 3DAh

w1:
		in	al, dx		; Video status bits:
					; 0: retrace.  1=display is in vert or horiz retrace.
					; 1: 1=light pen is triggered; 0=armed
					; 2: 1=light pen switch is open; 0=closed
					; 3: 1=vertical sync pulse is occurring.
		test	al, 8
		jz	short w1

	push es
	pop ds
	push 0A000h
	pop es
	xor si,si
	xor di,di
	mov ch,$FA
	rep movsb
;-----------------------------------
pop bx
inc bl
in al,60h
dec al
jne ch_lp
ret
;-------------------------------
;fx_:dw 0
;fy_:dw 0
 sint: