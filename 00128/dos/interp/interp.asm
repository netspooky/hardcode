; File:       interp.asm
; Decription: Mode 13h gradient noise in 8086 assembly
; Author:     orbitaldecay
; Date:       Jan. 2010
; Notes:      No floating point arithmetic used.  Compile using Nasm.  124 bytes.

[bits 16]
[org 0x100]

        mov     al, 0x13
        int     0x10
        push    word 0xA000
        pop     es

ini:
;        inc     si                      ; Uncomment for motion
        xor     di, di

main:   push    cx
        mov     ax, di
        mov     bx, 320
        xor     dx, dx
        div     bx                      ; DX = X, AX = Y
        mov     bx, dx
        mov     dx, 0000000000011111b   ; Bitmask to define hypergrid resolution
        mov     cx, 3                   ; Set recursion depth
        add     ax, si
        add     bx, si
        call    f1			; Calculate pixel value (AX = Y, BX = X)
        add     ax, 16
        stosb
        pop     cx  
        loop    main

        jmp     short ini

; f1(x, y) = (f2(x, y) + f3(x, y)) / (y2 - y1)
f1:     dec     cx              
        jz      prng
        push    di
        push    ax

; f2(x, y) = (y - y1) * f1(y2, x)
        push    bx
        push    ax
        or      ax, dx          ; Calculate y2
        inc     ax
        xchg    ax, bx
        call    f1
        pop     bx
        and     bx, dx          ; Calculate (y - y1)
        push    dx
        mul     bx
        pop     dx
        pop     bx
; End f2(x, y)

        mov     di, ax
        pop     ax

; f3(x, y) = (y2 - y) * f1(y1, x)
        push    bx              
        push    ax
        not     dx              ; Calculate y1
        and     ax, dx
        not     dx
        xchg    ax, bx
        call    f1
        pop     bx
        and     bx, dx          ; Calculate (y2 - y)
        neg     bx
        add     bx, dx
        push    dx
        mul     bx
        pop     dx
        pop     bx
; End f3(x, y)

        add     ax, di
        push    cx              ; Calculate (y2 - y1) and divide
        bsr     cx, dx
        inc     cx
        shr     ax, cl
        pop     cx
        pop     di
        inc     cx
        ret     

; prng(x, y)
prng:   push    bx              ; Prng for height values of hypergrid points
        push    dx
        add     ax, bx
        inc     bx
        mul     bx
        imul    ax, 0x1337      ; Big prime number
        shr     ax, 10          ; Return 0 - 63
        pop     dx
        pop     bx
        inc     cx
        ret
; End prng(x, y)

