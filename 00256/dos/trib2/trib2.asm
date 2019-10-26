; trib2
; 256b intro by Galen of MAXTER
; coded for the 256b intro compo 
; at 0a000h demoparty.
; to contact me: e-mail: gal_mxtr@dir.bg
; greets to all asm coders and to BSL//ZcS -
; I saw this effect for the first time in his rocking Debut 4k intro

      .model tiny
      .code
      .386
      .startup
 begin:
      mov  bp,offset Buf

      mov  al,13h
      int  10h

      xor  al,al
      mov  dx,3c8h
      out  dx,al
      inc  dx
 Pal1:
      out  dx,al
      and  al,cl
      shr  al,1
      out  dx,al
      mov  al,cl
      not  al
      out  dx,al
      loop Pal1

 Main:
      push cs
      pop  es
      mov  di,bp
      mov  cx,64000
      xor  al,al
      rep  stosb

      fld  phase
      fadd p_inc
      fst  phase
      fstp angle

      push 0a000h
      pop  es

      mov  bx,50
 HLine:
      mov  cl,3
 C3:
      fld  angle    ; angle
      fadd angle    ; 2*angle
      fsin          ; sin(2*angle)
      fimul Rad     ; rad*sin(2*angle)
      fistp X

      fld  angle    ; angle
      fsin          ; sin(angle)
      fimul YR
      fiadd YR
      fiadd YR
      fistp Y
      mov  dx,Y

      mov  di,bx
      add  di,X
      mov  ch,43
 Scan:
      cmp  dl,byte ptr [bp+di+160]
      jbe  Skip
      mov  al,ch
      xor  al,bh
      and  al,8
      jz   Black
      add  al,ah
      add  ax,dx
 Black:
      mov  byte ptr [bp+di],al
      mov  byte ptr [bp+di+160],dl          ; Z-buf
 Skip:
      cmp  ch,22
      jbe  Dec_clr
      inc  ah
      jmp  NxtPix
 Dec_clr:
      dec  ah
 NxtPix:
      inc  di
      dec  ch
      jnz  Scan

      fld  angle
      fadd third
      cmp  cl,1
      ja   Skip_a
      fadd a_inc
 Skip_a:
      fstp angle
      loop C3

      add  bx,320
      cmp  bx,64370
      jb   HLine

      mov  dx,3dah
 retrace:
      in   al,dx
      test al,8
      jz   retrace

      mov  si,bp
      mov  di,80
      mov  dx,200
      mov  ax,160
Copy:
      mov  cx,ax
      rep  movsb
      add  di,ax
      add  si,ax
      dec  dx
      jnz  Copy

      in   al,60h
      dec  ax
      jne  Main

      mov  ax,3
      int  10h

      ret

Rad   dw 40
YR    dw 12
a_inc dd 3be49ba6h
p_inc dd 3ca3d70dh ;3cf5c28fh
third dd 40060a7ch
Phase dd 0
Angle dd ?
X     dw ?
Y     dw ?
Buf   db 64000 dup (?)

      end begin

