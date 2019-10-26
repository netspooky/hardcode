assume cs:code_seg,ds:data_seg
;-
stk_seg  segment stack
         db 512 dup(0)
stk_seg  ends
;---------------
data_seg segment

SymbolSpace db 8 dup(0)
SymbolCou   db 0
String1     db "  AboutScientific Downgrade            "
            db 1
String2     db "  Festival! July 5, 2014.              "
            db 2
String3     db "  Russia, Moscow! Welcome!             "
            db 3
String4     db "  ZX Spectrum, Amiga funs, oldschool demosceners and gamers are glade to see you! We are alive!!! Greetings from: Vasya Pupkin, Wlodek Black and friends!      "
            db 0,0,0
Stringpoi0  dw offset String1
StringPoi   dw offset String1

; Font от Спектрума 'жирный':
Fontbase db 0,0,0,0,0,0,0,0,24,24,24,24,24,0,24,0,0,36,36,0,0,0,0,0,54,54,127,54
 db 127,54,54,0,12,63,104,62,11,126,24,0,96,102,12,24,48,102,6,0,56,108
 db 108,56,109,102,59,0,12,24,48,0,0,0,0,0,12,24,48,48,48,24,12,0,48,24
 db 12,12,12,24,48,0,0,24,126,60,126,24,0,0,0,24,24,126,24,24,0,0,0,0,0
 db 0,0,24,24,48,0,0,0,126,0,0,0,0,0,0,0,0,0,24,24,0,0,6,12,24,48,96,0,0
 db 60,102,110,126,118,102,60,0,24,56,24,24,24,24,126,0,60,102,6,12,24,48
 db 126,0,60,102,6,28,6,102,60,0,12,28,60,108,126,12,12,0,126,96,124,6,6
 db 102,60,0,28,48,96,124,102,102,60,0,126,6,12,24,48,48,48,0,60,102,102
 db 60,102,102,60,0,60,102,102,62,6,12,56,0,0,0,24,24,0,24,24,0,0,0,24,24
 db 0,24,24,48,12,24,48,96,48,24,12,0,0,0,126,0,126,0,0,0,48,24,12,6,12
 db 24,48,0,60,102,12,24,24,0,24,0,60,102,110,106,110,96,60,0,60,102,102
 db 126,102,102,102,0,124,102,102,124,102,102,124,0,60,102,96,96,96,102
 db 60,0,120,108,102,102,102,108,120,0,126,96,96,124,96,96,126,0,126,96
 db 96,124,96,96,96,0,60,102,96,110,102,102,60,0,102,102,102,126,102,102
 db 102,0,126,24,24,24,24,24,126,0,62,12,12,12,12,108,56,0,102,108,120,112
 db 120,108,102,0,96,96,96,96,96,96,126,0,99,119,127,107,107,99,99,0,102
 db 102,118,126,110,102,102,0,60,102,102,102,102,102,60,0,124,102,102,124
 db 96,96,96,0,60,102,102,102,106,108,54,0,124,102,102,124,108,102,102,0
 db 60,102,96,60,6,102,60,0,126,24,24,24,24,24,24,0,102,102,102,102,102
 db 102,60,0,102,102,102,102,102,60,24,0,99,99,107,107,127,119,99,0,102
 db 102,60,24,60,102,102,0,102,102,102,60,24,24,24,0,126,6,12,24,48,96,126
 db 0,124,96,96,96,96,96,124,0,0,96,48,24,12,6,0,0,62,6,6,6,6,6,62,0,24
 db 60,102,66,0,0,0,0,0,0,0,0,0,0,0,255,28,54,48,124,48,48,126,0,0,0,60
 db 6,62,102,62,0,96,96,124,102,102,102,124,0,0,0,60,102,96,102,60,0,6,6
 db 62,102,102,102,62,0,0,0,60,102,126,96,60,0,28,48,48,124,48,48,48,0,0
 db 0,62,102,102,62,6,60,96,96,124,102,102,102,102,0,24,0,56,24,24,24,60
 db 0,24,0,56,24,24,24,24,112,96,96,102,108,120,108,102,0,56,24,24,24,24
 db 24,60,0,0,0,54,127,107,107,99,0,0,0,124,102,102,102,102,0,0,0,60,102
 db 102,102,60,0,0,0,124,102,102,124,96,96,0,0,62,102,102,62,6,7,0,0,108
 db 118,96,96,96,0,0,0,62,96,60,6,124,0,48,48,124,48,48,48,48,0,0,0,102
 db 102,102,102,62,0,0,0,102,102,102,60,24,0,0,0,99,107,107,127,54,0,0,0
 db 102,60,24,60,102,0,0,0,102,102,102,62,6,60,0,0,126,12,24,48,126,0,12
 db 24,24,112,24,24,12,0,24,24,24,0,24,24,24,0,48,24,24,14,24,24,48,0,49
 db 107,70,0,0,0,0,0,60,66,153,161,161,153,66,255
