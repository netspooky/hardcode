.model large
.386
.data
        input1 db 'Nombre del archivo fuente  (BMP): $'
        input2 db 'Nombre del archivo destino (RES): $'
        filename1 db 256 dup (?)
        filename2 db 256 dup (?)
        e1 db 10,13,'No existe archivo fuente$'
        e2 db 10,13,'El archivo destino no es v lido$'
        buffer db 302 dup (?)
        dest db 150 dup (?)
.stack 100h
.code
.startup
        mov ah,9
        lea dx,input1
        int 21h

        mov esi,0
bucle1:
        mov ah,1
        int 21h
        cmp al,13
        je fora1
        mov filename1[esi],al
        inc esi
        jmp bucle1
fora1:
        mov filename1[esi],byte ptr 0

        mov ah,2
        mov dl,10
        int 21h

        mov ah,9
        lea dx,input2
        int 21h

        mov esi,0
bucle2:
        mov ah,1
        int 21h
        cmp al,13
        je fora2
        mov filename2[esi],al
        inc esi
        jmp bucle2
fora2:
        mov filename2[esi],byte ptr 0

        mov ah,3Dh
        mov al,0
        lea dx,filename1
        int 21h
        jc error1

        mov bx,ax

        mov ah,3Fh
        lea dx,buffer
        mov cx,302
        int 21h

        mov ah,3Eh
        int 21h

        mov esi,0
        mov edi,145
bucle_pral:
        mov eax,0
bucle_p:
        mov bl,buffer+62[esi]
        not bl
        mov dest[edi],bl
        inc esi
        inc edi

        inc eax
        cmp eax,5
        jne bucle_p

        add esi,3
        sub edi,10

        cmp esi,30*8
        jne bucle_pral

        mov ah,3Ch
        mov cx,0
        lea dx,filename2
        int 21h
        jc error2
        mov bx,ax

        mov ah,40h
        mov cx,150
        lea dx,dest
        int 21h

        mov ah,3Eh
        int 21h

        jmp final

error1:
        mov ah,9
        lea dx,e1
        int 21h
        jmp final

error2:
        mov ah,9
        lea dx,e2
        int 21h
        jmp final

final:
.exit
end
