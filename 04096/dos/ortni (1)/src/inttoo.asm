
;                       . I N T R O .
;                       =============
;
;                Copyright (c) Yzi/Fit 1994
;
;     Coded especially for the Asm'94 4kB intro compo.
;
;  This source is 100% Public Domain. You may freely spread these
;  files unchanged. You can also use the ideas and techniques used
;  in this source, yet I am not responsible for any damage caused
;  to anything or anybody dealing with it.
;
;  I haven't done anything fantastic, just a scrolly and stuff,
;  but you may discover something new, if you're not very
;  experienced in coding. For instance the TWGA init, the smart
;  buffering and the write mode 1 are very useful.
;
;  Some of the comments are quite obvious, but I didn't bother
;  to remove them.
;
;  If you encounter problems, you can throw me a letter:
;
;         Yrj” Fager
;         Vuorenp„„ntie
;         38210 Peipohja
;         Finland

.286
LOCALS                          ;local labels on (@name)

mittari = 0                     ;change to 1 to see the raster time meter
wide_text = 1

sbuflen         equ     22      ;the width of the scrolly (8-pixel columns)
sbufseg         equ     09f00h  ;the segment address of the scroll buffer
palseg          equ     09e00h  ;the segment address of the palette buffer
palspeed        equ     5       ;speed of the color cycling
stars           equ     25
maxz            equ     240     ;the maximum z coordinate of the stars
kuvaseg         equ     07000h  ;here's the piccy (I hope)
;kuvaofs         equ     0000h
zoomprocseg     equ     08000h
zoomprocofs     equ     0000h
bbufseg         equ     0aeb8h  ;the balls are drawn from bbuf to screen
startline       equ     74      ;the 'top' of the scrolly (64)
leftmostpoint   equ     28      ;the offset from left to draw the scrolly
dotyspace       equ     12      ;the dots are this far from each other
sinexadd        equ     2       ;the speed of the sinewobble
sineyadd        equ     1
sinexright      equ     1       ;amount to shr the wobble
sineyright      equ     2       ;the smaller the number, the wider the wobble
sinexroughness  equ     1       ;the sinecounters are added this much
sineyroughness  equ     9       ;inside the loop
fullcircle      equ     127     ;the sine table has 128 values
_lodsb          equ     0ach    ;lodsb opcode
dclev           equ     320

code    segment para public 'CODE'
        assume  cs:code

main    proc    near

        jmp     alku                    ;the data part has to be skipped

; and here's the data and variables...

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ table for the 'grafix' ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        ;  This is the pixel-form

        ; plane  0  1  2  3  ³0  1  2  3 ³
        ;                    ³           ³   line
        ;db      00,00,24,27,³27,24,00,00ÃÄ¿  0
        ;     ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        ;db   ÀÄ 00,26,29,31,³31,27,26,00³    1
        ;db      24,29,31,27,³27,27,27,24³    2
        ;db      27,31,27,27,³27,27,25,27³    3
        ;db      27,31,27,27,³27,26,22,27³    4
        ;db      24,27,27,27,³26,22,25,24³    5
        ;db      00,26,27,25,³22,25,26,00³    6
        ;db      00,00,24,27,³27,24,00,00³    7
        ;    byte boundary ÄÄÙ in vram  ÄÙ

        ;  This is how the bytes are stored in video memory (chain-4)
        ;  line 0      1      2      3      4      5      6      7
        ;                                                              plane
ballo   db      00,27, 00,31, 24,27, 27,27, 27,27, 24,26, 00,22, 00,27 ; 0
        db      00,24, 26,27, 29,27, 31,27, 31,26, 27,22, 26,25, 00,24 ; 1
        db      24,00, 29,26, 31,27, 27,25, 27,22, 27,25, 27,26, 24,00 ; 2
        db      27,00, 31,00, 27,24, 27,27, 27,27, 27,24, 25,00, 27,00 ; 3

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ table for SINE ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;   Here are the integer values of sine (and cosine) * 124,
;   Note that the circle is not divided into 360, but 128
;   degrees. This is because there is the 4kB limit and
;   we don't need that much accuracy. Otherweise I would
;   have used a 32-bit table... (Why 124? Because the scrolly
;   has to be shrunk a little to make it fit vertically.)

sini    db      0,5,11,16,21,27,32,37,42,47
        db      52,57,61,66,70,74,78,82,85,88
        db      91,94,97,99,102,104,105,107
        db      108,109,109,110,110,110,109
        db      109,108,107,105,104,102,99,97
        db      94,91,88,85,82,78,74,70,66,61
        db      57,52,47,42,37,32,27,21,16,11
        db      5,0,-5,-11,-16,-21,-27,-32,-37
        db      -42,-47,-52,-57,-61,-66,-70,-74
        db      -78,-82,-85,-88,-91,-94,-97,-99
        db      -102,-104,-105,-107,-108,-109,-109
        db      -110,-110,-110,-109,-109,-108,-107
        db      -105,-104,-102,-99,-97,-94,-91,-88
        db      -85,-82,-78,-74,-70,-66,-61,-57
        db      -52,-47,-42,-37,-32,-27,-21,-16,-11,-5

grey    db      2,4,8,9,10,11,2,18,20,22,25,28,29,30,31,32

; ÄÄÄÄÄÄÄÄÄÄÄÄÄ the scroll text ÄÄÄÄÄÄÄÄÄÄÄÄÄ

