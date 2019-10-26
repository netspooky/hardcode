org 100h
use16

mov ax,13h
int 10h

 mov si,128
 xor di,di
 xor dx,dx
 xor cx,cx
 mov bl,64
slp:
 add dx,cx
 add cx,4
 mov al,dh
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
 
;---test plot

; mov di,sint
; xor cx,cx
;testp:
; movsx dx,byte[es:di]
;; add dx,100
;
; mov ax,0C0Fh
; xor bh,bh
; int 10h
;inc di
;inc cx
;cmp cx,256
;jne testp
;ret 

;--------------------
xor bx,bx
flp:
mov ax,cs
add ah,10h
mov es,ax
xor si,si
xor ax,ax
mov cx,65535;ch,0FAh
;mov ch,0FBh
rep stosb

xor di,di;mov di,60*0
mov bp,199
push dx
;    For y=0 To 199
lp_y:
;      x1=Abs(99-y)
mov ax,99
sub ax,bp
jns nominus
neg ax;ax=x1
nominus:

;      x2=199-x1
mov cx,199
sub cx,ax;cx=x2

;      x=s(a)+s(b)
mov bl,dl
movsx si,byte [cs:sint+bx]
;sar si,1
mov bl,dh

;      LineXY(x1+x,y,x2+x,y,RGB(255,0,0))
push di

add di,ax
sub cx,ax;x2-x1
movsx ax,byte [cs:sint+bx]
sar ax,1
add si,ax

add di,si
inc cx
mov al,0fh
rep stosb

pop di
;      a=a+2
add dl,2
;      b=b+3
add dh,3
;    Next y
add di,320
dec bp
jne lp_y

	       mov     dx, 3DAh
tt1:
	       in      al, dx
	       test    al, 8
	       jnz     short tt1
tt2:
	       in      al, dx
	       and     al, 8
	       jz      short tt2

pop dx
inc dl
inc dh

push es
pop ds
push 0a000h
pop es
xor si,si
xor di,di
mov ch,0FAh
rep movsb

in al,60h
dec al
jne flp
ret
sint:
