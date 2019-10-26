
;edi = dest, al=digit
writedigit proc
    cbw
    cwde
   imul eax, 25
    lea esi, [eax+@font]
    mov cl, 5
    @yloopf:
       mov ch, 5
       @xloopf:
           lodsb
	test al, al
;           cmp al, 0
           jz @nopixel
              mov eax, 0ffffffh
              mov [edi], eax
           @nopixel:
           add edi, 4
       dec ch
       jnz @xloopf
       add edi, (320-5)*4
    loop @yloopf
ret
writedigit endp

;eax = nr, edi = dest
writenumber proc
     @nextdig:
     xor edx, edx
     mov ebx, 10
    idiv ebx
     pushad
        mov eax, edx
        call writedigit
     popad
     sub edi, 6*4
     cmp eax, 0
     jnz @nextdig
ret
writenumber endp

@font:
db 0,1,1,1,0
db 1,0,0,0,1
db 1,0,0,0,1
db 1,0,0,0,1
db 0,1,1,1,0

db 0,0,1,0,0
db 0,1,1,0,0
db 0,0,1,0,0
db 0,0,1,0,0
db 0,0,1,0,0

db 0,1,1,1,0
db 1,0,0,0,1
db 0,0,1,1,0
db 0,0,1,0,0
db 0,1,1,1,1

db 0,1,1,1,0
db 1,0,0,0,1
db 0,0,1,1,0
db 1,0,0,0,1
db 0,1,1,1,0

db 1,0,0,0,1
db 1,0,0,0,1
db 0,1,1,1,1
db 0,0,0,0,1
db 0,0,0,0,1

db 1,1,1,1,1
db 1,0,0,0,0
db 1,1,1,1,0
db 0,0,0,0,1
db 0,1,1,1,0

db 0,1,1,1,0
db 1,0,0,0,0
db 1,1,1,1,0
db 1,0,0,0,1
db 0,1,1,1,0

db 1,1,1,1,1
db 0,0,0,1,0
db 0,0,1,0,0
db 0,1,0,0,0
db 1,0,0,0,0

db 0,1,1,1,0
db 1,0,0,0,1
db 0,1,1,1,0
db 1,0,0,0,1
db 0,1,1,1,0

db 0,1,1,1,0
db 1,0,0,0,1
db 0,1,1,1,1
db 0,0,0,0,1
db 0,1,1,1,0

