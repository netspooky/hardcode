;
; Central Park West BBSTRo
;
; Code is pretty much un-optimized for speed or size :)
; Size opt's in code don't make much diff when you have nearly 30k of data ;)
;
; -Goblin/Xtatic'96-
;

        .model large
        .386
        .stack  256

        .data
    ASSUME DS:@DATA

IPS             =       50

Fade_count db 0

bs2    db 32000 dup (0) ; Virtual screen for the Plasmas

i1     db 0
j1     db 0 ; Used for red plasma

i2     db 0
j2     db 0 ; Used for green plasma

i3     db 0
j3     db 0 ; Used for blue plasma

sint label byte
include s1.inc   ; Sine tables

sint2 label byte
include s2.inc   ; *** THESE TWO TABLES MUST BE IN THE SAME SEGMENT ***

redt label byte
include rt.inc   ; This table is used to limit the Plasma colours (63 shades)

picture label byte
include cpw.inc  ; The actual logo
pic_h EQU 22     ; The REAL height of the logo divided by 3

start_text db 0ah,0dh,'Central Park West BBSTRo (C) Xtatic',027h,'96',0ah,0dh,'$'

start_text2 db 'Frog and Gator want you to know...',0ah,0dh
            db '                           This file passed through$'

ENDANSI LABEL BYTE
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,'�',8,0,0,'c',11,'e',3,'n',3,'t',3,'r',3
        DB      'a',3,'l',3,0,0,'p',11,'a',3,'r',3,'k',3,0,0,'w',11
        DB      'e',3,'s',3,'t',3,0,0,'�',8,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,'s',11,'t'
        DB      3,'a',3,'f',3,'f',3,0,0,':',8,0,0,'f',11,'r',3,'o'
        DB      3,'g',3,0,0,'&',8,0,0,'g',11,'a',3,'t',3,'o',3,'r'
        DB      3,'!',3,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,'"',8,'c',11,'a',3,'m',3,'p',3
        DB      'b',3,'e',3,'l',3,'l',3,'t',3,'o',3,'w',3,'n',3,39,8,'s'
        DB      3,0,0,'f',11,'i',3,'n',3,'e',3,'s',3,'t',3,'"',8,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,'+',3,'6',11
        DB      '1',3,'-',8,'4',11,'6',3,'-',8,'x',11,'R',3,'A',3,'T'
        DB      3,'E',3,'D',3,'!',3,0,0,'-',8,0,0,'a',11,'s',3,'k'
        DB      3,0,0,'a',11,'r',3,'o',3,'u',3,'n',3,'d',3,'!',3,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,'c',11,'o',3,'d',3,'e',3,',',8,0,0,'g'
        DB      11,'r',3,'a',3,'p',3,'h',3,'i',3,'c',3,'s',3,0,0,'a'
        DB      11,'n',3,'d',3,0,0,'d',11,'e',3,'s',3,'i',3,'g',3,'n'
        DB      3,0,0,0,0,':',8,0,0,'g',11,'o',3,'b',3,'l',3,'i'
        DB      3,'n',3,'/',8,'x',11,'t',3,'a',3,'t',3,'i',3,'c',3,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,'m',11,'u',3,'s',3
        DB      'i',3,'c',3,0,0,'a',11,'n',3,'d',3,0,0,'a',11,'d'
        DB      3,'d',3,'i',3,'t',3,'o',3,'n',3,'a',3,'l',3,0,0,'d'
        DB      11,'e',3,'s',3,'i',3,'g',3,'n',3,0,0,':',8,0,0,'l'
        DB      11,'e',3,'g',3,'e',3,'n',3,'d',3,'/',8,'f',11,'o',3,'r'
        DB      3,'c',3,'e',3,'^',8,'x',11,'t',3,'a',3,'t',3,'i',3,'c'
        DB      3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      15,'a',11,'d',3,'l',3,'i',3,'b',3,0,0,'m',11,'u',3,'s'
        DB      3,'i',3,'c',3,0,0,'r',11,'e',3,'p',3,'l',3,'a',3,'y'
        DB      3,0,0,'c',11,'o',3,'d',3,'e',3,0,0,0,0,0,0,0
        DB      3,':',8,0,0,'s',11,'h',3,'a',3,'y',3,'d',3,'e',3,'/'
        DB      8,'r',11,'e',3,'a',3,'l',3,'i',3,'t',3,'y',3,0,0,0
        DB      02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,'(',8,'c',11,')',8,0,0,'x',11,'t',3
        DB      'a',3,'t',3,'i',3,'c',3,0,0,'p',11,'r',3,'o',3,'d',3
        DB      'u',3,'c',3,'t',3,'i',3,'o',3,'n',3,'s',3,0,0,'1',11
        DB      '9',3,'9',3,'6',3,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB      0,0,0,0,0,0,0,0,0,0,0

