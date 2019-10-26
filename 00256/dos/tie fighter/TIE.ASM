
; =====================================================================
;
;   Tie Fighter
;   Copyright (c) 1997. Srdjan Dakic
;
;   Email: dale@eunet.yu
;   WWW:   http://solair.eunet.yu/~dale
;
;   WINNER in "256 bytes" compo at YALP '97  (Belgrade, YU)
;
;   "Global variables" in entire program:
;
;   BL register - X coord of alien formation
;   BH register - X coord of player
;   BP register - screen coords of player missile
;   SI register - screen coords of alien bomb
;   ES register - segment B800
;
;   Program assumes that registers AX,BX,CX,DX,SI,DI are = 0
;   at startup time from DOS prompt.
;
;   Sorry. No more translation. 
;   Happy debugging. :)
;
;   Srdjan
;
; =====================================================================

.MODEL TINY
.CODE
.286         ; da bi se smanjio kod - potreban je 386
ORG 100H

Start:
    xor   bp, bp                    ; BP nije 0 na startu iako bi trebalo
    push  0B800H
    pop   es

Game:

    push si                         ; sacuvaj koordinatu alienske bombe
    push bx                         ; sacuvaj koordinate aliena i igraca

    ; -------------- DRAW ALIENS ---------------

    mov  di, bx                     ; pocni od BL/2 pozicije

    mov  bh, 0AH                    ; ali pre toga
    call Paint                      ; oboji ekran u svetlo zeleno

    and  di, 00111110b              ; izbrisi 0.bit (znaci iscrtavaj aliene
                                    ; na novoj poziciji svaki drugi frejm)
    lea  bx, Aliens
DrawFormation:
    mov  dx, 8                      ; ima 8 mesta u jednom redu formacije
DrawRow:
    lea  si, AlienShip              ; gde se nalazi slika tie-fightera
    ror  byte ptr [bx], 1           ; ispitaj da li se nalazi u formaciji
    sbb  ah, ah                     ; prikazi ga ili obrisi
    and  ah, 13                     ; ako prikazujes, onda je boja = 13
    mov  cl, 5                      ; alienski brod je dugacak 5 znakova
DrawAlien:
    lodsb                           ; ocitaj znak
    stosw                           ; upisi ga
    loop DrawAlien
    dec  dx                         ; da li je iscrtan ceo red formacije ?
    jnz  DrawRow
    add  di, 240                    ; preskoci jedan red na ekranu
    inc  bx                         ; idi na sledeci red formacije
    cmp  bl, low offset Aliens[4]   ; kojih, jelda, ima 4 komada
    jne  DrawFormation

    pop  bx                         ; obnovi koordinate aliena i igraca


    ; -------------- DRAW PLAYER  ---------------

    mov  ah, 0FH                    ; iscrtaj ga u poslednjem redu
    mov  al, bh                     ; belom (0F) bojom
    mov  di, ax
    mov  cl, 5
DrawPlayer:
    lodsb                           ; ocitaj znak
    stosw                           ; upisi i znak i atribut
    loop DrawPlayer


    ; -------------- MOVE ALIENS ----------------

    lodsb                           ; ocitaj pomeraj (iza definicije igraca)

    add  bl, al                     ; BL ce uvek postati neparan jer se
                                    ; dodaje +1/-1 na paran broj

    xor  bl, 00111111b              ; posto je BL neparan, ovo ce
                                    ; resetovati nulti bit te ce on
                                    ; ponovo postati paran i tada lakse
                                    ; moze da se sagradi X koordinata
                                    ; na ekranu

    jz   AlienMoveDone
ChangeMove:
    neg byte ptr [si-1]             ; promena pravca kretanja
AlienMoveDone:


    ; -------------- DRAW MISSILE AND BOMB ----------------

    mov  di, bp                     ; raketa je odmah iza pomeraja
    movsb
    pop  si
    mov  byte ptr es:[si], 'V'


    ; -------------- MISSILE SOUND ----------------

    mov  ch, 12H
    mov  ax, bp
Zvuk:                               ; na ekranu
    ror  al, 1
    out  61H, al                    ; fijuk
    loop Zvuk


    ; -------------- MOVE MISSILE ----------------

    mov  dl, 160
    mov  cl, 10
