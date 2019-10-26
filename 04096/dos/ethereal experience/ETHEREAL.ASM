;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
;  ETHEREAL EXPERIENCE                  ú
;  A new 4k thing...
;  Code: ShadE / AliEN (C) 1997
;  Needs: 286 and VGA card
;  Greetings to anyone who reads this...
;  All this code is dedicated to Marta
;  and to Miguel A. Blanco (Rest in peace)
;ú
;À-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
VGA            EQU 0A000h

jumps

.286           ; Code for the good old 286
.287           ; and its friend the 287
code segment para public 'code'
assume ds:code,cs:code,es:code,ss:code
ORG     100h

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄÄ The program start ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú

MAIN:
        ; adjust memory block size
        call    adjustmem

        ; and get buffers for data and pictures
        call    get_mem

        ; generate "mirror" sinus table
        call    gensinus

        ; generate a texture for smoke plasma
        call    dotexture

        ; calculate Madelbrot set
        call    mandel

        ; set video mode
        mov     al, 13h
        int     10h

        ; initialize random seed
        in      ax, 40h
        mov     [seed], ax
        call    setpal

        ; generate a "random" background
        call    background

        ; get BIOS font address
        call    get_font

        ; set color palette
        call    setpal

        ; display intro stuff
        call    intro

        ; rotate "E" logo
        call    epsilon

        ; make the smoke plasma part
        call    smoke

        ; rotozoom twice (due to angle and register limitations)
        call    rotozoom
        call    rotozoom

        ; draw a new texture for voxel sky
        call    dotexture
        push    ds
        push    es
        mov     es, [backseg]
        mov     ds, [texture]
        mov     cx, 16000
        xor     si, si
        xor     di, di
cpysky:
        lodsw
        or      ax, 8080h
        stosw
        loop    cpysky
        pop     es
        pop     ds


        ; make a new texture for tunnel (instead of using mandelbrot)
        call    newtext
        ; calculate tunnel offsets table (using copro)
        call    calctunnel
        ; and draw it!
        call    drawtunnel

        ; clean vga before palette update
        mov     ax, vga
        call    clear_seg

        ; palette for green voxel
        call    greenpal
        ; voxel to say goodbye
        call    voxel

        ; restore video mode
        mov     ax, 3
        int     10h

        ; print propaganda message
        mov     dx, offset [etherea]
        mov     ah, 9
        int     21h

        ; and that's all folks! :)
        ret

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄÄÄ Draws a background pattern ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns nothing
background    proc

        ; basically a fire, but with a couple modifications

        ;push    es

        ; I'll keep it in a buffer for it'll be used more than once
        mov     es, [backseg]

        xor     di, di

        mov     cx,160
npix:   call    random
        and     ax, 3737h ;55 as maximum color
        stosw
        loop    npix

        mov     cx,64000-320
nmed:
        mov     bl, es:[di-320]

        shr     bl, 1
        mov     dl, bl
        shr     dl, 1
        add     bl, dl
        shr     dl, 1
        add     bl, dl

        mov     bh, es:[di-321]
        add     bh, es:[di-319]
        shr     bh, 4
        add     bl, bh
        ; get a random number...
        call  random

        shr     al, 6
        add     al, bl
        stosb
        loop    nmed

        ;pop     es

        ret

endp    background

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄÄÄ Gets memory for buffers ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns nothing
get_mem proc

        ; nothing to xplain here...

        call    alloc
        mov     [mandelseg], ax

        call    alloc
        mov     [texture], ax

        call    alloc
        mov     [backseg], ax

        call    alloc
        mov     [mixseg], ax

        call    alloc
        mov     [lastbuf], ax

        ret

endp    get_mem

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄ Difumines screen (like fire) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No parameters
;úúúú Returns nothing
difumine        proc

        ; this is just as fire routine
        ; used to get a color "decay"

        xor     ax, ax
        xor     dx, dx
        xor     di, di
        mov     cx, 0ffffh

dift1:
        xor     ax, ax
        mov     al, es:[di+320]
        mov     dl, es:[di-320]
        add     ax, dx
        mov     dl, es:[di+1]
        add     ax, dx
        mov     dl, es:[di-1]
        add     ax, dx
        shr     ax, 2
        stosb
        loop    dift1

        ret

endp    difumine

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄ Copy one buffer onto another if byte!=0 ÄÄÄÄÄ-----úúúú
;úúúú Receives buffers in "dumpsrc" and "dumpdst"
;úúúú Returns nothing
copynozero      proc

        ; this proc is just as a rep movs but just moves
        ; non zero bytes

        push    es
        push    ds

        mov     ds, cs:[dumpsrc]
        mov     es, cs:[dumpdst]

        xor     di, di
        mov     si, di
        mov     cx, 0ffffh
cnzt1:
        lodsb
        or    al, al
        jz    nxtnz
        mov   es:[di], al
nxtnz:  inc   di
        loop  cnzt1

        pop     ds
        pop     es

        ret

endp    copynozero

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄÄÄÄ Introduction ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input params
;úúúú Returns nothing
intro   proc

        ; This thing lets people know what they are watching
        ; doesn't need a lot of comments for var names say it all

        call    restoreback

        mov     es, [mixseg]

        mov     [strx], 16
        mov     [stry], 60
        mov     ax, offset alien
        mov     [string], ax
        mov     [strlen], 9

        CALL    gputs

        mov     [strx], 32
        mov     [stry], 120
        mov     ax, offset presen
        mov     [string], ax
        mov     [strlen], 8

        call    gputs

        call    doubledif

        push    [mixseg]
        pop     [dumpsrc]

        push    [lastbuf]
        pop     [dumpdst]

        call    copynozero

        push    [lastbuf]
        pop     [dumpsrc]
        push    vga
        pop     [dumpdst]

        call    retrace
        call    dumpscr

        call    wait_sec

        call    restoreback

        mov     [strx], 32
        mov     [stry], 30
        mov     ax, offset anew4k
        mov     [string], ax
        mov     [strlen], 8

        call    gputs

        mov     [strx], 48
        mov     [stry], 90
        mov     ax, offset release
        mov     [string], ax
        mov     [strlen], 7

        call    gputs

        mov     [strx], 64
        mov     [stry], 150
        mov     ax, offset called
        mov     [string], ax
        mov     [strlen], 6

        call    gputs

        call    doubledif

        push    [mixseg]
        pop     [dumpsrc]

        push    [lastbuf]
        pop     [dumpdst]

        call    copynozero

        push    [lastbuf]
        pop     [dumpsrc]
        push    vga
        pop     [dumpdst]

        call    retrace
        call    dumpscr

        call    wait_sec

        call    restoreback

        mov     es, [mixseg]

        mov     [strx], 32
        mov     [stry], 60
        mov     ax, offset etherea
        mov     [string], ax
        mov     [strlen], 8

        CALL    gputs

        mov     [strx], 16
        mov     [stry], 120
        mov     ax, offset xperien
        mov     [string], ax
        mov     [strlen], 9

        call    gputs

        call    doubledif

        push    [mixseg]
        pop     [dumpsrc]

        push    [lastbuf]
        pop     [dumpdst]

        call    copynozero

        push    [lastbuf]
        pop     [dumpsrc]
        push    vga
        pop     [dumpdst]

        call    retrace
        call    dumpscr

        call    wait_sec

        ret

endp    intro

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄÄÄÄÄ Rotates Epsilon points ÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input params
;úúúú Returns nothing
rotalogo        proc

        ; this rotates logo vertices and stores results in an array

        ; one of the angles is not incremented
        ; due to technical reasons
        ; but it would work if it were
        add     [Xang], 2
        ;add     [Yang], 0
        add     [Zang], 5

        xor     bx, bx

        mov     bl, [Xang]
        mov     al, stab[bx]
        mov     ah, ctab[bx]
        mov     [s1], al
        mov     [c1], ah

        mov     bl, [Yang]
        mov     al, stab[bx]
        mov     ah, ctab[bx]
        mov     [s2], al
        mov     [c2], ah

        mov     bl, [Zang]
        mov     al, stab[bx]
        mov     ah, ctab[bx]
        mov     [s3], al
        mov     [c3], ah

        mov     CX,14       ; they're 14 points
        xor     bx, bx
newini:
        ; retrieve point coordinates

        mov     ax, e_points[bx]
        mov     [x], ax

        mov     ax, e_points[bx+2]
        mov     [y], ax

        mov     [z], 30
        ;now let's rotate around Y axis

        mov     ax, [x]    ;
        cwd                ;
        imul    [c1]       ;
        mov     [Xxt], ax   ;
                          ;  xt=(x*c1)-(z*s1)
        mov     ax, [z]    ;
        cwd                ;
        imul    [s1]       ;
        sub     [Xxt], ax   ;


        mov     ax, [x]    ;
        cwd                ;
        imul    [s1]       ;
        mov     [Zzt], ax   ;
                          ;  zt=(x*s1)+(z*c1)
        mov     ax, [z]    ;
        cwd                ;
        imul    [c1]       ;
        add     [Zzt], ax   ;

        mov     ax, [Xxt]   ;
        sar     ax, 7      ;  x=xt/128
        mov     [x], ax    ;

        mov     ax, [Zzt]   ;
        sar     ax, 7      ;  z=zt/128
        mov     [Z], ax    ;

        ;now let's rotate around X axis

        mov     ax, [y]    ;
        cwd                ;
        imul    [c3]       ;
        mov     [Yyt], ax   ;
                           ;  yt=(y*c3)-(z*s3)
        mov     ax, [z]    ;
        cwd                ;
        imul    [s3]       ;
        sub     [Yyt], ax   ;


        mov     ax, [y]    ;
        cwd                ;
        imul    [s3]       ;
        mov     [Zzt], ax   ;
                           ;  zt=(y*s3)+(z*c3)
        mov     ax, [z]    ;
        cwd                ;
        imul    [c3]       ;
        add     [Zzt], ax   ;

        mov     ax, [yyt]   ;
        sar     ax, 7      ;  y=yt/256
        mov     [y], ax    ;

        mov     ax, [Zzt]   ;
        sar     ax, 7      ;  z=zt/256
        mov     [Z], ax    ;

        ;now let's rotate around Z axis

        mov     ax, [x]    ;
        cwd                ;
        imul    [c2]       ;
        mov     [Xxt], ax   ;
                           ;  xt=(x*c2)-(y*s2)
        mov     ax, [y]    ;
        cwd                ;
        imul    [s2]       ;
        sub     [Xxt], ax   ;


        mov     ax, [x]    ;
        cwd                ;
        imul    [s2]       ;
        mov     [Yyt], ax   ;
                           ;  yt=(x*s2)+(y*c2)
        mov     ax, [y]    ;
        cwd                ;
        imul    [c2]       ;
        add     [Yyt], ax   ;

        mov     ax, [yyt]   ;
        sar     ax, 7      ;  y=yt/256
        mov     [y], ax    ;

        mov     ax, [xxt]   ;
        sar     ax, 7      ;  x=xt/256
        mov     [x], ax    ;


        mov     ax, [X]   ;
        sal     ax, 8     ;
        add     [z], 160
        cwd                ; x=x*256 / z
        idiv    [z]        ;
        mov     [x], ax    ;

        mov     ax, [y]   ;
        sal     ax, 8     ;  y=y*256 / z
        cwd
        idiv    [z]        ;
        mov     [y], ax    ;

        ; now center result and save it
        mov     ax, [x]
        add     ax, 160
        mov     r_points[bx], ax
        mov     ax, [y]
        add     ax, 100
        mov     r_points[bx+2], ax

        add     bx, 4

        dec     cx
        ;jz      rotaend
        ;jmp     newini
        jnz      newini

rotaend:
        ret

endp    rotalogo

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄÄÄÄÄ Draws Epsilon poligons ÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input params
;úúúú Returns nothing
drawpolys       proc

        ; this proc gets the points it previous friend
        ; has just rotated and joins them into polygons

        ; bx points to vertex list   (3 words per entry)
        ; bp points to vertex coords (2 words per entry, Z assumed 0)

        ; 10 polygons
        mov     cx, 10
        xor     bx, bx
