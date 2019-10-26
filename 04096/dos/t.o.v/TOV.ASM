ideal
model tiny
p386
dataseg
p       db 20,20,20,20,20,19,19,19,18,18,17,17,16,15,14,13,12,11,9,6,0
shobr   db 1,26,1,8,14,8,1,32,1,1,26,1,8,14,8,1,32,1,1,26,1,8,14,8,1,32,1
        db 1,26,1,8,14,8,1,32,1,1,26,1,8,14,8,1,32,1,1,26,1,8,14,8,1,32,1
        db 1,26,1,8,14,8,1,32,1,1,26,1,8,14,8,1,32,1,1,26,1,8,14,8,1,32,1
        db 1,26,1,8,14,8,1,32,1,1,26,1,8,14,8,1,9,24,1,26,1,8,14,8,1,9,24
        db 1,26,1,8,14,8,1,9,24,1,26,1,30,1,9,24,10,7,11,30,1,9,24
        db 10,7,11,30,1,9,24,10,7,11,30,1,20,13,10,7,11,30,1,20,13
        db 10,7,11,30,1,20,13,10,7,11,8,14,8,1,20,13,10,7,11,8,14,8,1,20,13
        db 10,7,11,8,14,8,1,20,13,10,7,11,8,14,8,1,9,24,10,7,11,8,14,8,1,9,24
        db 10,7,11,8,14,8,1,9,24,10,7,11,8,14,8,1,9,24,10,7,11,8,14,8,1,32,1
        db 10,7,11,8,14,8,1,32,1,10,7,11,8,14,8,1,32,1,10,7,11,8,14,8,1,32,1
        db 10,7,11,8,14,8,1,32,1,10,7,11,8,14,8,1,32,1,10,7,11,8,14,8,1,32,1
        db 10,7,11,8,14,8,1,32,1,92,1,26,1,8,14,8,1,13,20
        db 1,26,1,9,13,8,1,16,17,1,26,1,9,13,8,1,19,14,1,26,1,10,12,8,1,21,12
        db 1,26,1,10,12,8,1,22,11,1,26,1,11,11,8,1,24,9,1,26,1,11,11,8,1,25,8
        db 1,26,1,12,10,8,1,26,7,1,26,1,13,9,8,1,27,6,1,26,1,13,9,8,1,10,1,17,5
        db 1,8,19,8,1,5,8,8,1,10,3,16,4,1,8,19,8,1,5,8,8,1,10,5,14,4,1,8,19,8,2,5,7,8,1,10,7,13,3
        db 1,8,19,8,2,6,6,8,1,10,8,12,3,1,8,19,8,3,5,6,8,1,10,8,12,3,1,8,19,8,3,6,5,8,1,10,9,12,2
        db 1,17,10,8,4,5,5,8,1,10,9,12,2,1,17,10,8,4,6,4,8,1,10,10,11,2,1,17,10,8,5,5,4,8,1,10,10,11,2
        db 1,17,10,8,6,5,3,8,1,10,10,11,2,1,17,10,8,6,6,2,8,1,10,9,11,3,1,17,10,8,7,5,2,8,1,10,9,11,3
        db 1,8,19,8,7,6,1,8,1,10,8,12,3,1,8,19,8,8,5,1,8,1,10,7,12,4,1,8,19,8,8,14,1,10,5,14,4
        db 1,8,19,8,9,13,1,10,2,16,5,1,8,19,8,10,12,1,27,6,1,26,1,8,10,12,1,26,7
        db 1,26,1,8,11,11,1,25,8,1,26,1,8,11,11,1,24,9,1,26,1,8,12,10,1,23,10
        db 1,26,1,8,12,10,1,22,11,1,26,1,8,13,9,1,20,13,1,26,1,8,13,9,1,18,15
        db 1,26,1,8,14,8,1,14,19
shp     db 20,20,20,20,20,19,19,19,18,18,17,17,16,15,14,13,12,11,9,6,0