stext   db      ' Hi there! This is No Name''s contribution to the Asm''94'
        db      ' 4kB intro compo! But nobody likes scrollers, so --->   ', 0

;These text lines are 40 chars each:

ots0    db      '                                         /'
        db      'The 4-channel music compi is running and/'
        db      'I already know, who I''m gonna vote for./'
        db      '(That''s myself, of course!)Well actually/'
        db      'there is nothing important to say here,/'
        db      'I just have to get a screen full of text/'
        db      'it must be the same for all coders,ithnk/'
        db      'Who hasn''t been in situation like this?/'
        db      'This text was just meant to be text.../'
        db      'Text among all the texts in the world.../'
        db      '...but because this is a 4kB compo, I''ll/'
        db      'make this 5kB small. After that it can b/'
        db      'packed with PKLite,  a brilliant program/'
        db      'by Phil Katz. Lotsamucha terrveissii JU!/'
        db      'Here is binary: 001010010101111010100100/'
        db      'But unfortunately most people will never/'
        db      'read this text, because it is visible/'
        db      'only little time. Anyhow, I want to send/'
        db      'grtx to Sakke, who is sitting here next/'
        db      'to me. I think he gets so seldom greets/'
        db      '(he''s in no group) so this is a fine/'
        db      'way to make people happy and so./'
        db      'Some more text is always welcome. Joo./'
        db      'This is the last line, I bromice. BBBB/'
        db      '                                      $'
ots1    db      'NoName$'
ots2    db      'presents:$'
ots3    db      'ORTNI$'

; ÄÄÄÄÄÄÄÄÄÄÄÄÄ CRTC registers ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

crtcregs        equ     10      ;number of regs to write

;The CRTC is programmed to create a 60Hz chain-4-mode with 320x240 resolution.
crtcr    dw      00d06h, 03e07h, 04109h, 0ea10h, 0ac11h
         dw      0df12h, 00014h, 0e715h, 00616h, 0e317h

; ÄÄÄÄÄÄÄÄÄÄÄÄÄ pre-initia1lized variables ÄÄÄÄÄÄÄÄÄÄÄÄ

        cursofs         dw      80*140           ;the first page
        cursofs2        dw      80*400          ;the second page
        framecnt        db      0
        starofs         dw      0
        starofs2        dw      stars*2

        textcnt         dw      0
        text8cnt        db      8
        curcharofs      dw      0fa6eh
        sbufofs         dw      0

        sineofsy        dw      0
        _sineofsy       dw      0
        sineofsx        dw      0
        _sineofsx       dw      0
        prevsinxadd     dw      0
        prevsinyadd     dw      0
        sinexcnt        dw      0
        sineycnt        dw      0

        dc_color        db      32
        ds_color        db      32

        r               dw      01400h          ;These are the counters
        dr              dw      -591            ;for the color cycling.
        g               dw      00300h          ;The hibytes are taken
        dg              dw      144             ;as the actual color,
        b               dw      01000h          ;the lobytes are used
        dbl             dw      476             ;as a "decimal"-part.
        paldelay        dw      palspeed

        savecx          dw      0
        savecx2         dw      0
        savecx3         dw      0
        savebx          dw      0

        _cnt            dw      0
        zoomfactor      dw      0
        zdnxk           dw      0
        zdnyk           dw      0

; these variables are for the zooming procedure:

        graffaseg       dw      ?       ;es is preserved here
        sx0             dw      0
        sy0             dw      0
        sx1             dw      319
        sy1             dw      199
        tx0             dw      0
        ty0             dw      0
        tx1             dw      319
        ty1             dw      199
        erox            dw      ?
        eroy            dw      ?
        erosx           dw      ?
        erosy           dw      ?
        laskuri         dw      ?
        scrofs          dw      ?
        kuvofs          dw      ?

; the following add_procedures are written especially to make
; the program smaller by moving here some code common to the calling events.

add_sinexcnt    proc near
        add     sinexcnt, sinexroughness
        and     sinexcnt, fullcircle            ;to prevent overflow
        mov     si, sinexcnt
        mov     al, sini[si]
        sar     al, sinexright
        mov     ah, 80
        imul    ah
        sub     di, prevsinxadd
        ret
add_sinexcnt    endp

add_sineycnt    proc near
        add     sineycnt, sineyroughness
        and     sineycnt, fullcircle            ;to prevent overflow
        mov     si, sineycnt
        mov     al, sini[si]
        cbw
        sub     di, prevsinyadd
        ret
add_sineycnt    endp

set_write_mode  proc near       ;ah=mode
        mov     dx, 03ceh
        mov     al, 5
        out     dx, al
        inc     dx
        in      al, dx
        and     al, 0fch
        add     al, ah
        out     dx, al
        ret
set_write_mode  endp

mask_all_planes proc near
        mov     dx, 03c4h               ;3c4/3c5 reg 2: select write plane
        mov     ax, 0f02h
        out     dx, ax                  ;select all planes
        ret
mask_all_planes endp

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Z O O M ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

