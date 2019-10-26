;"MATRIX64"
;A 64 byte screensaver by mados/TAP.
;Done for the 0a000h demoparty, held in Spiegelberg-Jux (near
;Stuttgart/Germany), January 2002.
;Special thanks to all the people who helped shrinking this code. %-)
;http://www.tap-home.de/
;mailto:mados@tap-home.de

code:
org 0100h
  mov al,03h
  int 10h
  push word 0B800h
  pop ds
  again:
    and bh, 0Fh
    rdtsc			;Read time timestamp counter in edx:eax
    test ax, 1111010111100000b
    jz putchar			;Use random number if it fits the mask
      mov ax, [bx]		;Elsewhere get old character off screen
      and al, 00011111b		;Avoid stupid colors
      jz putchar
        mov [bx + 160], ax	;Put a copy of this character below
        dec ax
    putchar:
    mov [bx], ax
    dec bx
    dec bx
  jnz again
    mov ah, 0Bh
    int 10h			;Wait retrace
    int 10h
    int 21h			;Get stdin status
    cmp al, 00h
  je again			;Break if any key is pressed
  ret

data:
  db 0Dh, 0Ah, "mados/TAP 2002" ;Stupid message to fill 64 bytes
