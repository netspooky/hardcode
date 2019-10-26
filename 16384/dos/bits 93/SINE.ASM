
                locals

font_height     equ 17
font_width      equ 16

scroll_posy     equ 80

wave_speed      equ 4
wave_wiggle     equ 2

col_start       equ 64

_buffer         segment para public 'FARDATA'
_buffer         ends

_data           segment para public 'DATA'


                extrn font_table:word


count           db font_width-1

sine_pos        db 0

                include sine.tbl

sine_end        label word

                align 2

                include message

                dw 0

message_pos     dw offset message

dest_seg        dw 0a000h

                align 4

scroll_buffer   db font_height*(320+font_width) dup(0)

_data           ends


                .model small

                .code
                .386

                public sine_scroll,dest_seg

sine_scroll     proc near

                cld

                add count,2
                cmp count,font_width
                jb @@skip_scroll

                mov count,0
                mov ax,ds
                mov es,ax

                lea esi,scroll_buffer+font_width
                lea edi,[esi-font_width]
                mov ecx,((320+font_width)*font_height)/4-font_width/4
                rep movsd

                mov bx,message_pos
                mov si,[bx]
                add bx,2
                or si,si
                jnz @@2

                mov bx,offset message+2
                movzx esi,word ptr [bx-2]
@@2:
                mov message_pos,bx

                mov dx,font_height
                mov edi,offset scroll_buffer+320

@@next_char_row:
                mov ecx,font_width/4
                rep movsd
                add edi,320

                dec dx
                jnz @@next_char_row

@@skip_scroll:

                mov es,dest_seg
                movzx si,count
                add si,offset scroll_buffer

                mov bl,sine_pos
                xor bh,bh
                shl bx,1
                add bx,offset sine_table

                mov dx,160
                mov bp,scroll_posy*320
                mov ax,_buffer
                mov fs,ax

@@clear_next_column:
                mov di,bp
                add di,[bx]

                mov cx,font_height
@@clear_next_row:
                mov ax,fs:[di]
                mov es:[di],ax
                add di,320
                dec cx
                jnz @@clear_next_row

                add bp,2
                add bx,2*wave_wiggle
                cmp bx,offset sine_end
                jae @@reset_bx1
@@after_reset1:
                dec dx
                jnz @@clear_next_column

                add sine_pos,wave_speed
                mov bl,sine_pos
                xor bh,bh

                shl bx,1
                add bx,offset sine_table

                mov bp,160
                mov di,scroll_posy*320
                mov dh,0ffh
                mov dl,sine_pos

@@wave_next_column:
                push di
                mov cx,[bx]
                add di,cx
                mov dx,cx
                sar dx,8
                sar cx,10

                sub dx,cx
                add dx,20+col_start

                mov cx,font_height
@@copy_next_row:
                mov ax,[si]
                test al,0ffh
                jz @@s1
                mov es:[di],dl
@@s1:
                test ah,0ffh
                jz @@s2
                mov es:[di+1],dl
@@s2:
                add si,320+font_width
                add di,320
                inc dl

                dec cx
                jnz @@copy_next_row

                sub si,(font_width+320)*font_height-2

                pop di
                add di,2
                add bx,2*wave_wiggle
                cmp bx,offset sine_end
                jae @@reset_bx
@@after_reset:
                dec bp
                jnz @@wave_next_column

                ret

@@reset_bx:
                sub bx,sine_end - sine_table
                jmp @@after_reset

@@reset_bx1:
                sub bx,sine_end - sine_table
                jmp @@after_reset1


sine_scroll     endp

                end

