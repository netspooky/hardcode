.MODEL TINY
.CODE
.STARTUP
.386
    mov al,13h
    int 10h

    mov dx,03c8h
    mov cl,64
@setpal:
    mov al,cl
    out dx,al   
    inc dx
    out dx,al
    out dx,al
    out dx,al
    dec dx
    loop @setpal

    mov bx,cs
    add bx,1000h
    mov es,bx

    dec cx          
    rep stosb       

    mov ds,bx
    add bx,2000h
    mov gs,bx
    mov bx,0a000h
    mov es,bx
    xor si,si
    xor di,di

@mainloop:
    mov cx,0ffh
    @randfire:
        in  al,40h
        add bx,ax
        in  al,40h
        add bx,ax
        mov [bx],al
        loop @randfire

    xor bx,bx
    @lusje:
        mov al,[bx]
        add al,[bx-1]
        add al,[bx-320]
        add al,[bx-321]
        shr al,2
        and al,3fh
        mov gs:[bx],al
        inc bx
        cmp bx,0
        jne @lusje

    push ds
    push gs
    pop ds
    pop gs                  
     
    dec cx
    rep movsb
          
    in  al,60h   
    cmp al,80h
    ja  @mainloop

    mov ax,3
    int 10h
    mov dx,cs
    mov ds,dx
    mov dx,offset msg
    mov ah,9
    int 21h
    ret
msg:
    db 'A little explanation:',0dh,0ah
    db 'I had no time left, hence this text to fill the remaining bytes.',0dh,0ah
    db 'Made by Sabre2th of The Third Foundation.',0dh,0ah,'$'
END
