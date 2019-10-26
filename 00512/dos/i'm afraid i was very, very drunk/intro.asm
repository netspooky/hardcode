;I'm afraid I was very, very drunk
;y0bi / wAMMA
;2013-9-21
org 0x100

    mov al,13h
    int 10h
;--------
    push 07000h     ;sinetable
    pop ds
    push 0a000h
    pop es
    push 06000h     ;rotated and projected object (coordinates)
    pop fs
    push 05000h     ;virtual screen, also zbuffer.
    pop gs
;---------
    mov dx,3c8h
    xor ax,ax
    out dx,al
    inc dx
    xor cx,cx
PalLoop:
    mov al,cl
    shr al,2
    out dx,al
    ror al,1
    out dx,al
    rol al,1
    out dx,al
   inc cl
    jnz PalLoop
;---------
    xor di,di
SinGenLoop:
    mov ax,di
    shr ax,1
    add ax,64
    cbw
    cwd
    mov ax,di
    imul al
    sub ah,64
    xor ax,dx
    sar ax,6
    mov [di],ax
    inc di
    inc di
    jnz SinGenLoop
;--------------------
;Rotation is done around z and then around x
;si - angle. 100h at first
MainLoop:
    mov bx,si
    shr bx,2
    shl bx,1
    mov bx,[bx]
    sar bx,1
    add bx,128
    xor bh,bh
    mov bp,Object1
    mov cx,28
MorphLoop:
    mov al,[bp]
    sub al,[bp+28]
    cbw
    imul bx
    sar ax,8
    add al,[bp+28]
    mov [bp+28*2],al
    inc bp
    loop MorphLoop

;--------------------------------------------------------
;di -> coordinates
    xor di,di
    mov bp,Object+26
MakeObjectLoopO:
    mov bx,512+32   ;make one extra loop..
MakeObjectLoopI:
    mov al,[bp+1]   ;get x
    cbw
    imul word [bx]
    mov cx,ax
    sar ax,8
    imul word [si]          ;x=cosx
    push ax
    mov al,[bp] 
    cbw 
    imul word [si+128]
    pop dx
    sub dx,ax               ;x=xcosx-siny
    push dx                 ;stack -> x
    mov al,[bp]
    cbw
    imul word [si]
    xchg ax,cx
    imul word [si+128]
    sar cx,8
    add cx,dx
    xchg ax,cx
;-------------------
;around x
    push ax
    imul word [si]
    push ax
    mov al,[bp+1]
    cbw
    imul word [bx+128]
    sar ax,8
    mov cx,ax           ;z
    imul word [si+128]
    neg ax
    pop dx
    add ax,dx           ;ycosx-zsinx
    pop dx              ;get old y and store new one
    push ax             ;stack -> yx, dx -> last y

    xchg ax,cx
    mov cx,dx           ;ax -> z cx -> y
    imul word [si]      ;zcos
    xchg ax,cx
    imul word [si+128]  ;ysin
    add ax,cx           ;zcos+ysin
    sar ax,8
    mov cx,ax
    neg ax
    add al,64
    mov [fs:di+2],ax
    add cx,190
;---------- 
    pop ax
    cwd
    idiv cx
    add al,128
    mov [fs:di],al
    pop ax
    cwd
    idiv cx
    add al,100
    mov [fs:di+1],al    ;store coordinate

    add di,4
    sub bx,32
    jnz MakeObjectLoopI
    dec bp
    dec bp
    cmp bp,Object
    jns MakeObjectLoopO
    
;--------------------------
    push si

    mov di,17*4*12
    mov cx,13
DrawObjectLoopO:
    xor bx,bx
DrawObjectLoopI:
    push di
    mov al,[fs:di+bx+4+2]
    mov si,[fs:di+bx+4]
    mov bp,[fs:di+bx+17*4]
    push word [fs:di+bx+17*4+4]
    mov di,[fs:di+bx]
    call polyfiller
    pop di
    call polyfiller
    pop di
    add bx,4
    cmp bx,16*4
    jb DrawObjectLoopI
    sub di,17*4
    loop DrawObjectLoopO
    pop si

;--------------------------
    xor di,di
FlipLoop:
    xor ax,ax
    xchg al,[gs:di]
    mov [es:di+bx+32],al
    shld bx,di,8
    shl bx,6
    inc di
    cmp di,256*200
    jb FlipLoop

    lodsw

    in al,60h
    cmp al,1
    jne MainLoop
    mov ax,3h
    int 10h
    ret

;-------------------------------------------------------------  
;bp,si,di -> coordinates for poly. Z in ax
polyfiller:
    pusha
    mov [cs:smc-1],al
    mov bl,31
outer:
    mov dx,bp
    mov cx,si
    call interp
    push ax
    mov dx,di
    call interp
    mov dx,ax
    pop cx
    mov bh,31
inner:
    xchg bl,bh
    call interp
    xchg ax,bx
    push ax
    mov ah,4
loopy:
    mov al,0xff
smc:
    cmp byte [gs:bx],al
    ja nopix
    mov byte [gs:bx],al
nopix:
    cmp ah,2
    jne jaa
    add bx,256-2
jaa:
    inc bx
    dec ah
    jnz loopy
    pop bx
    xchg bl,bh
    dec bh
    jns inner
    dec bl
    jns outer
    popa
    retn
;bl -> counter for interpolation
; dx,cx -> coordinates. dx -> interpolated coord.
interp:

    push dx
    mov al,cl
    sub al,dl
    imul bl
    sar ax,5
    add dl,al
    mov al,ch
    sub al,dh
    imul bl
    sar ax,5
    add dh,al
    xchg ax,dx
    pop dx
    retn
;-----------------------------------------------------------

;Bottle
Object1 db  -50,0
        db  -50,16
        db  -45,16
        db  -45,10
        db  -25,10
        db  -20,15
        db  -15,27
        db  -10,33
        db  0,35
        db  15,35
        db  30,35
        db  50,30
        db  55,25
        db  55,0


;Glass
Object2 db  -20,13
        db  -15,17
        db  -10,20
        db  -7,22
        db  -5,23
        db  5,25
        db  10,23
        db  15,18
        db  20,10
        db  25,2
        db  30,2
        db  33,17
        db  35,20
        db  35,0
Object:
        db 'meh' ; meh

