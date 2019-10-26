; Blob140
; by Optimus/Dirty Minds^Nasty Bugs
; compiled with Nasm
;
; for the Korillaclub competition

org 100h
        mov al,13h
	int 10h

        mov dx,3c8h
	xor al,al
        out dx,al
        inc dx

times256:
        mov al,bl
        shr al,2
        out dx,al
        out dx,al
        out dx,al
        inc bx
        jnz times256

; ----------- Sinegen ------------

        XOR     DI,DI
        push word 09000h
        pop ds
        push word 0a000h
        pop es

Singen:
        MOV     [DI],CH
        ADD     CX,SI
        MOV     AX,40
        IMUL    CX
        SUB     SI,DX
        INC     DI
	JNZ     Singen

main:
        inc di
        
        xor si,si
        mov bl,200
yloop:
        mov cx,320
xloop:

        push si
        push di
        mov si,3
        xor bp,bp
nblobs:
        mov al,bl
        sub al,100
        sub al,[di]
        imul al
        mov dx,ax

        mov al,cl
        sub al,160
        shr di,1
        sub al,[di+64]
        imul al
        add ax,dx


        push bp
        or al,3
        mov bp,ax
        xor dx,dx
        mov ax,65535
        div bp
        pop bp

        add bp,ax

        dec si
        jnz nblobs

        mov ax,bp

        or ah,ah
        jz below256
        mov al,255
below256:
        pop di
        pop si
        mov [es:si],al

        inc si
        dec cx
        jnz xloop

        dec bx
        jnz yloop


        MOV     DX,3DAh
Vsync:
        IN      AL,DX
        AND     AL,8
        JZ      Vsync

	in al,60h
	dec ax
	jnz main

        mov al,03h
	int 10h
RET
