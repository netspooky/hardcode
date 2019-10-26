;"PLASCII"
;A 64 byte intro by mados/TAP.
;Done for the 0a000h demoparty, held in Spiegelberg-Jux (near
;Stuttgart/Germany), January 2002.
;Based on an idea by Tomaes/TAP.
;Special thanks to MadMan/TAP for inspiration.
;http://www.tap-home.de/
;mailto:mados@tap-home.de

;%define debug		;Remove semicolon to enable debuging mode

code:
org 0100h
  ;db 19h, 59h, 5ch, 4ch ;This is the color table, stack will be destroyed
  ;mov bh, 1		;mov bx,0100h
  mov bx, Colors	;used in xlatb
  push word 0B800h
  pop es

@mainloop:
  ;xor di, di		;di will loop from 0000h to ffffh

  mov ch, 256 / 4	;70 Hz/4 = 17.5 frames per second
@FireLoop:
  mov al, [es:di]
  add al, [es:di + 2]
  add al, [es:di + 160]
  add al, [es:di + 162]
  dec ax		;Is equal to add al, 0FFh
  shr al, 2		;Calculate average
  jz @NoDec
  dec ax
@NoDec:
  cmp ch, 51
  jne @NoBaseline
  in al, 40h
@NoBaseline:
  stosb
  shr al, 2		;Divide character to get his color
  cmp al, 4
  jb @ColorOk
  mov al, 3		;mov ax,0B03h (smaller)
@ColorOk:
  xlatb
  stosb
  loop @FireLoop

  mov ah, 0Bh
  int 10h

%ifdef debug
  ;mov ah,0Bh		;Get stdin status
  int 21h
  cmp al,0
  je @mainloop		;Break if any key is pressed
  mov ah,06h		;Read character from standard input
  int 21h
  ;in al,60h
  ;dec al
  ;jnz @mainloop
  ret
%else
  jmp short @mainloop	;Run forever
%endif

data:
  Colors db 19h, 59h, 5ch, 4ch
