;"ANSI FIRE"
;A 64 byte intro by mados/TAP.
;Done for the 0a000h demoparty, held in Spiegelberg-Jux (near
;Stuttgart/Germany), January 2002.
;Based on an idea by MadMan/TAP. Also thanks to T$.
;http://www.tap-home.de/
;mailto:mados@tap-home.de

;%define debug		;Remove semicolon to enable debuging mode
%define cwood 100	; 63 / 100 / 127
%define cbaseline 118	;120 / 118 / 115

code:
org 0100h

  ;mov bx, Color	;Used in xlatb (safe)
  mov bx, Color - 1	;Used in xlatb (smaller)
  Color db 04h, 4Ch, 6Eh
  push word 0B800h
  pop es

@MainLoop:
  ;xor di, di		;Reset pointer for use in [es:di]

  mov ch, 256/2		;70 Hz/2 = 35 frames per second
@FireLoop:
  mov al, [es:di]	;Get character
  add al, [es:di + 162]
  shr al, 1
  add al, [es:di + 160]	;Get character below
  shr al, 1		;Divide
  jz @KeinDec		;Dont decrement if AL is already zero
  dec ax
@KeinDec:

  cmp ch, cbaseline
  jne @NoBaseline
  in al, 40h		;Get timer and use as random number
  ;rdtsc
  cmp al, cwood
  ja @Skip
@NoBaseline:
  stosb			;mov es:[di],al; inc di
  dec di
@Skip:
  inc di

  shr al, 3
  cmp al, 4		;Catch overflow
  jb @LimitOk
  mov ax, 0B03h		;mov al,3
@LimitOk:
  xlatb			;mov al,[ds:bx+al]
  stosb			;mov [es:di],al
  loop @FireLoop

  ;mov ah, 0Bh		;Wait retrace
  int 10h

%ifdef debug
  mov ah, 0Bh		;Get stdin status
  int 21h
  cmp al, 00h
  je @MainLoop		;Break if any key is pressed
  mov ah, 06h		;Read character from standard input
  int 21h
  ret
%else
  jmp short @MainLoop	;Run forever
%endif

data:
  ;Color db 01h, 04h, 4Ch, 6Eh
