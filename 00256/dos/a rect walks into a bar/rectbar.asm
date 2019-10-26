org 100h
section .text

timer equ 46Ch-130h

start:
        mov ax,13h
        mov fs,ax
        int 10h

        mov eax,dword[fs:timer]
        dec eax
        mov dword[stime],eax

ZOMG:
        mov ebx,dword[fs:timer]
        sub ebx,dword[stime]
        cmp bx,320
        jge progdone

        ; clear vbuf
        mov di,vbuf
        xor ax,ax
        mov cx,32000
        rep stosw

        mov dx,bx
        mov cl,40
        mov di,40*320+vbuf
        mov al,15
        call rect

        cmp bx,160
        jb skiplol
        and bl,8
        jz skiplol

        mov di,vbuf+100*320+86
shadeloop:
        inc al
        push di
        call lol
        pop di
        sub di,321
        cmp di,vbuf+100*320+86-321*16
        jne shadeloop
skiplol:

        push es
        push 0a000h
        pop es
        mov cx,32000
        xor di,di
        mov si,vbuf
        rep movsw
        pop es

        in al,60h
        cmp al,1
        jnz ZOMG
        ret
progdone:
%ifdef REALTHING
        cli
%endif

rline:

%ifdef REALTHING
        mov dx,3dah
lp1:
        in al,dx
        and al,1
        jnz lp1
lp2:
        in al,dx
        and al,1
        jz lp2
%endif

        xor al,al
        mov dx,3c8h
        out dx,al
        inc dx
        mov al,bl
        out dx,al
        add al,27
        out dx,al
        add al,27
        out dx,al
        inc bl

        in al,60h
        cmp al,1
        jnz rline

%ifdef REALTHING
        sti
%endif
        ret




lol:
    push di

call L

    pop di
    add di,60
    
    push di
    mov dl,50
    mov cl,16
    call rect
    push di
    push di
    mov dl,16
    mov cl,50
    call rect
    pop di
    add di,50-16
    mov dl,16
    mov cl,50
    call rect
    pop di
    add di,50*320
    mov dl,50
    mov cl,16
    call rect
    pop di

    add di,60
    call L

    ret

L:
    mov dx,16
    mov cx,50+16
    call rect
    mov dl,50
    mov cl,16
    call rect
    ret


; dx: width
; cx: height
; di: address of uppser-left corner
rect:
    push cx
    push di
    mov cx,dx
    rep stosb
    pop di
    add di,320
    pop cx
    loop rect
    ret
    
;times varbase-($-$$) db 0
;stride64 db 5
stime dd 0
varbase equ ($-$$)

section .bss
vbuf resb 64000

