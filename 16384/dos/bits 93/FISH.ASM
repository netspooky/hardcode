
                .model small

.386

                .data

fish_flag       db 1

                even

xv              dw 1
yv              dw 0
xp              dw 160
yp              dw 110
addr            dw 0
old_addr        dw 0

fish_buf        db 60*60 dup(0)

                align 4

under_fish      db 64*60 dup(0)


fish_table      label word

                even

                include fish.tbl

                extrn dest_seg:word

                .code

                public do_bounce,do_fish,addr,blank_fish


blank_fish      proc near

                test fish_flag,-1
                jnz @@skip_copy

                cld

                mov esi,offset under_fish
                mov es,dest_seg
                movzx edi,old_addr

                mov dx,60
@@replace_next_line:
                mov ecx,64/4

                rep movsd
                add edi,320-64
                dec dx
                jnz @@replace_next_line

@@skip_copy:

                mov fish_flag,0

                ret

blank_fish      endp


do_fish         proc near

                mov bp,di
                cld

                mov edi,offset under_fish
                push ds
                movzx esi,addr
                and esi,not 3
                mov old_addr,si
                mov ds,dest_seg
                mov ax,seg fish_buf
                mov es,ax
                mov dx,60
@@1:
                mov ecx,64/4
                rep movsd

                add esi,320-64

                dec dx
                jnz @@1

                pop ds

                mov dx,60
                mov bx,offset fish_table
                mov si,addr
                mov di,offset fish_buf

                mov es,dest_seg
@@next_line:
                mov cx,60

@@next_column:
                mov si,[bx]
                mov al,es:[si+bp]
                mov [di],al
                inc di
                add bx,2
                dec cx
                jnz @@next_column

                add si,320-60

                dec dx
                jnz @@next_line

                mov dx,60
                mov di,addr
                mov si,offset fish_buf

@@update_line:

                mov cx,60/2
                rep movsw

                add di,320-60
                dec dx
                jnz @@update_line

                ret

do_fish         endp


do_bounce       proc near

                mov ax,xv
                add xp,ax

                cmp xp,260
                jbe xp_ok

                neg xv
                neg ax
                add xp,ax

xp_ok:
                mov ax,yv
                add yp,ax

                cmp yp,252*3
                jbe yp_ok

                neg yv
                neg ax
                add yp,ax

yp_ok:
                add yv,1

                mov ax,yp
                shr ax,3
                xchg al,ah
                mov addr,ax
                shr ax,2
                add addr,ax
                mov ax,xp
                add addr,ax

                ret

do_bounce       endp


                end