shc1    db 3fh
shc2    db 0
shc3    db 39
shc21   db 3fh
shc22   db 0h
shc23   db 39
shco     dw 1000
sit     db 128,131,134,137,141,144,147,150,153,156
        db 159,162,165,168,171,174,177,180,183,186
        db 188,191,194,196,199,202,204,207,209,212
        db 214,216,219,221,223,225,227,229,231,233
        db 234,236,238,239,241,242,244,245,246,247
        db 249,250,250,251,252,253,254,254,254,254
        db 255,255,255,255,255,255,255,255,255,254
        db 254,254,254,253,252,251,250,250,249,247
        db 246,245,244,242,241,239,238,236,234,233
        db 231,229,227,225,223,221,219,216,214,212
        db 209,207,204,202,199,196,194,191,188,186
        db 183,180,177,174,171,168,165,162,159,156
        db 153,150,147,144,141,137,134,131,128,125
        db 122,119,115,112,109,106,103,100, 97, 94
        db  91, 88, 85, 82, 79, 76, 73, 70, 68, 65
        db  62, 60, 57, 54, 52, 49, 47, 44, 42, 40
        db  37, 35, 33, 31, 29, 27, 25, 23, 22, 20
        db  18, 17, 15, 14, 12, 11, 10,  9,  7,  6
        db   6,  5,  4,  3,  2,  2,  1,  1,  1,  0
        db   0,  0,  0,  0,  0,  0,  1,  1,  1,  2
        db   2,  3,  4,  5,  6,  6,  7,  9, 10, 11
        db  12, 14, 15, 17, 18, 20, 22, 23, 25, 27
        db  29, 31, 33, 35, 37, 40, 42, 44, 47, 49
        db  52, 54, 57, 60, 62, 65, 68, 70, 73, 76
        db  79, 82, 85, 88, 91, 94, 97,100,103,106
        db 109,112,115,119,122,125
z       dw 800
zz      dw 0
sega000 dw 0a000h
segb800 dw 0b800h
micro   db 0
ria     db 0
kol1    dw 7680
kol2    dw 64000
vs      dw 0

greetsnum equ 0

text    db ' TWINSENOVE 1-VE 4KB '
        db '  INTRO SPRED PAR    '
        db ' ROKOV. KOREKTNE IDE '
        db ' LEN NA STARYCH VGA- '
        db '  KARTACH, NAMIESTO  '
        db 'MANDEL-CHLEBU JE INAC'
        db 'TMA A PALETA JE SKORO'
        db 'VSADE DOST MIMO...ALE' ;
        db 'V DOSE TO AJ DOKONCA '
        db 'ZBEHNE DOKONCA.      '
        db '---------------------'
        db '  p o z d r a v y :  '
        db '---------------------'
        db 'Peon                 '
        db 'Peon                 '
        db 'inSOMNia             '
        db 'MovSD                '
        db 'Satori               '
        db 'Broncs               '
        db 'tb2                  '
        db 'Broncs               '
        db '??? (anonymous)      '
        db 'Vectors              '
        db 'shakul & lharp       '
        db 'Broncs               '
        db 'eL                   '
        db 'Terror Opera         '
        db 'Carlos / Downtown    '
        db 'Optik                '
        db 'Wizard Raist         '
        db 'Ollie                '
        db 'Carlos / Downtown    '
        db 'Carlos / Downtown    '
        db 'Downtown             '
        db 'Carlos / Downtown    '
        db 'Carlos / Downtown    '
        db 'MiP / Marshals       '
        db 'Fire / inSOMNia      '
        db 'Dement / Downtown    '
        db 'MiP / Marshals       '
        db 'MiP / Marshals       '
        db 'Broncs               '
        db 'X-Brain / inReal     '
        db 'Carlos / Downtown    '
        db 'Crs / Broncs         '
        db 'DvD                  '
        db 'Crs / Broncs         '
        db 'Crs / Broncs         '
        db 'Carlos / Downtown    '
        db 'Caitiff              '
        db 'Axe                  '
        db 'Panter               '
        db 'Extrem               '
        db 'Pofider              '
        db 'Wark                 '
        db 'Gondar               '
        db 'Protch               '
        db 'Flash                '
        db 'Kluzoo               '
        db 'Patrick NULA         '
        db 'Sparkie              '
        db 'Sputnik              '
        db 'JMC                  '
        db 'Peter Pea            '
        db 'TDM                  '
        db 'MaX                  '
        db 'Martin Schlemmer     '
        db 'Bluezone             '
        db 'Trixie               '
        db 'Wizard Raist         '
        db 'Johny909             '
        db 'Karel Fucik          '
        db 'Dzzin                '
        db 'Doga                 '
        db 'Frohikey             '
        db 'DuckD                '
        db 'Carlos               '
        db 'Bist                 '
        db 'Bass                 '
        db 'Jordy                '
        db 'Berosh               '
        db 'MPtak                '
        db 'Hranoll              '
        db 'Danny                '
        db 'Patrick_NULA         '
        db 'Axe                  '
        db 'Fire                 '
        db 'Lucas Buck           '
        db 'Doga                 '
        db 'Johny909             '
        db 'Pofider              '
        db 'Wizard Raist         '
        db 'Frohikey             '
        db 's are not available) '
        db 'Caitiff              '
        db 'Boop                 '
        db 'Carlos               '
        db 'Extrem               '
        db 'Axe                  '
        db 'Finarfin             '
        db 'Patrick NULA         '
        db 'Frohikey             '
        db 'Pofider              '
        db 'Johny909             '
        db 'Trixie               '
        db 'Martin Schlemmer     '
        db 'Finarfin             '
        db 'Wizard Raist         '
        db 's are not available) '
        db 'Scape / Mist         '
        db 'Kosto                '
        db 'sHTiF / inSOMNia     '
        db 'Lukasek              '
        db 'Wizard Raist         '
        db 'Filipes / Uchill Sect'
        db 'Johny909 / inSOMNia  '
        db 'Reekol / react       '
        db 'Kombajn              '
        db 'Osk / MovSD          '
        db 'Mudufukuz            '
        db 'Doga / Uchill Section'
        db 'Carlos / Downtown    '
        db 'iVirii               '
        db 'Mylee                '
        db 'Nov!n / tb2          '
        db 'Koza                 '
        db 'MiG                  '
        db 'Wizard Raist         '
        db 'Doga / Uchill Section'
        db 'Carlos / Downtown    '
        db 'Axe                  '
        db 'Frohikey             '
        db 'Filipes / U-chill sec'
        db 'Carlos / Downtown    '
        db 'D.Ment / Broncs      '
        db 'Satori               '
        db 'C.P.U. Team & Musica '
        db 'Martin Schlemmer     '
        db 'DVAID                '
        db 'Kapitan              '
        db 'Kombajn              '
        db 'Dezhik               '
        db 'atd.                 '



