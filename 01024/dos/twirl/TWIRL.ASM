
        ; -----------------------------------------------------------
        ;  TWiRL - an 1024 bytes intro presented at antiq99, hungary
        ;  copyright (c)1999.remage/fresh! [remage@makacs.poliod.hu]
        ; -----------------------------------------------------------

        .486
        .model use16 tiny
        .code
        jumps
        o equ offset
        b equ byte ptr
        w equ word ptr
        d equ dword ptr
        GUSP equ 0260h          ; gus baseport.
        BASE equ 00000h         ; base address, 01000h for packed version!
        org 0100h

        ; -----------------------------------------------------------
        ;  INIT
        ; -----------------------------------------------------------

entry:  fninit
        mov     al,013h         ; init videomode.
        int     010h
        mov     ax,cs
        add     ah,010h
        mov     es,ax
        mov     fs,ax

        mov     ax,04ch         ; gus reset=0.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al
        inc     dx
        inc     dx
        mov     ch,1
wloop1: in      al,dx
        loop    wloop1
        mov     ax,014ch        ; gus reset=1.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al
        inc     dx              ; gus onboard data.
        inc     dx
        mov     ch,1
wloop2: in      al,dx
        loop    wloop2
        mov     ax,041h         ; gus dma control.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al
        mov     ax,045h         ; gus timer control.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al
        mov     ax,049h         ; gus sampler control.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al
        mov     ax,0cd0eh       ; gus channels.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al
        mov     ax,074ch        ; gus reset=7.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al
        mov     dx,GUSP         ; gus playing control.
        mov     al,9
        out     dx,al

        xor     ax,ax           ; clear buffer.
        xor     cx,cx
        xor     di,di
cloop:  stosb
        loop    cloop

        ; -----------------------------------------------------------
        ;  GENERATE DRUM AND BASS TRACK
        ; -----------------------------------------------------------

        mov     bp,14
gloop1: mov     si,o [drum1+BASE]
        fldz                    ; initialize sample generator.
        fstp    d [freq+BASE]
        mov     w [count+BASE],0
        mov     cx,w [si]
        mov     di,w [si+2]
gloop2: fld     d [freqc+BASE]  ; generate sample position (1.0..0.0).
        inc     w [count+BASE]
        fild    w [count+BASE]
        fidiv   w [si]
        fld1
        fsub    st,st(1)
        fstp    d [posit+BASE]
        fyl2x                   ; generate frequency envelope.
        f2xm1
        fld1
        faddp   st(1),st
        fld     d [si+8]
        fsub    d [si+4]
        fmulp   st(1),st
        fadd    d [si+4]
        fadd    d [freq+BASE]   ; update frequency.
        fst     d [freq+BASE]
        fsin                    ; generate distorted sine
        fld     st              ; -- distort
        fabs
        fsqrt
        fmulp   st(1),st        ; --
        fld     d [posit+BASE]  ; generate amplitude envelope
      ; fsqrt
        fmul    st,st
        fmulp   st(1),st
        fimul   w [dvol+BASE]
        fistp   w [temp+BASE]   ; store sample word
        mov     ax,w [temp+BASE]
        add     es:[di],ax
        inc     di
        inc     di
        loop    gloop2
        add     w [si+2],01000h
        add     si,12
        fldz                    ; initialize sample generator.
        fstp    d [freq+BASE]
        mov     w [count+BASE],0
        mov     cx,w [si]
        mov     di,w [si+2]
