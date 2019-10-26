; Polizeifahrzeug
;-===============-

code:
org 0100h

 mov al, 01h                 ; 40*25 Textmodus
 int 10h

 mov ah, 01h                 ; Cursor ausschalten (Anfang nach Ende)
 mov ch,0FFh                 ; mov cx, 0100h => ch>cl
 int 10h
                             ; neue Spaltenzahl
 mov ax, 2013h               ; ah = Anzahl der Spalten durch 2
 mov dx, 03D4h               ; al = Funktionsnr. des CRT-Controllers
 out dx, ax

 mov ax,0B800h               ; Grafikspeicher nach es:di adressieren
 mov es, ax                  ; es:di = B800h:xxxxh

 mov ax, 860Fh               ; ah fÅr Wartezeit, al fÅr Farbe (wei·)
 mov cx, 0020h               ; 32 Zeichen
 mov di, 0608h               ; Screenstart Spruch (Zeile 13, Spalte 5)
 push di                     ; Startadresse fÅrs Lîschen zwischenspeichern
 mov si, Msg                 ; lea si, [Msg] ; Speicheradresse des Spruches
 
 @MSG:
  movsb                      ; Zeichen des Spruchs umkopieren
  stosb                      ; Farbe des Spruchs speichern
 loop @MSG

 mov cl, 20h                 ; Programm ca. 3 Sek. anhalten, ch ist bereits 00h
 int 15h                     ; dx (Portadresse) kann bleiben

 xor ax, ax                  ; Spruch lîschen
 pop di                      ; mov di, 0608h
                             ; push & pop sind kleiner als mov 16bit
 rep stosw                   ; cl wurde schon auf 20h gesetzt, ch ist 00h

 mov di, 0560h               ; Startadresse fÅr das Auto
 mov ax, 020Fh               ; ah = DurchlÑufe, al = Farbe (wei·)
; lea si, [Fahrzeug]         ; si zeigt bereits auf Fahrzeug
                             ; si zeigt eigentlich auf Status, das ist zur Op-
                             ; timierung auch das erste Zeichen des Fahrzeuges
 @AufbauFahrzeug:
  mov cx, 0006h              ; 6 Zeichen pro Zeile
  @Zeile:
   movsb                     ; Auto umkopieren - ds->es
   stosb                     ; Farbe hinzufÅgen
  loop @Zeile
  add di, 00F4h              ; entspr. Anfang der neuen Zeile + 1 Zeile
  dec ah                     ; (zweite Zeile wird Åbersprungen)
  cmp ah, 00h                ; ist bereits die dritte Zeile abgeschlossen?
  jne @AufbauFahrzeug


 sub di, 0182h               ; Mittelteil FÑrben, di=Adresse
 mov ax, 0E28h               ; Lampe vorn ist gelb
 stosw                       ; ah=Farbe, al='('

 mov cx, 0006h               ; Mittelteil ist grÅn
 mov ax, 02DBh               ; ah=Farbe, al='€'
 rep stosw

 mov ax, 0429h               ; Lampe hinten ist rot
 stosw                       ; ah=Farbe, al=')'

 sub di, 0087h               ; Blaulicht blau fÑrben
 mov al, 01h
 stosb

 mov ax, 000Dh               ; énderung der Anfangsadresse
 out dx, ax                  ; des Grafikspeichers
 inc dx
 xor ax, ax                  ; <- Wert  ^- Funktion

 @Schleife:
 out dx, ax                  ; Anfangsadresse des Grafikspeichers
 inc ax                      ; Word-weise erhîhen
 push ax
  xor bh, bh
  mov cx, 0008h              ; Anzahl der Wiederholungen
  @SmoothScrolling:
   mov ax, 1000h             ; Smooth-Scrolling Åber Palettenregisterfunktion
   mov bl, 13h
   int 10h
   inc bh
   pusha

    xor cx, cx               ; kurze Verzîgerung
    shl dx, 2                ; sollte derzeit noch reichen
    mov ah, 86h              ; Wartezeit betrÑgt jetzt 00000F54h Microsek.
    int 15h

    mov dx, 03DAh            ; 03DAh = CRT-Statusregister
    @RuecklaufStart:         ; Code um dem Flackern vorzubeugen, Scrolling
     in al, dx               ; erfolgt beim RÅcklauf des Kathodenstrahls
     and al, 08h             ; das Auto wird dadurch auch verlangsamt
     jnz @RuecklaufStart
   popa
  loop @SmoothScrolling

  pusha
  mov di, 04E4h              ; Anfangsadresse fÅr das Licht
;  lea si, [Blaulicht]       ; erster Lichtstatus, schon aktuelle Position
  mov al, 01h                ; Farbe
  mov cl, 03h                ; Zeichenanzahl, ch ist bereits 00h
  mov bl, Byte [Status]
  cmp bl, 00h
  je @Status0
  cmp bl, 01h
  je @Status1
  @Status2:                  ; dieses Label dient der öbersicht, wird aber nicht benîtigt
   add si, 0005h
   xor Byte [Status], bl
   jmp @StatusLoop
  @Status1:
   add si, 0002h
  @Status0:
   inc Byte [Status] 
  @StatusLoop:
   movsb
   stosb
  loop @StatusLoop
  popa

 pop ax
 cmp al, 40h
 jne @Schleife

 mov al, 03h                 ; Textmodus 80*25 wiederherstellen, ah ist bereits 00h
 int 10h
ret

data:
 Msg       db "Hey Lou', letz kill some hackaz!"
 Status    db 0
 Fahrzeug  db   ' ‹€‹ '
;          db '(€€€€€€)'     ; diese Zeile wird anders aufgebaut
           db  'ﬂoﬂﬂoﬂ'
 Blaulicht db '\| |/',  '\ /'; Status 0 & 1 sind in einem String
 Ende      db '256b'

;      \|/
;     ‹‹€‹‹‹
;   €€ﬂﬂ€€ﬂﬂ€€
;     ()  ()

;   ‹O‹
;(€€€€€€)
; ﬂoﬂﬂoﬂ
