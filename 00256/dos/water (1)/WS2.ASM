;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
;  WATER                                ú
;  Code: WiseFX & Shadä / AliäN (C) 96
;  Program size: 238 bytes
;  Needs: 286 and VGA card
;  Greetings to anyone who reads this...
;ú
;À-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

.286
code segment para public 'code'
assume ds:code,cs:code,es:code,ss:code
ORG	100h

;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The constant values ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

D_WIDTH EQU   160                               ; array width
HEIGHT  EQU    94                               ; array height
SCALE2  EQU     7                               ; scaling factor
VISCTY  EQU     4                               ; fluid viscosity
DROP    EQU 12024                               ; drop height


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The program start ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

MAIN:   Mov     Di,OFFSET ARRAY1                ; Set arrays to 0
        Mov     Ch,( (D_WIDTH*(HEIGHT+2)*2) / 256 )
        REP     STOSW

        PUSH    0A000h
        POP     ES                              ; Direct VGA
        MOV     AL,013h                         ; and standard 13h mode
        INT     10h

        in      ax, 40h                         ; init random seed
        mov     SEED, ax                        ; using PIT


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The color creation ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

        inc     cx
pal:    mov     dx, 03c8h
        mov     ax, cx
        out     dx, al
        inc     dx
        shr     ax, 1
        xchg    ah, al
        add     ah, 18
        mov     al, 63
        sub     al, ah
        xor     ah, ah
        xchg    ah, al
        out     dx, al
        xchg    ah, al
        out     dx, al
        out     dx, al
        inc     cx
        cmp     cl, 127
        jne     pal


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The main thing ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

BUCLE:
         mov     cx,(D_WIDTH*(HEIGHT-2))        ; Exchange pointer before
          mov     si,P_DATA                     ; the party begins...
          mov     di,si                         ;
          xchg    si,P_DATA2                    ;
          mov     P_DATA,si                     ;

          WAVING:
           mov     ax,word ptr [di-D_WIDTH*2]   ; this is a diferential
           add     ax,word ptr [di-2 ]          ; function that provides
           add     ax,word ptr [di+2 ]          ; fluid behavior.
           add     ax,word ptr [di+D_WIDTH*2]   ;
           sar     ax, 1                        ;
           sub     ax,[si]                      ;
           mov     [si],ax                      ;
           sar     ax,VISCTY                    ; The higher VISCTY is,
           sub     [si],ax                      ; the wilder the fluid
          inc     di                            ; moves...
          inc     di                            ;
	  inc	  si
	  inc	  si
          loop    WAVING


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Vertical synchro ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

        mov     dx,03dah                        ; Should I comment this?
        @SINC0:
        in      al, dx
        test    al,  8
        jnz     @SINC0
        @SINC1:
        in      al, dx
        test    al,  8
        jz      @SINC1


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The 3D pseudo proyection ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

        mov     ch,(160*(206-HEIGHT))/256;
        xor     di,di                           ; clean screen
        xor     ax,ax
        rep     stosw

        mov     di,320*200                      ; Pointer to screen base
        mov     si,P_DATA                       ; Pointer to water data
        mov     cx,D_WIDTH                      ; CX = Screen width / 2
        passX:
	  push	  si
	  push	  di
	  push	  cx
          xor     ax,ax                         ; AX = Actual height
          xor     bx,bx                         ; BX = Last Y
          xor     dx,dx                         ; DX = Initial color

          passY:
            inc   dl                            ; Increase color
            inc   dh

            mov   cx, [si]                      ; CX = Byte from map
            sar   cx, SCALE2
            add   cx,ax                         ; CX = actual line height
            sub   cx,bx                         ; if reater than previous
            jle   nopixel
              add bx,cx                         ; Actualize last Y with actual Y
              next:
                mov     es:[di],dx              ; set pixel
                sub     di,320                  ; increase line
              loop  next
            nopixel:
            add   si,D_WIDTH*2
            inc   al
          cmp     al,(HEIGHT-4)
          jne     passY

	  pop	  cx
	  pop	  di
	  pop	  si

          dec     di                            ; Next screen X
          dec     di
          inc     si                            ; Next data X
          inc     si
        loop      passX


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The random drop generator ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

        MOV AX, SEED                            ; linear congruence
        XOR AX,0AA55h                           ; random generation
        SHL AX,1
        ADC AX,118h
        MOV SEED, AX                            ; keep result as next seed


        cmp     ax,D_WIDTH*HEIGHT               ; throw random drops
        ja      na
         mov     bx,P_DATA
         sal     ax, 1
	 add	 bx,ax
         mov     word ptr[bx]  ,DROP
         mov     word ptr[bx+2],DROP
        na:

	mov	ah,01h
	int	16h
        jnz     ADIOS
        jmp     BUCLE


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The program end ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

ADIOS:  MOV     AX,03h                          ; back to text mode
        INT     10h
	RET


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The data arrays and variables ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

SEED    DW ?
P_DATA  DW OFFSET ARRAY1+D_WIDTH*4
P_DATA2 DW OFFSET ARRAY2+D_WIDTH*4
ARRAY1  DW D_WIDTH*(HEIGHT+2) DUP ( ? )
ARRAY2  DW D_WIDTH*(HEIGHT+2) DUP ( ? )

ends
end MAIN

;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The authors' note ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
; Use this code freely, you have our permission.
; All we want is to be credited in your production...
; And the same way we want to be credited,
; we thank iGUANA for the idea an the explaining DOCS...
; we should credit and thank DE-Phassed / Reset - TVC
; for his sources and stuff...
;
; Remember that nobody was born with knowledge... :)
;
;                       Signed: Shadä / AliäN
