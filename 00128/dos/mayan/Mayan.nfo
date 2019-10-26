; Mayan by Baudsurfer/rsi 2014 aka olivier.poudade.free.fr
; A 128 bytes intro with sound tested on XPSP3 and DOSBox
; Presented at Outline demoparty in Eersel/The Netherlands
; P.S : prefer XPSP3 and turn volume to the maximum please
; Greets to UkkO Ggn Fra Den and assembly language lovers 
  org 100h
  mov al,13h
  int 10h
  les bp,[bx]
  mov dx,G
  mov ax,251ch
  int 21h
A:mov cl,0ffh
  lahf
B:mov bl,cl
  not bl
  cwd
  lea ax,[di-10h]
  mov bp,140h
  div bp
  call F
  call F
  mov al,byte [fs:46ch]
  add bl,al
  add bl,ah
  test al,20h
  jnz C
  add dh,cl
C:test al,40h
  jnz D
  add dh,al
D:mov dl,ah
  shld bp,bx,0ah
  sub ah,[bp]
  and ah,dh
  xor ah,dl
  test si,200h
  jnz E
  and ah,bl
E:and ah,20h
  loopz B
  mov al,dl
  inc ax
  mul dh
  mul bl
  stosb
  jmp A
F:sub ax,64h
  imul ax,bx
  add ah,13h
  xchg ax,dx
  ret
G:lodsb
  mov dx,331h
  mov al,3fh
  out dx,al
  dec dx
  mov al,99h
  out dx,al
  mov ax,si
  test al,dh
  jnz H
  and al,4
  sahf
  adc al,31
  out dx,al
  out dx,al
H:iret