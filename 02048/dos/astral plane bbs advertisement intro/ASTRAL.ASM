
 comment /*******************************************************************

     Astral Plane BBS advertisement intro

     Original file size 1285B, now cut down to 1263B (wow, 22 bytes saved..)
     Code commented, a bit fixed & released on August 13th, 1994
     Written by Johannes H. Heinonen (aka Wihannes of Nordic Vision)

     This code was first written sometime in year 1993 and it was
     my second true asm-program, the first one was that usual
     "Hello Mom'n'Dad'n'AllTheOtherWorld!" stuff.. That's why you can
     optimize this code like hell and even get it under 1kB if
     you really want it.. One point to start is to use two virtual
     pages and combine the transformation routine & the vram output
     code -- just go for it!

     Oh, by the way: special greetings to everyone who admired this
     little addy at Assembly'94 gathering! Next year we'll come back
     with another amazing addy! ;-)

 ***************************************************************************/

code    SEGMENT para public 'CODE'
        ASSUME  cs:code
        LOCALS
        .286                    ; generate 80286+ compatible code

ORG     100h                    ; make .COM file

start:  mov     di, OFFSET frame
        mov     cx, 56*80
        mov     ax, 00FEh       ; initialize the fire table
        rep     stosw
        mov     di, OFFSET fmask
        mov     cx, 2384        ; 4000b for fmask, rest for palette
        xor     ax, ax          ; fmask includes the texts..
        rep     stosw

        ; create palette table

        mov     si, OFFSET paldata
        mov     cx, 0007
doLi_s: push    cx
        mov     bx, ds:[si]
        mov     cx, ds:[si+2]
        mov     ax, ds:[si+4]
        mov     dx, ds:[si+6]
        call    doLiuku
        pop     cx
        add     si, 0008
        loop    doLi_s          ; hum..hum.. it's not the clearest
        mov     cx, 0002        ; one but it costs less than that
vaFi_s: push    cx              ; 768 bytes table..
        mov     bx, ds:[si]
        mov     cx, ds:[si+2]
        mov     ax, ds:[si+4]
        call    vakioFi
        pop     cx
        add     si, 0006
        loop    vaFi_s

        mov     dx, 0a000h
        mov     es, dx          ; es=vram

;±±±±±±±±±±±±±±±±±±±±± check VGA  ±±±±±±±±±±±±±±±±±±±±±

	mov     ax, 1a00h       ; this vgacheck ripped sumwhere
	int     10h
	cmp     al, 01ah
	jne     endjmp          ; not vga
	cmp     bl, 07
	jb      endjmp          ; not vga

;±±±±±±±±±±±±±±±±±±±± check 80286+ ±±±±±±±±±±±±±±±±±±±±

tst286: pushf                    ; this 286check ripped sumwhere
        xor     ax, ax
        push    ax
        popf
        pushf
        pop     ax
        and     ax, 0f000h
        cmp     ax, 0f000h
        jne     tst186
        jmp     endjmp           ; 8088/8086
tst186: push    sp
        pop     bx
        cmp     bx, sp
        jne     endjmp           ; 80186

        jmp     setfne           ; 80286-> .. run the intro
endjmp: jmp     endtxt           ; <-80186 .. quit the proggy
                   
;±±±±±±±±±±±±±±±±± copy font from RAM ±±±±±±±±±±±±±±±±±