MovePlayerMissile:

    ; or   ax, ax                   ; kontrola da li uopste postoji raketa
    ; jz   MovePDone                ; ako se izbaci ova kontrola, onda ce
                                    ; gornji levi alien biti ubijen u
                                    ; startu (i kad god nema rakete)
                                    ; formacija je tako odabrana da se to
                                    ; ne primeti

    div  dl                         ; BP := Y * 160 + X

    cmp  al, 8                      ; ako se ove dve izostave onda alieni
    jae  MovePMissile               ; imaju "stitove" (potrebno je raketama
                                    ; prvo "ocistiti" nedefinisanu memoriju
                                    ; iznad alienskih formacija)

    push ax                         ; Y := BP DIV 160, X := BP MOD 160
    shr  al, 1                      ; redni br. alienske formacije je Y DIV 2
    cbw                             ; AH := 0
    mov  di, ax                     ; DI := redni broj alienske formacije
    pop  ax                         ; eventualno pogodjeni alien ima r.br.

    sub  ah, bl
    shr  ax, 8                      ; u formaciji ((X - AlienX) DIV 2) DIV 5
    div  cl                         ; AL := redni broj aliena
    cmp  al, 7
    ja   MovePMissile
    cbw                             ; AH := 0

    .386
    btr  word ptr Aliens[di], ax    ; ubij skota
    .286                            ; ako ga je ubio, unisti raketu
    jc   DestroyMissile             ; inace raketa nastavlja let ...

MovePMissile:
    sub  bp, dx                     ; pomeri je u vis
    jns  MovePDone                  ; ako je otislo u minus (udarila u
DestroyMissile:                     ; plafon) onda je unisti
    xor  bp, bp
MovePDone:



    ; -------------- READ KEYBOARD AND MOVE PLAYER ----------------

    mov  ah, 2
    int  16H
    test al, 00001000b              ; proveri da li je stisnut ALT
    jz   Move

Kill:
    mov  cx, 24*160 + 4             ; ispali novu raketu i unisti
    add  cl, bh                     ; staru ako je ispaljena i jos uvek leti
    mov  bp, cx                     ; ispali je od sredine broda
Move:
    and  al, 00000011b              ; proveri da li su stisnuti SHIFT-ovi
    jz   MoveDone                   ; ako nisu onda nista
    shl  al, 2                      ; inace bitove transformisi tako da
    sub  al, 6                      ; dobijes +2 ili -2 sto ces dodati
    sub  bh, al                     ; na poziciju igracevog broda

    ; and  bh, 01111111b              ; ako se ova instrukcija izostavi,
                                      ; onda brod moze da napusti vidljivi
                                      ; deo ekrana gde ne moze biti
                                      ; pogodjen (odlazak u bife)

MoveDone:



    ; -------------- MOVE BOMB ----------------

MoveAlienBomb:

    .386                            ; kreiraj novu bombu
    bsf  eax, dword ptr Aliens      ; bacio ju je AL-ti vanzemaljac
    .286                            ; (prvi od gore, s leva na desno)
    jnz  NotQuit                    ; ako nema vanzemaljaca onda QUIT !

    mov  bh, 0AH                    ; spremi se za poslednje brisanje ekrana
    jmp  short Clear

NotQuit:
    or   si, si                     ; ako vec leti alienska bomba, onda
    jnz  MoveABomb                  ; neka nastavi sa letenjem

    push ax                         ; inace ...
    and  al, 00000111b              ; odredi redni broj aliena u
    mul  cl                         ; formaciji i njegovu poziciju na
    add  al, bl                     ; ekranu (po horizontali)
    add  si, ax
    pop  ax
    shr  al, 2                      ; namesti bombu gde treba
    mul  dl
    add  si, ax

MoveABomb:
    add  si, dx                     ; bomba pada ...
    cmp  si, 25*160                 ; da li je izasla iz ekrana ?
    jb   CheckImpact
    xor  si, si                     ; jeste, onda je unisti ! inace proveri
CheckImpact:
    mov  ax, 24*160 + 4             ; da li je udarila u kabinu igracevog
    add  al, bh                     ; broda koji je u poslednjem redu
    cmp  ax, si                     ; da li su koordinate kabine i bombe
    .386                            ; iste? ako nisu, onda je igrac
    jne  Game                       ; preziveo, bomba i igra idu dalje
    .286                            ; (za ovo je potreban daleki 386 skok)

GameOver:                           ; inace je game over

    ; ----------------- PAUSE ---------------------

Paint:

; UNDOCUMENTED:  WaitRetrace is a side effect in this BIOS fn

    mov  ax, 1003H
    int  10H


    ; -------------- PAINT SCREEN IN BH COLOR ----------------

Clear:

    mov  ax, 0600H
    xor  cx, cx
    mov  dx, 184FH
    int  10H

    out  61H, al                    ; iskljuci zvuk

    sub  bh, 0AH                    ; menjaj boju
    jnz  GameOver                   ; ako to nije poslednja boja
                                    ; onda nastavi fleshovanje

    ret



; ----------------------------------------------------------------------------

AlienShip:      DB '(-*-)'
PlayerShip:     DB '(_ê_)'
MoveInc:        DB 1
PlayerMissile:  DB 'ê'

Aliens:         DB 01111110b
                DB 11100111b
                DB 11100111b
                DB 01111110b


END Start