p4      dw 09000h

t       db 'PRESENTS$'
tt      db 'TWINSEN$'
ttt     db 'intro$'
tttt    db 'called$'
ttttt   db 'T.O.V!$'
a       dw 0
s       dw 0
randseed dw 0,0
uk      db 0
vk      db 50
cc      dw 400
ph      db 1
sc      dw 400
u       db 90 dup(?)
b       dw ?
c       db ?
p1      db ?
p2      db ?
tmp1    db ?
tmp2    db ?
y       db ?
lope    db ?
shp1    dw ?
shp2    dw ?
shi     dw ?
shxn    dw ?
shlx    db ?
shly    db ?
shlj    db ?
shli    db ?
shlpo   dw ?
zaloha  db ?
pat     db ?


codeseg
startupcode

  mov ax,13h
  int 10h

      mov ax,10
@plu: push ax
      mov ch,al
      mov bl,6
      mul bl
      mov cl,al
      mov ah,cl
      mov al,ch
      mov bl,cl
      mov bh,cl
      call setpal
      pop ax
      dec ax
      cmp ax,0
      jnz @plu

      mov ax,20
@plv: push ax
      mov ch,al
      mov bl,6
      mul bl
      mov cl,63
      sub cl,al
      mov ah,cl
      mov al,ch
      mov bl,cl
      mov bh,cl
      call setpal
      pop ax
      dec ax
      cmp ax,10
      ja @plv

  call getpat
  xor ax,ax
  call fill

;{START-MENO}
        push ds
        lea dx,[t]
        mov ah,9
        int 21h ;{VYPIS TEXT}
        call vyptext c,46720,0,0a08h

        pop ds
        push ds
        lea dx,[tt]
        mov ah,9
        int 21h ;{VYPIS TEXT}
        call vyptext c,2575,64,3629h

        xor di,di
        xor ax,ax
        mov cx,2080
        rep stosb

        pop ds
  push ds
  pop es
  lea di,[u]
  mov cx,20
@fu:
  mov ax,cx
  mov bl,4
  mul bl
  stosb
  dec cx
  jns @fu

