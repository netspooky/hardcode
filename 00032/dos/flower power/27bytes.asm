;
; EFnet #asm compo nr 9
; 05.08.2004
;
; 32 byte MSDOS demo for 386+ class PCs
;
; Demo name: Flower power
; Size: 27 bytes
;
; Author: Thomas Nilsen
; Email: thomn@online.no
;

[bits 16]
[org 0x100]
        mov ax,0x13
        int 0x10
        push 0xa000
        pop ds
b:
        mov edx,(320*200)
        in al,0x40
a:
        dec edx
        mov [ds:edx],al
        jnz a
        jmp b