zoom    proc    near
        mov     ax, es
        mov     graffaseg, ax

        mov     ax, zoomprocseg
        mov     es, ax
        mov     di, zoomprocofs

          ;lasketaan koon pystymyytos
        mov     ax, sy1                 ;erosy := s1 - s0
        sub     ax, sy0
        inc     ax
        mov     erosy, ax
        mov     ax, ty1                 ;eroy := t1 - t0
        sub     ax, ty0
        inc     ax
        mov     eroy, ax

        cmp     ax, erosy
        jg      @pystysuurennos

                ;pystypienenn”s

        mov     al, _lodsb
        mov     ah, 26h     ;ES:
        xor     bx, bx
        cld
        mov     cx, erosy
        mov     dx, cx
@yl:    add     bx, eroy
        cmp     bx, dx
        jb      @ohi
        sub     bx, dx
        mov     es:[di], ah ;es:
        inc     di
        mov     si, 0588h  ;mov [di], al
        mov     es:[di], si
        add     di, 2
        mov     si, 0cf01h  ;add di, cx
        mov     es:[di], si
        add     di, 2
@ohi:   stosb       ;lodsb
        loop    @yl
        mov     al, 0cbh ;retf
        mov     es:[di], al
         ;...valmis
        jmp     @vaakajutut

@pystysuurennos:

        mov     al, 26h        ;ES:
        mov     ah, _lodsb
        xor     bx, bx
        cld
        mov     cx, eroy
        mov     dx, cx
@psyl:  add     bx, erosy
        cmp     bx, dx
        jb      @psohi
        sub     bx, dx
        mov     es:[di], ah     ;lodsb
        inc     di
@psohi: stosb   ;es:
        mov     si, 0588h  ;mov [di], al
        mov     es:[di], si
        add     di, 2
        mov     si, 0cf01h  ;add di, cx
        mov     es:[di], si
        add     di, 2
        loop    @psyl
        mov     al, 0cbh ;retf
        mov     es:[di], al
         ;...valmis

@vaakajutut:

        mov     ax, 320
        mul     ty0
        add     ax, tx0
        mov     scrofs, ax
        mov     ax, 200         ;huom! kuva on toisin p„in
        mul     sx0
;        add     ax, kuvaofs
        add     ax, sy0
        mov     kuvofs, ax

        mov     dx, 03c4h
        mov     al, 2
        out     dx, al
        inc     dx

        mov     ax, graffaseg
        mov     es, ax
        mov     ax, kuvaseg
        mov     ds, ax

          ;tutkitaan, onko suurennos vai pienenn”s
        mov     ax, sx1
        sub     ax, sx0
        inc     ax
        mov     erosx, ax
        mov     ax, tx1
        sub     ax, tx0
        inc     ax
        mov     erox, ax
        xor     bp, bp
        cmp     erosx, ax
        jl      @vaakasuurennos

              ;vaakapienenn”s
        mov     ax, erosx
        mov     laskuri, ax
        mov     bx, sx0
@xloop:
        inc     bx
        and     bx,07fh
        add     bp, erox
        cmp     bp, erosx
        jb      @ohi2
        mov     si, kuvofs
        mov     di, scrofs
        mov     cx, di
        shr     di, 2
        and     cx, 3
        mov     al, 1
        shl     al, cl
        out     dx, al

        mov     cx,80
        mov     al,byte ptr sini[bx]
        sar     al,1
        sar     al,1
        imul    cl
        add     di, ax

        lodsb

  ;The following creates a FAR CALL to 8000h:0000h
        db      9ah             ;far call opcode
        dw      zoomprocofs
        dw      zoomprocseg

        inc     scrofs
@ohi2:  add     kuvofs, 200
        dec     laskuri
        jnz     @xloop
        jmp     @loppu

@vaakasuurennos:
        mov     ax, erox
        mov     laskuri, ax
        mov     bx,sx0

@vsxlp: inc     bx
        and     bx,07fh

        add     bp, erosx
        cmp     bp, erox
        jb      @vsohi2
        
        add     kuvofs, 200
        sub     bp, erox
@vsohi2:mov     si, kuvofs
        mov     di, scrofs
        mov     cx, di
        shr     di, 2
        and     cx, 3
        mov     al, 1
        shl     al, cl
        out     dx, al

        mov     cx, 80
        mov     al,byte ptr sini[bx]
        sar     al,1
        sar     al,1
        imul    cl
        add     di, ax

        lodsb

  ;The following creates a FAR CALL to 8000h:0000h
        db      9ah             ;far call opcode
        dw      zoomprocofs
        dw      zoomprocseg

        inc     scrofs
        dec     laskuri
        jnz     @vsxlp
@loppu:
        ret
zoom    endp

kerro_ja_jaa    proc    near
        mul     byte ptr zoomfactor     ;zoomfactor 0..100
        mov     cl, 100
        div     cl                      ;0<ax<=160
        xor     ah, ah                  ;ah contains the remainder
        ret
kerro_ja_jaa    endp

zoom_up proc near       ;zooms "up" = suurentaa

        mov     ax, 159
        call    kerro_ja_jaa

        mov     sx0, 159
        mov     sx1, 160
        sub     sx0, ax
        add     sx1, ax

        ;the zoomfactor can be used straight to the y-coordinate

        mov     sy0, 99
        mov     sy1, 100
        mov     bx, zoomfactor
        dec     bx
        sub     sy0, bx
        add     sy1, bx

        call    zoom
        ret
zoom_up endp

