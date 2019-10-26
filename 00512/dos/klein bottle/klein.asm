org 100h

;set video mode 13h and configure palette
mov ax, 13h
int 10h

mov cx, 64
pal:
  mov dx, 03C8h
  mov al, cl
  out dx, al
  inc dx
  out dx, al
  out dx, al
  out dx, al
loop pal

finit

main:

fld dword [angle]
fadd dword [dalpha]
fst dword [angle]
fsincos
fstp dword [cosa]
fstp dword [sina]

mov cx, ds
add cx, 8192
mov es, cx
mov cx, 64000
xor di, di
xor al, al
cld
rep stosb


fldz
mov cx, 512
u: 
  fldz
  mov bx, 512
  v:
	;call torus
    call klein

    mov di, x
    mov si, z
    call rotate   
    mov di, z
    mov si, y
    call rotate

    fld dword [z]
    fadd dword [f55]
    fstp dword [z]
     
    ;project y 	
    fld dword [y]
    fdiv dword [z]
    fmul dword [ASP]
    fld1
    faddp st1, st0
    fimul word [iH2]
    fistp word [iy]

    ;project x
    fld dword [x]
    fdiv dword [z]
    fld1
    faddp st1, st0
    fimul word [iW2]
	fistp word [ix]

    ;load address
    mov di, word [iy]
    imul di, di,  320
    add di, word [ix]
    mov al, byte [es:di]
    cmp al, 63
    je ob
	  inc al
      stosb
	ob:
    ;.....
    fadd dword [fStep]

    dec bx
    test bx,bx
    jnz v
  .end_v:
  fstp st0;pop

  fadd dword [fStep]
  loop u
.end_u:
;  fstp st0;pop

push ds
xor di, di
xor si, si
push es
pop ds
push 0A000h
pop es
mov cx, 64000
rep movsb
pop ds


.retrace:
  mov dx, 03DAh
  in al, dx
  test al, 8
jz .retrace

;check for keystroke
wt:
mov ah, 1
int 16h
jz main

quit:
;go to 80x25 video mode and exit
mov ax, 3h
int 10h
ret

;torus:
;  fld st0
;  fsincos
;  fidiv word [i2]
;  fiadd word [i2]
;  fld st3
;  fsincos
;  fmul st0,st2
;  fstp dword [x]
;  fmul st0,st1
;  fstp dword [y]
;  fcomp
;  fidiv word [i2]
;  fstp dword [z]
;  ret
;
   

rotate:
  fld dword [di]
  fmul dword [cosa]
  fld dword [si]
  fmul dword [sina]
  fsubp st1,st0
  fld dword [di]
  fmul dword [sina]
  fld dword [si]
  fmul dword [cosa]
  faddp st1, st0
  fstp dword [si]
  fstp dword [di]
  ret


klein: 
  fld st1
  fsincos
  fst dword [cosu]
  fidiv word [i2]
  fld1
  fsubp st1,st0
  fchs
  fmul dword [f06]
  fstp dword [z]
  fstp dword [sinu]
  fld st0
  fsincos
  fstp dword [cosv]
  fstp dword [sinv]

  fld dword [z]
  fmul dword [cosv]
  cmp cx, 256
  jbe xugepi
    fmul dword [cosu]
    jmp xupi
  xugepi:
    fchs
  xupi:
  fld1
  fadd dword [sinu]
  fmul dword [cosu]
  fmul dword [f09]
  faddp st1, st0
  fstp dword [x]

  fld dword [sinu]
  fimul word [i2]
  fsub dword [f06]
  fchs
  cmp cx, 256
  jbe yugepi
    fld dword [sinu]
    fmul dword [cosv]
    fmul dword [z]
    fsubp st1, st0
  yugepi:
  fstp dword [y]

  fld dword [z]
  fmul dword [sinv]
  fstp dword [z]

  ret 

constants:
  i2     dw 2
  iW2    dw 160
  iH2    dw 100
  fStep  dd 0.01227184630308512
  ASP    dd 1.6
  f55    dd 5.5
  f06    dd 0.6
  f09    dd 0.9
  dalpha dd 0.0523598775598298873
  angle  dd ?
  x      dd ?
  y      dd ?
  z      dd ?
  ix     dw ?
  iy     dw ?
  sina   dd ?
  cosa   dd ?
  sinv   dd ?
  cosv   dd ?
  sinu   dd ?
  cosu   dd ?
