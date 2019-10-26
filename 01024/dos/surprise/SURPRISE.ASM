; Entry van Rob voor de surprise compo van Takeover'98
   IDEAL
   MODEL tiny
   CODESEG
   ORG 100h
   p486
START:
   jmp      @hetbegin
   db 13,10,13,10,13,10,13,10,"         De surprise compo entry van Rob.",13,10,"     Gekoot op 16 mei 1998 op Takeover '98!!!  ",13,10,13,10,"                De Mazzel !!!"  

   db 1Ah

@hetbegin:
   xor      bx, bx
@lkj:
   mov      [xpos + bx], 0
   mov      [ypos + bx], 0
   mov      [yvel + bx], 0
   add      bx, 2
   cmp      bx, 6000
   jbe      @lkj

   call     maak_een_sinustabel
   mov      al, 13h
   int      10h
   push     ds


   mov      dx, offset string
   mov      ah, 9h
   int      21h
   mov      ax, 0a000h
   mov      ds, ax
   mov      ax, 08000h
   mov      es, ax
   xor      di, di
   mov      cx, 32000
   xor      ax, ax
   rep      stosw

   xor      si, si
   mov      di, 29105
   mov      bx, 8
@vloop:   
   mov      cx, 105
@hloop:   
   lodsb
   or       al, al
   je       @niks1
   mov      ax, 0909h
   mov      es:[di], ax
   mov      es:[di+2], al
   mov      es:[di+320], ax
   mov      es:[di+322], al
   mov      es:[di+640], ax
   mov      es:[di+642], al
@niks1:
   add      di, 3
   loop     @hloop
   add      di, 5+640
   add      si, 215
   dec      bx
   jnz      @vloop

   pop      ds
                 
   push     es
   pop      fs
   mov      ax, 0a000h
   mov      es, ax

   mov      cx, 32000
   mov      ax, 00h
   xor      di, di
   rep      stosw

   xor      bx, bx
   xor      cx, cx
   mov      [max], 0
@hoofdloop:
   call     programma

   mov      dx, 3dah
@vloop1:
   in       al, dx
   and      al, 8h
   jz       @vloop1
@vloop2:
   in       al, dx
    and      al, 8h
   jnz      @vloop2

   xor      bx, bx
@plaats_de_sterren:
   mov      di, [xpos + bx]
   shr      di, 7
   mov      ax, [ypos + bx]
   shr      ax, 8
   shl      ax, 6
   add      di, ax
   shl      ax, 2
   add      di, ax
   mov      al, 0                               ; weghalen
   stosb
    

   mov      ax, [xvel + bx]
   add      [xpos + bx], ax
   mov      ax, [yvel + bx]
   add      [ypos + bx], ax
   mov      ax, [accel + bx]
   add      [yvel + bx], ax

   mov      ax, [ypos + bx]
   shr      ax, 8
   cmp      ax, 198
   jb       @okdan1
   call     maak_nieuwe_ster
@okdan1:
   cmp      ax, 1
   ja       @okdan2
   call     maak_nieuwe_ster
@okdan2:
   mov      ax, [xpos + bx]
   shr      ax, 7
   cmp      ax, 1
   ja       @okdan3
   call     maak_nieuwe_ster
@okdan3:
   cmp      ax, 318
   jb       @okdan4
   call     maak_nieuwe_ster

@okdan4:
   mov      di, [xpos + bx]
   shr      di, 7
   mov      ax, [ypos + bx]
   shr      ax, 8
   shl      ax, 6
   add      di, ax
   shl      ax, 2
   add      di, ax
   mov      al, fs:[di]
   cmp      al, 0
   je       @hallllooo
   mov      al, 41
   stosb
   jmp      @pop
@hallllooo:
   xor      ax, ax

   cmp      bx, 5600
   jb       @ety
   mov      al, 3
   jmp      @utr
@ety:
   cmp      bx, 4200
   jb       @hfg
   mov      al, -13
   jmp      @utr
@hfg:
   cmp      bx, 2800
   jb       @ew
   mov      al, -12
   jmp      @utr
@ew:
   cmp      bx, 1400
   jb       @utr
   mov      al, -4
@utr:
   add      al, 44                               
   stosb
@pop:   

   add      bx, 2
   cmp      bx, [max];4900
   jbe      @plaats_de_sterren

   in       al, 60h
   dec      al
   jnz      @hoofdloop

   mov      ax, 03h
   int      10h
   ret