@startcop:
  xor ax,ax
  mov es,[p4]
  mov di,24640
  mov cx,[kol1]
  rep stosw
  xor dx,dx
  mov dx,19
@go:
  push ds
  pop es
  lea di,[u]
  add di,dx
  mov al,[es:di]
  push ax
  add al,2
  mov [es:di],al
  lea di,[sit]
  pop ax
  add di,ax
  mov al,[es:di]
  mov es,[p4]
  mov bx,dx
  mov di,dx
  shl bx,6
  shl di,8
  add bx,di
  mov di,30560
  mov cx,1
@su:
  sub di,bx
  loop @su
  add di,ax
  sub di,128
  mov bx,10
  mov cx,1
  add cx,1
@su2:
  add bx,dx
  loop @su2
  mov cx,bx
@li:
  add di,320
  mov al,3
@ve:
  mov [es:di],al
  inc di
  inc al
  cmp al,18
  jnz @ve
  sub di,15
  loop @li
  dec dx
  cmp dx,0
  jnz @go
  call retrace

  push ds
  mov es,[segA000]
  mov di,[kol2]
  push di
  mov cx,[kol1]
  mov ds,[p4]
  mov di,24640
  mov si,di
  rep movsw
  pop di
  xor ax,ax
  mov cx,160
  rep stosw
  pop ds

  cmp [z],200
  ja @nad
  mov bx,[vs]
  call setvs
  sub [vs],80
  sub [kol2],320
  cmp [z],124
  ja @nad
  cmp [kol1],0
  jna @nad
  sub [kol1],160
@nad:
  dec [z]
  jnz @startcop

  xor bx,bx
  call setvs

;start-pozadie
        mov cx,63
@l4:    mov ax,cx
        xor bx,bx
        call setpal
        loop @l4

        mov es,[p4]
        xor di,di
        mov cx,32767
        xor ax,ax
        rep stosw

        mov es,[sega000]
        xor di,di
        mov cx,32767
@l3:
        call random
        shr al,2
        shr ah,2
        stosw
        loop @l3

    mov cx,13
@l2:call zvacsi
    loop @l2

    push ds
    mov es,[sega000]
    mov ds,[sega000]
    xor di,di
    mov si,321
    mov cx,31679
    rep movsw
    pop ds

    push ds
    std
    mov es,[sega000]
    mov cx,198
    mov di,318
    xor ax,ax
@l1: stosw
    add di,322
    loop @l1
    mov di,63999
    mov cx,1281
    rep stosw
    cld
    pop ds

        mov cx,63
@l5:    mov ax,cx
        mov bl,cl
        mov bh,cl
        call setpal
        loop @l5
;end-pozadie

    mov ax,03f3fh
    mov bx,3f3fh
    call setpal

    mov ax,04000h
    xor bx,bx
    call setpal

    mov ax,04100h
    xor bx,bx
    call setpal


      call getpat
      mov cx,255
@pla: mov al,cl
      xor ah,ah
      xor bh,bh
      call setpal
      loop @pla

        mov es,[sega000]
        xor di,di
        xor ax,ax
        mov cx,2240
        rep stosb

       ; {intro}
        push ds
        lea dx,[ttt]
        mov ah,9
        int 21h ;{VYPIS TEXT}
        call vyptext c,3260,120,4040h
       ;{called}
        pop ds
        push ds
        lea dx,[tttt]
        mov ah,9
        int 21h ;{VYPIS TEXT}
        call vyptext c,23400,160,4141h
       ;{T.O.V!}
        pop ds
        push ds
        lea dx,[ttttt]
        mov ah,9
        int 21h ;{VYPIS TEXT}
        call vyptext c,42600,208,3f3fh

        xor di,di
        xor ax,ax
        mov cx,2240
        rep stosb
        pop ds

        push ds
        pop es
        lea si,[pat]
        mov di,si
        add di,768
        mov cx,180h
        rep movsw

        call getpat


        mov cx,63
@defp:  call retrace
        call morfpal
        loop @defp



        mov cx,290
@del:   call retrace
        loop @del

        xor ax,ax
        call fill

        mov cx,63
@dep:   call retrace
        call morfpal
        loop @dep

        mov es,[sega000]
        xor di,di
        mov cx,32768
        xor ax,ax
        rep stosw

;start-mandel
              mov cx,16
