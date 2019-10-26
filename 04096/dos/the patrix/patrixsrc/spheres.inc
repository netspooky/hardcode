PutSphere PROC  ;ESI -> ESFERA ; EAX=X , EBX=Y, ECX=COL

        cld

        add edi,ecx

        shl eax,2
        add edi,eax    ;edi=X*4 + Y*(320*4)

        mov eax,ModoX*4
        mul ebx
        add edi,eax


        xor edx,edx
        lodsb   ;AL=TAM

        mov dl,al

        mov ebx,ModoX
        mov ecx,edx
        sub ebx,edx ; ebx=320-tam
        shl ebx,2   ; *4

@@LopY:
        push ecx
        mov ecx,edx

@@LopX:
        lodsb
        add al,es:[edi]

        jc @@SetToFF 
        mov es:[edi],al
        add edi,4
        loop @@LopX
@@CLPX:
        add edi,ebx
        pop ecx
        loop @@LopY

        jmp @@RT2

@@SetToFF:
        mov byte ptr es:[edi],0ffh

        add edi,4
        loop @@LopX
        jmp @@CLPX

@@RT2:  ret

PutSphere ENDP



GenSphere PROC  ;EDI -> DESTINO  ;AL=TAM

        push es
        push ds
        pop es
        movzx eax,al
        mov tamt,eax
        stosb
        mov yt,eax

        mov dat,512

        fild dat
        fidiv tamt  ;prop=512/tamt
        fstp prop

        mov dat,256

        

@@LopY:
        mov eax,tamt
        mov xt,eax
@@LopX:
        fild xt
        fmul prop
        fisub dat

        fild yt
        fmul prop
        fisub dat

        fmul st(0),st(0)
        fstp a

        fmul st(0),st(0)

        fadd a

        fsqrt

        fistp dat2

        cmp dat2,255
        ja @@saltar_y_poner_a0

        mov eax,255
        mov ebx,dat2
        sub eax,ebx
        stosb

        jmp @@continuar

@@saltar_y_poner_a0:
        xor al,al
        stosb

@@continuar:

        dec xt
        jnz @@LopX

        dec yt
        jnz @@LopY

        pop es
        ret


GenSphere ENDP