setfne: mov     ax, 0013h       ; well, hope this mess works :)
        int     10h             ; whee.. it has worked almost a year already!

        mov     ax, 1124h       ; select 8x16 font
        mov     bl, 00          ; user defined lines
        mov     dl, 12          ; 12 x 16 <= 200
        int     10h

        mov     cx, 'z'-' '+1   ;  !"#$%&'()*+,-./0123456789:;<=>?@ ..
        mov     bx, 16          ; .. ABCDEF..XYZ[\]^_`abcdef..xyz
        mov     al, ' '
onechr: mov     ah, 0eh         ; teletype output
        int     10h
        inc     al
        loop    onechr          ; a char by char output

        mov     di, OFFSET font ; now copy it from vram to ds:[di]
        xor     si, si          ; read from es:[si]
        mov     cx, 'z'-' '+1   ; nmbr of characters..
        shl     cx, 3           ; nbmr of columns (pixels)
horz_l: push    cx
        push    si
        mov     cx, 16          ; vertical size
vert_l: mov     al, es:[si]     ; read byte -> write byte
        cmp     al, 16          ; 16 (black) -> 255
        jne     zero_j
        mov     al, 255         ; now it works better later
zero_j: mov     ds:[di], al     ; write
        inc     di              
        add     si, 320         ; next line
        loop    vert_l          ; jmp for next point in column
horz_c: pop     si
        pop     cx              ; now prepare for next column
        inc     si              ; next column
        cmp     si, 320         ; next row?
        jne     not_nr
        mov     si, 00 + 16*320 ; one 16x8 row downwards
not_nr: cmp     si, 320+ 16*320 ; next row?
        jne     not_nr2
        mov     si, 00 + 32*320 ; one 16x8 row downwards
not_nr2:loop    horz_l

;±±±±±±±±±±±±±±±±±±±±± set modex  ±±±±±±±±±±±±±±±±±±±±±

setmde: mov     ax, 0013h       ; normal mode 13h
        int     10h

        mov     dx, 3c4h
        mov     ax, 604h        ; unchain VGA
        out     dx, ax
        mov     ax, 0f02h       ; all planes 
        out     dx, ax

        mov     dx, 3d4h
        mov     ax, 14h         ; disable dword 
        out     dx, ax
        mov     ax, 0e317h      ; enable byte 
        out     dx, ax

        mov     al, 09
        out     dx, al
        inc     dx              ; y-zoom 8 times
        in      al, dx
        and     al, 0e0h        ; now one byte write to vram equals
        add     al, 07          ; to a 4x4 pixel square..
        out     dx, al

;±±±±±±±±±±±±±±±±±±±± set palette ±±±±±±±±±±±±±±±±±±±±±

        mov     si, OFFSET palette
        mov     cx, 765
        mov     dx, 03c8h
        xor     al, al
        out     dx, al
        inc     dx
set_it: mov     al, ds:[si]
        out     dx, al          ; outta 'em
        inc     si
        loop    set_it

        ; color 255:            ; textcolor

        xor     al, al          ; zero for red
        out     dx, al
        mov     al, cs:infoclr[0]
        out     dx, al
        mov     al, cs:infoclr[1]
        out     dx, al

  ;ÕÕÕÕÕÕÕÕÕ initialize new keyboard routine ÕÕÕÕÕÕÕÕÕÕ
        mov     ds:Q_flag, 00
        call    initint
        mov     word ptr ds:counter, 0000       ; you got this?
        mov     byte ptr ds:texto, 01           ; which text to show?
        mov     byte ptr ds:cflag, 00           ; uu.. sumthing ;-)
        call    text1                           ; copy 1st text to fmask
        jmp     ROUTE                           ; main loop

;±±±±±±±±±±±±±±±±± fmask text routines ±±±±±±±±±±±±±±±±

text1:  mov     si, OFFSET texts
        mov     ax, 0016
        mov     bx, 0017
        mov     cx, 0006
        call    dotext
        mov     ax, 0020        ; YES, why I didn't wrote these to
        mov     bx, 0031        ; a table.. Okey, it's your business to do
        mov     cx, 0005        ; it when you are about to release another
        call    dotext          ; BBS addy using this source code :)
        ret

text2:  lea     si, texts [11]
        mov     ax, 0020
        mov     bx, 0017
        mov     cx, 0005
        call    dotext
        mov     ax, 0016
        mov     bx, 0031
        mov     cx, 0006
        call    dotext
        ret

text3:  lea     si, texts [22]
        mov     ax, 0004
        mov     bx, 0017
        mov     cx, 0006
        call    dotext
        mov     ax, 0028
        mov     bx, 0031
        mov     cx, 0006
        call    dotext
        ret

text4:  lea     si, texts [34]
        mov     ax, 0028
        mov     bx, 0017
        mov     cx, 0003
        call    dotext
        mov     ax, 0020
        mov     bx, 0031
        mov     cx, 0005
        call    dotext
        ret

text5:  lea     si, texts [42]
        mov     ax, 0004
        mov     bx, 0024
        mov     cx, 0009
        call    dotext
        ret

text6:  lea     si, texts [51]
        mov     ax, 0020
        mov     bx, 0017
        mov     cx, 0005
        call    dotext
        mov     ax, 0020
        mov     bx, 0031
        mov     cx, 0005
        call    dotext
        ret

text7:  lea     si, texts [61]
        mov     ax, 0008
        mov     bx, 0024
        mov     cx, 0008
        call    dotext
        ret

dotext: xor     dh, dh
@tl1:   mov     dl, ds:[si]
        sub     dl, ' '
        call    makechr
        inc     si
        add     ax, 0008
        dec     cx
        jnz     @tl1
        ret

clrmsk: mov     si, OFFSET fmask
        add     si, 17*80 
        mov     di, OFFSET frame
        add     di, 17*80*2
        mov     cx, 30*80
        mov     ax, 00FEh
        mov     bx, 00FFh       ; you can figure most of these by reading
clr_lp: cmp     ds:[si], bl     ; the variable names..
        jne     NoNeed
        mov     ds:[di], ax
        mov     ds:[si], bh
NoNeed: inc     si
        add     di, 2
        dec     cx
        jnz     clr_lp
        ret

;±±±±±±±±±±±±±±±±±±±±± the loop. ±±±±±±±±±±±±±±±±±±±±±± 

ROUTE:  mov     dx, 3dah
    wa: in      al, dx
        test    al, 8           ; vertical retrace
        jnz     wa
    re: in      al, dx
        test    al, 8
        jz      re

  ;ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ copy to vram ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ
        mov     si, OFFSET frame
        xor     di, di
        mov     bx, OFFSET fmask

        mov     cx, 50*40       ; only 50 lines are visible (50*4 = 200)
write:  mov     dl, ds:[si]
        mov     dh, ds:[si+2]
        or      dx, ds:[bx]
        mov     es:[di], dx     ; word output costs less
        add     si, 4
        add     di, 2
        add     bx, 2
        dec     cx
        jnz     write

        mov     cx, 4400        ; transform the buffer (expect the last line)
        mov     di, OFFSET frame
        xor     ax, ax

build1: mov     al, ds:[di+158] ; simple logic..  . n . . . (n=new pixel)
        add     ax, ds:[di+160] ;               . c c c .   (c=count these)
        add     ax, ds:[di+162] ;             . . . c .     (.=other pixels)
        add     ax, ds:[di+320]
        shr     ax, 2           ; divide by four
        sub     al, 4           ; subtract some colors..
        jnc     build2
        xor     al, al

build2: mov     ds:[di], al     ; save it..
next:   add     di, 2
        dec     cx
        jnz     build1

  ;ÕÕÕÕÕÕÕÕÕÕ random new values for line 56. ÕÕÕÕÕÕÕÕÕÕ
        mov     cx, 80
        lea     di, frame[4400*2]
  ;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ random routine ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
randor: push    cx
        mov     ax, ds:[seed1]
        mov     bx, ds:seed2
        mov     cx, ds:[seed3]  ; it works.. after all :)
        mov     dx, ds:seed4
        add     ax, bx
        add     ax, cx
        add     ax, dx
        mov     ds:seed1, bx
        mov     ds:seed2, dx
        mov     ds:seed3, cx
        mov     ds:seed4, ax
        pop     cx
  ;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ end-of-randor. ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
        cmp     ax, dx
        jl      takelo
        mov     al, ah
takelo: shr     al, 6           ; now al is either 00 or 01
        cmp     al, 01
        jl      fine
        mov     al, 254
fine:   mov     ds:[di], al
        mov     ds:[di-160], al
nochng: add     di, 2
        dec     cx
        jnz     randor

  ;ÕÕÕÕÕÕÕÕÕ time to check keyb flag & counter ÕÕÕÕÕÕÕÕ
keybbi: inc     word ptr ds:counter
        cmp     word ptr ds:counter, 0045
        jne     chk_key
        mov     word ptr ds:counter, 0000
        inc     byte ptr ds:cflag
        cmp     byte ptr ds:cflag, 03
        jne     tst04
        call    clrmsk
        jmp     chk_key
tst04:  cmp     byte ptr ds:cflag, 04
        jne     chk_key
        mov     byte ptr ds:cflag, 00
        inc     byte ptr ds:texto
        mov     al, ds:texto
tst1:   cmp     al, 01
        jne     tst2
        call    text1
        jmp     chk_key
tst2:   cmp     al, 02
        jne     tst3
        call    text2
        jmp     chk_key         ; uh.. this is it. the "where no man
tst3:   cmp     al, 03          ; has gone before" zone... you might
        jne     tst4            ; understand these, i don't have time
        call    text3           ; to describe each of them.
        jmp     chk_key         ; basically these "tstx" lines check
tst4:   cmp     al, 04          ; whether or not to write a new text..
        jne     tst5
        call    text4           ; tables rules, it'd save some bytes..
        jmp     chk_key
tst5:   cmp     al, 05
        jne     tst6
        call    text5
        jmp     chk_key
tst6:   cmp     al, 06
        jne     tst7
        call    text6
        jmp     chk_key
tst7:   cmp     al, 07
        jne     tstrest
        call    text7
        jmp     chk_key
tstrest:cmp     al, 08
        jne     chk_key
        mov     byte ptr ds:texto, 00

chk_key:cmp     ds:Q_flag, 01   ; esc pressed?
        je      quitto
        jmp     ROUTE

;±±±±±±±±±±±±±±±±±±±± back to dos ±±±±±±±±±±±±±±±±±±±±±

quitto: call    deinitint       ; return the original irq handler

endtxt: mov     ax, 0003h       ; text mode
        int     10h
                                
        push    0b800h          ; write some last notes, color code support
        pop     es
        xor     di, di
        mov     ax, di          ; al = character, ah = attribute
        mov     si, OFFSET tsau
lst_lp: lodsb
        cmp     al, 31
        jae     tst_nd          ; this writer mainly derived from starport
        mov     ah, al          ; intro (1993b) by Psi
        jmp     lst_lp
tst_nd: jz      termin          
        stosw
        jmp     lst_lp

termin: mov     ax, 4c00h       ; terminate 
        int     21h


initint PROC NEAR
        push    es
        xor     ax, ax
        mov     es, ax
	mov	ax, es:[9*4]
        mov     bx, es:[9*4+2]  ; no 386+ code, no 32-bit registers!
	mov	ds:old9_1, ax
        mov     ds:old9_2, bx
        mov     ax, OFFSET intti9
        mov     bx, cs
        jmp     set
deinitint:                      ; combined init and uninit
        push    es
        xor     ax, ax
        mov     es, ax
        mov     ax, ds:old9_1
        mov     bx, ds:old9_2
set:    cli
        mov     es:[9*4], ax
        mov     es:[9*4+2], bx
        sti
        pop     es
        ret
initint ENDP


intti9	PROC FAR                ; keyboard interrupt
	push	ax
	in      al, 60h
        cmp     al, 01h         ; esc pressed?
        jne     notESc
        mov     ds:Q_flag, 01
notESc: in      al, 61h
        mov     ah, al
        or      al, 80h
        out     61h, al
        xchg    ah, al
        out     61h, al
        mov	al, 20h
	out	20h, al         ; clear call
        pop	ax
	iret                    
intti9	ENDP                    
                                
                                
makechr PROC NEAR               ; build a character
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        mov     si, OFFSET font
        shl     dx, 7           ; * 128
        add     si, dx          ; ds:[si], offset to chr data
        mov     di, OFFSET fmask
        mov     cx, bx
        shl     cx, 6           ; * 64 +
        shl     bx, 4           ; * 16 = * 80
        add     di, cx
        add     di, bx
        add     di, ax          ; ds:[di], offset to frame
        mov     cx, 8
copyl:  push    cx
        push    di
        mov     cx, 8
copyl1: mov     ax, ds:[si]
        mov     ds:[di], al
        mov     ds:[di+80], ah 
        add     di, 160
        add     si, 2
        loop    copyl1
        pop     di
        inc     di
        pop     cx
        loop    copyl
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
makechr ENDP                    
                                
                                ; es = ds !
vakioFi PROC NEAR               ; strt = bx  count = cx  arvo = al
        lea     di, cs:palette[bx]
fillit: stosb
        add     di, 2           ; jmp the other two values (rgb)
        loop    fillit
        ret                     
vakioFi ENDP                    
                                ; es = ds !
                                ; strt = bx  count = cx  arvo = ax
doLiuku PROC NEAR               ; ince = dx
        lea     di, cs:palette[bx]            
doit:   push    ax
        shr     ax, 6
        stosb
        add     di, 2
        pop     ax              ; these are derived from my previous
        add     ax, dx          ; pascal routines, that's why all those
        loop    doit            ; variable alike names (count,arvo..)
        ret
doLiuku ENDP

;€€€€€€€€€€€€€€€€€€€€€ data site €€€€€€€€€€€€€€€€€€€€€€

seed1   dw      036c2h
seed2   dw      0a43dh
seed3   dw      0f21ch          ; random number seeds
seed4   dw      01c34h

        ; Black     ≥ 0 ∫ DarkGray     ≥  8
        ; Blue      ≥ 1 ∫ LightBlue    ≥  9
        ; Green     ≥ 2 ∫ LightGreen   ≥ 10  <- table from Turbo Pascal's
        ; Cyan      ≥ 3 ∫ LightCyan    ≥ 11     on-line help
        ; Red       ≥ 4 ∫ LightRed     ≥ 12
        ; Magenta   ≥ 5 ∫ LightMagenta ≥ 13
        ; Brown     ≥ 6 ∫ Yellow       ≥ 14  <- color codes
        ; LightGray ≥ 7 ∫ White        ≥ 15

tsau    LABEL BYTE
        db      15, 'Astral Plane'
        db      08, ' ƒƒƒ '
        db      11, '(973) 733148'      ; 31=end, <31=attribute, >31=text
        db      08, ' ƒƒƒ '
        db      11, '24h  v.32bis'
        db      08, ' ƒƒƒ '
        db      09, 'SPO WHQ'
        db      31

        ; currently supported letters:
        ;  !"#$%&'()*+,-./0123456789:;<=>?@ABCDEF..XYZ[\]^_`abcdef..xyz

        ; the "v" marks are hardcoded to the code..

        ;        v     v    v    v     v     v     v  v    v