zoom_dn proc near       ;zooms "down" = pienent„„
                        ;and remains the shape of the piccy

        mov     ax, zdnxk
        call    kerro_ja_jaa
        mov     tx0, 159
        mov     tx1, 160
        sub     tx0, ax
        add     tx1, ax

        ;the zoomfactor can be used straight to the y-coordinate

        mov     ax, zdnyk
        call    kerro_ja_jaa
        mov     ty0, 99
        mov     ty1, 100
        sub     ty0, ax
        add     ty1, ax

        call    zoom
        ret
zoom_dn endp

set_palette     proc near
        mov     ax, palseg
        mov     ds, ax
        mov     es, ax
        mov     si, 16*3
        mov     dx, 03c8h               ;set number of the first color (16)
        mov     al, 16
        out     dx, al
        inc     dx                      ;dx:=3c9
        mov     cx, 3*8*16
        cmp     _cnt, 1234h
        je      nousetti
        rep     outsb                   ;set the palette
nousetti:
        mov     di, 16*3
        mov     si, 32*3
        mov     cx, 112*3
        rep     movsb
        mov     di, 128*3
        sub     si, si
        mov     cx, 15
@l:     mov     al, byte ptr [r+1]
        mov     ah, byte ptr grey[si]
        add     al, ah
        stosb
        mov     al, byte ptr [g+1]
        add     al, ah
        stosb
        mov     al, byte ptr [b+1]
        add     al, ah
        stosb
        inc     si
        loop    @l
        mov     al, 60
        stosb
        stosb
        stosb
        sub     si, si
;--- take a look at this: r, g, & b are handled in the same loop with [+index]
@add_lp:mov     ax, word ptr [dr+si]    ;col:=col+dcol
        add     word ptr [r+si], ax
        test    byte ptr [r+si+1], 0f0h   ;test, if overflown (<0 or >31)
        jnz     @red_of
        jmp     @red_ok
@red_of:xor     ax, 0ffffh              ;turn dcol's sign
        add     word ptr [r+si], ax     ;and add it two times
        add     word ptr [r+si], ax     ;to "bounce" off the limit
        mov     word ptr [dr+si], ax    ;store the new value to the dcolor
@red_ok:add     si, 4
        cmp     si, 12
        jb      @add_lp
        mov     ax, cs                  ;restore ds
        mov     ds, ax
        ret
set_palette     endp

draw_ball       proc near               ;draw ball from ds:si to es:di
        mov     dx, 03c4h
        mov     al, 2
        out     dx, al
        inc     dx                      ;ready to set plane
        mov     cx, 4
pglp:   mov     savecx, cx
        mov     bx, di                  ;preserve di in bx (faster than var.)
        mov     cx, di
        shr     di, 2                   ;set di to be used in byte moves
        and     cx, 3                   ;decide the right plane to write (0..3)
        mov     al, 1                   ;bit 0 = plane 0, bit 1 = plane 1 etc.
        shl     al, cl
        out     dx, al                  ;set the plane
        mov     cx, 8                   ;draw 8 lines
pxylp:  lodsb
        test    al, 255                 ;if the pixel is black, don't draw it
        jz      d_no0
        add     al, ah                  ;add the color
        mov     es:[di], al
d_no0:
        inc     di
        lodsb
        test    al, 255
        jz      d_no1
        add     al, ah
        mov     es:[di], al
d_no1:
        add     di, 2
        loop    pxylp
        mov     cx, savecx

        mov     di, bx                  ;restore di
        inc     di                      ;the next of the four planes
        loop    pglp

        ret
draw_ball       endp

dc_prepare      proc near
        mov     ax, 0ffa6h              ;the font is in 0ffa6eh
        mov     ds, ax
        mov     si, 0eh
        sub     dh, dh                  ;add the offset of the character
        shl     dx, 3                   ;to si, there are eight bytes/char
        add     si, dx                  ;in the font.
        call    mask_all_planes         ;draw four pixels with one stosb
        mov     cx, 8                   ;eight lines
        ret
dc_prepare      endp

cond_inc_al     proc near ;al is increased, if color>0
        ;Here is some self-modifying code:
        db      0ebh                    ;near jmp
        ohi     db      0               ;ohi=2 if we have to skip the "inc al"
        inc     al                      ;this takes two bytes
        ret
cond_inc_al     endp

dc_read_font    proc near
        mov     al, ds:[si]             ;get a line out of the font
        mov     dl, 128
        shr     dl, cl                  ;get bit mask for current horiz.pixel
        and     al, dl                  ;take the corresponding pixel(bit)
        cmp     al, 0
        je      @nocol
        mov     al, dc_color
        mov     ohi, 0
        jmp     @skip
@nocol: mov     ohi, 2
@skip:  ret
dc_read_font    endp

draw_big_char   proc near               ;draws a BIG char with the BIOS font
; --- es:di must point to the destination of the char
; --- dl contains the character
        push    si
        call    dc_prepare
dbc_ylp:
        mov     savecx, cx
        sub     cx, cx
dbc_xlp:
        call    dc_read_font
        mov     savecx2, cx
        mov     cx, 4                   ;dot height is four lines
dbcp_lp:
        mov     es:[di+200], al         ;al=color if pixel on, 0 if no pixel
        mov     es:[di+400], al
        mov     es:[di+600], al
        stosb                           ;go to next line on scrn & put 4th pxl
        call    cond_inc_al             ;inc al if color>0
        loop    dbcp_lp
        mov     cx, savecx2
        add     di, 4*200-4             ;back to line 0, next dot
        inc     cx

        cmp     cx, 8                   ;if all 8 horiz. pixels drawn, end
        jb      dbc_xlp
        mov     cx, savecx
        sub     di, 32*200-4                   ;go to next dot line (4 lines each)
        inc     si                      ;get next 8 horiz.pixels from the font
        inc     dc_color
        loop    dbc_ylp
        pop     si
        mov     ax, cs                  ;restore ds
        mov     ds, ax
        ret
