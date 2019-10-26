bits 16
org 0x100
_N      equ     700
_M      equ     70


start:
    les bp,[bx]
    mov al,0x13
    int 0x10


    ; palette
    mov dx,0x3c8
    out dx,al
    inc dx
.pal_loop:
    add ax,cx
    shr ax,2
    out dx,al
    out dx,al
    ;mov ax,cx
    ;shl ax,1
    out dx,al
    loop .pal_loop
    push 0x9000
    pop fs
    xchg bp,dx          ; this segment will be used as our backbuffer
       
mainloop:
;   xor di,di
;   mov cx,256
;.test:
;   mov ax,cx
;   stosb
;   loop .test
 
.getN:
    mov bx,_N
.Nloop:
    mov si,_s
   
    fld dword [si]       ; s
    fadd dword [si-16+2]        ; s+=ds
    fstp dword [si]             ; s'
   
.getM:
    mov dx,_M
.Mloop:
 
    mov si,_tmpw
 
    fld dword [si-12]       ; s
    fsincos                 ; sin(s) cos(s)
    fld1                    ; 1 s sin(s) cos(s)
    fdivr dword [si-12]
    fsincos                 ; sin(s/2) cos(s/2) cos(s) sin(s)
   
    mov word [si],dx
    fild word [si]
    fmul dword [si-24+2]    ; _dt
    fadd dword [si-32+2]    ; _t
   
    fmul st1,st0            ; t t*sin(s/2) cos(s/2) cos(s) sin(s)
 
   
    fmulp st2,st0       ; t t*sin(s/2) t*cos(s/2) cos(s) sin(s)
    fld st1             ; t*cos(s/2) z t*cos(s/2) cos(s) sin(s)
    fmul st3            ; t*cos(s/2)*cos(s) z t*cos(s/2) cos(s) sin(s)
    faddp st3,st0       ; z t*cos(s/2) x sin(s)
    fxch st3            ; sin(s) t*cos(s/2) x z
    fmul st1,st0        ; sin(s) sin(s)*t*cos(s/2) x z
    fsubp st1           ; y x z
    fxch                ; x y z
 
    mov cl,3            ; rotate about x,y and z axis
.rotation:
 
    fldpi                   ; PI       
    fimul word [si-4]       ; (_angle)
    fidiv word [._180+2]
 
    fsincos                 ; sin cos x y z
    fld st2                 ; x sin cos x y z
    fmul st2                ; x*cos sin cos x y z
    fld st4                 ; y x*cos sin cos x y z
    fmul st2                ; y*sin x*cos sin cos x y z
    fsubrp st1              ; x' sin cos x y z
    fxch                    ; sin x' cos x y z
    fmulp st3,st0           ; x' cos x*sin y z
    fxch                    ; cos x' x*sin y z
    fmulp st3,st0           ; x' x*sin*cos z
    fxch                    ; x*sin x' y*cos z
    faddp st2               ; y ' x' z
    fxch st2                ; z y x    
    loop .rotation
                            ; z y x
    fld st0                 ; z z y x
    fimul word [._32+1]     ; zcol
    fistp word [si]         ; _tmpw
   
    mov ax,word [si]        ; _tmpw
    add ax,128+21
 
    fiadd word [._180+2]    ; z' y x    (zdist)
    fxch                    ; y z x
   
    fimul word [si-20+2]    ; (_persp)
    fdiv st1                ; y/z z x
    fistp word [si]         ; z x       (_tmpw)
   
    mov di,[si]
    lea di,[di+100]         ; y = y+100, lea saves a byte here
    imul di,320
   
   
    fdivp st1               ; x/z
    fimul word [si-20+2]    ; (_persp)
    fistp word [si]         ; x in tmpw
 
    add di,word [si]
._180:
    lea di,[di+bp+180]      ; the constant 180 is being
                            ; also used from elsewhere in the
    cmp byte [fs:di],al     ; code :)
    jnb .next  
 
    ; z-buffer 
    mov [fs:di],al
 
    ; texture and shading
    pusha
    xor dl,bl
    and dl,11111b
    sub dx,ax
    xchg ax,dx
._32:
    add ax,64
 
    mov [di],al
    ;stosb
    popa
.next:
 
    inc di
    dec dx
    jnz .Mloop
 
    dec bx
    jnz .Nloop
   
    inc word [si-4]             ; _angle
 
    mov dword [si-12+2],edx     ; _s
   
    mov ch,0x7D
    mov si,bp
    xor di,di
.copy_and_clear:
    mov word [fs:di],dx
    movsw
    ;mov bx,si
    ;xor bx,di
    mov word [si-2],dx
    loop .copy_and_clear
 
    in al,0x60
    dec ax
    jnz mainloop
 
    ret
 
_vars: 
    _t      dd  -0.4
    _ds     dd  0.00897597901025655210989326680937
    _dt     dd  0.011428571428571428571428571428571     ; dt = 0.8/M;
    _persp  dw  11500
 
_data:
   
    _s       equ  _data+4
    _tw      equ  _data+8
    _angle   equ  _data+12
    _tmpw    equ  _data+16
