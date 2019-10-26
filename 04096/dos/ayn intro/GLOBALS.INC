;
; write_string function , write a string pointed by SI
;
write_string    :
        pusha                   ; save all regs
        mov     ax,cs           ; get the data segment (ds=cs in tiny model)
        mov     ds,ax
        mov     cx,2            ; set X coordinate in CX
        mov     dx,150          ; get the Y coordinate in DX
.next_char      :
        lodsb                   ; get char
        and     al,al           ; is it zero ? (end of string)
        jz      .return         ; if yes then we have finished
        call    write_char      ; write the flaming char
        add     cx,16           ; next char is 32 pixel after
        jmp     .next_char      ; go get next char
.return :
        popa                    ; everything is done , restore regs
        ret                     ; and return
;
; write_char function , write a char to the screen at specific coordinates
; AL=char
; DX=Y CX=X
;
write_char      :
        pusha
        mov     bx,cs           ; get the data segment (DS=CS in tiny model)
        mov     ds,bx
        mov     es,[vga_buffer] ; destination seg is the video buffer
        mov     [curr_pos_x],cx ; save current X
        mov     [curr_pos_y],dx ; save current Y
        xor     ah,ah           ; AH must be zero
        mov     [curr_char],ax  ; save char
        mov     ax,320          ; calculate the starting pixel
        mul     word [curr_pos_y]       ; pixel=Y*320+X
        add     ax,[curr_pos_x]
        mov     di,ax           ; put it in di
        mov     si,[curr_char]  ; now find the current char in table
        shl     si,3            ; every char is 8 bytes long
        add     si,ch_table     ; the offset is the charactar table address
        mov     cx,8            ; 8 lines (char length)
.next_line      :
        push    cx              ; save cx
        mov     cx,8            ; now 8 pixel row len
        mov     al,80h          ; al=10000000b
        mov     ah,80h          ; ah=10000000b
.next_point     :
        and     al,[si]         ; al=al AND the charactar bit map
        jnz     .set_current    ; if it's 1 then set it
.continue       :
        shr     ah,1            ; ah>>1 advance the bit to left ie:100 -> 010
        mov     al,ah           ; save the mask (AL=mask)
        inc     di              ; four pixel at time
        inc     di
        loop    .next_point     ; next row
        add     di,2*640-2*8   ; next line in video buffer
        inc     si              ; next bitmap in the charactar table
        pop     cx              ; restore current line
        loop    .next_line      ; and save it
        popa                    ; restore regs
        ret                     ; and return
;
; set the current point bit-maped with charactar bit-map
; I think it's easy to understand
;
.set_current    :
        push    ax
        mov     al,120
        mov     [es:di],al
        mov     [es:di+1],al
        mov     [es:di+320],al
        mov     [es:di+321],al
        mov     [es:di+640],al
        mov     [es:di+641],al
        mov     [es:di+640+320],al
        mov     [es:di+640+321],al
        pop     ax
        jmp     .continue

curr_pos_x      dw      0
curr_pos_y      dw      0
curr_pixel      dw      0
curr_char       dw      0

;
; random function , AX contains max value that it shouldn't exceed
; return in AX the random number
;
random  :
        push    bx
        push    dx
        push    ax
        mov     bx,[rvalue]
        mov     ax,[seed]
        rol     ax,3
        sub     ax,7
        xor     ax,bx
        mov     [rvalue],ax
        mov     [seed],bx
        xor     dx,dx
        pop     bx
        div     bx
        mov     ax,dx
        pop     dx
        pop     bx
        ret

seed            dw      084501h
rvalue          dw      09203h

;
; set-up the palette
;
setup_palette   :
        mov     di,palette+248  ; we have reduced the palette , so we will
        mov     al,63           ; add missed colors (wich are white)
        mov     cx,521          ; add 174 colors
        cld                     ; clear copy direction
        rep     stosb           ; and set them
        ret
;
; set_palette , will send the current palette to the vga card
;
set_palette     :
        mov     dx,03C8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     cx,768
        rep     outsb
        ret
