; -----------------------------------------------------
;                  n0y / NEVER ^ BCF
;
;           a nice lense effect in 256 bytes
;
;            released at 0a000h 2003 held in
;                  in Spiegelberg/Jux
;                  (i like the name!) 
;
;
; be sure to visit our website at http://www.never.de
; visit tame records: http://www.tame.de
; also have a look at my 64byte entry
; come to next geekcamp!
; drop me a mail: noy@never.de
;
; -----------------------------------------------------



; just in case, i've static references to cs
org 100h

pusha

; want 2 extra bytes? replace
push word 0xa000
pop es
; by:
;   les [bp], bx
; i guess u know it 

; gfx
mov al, 0x13
int 0x10

; palette function will use 
; sin, cos and 1+sin for color values
; ein hoch auf die fpu!
mov dx, 0x3c9
col:
  push cx
  mov si, sp               ; addressing via stack
  fild word [si]
  mov word [si], 80
  fidiv word [si]
  fld st0
  fsincos
  fxch st3
  fld1
  faddp st1
  fsin
  pop ax
  mov bl, 3
  inner:
    push word 63           ; not mov byte [si], 63
                           ; since i use cx (dirty)
    fimul word [si]
    fabs
    fistp word [si]
    pop ax
    out dx, al
    dec bl
  jnz inner   
loop col

pointloop:
    ; i use div/mod for x/y coordinates.
    ; using dx, ax loops may be smaller...
    mov ax, di
    xor dx, dx
    mov bx, 320
    div bx
    shr bx, 1           ; since 160 is center of screen

    ; tests if inside lense:
    ;  sqrt((centerx-x)^2+(centery-y)^2) < diameter
    push bx
    fild word [si]
    mov word [si], dx
    fisubr word [si]
    fmul st0
    pop cx
    push word 100
    fild word [si]
    mov word [si], ax
    fisubr word [si]
    fmul st0
    faddp st1
    fistp word [si]
    pop cx
    
    cmp ch, byte 0x1f    ; i don't need that much precision
    jg short nofpu

    ;ax: line(y), dx: col(x)
    
    sub dx, bx           ;bx is center of screen (x)
    sub ax, byte 100     ;center of screen (y)
    
    ;i map screen coordinates through lense to texture coordinates

    ;calc z=sqrt(radius^2-x^2-y^2) -> st0
    
    push word 0x100
    fild word [si]
    fimul word [si]
    
    mov [si], ax
    fild word [si]
    fimul word [si]
    fsubp st1
    
    mov [si], dx
    fild word [si]

    fimul word [si]
    fsubp st1
    fsqrt

    ;calc (dist-z) -> st0, st1
    mov word [si], 330
    fild word [si]
    fsub st1
    fld st0

    ;calc (x/z) * first_(dist-z) -> dx
    mov [si], dx
    fild word [si]
    fdiv st3
    fmulp st1
    fistp word [si]
    mov dx, [si]

    ;calc (y/z) * second_(dist-z) -> ax
    mov [si], ax
    fild word [si]
    fdiv st2
    fmulp st1
    fistp word [si]
    mov ax, [si]
    
    ;clear fpu stack and stack
    fistp word [si]
    pop cx

    ;position offset hack (to correct some displacement)
    add dx, byte 30
    sub ax, byte 30
    
    nofpu:         ;outside lense: texture-coord=screen-coord

    add ax, [si+4] ;we want that nice bounce
    add dx, bp
    xor al, dl     ;simple XOR texture
    stosb
    or di, di
  jnz short weiter  ;jump pointloop, but *short* jmp

  ;exit if keypressed
  in al, 0x60
  cbw               ;sign extend: smaller than clearing before
  dec ax
  jnz ok
    popa 
    mov al, 0x3     ;back to text mode
    int 0x10
    int 0x16
    mov ah, 0x9
    mov dx, 501
    int 0x21        ;print my tag (important!)
    ret
  ok:
  
  inc word [si+8]          ;[si+8] is resp. for the movement
  fild word [si+8]
  mov word [si], 0x0020
  fidiv word [si]
  fsin
  fabs
  fchs                     ;bouncing at the top
  mov byte [si], 0x5f
  fimul word [si]
  fistp word [si+4]        ;bouncing: -5Fh*abs([si+8]/20h)
  mov bx, [si+8]
  rcr bh, 1                ;x-movement: change dir if > 512
                           ;i'd really liked >1024, but thats
			   ;1 byte more...
  jc runter
    add bp, byte 4
  runter:
    sub bp, byte 2
  weiter:
jmp pointloop

ostr: 
db "nOy@0a000h$"           ;wer den platz braucht hats nicht kapiert
