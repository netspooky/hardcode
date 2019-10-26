;forward
;64 byte MS-DOS intro
;
;by fsqrt
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;??-12-2013

org 0x100
 mov al, 0x13
 int 0x10
 push 0xA000
 pop es
 
L:
 xor bx, bx
p0:
 mov ax, 0xCCCD
 mul di
 lea cx, [si+bx]
p1:
 lea ax, [bx-128]
 add al, dl
 imul bl
 sar ax, 3
 add ax, si
 xor cl, al
 imul al
 add ch, ah
 shr dx, 8
 jnz p1
 sub ch, cl
 jnc p2
 inc bx
 and bx, 15
 jnz p0
 
p2:
 lea ax, [bx+15]
 stosb
 dec bp
 jnz L
 inc si
 in al, 0x60
 jnz L
 ret
 