; transformers 32 byte intro
; by rudi of yaphan~darklite
; compiled with tasm 4.1

.286
.model small
.code
org 100h

main:
les bp,[bx]
lds bp,[bx]
mov al,13h
int 10h
mov si, di
stosb

again:
lodsw
shl ah, 1
rol al, 1
xor ah, al
lodsb
xor al,ah
add di,321
stosb
sub di,319
jmp again

end main	