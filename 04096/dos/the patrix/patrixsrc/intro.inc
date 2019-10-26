SPSIZE=30

        ;Reservamos memoria-------------------------------------------------

        mov ecx,320*240*4*(num_reservas+1);
        call  alloc_himem



        mov esi,320*240*4

        lea edi,reservas


        mov ecx,num_reservas

@LoopIncr:      mov [edi],ebx
                add ebx,esi
                add edi,4
                loop @LoopIncr

        mov edi,small Sphere1

        mov al,small SPSIZE
        call  GenSphere
        mov ecx,small ModoY

;------------------------------------Generamos la textura ------------------
        call  Gen_Text_256x256

        mov edx,10
        call  Suaviz_N   ;tenemos en scratch_text la textura aleatoria


;------------------------------------------------------------------


        mov edi,small bocadillo
        call Clean_WHITE
        lea esi,bocadillo_sec
        call secuencia

;-------------------------------------------------------------------

        call Gen_Cartman

        mov edi,small kenny
        call Clean_WHITE
        push edi
        lea esi,kenny_body_sec
        call secuencia

;-------------------------------------------------------------------

        pop esi
        mov edi,small kenny_copy
        mov ecx,256*256
        rep movsd
;-------------------------------------------------------------------        


        mov esi,small cartman_body
        mov edi,small scratch_text2
        push edi
        call Suavizar_s1_s2

        mov small degradado,0101h
        pop esi
        mov edi,small Video_Cartman
        call Put128

;-------------------------------------------------------------------

        mov esi,small kenny
        mov edi,small scratch_text2
        push edi
        call Suavizar_s1_s2

        pop esi
        mov small degradado,010101h
        mov edi,small Video_Kenny
        call Put128

;-------------------------------------------------------------------


;black to white

        mov eax,0
        mov edx,010101h
        mov ebx,255

@loopFadeIn:
        mov edi,small VBuffADDR
        mov ecx,320*240
        rep stosd

        pusha
        call DumpVideo
        popa

        add eax,edx
        dec ebx
        jnz @loopFadeIn

;-------------------------------------------------------------------


        mov edi,small kenny
        mov esi,small scratch_text
        call  Text_MIX


        mov eax,small kenny
        xchg eax,small scratch_text
        xchg eax,small kenny

        mov edx,3
        call Suaviz_N

;-------------------------------------------------------------------

        mov small frame,2000
        mov small fijo,1
        mov eax,small scratch_text

;-------------------------------------------------------------------

        mov small textura_efecto,eax
        mov eax,small Video_Kenny
        mov small q_bocadillo,eax
        lea eax,ef_RotoZoom
        mov small efecto,eax
        mov ecx,200
        call Ejecutar_Efecto

;-------------------------------------------------------------------

        mov esi,small Video_Kenny
        mov edi,small VBuffADDR2
        push edi
        mov ecx,320*240
        rep movsd             ;lo copiamos

;-------------------------------------------------------------------

        mov esi,small VBuffADDR
        pop edi
        call Fade_VBuf

        lea eax,ef_Tunnel
        mov small efecto,eax

        xor eax,eax
        mov small fijo,al

        inc eax
        mov small modo_act,eax
        mov small tiempo,100
        mov small init_tiempo,30

        mov eax,small Video_Kenny;Cartman
        mov small q_bocadillo,eax
        mov ecx,530     ;****
        call Ejecutar_Efecto



        lea eax,ef_Rotozoom2
        mov small efecto,eax
        mov eax,small Video_Cartman
        mov small q_bocadillo,eax
        mov ecx,500
        call Ejecutar_Efecto




        mov ax,0c8d8h
        push eax
        mov edi,small offset @mod1
        push edi
        stosw
        stosw


        call EjecutarTunnel

        mov ax,09090h   ;restauramos
        pop edi
        stosw
        stosw

        pop eax
        mov edi,small offset @mod2
        push edi
        stosw
        

        call EjecutarTunnel

        mov ax,09090h  ;restauramos
        pop edi
        stosw





        mov small word ptr @mod3 ,0f2d9h
        mov small word ptr @mod3_,0ffd9h

        call EjecutarTunnel

skip:

        mov esi,Cartman_body
        mov edi,VBuffADDR2
        push edi
        call Clean_VBuff
        pop edi
        call PutTextOnScreen
        
        mov edi,VBuffADDR2
        mov esi,small VBuffADDR
        call Fade_VBuf


        mov ecx,300
@retardo2:
         call EsperarRetrazo
         loop @retardo2


        mov esi,kenny_copy
        mov edi,VBuffADDR2
        call PutTextOnScreen
        
        mov edi,VBuffADDR2
        mov esi,small VBuffADDR
        call Fade_VBuf

        
        mov ecx,400
@retardo:
         call EsperarRetrazo
         loop @retardo




        jmp @endintro



PutTextOnScreen PROC ;esi <- origen   edi <- destino

                
                add edi,((320-256)/2)*4
                mov edx,240
@PTLoopY:
                mov ecx,256
                rep movsd

                add edi,(320-256)*4
                dec edx
                jnz @PTLoopY


                ret                        
PutTextOnScreen ENDP

EjecutarTunnel PROC

                lea eax,ef_Tunnel
                mov small efecto,eax
                mov small fijo,1
                mov ecx,500
                call Ejecutar_Efecto
        
                ret
EjecutarTunnel ENDP


