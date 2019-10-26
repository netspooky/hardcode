; ------------------------------------------------------------------
; Cantorus, a not-quite 256 bytes effect for Main party 2007
; Rouquemoute/Titan, 3/10/2007
; ------------------------------------------------------------------

; My First effect! Done almost entirely at the party.
; There is room for optimization, but since it was for a 4k-compo,
; 377 bytes were good enough :)

; Uses a Cellular Automaton to generate the beat pattern.

; Compile with FASM

bob         equ     0110111111110110b
CArule      equ     byte 120
CAseed      equ     word 11b
StartInst   equ     36

org 100h
            mov     bp,Buffer
            mov     al,13h
            int     10h

            mov     dx,0331h            ; kicks MPU in UART mode (i.e. not Intelligent)
            mov     al,3Fh		; by sending 3Fh on command port
            out     dx,al

            mov	    al,1h
            mov	    dx,3C8h
	    out	    dx,al
	    inc	    dx

palette:    xchg    ax,cx
            out     dx,al               ; red
            xchg    ax,cx
            out     dx,al               ; green
            xchg    ax,bx
            out     dx,al               ; blue
            xchg    ax,bx
            inc     al
            jnz     palette

            call    gettick
            xor     cx,cx               ; initialize counter
            
start:      push    cx

            push    cs                  ; clear frame buffer
            pop     es
            mov     di,bp
            mov     cx,64000
            xor     ax,ax
            rep stosb
            push    0A000h
            pop     es

            fild    word [0FFFCh]       ; modulate a by somehting like cos(omega*counter)
            fidiv   [aspeed]            ; (gets the counter on the stack since fild doesn't accept registers)
            fcos
            fld     [aamp]
            fmulp
            fld     [amean]
            faddp
            fstp    [a]

            xor     ax,ax
            int     01Ah
            mov     cx,[tick]
            add     cx,3
            cmp     dx,cx
            jge     beat
            mov     cx,[percnb]
            jmp     kam
            
beat:       call    gettick

line:       mov     cx,16
            mov     al,CArule

automaton:  mov     dx,CAseed
            rol     dx,cl
            and     dx,111b
            bt      ax,dx
            rcr     bx,1
            loop    automaton

            rol     bx,1                ; rotation correction for the Cellular Automaton
            mov     [automaton+1],bx

drums:      and     bx,111b             ; 3 MIDI Instruments
            bsr     cx,bx
            jz      silence
            mov     dx,0330h
            mov     al,099h		; send channel 10 note on (percussions) on midi port data
            out     dx,al
            mov     al,StartInst
            add     al,cl
            out     dx,al
            mov     al,07Fh
            out     dx,al
            add     cx,3
            jmp     savebeat

silence:    mov     cx,1
            dec     [silencecnt]

savebeat:   mov     [percnb],cx

kam:        push    cx
            mov     [orbitcnt],cx

            fninit                      ; empty stack
            fld     [a]                 ; a
            fsincos                     ; cosa  sina
            fld     [deltainc]
            fimul   word [percnb]
            fld     [deltamin]
            faddp                       ; delta  cosa  sina
            fimul   word [orbitcnt]     ; counter*delta  cosa  sina
            fld     st0                 ; counter*delta  counter*delta  cosa  sina
            mov     cx,1000

; State of FPU stack: x0  y0  cosa  sina
; with x0 = y0 = orbit radius
       			
orbit:	    mov     al,cl
            push    cx

            fld	    st0		        ; x  x  y  cosa  sina
            fmul    st0,st1             ; x^2  x  y  cosa  sina
            fsubrp  st2,st0             ; x  x^2-y  cosa  sina
            fld     st1                 ; x^2-y  x  x^2-y  cosa  sina
            fmul    st0,st3             ; cosa*(x^2-y)  x  x^2-y  cosa  sina
            fld	    st1		        ; x  cosa*(x^2-y)  x  x^2-y  cosa  sina
            fmul    st0,st5             ; sina*x  cosa*(x^2-y)  x  x^2-y  cosa  sina
            fsubrp  st1,st0             ; sina*x-cosa*(x^2-y)  x  x^2-y  cosa  sina
            fld     st0                 ; sina*x-cosa*(x^2-y)  sina*x-cosa*(x^2-y)  x  x^2-y  cosa  sina
            fimul   word [rx]           ; xc*sina*x-cosa*(x^2-y)  sina*x-cosa*(x^2-y)  x  x^2-y  cosa  sina
            fiadd   word [rx]           ; xc*sina*x-cosa*(x^2-y)+xc  sina*x-cosa*(x^2-y)  x  x^2-y  cosa  sina
            fistp   [X]                 ; sina*x-cosa*(x^2-y)  x  x^2-y  cosa  sina
            fxch    st2                 ; x^2-y  x  sina*x-cosa*(x^2-y)  cosa  sina
            fmul    st0,st4             ; sina*(x^2-y)  x  sina*x-cosa*(x^2-y)  cosa  sina
            fxch                        ; x  sina*(x^2-y)  sina*x-cosa*(x^2-y)  cosa  sina
            fmul    st0,st3             ; cosa*x  sina*(x^2-y)  sina*x-cosa*(x^2-y)  cosa  sina
            faddp                       ; cosa*x+sina*(x^2-y)  sina*x-cosa*(x^2-y)  cosa  sina
            fld     st0                 ; cosa*x+sina*(x^2-y)  cosa*x+sina*(x^2-y)  sina*x-cosa*(x^2-y)  cosa  sina
            fimul   word [ry]           ; yc*cosa*x+sina*(x^2-y)  cosa*x+sina*(x^2-y)  sina*x-cosa*(x^2-y)  cosa  sina
            fiadd   word [ry]           ; yc*cosa*x+sina*(x^2-y)+yc  cosa*x+sina*(x^2-y)  sina*x-cosa*(x^2-y)  cosa  sina
            fistp   [Y]		        ; cosa*x+sina*(x^2-y)  sina*x-cosa*(x^2-y)  cosa  sina

            mov     di,[Y]	        ; compute position of the ball in frame buffer
            imul    di,320
            add     di,[X]
            add     di,bp

            mov     bx,bob
            mov     cx,4

Row:        mov     dx,4

Col:        rol     bx,1
            jnc     Black
            mov     [di],al

Black:      inc     di
            dec     dx
            jnz     Col
            add     di,320-4
            loop    Row
        
            pop     cx
            loop    orbit
            
            pop     cx
            dec     cx
            jnz     kam

            mov     dx,3DAh
retrace:    in      al,dx
            test    al,8
            jz      retrace

            xor     di,di	        ; copy frame buffer to screen
            mov     si,bp
            mov     cx,64000
            rep     movsb

            pop     cx                  ; read keyboard
            mov     ah,1
            int     16h
            jnz     exit
            inc     cx
            mov     ax,[silencecnt]
            or      ax,ax
            jnz     start

exit:       ret

gettick:    xor     ax,ax               ; Get the PC tick counter (roughly 18 clicks per second)
            int     01Ah
            mov     [tick],dx
            ret

rx          dw      160
ry          dw      100
aspeed      dw      80
aamp        dd      0.2
amean       dd      1.1
deltainc    dd      0.01
deltamin    dd      0.05
percnb      dw      1
silencecnt  dw      40
orbitcnt    dw      ?
tick        dw      ?
X           dw      ?
Y           dw      ?
a           dd      ?
Buffer:
