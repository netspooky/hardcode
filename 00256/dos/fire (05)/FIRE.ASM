;------------------- source ------------------
.386
assume cs:code,
ds:code,
ss:code
code segment para 'code' use16
org 100h
start:
        mov ax,13h
	int 10h
	push cs
	pop es
        xor ax,ax
        mov di,offset buf
        mov cx,32000
        rep stosw
        mov cl,127
        xor bl,bl
        mov dx,03c8h
        out dx,al
        inc dxstpal1:
        add al,bl
        xor bl,1
        out dx,al
        push ax
        xor al,al
        out dx,al
        out dx,al
        pop ax
        loop stpal1
        xor ax,ax
        push ax
        mov cl,129
        mov bx,7e00h
stpal:
        mov al,53
        out dx,al
        pop ax
        add ax,bx
        adc al,0
        push ax
        out dx,al
        xor al,al
        out dx,al
        loop stpal
        pop ax
        mov ax,0a000h
        mov es,ax
begin:
        mov bl,50
rnd:
        call random
        mov si,ax
        mov byte ptr [si+offset buf+320],255
        mov byte ptr [si+offset buf+320+320],255
        mov byte ptr [si+offset buf+320+640],255
        mov byte ptr [si+offset buf+320+960],255
        mov byte ptr [si+offset buf+320+1280],255
        dec bl
        jnz rnd
        mov di,offset buf+320
        mov cl,100
inner:
        push cx
        mov bx,320
inner1:
        movzx ax,byte ptr ds:[di-1]
        movzx dx,byte ptr ds:[di+1]
        add ax,dx
        movzx dx,byte ptr ds:[di-320]
        add ax,dx
        movzx dx,byte ptr ds:[di+320]
        add ax,dx
        shr ax,2
        or al,al
        jz skip
        dec alskip:
        mov byte ptr [di],al
        inc di
        dec bx
        jnz inner1
        pop cx
        dec cl
        jnz inner
        mov di,199*320
        mov si,offset buf+(5*320)
        cld
        mov al,100cp2scr:
        mov cx,160
        rep movsw
        sub di,640
        dec al
        jnz cp2scr
        push es
        push cs
        pop es
        mov di,32000
        mov cx,di
        add di,offset buf
        mov si,di
        add di,320
        std
        rep movsb
        pop es
        mov ah,1
        int 16h
        jz begin
        mov ax,3
        int 10h
        retrandom:
        push si bx
        xor si,si
        mov di,320
        mov bx,seed
        add bx,9248h
        ror bx,1
        ror bx,1
        ror bx,1
        mov seed,bx
        mov ax,di
        sub ax,si
        mul bx
        mov ax,dx
        add ax,si
        pop bx si
        
retseed    dw   4234h
buf db 64000 dup (?)
code ends
end start
;------------------------------------