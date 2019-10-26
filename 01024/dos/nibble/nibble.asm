    ; nibble
    ; a 1kb stroll down memory lame
    ;
    ; GPL v2
    ;
    ; Revision history:
    ;
    ; 13 Jan 2003  initial release (1023 bytes)
    ; 14 Jan 2003  1009 bytes
    ;
    
    .model tiny
    .486
    .code
    org 100h

entry_point:
    ;
    ; code for intersection_y is the same as the code for intersection_x,
    ; except that 02h becomes 00h and vice versa
    ;

    mov si,offset intersection_x
    mov di,offset intersection_y
    mov cx,rep_length
biy:
    lodsb
    test al,al
    jz short biy_0
    cmp al,2
    jnz short biy_1
biy_0:
    xor al,2
biy_1:
    stosb
    loop biy

    mov ax,13h      ; mov al,13h may save a byte here but won't work on 
    int 10h         ; FreeDOS, since ax != 0 on that

    ;
    ; set up retarded palette
    ;

    mov cl,64
    xor bx,bx
pal_loop:
    mov dx,3c8h
    lea ax,[bx + 64]
    out dx,al
    inc dx
    mov al,cl
    out dx,al
    out dx,al
    xor ax,ax
    out dx,al
    dec dx

    lea ax,[bx + 128]
    out dx,al
    inc dx
    mov al,bl
    out dx,al
    out dx,al
    out dx,al
    dec dx

    lea ax,[bx + 128 + 64]
    out dx,al
    inc dx
    mov al,bl
    out dx,al
    xor al,al
    out dx,al
    out dx,al

    inc bx
    loop pal_loop

main_loop:

waitvr:
    mov dx,03DAh
vbl:
    in al,dx
    test al,8
    jnz short vbl
novbl:
    in al,dx
    test al,8
    jz short novbl

    finit

    mov bx,offset rot_ang_1
    mov si,offset astep
    fld dword ptr [bx]
    fadd dword ptr [si]
    fadd dword ptr [si]
    fstp dword ptr [bx]
    add bx,4
    fld dword ptr [bx]
    fadd dword ptr [si]
    fadd dword ptr [si]
    fadd dword ptr [si]
    fstp dword ptr [bx]

    mov ax,cs
    add ax,4096
    mov es,ax
    add ax,4096
    mov fs,ax

    ;
    ; initialize z-buffer
    ;
    push es
    mov es,ax
    mov al,7fh
    dec cx
    rep stosb
    pop es

    ;
    ; initialize virtual screen
    ;

    dec cx
fade_loop:
    mov al,es:[di]
    test al,al
    jns short fl_1
    mov ah,al
    and ah,0c0h
    and al,3fh
    sub al,5
    jns short fl_2
fl_1:
    xor al,al
fl_2:
    or al,ah
    stosb
    loop fade_loop

    ; donut
    ; 
    ; render donut
    ;
    ; input:
    ;   step, r_small, r_big
    ;
    ; output:
    ;   no
    ;
    ; mangles: 
    ;   all
    ;

donut:
    ;
    ; calculate donut mesh
    ;

    finit
    fldz            ; a 
    fldz            ; b | a 
    mov si,offset donut_mesh
    mov di,offset step
donut0:
    call calc_point
    add si,8
    fxch
    fadd dword ptr [di]
    fadd dword ptr [di]
    fxch
    inc cl
    pushf
    test cl,7
    jnz donut1
    fadd dword ptr [di]
donut1:
    popf
    jns donut0

    ;
    ; draw donut
    ;

    mov si,127
draw_donut_0:
    push si
    mov bx,si
    inc bx
    and bx,7
    mov di,si
    and di,78h
    or di,bx
    lea bp,[si + 8]
    and bp,127
    mov dl,128
    pusha
    call trifill
    popa
    lea si,[di + 8]
    and si,127
    xchg si,di
    mov dl,64 + 128
    call trifill

    pop si
    dec si
    jns short draw_donut_0

    ;
    ; text
    ;

    push ds

    push 0f000h
    pop ds

    mov di,226*256 + 256 - 6*8*2
    mov si,7
scrl0:
    mov cl,6*8
scrl1:
    shrd bx,cx,16 + 3       ; bx = cx >> 3
    and bx,7
    mov bl,cs:scrtext[bx]
    shl bx,3
    mov al,[bx + si + 0fa6eh]
    push cx
    neg cx
    add cl,6*8
    and cl,7
    shl al,cl
    pop cx
    db 0d6h ; salc
    and al,7
    stosb
    stosb
    loop short scrl1
    sub di,256 + 6*8*2
    dec si
    jns short scrl0

    ;
    ; copy virtual screen
    ;

    push es
    pop ds

    push 0a000h
    pop es

    mov si,28 * 256
    mov di,32
    mov bx,200
