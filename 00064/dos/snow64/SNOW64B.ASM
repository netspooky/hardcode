;Snow64
;A 64 byte intro by mados/TAP.
;mailto:mados@tap-home.de

code:
org 0100h

  mov al,13h
  int 10h

@MainLoop:
  ;xor ah,ah		;Needed for add si,ax
  push ds
  pop es		;Used in stosb
  mov di,@Buffer+248*256-1
  std			;Set direction flag to decrement di

  mov cx,248*256
@SubLoop:
  mov al,[di]		;Get pixel
  shr al,1		;Divide pixel by 2

  test cx,1111111000011111b
  jnz @NoNew
  mov al,7		;Put new pixels at top of screen
@NoNew:
  stosb			;Rewrite pixel
  mov si,di		;Will be used in add si,ax and in rep movsw

  cmp al,7		;Check if this pixel is a snow flake
  jne @NoFlake
  in al,40h		;Get random number
  shr al,6
  ;mov si,di
  add si,ax
  mov byte [si+320],15	;Move snow flake
@NoFlake:
  loop @SubLoop

  push word 0A000h-16-4
  pop es
  cld			;Clear direction flag to increment di
  mov ch,248/2		;mov cx,32000
  rep movsw		;mov [es:di],[ds:si]

  ;mov ah,0Bh		;Wait retrace
  ;int 10h
  hlt

  in al,60h		;Check keyboard
  dec al		;Esc will be 0
  jnz @MainLoop		;Break if esc is pressed
  ;mov ax,0003h		;Reset screen
  ;int 10h
  ret

data:
  @Buffer
  db 1
