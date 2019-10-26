;"RAZZIA in 64 bytes"
;Just for fun code by mados/TAP.
;This is a sequel to "Razzia in FFh" by MadMan/TAP,
;released first at Mekka & Symposium 2001.
;http://www.tap-home.de/
;mailto:mados@tap-home.de

;      \|/
; лллллллл
; ллллллллл

org 0100h

  mov al, 03h
  int 10h

  push word 0B800h	;For use in stosw
  pop es

  mov di, (16 * 80 + 76) * 2 ;Row and column
  mov ax, '\' + (1 + 8 * 16) * 256
  stosw
  mov al, '|'
  stosw
  mov al, '/'
  stosw

  mov di, (17 * 80 + 71) * 2
  mov ax, 255 + (7 + 4 * 16) * 256
  mov cl, 7
  rep stosw

  dec ax		;mov al,'ў'
  stosw

  mov di, (18 * 80 + 71) * 2
  mov al, 'м'
  mov cl, 9
  rep stosw

  mov dx, 03D4h		;al = Funktionsnr. des CRT-Controllers
  mov ax, 0B0Dh		;mov ah,0Bh for use in int 10h
  out dx, al		;Change start adress of the graphics ram
  inc dx

  mov cl, 71 + 80	;Move over screen two times
@mainloop:
  mov al, cl
  out dx, al		;Anfangsadresse des Grafikspeichers
  int 10h
  int 10h
  loop @mainloop

  ret

  dw 0a000h		;Stupid bytes to fill 64b
