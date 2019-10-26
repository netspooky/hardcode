SPSIZE=30

        ;Reservamos memoria-------------------------------------------------

        mov ecx,SPSIZE*SPSIZE+1 +256*256*4*5 + 320*240*4*3; 1 bola, 3 texturas
        call  alloc_himem
        mov small Sphere1,ebx

        mov edi,ebx ;para el GenSphere 
        mov esi,256*256*4

        add ebx,SPSIZE*SPSIZE+1
        mov small scratch_text,ebx      ;Texturas
        add ebx,esi
        mov small scratch_text2,ebx
        add ebx,esi
        mov small cartman_head,ebx
        add ebx,esi
        mov small cartman_body,ebx
        add ebx,esi
        mov small kenny,ebx
        add ebx,esi

        mov esi,320*240*4       ;Buffers de video

        mov small VBuffADDR,ebx
        add ebx,esi
        mov small Video_Kenny,ebx
        add ebx,esi
        mov small Video_Cartman,ebx





        mov al,SPSIZE
        call  GenSphere
        mov ecx,ModoY

;------------------------------------Generamos la textura ------------------
        call  Gen_Text_256x256

        mov edx,10
        call  Suaviz_N   ;tenemos en scratch_text la textura aleatoria


;------------------------------------------------------

        Call Gen_Cartman
        mov edi,small cartman_body

        mov edi,small kenny
        call  Clean_WHITE

        mov edi, small kenny   ;dibujamos la cabeza en scratch_text2
        lea esi,small kenny_body
        call  secuencia
 
        mov esi,small cartman_body
        mov edi,small Video_Cartman

        mov edx,240
@ttloopY2:
        mov ecx,256
        rep movsd
        add edi,(ModoX-256)*4
        dec edx
        jnz @ttloopY2

        mov esi,small kenny
        mov edi,small Video_Kenny

        mov edx,240
@ttloopY22:
        mov ecx,256
        rep movsd
        add edi,(ModoX-256)*4
        dec edx
        jnz @ttloopY22

;	mov ecx,320*240
;	xor eax,eax
;	mov edi,small Video_Kenny
;	rep stosd
	
	
	mov esi,Video_Kenny
 	mov edi,Video_Cartman
        call  Fade_VBuf


;        call  DumpVideo


        xor eax,eax
        int 16h


rz:
        mov ecx,200
@ps:    push ecx

        mov esi,small scratch_text
        mov edi,small VBuffADDR

        pusha

        mov eax,ecx
        call  tunnel
        popa

;        call  RotoZoom
        call  InterpolarUV

        finit

        fld small fangle
        fadd small  fanginc
        fst small fangle

        fld st(0)
        fmul small fdist_ang
        fcos
        fmul small fdist_
        fabs
        fstp small fdist

        mov small a,0
@UnaMas:
        fadd small fballinc
        fld st(0)

        fsincos
        fmul small fdist
        fadd small fdist_
        fistp small xt

        fmul small fdist
        fadd small fdist_
        fistp small yt


        mov esi,small Sphere1
        mov edi,small VBuffADDR
        mov ecx,small small a
        mov eax,small xt
        mov ebx,small yt
        call  PutSphere

        inc small a
        cmp small a,3
        jbe @UnaMas



        call  EsperarRetrazo

        call  DumpVideo

        pop ecx
        dec ecx
        jnz @ps


        xor ax,ax
        int 16h

        jmp @endintro


Gen_Cartman PROC

        mov edi,small cartman_body
        call  Clean_WHITE

        mov edi,small cartman_head
        call  Clean_WHITE

        
        mov edi, small cartman_body   ;dibujamos la cabeza en scratch_text2
        lea esi,small cartman_body_sec
        call  secuencia

        mov edi, small cartman_head
        lea esi,small cartman_head_sec
        call  secuencia

        mov esi,small cartman_head
        mov edi,small cartman_body
        push edi

        call  Text_MIX

        pop edi

        ;cartman patch
        add edi,255*4
        mov ecx,255
        mov eax,00ffffffh
@loop_patch:
        mov [edi],eax
        add edi,256*4
        loop @loop_patch



        ret

Gen_Cartman ENDP





Suaviz_N PROC   ;ed     x->num  

@suaviz:
        mov esi,small scratch_text
        mov edi,small scratch_text2

        call  Suavizar_s1_s2

        call  XCHG_Text

        dec edx
        jnz @suaviz
        ret

Suaviz_N ENDP

XCHG_Text PROC
        mov eax,small scratch_text
        xchg eax,small scratch_text2
        xchg eax,small scratch_text
        ret
XCHG_Text ENDP        

Clean_VBuff PROC
        mov ecx,320*240
        mov eax,00ffffffh
        rep stosd
        ret
Clean_VBuff ENDP

Clean_WHITE PROC ;edi -> textura a borrar

        mov ecx,256*256
@clean_scr:
        mov eax,00ffffffh
        rep stosd
        ret

Clean_WHITE ENDP


Fade_VBuf PROC ; esi -> origen (se va pintando) edi -> buffer de destino (video)
	mov small VBuffADDR, esi
	mov ecx,0FFh

@fadebloop:

	call DumpVideo
	mov ebx,320*240*4
@fadepixel:
	mov al,[esi+ebx]  ;pillo el byte de origen en al
	mov ah,[edi+ebx]  ;pillo el byte destino en dl
	cmp al,ah
        ja @origMAYORdest
	jb @origMENORdest
	jmp @fadepixelcont
@origMENORdest:
		inc al
		jmp @fadepixelcont
@origMAYORdest:
		dec al
@fadepixelcont:
	mov [esi+ebx],al
	dec ebx
	jnz @fadepixel


	loop @fadebloop
Fade_VBuf ENDP

Text_MIX PROC    ;mezcla esi sobre edi

        mov ecx,256*256

@loopMIX:
        lodsd
        cmp [edi],00ffffffh
        jne @saltar_punto
        mov [edi],eax
@saltar_punto:
        add edi,4
        loop @loopMIX

        ret

Text_MIX ENDP

@endintro:
