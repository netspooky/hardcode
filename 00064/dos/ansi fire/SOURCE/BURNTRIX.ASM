;"ANSI FIRE"
;A 64 byte intro by mados/TAP.
;Done for the 0a000h demoparty, held in Spiegelberg-Jux (near
;Stuttgart/Germany), January 2002.
;Special thanks to MadMan/TAP and T$.
;http://www.tap-home.de/
;mailto:mados@tap-home.de

;%define debug		;Remove semicolon to enable debuging mode

code:
org 0100h

  push word 0B800h
  pop es
  mov bx,Color		;Used in xlatb (safe)
  ;mov bx,Color-1	;Used in xlatb (small)
  ;Color db 04h,4Ch,6Eh

@MainLoop:
  xor di,di		;Target pointer starts at B800:0000h
  mov ch,8		;mov cx,2048; Buffer length
@FireLoop:
  mov al,[es:di]	;Get character
  add al,[es:di+160]	;Get character below
  shr al,1		;div al,2
  jz @KeinDec		;Dont decrement if AL is already zero
  dec ax
@KeinDec:
  stosb			;mov es:[di],al; inc di
  shr al,3
  cmp al,4		;Catch overflow
  jb @LimitOk
  mov al,3
@LimitOk:
  xlatb			;mov al,ds:[bx+al]
  stosb			;mov [es:di],al
  loop @FireLoop

  ;xor dx,dx		;Maybe needed for in al,40h
  mov cl,160		;Base line is 80 characters long
@BaselineLoop:
  in al,40h		;Get timer and use as random number
  ;and al,00111111b	;Works too but looks awful
  ;shr al,2		;Works too but looks awful
  cmp al,76
  ja @ZuGross
  stosb			;mov es:[di],al; inc di
  dec di
@ZuGross:
  inc di
  loop @BaselineLoop

  mov ax,0b00h		;Wait retrace (save)
  ;mov ah,0bh		;Wait retrace (small)
  int 10h		;Registers wont be changed here
  int 10h

%ifdef debug
  mov ah,0Bh		;Get stdin status
  int 21h
  cmp al,00h
  je @MainLoop		;Break if any key is pressed
  mov ah,06h		;Read character from standard input
  int 21h
  ret
%else
  jmp short @MainLoop	;Run forever
%endif

data:
  Color db 02h,0Ah,2Ah,2Fh
