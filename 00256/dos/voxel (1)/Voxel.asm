;**************************************************************************
; LandScape over my fractal - Alberto Garcia-Baquero, Jul'96
;
; WiseFoX - AlieN '96.
;**************************************************************************
;==========================================================================
; CONSTANTES
;==========================================================================
VGA	       EQU 0A000h	;Segmento de la posici¢n de inicio de la VGA
AnchoPanta     EQU 320
AltoPanta      EQU 200
Linea	       EQU    111	;°±²  Linea a generar.

	      .MODEL TINY
	      .386
	      .CODE
	       ORG 100h

;========================================================================
; CODIGO
;========================================================================

Main	PROC
	MOV	AL,13h			;°±² Modo 320x200 256c. VGA
	INT	10h			;°±²
	MOV BH,1			;°±² Reserva 256*16 = 4 Kb
	MOV AH,4Ah			;°±² Modifica el tama¤o del bloque reservado
	INT 21h 			;°±² al segmento indicado en ES.Ahora ES = Seg.Programa
	PUSH VGA			;°±²
	POP  FS 			;°±²
	MOV BX,8096			;°±² N£mero de p rrafos. 64k/16 bytes por p rrafo
	MOV AH,48h			;°±²
	INT 21h 			;°±² Reserva memoria
	MOV	ES,AX			;°±² Ajustamos segmentos
	MOV	DS,AX			;°±²
	XOR	CX,CX			;°±²
	MOV	AX,CX			;°±² Limpiamos el segmento.
	DEC	CX			;°±²
	REP	STOSB			;°±²
					;°±²
        MOV    DX,03C8H                 ;°±² Definimos la paleta.
        OUT    DX,al                    ;°±²
        INC    DX
        MOV    CL,128                   ;°±²
       @BUCLE_DAC:                      ;°±²
        xor    ax,ax                    ;°±²
        OUT    DX,al                    ;°±²
        mov    al,cl                    ;°±²
        neg    al                       ;°±²
        OUT    DX,AL                    ;°±²
        neg    al                       ;°±²
        OUT    DX,AL                    ;°±²
        LOOP   @BUCLE_DAC               ;°±²

BUCLE1: MOV	ch,1			;°±² CX = 256... 1 linea.
	mov	di,Linea*256		;°±² DI = Linea * 256
        mov     dx,40h                  ;°±²
        rep     insb                    ;°±² Pone linea aleatoria.
;    kk: MOV     AX, SEED                            ; linear congruence
;        XOR     AX,0AA55h                           ; random generation
;        SHL     AX,1                                ; 7 clock ticks (486)!
;        ADC     AX,118h
;        MOV     SEED, AX                            ; keep result as next seed
;        stosb
;        loop    kk

	add	di,256*19		;°±² Sube 19 lineas
	mov	ch,    27		;°±² Retrocedera 27.
	MEDIA:				  ;°±²
;        mov   al,[di+256   ]             ;°±²
         mov   al,[di+256   ]             ;°±²
         add   al,[di+256-1 ]             ;°±²
	 add   al,[di]			  ;°±²
         add   al,[di+1]                  ;°±²
         shr   aL, 2                      ;°±² Hace la media.
	 mov   [di],al			  ;°±²
	 dec   di			  ;°±²
	loop  media			  ;°±²
	mov  si,256			;°±² Hace scroll
	mov  di,cx			;°±² de una linea.
	dec  cx 			;°±² CX = ffffh
	rep  movsb			;°±²

       ;°±ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov	Dl, 1
	OTRA_X: ;°±² for( ; DX<  320; dx++ )
	mov	di,(320*199)	  ;°±²
	add	di,dx		  ;°±² DI = Punto inferior de la pantalla.
	mov	bx,128*256	  ;°±²	X inicial de la camara.
	mov	si, 2		  ;°±²	Z = SI = 2  . Empieza desde Z =2
	mov	bp,200		  ;°±²
	OTRA_Z: 		  ;°±² for(; Z <  160; Z++, Xt += (Xp-160)  )
           PUSH    BX               ;°±²
           PUSH    DX               ;°±²
            mov     bl, 0            ;°±²  ax = ((Xt>>8))<<8
	    add     bx,si	     ;°±²  ax += Z
	    xchg    bh,bl	     ;°±²
	    mov     al,[bx]	     ;°±²  al = Datos[ ax ];
            mov     bl,al            ;°±²  bl = color = Datos[abs(Xt>>8)][(Z+rY)];
	    cbw 		     ;°±²
            neg     ax               ;°±²
            inc     ah               ;°±²
	    shl     ax,4	     ;°±²  ax = color<<6;
	    cwd 		     ;°±²
	    idiv    si		     ;°±²  ax /= Z;
            cmp     ax,bp            ;°±²  ax=Yp = (color<<6)/(Z))
	    jge     NO_PINTA	     ;°±²
		mov	cx, bp	       ;°±²
                sub     cx, ax         ;°±²
                mov     bp, ax         ;°±² LastY = Yp;
            eti:mov     fs:[di],bl     ;°±²
		sub	di,320	       ;°±²
		LOOP	eti	       ;°±²
	    NO_PINTA:		     ;°±²
           POP     DX               ;°±²
           POP     BX               ;°±²
           add     bx,dx            ;°±²
           sub     bx,160           ;°±²
           inc     si               ;°±² Z++
           cmp     si,Linea-10      ;°±²
           jl      OTRA_Z           ;°±² Hasta que Z llegue hasta el limite.
        inc     DX                  ;°±² Xp++
        cmp     DX,319              ;°±² Hasta que Xp llegue a la derecha .. 300
	jl	OTRA_X		  ;°±²
	;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	; Miramos el teclado
	;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov    ah,01h
	int    16h
	jz    BUCLE1
	;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ADIOS:	MOV	AX,03h	       ;°±² Modo 80x20 texto
	INT	10h	       ;°±²²²²²²²²²²²²²²²²²²²²²²²²²²²
        MOV  AX,4C00h          ;°±²  N§ de ifunci¢n de la INT 21 a utilizar
        INT  21h               ;°±²  Vuelta al DOS

Main	ENDP
SEED    dw (?)
	END	Main
