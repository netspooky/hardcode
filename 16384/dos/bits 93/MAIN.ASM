

setborder       macro red,green,blue

                push dx
                push ax

                mov dx,03c8h
                xor al,al
                out dx,al
                inc dx
                mov al,red
                out dx,al
                mov al,green
                out dx,al
                mov al,blue
                out dx,al

                pop ax
                pop dx

                endm


                .model small
                locals

                .data

                extrn addr:word

old_imask       db 0

                .code

quit            db 0
pause           db 0

                extrn sine_scroll:near
                extrn sync:near
                extrn put_background:near
                extrn set_colours:near
                extrn do_bounce:near,do_fish:near,blank_fish:near
                extrn SetInts:near,ClearInts:near,GetRasterLine:near
                extrn set_keys:near,reset_keys:near

                public quit,pause

                .startup

                mov ax,013h
                int 010h

                call SetInts

                in al,021h
                mov old_imask,al
                mov al,011111100b
                out 021h,al

                call set_colours
                call put_background

                call set_keys

next:

                call do_bounce
@@wait_line:
                call GetRasterLine

                cmp ax,240
                jnz @@wait_line

;                setborder 32 32 32

                call blank_fish
                call sine_scroll

                mov di,addr
                call do_fish

;                setborder 0 0 0

@@pause:
                test cs:pause,-1
                jnz @@pause

                test cs:quit,-1
                jz next

@@quit:
                call reset_keys
                call ClearInts

                mov al,old_imask
                out 021h,al

                mov ax,3
                int 010h

                mov ax,04c00h
                int 021h

                .stack

                end

