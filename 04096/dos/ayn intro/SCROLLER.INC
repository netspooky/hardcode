scroller_start   :
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        call    setup_buffer
        mov     si,palette
        call    set_palette
;
; set-up the palette
;
;        mov     dx,03C8h        ; vga palette register
;        xor     al,al           ; we will start at color 0
;        out     dx,al           ; tell that to the video
;        inc     dx              ; vga palette register (set colors)
;
;        mov     cx,63
;        xor     bx,bx
;.next_color     :
;        mov     ax,bx
;        out     dx,al
;        out     dx,al
;        out     dx,al
;        inc     bx
;        loop    .next_color
;
;        mov     cx,256-64
;        mov     ax,bx
;.next_color_2   :
;        out     dx,al
;        out     dx,al
;        out     dx,al
;        loop    .next_color_2
;
        mov     es,[vga_buffer]

;
; The main loop is here
;
.another_loop    :
        call    .new_line        ; each time add random lines and scroll up
        call    wait_retrace
        call    wait_retrace
        call    wait_retrace
        call    .show_buffer
        mov     ah,01h          ; is keypressed
        int     16h             ; bios keyboard service
        jz      .another_loop    ; if not then another loop

;
; The user wanna quit
;
.finish  :
        xor     ah,ah           ; get the pressed char (clear the keyboard
        int     16h             ; buffer) using bios keyb service

.finish_vga      :               ; just decrease colors , until everything
                                ; is black by scrolling up
        mov     cx,40           ; scroll_up 30 times
.next_  :
        push    cx              ; save counter
        call    scroll_up       ; scroll up
        call    blure_up
        call    wait_retrace    ; waite for vertical sync
        call    wait_retrace    ; waite for vertical sync
        call    wait_retrace
        call    .show_buffer
        pop     cx              ; restore counter
        loop    .next_           ; and loop until counter=0
        ret                     ; and quit

;
; new_line function , add random high intensity values and scroll up
; 
.new_line        :
        pusha                   ; save all regs
        mov     ax,cs           
        mov     ds,ax
        mov     ax,[vga_buffer] 
        mov     es,ax           ; destination is the video buffer


        mov     si,.balls
        mov     cx,4            ; balls number
.next_ball      :
        call    .next_flame
        add     si,6
        loop    .next_ball

        mov     bx,[.curr_txt]   ; now write some text

        cmp     word [.stime],25 ; we will wait for each text 200 time
        jb      .continue       ; still below , don't write another one
        xor     ax,ax           ; else set time to zero
        mov     [.stime],ax      ; to do it again
        mov     si,[bx]         ; write first string
        and     si,si           ; is it the last text
        jnz     .next_txt       ; if no continue
        jmp     .finish_new_line; else finish
.continue       :
        mov     si,[bx]
        cmp     word [.stime],0  ; if it's zero then go write another text
        je      .next_txt         
        jmp     .next_1         ; else just scroll up
.next_txt      :                ; point to next text and write it
        call    write_string
        add     bx,2            ; add txt pointer with 6
        mov     [.curr_txt],bx
.next_1         :
        inc     word [.stime]    ; we have made it one more time
        call    scroll_up       ; and scroll up
        call    blure_up
        popa                    ; restore all regs
        ret                     ; and return
.finish_new_line:
        popa
        pop     ax
        jmp     .finish_vga

.stime   dw      0
.curr_txt  dw     txts

%define flame_1_x si
%define flame_1_y si+2
%define inc_it_1_x si+4
%define inc_it_1_y si+5
.next_flame      :
        pusha
        mov     ax,cs
        mov     ds,ax
        xor     dx,dx
        mov     ax,320
        mul     word [flame_1_y]
        add     ax,[flame_1_x]
        mov     di,ax
        mov     ax,255
        call    random
        mov     [es:di],al
        mov     ax,128
        call    random
        mov     [es:di+1],al
        mov     ax,128
        call    random
        mov     [es:di-1],al
        mov     ax,128
        call    random
        mov     [es:di+320],al
        mov     ax,128
        call    random
        mov     [es:di-320],al
        mov     ax,128
        call    random
        mov     [es:di-321],al
        mov     ax,128
        call    random
        mov     [es:di+321],al
        mov     ax,128
        call    random
        mov     [es:di-319],al
        mov     ax,128
        call    random
        mov     [es:di+319],al

        mov     ax,128
        call    random
        mov     [es:di+2],al
        mov     ax,128
        call    random
        mov     [es:di-2],al
        mov     ax,128
        call    random
        mov     [es:di+640],al
        mov     ax,128
        call    random
        mov     [es:di-640],al
        mov     ax,128
        call    random
        mov     [es:di-642],al
        mov     ax,128
        call    random
        mov     [es:di+642],al
        mov     ax,128
        call    random
        mov     [es:di-638],al
        mov     ax,128
        call    random
        mov     [es:di+638],al

        mov     ax,[flame_1_x]
        cmp     ax,315
        ja      .set_dec_x
        cmp     ax,5
        jb      .set_inc_x
