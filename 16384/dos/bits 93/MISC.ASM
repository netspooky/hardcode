

_buffer         segment para public 'FARDATA'

                org 0

                db 64000 dup(0)

_buffer         ends


_backseg        segment para public 'FARDATA'

                extrn background:byte

_backseg        ends


                .model small

                .data

                extrn dest_seg:word,palette:byte

                .code
                locals

.386
                extrn pause:byte,quit:byte

                public sync,put_background,set_colours,DemoInt
                public set_keys,reset_keys

sync            proc near

                push ax
                push dx

                mov dx,03dah
@@1:
                in al,dx
                test al,8
                jnz @@1

@@2:
                in al,dx
                test al,8
                jz @@2

                pop dx
                pop ax

                ret

sync            endp


put_background  proc near

                push ds

                mov dx,69

                mov si,offset background
                mov di,50*320+(320-248)/2
                mov es,dest_seg
                mov ax,_backseg
                mov ds,ax

                cld
@@1:
                mov cx,248/2
                rep movsw

                add di,320-248
                dec dx
                jnz @@1

                mov dx,69

                mov si,offset background
                mov di,50*320+(320-248)/2
                mov ax,_buffer
                mov es,ax
                cld
@@2:
                mov cx,248/2
                rep movsw

                add di,320-248
                dec dx
                jnz @@2

                pop ds

                ret

put_background  endp


set_colours     proc near

                mov si,offset palette
                mov dx,03c8h
                xor al,al
                out dx,al
                inc dx

                mov cx,256*3
                cld
@@1:
                lodsb
                out dx,al
                loop @@1

                ret

set_colours     endp


DemoInt         proc near

                ret

DemoInt         endp


key_int         proc far

                push ax

                in al,060h
                test al,080h
                jnz @@end_int

                cmp al,1
                jnz @@not_quit

                mov cs:quit,1
                jmp short @@end_int

@@not_quit:

                xor cs:pause,1
@@end_int:
                mov al,020h
                out 020h,al

                pop ax
                iret

key_int         endp



old_int9        dd 0

set_keys        proc near

                xor ax,ax
                mov es,ax
                mov eax,es:[9*4]
                mov cs:old_int9,eax

                cli
                mov word ptr es:[9*4],offset key_int
                mov es:[9*4+2],cs
                sti

                ret

set_keys        endp


reset_keys      proc near

                xor ax,ax
                mov es,ax

                mov eax,cs:old_int9
                mov es:[9*4],eax

                ret

reset_keys      endp


                end



