;256 byte demo
;A first try
;FASM syntax

org 100h; code starts at offset 100h
use16; use 16-bit code

mov ax,13h
int 10h

;Because it might be hard to store font bitmaps in 256 bytes for the entire ascii character set
;we look for the text mode character bitmaps in the BIOS data area
;These are later scaled up
;Get font location in BIOS into ES:BP
mov ax,01130h
;Get 8x8 font
mov bh,3
int 10h

push es
pop ds
push 0a000h
pop es

;Put message offsets on stack
push 0
push msg6
push msg5
push msg4
push msg3
push msg2
push msg

_next_msg:
;SI holds amount to scale font by
mov si,1
pop dx
cmp dx,0
jz _exit
;Clear last message
xor ax,ax
mov di,16000
mov cx,4500
rep stosw
_doit:
mov di,16000
mov cx,dx
push dx
_r0:
push bp
push di
mov di,cx
movzx bx,byte[cs:di]
pop di
cmp bl,'$'
je _end
;multiply bx * 8 (bitmap is 8 bytes per character)
shl bx,3
add bp,bx
pusha
mov dx,8
mov cx,si
_d0:
push cx
;Get current byte from font data
mov bl,byte[ds:bp]
;Mask
mov bh,10000000b
;Row width into cx
mov cx,8
_draw_row:
;default to al=0 (draw black pixel)
xor al,al
;Is pixel at current position set?
test bl,bh
jz _no_pixel
mov al,cl
;******ADJUSTABLE****** Amount added to al decides colour, multiples of 10 starting at 20 seem good
add al,60
_no_pixel:
push cx
;scaling factor into cx - how many times to repeat pixels
mov cx,si
rep stosb
pop cx
;Shift mask to next bit position
shr bh,1
loop _draw_row
pop cx
;Next row - offset (di) = (di+320) - (si*8)
add di,320
;si * 8
shl si,3
sub di,si
;restore si
shr si,3
loop _d0
inc bp
dec dx
mov cx,si
jnz _d0
popa
inc cx
mov ax,8
mul si
add di,ax
pop bp
jmp _r0
_end:
pop bp
pop dx
;******ADJUSTABLE****** value in cx decides zoom speed - smaller = faster
mov cx,10
call _delay
inc si
cmp si,5
jne _doit
;******ADJUSTABLE****** value in cx decides time between each sentence
;Or comment out this line to make the delay the same as the last one and save a couple of bytes :)
mov cx,20
call _delay

jmp _next_msg

_exit:
;Wait for key
mov ah,7
int 21h

;Exit
mov ah,4ch
int 21h

;Wait an amount of time specified in cx
;specified in approx 1/70th seconds
;synchronises to vertical retrace
_delay:
pusha
_wait:
  mov dx,03dah
  _vrc_clear:
    in al,dx
    test al,00001000B
    jnz _vrc_clear
  _vrc_start:
    in al,dx
    test al,00001000B
    jz _vrc_start
  loop _wait
popa
ret

msg db "MADEYES$"
msg2 db "PRESENTS$"
msg3 db "A FIRST$"
msg4 db "256b DEMO$"
msg5 db "GREETS 2$"
msg6 db 01,00,"D B F",00,01,"$"