gloop3: inc     w [count+BASE]  ; generate sample position (1.0..0.0).
        fld1
        fild    w [count+BASE]
        fidiv   w [si]
        fsubp   st(1),st
        fstp    d [posit+BASE]
        fld     d [si+4]        ; update frequency.
        fadd    d [freq+BASE]
        fst     d [freq+BASE]
        fsin                    ; generate distorted sine
        fld     st              ; -- distort
        fabs
        fsqrt
        fmulp   st(1),st        ; --
        fld     d [posit+BASE]  ; generate amplitude envelope
      ; fsqrt
        fmul    st,st
        fmulp   st(1),st
        fimul   w [dvol+BASE]
        fistp   w [temp+BASE]   ; store sample word
        mov     ax,w [temp+BASE]
        add     w es:[di],ax
        inc     di
        inc     di
        loop    gloop3
        add     w [si+2],01000h
        dec     bp
        jnz     gloop1
        add     si,8
        fldz                    ; initialize sample generator.
        fstp    d [freq+BASE]
        mov     w [count+BASE],0
        mov     cx,w [si]
        mov     di,w [si+2]
gloop4: inc     w [count+BASE]  ; sample position (1.0..0.0).
        fld1
        fild    w [count+BASE]
        fidiv   w [si]
        fsubp   st(1),st
        fstp    d [posit+BASE]
        fld     d [si+4]        ; update frequency.
        fadd    d [freq]
        fst     d [freq]
        fsin                    ; generate distorted sine
        fld     st              ; -- distort
        fabs
        fsqrt
        fmulp   st(1),st        ; --
        fld     d [posit+BASE]  ; generate amplitude envelope
      ; fsqrt
        fmul    st,st
        fmulp   st(1),st
        fimul   w [dvol+BASE]
        fistp   w [temp+BASE]   ; store sample word
        mov     ax,w [temp+BASE]
        add     w es:[di],ax
        inc     di
        inc     di
        loop    gloop4
        add     w [si+2],01000h
        fldz                    ; initialize sample generator.
        fstp    d [freq+BASE]
        mov     w [count+BASE],0
        mov     cx,w [si]
        mov     di,w [si+2]
gloop5: inc     w [count+BASE]  ; sample position (1.0..0.0).
        fld1
        fild    w [count+BASE]
        fidiv   w [si]
        fsubp   st(1),st
        fstp    d [posit+BASE]
        fld     d [si+4]        ; update frequency.
        fadd    d [freq+BASE]
        fst     d [freq+BASE]
        fsin                    ; generate sine
        fld     st              ; -- distort
        fabs
        fsqrt
        fmulp   st(1),st        ; --
        fld     d [posit+BASE]  ; generate amplitude envelope
      ; fsqrt
        fmul    st,st
        fmulp   st(1),st
        fimul   w [dvol+BASE]
        fistp   w [temp+BASE]   ; store sample word
        mov     ax,w [temp+BASE]
        add     es:[di],ax
        inc     di
        inc     di
        loop    gloop5

        ; -----------------------------------------------------------
        ;  GENERATE ACID TRACK
        ; -----------------------------------------------------------

        mov     bp,4
gloop8: push    bp
        mov     bp,6
        mov     si,o [acid2+BASE]
gloop6: fldz                    ; initialize sample generator.
        fst     d [f_low+BASE]
        fst     d [f_band+BASE]
        fst     d [f_high+BASE]
        fstp    d [freq+BASE]
        mov     w [count+BASE],0
        mov     cx,w [si]
        mov     di,w [si+2]
gloop7: inc     w [count+BASE]  ; sample position (1.0..0.0).
        fld1
        fild    w [count+BASE]
        fidiv   w [si]
        fsubp   st(1),st
        fstp    d [posit+BASE]
        fld     d [si+4]        ; update frequency.
        fadd    d [freq+BASE]
        fst     d [freq+BASE]

        fld1                    ; generate saw
        fxch    st(1)
        fprem
        fadd    st,st
        fsubp   st(1),st
        fmul    d [freqc+BASE]

        fld     d [posit+BASE]  ; generate amplitude envelope
        fmul    st,st
        fmulp   st(1),st

        call    gen_filter

        fimul   w [avol+BASE]
        fistp   w [temp+BASE]   ; store sample word
        mov     ax,w [temp+BASE]
        add     es:[di],ax
        sar     ax,1
        add     es:[di+0c00h],ax
        sar     ax,1
        add     es:[di+01800h],ax
        inc     di
        inc     di
        loop    gloop7
        add     w [si+2],04000h
        add     si,8

        dec     bp
        jnz     gloop6

        pop     bp
        dec     bp
        jnz     gloop8

        ; -----------------------------------------------------------
        ;  LOAD & PLAY SAMPLE
        ; -----------------------------------------------------------

        xor     bx,bx           ; upload sample.
