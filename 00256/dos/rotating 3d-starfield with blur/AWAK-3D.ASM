;======================================================
;           ROTATING 3d-starfield with blur
;======================================================
; this proggy draws a random 3d-starfield. took me a
; while to get the FPU code to work :)  Lost of sleep-
; less nights to code this thingy for the tuhb 256
; byte compo... (actually it were just 2 sleepless
; nights :)
;======================================================
; (C) The Awakener - Coder for The Third Foundation
;                    contact me at m.bruins@st.hanze.nl
;
; other members of the third foundation:
;------------------------------------------------------
; DutchPanther - Coder / Pixel
; Shogun       - Coder / Music
;------------------------------------------------------

.model tiny
.386
.387

.data

anglef  dd  ?

angle   dw  ?
divid   dw  128
multp   dw  256

object  dw  192 dup(?)
xcoor   dw  ?
zcoor   dw  ?

.code
.startup

;=================================
;======= main program ============
;=================================
push    0a000h
pop     es

mov     ax,13h
int     10h

;=================================
;====== Create the pallette ======
;=================================
mov     cx,255
mov     dx,3c8h
pal_loop:
    mov     al,cl
    out     dx,al
    inc     dx
    shr     al,2
    out     dx,al
    out     dx,al
    out     dx,al
    dec     dx
loop    pal_loop

;=================================
;====== Create random object =====
;=================================
in      al,40h              ;get the timer thingy
mov     ebx,eax             ;throw it in the seed

;get a random number
mov     cx,192              ;i need 64 points
lea     bp,object           ;[bp] = x, [bp+2] = y, [bp+4] = z

object_loop:                ;create a random number
mov     eax,110702475
mul     ebx
mov     ebx,eax
sar     eax,25

mov     [bp],ax
add     bp,2                ;point to next coordinate
loop    object_loop



finit                       ;init the fpu


loopje:

;===============================
;====== Wait for retrace =======
;===============================
    mov     dx,3dah         ;this one is not complete...
w1:
    in      al,dx           ;but it looks fine  :)
    test    al,8h
    jz     w1

;===============================
;====== Blur the screen  =======
;==============================
    mov     cx,31358        ;kinda slow, but it looks nice :)
    mov     di,16320        ;don't blur the complete screen (to slow)
blur_loop:
    mov     al,es:[di-1]    ;standard blur matrix                            
    add     al,es:[di+1]    ;       1
    add     al,es:[di-320]  ;     1 0 1
    add     al,es:[di+320]  ;       1
    shr     al,2
    stosb
    loop    blur_loop

lea     di,object           ;point to object
mov     bp,64               ;want to draw 64 points

draw_object:

;===============================
;======  Rotate a point   ======
;===============================
    fldpi                   ;load pi
    fidiv   divid           ;divide by 128
    fimul   angle           ;multiply by the angle
    fst     anglef          ;store the calculated angle

    fcos                    
    fimul   word ptr [di]             ;x * cos(angle)
    fld     anglef
    fsin
    fimul   word ptr [di+4]          ;z * sin(angle)
    fadd    st,st(1)
    fistp   xcoor                    ;store the x-coordinate
    ffree   st

    fld     anglef
    fcos
    fimul   word ptr [di]         ;z * cos(angle)
    fld     anglef
    fsin
    fimul   word ptr [di+4]           ;x * sin(angle)
    fadd    st,st(1)
    fistp   zcoor
    ffree   st

    mov     ax,xcoor
    mov     bx,[di+2]
    mov     cx,zcoor
    sal     ax,8
    sal     bx,8
;===============================
;======  Project a point  ======
;===============================
    add     cx,400

    cwd
    idiv    cx                  ;x = x / z
    push    ax
    mov     ax,bx
    cwd
    idiv    cx                  ;y = y / z
    pop     bx
    add     bx,160
    add     ax,100

;=============================
;====== Display a point ======
;=============================
imul    ax,320
add     bx,ax
mov     al,255
sub     al,cl
mov     es:[bx],al

;=============================
;======  Point to next  ======
;=============================
add     di,6
dec     bp
;====== Draw next point ======
jnz     draw_object

;======  Rotate object  ======
add     angle,2

;======  Check for ESC  ======
in      al,60h
dec     al
;===== Draw object again =====
jnz     loopje

;====== End of program  ======
mov     ax,3
int     10h
ret

end