;end_text db 0ah,0dh,'Code&GFX&Design: Goblin'
;         db 0ah,0dh,'          Music: Legend'
;         db 0ah,0dh,' Music routines: Shayde/Reality'
;         db 0ah,0dh
;         db 0ah,0dh
;         db 0ah,0dh,'This file came from...'
;         db 0ah,0dh,'Central Park West  -  SysOps: FRoG & GaToR'
;         db 0ah,0dh,'    "Campbelltown',027h,'s Finest"'
;         db 0ah,0dh
;         db 0ah,0dh,'Ph: +61 46-XRATED - Ask around!'
;         db 0ah,0dh,0ah,0dh,'$'

Stand_pal db    768 dup (?); Used to store the Standard BIOS palette
tmp_pal   db    768 dup (?); Temporary palette, used for fades

        .code
    ASSUME CS:@CODE

Start:;          mov     ax,cs
      ;          mov     ds,ax  ; Point ds to cs, for Rad player

                mov al,01111010b
                out 21h,al     ; Disable the appropriate interrupts

;                mov     ax,cs
;                mov     ds,ax  ; Point ds to cs, for Rad player
;
;                mov     ax,Music
;                mov     es,ax
;                call    InitPlayer
;                call    SetInt ; Start up Rad player

mov ax,@data
mov ds,ax                      ; Set DS back to what it SHOULD be

mov dx,offset start_text
mov ah,09h
int 21h                        ; Output the start text, using BIOS function

        mov     ax, seg Stand_pal
        mov     es,ax
        mov     di, offset Stand_pal
        push    es
        push    di
          mov     cx,768
          xor     al,al
          mov     dx,03c7h
          out     dx,al
          inc     dx
          inc     dx
          rep     insb         ; Read in the palette
        pop     si
        pop     ds

        mov     cl,64
        @fade_txt:
                call    fade
                dec     cl
        jnz     @fade_txt      ; Does a luverly fade in text mode

mov ax,0003h
int 10h
mov cl,0
call fade                      ; Clear the screen, and set palette to black


mov dh, 12 ; row
mov dl, 23 ; column

mov ah,15
int 10h

mov ah,2
int 10h                        ; GotoXY (12,23)


mov dx,offset start_text2
mov ah,09h
int 21h                        ; Write "Frog and gator..."

mov ax,0b800h
mov es,ax
mov di,2182
               ;mov al,0 ; <- This is unneeded, as mov ax,0b800h sets al to 0
mov es:[di],al
mov es:[di+1],al               ; turn the cursor off by setting up
                               ; Black on black attribute where cursor lies

        mov     cl,0
        @fade_txt2:
                call    fade
                inc     cl
                cmp     cl,64
        jne     @fade_txt2      ;Does a luverly fade in text mode


        mov ax,100d ;       mov cx,100d
        @delay_loop:
                call waitv
                dec ax ;cx
        jnz @delay_loop


        mov     cl,64
        @fade_txt3:
                call    fade
                dec     cl
        jnz     @fade_txt3      ;Does a luverly fade in text mode

call Set320x400x256

cld

mov si,offset bs2   ; set ds:si to point to bs2 (filled with zeroes)