dptag1:

        mov     bp, e_polys[bx]

        ; bp*=4   (faster than shl 2)
        add     bp, bp
        add     bp, bp

        mov     ax, r_points[bp]
        mov     [x1], ax
        mov     ax, r_points[bp+2]
        mov     [y1], ax

        mov     bp, e_polys[bx+2]

        add     bp, bp
        add     bp, bp

        mov     ax, r_points[bp]
        mov     [x2], ax
        mov     ax, r_points[bp+2]
        mov     [y2], ax

        mov     bp, e_polys[bx+4]

        add     bp, bp
        add     bp, bp

        mov     ax, r_points[bp]
        mov     [x3], ax
        mov     ax, r_points[bp+2]
        mov     [y3], ax

        add     bx, 6

        push    ax bx cx dx
        call    ftriang
        pop     dx cx bx ax

        loop    dptag1

        ret

endp    drawpolys

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄ Rotates and displays Epsilon logo ÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input params
;úúúú Returns nothing
epsilon proc

        ; Ok, this one makes both things, rotate and draw polygons
        ; and the difumines and decrements the screen
        ; and then "add" it to the background pattern

        mov     es, [mixseg]

        mov     cx, 450
edtag1: push    cx
        call    rotalogo
        call    drawpolys
        call    difumine
        call    fade

        ; restore background
        push    [lastbuf]
        pop     [dumpdst]
        push    [backseg]
        pop     [dumpsrc]

        call    retrace
        call    dumpscr

        ; add logo screen
        push    [mixseg]
        pop     [dumpsrc]
        push    [lastbuf]
        pop     [dumpdst]

        call    addnozero

        ; throw it into VGA
        push    [lastbuf]
        pop     [dumpsrc]
        push    vga
        pop     [dumpdst]
        call    dumpscr

        pop     cx
        loop    edtag1

        ret
endp    epsilon

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄ Adds one buffer onto another if byte!=0 ÄÄÄÄ-----úúúú
;úúúú Receives buffers in "dumpsrc" and "dumpdst"
;úúúú Returns nothing
addnozero      proc

        ; Basically as that one that copies, but this one adds
        ; non zero bytes to the target screen

        push    es
        push    ds

        mov     ds, cs:[dumpsrc]
        mov     es, cs:[dumpdst]

        xor     di, di
        mov     si, di
        mov     cx, 64000
anzt1:
        lodsb
        or    al, al
        jz    anxtnz
        add   al, al
        mov   ah, es:[di]
        add   al, ah
        mov   es:[di], al
anxtnz: inc   di
        loop  anzt1

        pop     ds
        pop     es

        ret

endp    addnozero

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄ Decrements pixels in buffer if byte > 0 ÄÄÄÄÄ-----úúúú
;úúúú NO params
;úúúú Returns nothing
fade    proc

        ; this just decrements those points
        ; that are greater than zero

        xor     di, di
        mov     cx, 32000
faddec1:
        mov     ax, es:[di]
        or      ax, ax
        jz      escero
        or      ah, ah
        jz      nopixah
        dec     ah
nopixah:
        or      al, al
        jz      escero
        dec     al
escero:
        stosw
        loop    faddec1

        ret

endp    fade

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄÄ Smoke-like plasma ÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú NO params
;úúúú Returns nothing
smoke   proc

        ; Ok... I guess you have seen FC's Second Reality...
        ; and you rememder this plasma that looked like fog
        ; or smoke (even when it was not grey!)
        ; well... this is the only way I could figure out
        ; how it was done.
        ; I guess it would look more like that if I should use
        ; some sinus patters for the texture and the movement...

        ;push    es
        push    ds

        ; how many frames ?
        mov     bp, 600

        mov     ds, cs:[texture]
        mov     es, cs:[lastbuf]
smktag:
        xor     di, di