draw_big_char   endp

draw_small_char proc near
        push    si
        call    dc_prepare
dsc_ylp:
        mov     savecx, cx
        sub     cx, cx
dsc_xlp:
        call    dc_read_font
        mov     es:[di], al             ;al=color if pixel on, 0 if no pixel
        call    cond_inc_al             ;inc al, if color>0
        add     di, 200
        inc     cx
        cmp     cx, 8                   ;if all 8 horiz. pixels drawn, end
        jb      dsc_xlp
        mov     cx, savecx
        sub     di, 8*200-1             ;go to next dot line (4 lines each)
        inc     si                      ;get next 8 horiz.pixels from the font
        inc     dc_color
        loop    dsc_ylp
        pop     si
        mov     ax, cs
        mov     ds, ax
        ret
draw_small_char endp

draw_big_str    proc near
; --- draws a string pointed by ds:si ending with a '$'
dbstr_lp:
        mov     dl, ds:[si]
        cmp     dl, '$'
        je      dbstr_end
        mov     bx, di
        mov     al, ds_color
        mov     dc_color, al
        call    draw_big_char
        mov     di, bx
        add     di, 32*200      ;toisin p„in!
        inc     si
        jmp     dbstr_lp
dbstr_end:
        ret
draw_big_str    endp

dss_startofs    dw      ?

draw_small_str  proc near
        mov     dss_startofs, di
dsstr_lp:
        mov     dl, ds:[si]
        cmp     dl, '$'
        je      dsstr_end
        cmp     dl, '/'
        je      get_next_line
        mov     bx, di
        mov     al, ds_color
        mov     dc_color, al
        call    draw_small_char
        mov     di, bx
        add     di, 8*200
        inc     si
        jmp     dsstr_lp
dsstr_end:
        ret
get_next_line:
        add     dss_startofs, 8
        mov     di, dss_startofs
        inc     si
        jmp     dsstr_lp
draw_small_str  endp

wait_vr         proc near               ;waits until vertical retrace (dx=3da!)
waitvr: in      al, dx                  ;The bit 3 in port 3dah indicates
        test    al, 8                   ;whether the screen is in a vertical
        jnz     waitvr                  ;blank(bit3=1) or retrace(bit3=0).
        ret
wait_vr         endp

wait_vb         proc near               ;waits until vertical blank (dx=3da!)
waitvb: in      al, dx                  ;wait until bit 3 of port 3dah
        test    al, 8                   ;is set i.e. the screen is
        jz      waitvb                  ;in a vertical blank state.
        ret
wait_vb         endp

vb_wait         proc near               ;waits for [cx] vblanks
        mov     dx, 03dah
vbwlp:  call    wait_vr
        call    wait_vb
        loop    vbwlp
        ret
vb_wait         endp

get_vsync       proc near
; --- set vga start addx & catch vblank
        mov     dx, 03dah               ;CRT Status Register (3da)
        call    wait_vr
        mov     bx, cursofs
        mov     dx, 03d4h
        mov     al, 12                  ;write the screen offset lobyte
        out     dx, al                  ;to 6845 register 12 (at 3d4/3d5)
        inc     dx
        mov     al, bh
        out     dx, al
        dec     dx                      ;and the hibyte to reg. 13
        mov     al, 13
        out     dx, al                  ;!NOTE! This has to be done
        inc     dx                      ;during a vertical retrace to
        mov     al, bl                  ;prevent the awful flash that
        out     dx, al                  ;occurs sometimes.
        mov     dx, 03dah
        call    wait_vb
        ret
get_vsync       endp

togglepreppa    proc    near
        xchg    cursofs2, bx
        mov     cursofs, bx             ;toggle screen offset page1/page2
        mov     ax, cursofs
        shr     ax, 4                   ;Prepare the cursofs
        add     ax, 0a000h              ;to be contained in a segment
        mov     es, ax                  ;register.
        ret
togglepreppa    endp

hugezm1 proc    near
        mov     zoomfactor, 0
zoomlp1:call    get_vsync
        call    togglepreppa
        call    zoom_dn
        inc     zoomfactor
        cmp     zoomfactor, 100
        jb      zoomlp1
        ret
hugezm1 endp

hugezm2 proc    near
        mov     zoomfactor, 100
zoomlp2:call    get_vsync
        call    togglepreppa
        call    zoom_up
        dec     zoomfactor
        jnz     zoomlp2
        ret
hugezm2 endp

clear_kuva      proc    near
        mov     ax, kuvaseg
        mov     es, ax
        xor     di, di
        mov     cx, 65535
        rep     stosb
        ret
clear_kuva      endp

clear_a_segment proc    near
        call    mask_all_planes
        mov     ax, 0a000h
        mov     es, ax
        xor     di, di
        mov     cx, 64000
        rep     stosb
        ret
clear_a_segment endp

alku: ; (= the beginning)

