
;
;    
;
;

tempr dd  03f3f3f3fh
tempi dd  000030303h

;       generamos en random 256x258 pixels
;       hacemos n suavizados

rand dd 1234567
Suavizar_s1_s2 PROC     ;esi->origen edi->destino 256x256


        xor eax,eax
        movd mm6,tempi
@@loopY:
       
@@loopX:


        movd mm7,tempr


        inc al                  ;derecha
        lea ebx,[eax*4+esi]
        movd mm0,[ebx]


        dec al
        inc ah
        lea ebx,[eax*4+esi]     ;abajo
        movd mm1,[ebx]


        dec ah
        dec ah

        lea ebx,[eax*4+esi]     ;arriba
        movd mm2,[ebx]


        dec al
        inc ah
        lea ebx,[eax*4+esi]     ;izda
        movd mm3,[ebx]

        
        psrlq mm0,2
        psrlq mm1,2     ;dividimos los bytes RGB / 4
        psrlq mm2,2
        psrlq mm3,2

        pand mm0,mm7
        pand mm1,mm7
        pand mm2,mm7
        paddb mm0,mm1
        pand mm3,mm7
        paddb mm0,mm2
        paddb mm0,mm3

        inc al
        paddb mm0,mm6
        lea ebx,[eax*4+edi]     

        movd [ebx],mm0
        

                
        dec al
        jnz @@loopX

        dec ah
        jnz @@loopY
        


        emms
        ret
Suavizar_s1_s2 ENDP


Gen_Text_256x256 PROC

        mov edi,small scratch_text

   
;        push es
;        push ds
;        pop es

        mov ecx,(256*256)/10

        mov eax,small rand
        ;eax=nuestro pseudo_random
@next_pixel:
        add eax,0a5a5a5a5h
        rol eax,10
        add eax,0a1aa1456h
        ror eax,3
	push ecx
	mov ecx,10
        rep stosd
	pop ecx
        loop @next_pixel

        mov esi,Small scratch_text

        mov rand,eax
;        pop es
        RET
Gen_Text_256x256 ENDP