smkta2:
        xor     ax, ax
        xor     dx, dx
        mov     bx, cs:[off1]
        add     bx, di
        mov     al, byte ptr ds:[bx]
        mov     bx, cs:[off2]
        add     bx, di
        mov     dl, byte ptr ds:[bx]
        add     ax, dx
        mov     bx, cs:[off3]
        add     bx, di
        mov     dl, byte ptr ds:[bx]
        add     ax, dx
        mov     bx, cs:[off4]
        add     bx, di
        mov     dl, byte ptr ds:[bx]
        add     ax, dx
        shr     ax, 2
        stosb

        or      di, di
        jnz     smkta2

        push    cs:[lastbuf]
        pop     cs:[dumpsrc]
        push    vga
        pop     cs:[dumpdst]

        call    retrace
        call    dumpscr

goonsk:
        add     word ptr cs:[off1], 2
        add     word ptr cs:[off2], 319
        add     word ptr cs:[off3], -321
        add     word ptr cs:[off4], -2

        dec     bp
        jnz     smktag

        pop     ds
        ;pop     es

        ret

endp    smoke

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄÄÄ Generates sinus table ÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú NO params
;úúúú Returns nothing
gensinus        proc

        ; You all know that in a 256 degree circle,
        ; when ang < 64  -> sin(ang)=sin(128-ang)
        ; when ang < 128 -> sin(ang)=-sin(128+ang)
        ; so, keeping a quarter of the table, I can
        ; "mirror" generate the other 3 parts
        ; plus the cosinus "appended" 64 entries

        ; Don't know if I xplained myself, but...

        ; I know I could have done it with the copro
        ; but I just wanted to test this thing

        mov     si, offset [stab]
        mov     di, offset ctab[63]
        mov     cx, 64
cpysns1:
        mov     al, [si]
        neg     al
        dec     al
        mov     [di], al
        inc     si
        dec     di
        loop    cpysns1

        mov     si, offset [stab]
        mov     di, offset [ctab]
        add     di, 64
        mov     cx, 192
cpysns2:
        mov     al, [si]
        neg     al
        dec     al
        mov     [di], al
        inc     si
        inc     di
        loop    cpysns2

        ret

endp    gensinus

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄÄÄÄ Creates plasma texture ÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú NO params
;úúúú Returns nothing
dotexture     proc

        ; this is almost a fire too, but blurring is a bit
        ; weird, so that the result is not xactly fire

        ;push    es

        mov     es, [texture]

        mov     cx, 2048

maptag:
        call    random
        mov     di, ax
        mov     dh, 32
LIN2:
        mov     dl, 64
        add     di, 256
LIN1:
        add     byte ptr es:[di], 4
        inc     di
        dec     dl
        jnz     lin1
        dec     dh
        jnz     lin2

        loop    maptag

        mov     bx, 5
mxtag2: xor     di, di
mxtag1: xor     ax, ax
        xor     dx, dx
        mov     dl, es:[di+bx-320]
        mov     al, es:[di-bx-1]
        add     ax, dx
        mov     dl, es:[di+bx+1]
        add     ax, dx
        mov     dl, es:[di-bx+320]
        add     ax, dx
        shr     ax, 2
        mov     es:[di], al

        inc     di
        inc     di
        inc     di
        jnz     mxtag1

        dec     bx
        jnz     mxtag2

        ;pop     es

        ret

endp    dotexture

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄ Rotozoomer using mandelbrot as texture ÄÄÄÄ-----úúúú
;úúúú NO params
;úúúú Returns nothing
rotozoom        proc

        ; good old rotozoom
        ; texture coordinates are obtained with this formulas:
        ;
        ; TX=((SX*cos(ang))-(SY*sin(ang)))*scale_factor
        ; TY=((SX*sin(ang))+(SY*cos(ang)))*scale_factor
        ;
        ; scale_factor is a simple sinus wave

        push    ds
        push    es

        mov     ds, cs:[mandelseg]
        mov     es, cs:[lastbuf]

        mov     bp, 254         ; angle
rotamain:
        xor     ax, ax
        mov     di, ax          ; where to draw
        mov     cs:[ry], al     ; rotation Y (screen coord)
ryloop:
        xor     ax, ax
        mov     al, cs:[ry]
        sub     al, 100

        push    ax
        mov     bl, cs:ctab[bp]
        cwd
        imul    bl
        sar     ax, 7
        mov     cs:[yc], al     ; screen Y * cos(angle)

        pop     ax
        mov     bl, cs:stab[bp]
        cwd
        imul    bl
        sar     ax, 7
        mov     cs:[ys], al     ; screen Y * sen(angle)

        xor     al, al
        mov     cs:[rx], al     ; rotation X (screen coord)