uloop:  mov     ax,043h
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx

        inc     ax
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx
        mov     al,b es:[bx]
        mov     dx,GUSP+0107h
        out     dx,al
        inc     bx
        jnz     uloop

        xor     ax,ax           ; clear buffer.
        xor     di,di
cloop2: stosb
        loop    cloop2

        mov     dx,GUSP+0102h   ; gus channel select.
        mov     ax,080ch
        out     dx,al
        inc     dx              ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al
        mov     al,1            ; gus playing frequency.
        mov     bx,070h
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx
        mov     al,9            ; gus playing volume.
        mov     bx,0ffffh
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx

        inc     bx              ; gus playing address high.
        inc     ax
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx
        inc     ax              ; gus playing address low.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx

        mov     al,2            ; gus sample start high.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx
        inc     ax              ; gus sample start low.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx

        mov     bl,0FFh         ; gus sample end high.
        inc     ax
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx
        mov     bx,0FE00h
        inc     ax              ; gus sample end low.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xchg    ax,bx
        out     dx,ax
        xchg    ax,bx

        mov     ax,0C00h        ; gus playing control.
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        xchg    al,ah
        out     dx,al

        ; -----------------------------------------------------------
        ;  MAIN GRAPHIC CODE
        ; -----------------------------------------------------------

        xor     si,si
        mov     cx,320          ; Generate sine/cosine table.
sloop:  fild    w [BASE+frame]
        fmul    d [BASE+pi128]
        fsin
        fimul   w [BASE+i127]
        fistp   w [BASE+sintab+si]
        inc     w [BASE+frame]
        inc     si
        loop    sloop

        mov     di,offset [BASE+texture]
        mov     cx,128*128
qloop:  mov     ds:[di],ah
        inc     di
        loop    qloop

mloop:  xor     ax,ax
        mov     dx,03c8h        ; init 128color blue palette.
        out     dx,al
        inc     dx

        fild    w [BASE+frame]  ; r
        fmul    d [BASE+pi128]
        fsin
        fmul    d [BASE+reso]
        fadd    d [BASE+freqc]
        fimul   w [BASE+i60]
        fistp   w [BASE+temp]

        fild    w [BASE+frame]  ; g
        fmul    d [BASE+fl512_3]
        fsincos
        fmul    d [BASE+reso]
        fadd    d [BASE+freqc]
        fimul   w [BASE+i60]
        fistp   w [BASE+ycoord]
        fmul    d [BASE+reso]
        fadd    d [BASE+freqc]
        fimul   w [BASE+i60]
        fistp   w [BASE+xcoord]

        mov     ch,2
        xor     bx,bx
ploop:  mov     ax,w [BASE+temp]
        mul     bl
        shr     ax,4
        cmp     al,63
        jbe     pskip1
        mov     al,63
pskip1: out     dx,al
        mov     ax,w [BASE+ycoord]
        mul     bl
        shr     ax,4
        cmp     al,63
        jbe     pskip2
        mov     al,63
pskip2: out     dx,al
        mov     ax,w [BASE+xcoord]
        mul     bl
        shr     ax,4
        cmp     al,63
        jbe     pskip3
        mov     al,63
pskip3: out     dx,al
        inc     bx
        loop    ploop

        inc     w [BASE+frame]
        mov     di,offset [BASE+texture]
        mov     si,w [BASE+frame]
mkback: mov     bx,128          ; Generate texture for this frame.
bloop1: mov     cx,128
bloop2: mov     bp,cx
        pusha
        cwd
        mov     cx,1536+1