.next_12:
        cmp     byte [inc_it_1_x],0
        jnz     .dec_x
        inc     word [flame_1_x]
        inc     word [flame_1_x]
        inc     word [flame_1_x]

        jmp     .next
.dec_x  :
        dec     word [flame_1_x]
        dec     word [flame_1_x]
        dec     word [flame_1_x]

.next   :
        mov     ax,[flame_1_y]
        cmp     ax,128+20
        ja      .set_dec_y
        cmp     ax,45
        jb      .set_inc_y
.next_2 :
        cmp     byte [inc_it_1_y],0
        jnz      .dec_y
        inc     word [flame_1_y]
        inc     word [flame_1_y]
        inc     word [flame_1_y]
        jmp     .next_r
.dec_y  :
        dec     word [flame_1_y]
        dec     word [flame_1_y]
        dec     word [flame_1_y]
        dec     word [flame_1_y]
        dec     word [flame_1_y]
.next_r :        

        popa
        ret
.set_dec_x      :
        mov     byte [inc_it_1_x],1
        jmp     .next_12
.set_inc_x      :
        mov     byte [inc_it_1_x],0
        jmp     .next_12
.set_dec_y      :
        mov     byte [inc_it_1_y],1
        jmp     .next_2
.set_inc_y      :
        mov     byte [inc_it_1_y],0
        jmp     .next_2

.show_buffer    :
        push    ds
        push    es
        mov     ax,cs
        mov     ds,ax
        mov     ds,[vga_buffer]

        mov     si,320*25
        mov     di,320*32
        mov     cx,320*128
        call    show_vga_buffer     ; show the buffer

        pop     es
        pop     ds

        ret

.balls   :
        dw      160
        dw      10
        db      1
        db      0

        dw      160
        dw      10
        db      0
        db      0

        dw      160
        dw      190
        db      0
        db      1

        dw      160
        dw      190
        db      1
        db      1

txt_0           db      0
txt_1           db      '   Well , we reach',0
txt_2           db      '     the END :(',0
txt_3           db      '     Hopefully',0
txt_4           db      '   that u liked it',0
txt_5           db      ' This was our First',0
txt_6           db      '       shot',0
txt_7           db      '  It was entirely',0
txt_8           db      '  made using NASM',0
txt_9           db      '  if u think that',0
txt_10          db      '  u can port it to',0
txt_11          db      ' Linux, be my gest.',0
txt_12          db      '  The entire intro',0
txt_13          db      '   was coded by :',0
txt_14          db      '   K I N T A R O',0
txt_15          db      '  Hopefully that',0
txt_16          db      '  SIMON will do',0
txt_17          db      ' some work in the',0
txt_18          db      '      Future',0
txt_19          db      '   Hey , IBRAHIM',0
txt_20          db      ' your music is the',0
txt_21          db      '     coolest ',1,0
txt_22          db      '  Greatings to :',0
txt_23          db      'eagle_eye : man :/',0
txt_24          db      "  gnr-fan : don't",0
txt_25          db      '  study too hard .',0
txt_26          db      " JALH : don't fuck",0
txt_27          db      'z code I give u ;)',0
txt_28          db      ' silas : debugging',0
txt_29          db      'system code is hard',0
txt_30          db      ' tinus : drinking?',0
txt_31          db      '  smoke , aka... :',0
txt_32          db      '  ! PEACE guys !',0
txt_33          db      '  Matju : doing a',0
txt_34          db      '256 intro or what?',0
txt_35          db      '    and hi to',0
txt_36          db      'all #zealos,#geeks',0
txt_37          db      '  and #demoscene',0
txt_38          db      '       people',0
txt_39          db      0
txt_40          db      'cya~~~ soon ....',0

;
; texts offsets
;
txts            dw      txt_0,txt_0,txt_0
                dw      txt_1,txt_2,txt_3,txt_4,txt_5,txt_6,txt_7,txt_8,txt_9
                dw      txt_10,txt_11,txt_12,txt_13,txt_14,txt_15,txt_16,
                dw      txt_17,txt_18,txt_19,txt_20,txt_21,txt_22,
                dw      txt_23,txt_24,txt_25,txt_26,txt_27,txt_28,
                dw      txt_29,txt_30,txt_31,txt_32,txt_33,txt_34,
                dw      txt_35,txt_36,txt_37,txt_38,txt_39,txt_40,0
