;
; mandelbrot plotter, 61 bytes - Tenie Remmel
;
; assumes on startup:
;   ax = 0000h
;   di = fffeh
;

        IDEAL
        MODEL TINY
        P386
        CODESEG
        ORG 100h

start:
        push    0A000h          ; set segment
        pop     es
        mov     al,013h         ; set video mode
        int     10h
        stosw
        mov     cl,200          ; screen height
outer_loop:
        mov     si,320          ; screen width
inner_loop:
        mov     bp,79           ; #iterations
        xor     bx,bx           ; zero real part
        xor     dx,dx           ; zero imaginary part

complex_loop:
        push    dx
        mov     ax,bx
        sub     ax,dx
        add     dx,bx
        imul    dx              ; u:=re^2-im^2;
        mov     al,ah
        mov     ah,dl
        pop     dx
        xchg    bx,ax
        sub     bx,si           ; new_re:=u-width;
        imul    dx
        shld    dx,ax,9         ; 2*re*im
        sub     dx,cx           ; new_im:=2*rm*im-height
        test    dh,dh           ; if dh<>0 plot pixel
        jg      short plot_color
        dec     bp              ; next iteration
        jne     short complex_loop

plot_color:
        xchg    bp,ax
        stosb                   ; plot pixel
        dec     si
        jne     short inner_loop
        loop    short outer_loop

        ret                     ; end program

end     start
