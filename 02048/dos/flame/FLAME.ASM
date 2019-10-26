; FLAME coded by Bernard Schmitz 4/9/93
; Modified by Christopher L. Tumber 5/9/93

; Define EIGHT to average eight pixels instead of four.
; It's a bit slower, but looks better IMHO.

        title   flame

        locals

        .model  small

        .stack  1024

; buffers to hold frames

f1      segment byte

frame1  db      32000 dup(?)

        ends

f2      segment byte

frame2  db      32000 dup(?)

        ends

        .data

; random number seed

seed    dd      ?

; message

bye     db      'FLAME was coded by Bernard Schmitz on the 4th of September 1993', 13, 10
        db      'Internet: c8902477@peach.newcastle.edu.au', 13, 10
        db      'Modified by Christopher L. Tumber',13,10
        db      'Internet: aa993@freenet.carleton.ca',13,10
        db      13, 10
        db      'Inspired by FIRE coded by Jare of VangeliSTeam.', 13, 10
        db      'Another quality release from SPM'
        db      '$'

; palette

pal     label   byte
        i=0
        rept    8
        db      0, 0, i*2
        i=i+1
        endm

        i=0
        rept    8
        db      i*2, 0, 16-2*i
        i=i+1
        endm
        i=0
        rept    16
        db      16+47*i/16, 0, 0
        i=i+1
        endm
        i=0
        rept    24
        db      63, 21*i/8, 0
        i=i+1
        endm
        i=0
        rept    24
        db      63, 63, 21*i/8
        i=i+1
        endm

        db      179*3 dup(63)

        .code
        .386

main    proc

        mov     ax, 0013h               ; mode 13h
        int     10h


        mov     ax, @data               ; setup palette
        mov     ds, ax
        mov     dx, 3c8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     cx, 256*3
        mov     si, offset pal
        align   2
@@p1:
        mov     al, [si]
        out     dx, al
        inc     si
        dec     cx
        jnz     @@p1

        cld

        mov     ax, f1                  ; setup frame segments
        mov     fs, ax
        mov     ax, f2
        mov     gs, ax

        push    fs                      ; clear frame one
        pop     es
        xor     di, di
        xor     eax, eax
        mov     cx, 320*100/4     ;200 For full screen
        rep
        stosd

        push    gs                      ; clear frame two
        pop     es
        xor     di, di
        xor     eax, eax
        mov     cx, 320*100/4     ;200 for full screen
        rep
        stosd
        align   2
@@l0:
        push    fs
        pop     ds
        mov     si, 321
        push    gs
        pop     es
        mov     di, 1
        mov     cx, 320*100-322      ;200 for full screen
        xor     bl, bl
        align   2
@@l1:
        xor     ax, ax
        add     al, [si-320]
        adc     ah, bl
        add     al, [si+320]
        adc     ah, bl
        add     al, [si-1]
        adc     ah, bl
        add     al, [si+1]
        adc     ah, bl
ifdef   eight
        add     al, [si-321]
        adc     ah, bl
        add     al, [si+321]
        adc     ah, bl
        add     al, [si-319]

        adc     ah, bl
        add     al, [si+319]
        adc     ah, bl
        shr     ax, 3
else
        shr     ax, 2
endif
        or      ax, ax
        je      short @@l2
        dec     al
        align   2
@@l2:
        mov     es:[di], al
        inc     di
        inc     si
        dec     cx
        jnz     @@l1

        mov     edx, 69069
        mov     di, 320*98   ;198 for full screen
        mov     cx, 320
        mov     ax, @data
        mov     ds, ax
        mov     eax, seed
        align   2
@@l3:
        imul    eax, edx
        inc     eax
        mov     bl, ah
        and     bl, 0fh
        add     bl, 64
        mov     es:[di-320], bl
        imul    eax, edx
        inc     eax
        mov     bl, ah
        and     bl, 0fh
        add     bl, 64
        mov     es:[di], bl
        imul    eax, edx
        inc     eax
        mov     bl, ah
        and     bl, 0fh
        add     bl, 128
        mov     es:[di+320], bl
        inc     di
        dec     cx
        jnz     @@l3

        imul    eax, edx
        inc     eax
        mov     cl, al
        and     cx, 000fh
        mov     si, 320*98       ;198 for full screen
        align   2
@@l4:
        imul    eax, edx
        inc     eax
        mov     ebx, eax
        mov     bl, bh
        xor     bh, bh
        mov     di, si
        add     di, bx
        add     di, 32
        xor     bl, bl
        not     bl
        mov     es:[di-320], bl
        mov     es:[di+320], bl
        mov     es:[di-1], bl
        mov     es:[di+1], bl
        mov     es:[di], bl
        mov     es:[di-319], bl
        mov     es:[di+319], bl
        mov     es:[di-321], bl
        mov     es:[di+321], bl
        dec     cx
        jnz     @@l4

        mov     seed, eax               ; save random number seed

        mov     ax, 40960+1920              ; display current frame
        mov     es, ax
        xor     di, di
        push    gs
        pop     ds
        xor     si, si
        mov     cx, 320*100/4         ;100 for full screen
        rep
        movsd

        push    fs                      ; swap frames
        pop     ax
        push    gs
        pop     fs
        mov     gs, ax

        mov     ah, 01h                 ; check for key
        int     16h
        jz      @@l0

        xor     ah, ah
        int     16h                     ; get key

        mov     ax, 0003h               ; back to text screen
        int     10h

        mov     ax, @data               ; print message
        mov     ds, ax
        mov     dx, offset bye
        mov     ah, 9
        int     21h

        mov     ax, 4c00h               ; quit to dos
        int     21h

main    endp

        end     main
