.model small
.486
.stack 200h
.data
;paramX equ 0
;paramY equ 0
IloscPowtorzen equ 64   ;ilosc kolorow-1
even
pozx dw 0
pozy dw 0
x dw 0
y dw 0
la dd 0
lb dd 0
;kolor db 3

startx dd -618*256
starty dd -324*256
zla dw 768
zlb dw 791
paramx db 0
paramy db 0
even
include c:\jezyk\asembler\source\fpal.txt

.code

zmiana proc near
cmp ah,48h
je zmstarty
cmp ah,50h
je zwstarty
cmp ah,4bh
je zmstartx
cmp ah,4dh
je zwstartx
cmp ah,0dh
je zmlalb
cmp ah,0ch
je zwlalb
cmp ah,39h
je stanpocz
cmp ah,1eh
je zwparamx
cmp ah,2ch
je zmparamx
cmp ah,1fh
je zwparamy
cmp ah,2dh
je zmparamy
xor al,al
jmp nierysuj

zwstarty:
lea di,starty
add dword ptr ds:[di],20*256
jmp wroc

zmstarty:
lea di,starty
sub dword ptr ds:[di],20*256
jmp wroc

zwstartx:
lea di,startx
add dword ptr ds:[di],20*256
jmp wroc

zmstartx:
lea di,startx
sub dword ptr ds:[di],20*256
jmp wroc

zmlalb:
lea di,zla
mov ax,ds:[di]
mov dx,ds:[di+2]
cmp ax,10
jb d1
cmp dx,10
jb d1
sub ax,10
sub dx,10
mov ds:[di],ax
mov ds:[di+2],dx
d1: jmp wroc

zwlalb:
lea di,zla
mov ax,ds:[di]
mov dx,ds:[di+2]
cmp ax,8000
ja d2
cmp dx,8000
ja d2
add ax,10
add dx,10
mov ds:[di],ax
mov ds:[di+2],dx
d2: jmp wroc

stanpocz:
lea di,startx
mov dword ptr ds:[di],(-612*256)
mov dword ptr ds:[di+4],(-324*256)
mov word ptr ds:[di+8],768
mov word ptr ds:[di+10],791
lea di,paramx
mov byte ptr ds:[di],0
mov byte ptr ds:[di+1],0
jmp wroc

zmparamx:
lea di,paramx
sub byte ptr ds:[di],4
jmp wroc

zwparamx:
lea di,paramx
add byte ptr ds:[di],4
jmp wroc

zmparamy:
lea di,paramy
sub byte ptr ds:[di],4
jmp wroc

zwparamy:
lea di,paramy
add byte ptr ds:[di],4


wroc:
mov al,0ffh
nierysuj:
lea di,pozx
mov word ptr ds:[di],0
mov word ptr ds:[di+2],0
ret
zmiana endp

start:
mov ax,@data
mov ds,ax
mov ax,0013h
xor bx,bx
int 10h                 ;tryb 320x200x256

;paleta kolorow
mov ax,seg paleta
mov es,ax
mov ax,1012h
xor bx,bx               ;od koloru 0
mov cx,64              ;ile kolorow do zmiany
lea dx,paleta
int 10h

mov ax,0a000h
mov es,ax               ;w es seg obrazu

;-----------------------liczenie fraktala
rysuj:
lea si,la
lea di,startx
mov eax,ds:[di]
mov [si],eax               ; zmniejszenie - idzemy w prawo
;                                             - rysunek przesuwa sie w lewo
;

nexti:
lea si,lb
lea di,starty
mov eax,ds:[di]
mov [si],eax   ;zmniejszenie - idziemy w dol - rysunek
lea si,pozy                     ;przesuwa sie do gory
mov dword ptr[si],0
;
;

nextj:
xor ax,ax
lea si,x
lea di,paramx
mov al,ds:[di]           ;pobierz paramx
mov word ptr [si],ax     ;ustaw paramx
mov al,ds:[di+1]         ;pobierz paramy
mov word ptr [si+2],ax   ;ustaw paramy
mov cx,IloscPowtorzen
spr:
;push cx
;podnies x do kwadratu
dec cx
jz  br
xor eax,eax
xor ebx,ebx
xor edx,edx
mov ax,[si]                 ;w ax - x
imul ax                     ; |
mov bx,ax                   ; |
mov ax,dx                   ; |
shl eax,16                  ; |
or eax,ebx                  ; V
push eax                    ;x^2 - caly 32bit wynik w eax

;podnies y do kwadratu
xor ebx,ebx
xor edx,edx
xor eax,eax
mov ax,[si+2]               ;w ax - y
imul ax                     ; |
mov bx,ax                   ; |
mov ax,dx                   ; |
shl eax,16                  ; V
or eax,ebx                  ;y^2 - caly 32bit wynik w eax
mov ebx,eax                 ;w ebx - y^2

pop eax                     ;w eax - x^2

sub eax,ebx                 ;x^2-y^2
xor edx,edx
add eax,[si+4]                 ;x^2-y^2+la
shr eax,8               ;-

push eax                    ;zapamietaj x

xor eax,eax
xor ebx,ebx
xor edx,edx
mov ax,[si]                 ;w ax - x
mov bx,[si+2]               ;w bx - y
imul bx                     ;y*x
xor ebx,ebx
mov bx,dx
shl ebx,16
or ebx,eax                  ;y*x - caly wynik z DX:AX w EBX


add ebx,ebx                 ;2*y*x
xor edx,edx
add ebx,[si+8]              ;2*x*y+lb

shr ebx,8       ;-

mov [si+2],bx               ;y=2*x*y+lb
pop eax

mov [si],ax                 ;x=x^2-y^2+la
push ebx                    ;zapamietaj y
;----------------------------podnies x do kwadratu
xor ebx,ebx                 ;najpirw zap. ebx potem wyzeruj
xor edx,edx                 ;potrzebne rejestry
imul ax                     ;x^2 - mnozenie ze znakiem
mov bx,ax                   ;mlodsze slowo do bx (wynik jest w DX:AX)
xor eax,eax                 ;wyzeruj eax
mov ax,dx                   ;
shl eax,16                  ;dx do eax - starsze slowo wyniku
or eax,ebx                  ;bx do ax  - mlodsze slowo wyniku

pop ebx                     ;odtworz y
push eax                    ;zapamieteaj x

xor eax,eax                 ;podnies y do kwadratu
xor edx,edx                 ;
mov eax,ebx                 ;y do eax
imul ax                     ;y^2
xor ebx,ebx
mov bx,ax                   ;mlodsze slowo wyniku do bx
xor eax,eax
mov ax,dx
shl eax,16                  ;dx do eax - starsze slowo wyniku
or eax,ebx                  ;bx do ax  - mlodsze slowo wyniku
mov ebx,eax                 ;caly wynik y^2 do ebx

pop eax                     ;odtworz x
add eax,ebx                 ;|Z|=sqrt(x^2+y^2)


shr eax,8                   ;podziel |Z| przez 256
cmp ax,1024                  ;----------------------------sprawdz warunek
jl spr

;pop cx
;-dec cx
;-jnz spr
;loop spr

br:

;brdalej:
;------
;retu:
lea si,pozx
mov bx,[si]     ;w bx pozx
mov dx,[si+2]   ;w dx pozy
;postaw punkt
shl dx,6
add bx,dx
shl dx,2
add bx,dx
mov es:[bx],cl ;postaw punkt x,y,al - kolor

;nastepna pozycja
lea si,lb
lea di,zlb
xor eax,eax
mov ax,ds:[di]
add dword ptr[si],eax ;-------------zwieksz licznik b
;zy ESC
in al,60h
cmp al,1
je wyjscie
;
lea si,pozy
add word ptr[si],1
cmp word ptr[si],200
jne nextj
lea si,la
lea di,zla
xor eax,eax
mov ax,ds:[di]
add dword ptr[si],eax   ;-------------zwieksz licznik a
lea si,pozx
add word ptr[si],1
cmp word ptr[si],320
jne nexti

;czekaj na klawisz
czekaj:
xor ax,ax
int 16h
cmp ah,10h
je wyjscie
call zmiana
or al,al
jz czekaj
jmp rysuj

;wyjscie z programu
wyjscie:
xor ax,ax
mov al,3
int 10h       ;wlacz tryb tekstowy 80x25x16

mov ax,4c00h
int 21h
end start