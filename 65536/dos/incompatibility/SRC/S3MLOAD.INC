;
;S3M player interface v0.0
;

inits3mplay:
;
;BX = gusaddress (pl. 220h)
;
call initsoundcard      ;sets baseaddress
push ds es
mov ax,music
mov ds,ax
mov ax,9000h-400h
mov es,ax
xor si,si
xor di,di
assume ds:music
mov cx,offset musend
assume ds:data1
rep movsb
push cs
pop ds
mov ax,music
mov es,ax
mov si,offset reals3mloader
call setmodule
pop es ds
retn

reals3mloader:
push ds
pusha
mov si,9000h-400h
mov ds,si
mov si,ax
rep movsb
popa
pop ds
retf