@palloop:     mov al,cl
              mov ah,cl
              mov bx,ax
              shl ah,2
              shl bx,2
              call setpal
              mov al,31
              sub al,cl
              call setpal
              loop @palloop

              mov di,190h
@j5:          mov [b],0
              mov si,0fda0h;E=F
@j4:          mov bx,si
              mov cx,di
              mov [c],18h
@j3:          mov ax,bx
              imul ax
              mov al,ah
              mov ah,dl
              mov bp,ax
              mov ax,cx
              imul cx
              mov al,ah
              mov ah,dl
              mov es,ax
;              add ax,bp
              sub ax,800h
              jnb @j1
              mov ax,es
              sub bp,ax
              add bp,si
              xchg bp,bx
              mov ax,cx
              imul bp
              mov cl,ah
              mov ch,dl
              test dh,80h
              jz @j2
@j2:          add cx,di
              add cx,cx
              dec [c]
              jnz @j3
@j1:          mov dx,[a]

              push di

              mov ax,0a000h
              mov es,ax
              mov di,[s]
              inc [s]
              mov al,[c]
              stosb

              pop di

              add si,3
              inc [b]
              cmp [b],0140h
              jz @h4
              jmp @j4


@h4:
              sub di,4
              inc dx

              push ax dx bx
              mov ax,dx
              mov bx,80
              mul bx
              mov bx,ax
              add bx,384
              call retrace
              call setvs
              pop bx dx ax

              mov [a],dx
              cmp dx,0c8h
              jz @h5
              jmp @j5
@h5:

        mov cx,190
@dela:  call retrace
        loop @dela


              mov bx,2
@mcll:        call retrace
              mov dx,3d4h
              mov ax,2813h
              out dx,ax
              mov cx,396
@minlo:       call wfh
              cmp cx,bx
              jnz @mvvp
              xor ah,ah
              out dx,ax
@mvvp:
              loop @minlo
              inc bx
              cmp bx,396
              jne @mcll

              xor bx,bx
              call setvs
;end-mandel

;* start coppers
            mov ax,13h
            int 10h
            lea bx,[sit]
            mov ch,0
            mov ax,0a000h
            mov es,ax
@cl1:
            mov cx,399
   @cl2:
            mov al,[uk]
            xlat
            xor ah,ah
            shr ax,1
            mov di,ax
            add di,96
            call wfh
            call st1

            cmp cx,160
            jb @n2
            inc [uk]
@n2:

            mov al,[vk]
            xlat
            xor ah,ah
            mov di,ax
            add di,32
            call st2
            cmp cx,200
            jb @n1
            inc [vk]
@n1:

            mov dx,3d4h
            mov ax,0013h
            cmp [cc],cx
            jb @vvp
            mov ah,28h
@vvp:       out dx,ax
            loop @cl2
@nxt:

            sub [uk],238
            sub [vk],197

            call retrace

            cmp [ph],1
            ja @ph2
            cmp [cc],0
            jz @nez
            dec [cc]
            jmp @fph
@nez:       inc [ph]
            jmp @fph
@ph2:       cmp [ph],2
            ja @ph3
            dec [sc]
            jnz @okph2
            inc [ph]
@okph2:     jmp @fph
@ph3:       inc [cc]
            cmp [cc],400
            jz @koncime

@fph:

            mov di,32
            xor ax,ax
            mov cx,134
            rep stosw
            jmp @cl1
@koncime:
;* end coppers







  mov dx,3d4h
  mov al,9
  out dx,al
  inc dx
  in al,dx
  or al,128
  out dx,al

   mov cx,128   ;naplnenie palety
@ep:
   mov al,cl
   mov ah,cl
   mov bl,cl
   mov bh,cl
   shr ah,1
   shr bl,1
   shr bh,1
   push ax
   push bx
   call setpal
   pop bx
   pop ax
   neg al
   dec al
   call setpal
   loop @ep
   mov ax,0ffh
   xor bx,bx
   call setpal
   call getpat

   mov ax,3f3fh
   call fill

@start:                 ;***** VGA PLASMA *****
     add [p1],2
     sub [p2],1
     mov es,[segA000]
     xor di,di
     lea bx,[sit]
     call retrace
     mov [y],100
@yl:               ;y-ova slucka
     call part1
     mov cx,160