; Для преобразования из спектрумовского файла использовалась
; утилита file2db.exe, написанная Wlodek-ом в 2001 году.
;------------------------------------------------------------------------
; Адреса линий экрана для основного скролла:
line0 equ 59199
line1 equ 59839
line2 equ 60479
line3 equ 61119
line4 equ 61759
line5 equ 62399
line6 equ 63039
line7 equ 63679

; Адреса линий экрана для вывода заголовков:
aline0 equ 59199-51200
aline1 equ 59839-51200
aline2 equ 60479-51200
aline3 equ 61119-51200
aline4 equ 61759-51200
aline5 equ 62399-51200
aline6 equ 63039-51200
aline7 equ 63679-51200

data_seg ends
;-----------------------------------------------------------
code_seg segment
START: mov ax,data_seg
       mov ds,ax; Не забывать!!!

       mov ax,0013h; включаем олдскульный режим 320x200
       int 10h

       mov ax,0A000h; адрес начала видеопамяти в режиме 320x200
       mov es,ax

       cld; направление для movsb в групповых пересылках для скролла
;           справа налево. Действует впредь до изменения. Изначально
;           не определён! Нужно задавать, если предполагается movsb.
;-
       mov ax,offset string1
       mov stringpoi,ax
       mov stringpoi0,ax
       xor al,al
       mov symbolcou,al
;-
main2: call poka_pryam; 'пока прямо' - ждём, пока идёт прямой ход луча
       call scroll; одна продвижка основного скролла

       mov ah,01h; если нужен выход, нажимаем Esc
       int 16h

       jz main1
       jmp to_exit
;-
main1: call poka_obr; 'пока обратный' - пока идёт обратный ход луча.
;                     В x86, в отличие от Спектрума, нет возможности
;                     синхронизировать движения по прерываниям,
;                     поэтому приходится отслеживать ход луча программно.
       jmp main2

to_exit: mov ax,0003h; Не забывать вернуть стандартный экран!
       int 10h

;-
EXIT_ALL:
       mov ax,4c00h; Не забывать!!! Выход должен быть корректным!
       int 21h; ЗАВЕРШЕНИЕ РАБОТЫ ПРОГРАММЫ. Теперь питание компьютера
;               можно... не выключать.
;-------------------------
;-
POKA_PRYAM proc near
         mov dx,3DAh; опрашиваем регистр видеоконтроллера
PRYAM0:  in al,dx
         and al,8
         jz PRYAM0
         ret
POKA_PRYAM endp
;-
POKA_OBR proc near
         mov dx,3DAh
OBR0:    in al,dx
         and al,8
         jnz OBR0
         ret
POKA_OBR endp
;-
POINT proc near
         rol byte ptr [si],1
         mov al,7; это цвет, которым выводится скролл
         jc point1
         xor al,al
point1:  mov es:[bx],al
         ret
POINT    endp
;-
Perebros02: mov ax,0A000h
         mov ds,ax

         push si
         push di

         mov si,line0-318
         mov di,aline0-319+6400
         mov cx,319
         rep movsb
         mov si,line1-318
         mov di,aline1-319+6400
         mov cx,319
         rep movsb
         mov si,line2-318
         mov di,aline2-319+6400
         mov cx,319
         rep movsb
         mov si,line3-318
         mov di,aline3-319+6400
         mov cx,319
         rep movsb
         mov si,line4-318
         mov di,aline4-319+6400
         mov cx,319
         rep movsb
         mov si,line5-318
         mov di,aline5-319+6400
         mov cx,319
         rep movsb
         mov si,line6-318
         mov di,aline6-319+6400
         mov cx,319
         rep movsb
         mov si,line7-318
         mov di,aline7-319+6400
         mov cx,319
         rep movsb
         jmp perebroswyhod
