        ; rotozoomer + scroller, not too original...
        ; fuse/flare, 3 Jan 2003
        ; GPL v2
        ;
        ; Revision history:
        ;
        ;  3 Jan 2003  initial release (251 bytes)
        ;  4 Jan 2003  optimized mandelbrot set code (248 bytes)
        ;  6 Jan 2003  rearranged mandelbrot set code
        ;              replaced `mov bx,dx/shr bx,3' with `shrd bx,dx,19'
        ;              replaced `sar al,8/and al,7' with `cbw/shr ax,16 - 3'
        ;              (245 bytes)
        ;  9 Jan 2003  237 bytes, thanks to Marko Elezovic!
        ; 14 Jan 2003  replaced
        ;                       mov al,ah               ; 2 bytes
        ;                       mov ah,dl               ; 2 bytes
        ;                       lea si,[2*eax + ebp]    ; 5 bytes
        ;              with
        ;                       shrd ax,dx,7            ; 4 bytes
        ;                       add ax,bp               ; 2 bytes
        ;                       xchg ax,si              ; 1 byte
        ;              (235 bytes)
        ;              setting direction flag in scroller could turn 
        ;              `xor si,si / ... / inc si / cmp si,8 / jnz' loop into
        ;              `mov si,7 / ... / dec si / jns' (233 bytes)
        ;              optimized scroller code (231 bytes)
        ;              got rid of useless xor bx,bx - thanks Marko! (229 bytes)
        ;              fixed zero-column bug (230 bytes)

        .model tiny
        .486
        .code
        org 100h

entry_point:

        mov ax,13h      ; mov al,13h may save a byte here but won't work on 
                        ; FreeDOS, since ax != 0 on that
        int 10h

        finit
        fild word ptr k1


        ;;
        ;; mandelbrot set
        ;;


        mov ax,cs
        add ah,16
        mov ds,ax

        ;   pseudocode:
        ;
        ;   xl = -2;
        ;   for (x = 0; x < 256; x++) {
        ;       yl = -1.5;
        ;       for (y = 0; y < 256; y++) {
        ;           py = yl; px = xl;
        ;           for (i = 0; i < 128; i++) {
        ;               if (px * px + py * py > 4)
        ;                   break;
        ;               npx = px * px - py * py + xl;
        ;               npy = 2 * px * py + yl;
        ;               px = npx;
        ;               py = npy;
        ;           }
        ;           *buf++ = i;
        ;           yl += 3 / 200;
        ;       }
        ;       xl += 3 / 200;
        ;   }
        ;
        ;   notes:
        ;
        ;   - using fixed point (8.8)
        ;   - register allocation:
        ;       bp: y1
        ;       dx: x1
        ;       si: py
        ;       di: px
        ;       bx: buf (high byte: y, low byte: x)

        mov bp,-381         ; -1.5 * 256 - 3
mand0:
        test bl,bl
        jnz short mand1
        add bp,3
        mov dx,-512         ; -2 * 256
mand1:
        mov si,bp
        mov di,dx

        mov byte ptr [bx],80h
mand2:
        push dx

        mov ax,si
        imul ax
        mov cl,ah
        mov ch,dl           ; cx = py*py
        mov ax,di
        imul ax
        mov al,ah
        mov ah,dl           ; ax = px*px
        add dl,ch
        shr dl,2
                            ; replace the two instructions above with the
                            ; following to get more precision (and lose two 
                            ; bytes):
                            ;   mov dx,ax
                            ;   add dx,cx
                            ;   shr dx,10
        jnz short mand3     ; if (px*px + py*py > 4) break;
        sub ax,cx           ; ax = px*px - py*py
        xchg ax,di          ; di = px*px - py*py
                            ; ax = px
        imul si
        shrd ax,dx,7        ; ax = 2*px*py
        add ax,bp           ; ax = 2*px*py + y1
        xchg ax,si          ; npy = 2*px*py + y1
        pop dx
        add di,dx           ; npx = px*px - py*py + x1;

        inc byte ptr [bx]
        jnz short mand2

        push dx
mand3:
        pop dx
        add dx,3
        inc bx
        jnz short mand0

        push 0a000h
        pop es

        fldpi
        fdiv st,st(1)           ; step = pi / k
        fldz                    ; fp stack: ang | step | k

        std

main_loop:

        ;;
        ;; scroller
        ;;

        push ds

        mov di,320*200 - 1
        mov ds,di               ; ds = 0f9ffh

                                ; 8x8 font data is at f000:fa6e on 100% 
                                ; compatible BIOSes
                                ;
                                ; f000:fa6e = f9ff:5a7e
        mov si,7
scrl0:
        mov cx,320
scrl1:
        push cx

        add cx,dx

        shrd bx,cx,16 + 3       ; bx = dx >> 3
        and bx,7
        mov bl,cs:text[bx]
                                ; we wanted `mov al,[ebx*8 + esi]' here, but 
                                ; the high word of ebx/esi isn't guaranteed to 
                                ; be 0 - too bad, it could save a byte
        shl bx,3
        mov al,[bx + si + 5a7eh]

        and cl,7
        shl al,cl

        pop cx

        db 0d6h ; salc
        and al,7
        ; shr ax, 6             ; nice colors (thanks Marko!)

        stosb
        loop scrl1

        dec si
        jns short scrl0

        pop ds

        ;;
        ;; rotozoomer
        ;;

        inc dx

        fadd st,st(1)

        fld st(0)
        fsincos

        fld st(0)
        fmul st,st(5)
        fadd st,st(5)
        fadd st,st(5)           ; fp stack: amp | sin | cos | ang | step | k

        push ax
        push ax
        mov bp,sp
        fmul st(2),st(0)
        fmulp
        fistp word ptr [bp]
        fistp word ptr [bp + 2]
        pop si                  ; si = dv
        pop bp                  ; bp = du

                                ; bx = u
                                ; dx = v

        push dx
roto1:
        push bx
        push dx

        mov cx,320
roto2:
        xchg bl,dh
        mov al,[bx]
        stosb
        xchg bl,dh
        add bx,bp
        add dx,si
        loop roto2

        pop dx
        pop bx

        sub bx,si
        add dx,bp

        cmp di,-1               ; stupid tasm assembles cmp di,0ffffh to
                                ; 4 bytes (81 ff ff ff)
        jnz short roto1

        pop dx

        ;;
        ;; poll for ESC (scan code 1)
        ;;


        in al,60h
        dec al
        jnz short main_loop

        ret

k1      dw 400
text    db "FLARE - "

        end entry_point

