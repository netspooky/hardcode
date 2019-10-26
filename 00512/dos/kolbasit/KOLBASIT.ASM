;       KOLBASIT.ASM
;
;       Author: Glorija
;       Mailto: glorija@nm.ru
;
.model tiny
.code
.386
org 100h

start:

;	Инициализирунг
finit
mov ax,13h
int 10h

m1:

; Зачищаем буфферок...
push ds
pop es
mov di, offset buffer
xor ax,ax 	 
mov cx,320*200/4
rep stosd  ; Порепстосить малёха, отвести душу...

fld t
fld st
fsin
fstp s
fcos
fstp c

mov ax,16
mov c1,ax
mov c0,ax

mov ax,zpr
neg ax
mov z,ax

m2:
mov ax,-100
mov y,ax
mov ax,160
mov x0,ax

; *** Блок искажений (колбасим тор) ***
fild z
fmul td
fld t
fmul k1
fsin
fld t
fmul k2
fcos
fadd
fmul
fsin
fld st
fadd k0
fstp k
fimul x0
fiadd x0
fistp x0 
; ******* Хорошо поколбасили! ********

m3:     ; К 	
fild rk ;  Р
fild y  ;   У
fmul c  ;    Т
fild z  ;     О
fmul s  ;      Й
fsub    ;       
fld st  ;        П
fmul    ;         Р
fsub    ;          О
ftst    ;           Г	
fstsw ax;            Р
fstp u  ;             А
sahf    ;              М 	
jc m11  ;               М
        ;                И
fild z  ;                 Р	
fmul c  ;                  У	
fild y  ;                   Н
fmul s  ;                    Г	
fadd    ;                     .	
fld st  ;                      .	
fmul    ;                       .	
fstp b  ;			
fld u   ;
fsqrt   ;                       Л 
fst u   ;                      Е
        ;                     Н
fild r  ;                    Ь
fmul f2 ;
fadd    ;                  К
fld st  ;                 О
fmul    ;                М
fsub b  ;               М
ftst    ;              Е
fstsw ax;             Н
fstp d1 ;            Т
sahf    ;           И
jc m11  ;          Р
fld d1  ;         О
fsqrt   ;        В
fmul k  ;       А
fistp x1;      Т
        ;     Ь
mov di,y0
add di,y
imul di,320
add di,offset buffer

fild r
fmul f2
fsub u
fld st
fmul
fsub b
ftst
fstsw ax
fstp d2
sahf
jnc m4

mov ax,x1
jmp m5

m4:
fld d2
fsqrt
fmul k
fistp x2
call line

mov ax,x2
neg ax
xchg ax,x1

m5:
neg ax
mov x2,ax
call line

m11:
mov ax,y
inc ax
mov y,ax
cmp ax,100
jle m3

; Разбираемся с цветом
mov ax,c1 
add ax,1
cmp ax,16+30
jl m9
mov ax,16
m9:
mov c1,ax
cmp ax,32
jl m10
neg ax
add ax,62
m10:
mov c0,ax
mov ax,z
add ax,dz
mov z,ax
cmp ax,zpr
jle m2

; Выводим на экран
xor di,di
push 0A000h
pop es
mov si, offset buffer
mov cx,320*200/4
rep movsd

fld t
fadd td
fstp t

; Ожидаем завершения
in al,60h	
dec al
jnz m1        ; Не нажать ли нам ESC ?	
mov ax,3
int 10h
retn	      ; Ну и слава тебе, Господи!

; Рисуем линию
line proc near	      
push di
mov ax,x0
mov cx,ax
add ax,x2
jge m6
xor ax,ax
m6:
add cx,x1
cmp cx,320
jl m7
mov cx,319
m7:
sub cx,ax
jl m8 
add di,ax
mov ax,c0
rep stosb ; Порепстосили, и бросили...	
m8:	
pop di
retn	
line endp

; Всё, кажись! 

; ********************************************************
; А вот для чего были нужны все эти переменные-постоянные:

f2 dd 2.0       ; Соотношение радиусов в торе
r dw 32         ; Малый радиус тора	
rk dw 32*32	; Квадрат малого радиуса
zpr dw 32*3	; Предел изменения координаты z	
dz dw 8     ; Шаг по z
t dd 0.0	; Текущий угол поворота
td dd 0.02	; Изменение угла поворота
x0 dw 160	; Координаты
y0 dw 100   ;            центра 
k0 dd 1.2	; Искажающие коэффициенты
k1 dd 1.37	; для тороидального 
k2 dd 1.83	; вспучивания

k dd ?		; Растяжение по x
s dd ?		; Синус t
c dd ?		; Косинус t
u dd ?          ; Вс
b dd ?          ;   по	
d1 dd ?         ;     мо		
d2 dd ?         ;       га
x1 dw ?         ;         ло	
x2 dw ?         ;           во			
y dw ?		; Текущий y
z dw ?		; Текущий z
c0 dw ?		; Цвет
c1 dw ?		; Счетчик цвета

buffer db 320*200 dup (?) ; Буфферок под картинку

end start 

; *****************  Аминь!  ********************