copy_scrn:
    mov cx,128
    rep movsw
    add di,320 - 256
    dec bx
    jnz copy_scrn

    pop ds

    in al,60h
    dec al
    jnz main_loop

    mov ax,3
    int 10h

    ret

    ;
    ; calc_point
    ;
    ; calculate point in donut surface; donut surface described parametrically
    ; with terms a and b, which go from 0 to 2*pi
    ;
    ; x = (R + r * sin(a)) * sin(b)
    ; y = r * cos(a)
    ; z = (R + r * sin(a)) * cos(b)
    ;
    ; nx = x - R * sin(b)
    ; ny = y
    ; nz = z - R * cos(b)
    ;
    ; input:
    ;   st(0): b
    ;   st(1): a
    ;   r_small: small radius
    ;   r_big: big radius
    ;
    ; output:
    ;   [si]: x
    ;   [si + 2]: y
    ;   [si + 4]: z
    ;
    ; mangles: 
    ;   bx

calc_point:
    mov bx,offset r_big

    ; donut points
    call calc_xyz
    fld dword ptr rot_ang_2 ; rot_ang, x, y, z, b, a
    fsin                    ; sin(rot_ang), x, y, z, b, a
    fimul word ptr [bx]     ; R * sin(rot_ang), x, y, z, b, a
    fadd
    call write_point

    call calc_xyz           ; x, y, z, b, a
    fld st(3)               ; b, x, y, z, b, a
    fsincos                 ; sin(b), cos(b), x, y, z, b, a
    fimul word ptr [bx]     ; R * sin(b), cos(b), x, y, z, b, a
    fxch
    fimul word ptr [bx]     ; R * cos(b), R * sin(b), x, y, z, b, a
    fxch st(2)              ; x, R * sin(b), R * cos(b), y, z, b, a
    fxch
    fsub                    ; nx, R * cos(b), y, z, b, a
    fxch st(3)              ; z, R * cos(b), y, nx, b, a
    fxch
    fsub                    ; nz, y, nx, b, a

    push si
    add si,128*4*2
    call write_point
    pop si
    ret

write_point:
    push bx

    mov bx,offset rot_ang_1
    call rotate
    add bx,4
    fxch st(2)
    call rotate

    sub bx,offset rot_ang_2 - offset k

    fiadd word ptr [bx]
    fistp word ptr [si]
    fiadd word ptr [bx]
    fistp word ptr [si + 2]
    fistp word ptr [si + 4]

    pop bx
    ret

calc_xyz:
    fld st(1)
    fsincos                 ; sin(a), cos(a), b, a 

    fimul word ptr [bx + 2] 

    fiadd word ptr [bx]     ; R + r * sin(a), cos(a), b, a 
    fld st(0)               ; R + r * sin(a), R + r * sin(a), cos(a), 
                            ;   b, a 
    fld st(3)
    fsincos                 ; sin(b), cos(b), R + r * sin(a), 
                            ;   R + r * sin(a), cos(a), b, a 
    fxch st(2)              ; R + r * sin(a), cos(b), sin(b), 
                            ;   R + r * sin(a), cos(a), b, a 
    fmul                    ; z, sin(b), R + r * sin(a), cos(a), b, 
                            ;   a 
    fxch st(2)              ; R + r * sin(a), sin(b), z, cos(a), b, a 
    fmul                    ; x, z, cos(a), b, a 
    fxch st(2)              ; cos(a), z, x, b, a 
    fimul word ptr [bx + 2] ; y, z, x, b, a 
    ret

    ;
    ; rotate
    ;
    ; rotate 2d point around origin
    ;
    ; y' = y * cos(rot_ang) - z * sin(rot_ang)
    ; z' = y * sin(rot_ang) + z * cos(rot_ang)
    ;
    ; input:
    ;   st(0): y
    ;   st(1): z
    ;
    ; output:
    ;   st(0): z'
    ;   st(1): y'
    ;
    ; mangles: 
    ;   st(0), st(1)
    ;

rotate:
    fld dword ptr [bx]
    fsincos             ; sin, cos, y, z
    fmul st(0),st(3)    ; z*sin, cos, y, z
    fxch                ; cos, z*sin, y, z
    fmul st(0),st(2)    ; y*cos, z*sin, y, z
    fxch                ; z*sin, y*cos, y, z
    fsub                ; y', y, z
    fxch st(2)          ; z, y, y'

    fld dword ptr [bx]
    fsincos             ; sin, cos, z, y, y'
    fxch st(2)          ; z, cos, sin, y, y'
    fmul                ; z*cos, sin, y, y'
    fxch st(2)          ; y, sin, z*cos, y'
    fmul                ; y*sin, z*cos, y'
    fadd                ; z', y'

    ret

    ;
    ; trifiller
    ;
    ; 1. start with rectangle covering the whole screen; push it to a stack
    ; 2. if there are no more rectangles on the stack, we're done
    ; 3. pop rectangle from stack
    ; 4. if triangle is outside rectangle, go to step 2
    ; 5. is rectangle is inside triangle, paint rectangle, go to step 2
    ; 6. triangle intersects rectangle; subdivide rectangle in 4 smaller 
    ;    rectangles, push them to stack, go to step 2
    ;
    ; input:
    ;   si: pointer to p0
    ;   di: pointer to p1
    ;   bp: pointer to p2
    ;   dl: color
    ;
    ; output:
    ;   no
    ;
    ; mangles: 
    ;   all
    ;