;-
NEXTCHAR proc near
         mov si,stringpoi
         mov al,[si]
         inc si
         or al,al
         jz nextchr3
         cmp al,1
         jz perebros01
         cmp al,2
         jz perebros02
         cmp al,3
         jz perebros03
         jmp nextchr1
;------------------------------
nextchr3: mov si,offset string4
         mov al,[si]
nextchr1: mov stringpoi,si
         mov ah,0
         add ax,ax
         add ax,ax
         add ax,ax
         add ax,offset fontbase-256
         mov si,ax
         mov di,offset symbolspace
         mov cx,8
nextchr2: mov al,[si]
         mov [di],al
         inc si
         inc di
         loop nextchr2

         mov symbolcou,8

         ret
NEXTCHAR endp
;-
Perebros03: mov ax,0A000h
         mov ds,ax

         push si
         push di
         jmp perebros03a
;-
Perebros01: mov ax,0A000h
         mov ds,ax

         push si
         push di

         mov si,line0-318
         mov di,aline0-319
         mov cx,319
         rep movsb
         mov si,line1-318
         mov di,aline1-319
         mov cx,319
         rep movsb
         mov si,line2-318
         mov di,aline2-319
         mov cx,319
         rep movsb
         mov si,line3-318
         mov di,aline3-319
         mov cx,319
         rep movsb
         mov si,line4-318
         mov di,aline4-319
         mov cx,319
         rep movsb
         mov si,line5-318
         mov di,aline5-319
         mov cx,319
         rep movsb
         mov si,line6-318
         mov di,aline6-319
         mov cx,319
         rep movsb
         mov si,line7-318
         mov di,aline7-319
         mov cx,319
         rep movsb
         jmp perebroswyhod
;-
perebros03a: mov si,line0-318
         mov di,aline0-319+12800
         mov cx,319
         rep movsb
         mov si,line1-318
         mov di,aline1-319+12800
         mov cx,319
         rep movsb
         mov si,line2-318
         mov di,aline2-319+12800
         mov cx,319
         rep movsb
         mov si,line3-318
         mov di,aline3-319+12800
         mov cx,319
         rep movsb
         mov si,line4-318
         mov di,aline4-319+12800
         mov cx,319
         rep movsb
         mov si,line5-318
         mov di,aline5-319+12800
         mov cx,319
         rep movsb
         mov si,line6-318
         mov di,aline6-319+12800
         mov cx,319
         rep movsb
         mov si,line7-318
         mov di,aline7-319+12800
         mov cx,319
         rep movsb
;-
Perebroswyhod: mov ax,data_seg
         mov ds,ax
         mov si,stringpoi
         mov stringpoi0,si
         pop di
         pop si
         mov al,32
         jmp nextchr1
;---------------------------------
SCROLL   proc near
         mov ax,0A000h
         mov ds,ax

         mov si,line0-318
         mov di,line0-319
         mov cx,319
         rep movsb
         mov si,line1-318
         mov di,line1-319
         mov cx,319
         rep movsb
         mov si,line2-318
         mov di,line2-319
         mov cx,319
         rep movsb
         mov si,line3-318
         mov di,line3-319
         mov cx,319
         rep movsb
         mov si,line4-318
         mov di,line4-319
         mov cx,319
         rep movsb
         mov si,line5-318
         mov di,line5-319
         mov cx,319
         rep movsb
         mov si,line6-318
         mov di,line6-319
         mov cx,319
         rep movsb
         mov si,line7-318
         mov di,line7-319
         mov cx,319
         rep movsb

         mov ax,data_seg
         mov ds,ax

         mov al,symbolcou
         or al,al
         jnz scroll1
         call nextchar
scroll1: dec symbolcou
         mov si,offset symbolspace

         mov bx,line0
         call point
         inc si
         mov bx,line1
         call point
         inc si
         mov bx,line2
         call point
         inc si
         mov bx,line3
         call point
         inc si
         mov bx,line4
         call point
         inc si
         mov bx,line5
         call point
         inc si
         mov bx,line6
         call point
         inc si
         mov bx,line7
         call point

         ret
SCROLL   endp
;-
code_seg ends
;-----------------
         end start