@xl:                ;x-ova slucka
     call part2
     add [tmp2],al
     mov al,[tmp1]
     mov ah,[tmp2]
     stosw

     inc dl
     loop @xl

     dec [y]
     cmp [y],0
     jne @yl

     inc [z]
     cmp [z],400
     jna @start
     call morfpal
     cmp [z],462
     jna @start

                        ;***** textmode plasma *****
     mov ax,3
     int 10h

   push ds
   pop es
   lea dx,[pat]
   add dx,768
   xor bx,bx
   mov cx,256
   mov ax,1017h
   int 10h


     mov ah,11h
     mov al,10h
     mov bh,4
     xor bl,bl
     xor cx,cx
     xor dx,dx
     int 10h
     mov ah,11h
     mov al,02h
     mov bl,0
     int 10h
     mov dx,3d4h
     mov al,0ah
     out dx,al
     inc dx
     in al,dx
     or al,20h
     out dx,al
@atart:

     add [p1],2
     sub [p2],1

     mov es,[segB800]
     mov di,1
     lea bx,[sit]
     mov [y],100
@ya:
     call part1
     mov cx,40
@xa:
     call part2
     add [tmp2],al
     mov [z],bx
     mov bl,16
     mov ah,0
     mov al,[tmp1]
     div bl
     mov ah,1
     shl al,3
     stosw
     mov ah,0
     mov al,[tmp2]
     div bl
     mov ah,1
     shl al,3
     stosw
     mov bx,[z]
     inc dl
     loop @xa
     dec [y]
     cmp [y],0
     jne @ya
     call retrace

     inc [zz]
     cmp [zz],64
     ja @nx
     jz @clp
     call morfpal
     jmp @nx
@clp:
   xor ax,ax
   call fill
@nx:
     cmp [zz],400
     jb @atart
     call morfpal
     cmp [zz],462
     jb @atart


;*

            mov ax,3
            int 10h

            mov ah,2
            xor bh,bh
            mov dx,2001h
            int 10h

            mov dx,3d4h
            mov al,8
            out dx,al
            inc dx
            in al,dx
            mov [zaloha],al
            lea si,[text]
            mov bx,39+272+2*greetsnum


@oulo:
            mov [micro],0
            call vypis
@inlo:
            inc [micro]
            call retrace
            call microposun
            cmp [micro],15
            jnz @inlo

            mov [micro],0
            call retrace
            call microposun
            call scrollup

            dec bx
            jnz @oulo


@koniec:

;* shadebobs

        mov ax,13h
        int 10h
        call setallpal
;*
            mov di,22520
            mov es,[sega000]
            mov [shly],0
            mov [shlpo],0
@LL1:
            mov [shlj],0
            mov [shli],0
            mov [shlx],0
@LL2:
            lea si,[shobr]
            add si,[shlpo]
            lodsb
            inc [shlpo]

            xor ch,ch
            mov cl,al

            add [shlx],cl
            mov al,[shlj]
            rep stosb
            mov ah,128
            sub ah,al
            mov [shlj],ah


            cmp [shlx],92
            jb @LL2

            add di,228

            inc [shly]
            cmp [shly],70
            jb @LL1
;*

@gl:
        call retrace
        cmp [shco],128
        jb @cls
        lea bx,[sit]
        add [shc1],3
        add [shc2],2
        add [shc3],5

        xor ah,ah
        mov al,[shc1]
        xlat
        shr al,2
        mov [shp1],ax

        mov al,[shc2]
        xlat
        shr al,2
        mov [shp2],ax
        mov al,[shc3]
        xlat
        shr al,4
        add [shp2],ax
        add [shp1],130
        add [shp2],60
        call kruh c,[shp1],[shp2],1
@cls:
        cmp [shco],872
        ja @me

        lea bx,[sit]
        add [shc21],3
        add [shc22],2
        add [shc23],5

        xor ah,ah
        mov al,[shc21]
        xlat
        shr al,2
        mov [shp1],ax

        mov al,[shc22]
        xlat
        shr al,2
        mov [shp2],ax
        mov al,[shc23]
        xlat
        shr al,4
        add [shp2],ax
        add [shp1],130
        add [shp2],60
        call kruh c,[shp1],[shp2],255
@me:
        dec [shco]
        jnz @gl
        mov ax,3
        int 10h

;* koniec shadebobs


                       ;***** koniec *****
