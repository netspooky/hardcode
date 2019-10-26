;totalistic (alternative version in 75 bytes)
;by Rudi
;
;generates totalistic cellular automaton code 225.
;no time to optimize more so i just release it as it is.
;greetz to tinytro-pimps.

  mov al,13h
  int 10h
  push 0xa000
  pop es
  push word [bx]
  pop ds
  mov cx,65535
R lodsb
  and al,3
  mov[ds:di],al
  inc di
  loop R
  xor di,di
L mov si,225	;change this to computer other tca rules/codes
  mov al,[ds:di+0]
  add al,[ds:di+1]
  add al,[ds:di+2]
  push cx
  mov ch,al
  xor cl,cl
A xor dx,dx
  xchg ax,si
  mov bx,3	;base 3
  div bx
  xchg si,ax
  mov bl,dl
  cmp cl,ch
  je C
  inc cl
  jmp A
C pop cx
  xchg ax,bx
  mov [ds:di+321],al
  add al,52	;add some water color
  stosb
  jmp L