;-----------------------------------------------------------------------------
random_getal:                                    ; in bx het 'bereik'
   in       ax, 40h
@hgf:
   sub      ax, bx
   cmp      ax, bx
   ja       @hgf
   ret                                          ; einde van @random_getal

maak_nieuwe_ster:
   push     bx                                  ; bx = # van de ster
   mov      di, bx

   cmp      di, 5600
   jbe      @fgh
   mov      ax, [xkoers5]
   shl      ax, 7
   mov      [xpos + di], ax
   mov      ax, [ykoers5]
   jmp      @jhgf
@fgh:
   cmp      di, 4200
   jbe      @jkl
   mov      ax, [xkoers4]
   shl      ax, 7
   mov      [xpos + di], ax
   mov      ax, [ykoers4]
   jmp      @jhgf
@jkl:
   cmp      di, 2800
   jbe      @dfkgj
   mov      ax, [xkoers3]
   shl      ax, 7
   mov      [xpos + di], ax
   mov      ax, [ykoers3]
   jmp      @jhgf
@dfkgj:
   cmp      di, 1400
   jbe      @qtwre
   mov      ax, [xkoers2]
   shl      ax, 7
   mov      [xpos + di], ax
   mov      ax, [ykoers2]
   jmp      @jhgf
@qtwre:
   mov      ax, [xkoers]
   shl      ax, 7
   mov      [xpos + di], ax
   mov      ax, [ykoers]
@jhgf:
   shl      ax, 8
   mov      [ypos + di], ax
   mov      bx, 300
   call     random_getal
   sub      ax, 150
   mov      [xvel + di], ax
   mov      bx, 800
   call     random_getal
   sub      ax, 400
   mov      [yvel + di], ax
   mov      bx, 10
   call     random_getal
   add      ax, 10
   mov      [accel + di], ax
   pop      bx
   ret

maak_een_sinustabel:
   finit                           ; init the fpu.
   xor      di, di
buildtrig:
   fldpi
   fimul    [xx]
   fidiv    [degs]
   fsin
   fimul    [ampl]
   fistp    [word ptr sintabel + di]
   add      di, 2
   dec      [xx]
   jnz      buildtrig   ; setup the sin table.
   ret



programma:
   xor      bx, bx
   mov      bl, [x]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 200
   mov      [xkoers], ax
   xor      bx, bx
   mov      bl, [y]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 85
   mov      [ykoers], ax
   inc      [x]
   inc      [y]
   cmp      [max], 6900
   jae      @hehe
   add      [max], 8
@hehe:
   xor      bx, bx
   mov      bl, [x2]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 60
   mov      [xkoers2], ax
   xor      bx, bx
   mov      bl, [y2]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 60
   mov      [ykoers2], ax
   inc      [x2]
   dec      [y2]

   xor      bx, bx
   mov      bl, [x3]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 170
   mov      [xkoers3], ax
   xor      bx, bx
   mov      bl, [y3]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 60
   mov      [ykoers3], ax
   inc      [x3]
   inc      [y3]

   xor      bx, bx
   mov      bl, [x4]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 85
   mov      [xkoers4], ax
   xor      bx, bx
   mov      bl, [y4]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 80
   mov      [ykoers4], ax
   dec      [x4]
   inc      [y4]

   xor      bx, bx
   mov      bl, [x5]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 240
   mov      [xkoers5], ax
   xor      bx, bx
   mov      bl, [y5]
   shl      bx, 1
   mov      ax, [word ptr sintabel + bx]
   add      ax, 60
   mov      [ykoers5], ax
   dec      [x5]
   dec      [y5]
   ret

max dw 7200 ; = 3000 sterretjes
xx dw 255
ampl dw 50
degs dw 128
x db 0
x2 db 50
x3 db 80
x4 db 240
x5 db 180
y db 90
y2 db 140
y3 db 170
y4 db 74
y5 db 240
xkoers dw 160
xkoers2 dw 80
xkoers3 dw 110
xkoers4 dw 110
xkoers5 dw 110
ykoers dw 100
ykoers2 dw 70
ykoers3 dw 110
ykoers4 dw 110
ykoers5 dw 110
string db " Takeover '98$"
xpos dw 3500 dup(?)
ypos dw 3500 dup(?)
xvel dw 3500 dup(?)
yvel dw 3500 dup(?)
accel dw 3500 dup(?)
Sintabel dw 256 dup(?)
END START