;
; setup_buffer function , will setup the video screen buffer
;
setup_buffer    :
        push    es
        mov     ax,cs
        add     ax,4096
        mov     [vga_buffer],ax

        mov     es,ax
        xor     ax,ax
        xor     di,di
        cld
        
        mov     cx,65535
        rep     stosw
        pop     es
        ret
;
; scroll_up function , scroll up
;
scroll_up       :
        pusha                   ; first save all regs
        mov     ax,cs
        mov     ds,ax
        mov     ax,[vga_buffer]
        mov     es,ax           ; set destination to video buffer
        mov     ds,ax           ; and source too

        xor     di,di           ; destination to 0
        mov     si,320          ; but here is the trick for rizing , source
                                ; is one line down
        mov     cx,320*199      ; number of pixels to work on
.lp1    :
        mov     al,[si]
        stosb
        inc     si              ; next pixel
        loop    .lp1            ; haven't finish yet ! continue then
        popa                    ; all done , restore regs
        ret                     ; and quit

;
; blure_up function , makes rizing fire
;
blure_up       :
        pusha                   ; first save all regs
        mov     ax,es
        mov     ds,ax

        xor     di,di           ; destination to 0
        mov     si,320          ; but here is the trick for rizing , source
                                ; is one line down
        mov     cx,320*199      ; number of pixels to work on
.lp1    :
        xor     ax,ax           ; ax=0
        xor     bx,bx           ; bx=0
        mov     al,[si-1]         ; ax=value of current pixel
        mov     bl,[si-320]     ; bx=value of the upper left pixel
        adc     ax,bx           ; get sum
        mov     bl,[si+320]     ; bx=value of the bottom left pixel
        adc     ax,bx           ; get sum
        mov     bl,[si+1]     ; bx=value of the bottom pixel
        adc     ax,bx           ; get sum
        shr     ax,2            ; calculate average
        mov     bl,[si]
        add     ax,bx
        shr     ax,1
        or      ax,ax           ; is color 0 ?
        jz      .set_point      ; if yes then nothing to do
        dec     al              ; no , decrement the pixel color
.set_point      :
        stosb                   ; store the pixel color
        inc     si              ; next pixel
        loop    .lp1            ; haven't finish yet ! continue then
        popa                    ; all done , restore regs
        ret                     ; and quit

;
; some global routines
;
show_vga_buffer :
        push    es
        shr     cx,2
        mov     ax,0A000h
        mov     es,ax
        cld
        rep     movsd
        pop     es
        ret

;
; wait_retrace function , wait until vga draw all the screen
;
wait_retrace    :
        mov dx,03DAh
.wait   :
        in      al,dx
        test    al,08h
        jnz     .wait
.wait_2 :
        in      al,dx
        test    al,08h
        jz      .wait_2
        ret

vga_buffer      dw      0

ch_table :
        incbin "font.bin"

;
; palette , because I wanna to reduce the file size , the palette is incomplete
; so , we just complete it in running time , see source above...
;
palette :
        db 0,0,0,0,0,2,0,0,4,0,0,6,0,0,8,0,0,10,0,0,12,0,0,14,0,0,16,2,0,14,5
        db 0,12,8,0,10,10,0,8,13,0,6,16,0,4,19,0,2,21,0,0,24,0,0,27,0,0,30,0,0,32,0
        db 0,35,0,0,38,0,0,41,0,0,43,0,0,46,0,0,49,0,0,52,0,0,54,0,0,57,0,0,60,0,0
        db 63,0,0,63,0,0,63,2,0,63,5,0,63,8,0,63,10,0,63,13,0,63,16,0,63,19,0,63,21,0,63
        db 24,0,63,27,0,63,30,0,63,32,0,63,35,0,63,38,0,63,41,0,63,43,0,63,46,0,63,49,0,63,52
        db 0,63,54,0,63,57,0,63,60,0,63,63,0,63,63,0,63,63,2,63,63,5,63,63,8,63,63,10,63,63,13
        db 63,63,16,63,63,19,63,63,21,63,63,24,63,63,27,63,63,30,63,63,32,63,63,35,63,63,38,63,63,41,63
        db 63,43,63,63,46,63,63,49,63,63,52,63,63,54,63,63,57,63,63,60,63,63,63,63,63,63,63,63,63,63,63
