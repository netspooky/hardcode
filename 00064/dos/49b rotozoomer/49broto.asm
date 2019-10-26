;----------------------------------------------------------------------
; 49 byte (faked) rotozoomer
; by Gargaj/Ümlaüt Design (c) 2002
;
; Special hiho goes to Ryg/Farbrausch for asking us to make smaller
; rotozoomers than 51 bytes. Yes, it's faked, it's only a nice(?) try,
; but still, I'm quite happy since I managed to code this :)
;----------------------------------------------------------------------

;%DEFINE QUIT    ;; --- enable this to use exit routine (+10 bytes)
;%DEFINE OFFSET  ;; --- enable this to use offsetting   (+ 8 bytes)

ZOOM equ 3

org 100h
start:
  mov al,13h
  int 10h

  les di,[bx]

  
ciklus:
  mov cl,199
  xor di,di
  
  c1:
  push cx

   mov cx,320
   c2:
    pop bp
    push bp       ; ax/bx-ben szamolunk, x=>cx, y=>bp, si=>counter

    mov ax,si
    mul bp
    shr ax,ZOOM
    mov bx,cx
    sub bx,ax
%IFDEF OFFSET    
    add bx,si
%ENDIF
    push bx

    mov ax,si
    mul cx
    shr ax,ZOOM
    add ax,bp
%IFDEF OFFSET    
    mov bx,si
    shr bx,1
    add ax,bx
%ENDIF
    pop bx

    or al,bl
    stosb

   loop c2

  pop cx
  loop c1 
  
  dec si
  
%IFDEF QUIT
  mov ah,1
  int 16h
jz ciklus

  mov al,3
  int 10h

  int 20h

%ELSE
  jmp short ciklus
%ENDIF