ef_RotoZoom PROC

                cmp frame,90
                jbe @noincframe

                fild frame
                fld fangle
                fsin
                fimul t5
                fiadd t5
                fiadd t5
                fiadd t5
                fsubp
                fistp frame
                jmp skipit
@noincframe:
                mov frame,90    ;recentramos

skipit:
                fld ZooM
                fadd zoominc

                fstp ZooM
                call RotoZoom                
                ret
                     
ef_RotoZoom ENDP

ef_RotoZoom2 PROC



                add frame,1

                fild frame
                fidiv t5

                fsincos
                fld1
                faddp

                fmul zi2
                fadd zi2

                fstp ZooM

                fimul t100
                fist XCenter
                fcos


                call RotoZoom                
                ret
                     
ef_RotoZoom2 ENDP


ef_Tunnel PROC
                mov eax,ecx
                call Tunnel
                call InterpolarUV
                ret
ef_Tunnel ENDP

fijo db 0

Ejecutar_Efecto PROC ;ecx -> iteraciones

@ps:    push ecx


        pusha

        mov esi,small textura_efecto
        mov edi,small VBuffADDR2

        mov eax,small efecto
        call eax

        popa

        mov al,small fijo
        or al,al
        jnz @DibujarSinBocadillo

        dec small Tiempo
        jnz @NoTerminado
        inc small modo_act
        mov eax,small dec_init_tiempo
        add small init_tiempo,eax
        mov eax,small init_tiempo
        mov small Tiempo,eax


@NoTerminado:
        mov eax,small modo_act
        and eax,1h
        jz @DibujarSinBocadillo



        mov edi,small VBuffADDR2    ;en VBuffADDR2 tenemos el efecto
        mov esi,small q_bocadillo   ;en Video_Cartman tenemos el bocadillo
        mov ebx,small VBuffADDR     ;en VBuffADDR El destino

        call DumpBocadillo
        jmp @ok

@DibujarSinBocadillo:
        mov eax,VBuffADDR2
        xchg eax,VBuffADDR
        xchg eax,VBuffADDR2


@ok:


         mov edi,small VBuffADDR
         call Esferitas



        call  EsperarRetrazo

        call  DumpVideo

        pop ecx
        dec ecx
        jnz @ps

        ret
Ejecutar_Efecto ENDP


Esferitas PROC
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
       ; mov edi,small VBuffADDR
        push edi
        mov ecx,small small a
        mov eax,small xt
        mov ebx,small yt
        pusha
        call  PutSphere
        popa

        inc ecx
        cmp ecx,3
        jne @skipitit
        xor ecx,ecx
@skipitit:
        call  PutSphere

        pop edi
        inc small a
        cmp small a,3
        jbe @UnaMas

          ret
Esferitas ENDP

DumpBocadillo PROC ;esi bocadillo
                   ;edi efecto
                   ;ebx destino
        push esi
        push edi
        mov edi,ebx
        mov ecx,320*240
        rep movsd
        pop edi
        pop esi



        add esi,128*4+320*4*20
        add ebx,128*4+320*4*20

        mov edx,4
        mov ecx,100
@loopBocaY:
        push ecx
        mov ecx,160

@loopBocaX:     lodsd

                cmp eax,0fefefeh
                jne @NoCogerEfecto
                mov eax,[edi]

@NoCogerEfecto: mov [ebx],eax
                
                add edi,edx
                add ebx,edx
                add edi,edx ;nos saltamos  1
                loop @loopBocaX

        pop ecx
        add edi,320*4 ;nos saltamos una linea
        add esi,160*4
        add ebx,160*4

        loop @loopBocaY


                ret
DumpBocadillo ENDP



Put128 PROC
        push edi
        call Clean_VBuff
        pop edi
        push edi

        add esi,8*(256*4)
        add edi,((ModoY-128)*ModoX)*4 ;Nos situamos donde queremos pintar

        mov edx,120

@PLoopY:

        mov ecx,128
@PLoopX:
        movsd
        add esi,4
        loop @PLoopX

        add edi,(ModoX-128)*4
        add esi,(256*4)


        dec edx
        jnz @PLoopY

;ahora el bocadillo

        pop edi
        push edi
        add edi,(320-256)*4
        mov esi,small bocadillo


             mov edx,200
@LoopBocadY:    
             mov ecx,256
@LoopBocadX: lodsd
             cmp eax,0ffffffh
             je @saltar

             mov [edi],eax
@saltar:     add edi,4
             loop @LoopBocadX
             add edi,(320-256)*4
             dec edx
             jnz @LoopBocadY


        pop edi

        mov edx,0
        mov ebx,small degradado
        mov ecx,240
@lineaGrad:
        push ecx


         mov ecx,320
@GradX:
        mov eax,[edi]
        cmp eax,0ffffffh
        jne @noPintar
        mov eax,edx
        mov [edi],eax
@noPintar:
        add edi,4
        loop @GradX

        add edx,ebx
        
        pop ecx
        loop @lineaGrad

        ret
Put128 ENDP


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
        push edi
        ;mov ecx,256*256
        xor ecx,ecx
        dec cx
        inc ecx
@clean_scr:
        mov eax,00ffffffh
        rep stosd
        pop edi
        ret

Clean_WHITE ENDP

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

Fade_VBuf PROC ; esi -> origen (se va pintando) edi -> buffer de destino (video)
        ;mov small VBuffADDR, esi
	mov ecx,0FFh

@fadebloop:

        pusha
        mov edi,small VBuffADDR
        Call Esferitas
        popa
        

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

        ret
Fade_VBuf ENDP


@endintro:
