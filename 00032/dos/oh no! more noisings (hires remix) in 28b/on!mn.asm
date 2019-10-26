;Oh No! More Noisings (Hires Remix) in 28b.
;------------------------------------------
;Hi-resolution 640x400 static in VESA-mode.
;How to make the best looking noise since Direct X!
;No more noise in mode 13h.
;by Rudi (8th feb. 2017)

org 100h
  les bp,[bx]   ;load es=videomem
  mov ax,4f02h  ;super vga (VESA)
  mov bh,1      ;video mode (640x400 256c)
  int 10h
S mov ax,0x4f05 ;video control
  xor bx,bx     ;0=set bank, window a
  int 10h
P xchg ax,si	;pseudo random generator
  sbb ax,si
  stosb
  loop P        ;loop the fuck
  inc dx        ;bank-index
  and dx,3
  jmp S
  
;I know some code-tard can optimize this
;further. PCS-sound will fit the 32b limit,
;but it will be darn slow due to the
;interrupt inside the loop.
                           ;Lazy non-keypress-exit.