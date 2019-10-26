;ú - Ä --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>
;  -  ÄÄÄ -ÄÄÄÄÄ ÜÜÜÜÛß ÄÄÄÄÄÄÄÄÜÜÜÜÄÄÄÄÄ> Û Ûİ   ÜÛßßßßÛÛÜ
;    ú -ÄÄÄÄÄÄ ÜÛÛß  ÜÜ ÄÄÄÄÄÄÜÛß ÛßÛÜÄÄÄÄŞÛ ÛÄ>ÜŞÛİ      ßß
;  ù   úù- ÄÄÄŞÛß ÄÄÄÄ ßÜ Ä ÜŞÛİ ÜÛ ŞÛİ ÜÜÛÛ Û ŞÛİßßÛÜ
;      ù  ù--ÄŞÛÛÜÜÜÛßß  ÛÜÛ ŞÛİ Û  ŞÛİÛß ŞÛ>Ûİ ßÛÜ  ßßßßßÛÛÜ
;     ú  úù -ÄŞÛİ ÄÄÄÄÄÄ ŞÛİÄŞÛİÛß  ŞÛŞİÄ>ŞÛ Ûİ   ßÛÜ      ŞÛİ
;     ú  Ä ÄÄÄ ÛÛ ÄÄÄÄÄÄ ÛßÛÄ ßÛÜ  ÜÛİ ÛÜ ÛÛ ŞÛÜÜ   ßÛÜ   ÜÛß
;  - ù úù -Ä ÄÄÄßÛÛÜÜÛß Ûß  ßÜ  ßßßß ÄÄ ßßß   ßßßßßßßßß ÜÛß
;    úù--ÄÄ-ÄÄÄÄÄÄÄÄÄ Üß Ä-ù÷ğ of Àtäçï„tŒVî ğ÷> Ûßßßßßß
;ú úù--ÄÄ-- ÄÄÄÄÄÄÄÄ ß ÄÉÍÍÍÍÍÍ-=-  - ù    -ù-  ú  -   -=ÍÍÍÍ¿
; ù - ÄÄÄÄÄÄÄÄ\//\...\/\/\ T.I.L.E.D. - a 512b intro...      \ğ->
;  ú -ùÄÄÄÄÄÄ>          Ó-  --ÄÄÄ--  -    ú-ú    ú      -- -ÄÙ

; Ok. It's a source for my intro I released for Delirium'96 512-bytes intro
; competition.  Whole  intro  (as you saw)  consists of scrolled background
; and strange message in the centre. Thiz  message's  letters  creates LCD-
; faked-self-transparent effect (whatta joke! :)
; Take a look in thiz  code, sorry  I didn't commented the source, anyway I
; think everything'll be understandable  to you. Enjoy, and remember : code
; ripping is very, very lame!

