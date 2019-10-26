; Nightshift 128-byte by Baudsurfer/rsi 2013 aka olivier.poudade.free.fr
; Greets to all Pouet and Dark Bit Factory users who program in assembly
; For 9x/2k/xp/DOSBox-0.74/Win7(32-bit). Coded on Core Duo 2GHz /w xpsp3  
; Youtube video :
  org 100h
  mov al,13h
  int 10h
  mov bl,8
  mov di,180h
A:mov ch,1fh
B:mov ax,cx
  stosb
  loop B
  add di,7fh
  dec bx
  jnz A
  dec cx
  les ax,[bx]
  aas 
  rep stosb
C:mov di,1410h
  mov dx,0ffach
D:mov bp,0ff60h
E:fninit
  fild word [si-0fdh]
  mov [si],dx
  fild word [si]
  fdiv st0,st1
  mov [si],bp
  fild word [si]
  fdiv st0,st2
  fldz
  fld st0
  mov al,ch
F:fld st3
  faddp st2,st0
  fadd st0,st2
  fist word [si]
  fld st1
  fistp word [si+1]
  mov bx,[si]
  add bx,word [si+15h]
  cmp al,byte [bx]
  jbe G
  dec ax
  jnz F
G:xor al,bh
  xor al,bl
  and al,11h
  stosb
  inc bp
  cmp bp,0a0h
  jnz E
  inc dx
  cmp dx,54h
  jnz D
  add word [si+15h],101h
  test cl,cl
  js I
  inc ax
  sub ch,al;dec ch
H:sub byte [si+16h],2
I:in ax,60h
  dec ax
  loopnz C
  ret