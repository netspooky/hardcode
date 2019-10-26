;
; Outburst by -SP-
; function11 | Sep. 16-18. 2011.
;
; compile with NASM
;

org 100h

mov ax, 13h
int 10h

push 0xA000
pop es

pal:	
  mov	dx, 0x3C8
  mov al, cl
	out	dx, al
	inc	dx
	out	dx, al
	xor al, al
	out	dx, al
	out	dx, al
	loop	pal

xor di, di
xor si, si

main_loop:

mov cx, 198
rows:

  fld dword [angle]
  fadd dword [step]
  fst dword [angle] 
  fdiv dword [dv]
  fsin
  fmul dword [mult]
  fst dword [sval]
  mov bx, [sval]
  fmul dword [mult]
  fstp dword [sval]
  mov bp, [sval]  

  mov dx, cx
  push cx
  mov cx, 320
  cols: 
    mov ax, dx
    imul ax, 320
    add ax, cx
    mov di, ax
    sub di, 2
    
    xor bx, cx
    xor bp, dx

    add bx, bp
    
    mov [es:di], bx 
    
  loop cols
  pop cx
loop rows

cmp si, 0 
jnz att

amp:
add word [mult], 80
cmp word [mult], 20000
jnz skip
inc si

att: 
sub word [mult], 80
cmp word [mult], 4000
jnz skip
xor si, si 

skip:

push	dx
mov	dx, 0x03DA
vsync:
in	al, dx
test	al, 8
jz	vsync
pop	dx

in al, 60h
dec al
jnz main_loop

mov ax, 3h
int 10h

ret

angle dd 0.0
step dd 0.1
sval dd 0.0
dv dd 6.1415
mult dd 0
