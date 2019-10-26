;; gump -- 09. may 2003

locals @@
.model tiny
.386
.code

org 100h

banks       equ 5h
hStartVal   equ 0457d2000h
hLimit      equ 045b91000h

start:

    add     dh,10h
    mov     [buffer],dx
    mov     ax,04F02h
    mov     bx,101h
    int     10h

set_h:
    mov [h],hStartVal
mainloop:
    cmp word ptr [hplace+2],045b9h
    jg  set_h

    fldz                ; theta=0
    mov     cx,18720
plotloop:

    fld     h           ; h                     theta
    fadd    hAdd        ; h                     theta
    fst     h           ; h                     theta
    fsin                ; sin(h)                theta
    fld     st(1)       ; theta                 sin(h)  theta
    fmul    n           ; n*theta               sin(h)  theta
    fsin                ; sin(n*th)             sin(h)  theta
    fmulp   st(1)       ; sin(n*th)*sin(h)      theta
    fmul    radius      ; r*sin(n*th)*sin(h)    theta

                        ; r                     theta
    fld     st(1)       ; theta                 r       theta
    fsincos             ; cos(theta)            sin(th) r       theta

    fmul    st(0),st(2) ; x=r*cos(theta)        sin(th) r       theta
    fadd    halfWidth   ; x=hW + (r*cos(theta)) sin(th) r       theta

    fxch    st(1)       ; sin(th)               x       r       theta
    fmul    st(0),st(2) ; y=r*sin(th)           x       r       theta
    fadd    halfHeight  ; y=hH + (r*sin(th))    x       r       theta
    fistp   int_y       ; Why on earth does it work when this is added?
    fild    int_y       ; ^^..?
    fmul    fullWidth   ; y*width               x       r       theta
    faddp   st(1),st(0) ; (y*width)+x           r       theta
    fistp   place       ; r                     theta

    fstp    st(0)       ; theta - could be removed with a fmulp above?
    fadd    thetaStep   ; theta

    mov     ebx,[place]
    push    bx
    shr     ebx,16      ; div by 65536
    shl     bx,4        ; mul by 10h
    mov     dx,[buffer]
    add     dh,bl
    mov     fs,dx
    pop     bx
    mov     fs:[bx],byte ptr 30
    loop    plotLoop
    fstp    st(0)


; *** Copy to screen code below.
    push    0a000h
    pop     gs

    mov     ax,[buffer]

clearCx: loop clearCx

copyToScreen:
    mov     fs,ax
    add     ah,10h
    push    ax
    mov     ax,04f05h
    mov     dx,cx
    xor     bx,bx
    int     10h

    ;xor     si,si          ; si = 0 -- safe to assume?
    ;mov     ah,0
copyAndCleanLoop:
    mov     al,fs:[si]
    mov     gs:[si],al
    mov     fs:[si],ah      ; ah = 0 on return from int 10h
    inc     si
    jnz     copyAndCleanLoop

    pop     ax
    inc     cx
    cmp     cx,banks
    jnz     copyToScreen

    in  al,60h
    dec al
    jnz mainloop

    mov ax,3h
    int 10h

    ret

n           dd  1.0769230769230769230769230769231
thetaStep   dd  0.0043633231299858239423092269212215
radius      dd  150.0
fullWidth   dd  640.0

halfWidth   dd  320.0
halfHeight  dd  240.0
hAdd        dd  0.01

theta       dd  ?
place       dd  ?

hplace:
    h       dd  ?

buffer      dw  ?
int_y       dd  ?
x           dd  ?
y           dd  ?

fpuControlWord  dw  ?
end start
