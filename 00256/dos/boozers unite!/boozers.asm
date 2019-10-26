;
; Boozers Unite!
; 256b intro by Argasek | Function 2012
; jakub@argasinski.eu
;
; Just for fun :)
;

%define LINES 3*20
org 100h

    mov al, 13h
    int 10h

init:

    push 0A000h
    pop es
    mov di, 320*20+(320/4)
    mov dl, 2
    mov al, 15
flagpl:
    mov bl, LINES / 2
flagpl_half:
    mov cl, 160
    repe stosb
    add di, 160
    dec bl
    jnz flagpl_half
    mov al, 4
    dec dl
    jnz flagpl

    add di, 320*34

; OMG!!!1111 32-bit instruction!
    mov eax, 0x00020f04
    mov dl, 3
flaghu:
    mov bl, LINES / 3
flaghu_third:
    mov cl, 160
    repe stosb
    add di, 160
    dec bl
    jnz flaghu_third
    shr eax, 8
    dec dl
    jnz flaghu

    push ds
    pop es

    mov bl, 15 ; color
    mov bp, Text1
    mov cl, 16 ; len
    mov dh, 1 ; row
    mov dl, 12 ; column
    call print

    mov bp, Text3
    mov cl, 22 ; len
    mov dh, 22 ; row
    mov dl, 9 ; column
    call print

    mov bl, 12 ; color
    mov bp, Text2
    mov cl, 5 ; len
    mov dh, 12 ; row
    mov dl, 17 ; column
    call print

    mov bl,0
    mov bh,0
draw:
    call retrace

    mov al,12
    mov dx,03c8h
    out dx,al
    inc dl

    mov al,255
    out dx,al

    mov al,bl
    out dx,al
    out dx,al

    cmp bh,1
    je decrease
    inc bl
    cmp bl,63
    jne wait_for_esc
    mov bh,1
    jmp wait_for_esc
decrease:
    dec bl
    jnz wait_for_esc
    mov bh,0
wait_for_esc:
    in al, 60h
    dec al
    jnz draw

    mov ax, 0003h
    int 10h

    ret

print:
    mov ax,1301h
    int 10h
    ret

retrace:
    mov dx,3dah
vrt:
    in al,dx
    test al,8
    jnz vrt
novrt:
    in al,dx
    test al,8
    jz novrt
    ret

Text1
    db 'Polish drunkards'
Text2
    db 03,32,03,32,03
Text3
    db 'Hungarian Demoscene! ',02
