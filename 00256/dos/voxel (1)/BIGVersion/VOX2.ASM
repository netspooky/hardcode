
;**************************************************************************
; LandScape over my fractal - Alberto Garcia-Baquero, Jul'96
;
; WiseFX - AliäN '96.
;**************************************************************************
;==========================================================================
; CONSTANTES
;==========================================================================
VGA            EQU 0A000h       ;Segmento de la posici¢n de inicio de la VGA
AnchoPanta     EQU 320
AltoPanta      EQU 200

	      .MODEL TINY
	      .386
	      .CODE
	       ORG 100h

;========================================================================
; CODIGO
;========================================================================

Main    PROC
	CALL    Memoria
	MOV     AX,13h         ;°±² Modo 320x200 256c. VGA
	INT     10h            ;°±²²²²²²²²²²²²²²²²²²²²²²²²²²²

        push    SegiMAGEN
	pop     fs

        PUSH    sEGbuffer
	POP     ES
	MOV     DI, 0
	mov     cx,0ffffh
	mov     al,  1
	rep     stosb

        call    landpal

BUCLE1:
       ;call    cielo
	call ScrollLand
        call LandScape
        mov     ax, ds
        push    es
        pop     ds
        mov     si, 256
        xor     di, di
        mov     cx, (0ffffh-512)/2
        rep     movsw
        mov     ds, ax
        call    cielo

	;----------------------------------------
	; miramos el teclado
	;----------------------------------------
	mov    ah,01h
	int    16h
	jz    BUCLE1
	;----------------------------------------------------------
ADIOS:  MOV     AX,03h         ;°±² Modo 80x20 texto
	INT     10h            ;°±²²²²²²²²²²²²²²²²²²²²²²²²²²²
        MOV  AX,4C00h          ;°±²  N§ de ifunci¢n de la INT 21 a utilizar
        INT  21h               ;°±²  Vuelta al DOS

Main    ENDP

;°±²ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ²±°
;°±      Crea una linea del mapa                          ±°
;°±           Linea -> Linea a crear.                     ±°
;°±²ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ²±°
ScrollLand      PROC
        ;mov     ah,Linea
        ;xor     al,al
        ;mov     cx, 255
           mov     cx, 128
        mov     di, 131*256 ;ax
          push    ax
       ;///////////////////////////////////////////////////
        ;mov     dx,40h
        ;rep     insb
rndt1:      call    random
            stosw
            loop    rndt1
            pop     ax

        add     di,256*19
	mov     ch,    26
	MEDIA:
         movzx ax,es:[di+256 ]
         movzx bx,es:[di+257 ]
         add   ax,bx
         mov   bl,es:[di-255 ]
         add   ax,bx
         mov   bl,es:[di]
         add   ax,bx
         shr    ax, 2
         mov   es:[di],al
         dec   di
        loop  media

	RET
       ;///////////////////////////////////////////////////
ScrollLand      ENDP

;°±²ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ²±°
;°±              HACE LANDSCAPE                           ±°
;°±     rX = X inical    ; rY = Y inicial.                ±°
;°±²ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ²±°
LandScape       PROC

	mov     Xp, 1

	OTRA_X: ;°±² for( ; Xp<  300; Xp++ )
	mov     di,(320*199)      ;°±²
	add     di,Xp             ;°±² DI = Punto inferior de la pantalla.
	mov     ax,rX             ;°±²
	shl     ax,8              ;°±²  Xt      = ((rX)<<8);
	mov     Xt,ax             ;°±²  X inicial de la camara.
	mov     si, 2             ;°±²  Z = SI = 2  . Empieza desde Z =2
	mov     LastY,200         ;°±²
	OTRA_Z:                   ;°±² for(; Z <  160; Z++, Xt += (Xp-160)  )
	    mov     ax,Xt            ;°±²
	    mov     al, 0            ;°±²  ax = (abs(Xt>>8))<<8
	    add     ax,si            ;°±²  ax += Z
	    add     ax,rY            ;°±²  ax += rY
	    xchg    ah,al
	    mov     bx,ax            ;°±²
	    mov     al,es:[bx]       ;°±²  al = Datos[ ax ];
	    mov     color,al         ;°±²  color = Datos[abs(Xt>>8)][(Z+rY)];
	    movzx   ax,color         ;°±²
	    neg     ax
	    inc     ah
            shl     ax,5             ;°±²  ax = color<<6;
	    cwd                      ;°±²
	    idiv    si               ;°±²  ax /= Z;
	    mov     Yp,ax            ;°±²  Yp = (color<<6)/(Z))
	    cmp     ax, LastY        ;°±²
	    jge     NO_PINTA         ;°±²
		mov     cx, LastY      ;°±²
		sub     cx, Yp         ;°±²
		mov     al,color       ;°±²
	    eti:mov     fs:[di],al     ;°±²
		sub     di,320         ;°±²
		dec     cx             ;°±²
		jnz     eti            ;°±²
		mov     ax,Yp          ;°±² LastY = Yp;
		mov     LastY,ax       ;°±²
	    NO_PINTA:                ;°±²
	    mov     ax,Xp            ;°±²
	    add     ax,-160          ;°±²
	    add     Xt,ax            ;°±² Xt += (Xp-160)
	    inc     si               ;°±² Z++
	    cmp     si,120           ;°±²
	    jl      OTRA_Z           ;°±² Hasta que Z llegue hasta el limite.
	inc     word ptr Xp          ;°±² Xp++
	cmp     Xp,319               ;°±² Hasta que Xp llegue a la derecha .. 300
	jl      OTRA_X            ;°±²
	RET
