;Triangle Flat-Filling Routine
;by Shade / AlieN
;...ok, ok... WiseFox has a better one, but I wanted to code my own routine!

; WARNING!! clipping is commented due to space limitations

ftriang proc
        ;first sort vertexes on Y's

        mov     ax, [y1]
        mov     bx, [y2]
        cmp     ax, bx
        jle     y1above
        mov     [y1], bx
        mov     [y2], ax
        mov     ax, [x1]
        xchg    ax, [x2]
        mov     [x1], ax

y1above:

        mov     ax, [y1]
        mov     bx, [y3]
        cmp     ax, bx
        jle     y1above2
        mov     [y1], bx
        mov     [y3], ax
        mov     ax, [x1]
        xchg    ax, [x3]
        mov     [x1], ax

y1above2:

        mov     ax, [y2]
        mov     bx, [y3]
        cmp     ax, bx
        jle     y2above
        mov     [y2], bx
        mov     [y3], ax
        mov     ax, [x2]
        xchg    ax, [x3]
        mov     [x2], ax

y2above:

;        ; if Y3 is out of the screen (<0), it's over
;        mov     ax, [y3]
;        cmp     ax, 0
;        jge     y3on
;        jmp     midt3

;        ; if Y1 is out of the screen (>199), it's over too
;        mov     ax, [y1]
;        cmp     ax, 199
;        jle     y3on
;        jmp     midt3
y3on:

        ; now calculate deltas

        mov     ax, [y2]
        mov     bx, [y1]
        sub     ax, bx
        jz      dta12_0
        mov     cx, ax
        mov     ax, [x2]
        mov     bx, [x1]
        sub     ax, bx
        sal     ax, 6
        cwd
        idiv    cx
        mov     [deltax12], ax

dta12_0:

        mov     ax, [y3]
        mov     bx, [y1]
        sub     ax, bx
        jz      dta13_0
        mov     cx, ax
        mov     ax, [x3]
        mov     bx, [x1]
        sub     ax, bx
        sal     ax, 6
        cwd
        idiv    cx
        mov     [deltax13], ax

dta13_0:

        mov     ax, [y3]
        mov     bx, [y2]
        sub     ax, bx
        jz      dta23_0
        mov     cx, ax
        mov     ax, [x3]
        mov     bx, [x2]
        sub     ax, bx
        sal     ax, 6
        cwd
        idiv    cx
        cwd
        mov     [deltax23], ax

dta23_0:

 ;       mov     ax, [y2]
 ;       mov     bx, 199
 ;       cmp     ax, bx
 ;       jle     y2in
 ;       mov     [y2], bx

 ;       mov     ax, [y3]
 ;       mov     bx, 199
 ;       cmp     ax, bx
 ;       jle     y2in
 ;       mov     [y3], bx

y2in:

        mov     ax, [x1]
        sal     ax, 6
        mov     [xl], ax
        mov     [xr], ax
        mov     ax, [y1]
        mov     [yt], ax


        mov     dx, [y2]
        sub     dx, [y1]
        ;jnz     midt1
        ;jmp     midt4
        jz       midt4

        ; FIRST HALF OF THE POLYGON

midt1:

;        ; if this line is > 199 or < 0, don't draw it
;        mov     ax, [yt]
;        cmp     ax, 199
;        ja      eol1

        ;get line limits
        mov     bx, [xr]
        sar     bx, 6
        mov     [auxr], bx

        mov     ax, [xl]
        sar     ax, 6
        mov     [auxl], ax

        cmp    ax, bx
        jle    xsort
        xchg   ax, [auxr]
        xchg   bx, [auxl]

xsort:

        ;if the line is out by one side, don't draw it
;        cmp    ax, 319
;        jg     eol1
;        cmp    bx, 0
;        jl     eol1

        ; if left side is <0, start in 0
;        cmp    ax, 0
;        jge    leftpos
;        mov    ax, 0
;        mov    [auxl], ax

leftpos:

        ; same for right side and 319...
;        cmp    bx, 319
;        jng    rightok
;        mov    bx, 319

rightok:

        ; get line length
        mov    cx, bx
        sub    cx, ax

        ; and draw it!
        xor    bx, bx
        mov    ax, [yt]
        mov    bh, al
        shl    ax, 6
        add    bx, ax
        mov    ax, [auxl]
        add    bx, ax
        mov    di, bx
        mov    al, [tricol]
        mov    ah, al
        shr    cx, 1
        jnc    nocarr
        stosb

nocarr:

        rep    stosw

eol1:

        ; add deltas
        mov    ax, [xl]
        mov    bx, [deltax12]
        add    ax, bx
        mov    [xl], ax

        mov    ax, [xr]
        mov    bx, [deltax13]
        add    ax, bx
        mov    [xr], ax

        ; increment Y
        inc    word ptr [yt]

        ; and loop back
        dec    dx
        jnz    midt1

        ; SECOND HALF OF THE POLYGON

midt4:

        mov    ax, [x2]
        sal    ax, 6
        mov    [xl], ax

        mov    dx, [y3]
        sub    dx, [y2]
        jz     midt3

midt2:

;        mov    ax, [yt]
;        cmp    ax, 199
;        ja     eol2

        mov    ax, [xl]
        sar    ax, 6
        mov    [auxl], ax

        mov    bx, [xr]
        sar    bx, 6
        mov    [auxr], bx

        cmp    ax, bx
        jle    xsort2
        xchg   ax, [auxr]
        xchg   bx, [auxl]

xsort2:

;        cmp    ax, 319
;        jg     eol2
;        cmp    bx, 0
;        jl     eol2

;        cmp    ax, 0
;        jge    leftpos2
;        mov    ax, 0
;        mov    [auxl], ax

leftpos2:

;        cmp    bx, 319
;        jng    rightok2
;        mov    bx, 319

rightok2:

        mov    cx, bx
        sub    cx, ax

        xor    bx, bx
        mov    ax, [yt]
        mov    bh, al
        shl    ax, 6
        add    bx, ax
        mov    ax, [auxl]
        add    bx, ax
        mov    di, bx
        mov    al, [tricol]
        mov    ah, al
        shr    cx, 1
        jnc    nocarr2
        stosb

nocarr2:

        rep    stosw

eol2:

        mov    ax, [xl]
        mov    bx, [deltax23]
        add    ax, bx
        mov    [xl], ax

        mov    ax, [xr]
        mov    bx, [deltax13]
        add    ax, bx
        mov    [xr], ax

        inc    word ptr [yt]

        dec    dx
        jnz    midt2

midt3:

        ret

endp            ftriang
