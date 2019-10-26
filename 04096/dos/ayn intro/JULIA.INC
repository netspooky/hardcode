;
; julia.asm ,By Wael M. Araiby 2001(c) , email : wael_araiby@yahoo.com
; 3Ayn group ....
;
; Animated julia using assembly language
;

julia_start     :
        mov     ax,cs
        mov     ds,ax
        call    setup_buffer
        mov     es,[vga_buffer]
next_julia      :
        mov     eax,[tcx]
        cmp     eax,65536
        jge     near finish_all

        mov     eax,-100
        mov     [y],eax
.next_y :
        mov     eax,[y]
        cmp     eax,100
        jge     near .finish_y

        mov     eax,-160
        mov     [x],eax
.next_x :
; zx=x<<2;tx=zx*zx        
        mov     eax,[x]
        cmp     eax,160
        jge     near .finish_x

        shl     eax,2
        mov     [zx],eax
        imul    eax,eax
        mov     [tx],eax

; zy=y<<2;ty=zy*zy
        mov     eax,[y]
        shl     eax,2
        mov     [zy],eax
        imul    eax,eax
        mov     [ty],eax

        mov     cx,1
.next_point     :

        mov     eax,[tx]
        add     eax,[ty]
        cmp     eax,262144
        jge     .exit_loop
        cmp     cx,63
        jge     .exit_loop
        mov     eax,[tx]
        sub     eax,[ty]
        add     eax,26214
        sar     eax,8
        push    eax

        mov     eax,[zx]
        imul    eax,[zy]
        shl     eax,1
        add     eax,[tcx]
        sar     eax,8
        mov     [zy],eax
        imul    eax,eax
        mov     [ty],eax

        pop     eax
        mov     [zx],eax
        imul    eax,eax
        mov     [tx],eax

        inc     cx
        jmp     .next_point

.exit_loop      :

        mov     bx,[y]
        add     bx,100
        mov     ax,320
        mul     bx
        mov     bx,[x]
        add     bx,160
        add     ax,bx
        mov     di,ax
        mov     al,cl

        stosb
        inc     dword [x]
        jmp     .next_x
.finish_x       :
        inc     dword [y]
        jmp     .next_y
.finish_y        :
        mov     eax,[tcx]
        add     eax,655
        mov     [tcx],eax

        push    ds
        mov     ds,[vga_buffer]
        call    blure_up
        call    blure_up
        pop     ds

        push    ds
        pusha
        call    wait_retrace
        call    wait_retrace
        mov     ds,[vga_buffer]
        xor     si,si
        xor     di,di
        mov     cx,320*200
        call    show_vga_buffer
        popa
        pop     ds

        mov     ah,01h          ; is keypressed
        int     16h             ; bios keyboard service
        jz      near next_julia ; if not then another loop

finish  :
        xor     ax,ax
        int     16h
finish_all      :
        ret
;
; Julia variables
;
x       dd      -160
y       dd      -100
nx      dd      0
ny      dd      0
zx      dd      0
zy      dd      0
tx      dd      0
ty      dd      0
tcx     dd      -65536
i       dw      0