tloop:  push    bp              ; turbulence.
        shl     bp,cl
        add     bp,si
        push    bx
        shl     bx,cl
        sub     bx,si
        xor     bh,bh           ; 2d sine function.
        mov     al,[BASE+sintab+bx]
        sub     al,[BASE+costab+bx]
        mov     bx,bp
        xor     bh,bh
        add     al,[BASE+sintab+bx]
        xchg    bx,ax
        xor     bh,bh
        mov     al,[BASE+sintab+bx]
        pop     bp
        pop     bx
        inc     cx
        sar     al,cl
        add     dl,al
        dec     ch
        jnz     tloop
texit:  xchg    ax,dx
        sar     al,1
        js      tskip
        mov     byte ptr ds:[di],al
tskip:  popa
        inc     di
        loop    bloop2
        dec     bx
        jnz     bloop1

        xor     di,di
        mov     dx,200
        mov     w [BASE+yscreen],100
loop1:  dec     w [BASE+yscreen]
        mov     cx,320
        mov     w [BASE+xscreen],160
loop2:  dec     w [BASE+xscreen]

        fild    w [BASE+frame]
        fmul    d [BASE+fl1]
        fsincos
        fimul   w [BASE+i60]
        fiadd   w [BASE+xscreen]
        fstp    d [BASE+xscr]
        fimul   w [BASE+i40]
        fiadd   w [BASE+yscreen]
        fstp    d [BASE+yscr]

        fld     d [BASE+xscr]
        fmul    d [BASE+freqc]
        fmul    st,st
        fld     d [BASE+yscr]
        fmul    d [BASE+freqc]
        fmul    st,st
        faddp   st(1),st
        fsqrt

        fild    w [BASE+frame]
        fmul    d [BASE+fl2]
        fcos
        fimul   w [BASE+i60]
        fiadd   w [BASE+i40]
        faddp

        fist    w [BASE+xcoord]
        fiadd   w [BASE+frame]
        fmul    d [BASE+fl3]
        fsin
        fimul   w [BASE+i40]

        fld     d [BASE+yscr]
        fld     d [BASE+xscr]
        fadd    d [BASE+epsilon]
        fpatan
        fdiv    d [BASE+pi128]
        faddp
        fistp   w [BASE+ycoord]

        mov     ax,w [BASE+ycoord]
        and     ax,07Fh
        xchg    ax,bx
        shl     bx,7
        mov     ax,w [BASE+xcoord]
        and     ax,07Fh
        xchg    ax,bx
        add     bx,ax
        mov     al,byte ptr ds:[BASE+texture+bx]
        add     al,es:[di]
        add     al,es:[di]
        add     al,es:[di]
        shr     al,2
        stosb

        loop    loop2
        dec     dx
        jnz     loop1

        push    es              ; put buffer to screen.
        push    0a000h
        pop     es
        xor     si,si
        xor     di,di
        mov     ch,07dh
        rep segfs movsw
        pop     es
        in      al,060h         ; keypressed?
        cbw
        dec     ax
        jnz     mloop

        ; -----------------------------------------------------------
        ;  DONE
        ; -----------------------------------------------------------

        mov     al,03h          ; back to textmode.
        int     010h
        mov     al,09h          ; gus stop playing
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data low.
        xor     ax,ax
        out     dx,ax
        mov     dx,GUSP+0103h   ; gus register select.
        out     dx,al
        inc     dx              ; gus register data high.
        inc     dx
        out     dx,al

        ; -----------------------------------------------------------
        ;  RESONANT LOWPASS FILTER CODE
        ; -----------------------------------------------------------

