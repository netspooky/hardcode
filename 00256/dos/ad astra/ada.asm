org 100h
use16

mov al,13h
int 10h


;---calc sin---
; strange behaviour at oracle virtualbox
;bx=0
;sinlp:
;;s(i)=Int(32*Sin(i*#PI/128))
; fldpi
; fidiv [cs:const128]
; mov [cs:tmp],bx
; fimul word [cs:tmp]
; fsin
; fimul [cs:const32]
; fist  word [cs:tmp]
; mov al,byte [cs:tmp]
; mov [cs:sint+bx],al
; inc bl
; jne sinlp

; call tpl
 

 mov si,128
 xor di,di
 xor dx,dx
 xor cx,cx
 mov bl,64
slp:
 add dx,cx
 add cx,4
 mov al,dh
; neg al
 mov [cs:sint+di],al
 mov [cs:sint+si+128],al

 neg al
 add al,32*2
 mov [cs:sint+si],al

 mov [cs:sint+di+128],al

 
 dec si
 inc di
 dec bl
 jns slp


;------------test plot--------------
;tpl:
;xor bx,bx
;push 0A000h
;pop es
;tplp:
; mov ax,100*0
; add al,byte [cs:sint+bx]
; cwd
; imul ax,320
; add ax,bx
; mov di,ax
; mov byte [es:di],15
; inc bl
; jne tplp
;; ret

 mov dx,03c8h
 xor al,al
 out dx,al
 inc dx
out_pal:
 out dx,al
 out dx,al
 out dx,al
 inc al
 cmp al,64
 jne out_pal
;----------------
adalp:
 push 08000h
 pop es
 xor di,di;mov di,320*20
 xor cx,cx;hl
 xor dh,dh;dh=y,dl=a
 dec dl;a-1
;a.a=0
;-sh.a=1
;-de.w=85
;-y0.a=20
;  Repeat
;    a-1
;    a0.a=a
;    hl.w=0
;    StartDrawing(ScreenOutput())
;    Box (0,0,256,192,RGB(0,0,255)) 
ylp:
;    For y=0 To 191


;     a0=a+(hl>>8)
;     hl+de
;      x=128+((y>>sh)*s(a0))>>5
mov bl,dl
add bl,ch
add cx,85
 call plot2
 call plot2
;; call plot
;; call plot


;      Box (x,y+y0,1,1,RGB(255,255,255))
;      b.a=a0+64
;      x=128+((y>>sh)*s(b))>>5
;      Box (x,y+y0,1,1,RGB(255,255,255))
;      
;      b=b+64
;      x=128+((y>>sh)*s(b))>>5
;      Box (x,y+y0,1,1,RGB(255,255,255))
;      
;      b=b+64
;      x=128+((y>>sh)*s(b))>>5
;      Box (x,y+y0,1,1,RGB(255,255,255))
;
;    Next y
 inc dh
 add di,320
 cmp dh,200-20-1
 jne ylp

push dx

;verical retrace check: 
mov dx, 3dah
@wait1: 
in al, dx
test al, 8
jz @wait1

@wait2:
in al, dx
test al, 8
jnz @wait2

;		mov	dx, 3DAh
;@wait4retrace:
;		in	al, dx
;		and	al, 8
;		jz	short @wait4retrace

 xor si,si
 xor di,di
 mov cx,64000
 push es
 pop ds

 push 0A000h
 pop es
 
 pusha
 rep movsb
 popa
 push ds
 pop es
 xor ax,ax
 rep stosd
; draw stars
 mov di,bp
 push cx
; add bp,320
 mov cx,320*3
 add bp,cx
star_lp:
 mov byte [es:di],al
 inc al
 and al,63
 add di,si
 add di,si
 add si,cx
 sar si,1
 dec cx
 jne star_lp
;
pop cx
pop dx

  in al, 60h
  dec al
  jnz adalp

plot2:
 call plot
plot:
;      x=128+((y>>sh)*s(a0))>>5
pusha

movzx ax,dh
sar ax,1
cwd
movsx cx,byte[cs:sint+bx]
sub cx,32
imul ax,cx
sar ax,5

mov bx,ax
mov byte [es:di+bx+159+20*320],63;15
 popa
 add bl,64

 ret
const128 dw 128
const32  dw 32
tmp dw 0
sint: