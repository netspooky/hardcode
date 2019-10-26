;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; "BURN" intro klubu SGA                                                    º
; autor: Lukasz Sterkowicz vel Gutz                                         º
;        gutz@mops.uci.agh.edu.pl                                           º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
; Oto kod zrodowy intra BURN. Pokazuje technike tworzenia realistycznego    º
; ognia, skalowanie, nakladanie tekstury itp.                               º
;                                                                           º
; Wszystkie czesci programu moga byc uzyte bezplatnie. Autor nie ponosi     º
; odpowiedzialnosci za szkody wynikle ze zlego funkcjonowania programu.     º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

%include 'header.inc'

CR            equ 13
NL            equ 10
STACK_SIZE    equ 1024

;ÄÄÄÄÄÄÄÄÄÄÄÄ dlugosc kolejki liter
QUEUE_L       equ 50
;ÄÄÄÄÄÄÄÄÄÄÄÄ maksymalne lewe wychylenie
LEFT_SP       equ -80
;ÄÄÄÄÄÄÄÄÄÄÄÄ maksymalne prawe wychylenie
RIGHT_SP      equ 320 - LEFT_SP
;ÄÄÄÄÄÄÄÄÄÄÄÄ odleglosc od obserwatora (w potegach dwojki)
OBSERVER      equ 9

START_PROGRAM


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; segment kodu                                                              º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
  section .text                                                           ; º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; przygotowanie pamieci                                                     ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ przygotowanie segmentu danych
              cld
              mov ax,cs
              add ax,TEXT_SIZE / 16
              mov ds,ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ zmniejszenie przydzielonej pamieci
              mov bx,es
              add bx,(0x200 + TEXT_SIZE + DATA_SIZE + BSS_SIZE + STACK_SIZE) / 16
              mov ah,0x4A
              int 0x21
;ÄÄÄÄÄÄÄÄÄÄÄÄ przydzielenie dodatkowej pamieci
              mov bx,0x2500
              mov ah,0x48
              int 0x21
              jnc short mem_ok
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyswietlenie bledu
              mov dx,no_mem
              mov ah,9
              int 0x21
              mov ax,0x4C01
              int 0x21
;ÄÄÄÄÄÄÄÄÄÄÄÄ przygotowanie segmentu masek
mem_ok:       mov fs,ax
              add ax,320 * (67 * 2 + 132) / 16
              mov gs,ax
              mov es,ax
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; rozpakowanie masek bitowych                                               ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ rozpakowanie napisu SGA
              mov si,sga_mask
              xor di,di
              mov bp,260
              mov bh,40
              call unpack
;ÄÄÄÄÄÄÄÄÄÄÄÄ rozpakowanie kolejnych liter
              mov bx,let_width
let_1:        movzx bp,byte [bx]
              or bp,bp
              je short add_space
              push bx
              mov bh,38
              call unpack
              pop bx
              inc bx
              jmp short let_1
;ÄÄÄÄÄÄÄÄÄÄÄÄ dodanie spacji
add_space:    mov byte [bx],50
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; zapisanie adresow buforow                                                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              mov ax,fs
              mov [buf1],ax
              add ax,320 * 67 * 2 / 16
              mov [buf2],ax
              push ds
              pop es
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; przygotowanie tekstu do wyswietlania                                      ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ konwersja tekstu scrollowanego
prep_text:    mov si,scroll
conv_1:       lodsb
              cmp al,-1
              je short pointers
              mov di,let_def
              mov cx,let_def - let_width
              repne scasb
              sub di,let_def + 1
              mov ax,di
              mov [si - 1],al
              jmp short conv_1
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyznaczenie wskaznikow do liter
pointers:     mov si,let_width
              mov di,let_point
              mov cx,let_def - let_width - 1
              mov bl,38
              xor ax,ax
              mov dx,40 * 260
              jmp short pointers_2
pointers_1:   lodsb
              mul bl
pointers_2:   add ax,dx
              mov dx,ax
              stosw
              loop pointers_1
              mov ax,-1
              stosw
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyzerowanie kolejki
              mov di,queue_p
              mov cx,QUEUE_L + 1
              rep stosw
;ÄÄÄÄÄÄÄÄÄÄÄÄ pierwsza litera (spacja)
              mov word [queue_x + QUEUE_L],RIGHT_SP
              mov word [queue_w + QUEUE_L],50
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; wygenerowanie funkcji sinus                                               ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              mov si,sinus + 255
              lea di,[si + 1]
;ÄÄÄÄÄÄÄÄÄÄÄÄ uzupelnienie sinusa do pi
              mov cx,256
sinus_1:      std
              lodsb
              cld
              stosb
              loop sinus_1
              inc si
;ÄÄÄÄÄÄÄÄÄÄÄÄ uzupelnienie sinusa do 2*pi
              mov cx,512
sinus_2:      lodsb
              not al
              stosb
              loop sinus_2
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; wygenerowanie gruntu                                                      ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              mov si,sinus
              mov di,ground
              xor dx,dx
              mov cx,320
ground_1:     xor ax,ax
              mov bx,cx
;ÄÄÄÄÄÄÄÄÄÄÄÄ pierwsza funkcja harmoniczna [ sin(4x) ]
              shl bx,2
              and bh,3
              mov al,[si + bx]
;ÄÄÄÄÄÄÄÄÄÄÄÄ druga funkcja harmoniczna [ sin(8x) ]
              shl bx,1
              and bh,3
              add al,[si + bx]
              adc ah,dl
              shr ax,1
              stosb
              dec cx
              jne short ground_1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; wygenerowanie palety ognia                                                ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              mov di,fire_pal
              xor cx,cx
make_pal:     mov ax,cx
              or al,al
              je short write_color
              cmp al,0xC0
              jae short write_color
              dec ax
              je short write_color
              cmp al,0x80
              jae short write_color
              sub al,2
              jbe short black
              cmp al,0x40
              jae short write_color
              sub al,5
              jae short write_color
black:        xor al,al
write_color:  stosb
              inc cl
              jne short make_pal
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; inicjacja trybu graficznego                                               ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ wlaczenie trybu
              mov ax,0x13
              int 0x10
;ÄÄÄÄÄÄÄÄÄÄÄÄ przygotowanie karty do zapisu palety
              mov dx,0x3C8
              xor al,al
              out dx,al
              inc dx
;ÄÄÄÄÄÄÄÄÄÄÄÄ ustawienie kolorow ognia
              mov si,fire_pal
              mov cx,64
palette_1:    movzx ax,[si]
              cmp al,0x80
              jbe short palette_1a
              mov ah,al
              add ah,al
palette_1a:   shr al,2
              out dx,al
              mov al,ah
              shr al,2
              out dx,al
              xor al,al
              out dx,al
              add si,4
              dec cx
              jne palette_1
;ÄÄÄÄÄÄÄÄÄÄÄÄ ustawienie kolorow tekstury
              mov si,txt_pal
              mov cx,60
palette_2:    lodsb
              shr al,2
              out dx,al
              lodsb
              shr al,2
              out dx,al
              lodsb
              shr al,2
              out dx,al
              dec cx
              jne palette_2
;ÄÄÄÄÄÄÄÄÄÄÄÄ ustawienie kolorow duzych gwiazd
              mov cx,4
              mov ah,0x2F
palette_3:    mov al,ah
              out dx,al
              out dx,al
              mov al,0x3F
              out dx,al
              add ah,4
              dec cx
              jne palette_3
;ÄÄÄÄÄÄÄÄÄÄÄÄ ustawienie kolorow odbicia ognia
              mov si,fire_pal
              mov cx,64
palette_4:    movzx ax,[si]
              cmp al,0x80
              jbe short palette_4a
              mov ah,al
              add ah,al
palette_4a:   shr al,3
              out dx,al
              mov al,ah
              shr al,3
              out dx,al
              xor al,al
              out dx,al
              add si,4
              dec cx
              jne palette_4
;ÄÄÄÄÄÄÄÄÄÄÄÄ ustawienie kolorow odbicia tekstury
              mov si,txt_pal
              mov cx,60
palette_5:    lodsb
              shr al,3
              out dx,al
              lodsb
              shr al,3
              out dx,al
              lodsb
              shr al,3
              out dx,al
              dec cx
              jne palette_5
;ÄÄÄÄÄÄÄÄÄÄÄÄ ustawienie kolorow malych gwiazd
              mov cx,4
              mov ah,0x17
palette_6:    mov al,ah
              out dx,al
              out dx,al
              mov al,0x1F
              out dx,al
              add ah,2
              dec cx
              jne palette_6
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; wyrysowanie duzych gwiazd                                                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyczyszczenie bufora
              push fs
              pop es
              xor di,di
              mov cx,320 * 68 / 4
              xor eax,eax
              rep stosd
;ÄÄÄÄÄÄÄÄÄÄÄÄ losowanie pozycji
              mov ax,[seed]
              mov bp,8903
              mov cx,45
big_stars:    mul bp
              inc ax
              push ax
              xor dx,dx
              mov bx,3
              div bx
              mov di,ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ losowanie koloru
              pop ax
              mul bp
              inc ax
              push ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyrysowanie gwiazdy
              shr ax,14
              or al,0x7C
              mov [es:di],al
              or al,0x80
              mov [es:di - 320],al
              mov [es:di + 320],al
              mov [es:di - 1],al
              mov [es:di + 1],al
              pop ax
              dec cx
              jne near big_stars
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; wyrysowanie malych gwiazd                                                 ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ losowanie pozycji
              mov cx,70
small_stars:  mul bp
              inc ax
              push ax
              xor dx,dx
              mov bx,3
              div bx
              mov di,ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ losowanie koloru
              pop ax
              mul bp
              inc ax
              push ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyrysowanie gwiazdy
              shr ax,14
              or al,0xFC
              stosb
              pop ax
              dec cx
              jne short small_stars
              mov [seed],ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ zapisanie bufora na ekran
              push word 0xA000
              pop es
              mov cx,320 * 68 / 4
              xor si,si
              xor di,di
              fs rep movsd
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyczyszczenie bufora
              push fs
              pop es
              xor di,di
              mov cx,320 * 67 * 2 / 4
              xor eax,eax
              rep stosd
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; przygotowanie systemu odmierzania czau                                    ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ podmiana procedury obslugi przerwania zegarowego
              push word 0
              pop es
              mov ax,cs
              shl eax,16
              mov ax,int8
              xchg eax,[es:8 * 4]
              mov [old_int8],eax
;ÄÄÄÄÄÄÄÄÄÄÄÄ zaprogramowanie ukladu odmierzania czasu
              mov al,110100b
              out 43h,al
              xor ax,ax
              out 40h,al
              mov al,0x20
              out 40h,al


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; wygenerowanie podstawy ognia                                              ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
main_loop:    mov es,[buf1]
              mov di,320 * 2 * 66
              mov cx,320 / 8
              mov ax,[seed]
              mov bp,8903
;ÄÄÄÄÄÄÄÄÄÄÄÄ wylosowanie koloru
bottom:       push cx
              mul bp
              inc ax
              push ax
              or ah,0x80
              shr ax,8
;ÄÄÄÄÄÄÄÄÄÄÄÄ zapisanie na 8 punktach
              mov cx,8
              rep stosw
              pop ax
              pop cx
              dec cx
              jne short bottom
              mov [seed],ax
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; rysowanie plomieni                                                        ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              mov di,2
              mov cx,66
flame:        push cx
              mov cx,318
;ÄÄÄÄÄÄÄÄÄÄÄÄ obliczenie sredniej z czterech punktow
line:         mov bx,[es:di]
              add bx,[es:di + 319 * 2]
              add bx,[es:di + 320 * 2]
              add bx,[es:di + 321 * 2]
              shr bx,2
              movzx ax,byte [fire_pal + bx]
;ÄÄÄÄÄÄÄÄÄÄÄÄ zapisanie koloru
              stosw
              dec cx
              jne short line
              add di,4
              pop cx
              dec cx
              jne short flame
;ÄÄÄÄÄÄÄÄÄÄÄÄ skopiowanie czesci plomieni do bufora roboczego
              mov fs,[buf1]
              mov es,[buf2]
              xor si,si
              xor di,di
              mov cx,320 * 56
copy_flame:   fs lodsw
              shr al,2
              stosb
              dec cx
              jne short copy_flame
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; rysowanie gruntu                                                          ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ porownanie ze wzorcem gruntu
              mov dl,-1
make_grnd:    mov bx,320
line_grnd:    cmp byte [ground + bx - 1],dl
              jb short not_grnd
              add si,2
              xor ax,ax
              jmp short check_grnd
;ÄÄÄÄÄÄÄÄÄÄÄÄ jezeli nie grunt skopiowanie plomieni
not_grnd:     fs lodsw
              shr al,2
check_grnd:   stosb
              dec bx
              jne short line_grnd
              sub dl,32
              ja short make_grnd
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; rysowanie tekstu                                                          ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              xor bx,bx
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyswietlanie od zewnatrz do srodka
one_letter:   push bx
              cmp bx,QUEUE_L
              jb short take_pointer
              neg bx
              add bx,QUEUE_L * 3
;ÄÄÄÄÄÄÄÄÄÄÄÄ pobranie wskaznika maski litery
take_pointer: movzx esi,word [queue_p + bx]
              inc si
              je near next_letter
              dec si
;ÄÄÄÄÄÄÄÄÄÄÄÄ pobranie dlugosci litery i wspolrzednej x
              movzx ax,[queue_w + bx]
              mov [width],ax
              mov [right],ax
              movsx ebx,word [queue_x + bx]
              push ebx
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyznaczenie wskaznika do tekstury
              mov di,texture + 56 / 2
              shr ax,1
              sub di,ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyznaczenie pozycji na fali
              add bx,ax
              shl bx,2
              add bx,[sin_add]
              and bx,0x3FF
              movzx eax,byte [sinus + bx]
              push ax
              not al
              shr al,1
              mov [wave_pos],al
              pop ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ obliczenie wspolczynnika pomniejszenia
              add ax,1 << OBSERVER
              mov ebx,eax
              shl eax,16 - OBSERVER
              mov [scale],eax
;ÄÄÄÄÄÄÄÄÄÄÄÄ obliczenie odchylenia w pionie
              mov ax,(1 << OBSERVER) * 38 / 2
              cwd
              div bx
              neg ax
              add ax,(38 / 2) + 14
              shl ax,6
              mov bp,ax
              shl ax,2
              add bp,ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ obliczenie odchylenia w poziomie
              pop eax
              sub eax,320 / 2
              shl eax,OBSERVER
              cdq
              idiv ebx
              add ax,320 / 2
              mov cx,[width]
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie czy liera wystaje na lewo
              cmp ax,0
              jg short check_right
              neg ax
              cmp ax,cx
              jae near next_letter
              jmp short save_left
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie czy liera wystaje na prawo
check_right:  cmp ax,320
              jae near next_letter
              add bp,ax
              mov bx,ax
              add bx,cx
              xor ax,ax
              sub bx,319
              jb short save_left
              sub cx,bx
              mov [right],cx
save_left:    mov [left],ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ zapisanie poczatku litery i tekstury
              xor ecx,ecx
              mov [let_start],si
              mov [txt_start],di
one_line:     xor ebx,ebx
              push bp
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie czy punkt miesci sie na ekranie
one_pixel:    cmp bx,[left]
              jb short next_pixel
              cmp bx,[right]
              ja short next_pixel
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie maski litery
              mov al,[gs:si + bx]
              inc al
              je short empty
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie czy ogien przeslania punkt
              mov al,[es:bp]
              cmp al,0x40
              jae short not_empty
              cmp al,0x20
              jbe short not_empty
              shl al,3
              cmp al,[wave_pos]
              ja short empty
;ÄÄÄÄÄÄÄÄÄÄÄÄ przepisanie punktu z tekstury
not_empty:    mov al,[di + bx]
              or al,0x40
              mov [es:bp],al
;ÄÄÄÄÄÄÄÄÄÄÄÄ skalowanie w poziomie
empty:        inc bp
next_pixel:   ror ebx,16
              add ebx,[scale]
              ror ebx,16
              cmp bx,[width]
              jb short one_pixel
;ÄÄÄÄÄÄÄÄÄÄÄÄ skalowanie w pionie
              mov si,[let_start]
              mov di,[txt_start]
              ror ecx,16
              add ecx,[scale]
              ror ecx,16
              mov ax,cx
              push ax
              mul word [width]
              add si,ax
              pop ax
              shl ax,3
              mov dx,ax
              shl ax,3
              sub ax,dx
              add di,ax
;ÄÄÄÄÄÄÄÄÄÄÄÄ przejscie do kolejnej lini
              pop bp
              add bp,320
              cmp cx,38
              jb near one_line
;ÄÄÄÄÄÄÄÄÄÄÄÄ przejscie do kolejnej litery
next_letter:  pop bx
              add bx,2
              cmp bx,QUEUE_L * 2
              jna near one_letter
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; rysowanie wody                                                            ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ skopiowanie plomieni w lustrzanym odbiciu
              mov si,320 * 58
              mov di,320 * 64
mirror_1:     mov cx,320 / 4
mirror_2:     es lodsd
;ÄÄÄÄÄÄÄÄÄÄÄÄ wyblakly kolor
              or eax,0x80808080
;ÄÄÄÄÄÄÄÄÄÄÄÄ zapisanie czterech pikseli
              stosd
              dec cx
              jne short mirror_2
              sub si,320 * 2
              jae short mirror_1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; rysowanie napisu SGA                                                      ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              xor si,si
              mov di,320 * 74 + 30
              mov bp,40
SGA_1:        mov cx,260 / 4
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie maski i wyzerowanie punktu jezeli napis
SGA_2:        gs lodsd
              and [es:di],eax
              add di,4
              dec cx
              jne short SGA_2
              add di,60
              dec bp
              jne short SGA_1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; przesuwanie tekstu                                                        ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              push ds
              pop es
;ÄÄÄÄÄÄÄÄÄÄÄÄ przesuniecie fali
              add word [sin_add],10
              and word [sin_add],0x3FF
;ÄÄÄÄÄÄÄÄÄÄÄÄ przesuniecie liter o jeden piksel w lewo
              mov si,[first]
              push si
turn_left:    dec word [queue_x + si]
              add si,2
              cmp si,[last]
              jna short turn_left
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie czy pobrac nowa litere
              mov ax,[queue_x + si - 2]
              add ax,[queue_w + si - 2]
              cmp ax,RIGHT_SP
              jg short check_lt
;ÄÄÄÄÄÄÄÄÄÄÄÄ pobranie indeksu litery
              mov bx,[char_no]
take_char:    movsx di,byte [scroll + bx]
              inc bx
              inc di
              jne short save_pos
              xor bx,bx
              jmp short take_char
save_pos:     mov [char_no],bx
              dec di
;ÄÄÄÄÄÄÄÄÄÄÄÄ pobranie wlasciwosci litery
              movzx ax,byte [let_width + di]
              mov [queue_w + si],ax
              shl di,1
              mov ax,[let_point + di]
              mov [queue_p + si],ax
              mov word [queue_x + si],RIGHT_SP
              add word [last],2
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie czy wyrzucic litere
check_lt:     pop si
              mov ax,[queue_x + si]
              add ax,[queue_w + si]
              add ax,-LEFT_SP
              jg short check_sft
              mov word [queue_p + si],-1
              add word [first],2
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie czy przesunac kolejke
check_sft:    cmp word [queue_x + QUEUE_L],320 / 2
              ja short to_screen
;ÄÄÄÄÄÄÄÄÄÄÄÄ przesuniecie kolejki
              mov cx,QUEUE_L
              push cx
              push cx
              mov si,queue_p + 2
              mov di,queue_p
              rep movsw
              pop cx
              mov si,queue_x + 2
              mov di,queue_x
              rep movsw
              pop cx
              mov si,queue_w + 2
              mov di,queue_w
              rep movsw
              sub word [first],2
              sub word [last],2
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; zamkniecie glownej petli                                                  ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ zapisanie obrazu do pamieci karty
to_screen:    mov fs,[buf2]
              push word 0xA000
              pop es
              xor si,si
              mov di,320 * 68
              mov cx,320 * 64 / 4
              fs rep movsd
              add di,320 * 8
              mov cx,320 * 58 / 4
              fs rep movsd
;ÄÄÄÄÄÄÄÄÄÄÄÄ sprawdzenie czy wcisniety klawisz
check_key:    mov ah,01h
              int 16h
              jne short exit
;ÄÄÄÄÄÄÄÄÄÄÄÄ oczekiwanie na przerwanie zegara
              cmp byte [allow],1
              jne short check_key
              mov byte [allow],0
              jmp main_loop


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; posprzatanie po sobie i wyjscie                                           ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ pobranie klawisza
exit:         xor ah,ah
              int 16h
;ÄÄÄÄÄÄÄÄÄÄÄÄ zaprogramowanie ukladu odmierzania czasu
              mov al,110100b
              out 43h,al
              mov al,-1
              out 40h,al
              out 40h,al
;ÄÄÄÄÄÄÄÄÄÄÄÄ przywrocenie starej procedury zegara
              push word 0
              pop es
              mov eax,[old_int8]
              mov [es:8 * 4],eax
;ÄÄÄÄÄÄÄÄÄÄÄÄ ustawienie trybu tekstowego i wypisanie informacji
exit_1:       mov ax,3
              int 0x10
              mov dx,end_text
              mov ah,9
              int 0x21
;ÄÄÄÄÄÄÄÄÄÄÄÄ opuszczenie proramu
              mov ax,0x4C00
              int 0x21
;             ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> DOS


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; procedura obslugi przerwania zegarowego (0x8)                             ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÄÄÄÄÄÄÄÄÄÄÄÄ zezwolenie na wykonanie petli
int8:         mov byte [cs:TEXT_SIZE + allow],1
;ÄÄÄÄÄÄÄÄÄÄÄÄ wywolanie starej procedury co osiem razy
              inc byte [cs:TEXT_SIZE + counter]
              test byte [cs:TEXT_SIZE + counter],7
              jne short send_EOI
              jmp far [cs:TEXT_SIZE + old_int8]
;ÄÄÄÄÄÄÄÄÄÄÄÄ sygnal EOI
send_EOI:     push ax
              mov al,0x20
              out 0x20,al
              pop ax
              iret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; procedura rozpakowujaca maske bitowa                                      ³
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
unpack:       mov dx,bp
;ÄÄÄÄÄÄÄÄÄÄÄÄ zamiana pojedynczego bitu na bajt
unpack_1:     lodsb
              mov bl,al
              mov cx,8
unpack_2:     xor al,al
              rcl bl,1
              adc al,-1
              stosb
              dec cx
              dec dx
              je short unpack_3
              jcxz unpack_1
              jmp short unpack_2
unpack_3:     dec bh
              jne short unpack
              ret


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; segment danych                                                            º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
  section .data                                                           ; º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

;ÄÄÄÄÄÄÄÄÄÄÄÄ komunikaty
no_mem:       db 'Za malo dostepnej pamieci',CR,NL,'$'
end_text:     db 'BURN -+- intro klubu SGA -+- kod Gutz 1999',CR,NL,CR,NL
              db 'SGA ÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',CR,NL
              db '      ³ http://sga.koti.com.pl           ³',CR,NL
              db '      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',CR,NL
              db 'Gutz ÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿',CR,NL
              db '      ³ gutz@mops.uci.agh.edu.pl         ³',CR,NL
              db '      ³ http://mops.uci.agh.edu.pl/~gutz ³',CR,NL
              db '      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ',CR,NL,'$'
;ÄÄÄÄÄÄÄÄÄÄÄÄ tekst scrollowany
scroll:       db '   KLUB SGA PRZEDSTAWIA INTRO         =BURN=         '
              db 'SUPEROWA GRUPA ASMOWA ZRZESZA MIlOsNIKoW ASEMBLERA. '
              db 'ZAPRASZAMY DO UCZESTNICTWA POCZaTKUJaCYCH I ZAAWANSOWANYCH '
              db 'W CELU WYMIANY POGLaDoW I DOsWIADCZEn ORAZ POMOCY. WIeCEJ '
              db 'INFORMACJI ZNAJDZIESZ NA STRONIE KLUBU.         KOD GUTZ.  '
              db 'POZDROWIENIA DLA WSZYSTKICH KLUBOWICZoW ORAZ  QUO  '
              db 'GRAZBUHER  POP  DICKTA  GHAD  ZGRED  STAWROGIN  RUFF  '
              db 'BATT  BORG  I TYCH KToRYCH PRZEZ PRZYPADEK POMINalEM. '
              db '          ',-1
;ÄÄÄÄÄÄÄÄÄÄÄÄ seed generatora liczb losowych
seed:         dw 0x575
;ÄÄÄÄÄÄÄÄÄÄÄÄ przesuniecie funkcji sinus
sin_add:      dw 30
;ÄÄÄÄÄÄÄÄÄÄÄÄ numer pobieranego znaku
char_no:      dw 0
;ÄÄÄÄÄÄÄÄÄÄÄÄ zezwolenie na ponowne wykonanie petli glownej
allow:        db 0
;ÄÄÄÄÄÄÄÄÄÄÄÄ pierwszy i ostatni znak kolejki
first:        dw QUEUE_L
last:         dw QUEUE_L
;ÄÄÄÄÄÄÄÄÄÄÄÄ licznik procedury przerwania zegarowego
counter:      db 0
;ÄÄÄÄÄÄÄÄÄÄÄÄ dlugosci poszczegolnych liter i ich kody
              %include 'letters.inc'
;ÄÄÄÄÄÄÄÄÄÄÄÄ tekstura liter
texture:      incbin 'texture.bin'
;ÄÄÄÄÄÄÄÄÄÄÄÄ paleta kolorow tekstury
txt_pal:      incbin 'palette.bin'
;ÄÄÄÄÄÄÄÄÄÄÄÄ wartosci funkcji sinus (0 - pi/2)
              align 16,db 0
              %include 'sinus.inc'


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; segment danych niezainicjowanych                                          º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
  section .bss                                                            ; º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

;ÄÄÄÄÄÄÄÄÄÄÄÄ wartosci funkcji sinus (pi/2 - 2*pi)
              resb 3 * 256
;ÄÄÄÄÄÄÄÄÄÄÄÄ grunt
ground:       resb 320
;ÄÄÄÄÄÄÄÄÄÄÄÄ paleta ognia
fire_pal:     resb 256
;ÄÄÄÄÄÄÄÄÄÄÄÄ wskazniki do liter
let_point:    resw let_def - let_width
;ÄÄÄÄÄÄÄÄÄÄÄÄ kolejka wyswietlanych liter (wskaznik, x wsp, dlugosc)
queue_p:      resw QUEUE_L + 1
queue_x:      resw QUEUE_L + 1
queue_w:      resw QUEUE_L + 1
;ÄÄÄÄÄÄÄÄÄÄÄÄ adresy buforow
buf1:         resw 1
buf2:         resw 1
;ÄÄÄÄÄÄÄÄÄÄÄÄ chwilowe dane dotyczace wyswietlanej litery
scale:        resd 1
width:        resw 1
right:        resw 1
left:         resw 1
let_start:    resw 1
txt_start:    resw 1
wave_pos:     resb 1
;ÄÄÄÄÄÄÄÄÄÄÄÄ wskaznik do starej procedury przerwania 0x8
old_int8      resd 1
;ÄÄÄÄÄÄÄÄÄÄÄÄ zarezerwowanie miejsca na dane includowane
              align 1024 * 10,resb 1


;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
; pseudo segment danych includowanych                                       º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
  section .include                                                        ; º
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

;ÄÄÄÄÄÄÄÄÄÄÄÄ maska bitowa napisu sga
sga_mask:     incbin 'sga.bin'
;ÄÄÄÄÄÄÄÄÄÄÄÄ maska bitowa liter
let_mask:     incbin 'letters.bin'


END_PROGRAM