gen_filter:                     ; Smp
        fld1                    ; Smp; 1
        fld     d [posit+BASE]  ; Smp; 1; Pos
        fadd    st,st(1)        ; Smp; 1; 1+Pos
        fmul    d [reso+BASE]   ; Smp; 1; (1+Pos)*Reso
        fsubp   st(1),st        ; Smp; Reso=1-(1+Pos)*Reso [0.2..0.6]
        fstp    d [f_reso+BASE] ; Smp
        fld     d [posit+BASE]  ; Smp; Pos
        fmul    d [cutoff+BASE] ; Smp; Pos*CutOff [0.2..0.1]
        fsqrt                   ; Smp; Cut=sqrt(Pos*CutOff) [0.447..0.316]
        fild    w [count+BASE]
        fiadd   w [si+2]
        fmul    d [epsilon+BASE]
        fmul    d [epsilon+BASE]
        fabs
        faddp   st(1),st
        fst     d [f_cut+BASE]  ; Smp; Cut
        fmul    d [f_band+BASE] ; Smp; Cut*Band
        fadd    d [f_low+BASE]  ; Smp; Low2=Cut*Band+Low
        fst     d [f_low+BASE]  ; Smp; Low2
        fld     d [f_band+BASE] ; Smp; Low2; Band
        fmul    d [f_reso+BASE] ; Smp; Low2; Band*Reso
        fmul    d [f_reso+BASE] ; Smp; Low2; Band*sqr(Reso)
        faddp   st(1),st        ; Smp; Low2+Reso*Band
        fsubp   st(1),st        ; High2=Smp-Low2-Reso*Band
        fst     d [f_high+BASE] ; High2
        fmul    d [f_cut+BASE]  ; High2*Cut
        fadd    d [f_band+BASE] ; Band2=High2*Cut+Band
        fstp    d [f_band+BASE] ; --
        fld     d [f_low+BASE]  ; Low2
        fdiv    d [f_reso+BASE] ; Smp2=Low2/Reso
        fld1
        fcomp   st(1)
        fstsw   ax
        sahf
        jnb     fskip1
        fistp   w [temp+BASE]
        fld1
fskip1: fld1
        fchs
        fcomp   st(1)
        fstsw   ax
        sahf
        jb      fskip2
        fistp   w [temp+BASE]
        fld1
        fchs
fskip2: ret

        ; -----------------------------------------------------------
        ;  VARIABLES
        ; -----------------------------------------------------------

reso    dd      0.33            ; filter resonance constant.
freqc   dd      0.67            ; frequency envelope curve.
dvol    dw      12000           ; drum+bass volume.
avol    dw      8000            ; acid volume.

        ; -----------------------------------------------------------

drum1   dw      1638,0          ; length, position.
cutoff  dd      0.1003030032    ; frequency start.
epsilon dd      0.003134469     ; frequency end.
bass1   dw      1638,34816      ; length, position.
fl3     dd      0.062689377     ; frequency.
bass2   dw      1638,26624      ; length, position.
fl2     dd      0.083679776     ; frequency.

        ; -----------------------------------------------------------

acid2   dw      5530,01000h     ; length, position.
        dd      0.019954648     ; frequency.
acid3   dw      1638,02800h     ; length, position.
        dd      0.026636260     ; frequency.
acid4   dw      909,03000h      ; length, position.
        dd      0.022444150     ; frequency.
acid1   dw      2867,00400h     ; length, position.
fl1     dd      0.019954648     ; frequency.
acid5   dw      909,03400h      ; length, position.
        dd      0.022444150     ; frequency.
acid6   dw      2867,03800h     ; length, position.
        dd      0.025192707     ; frequency.

        ; -----------------------------------------------------------

fl512_3 dd      0.018407769454627695
pi128   dd      0.02454369260617026
i60     dw      60
i40     dw      40
i127    dw      127

frame   dw      ?               ; frame counter.
sintab  db      64 dup (?)      ; sine table.
costab  db      256 dup (?)     ; cosine table.
xscreen dw      ?
yscreen dw      ?
xcoord  dw      ?
ycoord  dw      ?

xscr    dd      ?
yscr    dd      ?

f_cut   dd      ?               ; actual cutoff value.
f_reso  dd      ?               ; actual resonance value.
f_low   dd      ?               ; filter variables.
f_band  dd      ?
f_high  dd      ?
freq    dd      ?               ; actual frequency.
posit   dd      ?               ; actual position (1.0f..0.0f).
count   dw      ?               ; sample counter.
temp    dw      ?
texture db      128*128 dup (?) ; texture data.

        end entry