;        cli                             ;don't want interrupts

        cld                             ;direction forwards (si&di increment)

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ the SCROLL BUFFER ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; The dots of the scrolly have to be contained in a buffer.
; We set the buffer to the address 9f00:0000, which ought
; to be unused.
; ! The buffer uses a so-called smart-scrolling-system, which
; doesn't perform any byte moves. The scrolling is done by
; changing the starting offset of the buffer. Therefore the
; length of the buffer has to be twice the size of the screen,
; (i.e. (sbuflen+2) * 2). The drawing is made from offset +2,
; and the clearing from offset 0. Check it out!

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ init physical segment 9 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        mov     ax, 09000h
        mov     es, ax
        sub     di, di
        mov     cx, 65535-stars*4
        rep     stosb

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ TWGA 320x200 init ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; I used a so-called TWeaked vGA mode in this intro. The TWGA
; modes are based on the bios mode 13h, 320x200, 256 colors =
; 8bits/pixel. The difference is, however, that the normal
; VGA allows the use of the first 64kB of vram only, though
; there is four times more of it, 256kB (in standard VGA).
; This is because the vram is handled through a 64kB memory
; area in the a-segment. By setting the VGA to a chain-4-mode
; we can access four 64kB-pages. There are also other TWGA
; resolutions than 320x200, for instance 256x200 and 376x480.
; They can be accessed by changing the CRTC registers a little
; more dramatically.

        mov     ax, 013h                ;init the normal mode 13h
        int     010h                    ;via int 10

        mov     dx, 03c4h
        mov     ax, 0604h
        out     dx, ax                  ;a word out puts ah to port dx+1
        mov     ax, 0100h
        out     dx, ax                  ;synchronous reset (unnesseccary?)
        mov     ax, 0300h
        out     dx, ax                  ;start sequencer (unnecessary?)
        mov     dx, 03d4h
        mov     al, 011h
        out     dx, al
        inc     dx
        in      al, dx
        and     al, 07fh
        out     dx, al                  ;unprotect 6845(CRTC) regs. 0-7
        dec     dx

;        mov     ax, 014h                ;This could be used instead
;        out     dx, ax                  ;of the table to set a chain-4
;        mov     ax, 0e317h              ;without any tricks with the
;        out     dx, ax                  ;display rate.

        mov     ax, cs
        mov     ds, ax
        mov     cx, crtcregs
        lea     si, ds:crtcr
        rep     outsw

        call    mask_all_planes
        mov     ax, 0a000h
        sub     di, di
        mov     es, ax
        sub     ax, ax
        mov     cx, 32768               ;write 32kwords, 4 pixels/byte
        rep     stosw                   ;clear video ram

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ MAIN PROGRAM ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

; ÄÄÄÄÄÄÄÄÄÄÄ Draw the title screen ÄÄÄÄÄÄÄÄÄÄÄÄÄ

        mov     ax, cs
        mov     ds, ax

        call    clear_kuva

        xor     di, di
        lea     si, ots1
        call    draw_small_str
        mov     sx0, 0
        mov     sx1, 6*8-1
        mov     sy0, 0
        mov     sy1, 7

        mov     zdnxk, 149
        mov     zdnyk, 89
        call    hugezm1

        mov     cx, 120
        call    vb_wait

        call    clear_a_segment
        call    clear_kuva

        mov     ax, cs
        mov     ds, ax
        lea     si, ots2
        xor     di, di
        call    draw_small_str
        mov     sx0, 0
        mov     sx1, 9*8-1
        mov     sy0, 0
        mov     sy1, 7
        call    hugezm1

        mov     cx, 120
        call    vb_wait

        call    clear_a_segment
        call    clear_kuva

        mov     ax, cs
        mov     ds, ax
        lea     si, ots3
        mov     di, 2205
        call    draw_big_str
        mov     sx0, 0
        mov     sx1, 32*5+9
        mov     sy0, 0
        mov     sy1, 31+11
        call    hugezm1

        mov     cx, 120
        call    vb_wait

        mov     zoomfactor, 94
zmlp:   call    get_vsync
        call    togglepreppa
        call    zoom_dn
        dec     zoomfactor
        cmp     zoomfactor, 11
        ja      zmlp

        call    clear_a_segment

        mov     ax, cs
        mov     ds, ax
        mov     ax, kuvaseg
        mov     es, ax
        xor     di, di
        lea     si, ots0
        call    draw_small_str

        mov     _cnt, 1234h
        mov     savecx, 8
astcl:  call    set_palette
        dec     savecx
        jnz     astcl
        mov     _cnt, ax        ;just hope that ax is not 1234h