;úù--ÄÄ=ş[ Equ's ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TileOffst          equ 20*320
Tiles_X            equ 20
Tiles_Y            equ 10

TextOffst          equ 64*320+10

                   .286
                   .model tiny
                   .code
                   org 100h

;úù--ÄÄ=ş[ Initialize intro ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
start:             mov  ax, 1130h
                   mov  bh, 6
                   int  10h

                   mov  cs:FontOffst, bp
                   mov  cs:FontSeg, es
                   push cs
                   pop  es

SetMode13h:        mov  ax, 0013h
                   int  10h

;úù--ÄÄ=ş[ Makes palette ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPalette:        mov  ax, 1012h
                   mov  cx, 5
                   mov  bl, 1
                   lea  dx, TileColors
                   int  10h
                   mov  bl, 9
                   sub  cx, 2
                   int  10h

;úù--ÄÄ=ş[ Expands tile ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ExpandTile@s1:     lea  si, Tile_1[3*16]
                   lea  di, Tile_1[5*16]
                   mov  cx, 3
et@l1:             push cx
                   mov  cx, 8
                   rep  movsw
                   sub  si, 2*16
                   pop  cx
                   loop et@l1

ExpandTile@s2:     lea  si, Tile_1
                   lea  di, Tile_1[8*16+8]
                   call ExpandTile2
                   lea  si, Tile_1[8]
                   lea  di, Tile_1[8*16]
                   call ExpandTile2

ClearVirt:         xor  ax, ax
                   mov  cx, 80*320
                   lea  di, VirtScreen
                   rep  stosw

                   xor  bl, bl                   ; direction counter

;úù--ÄÄ=ş[ Main loop ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MainLoop:          lea  si, Tile_1
                   mov  di, si

                   inc  bl
                   cmp  bl, 127
                   ja   ScrollRight

;úù--ÄÄ=ş[ Scroll left ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ScrollLeft:        mov  cx, 16
L_ScrollLoop:      lodsw
                   push cx
                   push ax
                   mov  cx, 7
                   rep  movsw
                   pop  ax
                   pop  cx
                   stosw
                   loop L_ScrollLoop
                   jmp  ScrollUp

;úù--ÄÄ=ş[ Scroll right ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ScrollRight:       mov  cx, 16
                   sub  si, 2
                   std
R_ScrollLoop:      add  si, 16
                   mov  di, si
                   lodsw
                   push cx
                   push ax
                   mov  cx, 7
                   rep  movsw
                   pop  ax
                   pop  cx
                   stosw
                   add  si, 16
                   loop R_ScrollLoop
                   cld

;úù--ÄÄ=ş[ Scroll up ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ScrollUp:          lea  si, Tile_1
                   lea  di, Buffer
                   mov  cx, 8
                   rep  movsw
                   lea  di, Tile_1
                   mov  cx, 15*8
                   rep  movsw
                   lea  si, Buffer
                   lea  di, Tile_1[15*16]
                   mov  cx, 8
                   rep  movsw

;úù--ÄÄ=ş[ Draw background ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DrawBackgrnd:      lea  si, Tile_1
                   lea  di, VirtScreen
                   xor  ax, ax

                   mov  cx, Tiles_Y*16
V_TileLoop:        push cx

                   mov  cx, Tiles_X
H_TileLoop:        push cx
                   mov  cx, 8
                   rep  movsw
                   sub  si, 16
                   pop  cx

                   loop H_TileLoop

                   add  si, 16
                   inc  ax
                   cmp  ax, 16
                   jb   InTile
                   sub  si, 16*16
                   xor  ax, ax

InTile:            pop  cx
                   loop V_TileLoop

;úù--ÄÄ=ş[ Draw text ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DrawText:          lea  di, VirtScreen[TextOffst]
                   xor  bp, bp                   ; char counter

                   push ds
                   mov  ax, cs:FontSeg
                   mov  ds, ax

NewChar:           mov  al, cs:Text[bp]

                   cmp  al, 0
                   je   EndText

                   xor  ah, ah
                   shl  ax, 4
                   mov  si, ax
                   add  si, cs:FontOffst

                   mov  dl, 10000000b
CharLoop:          cmp  dl, 0
                   jz   CharDrawn

                   mov  cx, 16
ColLoop:           lodsb
                   test al, dl
                   jz   NoDot
                   mov  al, cs:[di]
                   xor  al, 08h
                   mov  cs:[di], al
                   add  al, 2
                   mov  cs:[di+320], al

NoDot:             add  di, 2*320
                   loop ColLoop

                   shr  dl, 1
                   sub  di, 2*16*320
                   add  di, 2
                   sub  si, 16
                   jmp  CharLoop

CharDrawn:         inc  bp
                   jmp  NewChar
EndText:           pop  ds

;úù--ÄÄ=ş[ Display Virtual Screen ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   push es
DisplayVirt:       mov  ax, 0a000h
                   mov  es, ax
                   lea  si, VirtScreen
                   mov  di, TileOffst
                   mov  cx, 80*320

                   mov  dx, 3dah
HZ_Wait:           in   al, dx
                   test al, 8
                   je   HZ_Wait

                   rep  movsw
                   pop  es

                   in   al, 60h
                   cmp  al, 1
                   je   ShutDown

                   lea  bp, MainLoop
                   jmp  bp

;úù--ÄÄ=ş[ Shutdown ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ShutDown:          mov  ax, 3
                   int  10h
                   mov  ax, 4c01h
                   int  21h
                   ret

;úù--ÄÄ=ş[ PrOceDuREz ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ù- ù ú
;º ExpandTile2: expands tile (step)
;ÈÍÍÍÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-- -ù- ú ù Ä-- - ù   ú
;ù     In : - (si, di adjusted...)
;:    Out : -
;| Modify : cx, si, di
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-- - ù ú -ù- -Ä- ù   ú
ExpandTile2:       mov  cx, 8
et@l2:             push cx
                   mov  cx, 4
                   rep  movsw
                   pop  cx
                   add  si, 8
                   add  di, 8
                   loop et@l2
                   ret

;úù--ÄÄ=ş[ Datas in code segment ]ş=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;          ú   ú ù- --ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Text               db '-=ğş T.i.L.E.D şğ=-'

TileColors:        db 00,00,18, 00,00,22, 00,00,26, 00,00,30
                   db 00,00,34

Tile_1:            db 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
                   db 4,4,4,4,4,4,4,5,1,1,1,1,1,1,1,5
                   db 4,3,3,3,3,3,4,5,1,2,2,2,2,2,1,5
                   db 4,3,2,2,2,3,4,5,1,2,3,3,3,2,1,5
                   db 4,3,2,1,2,3,4,5,1,2,3,4,3,2,1,5
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
                   db ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
VirtScreen:        dw 80*320 dup (?)
Buffer:            dw 8 dup (?)
FontOffst          dw ?
FontSeg            dw ?
                   end start