texts   db      'AstralPlane(973)733148-> SPOBBS <-24H14.4kPrgrmming'
        ;        v    v    v
        db      'DemosGamesAnd more'

infoclr db      25, 62          ; text color, bright blue

        ; hack these out :) (not a hard task..)
        ; (strt mod 3) = {0..2} = {R,G,B}
paldata dw      0021, 0017, 0000, 0128, 0072, 0032, 2048, 0059
        dw      0115, 0101, 0000, 0032, 0418, 0053, 3328, 0013
        dw      0005, 0007, 0384, 0042, 0026, 0016, 0640, 0ffd6h
        dw      0563, 0069, 0000, 0059
        dw      0168, 0199, 0063, 0577, 0063, 0063

counter dw      0000
cflag   db      00
texto   db      00                      ; run postproc and get rid of
frame   dw      4480    dup (0000)      ; these unused zeros..
fmask   db      4000    dup (00)
palette db      768     dup (00)
font    db      91*8*16 dup (00)
old9_1	dw	0000
old9_2  dw      0000
Q_flag  db      00

code    ENDS
        END start

 comment /*******************************************************************

     Contact us!

     By mail  :  Johannes H. Heinonen
                 Touvitie 1
                 FIN-80160 Joensuu

     E-mail   :  wihannes@pcb.mpoli.fi  ( at least until summer/autumn -95 )

     By modem :  Astral Plane BBS
                 +358-(9)73-733148      
                 1200-14400bps, 24H

 ***************************************************************************/
