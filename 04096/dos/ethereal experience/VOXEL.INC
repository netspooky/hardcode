;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The voxel part ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns nothing
voxel   proc

        push    ds

        mov     ax, [lastbuf]
        call    clear_seg

        mov     ax, [mixseg]
        call    clear_seg

        mov     ax, [lastbuf]

        mov     ds, cs:[texture]
        mov     es, ax

        mov     bp, 300
voxtmain:

        ; scroll the texture
        push    es

        mov     ax, ds
        mov     es, ax

        xor     di, di
        mov     si, 1
        mov     cx, 0ffffh/2
        rep     movsw

        pop     es

        push    ds
        push    es
        mov     cx, 16000
        xor     di, di
        mov     ax, 300
        sub     ax, bp
        mov     si, ax  ; to add a bit of scroll to sky
        mov     ax, cs:[backseg]
        mov     ds, ax
        mov     ax, cs:[lastbuf]
        mov     es, ax
        rep     movsw
        pop     es
        pop     ds

        call    landscape

        call    outtro

        mov     ax, cs:[mixseg]
        mov     cs:[dumpsrc], ax
        mov     ax, cs:[lastbuf]
        mov     cs:[dumpdst], ax

        call    copynozero

        mov     ax, cs:[lastbuf]

        mov     cs:[dumpsrc], ax
        mov     cs:[dumpdst], vga

        call    retrace
        call    dumpscr

        mov     ax, cs:[lastbuf]
        call    clear_seg

        dec     bp
        jnz     voxtmain

        pop     ds

        ret

endp    voxel


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ The 3D landscape stuff ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns nothing
LandScape       PROC

        mov     cs:[voxx], 320

OTRA_X:
        mov     di, (320*199)
        add     di, cs:[voxx]
        dec     di
        mov     ax, cs:[voxrX]
        shl     ax, 8
        mov     cs:[voxXt], ax
        mov     si, 2
        mov     cs:[vLastY], 200
OTRA_Z:
        mov     ax, cs:[voxXt]
        xor     al, al
        add     ax, si
        add     ax, cs:[voxrY]
        xchg    ah, al
        mov     bx, ax
        mov     al, ds:[bx]
        mov     cs:[color], al
        xor     ah, ah
        cmp     al, 128
        jb      noset3
        or      ah, 128
noset3:
        neg     ax
        inc     ah
        shl     ax, 5
        cwd
        idiv    si
        mov     cs:[voxYp], ax
        cmp     ax, cs:[vLastY]
        jge     NO_PINTA
        mov     cx, cs:[vLastY]
        sub     cx, cs:[voxYp]
        mov     al, cs:[color]
eti:    mov     es:[di], al
        sub     di, 320
        dec     cx
        jnz     eti
        mov     ax, cs:[voxYp]
        mov     cs:[vLastY], ax
NO_PINTA:
        mov     ax, cs:[voxx]
        add     ax, -160
        add     cs:[voxXt], ax
        inc     si
        cmp     si, 120
        jl      OTRA_Z
        dec     word ptr cs:[voxx]
        jz       endx
        jmp     otra_x
endx:
        RET
LandScape       ENDP