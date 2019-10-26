;                                                                    33bytes fire
;                                                      Mathieu "P01" HENRI | 0999

.model tiny
.code
.386
org 100h

start:

 mov al,13h
 int 10h
 mov bh,0a5h
 mov es,bx
 mov ds,bx

@mainLoop:
  in al,41h
  mov [bx],al
  inc bl

  lodsb
  add al,al
  add al,[si+319]
  add al,[si]
  shr al,2
  or  al,128
  stosb

  ;in al,60h
 ; dec al
 jmp @mainLoop
;ret

end start
