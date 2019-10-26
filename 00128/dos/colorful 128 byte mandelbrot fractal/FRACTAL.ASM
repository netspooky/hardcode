; Colorful 128 byte Mandelbrot fractal by KranK (johannes@localtalk.org)

SEGMENT Code PARA

.386

ASSUME cs:Code,ds:Code,ss:Code
ORG 100h

; Calculate color value of pixel
GetColor MACRO

        mov     cl,32
        xor     si,si

        ColorLoop:
            sub     si,ax
            add     si,[Cr]
            mov     ax,[Zr]
            mov     bp,[Zi]
            imul    bp
            shrd    ax,dx,fBits-1
            add     ax,[Ci]
            mov     [Zi],ax
            mov     [Zr],si

            inc     cl
            cmp     cl,MaxIterations+32
            jz      SHORT GotColor

            imul    ax
            shrd    ax,dx,fBits
            mov     bp,ax
            xchg    si,ax
            imul    ax
            shrd    ax,dx,fBits
            add     bp,ax
            xchg    si,ax
            cmp     bp,4*fMax
            jl      SHORT ColorLoop

    GotColor:

ENDM

Mandelbrot MACRO

        mov     ah,-2*fMax/256
        mov     [Cr],ax
        mov     [Ci],ax

        ;height is 200 pixels
        mov     cl,200
        
        ;loop along y-axis
    VertLoop:
            ;width is 320 pixels
            mov     bx,320
            push    cx

            ;loop along x-axis
        HorizLoop:
                mov     [Zr],ax
                mov     [Zi],ax

                ;calculate color for current pixel
                GetColor

                mov     ax,cx
                stosb 
                mov     al,4*fMax/320
                add     [Cr],ax
                dec     bx
                jnz     SHORT HorizLoop

            ;makes the fractal fit the screen
            ;but the size exceeds 128 bytes :P
            ;mov     al,fMax*4/200

            add     [Ci],ax
            mov     ax,-2*fMax
            mov     [Cr],ax
            pop     cx
            loop    VertLoop
ENDM

Start:
        ;set graphics
        mov     al,13h
        int     10h

        ;video memory segment
        push    0A000h
        pop     es

        ;output mandelbrot fractal to screen
        Mandelbrot
        
        ;wait for a keypress
        xor     ah,ah
        int     16h

        ;back to text mode
        mov     ax,3h
        int     10h

        ret

fBits           EQU 8
fMax            = 1
REPT fBits
        fMax    = fMax*2
ENDM

MaxIterations   EQU 16

Cr              dw ?
Ci              dw ?
Zr              dw ?
Zi              dw ?

ENDS Code
END Start
