render_perspective:

        ; bx=kulma
        ; ds=cs
        ; fs:00 = bitmap
        ; es:di = destination
        ; [.x0],[.y0] = silm„piste

        mov si,sin_table

        ; lyhennä tätä joskus?

        and bx,510
        mov ax,[si+bx]
        mov [.dx],ax

        add bx,128
        and bx,510
        mov ax,[si+bx]
        mov [.dy],ax

        add bx,48   ;128+48
        and bx,510
        mov ax,[si+bx]
        mov [.du0],ax

        add bx,128  ;256+48
        and bx,510
        mov ax,[si+bx]
        mov [.dv0],ax

        mov cx,128*3
        xor ax,ax
        rep stosw

        mov esi,8

.l1     inc si
        push si

        ; oli: dx, ax, 10000, si, bp
        xor edx,edx     ; oli: ax=5000, cbw, si alussa 0
        mov eax,500000000
        idiv esi
        mov ebp,eax     ; bp = r = 10.000/scanline

        mov ax,0        ; x=(dx*r)>>8
        .dx equ $-2
        cwde;;!
        imul ebp;;bp
        shrd eax,edx,24
        add ax,0
        .x0 equ $-2
        mov bl,ah       ; bl = x.hi
        mov cl,al       ; cl = x.lo
        shl cx,8

        mov ax,0        ; y=(dy*r)>>8
        .dy equ $-2
        cwde
        imul ebp
        shrd eax,edx,24
        add ax,0
        .y0 equ $-2
        mov bh,ah       ; bh = y.hi
        mov dl,al       ; ch = y.lo
        shl dx,8

        push dx

        mov ax,0        ; du=du0*r
        .du0 equ $-2
        cwde
        imul ebp
        shrd eax,edx,24
        mov [.dulo],ax
        shr eax,16
        mov [.du],al    ; [.du]=du.hi

        mov ax,0        ; dv=dv0*r
        .dv0 equ $-2
        cwde
        imul ebp
        shrd eax,edx,24
        mov [.dvlo],ax
        shr eax,16
        mov [.dv],al    ; [.dv]=dv.hi

;       mov dh,al       ; dh=du.lo, dl=dv.lo

        pop dx

        mov bp,256
.l0     add cx,0
        .dulo equ $-2
        adc bl,0
        .du equ $-1
        add dx,0
        .dvlo equ $-2
        adc bh,0
        .dv equ $-1
        mov al,[fs:bx]
        stosb
        dec bp
        jne .l0

        pop si
        cmp si,128+4
        je .ret
        jmp .l1

.ret:   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;do_bumpmap:    ; pois?
;
;       ; es+ds => es
;
;       pusha
;
;       movzx bx,byte[cs:timer]
;       shl bx,1
;       mov al,[cs:sin_table+bx+1]
;       mov ah,[cs:sin_table+bx+100+1]
;       and al,254
;       mov si,ax
;
;       xor di,di
;       mov cx,32768
;.l0    lodsw
;       add ax,[es:di]
;       or ax,0x8080
;       stosw
;       loop .l0
;       
;       popa
;       ret




