
; p„„tepisteet bx,cx,dx  v„rit al,ah  rekursiom„„r„ di

recursepoly:    ; edges bx,cx,dx
                ; recursively divides a triangle (depth = di)
                ; in smaller triangles of colors al,ah and draws them

        pop bp  ; return address
        pop dx  ; point0
        pop cx  ; point1
        pop bx  ; point2
        push bp

.r0     test di,di      ; out of recursions -> draw it
        je triangle

        cmp di,3        ; swap some edge coords. just for dEzIgN
        jc .c0
        xchg bx,dx

.c0     mov bp,2        ; loop twice (divide into two halves)
.l0     pusha

        push bx
        push dx         ; set one of the edges to a mediane vec
        add dl,cl
        rcr dl,1
        add dh,ch
        rcr dh,1
        pop bx
        pop cx

        dec di
        call .r0        ; recurse
        popa
        xchg cx,dx      ; blah
        inc ax ;ainiin tuo
        xchg al,ah
        dec bp
        jne .l0
        ret

triangle:               ; draws a constant-filled triangle
                        ; in a 256x256 buffer (at es:nnnn)
                        ; edges bx,cx,dx color ax                        
        mov bp,ax
        mov ax,cx
        sub ax,dx
        add ax,16
        and ax,31

        cmp bx,cx       ; y-sort
        jc .so0
          xchg bx,cx
.so0    cmp bx,dx
        jc .so1
          xchg bx,dx
.so1    cmp cx,dx
        jc .so2
          xchg cx,dx
.so2:

        inc ch          ; prevent flattops
        inc dh

        mov ax,dx       ; line #0 (p0->p2)
        sub ah,bh
        sub al,bl
        call .divsub    ; div
        mov di,ax       ; di=k02

        push dx   ;p2>
        push bp   ;col>

        mov ax,cx       ; line #1 (p0->p1)
        sub ah,bh
        sub al,bl
        call .divsub    ; div
        mov bp,ax       ; bp=k01

        mov dh,bl       ; dx=si=p0x
        mov dl,0
        mov si,dx

        pop ax    ;col<
        mov ah,ch ;y1   ; ax=y1;col. bx=y0 already

        call .drawlp    ; draw upper half

        pop bx    ;p2<
        mov ah,bh
        push ax   ;y2;col>

        mov ax,bx       ; line #2 (p1->p2)
        sub ah,ch
        sub al,cl
        call .divsub    ; div
        mov bp,ax       ; bp=k12

        pop ax    ;y2;col<
        mov bx,cx ;y1

.drawlp push cx         ;;;;;;;;;;;;;; drawloop

    .l0 cmp bh,ah
        je .o9

        add dx,di
        add si,bp

        mov bl,dh

        mov cx,si ;x1
        sub ch,dh ;x0
        jnc .c0
            neg cx
            std
    .c0 mov bl,dh
        push di
        mov di,bx
        mov cl,ch
        mov ch,0
        inc cx
        rep stosb
        cld
        pop di

        inc bh
        jmp .l0
    .o9 pop cx
        ret

.divsub push cx
        push dx
        mov cl,ah
        mov ah,al
        mov al,0
        mov ch,0
        cwd
        jcxz .c1 
        idiv cx
    .c1 pop dx
        pop cx
        ret