trifill:
    mov cl,3
triset:
    shl si,3
    add si,offset donut_mesh
    xchg si,di
    xchg di,bp
    loop triset

;    mov al,[si + 4]
;    mov byte ptr trif20 + 1,al

    mov ax,[si + 128*4*2]
    sub ax,k
    sar ax,1
    jns short frob
    xor ax,ax
frob:
    add ax,20
    cmp ax,63
    jle short frob2
    mov al,63
frob2:
    add al,dl
    mov byte ptr trif21 + 1,al

    ; order of triangle vertexes is clockwise?

    call dot_a
    xchg ax,bx
    call dot_b
    cmp ax,bx
    jl short skip
    ret
skip:
    mov bx,offset quad_stack
    xor ax,ax
    mov [bx],ax                 ; x
    mov [bx + 2],ax             ; y
    mov word ptr [bx + 4],256   ; square side
    add bx,6

trif_loop:
    ;
    ; if stack is empty, return
    ;

    cmp bx,offset quad_stack
    jne short trif0
    ret

trif0:
    ;
    ; pop square off the stack
    ;

    sub bx,6

    ;
    ; count how many vertices of the square are outside the triangle
    ;

    xor ax,ax

    mov dl,[bx]
    mov dh,[bx + 2]
    call inside_tri
    add dl,[bx + 4]
    call inside_tri
    add dh,[bx + 4]
    call inside_tri
    sub dl,[bx + 4]
    call inside_tri

    test al,al
    jnz short trif3

    ;
    ; subdivide it further if square is too small
    ;

    mov ax,[bx + 4]
    cmp ax,4
    jge subdivide_quad

    ;
    ; square is completely inside triangle; fill it
    ;

    push di
    call caddr
    mov al,[si + 4]
    cmp al,fs:[di]
    jg short trif4
    mov fs:[di],al
    trif21: mov al,7
    stosb
    sub di,258
    stosb
    inc di
    stosb
    add di,509
    stosb
    inc di
    stosb
trif4:
    pop di

    jmp trif_loop

trif3:
    ;
    ; either triangle intersects square, or square and triangle are disjoint
    ;

    ;
    ; drop the square if it's too small
    ;

    mov ax,[bx + 4]
    cmp ax,4
    jl short trif_loop

    push di
    call caddr
    bsr ax,[bx + 4]
    shl al,2
    add al,64 + 40
    dec di
    stosb
    stosb
    stosb
    sub di,258
    stosb
    add di,511
    stosb
    pop di

    ;
    ; if one of the points of the triangle is inside the square, triangle
    ; intersects square; subdivide it
    ;

    mov cx,3
foo:
    mov ax,[bx]
    cmp [si],ax
    jl short not_inside_quad
    add ax,[bx + 4]
    cmp [si],ax
    jg short not_inside_quad
    mov ax,[bx + 2]
    cmp [si + 2],ax
    jl short not_inside_quad
    add ax,[bx + 4]
    cmp [si + 2],ax
    jle short subdivide_quad
not_inside_quad:
    xchg si,di
    xchg di,bp
    loop foo

    ;
    ; if there are intersections between triangle sides and square sides,
    ; triangle intersects square; subdivide it
    ;

    mov cl,3
bar:
    mov dx,[bx]
    call intersection_x         ; check left side
    jc short subdivide_quad
    mov dx,[bx]
    add dx,[bx + 4]             ; check right side
    call intersection_x
    jc short subdivide_quad
    mov dx,[bx + 2]             ; check top side
    call intersection_y
    jc short subdivide_quad
    mov dx,[bx + 2]
    add dx,[bx + 4]             ; check bottom side
    call intersection_y
    jc short subdivide_quad
    xchg si,di
    xchg di,bp
    loop bar

    ;
    ; no triangle vertices inside the square, and no intersections between
    ; square sides and triangle sides.
    ;
    ; square and triangle are disjoint. drop the square.
    ;

    jmp trif_loop

caddr:
    mov cx,[bx + 4]
    mov ch,cl
    shr cx,1
    and cl,7fh
    mov al,[bx]
    mov ah,[bx + 2]
    add ax,cx
    mov di,ax
    ret

    ;
    ; subdivide square and push four smaller squares
    ;

