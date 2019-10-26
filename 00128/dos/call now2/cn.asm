;lame compofiller, greets to wbc - sorry, i borrow flashing routine
org 100h
use16
		mov ax,1130h
		mov bh,3
		int 10h
	push es
	push bp

    mov   ax,3
    mov di,ax
    int   10h


    mov   ax,1112h
    xor   bx,bx
    int   10h

  push 0b800h
  pop es
  mov si,text
  ;xor di,di
  pop bp
  pop fs
tlp1:
  lodsb
  or al,al
  jne putchar
;-wbc routine-
@loop:	  
    mov   dx, 3DAh
retr2:
    in	  al, dx
    and   al, 8
    jnz   retr2    
retr1:
    in	  al, dx
    and   al, 8
    jz	  retr1
    
    mov    dl, 0C8h
    xor    ax, ax
    out    dx, al
    inc    dl
    mov    al, bl
    out    dx, al
    out    dx, al
    out    dx, al
    neg    bl

    hlt
    
    mov    ah, 1
    int    16h
    jz	   @loop
    ret
putchar:
  xor ah,ah
  shl ax,3
  mov bx,bp
  add bx,ax
  mov cl,8
  push di
ch1:
  mov ch,128
  push di
ch2:
  mov al,byte [fs:bx]
  and al,ch
  je notcall
  mov al,0dbh;0b1h
notcall:
  mov ah,al
  stosw
  shr ch,1
  jnc ch2
  inc bx
  pop di
  add di,160
  loop ch1
  pop di
  add di,16
  jmp tlp1
text: db "Call Now2",0