;       ÄÄÄÄÄÄÄÄÄÄ Prepare the balls ÄÄÄÄÄÄÄÄÄÄÄÄ
;   Prior to doing any on-screen action the balls have
;   to be copied into a graphics buffer(in vram). They can be
;   drawn quickly from there using the write mode one,
;   that takes full advantage of the VGA internal 32-bit
;   bus. In mode 1 a single byte read actually loads four
;   bytes into the 32-bit bus. The extra bytes (pl.1-3)
;   can also be written to the vram (yet they can't be
;   written elsewhere, because the cpu doesn't "see" them).
;     The write mode 1 has one serious limitation in its
;   use: the moved data has to begin at a four-pixel
;   boundary, because in the chain-four mode the actual
;   pixels are handled through the same byte in memory.
;   Since four-pixel accuracy, however, is not enough
;   for us, we have to do the trick of pre-drawing four
;   different shapes of the same ball, but in different
;   positions. Thus we can draw the ball starting from
;   any horizontal position, yet separate balls cannot
;   reside in the same 4-pixel boundary.

        mov     ax, bbufseg
        mov     es, ax
        mov     savebx, 0
        mov     savecx3, 8
        sub     ah, ah
db_c_lp:mov     savecx2, 4
db_lp:  lea     si, ballo
        mov     di, savebx
        call    draw_ball
        add     savebx, 128+1
        dec     savecx2
        jnz     db_lp
        add     ah, 16
        dec     savecx3
        jnz     db_c_lp

        sub     bx, bx

main_loop1:

if mittari
; --- set raster time meter color (yellow)
        mov     dx, 03c0h               ;3c0 register 49: border color
        mov     al, 49                  ;First out the register number...
        out     dx, al
        mov     al, 1
        out     dx, al                  ;...and then the data byte.
endif

        call    get_vsync
        dec     paldelay
        jnz     dont_set_palette        ;if time to set the palette
        mov     paldelay, palspeed
        call    set_palette
dont_set_palette:

if mittari
; --- reset raster time meter color (black)
        mov     dx, 03c0h
        mov     al, 49
        out     dx, al
        sub     al, al
        out     dx, al
endif
; --- the offset has previously been set into bx (in the end of the loop)
        xchg    cursofs2, bx
        mov     cursofs, bx             ;toggle screen offset page1/page2

        inc     sbufofs                 ;adjust scroll buffer
        cmp     sbufofs, sbuflen+2      ;note: no byte moves!
        jb      dont_zero_sbufofs
        mov     sbufofs, 0
dont_zero_sbufofs:        

; ÄÄÄÄÄÄÄÄÄÄÄ clear the current page ÄÄÄÄÄÄÄÄÄ
        mov     ax, cursofs
        shr     ax, 4                   ;Prepare the cursofs
        add     ax, 0a000h              ;to be contained in a segment
        mov     es, ax                  ;register.

        mov     di, 80*startline+leftmostpoint/4

        sub     ah, ah
        call    set_write_mode
        call    mask_all_planes

        mov     ax, _sineofsx           ;where the counters were on prev. page
        mov     sinexcnt, ax
        mov     prevsinxadd, 0
        mov     ax, sbufseg
        mov     ds, ax
        mov     bx, sbufofs
        mov     cx, sbuflen             ;clear cx vertical lines

horiz_clr_loop:
        mov     savecx2, cx

        mov     prevsinyadd, 0          ;the y-wobble counters have to
        mov     ax, _sineofsy           ;be reset every horizontal dot
        mov     sineycnt, ax

        call    add_sinexcnt
        mov     prevsinxadd, ax
        add     di, ax

        mov     cx, 8                   ;clear 8 dots vertically
vert_clr_loop:
        mov     savecx, cx

        call    add_sineycnt
        sar     ax, sineyright+2
        mov     prevsinyadd, ax
        add     di, ax
        mov     savebx, bx

        mov     al, ds:[bx]             ;check, if there was a dot
        test    al, 255                 ;in here to be cleared
        jz      dont_clear_dot

        sub     ax, ax
        mov     dx, di                  ;save di
        mov     bx, 78
        mov     cx, 8
clr_lp: stosw                           ;read&write four pixels (write mode 1!)
        mov     es:[di], al             ;write four pixels
        add     di, bx                  ;goto next line
        loop    clr_lp
        mov     di, dx                  ;restore di
dont_clear_dot:
        mov     bx, savebx
        add     bx, (sbuflen+2)*2       ;goto next line in scroll buffer
        add     di, dotyspace*80        ;ten lines down
        mov     cx, savecx
        loop    vert_clr_loop

        sub     di, 8*dotyspace*80-3    ;back to the first line, next column
        sub     di, prevsinyadd         ;"unwobble"
        sub     bx, 2*8*(sbuflen+2)-1   ;set bx to start of next vert. line
        mov     cx, savecx2
        loop    horiz_clr_loop

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ adjust counters ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        mov     ax, sineofsx
        mov     _sineofsx, ax
        add     sineofsx, sinexadd
        and     sineofsx, fullcircle

        mov     ax, sineofsy
        mov     _sineofsy, ax
        add     sineofsy, sineyadd
        and     sineofsy, fullcircle

if wide_text
        inc     framecnt                ;make the font 16-pixels wide
        test    framecnt, 1             ;by writing every pixel twice
        jz      not_new_char
endif

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ adjust scroll text ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        dec     text8cnt                ;adjust the x-offset inside char (7..0)
        jnz     not_new_char
        inc     textcnt                 ;get next character
        mov     bx, textcnt
        mov     al, byte ptr stext[bx]  ;take char out of the scroll text
        cmp     al, 32                  ;if char=' '
        jg      not_space
        sub     text8cnt, 2             ;it was a space, reduce its width...
not_space:
        add     text8cnt, 8
        inc     framecnt                ;decrease the space btwn chars to 1 pxl
        test    al, 255                 ;check if all bits zero, which
        jnz     not_eostext             ;means end-of-scrolly and wrap
        jmp     zoompart
;        mov     al, byte ptr stext[0]   ;get new character also in this case
not_eostext: ; make a pointer to the bios font
        sub     ah, ah
        shl     ax, 3                   ;one character takes eight bytes
        add     ax, 0fa6eh              ;the font we use resides at f000:fa6e
        mov     curcharofs, ax          ;save the offset
not_new_char:

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ draw the font into the scroll buffer ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        mov     si, curcharofs          ;set ds:si to the font
        mov     ax, 0f000h
        mov     ds, ax
        mov     ax, sbufseg             ;and es:di to the scroll buffer
        mov     es, ax
        mov     di, sbufofs
        mov     bl, 8                   ;use bl as counter
        mov     bh, 1
        mov     cl, text8cnt            ;cl is needed here
        shl     bh, cl                  ;get the bit mask to bh
draw_char_loop:
        lodsb                           ;get an x-line from the font
        and     al, bh                  ;check the bit and
        shr     al, cl                  ;shift it to bit 0: al=1, if pixel on
        mov     es:[di], al             ;write the byte to the buffer
        add     di, sbuflen+2           ;!this is how the smart buffering works
        mov     es:[di], al             ;the new bytes are written in two places
        add     di, sbuflen+2           ;go to next vert. line in the buffer
        dec     bl                      ;zero flag set when zero(!)
        jnz     draw_char_loop          ;else jump

; ÄÄÄÄÄÄÄÄÄÄÄ draw the scroller (8x8 dots) ÄÄÄÄÄÄÄÄÄÄ
;    The names of the sine counters are somehow illogical.
;    The horizontal wobbling is called y-wobble, because it
;    is done in the vertical loop. (Thus, vertical wobbling is
;    called x-wobble.)
        mov     ax, cursofs
        shr     ax, 4                   ;make the screen offset to be contained
        add     ax, 0a000h              ;in a segment register
        mov     es, ax                  ;set es to current page/buffer
        mov     di, 320*startline+leftmostpoint
        mov     prevsinxadd, 0

        mov     ah, 1
        call    set_write_mode          ;write mode 1: read/write 32 bits
        call    mask_all_planes         ;all planes have to be masked first

        mov     bx, sbufofs
        add     bx, 2                   ;ds:bx points to the scroll buffer
        mov     cx, sbuflen             ;draw cx vertical dot lines
        mov     ax, sineofsx
        mov     sinexcnt, ax

horiz_dotloop:
        mov     savecx3, cx

        mov     ax, sineofsy
        mov     sineycnt, ax
        mov     prevsinyadd, 0
        call    add_sinexcnt
        sal     ax, 2                   ;*4 to get the change in pixels
        mov     prevsinxadd, ax
        add     di, ax

        mov     savecx, 0               ;savecx is used to add si

        mov     cx, 8
vert_dotloop:
        mov     savecx2, cx
        call    add_sineycnt
        sar     ax, sineyright
        mov     prevsinyadd, ax
        add     di, ax

        mov     ax, sbufseg             ;ds has to be set every time
        mov     ds, ax
        mov     al, ds:[bx]
        test    al, 255                 ;check, if there is a dot in here
        jz      dont_draw_dot

        mov     savebx, bx              ;preserve bx
        mov     dx, di
        mov     ax, bbufseg
        mov     ds, ax
        mov     si, di
        shr     di, 2
        and     si, 3
        shl     si, 5
        add     si, savecx

        mov     bx, 77                  ;some speed by adding...
        mov     cx, 8
vert_drawloop:
        movsb
        movsb
        movsb
        add     di, bx                  ;...a register instead of an immediate
        loop    vert_drawloop
        mov     di, dx
        mov     bx, savebx

dont_draw_dot:
        add     bx, (sbuflen+2)*2
        add     di, dotyspace*320       ;adjust di for next vert. ball (dot)
        add     savecx, 129
        mov     cx, savecx2
        loop    vert_dotloop

        sub     di, prevsinyadd
        sub     di, 8*dotyspace*320-12
        sub     bx, 2*8*(sbuflen+2)-1   ;set bx to start of next vert. line
        mov     cx, savecx3
        dec     cx
        jz      end_of_dots
        jmp     horiz_dotloop           ;out of range, cannot do loop
end_of_dots:

        in      al, 60h                 ;check if key pressed
        cmp     al, 80h                 ;i.e. if port 60h < 80h
        jb      zoompart

        jmp     main_loop1

zoompart:
        mov     ah, 0
        call    set_write_mode

        mov     _cnt, 1234h             ;prevents palette output
        mov     r, 03400h               ;set a new palette for
        mov     dr, -256                ;the zoom part
        mov     g, 01000h
        mov     dg, -256
        mov     b, 03900h
        mov     dbl, 256

        mov     savecx, 8
zstcl:  call    set_palette
        dec     savecx
        jnz     zstcl

        mov     _cnt, ax                ;ax most probably doesn't contain 1234h
        call    wait_vb
        call    set_palette

        mov     sx0, 0
        mov     sx1, 319
        mov     sy0, 0
        mov     sy1, 199
        mov     zdnxk, 159
        mov     zdnyk, 99
        call    hugezm1

        mov     tx0, 0
        mov     tx1, 319
        mov     ty0, 0
        mov     ty1, 199
        call    hugezm2

wtks:   in      al, 60h                 ;wait 'till keys up
        cmp     al, 80h
        jb      wtks

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ the end ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
the_end:


        mov     ax, 3                   ;set text mode (80x25, color)
        int     010h

;        sti

        mov     ax, 04c00h              ;return to dos via int21, 4c
        int     021h                    ;(Terminate Process with Return Code)

main    endp

code    ends
        end

