; ===========================================================================
; plasmic / luks <luks@host.sk>
; ---------------------------------------------------------------------------
; just a some plasma with ugly palette morphing. nothing special, because
; i done it in big hurry (some days before compo).
; ===========================================================================

[BITS 16]
[ORG 0x100]
[SECTION .text]

        mov     al,0x13
        int     0x10

;; do cosinus table
;; --------------------------------------------------------------------------

cosinus mov     cx,0x783F
        xor     si,si
        mov     bx,costab
.loop   mov     ax,0xFFD9
        imul    cx
        add     si,dx
        add     cx,si
        mov     [bx],ch
        sar     byte [bx],1
        inc     bl
        jnz     .loop

        push    word 0xA000
        pop     es

;; wait for retrace
;; --------------------------------------------------------------------------

retrace mov     dx,0x03DA
.loop1  in      al,dx
        test    al,8
        jz      .loop1
.loop2  in      al,dx
        test    al,8
        jnz     .loop2

;; set palette
;; --------------------------------------------------------------------------

palette mov     dx,0x03C8
        xor     al,al
        out     dx,al
        inc     dx

        mov     si,1
.colors mov     cl,127

        mov     bl,[shift]
        mov     ax,si
        mul     cl
        add     bl,al
        or      bl,bl
        jnz     .calc
        inc     byte [color+si]
.calc   mov     ch,194
        add     ch,[bx]

.loop   movzx   bp,[color+si]
        add     bp,si
        and     bp,7
        movzx   di,[colors+bp]

        mov     bp,4
        mov     bl,127
        sub     bl,cl
        cmp     cl,64
        jge     .setrgb
        mov     bl,cl

.setrgb mov     al,bl           ; set one color (r,g,b)
        test    di,bp
        jnz     .out
        inc     al
        mul     ch
        shr     ax,8
.out    out     dx,al
        shr     bp,1
        jnz     .setrgb

.next   dec     cl              ; loop for 128 colors
        jns     .loop

        dec     si              ; loop for two palettes (0..127,128..255)
        jns     .colors

;; draw plasma
;; --------------------------------------------------------------------------

plasma  xor     di,di           ; set screen offset

        inc     byte [shift]    ; update plasma #1

        add     dword [starts], dword 0xFD04FF02        ; update plasma #2
        mov     ax,word [starts+2]
        mov     bp,temps
        mov     word [bp+2],ax

        mov     cx,200

.loopy  mov     si,320

        mov     bl,cl           ; plasma #1 y
        mov     dl,[shift]
        add     bl,dl
        mov     dh,[bx]
        mov     bl,dh

        mov     ax,word [starts]; plasma #2 y
        mov     word [bp],ax

.loopx  mov     al,[bx]         ; plasma #1 x
        sub     al,cl
        add     al,dh
        add     al,dl
        inc     bl

        push    bx              ; plasma #2 x
        push    cx
        mov     cx,3
.plas2  mov     bl,[bp]
        inc     bp
        mov     ah,[bx]
        sar     ah,1
        add     al,ah
        loop    .plas2
        sub     bp,byte 3
        pop     cx
        pop     bx

        stosb

        add     word [bp],word 0x0201   ; update x-temps for plasma #2

        dec     si
        jnz     .loopx

        add     word [bp+2], word 0x0102        ; update y-temps for plasma #2

        loop    .loopy

;; check keyboard
;; --------------------------------------------------------------------------

        mov     ah,0x11
        int     0x16
        jz      near retrace

;; exit
;; --------------------------------------------------------------------------

        mov     ax,0x03
        int     0x10

        ret

colors  db      100b, 010b, 001b, 101b, 110b, 011b, 001b, 101b
color   db      0, 1

[ABSOLUTE 0x200]

costab  resb    256
starts  resd    1
temps   resd    1
shift   resb    1