rxloop:
        xor     ax, ax
        mov     al, cs:[rx]
        sub     al, 128

        push    ax
        mov     bl, cs:ctab[bp]
        cwd
        imul    bl
        sar     ax, 7
        sub     al, cs:[ys]

        xor     ah, ah
        imul    cs:stab[bp]
        sar     ax, 4

        mov     cs:[tx], al     ; texture X

        pop     ax
        mov     bl, cs:stab[bp]
        cwd
        imul    bl
        sar     ax, 7
        add     al, cs:[yc]

        xor     ah, ah
        imul    cs:stab[bp]
        sar     ax, 4

        mov      bh, al         ; got texture Y

        mov     bl, cs:[tx]
        mov     si, bx

        ; read pixel and add it to a static image
        xor     ax, ax
        mov     bx, ax
        mov     al, ds:[si+32895]
        mov     bl, ds:[di+28*256]
        add     ax, bx
        add     ax, bx

        inc     si
        stosb

        inc     cs:[rx]
        jnz     rxloop

        inc     cs:[ry]
        jnz      ryloop
rtend:

        push    es
        push    ds

        mov     ax, es
        mov     ds, ax
        push    vga
        pop     es

        xor     si, si
        mov     di, 32
        mov     bx, 200
cpy256:
        mov     cx, 128
        rep     movsw
        add     di, 64
        dec     bx
        jnz     cpy256

        pop     ds
        pop     es

        dec     bp
        dec     bp
        jnz     rotamain
rotoend:

        pop     es
        pop     ds

        ret

endp    rotozoom

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄ Greetings ÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú NO params
;úúúú Returns nothing
outtro   proc

        ; just as the intro part...
        ; nothing to say

        push    es
        push    ds

        mov     ax, cs
        mov     ds, ax

        mov     es, [mixseg]

        mov     [dumpsrc], es

        push    [lastbuf]
        pop     [dumpdst]

        cmp     bp, 60
        je      grtscr4
        cmp     bp, 120
        je      grtscr3
        cmp     bp, 180
        je      grtscr2
        cmp     bp, 240
        je      grtscr1

        jmp     endouttro
grtscr1:

        mov     ax, [mixseg]
        call    clear_seg

        mov     [strx], 64
        mov     [stry], 40
        mov     ax, offset grtjmp1
        mov     [string], ax
        mov     [strlen], 6

        CALL    gputs

        mov     [strx], 112
        mov     [stry], 100
        mov     ax, offset grtjmp2
        mov     [string], ax
        mov     [strlen], 3

        call    gputs

        mov     [strx], 128
        mov     [stry], 160
        mov     ax, offset grtjmp3
        mov     [string], ax
        mov     [strlen], 2

        call    gputs

        call    doubledif

        ;call    copynozero

        jmp     endouttro

grtscr2:
        mov     ax, [mixseg]
        call    clear_seg

        mov     [strx], 64
        mov     [stry], 36
        mov     ax, offset greet1
        mov     [string], ax
        mov     [strlen], 6

        call    gputs

        mov     [strx], 80
        mov     [stry], 68
        mov     ax, offset greet2
        mov     [string], ax
        mov     [strlen], 5

        call    gputs

        mov     [strx], 64
        mov     [stry], 100
        mov     ax, offset greet3
        mov     [string], ax
        mov     [strlen], 6

        call    gputs

        mov     [strx], 48
        mov     [stry], 132
        mov     ax, offset greet4
        mov     [string], ax
        mov     [strlen], 7

        call    gputs

        call    doubledif

        ;call    copynozero

        jmp     endouttro

