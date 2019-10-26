;-------------------------------------------
; fluid64 (spiral-vortices and waves in 64b)
; by Rudi
;-------------------------------------------
  org 100h
  mov al,19
  int 16
; les bp,[bx]
  les cx,[bx]
  mov ds,bp
L mov cl,0
  mov bp,8
K mov bx,[T+bp-2]
  add cl,[bx+di]
  neg bx
  add cl,[bx+di]
  dec bp
  dec bp
  jnz K
  shr cl,2
  mov al,[di]
  dec ax
  and al,31
  sub al,cl
  cmp al,10
  jge M
  and al,1
  neg al
  add al,[di]
  and al,31
  mov [di],al
M lodsb
  stosb
  jmp L
T dw 319,320,321,1