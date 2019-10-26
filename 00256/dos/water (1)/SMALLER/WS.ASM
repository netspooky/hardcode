.286
;**************************************************************************
; Agua de ?? bytes !!!	- Alberto Garcia-Baquero, Ene'96
; Trabaja bajo cualquier 386 o superior con una tarjeta VGA
; FX - AliäN '95.
;**************************************************************************
code segment para public 'code'
assume ds:code,cs:code,es:code,ss:code
ORG	100h

ANCHO	EQU 160
ALTO    EQU 94
SCALE   EQU 12
SCALE2  EQU  4
DISPER  EQU  4
GOTA    EQU 1024

;**************************************************************************
;**************************************************************************
;==========================================================================
;      Rutina principal
;==========================================================================
MAIN:   Mov     Di,OFFSET TABLA1  ; Ponemos las tablas a 0
        Mov     Ch,( (ANCHO*(ALTO+2)*2) / 256 )
        REP     STOSW

	PUSH	0A000h		  ;
	POP	ES		  ; Directamente en RAM
	MOV	AL,013h 	  ; A mi modo gr fico...
	INT	10h		  ;


        mov    al, 1              ; Desde el color 1
        mov    dx,03C8h
        out    dx,al
        inc    dl
        dec    cl
       @BUCLE_DAC:
        mov    al,cl
        shr    al,1
        out    dx,al
        out    dx,al
        neg    ax
        sar    al,1
        out    dx,al
        loop   @BUCLE_DAC

;--------------------------------------------------

;--------------------------------------------------
; RUTINA PRINCIPAL
;--------------------------------------------------
BUCLE:	;------------------------------------------
         mov     cx,(ANCHO*(ALTO-2)) ;/256
          mov     si,DATOS
          mov     di,si
          xchg    si,DATOS2
          mov     DATOS,si

          ONDEANDO:
           mov     ax,word ptr [di-ANCHO*2]
           add     ax,word ptr [di-2 ]
           add     ax,word ptr [di+2 ]
           add     ax,word ptr [di+ANCHO*2]
           sar     ax, 1
           sub     ax,[si]
           mov     [si],ax
           sar     ax,DISPER
           sub     [si],ax
	  inc	  di
	  inc	  di
	  inc	  si
	  inc	  si
          loop    ONDEANDO

	;--------------------------------------------------
        mov     dx,03dah         ; Espera a la pantalla
        @SINC0:
        in      al, dx
        test    al,  8
        jnz     @SINC0
        @SINC1:
        in      al, dx
        test    al,  8
        jz      @SINC1

	;--------------------------------------------------
        mov     ch,(160*(206-Alto))/256;
        xor     di,di           ;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        xor     ax,ax           ;³ Borra la pantalla ³
        rep     stosw           ;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

        mov     di,320*200      ; Puntero a la parte baja de la pantalla
	mov	si,DATOS	; Puntero a los datos de agua
	mov	cx,ANCHO	; CX = Ancho de pantalla / 2
	pasaX:
	  push	  si
	  push	  di
	  push	  cx
	  xor	  ax,ax 	; AX = ALTO. ACTUAL.
	  xor	  bx,bx 	; BX = Ultima Y
          xor     dx,dx         ; DX = Color inicial

	  pasaY:
            inc   dl            ; Aumenta el color
            inc   dh            ; Aumenta el color

            mov   cx, [si]      ; CX = Dato del mapa
            sar   cx, SCALE2
            add   cx,ax         ; CX = Altura de la linea actual.
            sub   cx,bx         ; Si es mayor que la anterior Y.
            jle   nopinta
              add bx,cx            ; Actualiza la ultima Y con valor actual de Y
	      otro:
                mov     es:[di],dx ; Pone punto
                sub     di,320     ; Sube linea.
	      loop  otro
	    nopinta:
            add   si,ANCHO*2
            inc   al
          cmp     al,(ALTO-4)
	  jne	  pasaY

	  pop	  cx
	  pop	  di
	  pop	  si

	  dec	  di		; Siguiente X en pantalla...
	  dec	  di		;
	  inc	  si		; Siguiente X en datos......
	  inc	  si		;
	loop	  pasaX

        in      ax,40h          ;----------------------------------------
        cmp     ax,ANCHO*ALTO   ; Ponemos gotitas en el agua.. :)
        ja      na
         mov     bx,DATOS
         sal     ax, 1
	 add	 bx,ax
         mov     word ptr[bx]  ,GOTA
         mov     word ptr[bx+2],GOTA
        na:

	mov	ah,01h
	int	16h
        jnz     ADIOS                ;----------------------------------------
	jmp	BUCLE
	;---------------------------------------------------------------------
ADIOS:	MOV	AX,03h		     ;____/ \___\   Nos ponemos en el
	INT	10h		     ;	  \_/	/ modo raro ese de las letritas.:)
	RET

DATOS   DW OFFSET TABLA1+ANCHO*4
DATOS2  DW OFFSET TABLA2+ANCHO*4
TABLA1  DW ANCHO*(ALTO+2) DUP ( ? )
TABLA2  DW ANCHO*(ALTO+2) DUP ( ? )

ends
end MAIN