xor al,al
mov ah,64
mov dx,03c8h
out dx,al
inc dx
@pal_let_loop:
   out dx,al
   outsb            ; output a byte from bs2 (zero), instead of out dx, 0
   outsb
   inc al
   dec ah
   jnz @pal_let_loop

   xor al,al
   mov ah,64
@pal_let_loop2:
   outsb
   out dx,al
   outsb
   inc al
   dec ah
   jnz @pal_let_loop2

   xor al,al
   mov ah,64
@pal_let_loop3:
   outsb
   outsb
   out dx,al
   inc al
   dec ah
   jnz @pal_let_loop3

   xor al,al
   mov ah,64
@pal_let_loop4:
   out dx,al
   out dx,al
   out dx,al
   inc al
   dec ah
   jnz @pal_let_loop4

        mov     ax, seg Stand_pal
        mov     es,ax
        mov     di, offset Stand_pal
          mov     cx,768
          xor     al,al
          mov     dx,03c7h
          out     dx,al
          inc     dx
          inc     dx
          rep     insb       ; Read in the palette

                mov     ax,cs
                mov     ds,ax  ; Point ds to cs, for Rad player

                mov     ax,Music
                mov     es,ax
                call    InitPlayer
                call    SetInt ; Start up Rad player

                mov     ax, @data
                mov     ds, ax

@main_big_ole_loop:
  cmp [Fade_count],64
  je @fader_poo
  inc [Fade_count]
  mov cl,[Fade_count]
  mov si,offset stand_pal
  call fade
@fader_poo:

  add [i1],255
  inc [j1]
  xor di,di
mov si,100
 @r0:
  mov bx,si
  add bl,[i1]
  adc bh,0
  and bx,0ffh
  mov dl,sint2[bx]
  mov bl,[j1]
  xor bh,bh
  mov dh,sint2[bx]
mov cx,320
 @r1:
  mov bx,cx
  add bl,dl
  mov al,sint[bx]
  mov bx,si
  add bl,dh
  add al,sint[bx]
  mov bl,al
  mov al,redt[bx]

  mov bs2[di],al
  inc di
  dec cx
  jnz @r1
dec si
jnz @r0                 ; Do the Red Plasma

mov di,offset picture
mov si,offset bs2
add si,40*320-5  ; For centering the picture on the screen

mov bx,pic_h
@tsy:
  mov cx,320
  @tsx:
    mov al,ds:[di]
    cmp al,0
    jz @no_logo
    mov ds:[si],al
    @no_logo:
    inc di
    inc si
    dec cx
    jnz @tsx
    add di,640
  dec bx
  jnz @tsy


mov di, 50*80
call Copy_thing  ; THIS COPIES THE Red TO THE SCREEN

  add [i2],255
  inc [j2]
  xor di,di
mov si,100
 @g0:
  mov bx,si
  add bl,[i2]
  adc bh,0
  and bx,0ffh
  mov dl,sint[bx]
  mov bl,[j2]
  xor bh,bh
  mov dh,sint[bx]
mov cx,320
 @g1:
  mov bx,cx
  add bl,dl
  mov al,sint[bx]
  mov bx,si
  add bl,dh
  add al,sint2[bx]
  mov bl,al
  mov al,redt[bx]
  add al,64

  mov bs2[di],al
  inc di
  dec cx
  jnz @g1
dec si
jnz @g0                 ; Do the Green Plasma

mov di,offset picture
add di,320
mov si,offset bs2
add si,40*320-5

mov bx,pic_h
@tsy2:
  mov cx,320
  @tsx2:
    mov al,ds:[di]
    cmp al,0
    jz @no_logo2
    mov ds:[si],al
    @no_logo2:
    inc di
    inc si
    dec cx
    jnz @tsx2
    add di,640
  dec bx
  jnz @tsy2

mov di, 51*80
call Copy_thing  ; THIS COPIES THE Green TO THE SCREEN

  add [i3],255
  inc [j3]
  xor di,di
mov si,100
 @b0:
  mov bx,si
  add bl,[i3]
  adc bh,0
  and bx,0ffh
  mov dl,redt[bx]
  mov bl,[j3]
  xor bh,bh
  mov dh,sint2[bx]
mov cx,320
 @b1:
  mov bx,cx
  add bl,dl
  mov al,sint[bx]
  mov bx,si
  add bl,dh
  add al,sint[bx]
  mov bl,al
  mov al,redt[bx]
  add al,128

  mov bs2[di],al
  inc di
  dec cx
  jnz @b1
dec si
jnz @b0                 ; Do the Blue Plasma

mov di,offset picture
add di,640
mov si,offset bs2
add si,40*320-5

mov bx,pic_h
@tsy3:
  mov cx,320
  @tsx3:
    mov al,ds:[di]
    cmp al,0
    jz @no_logo3
    mov ds:[si],al
    @no_logo3:
    inc di
    inc si
    dec cx
    jnz @tsx3
    add di,640
  dec bx
  jnz @tsy3

mov di, 52*80
call Copy_thing  ; THIS COPIES THE Blue TO THE SCREEN


  cmp [Fade_count],64
  jne @main_big_ole_loop

;Get keypress(es)
@keys:          in   al, 60h
                cmp  al, 128   ;dec  al
                jae  @main_big_ole_loop

; Values ABOVE 128 returned indicate a "key release code", so, keep looping
; until a non-release code (i.e. a keypress code) is recieved.
; "dec al;jnz..." jumps if al is not 1, 1 being the code for the Escape key.
; i.e. can be used to stop looping when the ESC key is pressed.


        mov     si,offset stand_pal
        mov     cl,64
        @fade_to_txt:
                call    fade
                dec     cl
        jnz     @fade_to_txt       ;Does a luverly fade in GFX mode

mov ax,0003h
int 10h

;mov dx,offset start_text
;mov ah,09h
;int 21h
;mov dx,offset end_text
;mov ah,09h
;int 21h

mov ax, 0b800h
mov es, ax
xor di, di
mov si, offset endansi
mov cx, 160*14/4
rep movsd

mov dh, 14 ; row
;mov dl, 23 ; column

mov ah,15
int 10h

mov ah,2
int 10h    ; GotoXY (14,xx)

                mov     ax,cs
                mov     ds,ax

                call    ResetInt
                call    EndPlayer

                xor al,al
                out 21h,al

        mov     ax,4c00h
        int     21h         ; Quit to Dos



Set320x400x256 PROC NEAR
        mov     ax,13h  ; Set mode 13h Initialise 320x200
        int     10h             ; And tweak it to 320x400

        mov   dx,3ceh   ; Memory division
        mov   al,5      ; Disable bit 4 of
        out   dx,al     ; graphic mode register
        inc   dx        ; in graphics controller
        in    al,dx
        and   al,11101111b
        out   dx,al
        dec   dx

        mov   al,6      ; And change bit 1
        out   dx,al     ; in the miscellaneous
        inc   dx        ; register
        in    al,dx
        and   al,11111101b
        out   dx,al

        mov   dx,3c4h   ; Modify memory mode register in
        mov   al,4      ; sequencer controller so no further
        out   dx,al     ; address division follows in
        inc   dx        ; bitplanes, and set the bitplane
        in    al,dx     ; currently in the bit mask register
        and   al,11110111b
        or    al,4
        out   dx,al

        push  0a000h    ; Fill all four bitplanes with color
        pop   es        ; code 00H and clear the screen
        xor   di,di
        mov   ax,di
        mov   cx,8000h
        rep   stosw

        mov   dx,3d4h   ; Double pixel rows in maximum
        mov   al,9      ; scan line register of the CRT
        out   dx,al     ; controller by disabling bit 7,
        inc   dx        ; while setting bits 0-4 to 1 to
        in    al,dx     ; change the character height
        and   al,01110000b
        out   dx,al
        dec   dx        ; Return DX to CRT index register

        mov   al,14h    ; Set double word mode using bit 6
        out   dx,al     ; in underline register of
        inc   dx        ; CRT controller
        in    al,dx
        and   al,10111111b
        out   dx,al
        dec   dx

        mov   al,17h    ; Using bit 6 of mode control reg.
        out   dx,al     ; of CRT controller, change
        inc   dx        ; from word mode to byte mode
        in    al,dx
        or    al,01000000b
        out   dx,al
        ret
ENDP Set320x400x256

Copy_thing PROC NEAR
  push ds
  push dx
  mov  ax, seg bs2
  mov  ds, ax
  mov  si, offset bs2
;  inc  si
  mov bx,100
  mov ax,0a000h
  mov es,ax
;  mov di,50*80
@loop_to_here:

  mov cx,5
        mov dx,3c4h   ;  { Copies in 64 byte chunks }
        push cx
        push di
        push si
        mov ax,0102h
        out dx,ax
@pl1:
        mov ah,ds:[si+12]
        mov al,ds:[si+8]
        shl eax,16
        mov ah,ds:[si+4]
        mov al,ds:[si+0]
        stosd
        mov ah,ds:[si+28]
        mov al,ds:[si+24]
        shl eax,16
        mov ah,ds:[si+20]
        mov al,ds:[si+16]
        stosd
        mov ah,ds:[si+44]
        mov al,ds:[si+40]
        shl eax,16
        mov ah,ds:[si+36]
        mov al,ds:[si+32]
        stosd
        mov ah,ds:[si+60]
        mov al,ds:[si+56]
        shl eax,16
        mov ah,ds:[si+52]
        mov al,ds:[si+48]
        stosd
        add si,64
        loop @pl1

        pop si
        pop di
        pop cx
        inc si
        push cx
        push di
        push si

        mov ax,0202h
        out dx,ax
@pl2:
        mov ah,ds:[si+12]
        mov al,ds:[si+8]
        shl eax,16
        mov ah,ds:[si+4]
        mov al,ds:[si+0]
        stosd
        mov ah,ds:[si+28]
        mov al,ds:[si+24]
        shl eax,16
        mov ah,ds:[si+20]
        mov al,ds:[si+16]
        stosd
        mov ah,ds:[si+44]
        mov al,ds:[si+40]
        shl eax,16
        mov ah,ds:[si+36]
        mov al,ds:[si+32]
        stosd
        mov ah,ds:[si+60]
        mov al,ds:[si+56]
        shl eax,16
        mov ah,ds:[si+52]
        mov al,ds:[si+48]
        stosd
        add si,64
        loop @pl2

        pop si
        pop di
        pop cx
        inc si
        push cx
        push di
        push si

        mov ax,0402h
        out dx,ax
@pl3:
        mov ah,ds:[si+12]
        mov al,ds:[si+8]
        shl eax,16
        mov ah,ds:[si+4]
        mov al,ds:[si+0]
        stosd
        mov ah,ds:[si+28]
        mov al,ds:[si+24]
        shl eax,16
        mov ah,ds:[si+20]
        mov al,ds:[si+16]
        stosd
        mov ah,ds:[si+44]
        mov al,ds:[si+40]
        shl eax,16
        mov ah,ds:[si+36]
        mov al,ds:[si+32]
        stosd
        mov ah,ds:[si+60]
        mov al,ds:[si+56]
        shl eax,16
        mov ah,ds:[si+52]
        mov al,ds:[si+48]
        stosd
        add si,64
        loop @pl3


        pop si
        pop di
        pop cx
        inc si

        push di
        push si

        mov ax,0802h
        out dx,ax
@pl4:
        mov ah,ds:[si+12]
        mov al,ds:[si+8]
        shl eax,16
        mov ah,ds:[si+4]
        mov al,ds:[si+0]
        stosd
        mov ah,ds:[si+28]
        mov al,ds:[si+24]
        shl eax,16
        mov ah,ds:[si+20]
        mov al,ds:[si+16]
        stosd
        mov ah,ds:[si+44]
        mov al,ds:[si+40]
        shl eax,16
        mov ah,ds:[si+36]
        mov al,ds:[si+32]
        stosd
        mov ah,ds:[si+60]
        mov al,ds:[si+56]
        shl eax,16
        mov ah,ds:[si+52]
        mov al,ds:[si+48]
        stosd
        add si,64
        loop @pl4
        pop si
        pop di

    add si,317
    add di,240
    dec bx
    jnz @loop_to_here

    pop dx
    pop ds
    ret
ENDP Copy_thing

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Palette Fading Procedure
;
; Sets the palette to a certain intensity, use in a loop for a palette fade
; Assumes:
; CL=0..64 for intensity of total palette
; DS:SI points to palette to fade
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Fade proc near
        pusha
        push es
        push ds
        mov  ax, seg tmp_pal
        mov  es, ax
        mov  ax, offset Tmp_pal
        mov  di, ax        ; ES:DI points to the Temporary palette

        mov  bx, 768
@palette_copy_loop:
        xor     ax,ax
        mov     al,byte ptr ds:[si]
        inc si
        mul     cl
        shr     ax,6
        mov     es:[di],al
        inc di
        dec     bx
        jnz     @palette_copy_loop

        mov     ax,offset tmp_pal
        mov     si,ax
        mov     ax,seg tmp_pal
        mov     ds,ax       ; Now output the temporary palette

        call waitv

        mov     cx,768
        xor     al,al
        mov     dx,03c8h
        out     dx,al
        inc     dx
        @stupid_shit:
        mov al,ds:[si]
        inc si
        out dx,al
        dec cx
        jnz @stupid_shit
;        rep     outsb       ; Output the palette

        pop ds
        pop es
        popa
        ret
ENDP Fade

waitv           PROC      NEAR
		push ax
		push dx
		mov  dx, 3dah
wv1:            in   al, dx
		test al, 08h
		jnz  wv1
wv2:            in   al, dx
		test al, 08h
		jz   wv2
		pop  dx
		pop  ax
		ret
waitv           ENDP


; RADTEST.ASM Source below

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Enables and starts the player interrupt.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetInt:         push    ax es

                cli
                xor     ax,ax
                mov     es,ax
                mov     ax,es:[8*4]
                mov     word ptr OldInt,ax
                mov     ax,es:2[8*4]
                mov     word ptr OldInt+2,ax
                mov     word ptr es:[8*4], offset PlayerInt
                mov     es:2[8*4],cs

                mov     ax,IPS
                call    SetTimer

                sti
                pop     es ax
                ret


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Disables the player interrupt.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ResetInt:       push    ax es

                cli
                xor     ax,ax
                mov     es,ax
                mov     ax,word ptr OldInt
                mov     es:[8*4],ax
                mov     ax,word ptr OldInt+2
                mov     es:2[8*4],ax

                call    ResetTimer

                sti
                pop     es ax
                ret


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; The player interrupt.  Called 50 times a second.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
PlayerInt:      push    ax

                call    PlayMusic

        ; see if we have passed 18.2/s mark
        @@lx:   mov     ax,TimerSteps           ; this no. of steps per int.
                add     TimerCnt,ax
                jnc     @@ly                    ; don't call timer interrupt
                pop     ax
                jmp     cs:OldInt               ; call old interrupt handlers

        ; standard exit
        @@ly:   mov     al,20h
                out     20h,al
                pop     ax
                iret


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Sets the interrupt timer duty cycle.
; IN:
;       AX      - number of times per second for INT08.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SetTimer:       push    ax bx dx

                mov     bx,ax
                mov     ax,13532        ; 1193180 mod 65536 (TASM craps out)
                mov     dx,18           ; 1193180/65536 (TASM can't calculate this)
                div     bx
                mov     bx,ax

                mov     al,36h
                out     43h,al
                mov     al,bl
                out     40h,al
                mov     al,bh
                out     40h,al

                mov     TimerSteps,bx   ; for keeping 18.2 timer correct
                mov     TimerCnt,0      ; counter

                pop     dx bx ax
                ret


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; Resets the interrupt timer back to 18.2/sec duty cycle.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ResetTimer:     push    ax

                mov     al,36h
                out     43h,al
                xor     al,al
                out     40h,al
                out     40h,al

                pop     ax
                ret


                include         Player.Asm


OldInt          dd      ?
TimerCnt        dw      ?
TimerSteps      dw      ?
                ends


Music           segment para public use16
                include music.Inc
                ends

END Start
