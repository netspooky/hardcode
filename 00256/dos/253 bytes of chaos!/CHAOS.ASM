;--------------------------------------;
;          253 Bytes of CHAOS          ;
;        Presented at CRASH '97        ;
;   4th Place  - 256 Byte Demo Comp.   ;     
;                                      ;
; Coded by CHAOS  (a.k.a Dan Selinger) ;
;--------------------------------------;


.386p
code  segment use16
  assume cs:code,ds:code
  org  100h

Start:
  xor  si,si                 ;------------------
  mov  bx,379                  ;Make me a sine table
  mov  cx,bx
  mov  bp,1560
  mov  di,offset SinValues
  push di
CreateSinTable:
  mov  ax,si
  sar  ax,7
  stosw
  mov  ax,si
  cwd
  idiv bp
  sub  bx,ax
  add  si,bx
  loop CreateSinTable

  pop  es
  mov  al,13h                  ;Init graphics
  int  10h                   ;---- 36 bytes ----

RepeatDrawVectors:
  mov  dx,3dah               ;------------------
VRT:
  in   al,dx
  test al,8
  jnz  VRT
NoVRT:
  in   al,dx
  test al,8
  jz   NoVRT                 ;---- 13 bytes ----

  mov  si,offset VectorData  ;------------------
  mov  bx,24
NextRow:
  mov  bp,-128
NextPoint:
  mov  cl,8
  lodsb
  test al,1
  jz   RotateWord              ;Decode object data
  dec  ax
  add  cl,cl
RotateWord:
  rol  al,1
  jnc  DontAddPixel          ;---- 23 bytes ----

  mov  di,65                 ;------------------
NextZ:
  pusha
  push di
  push dx

  call RotPoint                ;Rotate around each axis
  call RotPoint
  xchg di,bp
  call RotPoint              ;---- 17 bytes ----

  inc  cx                    ;------------------
  inc  bh
  xchg ax,di
  cwd
  shl  ax,cl                   ;Multiply X by 256
  idiv bx                      ;Divide by Z
  xchg ax,bp
  cwd
  shl  ax,cl                   ;Multiply Y by 256
  pop  si
  mov  di,ds:[si]
  stosb
  idiv bx                      ;Divide by Z
                             ;---- 19 bytes ----
  mov  di,-320               ;------------------
  imul di
  jc   short OffScreen
  xchg ax,di
  lea  di,[bp+di+32160]
OffScreen:
  mov  ds:[si],di

  pop  ax
  add  al,67
  jc   ColorSet
  mov  al,104
  jp   ColorSet                ;Do layering
  mov  al,1
ColorSet:
  stosb                      ;---- 26 bytes ----

  popa                       ;------------------
  inc  dx
  inc  dx

  sub  di,50
  jp   NextZ

DontAddPixel:
  add  bp,6
  loop RotateWord
  jnp  NextPoint
  sub  bx,6
  cmp  bx,-36
  jne  NextRow               ;---- 23 bytes ----

  db   0feh,4ch,offset Rotate-offset VectorData-46
                               ;Decrement rotate value
  xchg ax,si
  int  16h
  jz   RepeatDrawVectors
  mov  ax,3                    ;Done graphics
  int  10h                   ;---- 15 bytes ----

            ;we'll use the ret at the end of rotpoint to terminate!

RotPoint  proc
  db   0beh                  ;---------------------
  Rotate db 0,80               ; Self-modifying rotate value
  add  si,si
  lodsw
  mov  si,ds:[si+126]
  mov  cx,ax
  imul bx
  imul cx,di
  imul di,si
  imul bx,si
  add  di,ax
  sub  bx,cx
  mov  cl,7
  sar  bx,cl
  sar  di,cl
  xchg bx,bp
  ret                        ;---- 35 bytes ----
endp

                               ;Object Data
VectorData db 124, 198,  16, 125, 96
           db 199, 56,  199, 240
           db 199, 108, 199, 240
           db 192, 199, 198, 96, 240
           db 192, 254, 199, 56, 96
           db 192, 198, 254, 198, 12, 96
           db 192, 199, 198, 6, 96
           db 199, 199, 198, 0
           db 199, 199, 198, 96
           db 124, 199, 125, 96
                             ;---- 46 bytes ----

 org 3dah
  PrevCoords    dw 480*3 dup (?)
 org 0a000h
  SinValues     dw 390 dup (?)

ends
end Start
