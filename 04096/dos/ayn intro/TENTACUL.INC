%define BALLS 1200
%define balls palette+768

tentacul_start   :
        call    setup_buffer
        mov     cx,BALLS
        mov     di,balls
        cld
        xor     eax,eax
.clear_next_ball :
        stosd
        stosw
        loop    .clear_next_ball

        mov     si,balls
        mov     cx,BALLS
.init_next_ball  :
        mov     ax,320
        call    random
        add     ax,5
        mov     [si],ax
        mov     ax,200
        call    random
        sub     ax,200
        mov     [si+2],ax
        mov     ax,3
        call    random
        mov     [si+4],al
        mov     al,1
        mov     [si+5],al
        add     si,6
        loop    .init_next_ball



        call    setup_buffer
;
; The main loop is here
;
        mov     cx,500
.another_loop    :
        push    cx
        call    .new_line       ; each time add random lines and blure up
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
        and     cx,cx
        jz      .finish_vga
        dec     cx
        mov     ah,01h          ; is keypressed
        int     16h             ; bios keyboard service
        jz      .another_loop    ; if not then another loop

;
; The user wanna quit
;
.finish  :
        xor     ah,ah           ; get the pressed char (clear the keyboard
        int     16h             ; buffer) using bios keyb service

.finish_vga     :               ; just decrease colors , until everything
                                ; is black by blureing up
        mov     cx,40           ; blure_up 30 times
.next  :
        push    cx              ; save counter
        call    blure_up       ; blure up
        call    wait_retrace    ; waite for vertical sync
        call    wait_retrace    ; waite for vertical sync
        push    ds
        push    es
        mov     ax,cs
        mov     ds,ax
        mov     ds,[vga_buffer]
        xor     si,si
        xor     di,di
        mov     cx,320*200
        call    show_vga_buffer     ; show the buffer
        pop     es
        pop     ds
        pop     cx              ; restore counter
        loop    .next           ; and loop until counter=0
        ret
;
; new_line function , add random high intensity values and blure up
; 
.new_line       :
        pusha                   ; save all regs
        mov     ax,cs           
        mov     ds,ax
        mov     ax,[vga_buffer] 
        mov     es,ax           ; destination is the video buffer

        mov     si,balls
        mov     cx,BALLS           ; balls number
.next_ball      :
        call    .next_flame
        add     si,6
        loop    .next_ball

        call    blure_up       ; and blure up
        popa                    ; restore all regs
        ret                     ; and return

%define flame_x si
%define flame_y si+2
%define inc_it_x si+4
%define inc_it_y si+5
.next_flame      :
        pusha
        xor     dx,dx
        cmp     word [flame_y],198
        ja      .next_0
        mov     ax,320
        mul     word [flame_y]
        add     ax,[flame_x]
        mov     di,ax

        mov     ax,10
        call    random
        add     ax,40
        mov     [es:di],al
        mov     ax,32
        mov     [es:di+321],al
        mov     ax,32
        mov     [es:di-321],al
        mov     ax,32
        mov     [es:di+319],al
        mov     ax,32
        mov     [es:di-319],al

        mov     ax,32
        mov     [es:di+1],al
        mov     ax,32
        mov     [es:di-1],al
        mov     ax,32
        mov     [es:di+320],al
        mov     ax,32
        mov     [es:di-320],al
        mov     ax,32
        mov     [es:di-640],al
        mov     ax,32
        mov     [es:di+640],al
        mov     ax,32
        mov     [es:di-2],al
        mov     ax,32
        mov     [es:di+2],al

.next_0 :
        jmp     .next_
.dec_x  :
        mov     ax,2
        call    random
        sub     [flame_x],ax

.next_  :
        mov     ax,[flame_y]
        cmp     ax,190
        jns     .set_dec_y
        mov     ax,2
        call    random
        inc     ax
        add     [flame_y],ax

        popa
        ret
.set_dec_y      :
        mov     word [flame_y],0
        mov     byte [inc_it_y],0
        jmp     .next_
.set_inc_y      :
        mov     byte [inc_it_y],0
        jmp     .next_

