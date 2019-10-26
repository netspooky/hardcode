%define RAINS 1300
%define rains palette+768


rain_start   :
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        call    setup_buffer
;
; set-up the palette
;

        mov     dx,03C8h        ; vga palette register
        xor     al,al           ; we will start at color 0
        out     dx,al           ; tell that to the video
        inc     dx              ; vga palette register (set colors)
        mov     cx,64
        xor     bx,bx
.next_color      :
        mov     ax,bx
        shr     ax,2
        out     dx,al
        mov     ax,bx
        shr     ax,1
        out     dx,al
        mov     ax,bx
        out     dx,al
        inc     bx
        loop    .next_color

        mov     cx,RAINS
        mov     di,rains
        cld
.init_next_ball  :
        mov     ax,320
        call    random
        add     ax,5
        stosw
        mov     ax,190
        call    random
        sub     ax,190
        stosw
        loop    .init_next_ball

;
; The main loop is here
;
        mov     cx,350        
.another_loop    :
        push    cx
        call    .new_rain        ; each time add random lines and blure up
        call    wait_retrace
        call    wait_retrace
        push    ds
        push    es
        mov     ax,cs
        mov     ds,ax
        mov     ds,[vga_buffer]
        xor     si,si
        xor     di,di
        mov     cx,320*190
        call    show_vga_buffer     ; show the damn buffer
        pop     es
        pop     ds
        pop     cx
        push    cx
        cmp     cx,200
        ja      .no_key_yet
        mov     ah,01h          ; is keypressed
        int     16h             ; bios keyboard service
        jnz     .finish_1
.no_key_yet     :
        pop     cx
        loop     .another_loop    ; if not then another loop
        jmp     .finish
.finish_1:
        xor     ax,ax
        int     16h
        pop     cx
;
; The user wanna quit
;
.finish  :
        ret
;
; new_rain function , add random high intensity values and blure up
; 
.new_rain        :
        pusha                   ; save all regs
        mov     ax,cs           
        mov     ds,ax
        mov     ax,[vga_buffer] 
        mov     es,ax           ; destination is the video buffer

        mov     si,rains
        mov     cx,RAINS           ; rains number
.next_ball      :
        call    .do_drop
        add     si,4
        loop    .next_ball

        call    blure_up       ; and blure up
        popa                    ; restore all regs
        ret                     ; and return

%define drop_x si
%define drop_y si+2

.do_drop :
        pusha
        cmp     word [drop_y],195
        ja      .next
        mov     ax,320
        mul     word [drop_y]
        add     ax,[drop_x]
        mov     di,ax
        cld
        mov     al,45
        stosb
        mov     al,63
        add     di,319
        stosb
        mov     al,63
        add     di,319
        stosb
        mov     al,45
        add     di,319
        stosb
.next   :
        mov     ax,[drop_y]
        cmp     ax,202
        jns     .y_pass
        mov     ax,3
        call    random
        inc     ax
        add     [drop_y],ax
        popa
        ret

.y_pass :
        mov     word [drop_y],0
        jmp     .next