LandScape       ENDP


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Manejo de paleta ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

DAC     PROC
        MOV     DX, 3c8h
        MOV     AL, [DACREG]
        OUT     DX, AL

        INC     DX
        MOV     AL, [R1]
        OUT     DX, AL
        MOV     AL, [G1]
        OUT     DX, AL
        MOV     AL, [B1]
        OUT     DX, AL

        INC     [DACREG]

        RET
ENDP    DAC

;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Refresco vertical ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

;retrace proc
;        mov     dx,03dah         ; Espera a la pantalla
;@SINC0: in      al, dx
;        test    al,  8
;        jnz     @SINC0
;@SINC1: in      al, dx
;        test    al,  8
;        jz      @SINC1
;        ret
;endp    retrace

;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Paleta de landscape ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

landpal proc
        mov     [dacreg], 0
lpal1:
        mov     al, [dacreg]
        mov     [b1], al
        shr     al, 1
        mov     [g1], al
        xor     al, al
        mov     [r1], al
        call    dac

        cmp     [dacreg], 48

        jne     lpal1

lpal2:  mov     al, [dacreg]
        sub     al, 32
        shr     al, 2
        add     al, 10
        mov     [r1], al
        mov     al, [dacreg]
        sub     al, 32
        shl     al, 1
        add     al, [dacreg]
        add     al, 63
        xor     ah, ah
        shr     al, 4
        add     al, 7
        mov     [g1], al
        mov     al, [dacreg]
        sub     al, 32
        shr     al, 3
        add     al, 10
        mov     [b1], al
        call    dac
        cmp     [dacreg], 48+26
        jne     lpal2

lpal3:  cmp     [g1], 62
        je      nomg
        inc     [g1]
        inc     [g1]
nomg:   cmp     [r1], 62
        je      nomr
        inc     [r1]
        inc     [r1]
nomr:   cmp     [b1], 62
        je      nomb
        inc     [b1]
        inc     [b1]
nomb:   call    dac
        cmp     [dacreg], 200
        jne     lpal3

        ret

endp    landpal


cielo   proc
        push    es
        mov     ax, segpanta
        mov     es, ax
        mov     dl, 42
        xor     di, di
        mov     es, ax
        mov     di, 320*5
        ;xor     di, di
cltag1: mov     cx, 160
        mov     al, dl
        mov     ah, dl
        rep     stosw
        inc     al
        inc     ah
        dec     dl
        jnz     cltag1
        pop     es

        ret
endp    cielo

random  proc
        MOV     AX, SEED                            ; linear congruence
        XOR     AX,0AA55h                           ; random generation
        SHL     AX,1                                ; 7 clock ticks (486)!
        ADC     AX,118h
        MOV     SEED, AX                            ; keep result as next seed
        ret
endp    random


;========================================================================
; INCLUDES
;========================================================================
include MEMO.INC

;==========================================================================
;       DATOS
;==========================================================================
SegiMAGEN       EQU    0a000h
RandSeed        DB 37h
RandSeed2       DB 7Ah
Linea           DB   (131)       ;°±²  Linea a generar.
rX              DW   (128)       ;°±²  X origen.
rY              DW   (?)         ;°±²  Y origen.
sEGBUFFER       DW   (?)
color           DB   (?)         ;°±²  color
Xt              DW   (?)         ;°±²  X en mapa.
Xp              DW   (?)         ;°±²  X en pantalla
Yp              DW   (?)         ;°±²  Y en pantalla
LastY           DW   (?)         ;°±² Ultima Y.
r1              db    ?
g1              db    ?
b1              db    ?
dacreg          db    ?
world           dw    ?
seed            dw    ?

	END     Main