exitcode

proc morfpal            ;premena palety
      push cx
      mov bx,256
      lea si,[pat]
@moop:mov cx,3
@mop1:lodsb
      mov ah,[si+767]
      cmp al,ah
      jz @mk
      ja @mod
      inc al
      jmp @mwri
@mod: dec al
@mwri:mov [si-1],al

@mk:  loop @mop1
      dec bx
      jnz @moop
      sub si,768
      mov dx,3c8h
      mov cx,256
@mop2:mov al,cl
      neg al
      out dx,al
      inc dx
      outsb
      outsb
      outsb
      dec dx
      loop @mop2
      pop cx
      ret
endp morfpal

proc retrace     ;cakanie na v.retrace
      push dx ax
      mov dx,3dah
@v1:  in  al,dx
      and al,8h
      cmp al,0h
      jne @v1
@v2:  in al,dx
      and al,8h
      cmp al,8h
      jne @v2
      pop ax dx
      ret
endp retrace

proc setpal         ;nastavenie palety
   mov dx,3c8h
   out dx,ax
   inc dx
   mov al,bl
   out dx,al
   mov al,bh
   out dx,al
   ret
endp setpal

proc part1
     mov al,[p1]
     add al,[y]
     xlat
     mov dl,al

     mov al,[p2]
     xlat
     mov dh,al
   ret
endp part1

proc part2
     mov al,dl
     xlat
     mov [tmp1],al
     mov al,dh
     add al,[y]
     xlat
     add [tmp1],al
     inc dl
     mov al,dl
     xlat
     mov [tmp2],al
     mov al,dh
     add al,[y]
     xlat
     ret
endp part2

proc fill
   push ds
   pop es
   lea di,[pat]
   add di,768
   mov cx,384
   rep stosw
     ret
endp fill

proc vypis
            push bx
            shr bx,1
            jc @ko
            cmp bx,13
            jb @ko

            mov es,[segb800]
            mov di,4062
            mov ah,7
            mov cx,21
@l:
            lodsb
            stosw
            loop @l

;            inc [ria]
;            cmp [ria],20
;            jnz @ok1
;            sub si,21
;@ok1:
;            cmp [ria],7
;            jmp @ok2
;            sub si,21
;            cmp [ria],19
;            jnz @ok2
;            add si,21
;@ok2:
@ko:        pop bx
            ret
endp vypis

proc scrollup
            push bx
            mov ax,0601h
            xor cx,cx
            mov dx,1f50h
            mov bh,07
            int 10h
            pop bx
            ret
endp scrollup

proc microposun
            mov dx,3d4h
            mov al,8

            mov ah,[zaloha]
            or ah,[micro]
            out dx,ax
            inc dx
            ret
endp microposun

proc getpat
   push ds
   pop es
   lea dx,[pat]
   xor bx,bx
   mov cx,256
   mov ax,1017h
   int 10h
   ret
endp getpat

proc setvs
    push dx ax
    mov dx,3d4h
    mov ax,bx
    mov al,0ch
    out dx,ax
    mov ax,bx
    mov ah,al
    mov al,0dh
    out dx,ax
    pop ax dx
    ret
endp setvs

proc c vyptext par1,par2,par3
        mov bx,0
        mov es,[sega000]
        mov ds,[sega000]

@p1:    mov si,bx

        mov dx,ds
        pop ds
        push ds
        add si,[par2]
        mov ds,dx

        mov cx,64
@lop:   lodsb
        mov di,bx
        shl di,3

        sub di,cx
        sub di,cx
        sub di,cx
        sub di,cx
        sub di,cx

        cmp al,7
        jnz @okk


        mov dx,ds
        pop ds
        push ds
        add di,[par1]
        mov ds,dx


        push di
        push cx
        push bx

        mov bx,7
@il:
        mov cx,2

        mov dx,ds
        pop ds
        push ds
        mov ax,[par3]
        mov ds,dx

        rep stosw
        add di,316
        dec bx
        jnz @il

        pop bx
        pop cx
        pop di


@okk:    loop @lop

        add si,256
        add bx,320
        cmp bx,2240
        jb @p1
        ret
endp vyptext

proc random
        push bx
        push cx
        push dx
        mov bx,[randseed+2]
        mov cx,[randseed]
        mov al,bh
        mov bh,bl
        mov bl,ch
        mov ch,cl
        xor cl,cl
        rcr al,1
        rcr bx,1
        rcr cx,1
        add cx,[randseed]
        adc bx,[randseed+2]
        add cx,62E9h
        adc bx,3619h
        mov [randseed+2],bx
        mov [randseed],cx
        mov ax,bx
        pop dx
        pop cx
        pop bx
        ret
endp random


proc zvacsi
        push cx
        mov ax,[sega000]
        push ds
        mov ds,[p4]
        xor si,si
        mov es,ax
        xor di,di
        xor bl,bl
        mov cx,16000
@loop:
        movsb
        inc di
        inc bl
        cmp bl,159
        jna @ok
        xor bl,bl
        add si,160
        add di,320
@ok:    loop @loop

        push es
        push ds
        pop es
        pop ds
        xor di,di
        xor si,si
        mov cx,32000
        rep movsw

        push es
        push ds
        pop es
        pop ds
        xor di,di
        xor si,si
        mov cx,16000
        xor bl,bl
@loop2:
        xor ax,ax
        xor dx,dx
        lodsb
        mov dl,al
        inc si
        lodsb
        sub si,3
        add ax,dx
        inc di
        shr ax,1
        stosb

        xor dl,dl
        lodsb
        mov dl,al
        add si,639
        lodsb
        sub si,641
        add ax,dx
        add di,318
        shr ax,1
        stosb

        xor dl,dl
        xor ax,ax
        lodsb
        mov dl,al
        inc si
        lodsb
        add dx,ax
        add si,637
        lodsb
        add dx,ax
        inc si
        lodsb
        add ax,dx
        shr ax,2
        stosb
        sub di,320
        sub si,641

        inc bl
        cmp bl,159
        jna @okk2
        xor bl,bl
        add di,320
        add si,320
@okk2:
        loop @loop2

        pop ds
        push ds

    mov es,[sega000]
    mov ds,[sega000]
    xor di,di
    mov si,321
    mov cx,31679
    rep movsw
    pop ds
    pop cx
    ret
endp zvacsi

proc c kruh kx,ky,oko:byte
        mov [shi],20
@GlL:
        mov ax,[shi]
        lea bx,[p]
        xlat
        xor ah,ah
        mov [shxn],ax

        mov es,[sega000]
        mov ax,[ky]
        add ax,[shi]
        mov di,ax
        shl ax,6
        shl di,8
        add di,ax
        add di,[kx]
        sub di,[shxn]
        mov al,15
        mov cx,[shxn]
        jcxz @en1
        push ds
        push es
        pop ds
        mov si,di
@lk1:    lodsw
        add al,[oko]
        add ah,[oko]
        stosw
        loop @lk1
        pop ds
@en1:
        cmp [shi],0
        jz @en2
        mov ax,[ky]
        sub ax,[shi]
        mov di,ax
        shl ax,6
        shl di,8
        add di,ax
        add di,[kx]
        sub di,[shxn]
        mov al,15
        mov cx,[shxn]
        jcxz @en2
        push ds
        push es
        pop ds
        mov si,di
@lk2:    lodsw
        add al,[oko]
        add ah,[oko]
        stosw
        loop @lk2
        pop ds
@en2:
        dec [shi]
        cmp [shi],65530
        jna @gll
     ret
     endp

proc c setallpal         ;nastavenie palety
    mov dx,3c8h
    xor al,al
    out dx,al
    inc dx
    mov cx,127
@lk:xor al,al
    out dx,al
    out dx,al
    mov al,127
    sub al,cl
    shr al,1
    out dx,al
    loop @lk

   mov cx,127
@k:mov al,127
   sub al,cl
   out dx,al
   out dx,al
   out dx,al
   loop @k

   ret
endp setallpal

proc st1
  mov eax,8c898580h
  stosd
  mov eax,738e8e73h
  stosd
  mov eax,8085898ch
  stosd
  sub di,12
  ret
  endp

proc st2
  mov eax,1c191510h
  stosd
  mov eax,1e03031eh
  stosd
  mov eax,1015191ch
  stosd
  sub di,12
  ret
  endp

proc wfh
    push dx ax
    mov dx,3dah
@h1:in  al,dx
    test al,1
    jnz @h1
@h2:in al,dx
    test al,1
    jz @h2
    pop ax dx
    ret
    endp
end