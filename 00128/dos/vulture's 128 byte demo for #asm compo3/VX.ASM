
;
;   This code written by vulture a.k.a. Sean Stanek
;   Email: vulture@iastate.edu or Srstanek@aol.com
;
;   Please do not be lame, as I am releasing this source to the
;   public. Go ahead and learn from it or whatever and use parts,
;   just don't rip it (ahem, you know who you are).
;
;   Greets to: spASM, mcarp, as, Opcode, DooD, Falcon, Eledhrim.
;

segment code
assume cs:code,ds:code
org 100h
start:
.586

 add dh,10h                     ; allocate next 64kb of RAM for doublebuffer
 mov es,dx

 mov cx,di                      ; clear doublebuffer
 rep stosb

 mov al,13h
 int 10h

 mov dx,3c8h
 mov al,0
 out dx,al
 inc dx
@@pal:                          ; this will set a cyan palette
 pusha                          ;   0..63, 64..127, 128..191, 192..255
 mov al,0
 out dx,al
 popa
 out dx,al
 out dx,al
 inc al
 jnz @@pal

 pusha
going:
 mov ch,64000/256+1             ; do at least 64000 pixels
@@a:
 mov al,es:[di+320]             ; this is the effect. that is all. :)
 add es:[di],al
 inc di
 loop @@a
 popa

; mov di,07fffh
 mov di,7fffh*10000/31415       ; put pi here to save space
 add cx,40h                     ; rotation of point and cylinder
 mov [di],cx
 fild word ptr [di]
 mov [di],di                    ; la la la.. DI is somewhere ;)
 fild word ptr [di]
 fdivp                          ; scale nicely and use pi for sincos
; fldpi
; fmulp
 fsincos                        ; get sine and cosine
 mov word ptr [di],90           ; radius
 fild word ptr [di]
 fmul st(2),st(0)               ; multiply r*sin(theta) to get y
 fmulp                          ;          r*cos(theta) to get x
; fistp word ptr [di]
; mov ax,[di]
 pusha
     xchg si,ax                 ; si = 0 for later
 fistp word ptr [si]
 lodsw                          ; get x
 fistp word ptr [di]
 mov bx,[di]                    ; get y

 neg bx                         ; convert from window of (-160,-100)-(159,99)
; add bx,100
 imul bx,bx,320                 ; location = y*320+x
; add bx,ax
; sub bx,160-32000
     sub ax,160-32000
     add bx,ax
 mov byte ptr es:[bx],3fh       ; plot 3Fh into location in doublebuffer

 push ds
 push es
 push es
 pop ds
 push 0a000h
 pop es
; xor si,si                     ; si already 0
 xor di,di
 mov ch,32000/256+1             ; saving some more bytes...
 rep movsw                      ; copy double buffer to video
 pop es
 pop ds

 mov ah,1
 int 16h
 jz going


 mov ax,3
 int 10h
 int 20h        ; because [di] = [0000] which means it was overwritten :(

ends
end start
