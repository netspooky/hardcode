;------------------------------------;
;"Starway 128" intro by Tyler Durden ;
;Compiled with Fasm v.1.54           ;
;------------------------------------;
;website: www.tylerdurden.net.ru     ;
;email: starway@tylerdurden.net.ru   ;
;------------------------------------;
org 100h
mov al,13h
int 10h
mov ch,2h
mov di,64000
rep stosw
push 0a000h
pop es
.wait:
xor di,di
mov ch,0fah
salc
rep stosb
mov si,di
mov cl,stars_count
.stars_draw:
dec byte [si+4]
mov ax,[si+2]
call convert
add ax,100
add ax,[si]
mov bx,320
cmp ax,200
jbe .y_ok
call star_gen
.y_ok:
mul bx
xchg ax,di
mov ax,[si]
call convert
add ax,160
cmp ax,bx
jbe .x_ok
call star_gen
.x_ok:
add di,ax
lodsw
lodsw
lodsw
shr al,4
neg al
add al,31
stosb
loop .stars_draw
jmp .wait
random:
xor dx,dx
xchg ax,bp
xlatb
add ax,cx
mov bp,ax
div bx
retn
convert:
cwd
xchg al,ah
idiv word [si+4]
retn
star_gen:
call random
sub dx,160
mov [si],dx
call random
sub dx,100
mov [si+2],dx
mov byte [si+4],0ffh
retn
stars_count=255