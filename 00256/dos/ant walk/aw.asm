org 100h
use16

mov ax,13h
int 10h


;		cli
;		mov	dx, 3C4h
;		mov	ax, 604h
;		out	dx, ax		; EGA: sequencer address reg
;					; unknown register
;		mov	ax, 0F02h
;		out	dx, ax		; EGA: sequencer address reg
;					; unknown register
;		mov	dx, 3D4h
;		mov	ax, 14h
;		out	dx, ax		; Video: CRT cntrlr addr
;;					; underline location.  Bits 0-5 are scan line number.
;		mov	ax, 0E317h
;		out	dx, ax		; Video: CRT cntrlr addr
;					;
;		mov	al, 9
;		out	dx, al		; Video: CRT cntrlr addr
;					; maximum scan line
;		inc	dx
;		in	al, dx		; Video: CRT controller internal registers
;		and	al, 0E0h
;		add	al, 4
;		out	dx, al		; Video: CRT controller internal registers

            mov dx,3d4h
            mov al,14h;9
            out dx,al
            inc dl
            in  al,dx
            and al, 255-31;NOT(31)
            or  al, 4;height
            out dx,al

push 0A000h
pop es

;;;;;;;;;setpal
 xor al,al
setpal:
mov dx,03c8h
out dx,al
inc dx

push ax
xor al,al

out dx,al

pop ax
out dx,al
out dx,al

inc al
cmp al,64
jne setpal
;;;;;;;;;;;;;;;

mov ax,cs
add ah,10h
mov ds,ax

mov si,320*100/2;Y
mov cx,160/2;x
;bp is dir
xor bp,bp
ant_lp:

;	       mov     dx, 3DAh
;tt1:
;	       in      al, dx
;	       test    al, 8
;	       jnz     short tt1
;tt2:
;	       in      al, dx
;	       and     al, 8
;	       jz      short tt2


mov di,si
add di,cx

mov al,[ds:di]
;or al,al
;jne elseif
cmp al,64
je elseif
;    If v(x,y)<>64;=0
;      v(x,y)=64
mov al,64
mov byte [es:di],63
;xor al,al
;      adir+1
dec bp
jmp endif

elseif:
;    ElseIf v(x,y)=64
;      v(x,y)=63
; mov al,63+1
 xor al,al
;      adir-1
 cmp byte [es:di],al
 je xx
 dec byte [es:di]
xx:
inc bp
;    EndIf
endif:
 mov [ds:di],al
; mov [es:di],al
 
push bp
and bp,3
add bp,bp
;X
 add cx,word [cs:bp+d_x]
 jns no_x_l
 mov cx,320/2
no_x_l:
 cmp cx,320/2
 jc no_x_r
 xor cx,cx
no_x_r:
;Y
 add si,word [cs:bp+d_y]
 jns no_y_l
 mov si,99*320
no_y_l:
 cmp si,64000
 jc no_y_r
 xor si,si
no_y_r:
pop bp
;--------------------------------
xor di,di
outlp:
mov al,[es:di]
or al,al
je bra2
dec al
bra2:
 stosb
 cmp di,64000
 jne outlp

in al,60h
dec al
jne ant_lp
ret
d_x:
 dw 0,-1,0,1
d_y:
 dw -320,0,320,0
;    Select adir&3
;    Case 0 ;up
;      y - 1
;    Case 1 ;left
;      x - 1
;    Case 2 ;down
;      y + 1
;    Case 3 ;right
;      x + 1
;  EndSelect