subdivide_quad:
    mov ax,[bx]
    mov dx,[bx + 2]
    mov cx,[bx + 4]
    shr cx,1
    call push_quad
    add ax,cx
    call push_quad
    add dx,cx
    call push_quad
    sub ax,cx
    call push_quad
    jmp trif_loop
push_quad:
    mov [bx],ax
    mov [bx + 2],dx
    mov [bx + 4],cx
    add bx,6
    ret

    ;
    ; inside_tri
    ;
    ; check if point is inside triangle
    ;
    ; condition for point to be inside triangle is point is to the right of
    ; all triangle sides - this is checked by tri_test
    ;
    ; input:
    ;   si: pointer to p0
    ;   di: pointer to p1
    ;   bp: pointer to p2
    ;   dl: x
    ;   dh: y
    ;
    ; output:
    ;   increments al if point is outside
    ;
    ; mangles: 
    ;   no
    ;
inside_tri:
    mov cx,3
intri0:
    push dx
    call tri_test
    pop dx
    jl short intri2
    xchg si,di
    xchg di,bp
    loop intri0
    ret
intri2:
    inc al
    ret

    ;
    ; tri_test
    ;
    ; check if point is on right or left side of segment p0-p1
    ;
    ; the sign of the dot product between a vector normal to the segment
    ; and the segment p-p0 tells us on which side it is:
    ;
    ; d = (p0.y - p1.y) * (p.x - p0.x) + (p1.x - p0.x) * (p.y - p0.y)
    ;
    ; input:
    ;   si: pointer to p0
    ;   di: pointer to p1
    ;   dl: x
    ;   dh: y
    ;
    ; output:
    ;   sign flag
    ;
    ; mangles: 
    ;   no

tri_test:
    push ax
    push dx
    movzx ax,dl
    sub ax,[si]         ; ax = p.x - p0.x
    mov dx,[si + 2]
    sub dx,[di + 2]     ; dx = p0.y - p1.y
    imul dx
    pop dx
    push ax
    movzx ax,dh
    sub ax,[si + 2]     ; cx = p.y - p0.y
    mov dx,[di]
    sub dx,[si]         ; dx = p1.x - p0.x
    imul dx
    pop dx
    add ax,dx
    pop ax
    ret

    ; intersection_x
    ;
    ; y on the intersection between p0-p1 and x
    ;
    ; x = p0.x + t * (p1.x - p0.x)
    ; y = p0.y + t * (p1.y - p0.y)
    ;
    ; t = (x - p0.x) / (p1.x - p0.x)
    ;
    ; y = p0.y + (x - p0.x) * (p1.y - p0.y) / (p1.x - p0.x)
    ;
    ; input:
    ;   si: pointer to p0
    ;   di: pointer to p1
    ;   dx: x
    ;
    ; output:
    ;   y in ax
    ;
    ; mangles: 
    ;   dx

intersection_x:
    push cx

    xor cx,cx

    db 3bh, 54h, 00h ; cmp dx,[si + 0]
    jl short ix1
    inc cx
ix1:
    db 3bh, 55h, 00h ; cmp dx,[di + 0]
    jl short ix2
    xor cl,1 
ix2:
    jcxz no_intersection

    db 2bh, 54h, 00h ; sub dx,[si + 0]
    mov ax,[di + 2]
    sub ax,[si + 2]
    imul dx
    db 8bh, 4dh, 00h ; mov cx,[di + 0]
    db 2bh, 4ch, 00h ; sub cx,[si + 0]
    jz short no_intersection
    idiv cx
    add ax,[si + 2]  ; ax = y on intersection
    mov dx,[bx + 2]
    cmp ax,dx
    jl short no_intersection
    add dx,[bx + 4]
    cmp ax,dx
    jg short no_intersection
    pop cx
    stc
    ret
no_intersection:
    pop cx
    clc
    ret
end_intersection_x:

intersection_length = offset end_intersection_x - offset intersection_x

dot_a:
    db 8bh, 45h, 00h ; mov ax,[di + 0]
    db 2bh, 44h, 00h ; sub ax,[si + 0]
    mov dx,[bp + 2]
    sub dx,[si + 2]
    imul dx
    ret
end_dot_a:

rep_length = offset end_dot_a - offset intersection_x

r_big       dw  80
r_small     dw  40
step        dd  .3927   ;(2 * pi) / 16
astep       dd  .02
k           dw  128
rot_ang_1   dd  0.
rot_ang_2   dd  0.

scrtext     db  "!ERALf"

intersection_y:
            db intersection_length dup (?)
dot_b:
            db offset end_dot_a - offset dot_a dup (?)

donut_mesh  dw 128*4 dup (?)
normals     dw 128*4 dup (?)

sinus       dw ?

quad_stack:

    end entry_point
