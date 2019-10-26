; Life simulator, 72 bytes  - Vladislav Kaipetsky and Tenie Remmel

; If no args, regs on startup are:

; AX = BX = 0000h
; SI = IP = 0100h
; DI = SP = FFFEh

IDEAL
MODEL TINY
P386
CODESEG
ORG 100h

Start:
        mov     al,13h          ; Set mode 13h
        int     10h

        mov     ds,ax           ; Seed RNG with clock
        mov     ax,[033Ch]

        push    09000h          ; DS = last 64K segment
        pop     ds
        push    0A000h          ; ES = video memory
        pop     es
                                ; BX is already zero
RandLoop:
        add     ax,ax           ; Generate random number
        setc    [bx]
        jnc     RandSkip
        xor     al,45
RandSkip:
        dec     bx
        jnz     RandLoop

; BX will not be equal to 3 the first time this loop is executed, but
; it will be for all other times.   As SI = 0100h and DI = FFFEh on
; startup, SI - DI will be equal to 258.

LifeLoop:
        xchg    cx,ax
AccLoop:
        add     cl,[di+bx-64]   ; Add in this column
        add     cl,[si+bx-2]
        add     cl,[si+bx+318]
        dec     bx              ; Loop back
        jnz     AccLoop

        mov     al,[si]         ; Get center cell, set pixel
        stosb
        stc                     ; 3 = birth, 4 = stay (tricky):
        rcr     al,cl           ; 1.00?0000x --> 0.0x100?00 (rcr 3)
        and     al,20h          ; ^carry   |         ^
                                ;          +---> 0.00x100?0 (rcr 4)
        or      [si],al         ; Add in new cell     ^
        shr     [byte di-65],5  ; Shift previous value

        mov     bl,3            ; 3 iterations in AccLoop
        inc     si              ; Loop while not zero
        jnz     LifeLoop

        mov     ah,1            ; Check for key
        int     16h
        jz      LifeLoop        ; Loop if no key

        xchg    ax,bx           ; Set text mode
        int     10h
        ret                     ; Return

End     Start