grtscr3:
        mov     ax, [mixseg]
        call    clear_seg

        mov     [strx], 0
        mov     [stry], 36
        mov     ax, offset greet5
        mov     [string], ax
        mov     [strlen], 10

        call    gputs

        mov     [strx], 32
        mov     [stry], 68
        mov     ax, offset greet6
        mov     [string], ax
        mov     [strlen], 8

        call    gputs

        mov     [strx], 16
        mov     [stry], 100
        mov     ax, offset greet7
        mov     [string], ax
        mov     [strlen], 9

        call    gputs

        mov     [strx], 0
        mov     [stry], 132
        mov     ax, offset greet8
        mov     [string], ax
        mov     [strlen], 10

        call    gputs

        call    doubledif

        ;call    copynozero

        jmp     endouttro

grtscr4:
        mov     ax, [mixseg]
        call    clear_seg

        mov     [strx], 0
        mov     [stry], 36
        mov     ax, offset greet9
        mov     [string], ax
        mov     [strlen], 10

        call    gputs

        mov     [strx], 64
        mov     [stry], 68
        mov     ax, offset greetA
        mov     [string], ax
        mov     [strlen], 6

        call    gputs

        mov     [strx], 16
        mov     [stry], 100
        mov     ax, offset greetB
        mov     [string], ax
        mov     [strlen], 9

        call    gputs

        call    doubledif

        ;call    copynozero

endouttro:

        pop     ds
        pop     es

        ret

endp    outtro


;           __wWw__
;            q. .p
;úúúú----ÄooOÄ(_)ÄOooÄ Double call to difumine (space optimisation!) -----úúúú
;úúúú NO params
;úúúú Returns nothing
doubledif       proc

        ; I just noticed I called "difumine" twice
        ; wherever I called it, so I did this to save a few bytes

        call    difumine
        call    difumine

        ret
endp    doubledif

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄ Mandelbrot set (texture for rotozoomer) ÄÄÄÄ-----úúúú
;úúúú NO params
;úúúú Returns nothing
mandel  proc

        ; a simple Mandelbrot routine
        ; a but optimised for space (and a bit of speed)
        ; will be used as texture for rotozoom and tunnel parts

        ;push    es
        mov     es, [mandelseg]

        mov     si, 1024
CalcRw: mov     bp, 768
CalcPx: mov     cl, 127
        xor     bx, bx
        xor     dx, dx
Cycle:  push    dx
        mov     ax, bx
        sub     ax, dx
        add     dx, bx
        imul    dx
        mov     al, dl
        pop     dx
        xchg    ah, al
        xchg    bx, ax
        sub     bx, bp

        ;center image
        add     bx, 256

        test    bh, bh
        jg      Draw
        imul    dx
        mov     dh, dl
        mov     dl, ah
        add     dx, dx
        sub     dx, si
        add     dx, 512
        loop    Cycle    ;Loop back
Draw:   mov     ax, cx
        stosb               ;Write pixel

        dec     bp              ;Dec column counter
        dec     bp              ;Dec column counter
        dec     bp              ;Dec column counter
        jnz     CalcPx          ;Loop back
        sub     si, 4           ;Dec row
        jnz     CalcRw          ;Loop back

        ;pop     es

        ret

endp    mandel

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄÄ Restores background ÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns nothing
restoreback     proc

        ; just to save a few bytes...
        ; restores background and clears a very used segment


        mov     ax, [mixseg]
        call    clear_seg

        push    [backseg]
        pop     [dumpsrc]
        push    [lastbuf]
        pop     [dumpdst]

        call    dumpscr

        ret

endp    restoreback

;            __wWw__
;             q. .p
;úúúú----ÄÄooOÄ(_)ÄOooÄ-----úúú
;úúúú And now some extern files...
; The polygon filler
include poly.inc

; The tunnel part
include tunnel.inc

; The general stuff (memory, vertical retrace...)
include procs.inc

; the palette
include pals.inc

; the voxel part
include voxel.inc

;          __wWw__     __wWw__     __wWw__     __wWw__     __wWw__
;           q. .p       q. .p       q. .p       q. .p       q. .p
;úúúú----ooOÄ(_)ÄOooÄooOÄ(_)ÄOooÄooOÄ(_)ÄOooÄooOÄ(_)ÄOooÄooOÄ(_)ÄOoo----úúúú
;úúúú AND THE DATA STUFF
alien   db 'A L i E N'
presen  db 'presents'
anew4k  db 'a new 4k'
release db 'release'
called  db 'called'
etherea db 'Ethereal '
xperien db 'Xperience'

byestuf db ' by ALiEN ',39,'97', 10, '$' ; 13 is not needed!! :)

grtjmp1 db 'GREETZ'
grtjmp2 db 'JMP'
grtjmp3 db 'TO'

greet1  db 'iGUANA'
greet2  db 'DOSIS'
greet3  db 'SAVAGE'
greet4  db 'UNKNOWN'
greet5  db 'THE BANNER'
greet6  db 'C. SHADE'
greet7  db 'NORIA WKS'
greet8  db 'T.L.O.T.B.'
greet9  db 'CLONE ZERO'
greetA  db 'EXOBIT'
greetB  db 'INCOGNITA'

fontcol   db 240 ; text initial color
tricol    db 64  ; polygons color

pi        dd 3.141592
degs      dd 128 ; degrees to use with tunnel

e_points dw   -23, -33,  13, -33, 23, -14,  14, -21, -7, -21
         dw    11,  -3, -12,  20, 18,  20,  27,  12, 17,  32
         dw   -28,  32, -28,  20, -5,  -3, -23, -21

e_polys  dw   0, 1, 13, 1, 3, 13, 1, 2, 3, 4, 12, 13, 4, 5, 12
         dw   6, 11, 12, 5, 6, 12, 11, 7, 9, 9, 10, 11, 7, 8, 9

Stab     db   127,  127,  127,  127,  127,  126,  126,  125
         db   124,  124,  123,  122,  121,  120,  119,  118
         db   117,  115,  114,  112,  111,  109,  108,  106
         db   104,  102,  100,   98,   96,   94,   92,   90
         db    88,   85,   83,   81,   78,   76,   73,   71
         db    68,   65,   63,   60,   57,   54,   51,   48
         db    46,   43,   40,   37,   34,   31,   28,   24
         db    21,   18,   15,   12,    9,    6,    3,   -1
Ctab     db    256 dup (?)

; Rotated points table
r_points dw   28 dup (?)

Seed    dw ?  ;pseudo random number seed <>0

fontseg dw ?  ;fonts memory segment
fontoff dw ?  ;fonts memory offset

charx   dw ?  ;character x coord
chary   dw ?  ;character y coord
charac  db ?  ;character

strx    dw ?  ;string x coord
stry    dw ?  ;string y coord
string  dw ?  ;string offset
strlen  db ?  ;string length

dumpsrc dw ?  ;source of buffers to dump
dumpdst dw ?  ;destination of buffers to dump

clrseg  dw ?  ;segment to be cleared

mandelseg dw ?  ; segment for mandelbrot set
texture   dw ?  ; segment for smoke plasma texture
backseg   dw ?  ;segment for background pic
mixseg    dw ?  ;segment for image mixing

lastbuf dw ?  ;last buffer to draw to

;------- Rotation variables

Xang    Db ?
Yang    Db ?
Zang    Db ?

X       DW ?
Y       DW ?
Z       DW ?

Xxt     DW ?
Yyt     DW ?
Zzt     DW ?

s1      Db ?
s2      Db ?
s3      Db ?
c1      Db ?
c2      Db ?
c3      Db ?

;------- Polygon variables

x1        dw ?
y1        dw ?
x2        dw ?
y2        dw ?
x3        dw ?
y3        dw ?
xl        dw ?
auxl      dw ?
xr        dw ?
auxr      dw ?
yt        dw ?
deltax12  dw ?
deltax13  dw ?
deltax23  dw ?

;------ offsets for smoke plasma
off1      dw ?
off2      dw ?
off3      dw ?
off4      dw ?

;------ Rotozoomer variables
yc        db ?
ys        db ?
tx        db ?
ty        db ?
rx        db ?
ry        db ?
rs        db ?
rc        db ?

;------ Tunnel auxiliar stuff
taux1     dw ?
taux2     dw ?
taux3     dw ?

;------ Voxel counters
voxx      dw ?
voxrx     dw ?
voxxt     dw ?
vlasty    dw ?
voxry     dw ?
color     db ?
voxyp     dw ?

ENDS
END     MAIN


