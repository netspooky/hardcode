; 4ge's Xmas 94 Intro fractalzoom source
; ======================================

; Copyright (C) 1994/5 Samuel Marshall. All rights reserved. 

; Text and program code by Samuel Marshall, a.k.a. CuteElf / 4ge.

; Contact me at the following email address:

; Samuel.Marshall@durham.ac.uk

; and if you don't get a response, probably it's not during termtime, and
; I am at home - in which case, I check email here only about once a month
; (if that). You will get a reply eventually.

; My WWW homepage is

; http://www.dur.ac.uk/~d405ua/

; Enjoy the program... hope it helps you. Don't expect a wonderfully-
; optimised piece of code, because 1) the zoom routine wasn't really time-
; critical, and 2) this is the first time I ever wrote a fractal program,
; in my entire life, and 3) I didn't know how to do fixed-point numbers
; properly when I wrote this ;)




; General Principles for a real-time fractalzoom using this method
; ================================================================
;
; First, we calculate a fractal at twice the size, each way (i.e. 4 times
; the area) as the screen display area.
;
; We then display that fractal, zoomed-out to half size each way, so that
; it will exactly fill the screen display area.
;
; Then, we calculate another fractal twice the size of the display area,
; but this one is calculated "zoomed in" so that this fractal is a more
; detailed view of one-quarter of the area of the fractal just calculated.
;
; While we are calculating this, which takes a few seconds, we gradually
; zoom in the fractal we already have - using standard bitmap-zoom 
; techniques - until eventually by the time the new fractal is finished,
; the old fractal will be showing at 1:1 size, and will can then be 
; seamlessly replaced on the display by the new fractal at 1:2. Then
; repeat.
;
; Note: the fractal being DISPLAYED, i.e. the one that's already been
; calculated, can be zoomed to any point at all within the region, but
; this decision must be known in advance so that the next fractal is
; calculated from the right point. That's why you can't change the direction
; "realtime", only every so often.

; I would include references here but I worked the method out myself with
; no help from anything or anyone, so there aren't any... (oh, by the
; way, I assume this is the standard method everyone else uses too, it's
; nothing special or anything, just that I reinvented the wheel one more
; time ;)

; More details are included in the individual function descriptions.

.MODEL tiny
.386
.CODE

.STARTUP
jmp start

Getch:
mov ax,0
int 16h
ret

; You can probably change height without messing things up, but
; changing the width will I think need some work.

FRACWIDTH equ 256
FRACHEIGHT equ 128

; Fractal parameter
frac    dd 3

; Memory
enlargebufferseg        dw 0    ; segment address of the 64*32 enlarge buf.
textureseg              dw 0    ; the segment address of texture to display.
fractalseg              dw 0    ; the segment address of texture to create

;====================================================================
;ZOOMTEXTURE - display picture at given zoom fraction
;--------------------------------------------------------------------

; This is pretty obvious; just a standard, fixed-point bitmap
; display routine. The only extra bit you might notice is that
; it doubles each pixel, so as to get a larger screen display without
; taking too long to calculate the fractals.

; Data_______________________________________________________________

lfrac   dw 0    
hfrac   dw 0    ; texture pixels per real pixel
hfracb  db 0    ; same but a byte

ystart  db 0
xstart  db 0    ; where to start, in texturemap

oldbx   dw 0
oldss   dw 0

yfracpos dw 0   ; fractional y-position

stopat  dw 0    ; where to stop in screen ram

; Source_____________________________________________________________

ZoomTexture:
push ax
push bx
push cx
push dx
push si
push di

mov di,screenstart      ; start position on display memory
mov stopat,di
add stopat,FRACHEIGHT*320    ; stop position on display memory
mov bh,ystart
mov bl,xstart           ; start position on texture memory

mov ax,hfrac
mov hfracb,al
mov dx,lfrac

mov ax,ss
mov oldss,ax
mov ax,textureseg
mov ss,ax

  ZoomYLoop:

  mov si,FRACWIDTH/2
  mov oldbx,bx
  mov cx,0

    ZoomXLoop:

    mov al,ss:[bx]
    mov ah,al
    mov es:[di],ax
    mov es:[di+320],ax
    add di,2
    add cx,lfrac
    adc bx,hfrac

    dec si
    jnz ZoomXLoop

  mov bx,oldbx

  add yfracpos,dx
  adc bh,hfracb

  add di,640-FRACWIDTH
  cmp di,stopat
  jb ZoomYLoop

mov ax,oldss
mov ss,ax

; Check for keypress
mov ah,1
int 16h
jz zt_afterkeyhit  

jmp dfs_keyhit

zt_afterkeyhit:

pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret

;====================================================================
;CALCULATE - work out one pixel of Mandelbrot fractal
;--------------------------------------------------------------------

; The fractal formula used, with coordinates x,y, is:
; A = B = 0. Colour=starting colour.
;
; new A = a squared - b squared - x
; new B = 2 * a * b - y
;
; If A squared + B squared > some number frac, then stop.
; If been round loop more than colour limit (64) times, then stop too.
;
; Otherwise, work out next A and B, and increment the colour we're going
; to use for the pixel.
;
; When we get out of the loop, that colour value is the one to draw at
; this pixel.

; Note:
; The fixed point sections of this are pretty crap; there are proper ways
; to do fixed point (I think...) so for god's sake don't copy those
; bits for your own fixed point code.

; Data_______________________________________________________________

colour  db 0    ; colour to plot the pixel

esign    db 0    ; esign of multiplication result

la      dd 0
ha      dd 0    
lb      dd 0
hb      dd 0    ; a,b from a+bi. Low and high words thereof.

lasq    dd 0
hasq    dd 0
lbsq    dd 0
hbsq    dd 0    ; a squared, b squared, low and high words.

lnewa   dd 0
hnewa   dd 0    ; temporary storage for `new' veresion of `a'.

lx      dd 0
hx      dd 0
ly      dd 0
hy      dd 0    ; co-oredinates in complex plane of this point

; Source_____________________________________________________________

Calculate:
  push eax
  push ebx
  push ecx
  push edx
  push esi
  push edi

; 0) Fix up the x,y data to specific point
;  mov lx,2621
;  mov hx,1
;  mov ly,11107
;  mov hy,1

; 1) setup colour
  mov colour,32

; 2) clear the a,b and squared variables
  mov la,0
  mov ha,0
  mov lb,0
  mov hb,0
  mov lasq,0
  mov hasq,0
  mov lbsq,0
  mov hbsq,0

  CalcLoop:

  ; 3) increment colour
  inc colour

  ; 4) set up a-squared
asquared:  
  mov eax,lasq
  mov edx,hasq

minusbsquared:
  ; 5) subtract b-squared
  sub eax,lbsq
  sbb edx,hbsq

minusx:  
  ; 6) subtract x and store result in new-a
  sub eax,lx
  sbb edx,hx
  mov lnewa,eax
  mov hnewa,edx

  ; 7) multiply a and b
  
atimesb:
  ; a. setup variables
  mov ebx,la
  mov ecx,ha
  mov esi,lb
  mov edi,hb

fixesigns:  
  ; b. sort out esigns to be poesitive
  mov esign,0
  cmp ecx,0
  jge ecxok_1
    xor ecx,0ffffffffh
    xor ebx,0ffffffffh
    add ebx,1
    adc ecx,0
    inc esign
  ecxok_1:
  cmp edi,0
  jge ediok_1
    xor edi,0ffffffffh
    xor esi,0ffffffffh
    add esi,1
    adc edi,0
    inc esign
  ediok_1:

multiply:
  ; c. multiply the two numbers
  mov hb,0
  mov eax,ebx
  mov edx,esi
  mul edx
  mov lb,edx
  mov eax,ebx
  mov edx,edi
  mul edx
  add lb,eax
  adc hb,edx
  mov eax,ecx
  mov edx,esi
  mul edx
  add lb,eax
  adc hb,edx
  mov eax,ecx
  mov edx,edi
  mul edx
  add hb,eax

fixresultesign:
  ; d. fix the esign of the result
  test esign,1
  jz esignok_1
    xor hb,0ffffffffh
    xor lb,0ffffffffh
    add lx,1
    adc hb,0
  esignok_1:

doublenumber:
  ; 8) Add this to itself, (with carry)
  mov eax,lb
  mov edx,hb
  add eax,eax
  adc edx,edx

subtracty:
  ; 9) Subtract y and store in b
  sub eax,ly
  sbb edx,hy
  mov lb,eax
  mov hb,edx

  ; 10) Update a from new-a : combined with
  ; 11) Square a and store in a-squared
  ; a. setup variable
starttosquare:  
  mov ebx,lnewa
  mov ecx,hnewa
  mov la,ebx
  mov ha,ecx

fixesign:
  ; b. sort out esign to be poesitive
  cmp ecx,0
  jge ecxok_2
    xor ecx,0ffffffffh
    xor ebx,0ffffffffh
    add ebx,1
    adc ecx,0
  ecxok_2:

squareit:
  ; c. square data
  mov hasq,0
  mov eax,ebx
  mul eax
  mov lasq,edx
  mov eax,ebx
  mul ecx
  add lasq,eax
  adc hasq,edx
  add lasq,eax
  adc hasq,edx
  mov eax,ecx
  mul eax
  add hasq,eax

sametosquareb:
  ; 12) Square b and store in b-squared
  ; a. setup variable
  mov ebx,lb
  mov ecx,hb

  ; b. sort out esign to be poesitive
  cmp ecx,0
  jge ecxok_3
    xor ecx,0ffffffffh
    xor ebx,0ffffffffh
    add ebx,1
    adc ecx,0
  ecxok_3:

  ; c. square data
  mov hbsq,0
  mov eax,ebx
  mul eax
  mov lbsq,edx
  mov eax,ebx
  mul ecx
  add lbsq,eax
  adc hbsq,edx
  add lbsq,eax
  adc hbsq,edx
  mov eax,ecx
  mul eax
  add hbsq,eax

asquaredaddbsquared:  
  ; 13) Setup a-squared
  mov eax,lasq
  mov edx,hasq

  ; 14) Add b-squared
  add eax,lbsq
  adc edx,hbsq

  ; 15) Compare with *n*, stop if >
  cmp edx,frac
  jg CalcFinish

  ; 16) If colour > *c*, stop
  cmp colour,63
  jg CalcFinish

jmp CalcLoop

CalcFinish:
; 17) Return pixel colour
pop edi
pop esi
pop edx
pop ecx
pop ebx
pop eax
mov al,colour
ret

;====================================================================
;FRACTAL - loop round to draw a 256x256 fractal using Calculate
;--------------------------------------------------------------------

; Basically, this just uses fixed-point to go through all the 
; x and y coordinates corresponding to SCREEN x and y.
; If you're confused about the "normaltime", "othertime", etc crap
; in the zooming-in section, well, I *think* this is because the
; Y-position sometimes needs to start at a half-pixel (i.e. "othertime")
; but usually ("normaltime") starts on a whole pixel.

; Note, it would be possible to speed this up by 1/4, simply by re-using
; the relevant pixels from the fractal calculated last: see this diagram

; We're zooming in to top left corner.

; Original fractal      Fractal needs calculating next
;
; abcd....              a?b?c?d?
; efgh....              ????????
; ijkl....              e?f?g?h?
; mnop....              ????????
; ........              i?j?k?l?
; ........              ????????
; ........              m?n?o?p?
; ........              ????????
;
; where "." has been calculated on original fractal, but will not be used
; for the new one, and ? represents what actually needs to be calculated
; in the new one. (a,b,c,... could be copied from the old one).
;
; Actually, this routine doesn't copy over a,b,c,..., they are recalculated.

; Data_______________________________________________________________

lxcentre     dd 0
hxcentre     dd 0
lycentre     dd 0
hycentre     dd 0    ; co-ordinates of the window's centre, not used here
                     ; (they are used in the main loop...)

lxs     dd 0
hxs     dd 0
lys     dd 0
hys     dd 0    ; co-oredinates of the window's top left corner

lxi     dd 0
hxi     dd 0
lyi     dd 0
hyi     dd 0    ; amount to increment fractal parameter per pixel

ycount  dw 0
xcount  dw 0    ; loop counters

nodraw  db 1    ; whether or not to draw the last one

ydirection db 1
xdirection db 1 ; direction of the zoom (0 = left/up, 1=centre, 2=rt/down)
newxdirection db 1
newydirection db 1


screenstart     dw 0    ; screen edisplay offset

; Source_____________________________________________________________

Fractal:
push eax
push ebx
push ecx
push edx
push esi
push edi

; 1) Initialise x and y parameters of fractal to xstart,ystart
mov eax,lxs
mov edx,hxs
mov lx,eax
mov hx,edx
mov eax,lys
mov edx,hys
mov ly,eax
mov hy,edx

; 1.5) Initialise zoom parameters
mov lfrac,1024*63
mov hfrac,1
mov ystart,0
mov xstart,0

; 2) Set up screen pointer
push es
mov ax,fractalseg
mov es,ax
mov edi,0

mov ycount,FRACHEIGHT
  FracYLoop:

  mov xcount,FRACWIDTH
    FracXLoop:
    
    ; 3) Calculate pixel
    call Calculate

    ; 4) Draw pixel
    mov es:[edi],al

    ; 5) Add X increment to X
    mov eax,lxi
    mov edx,hxi
    add lx,eax
    adc hx,edx

    ; 6) Increment screen poesition
    inc edi
    
    ; 7) If count >127, stop
    dec xcount
    jnz FracXLoop

  ; 8) Set X to xstart
  mov eax,lxs
  mov edx,hxs
  mov lx,eax
  mov hx,edx

  ; 10) Add Y increment to Y
  mov eax,lxi
  mov edx,hxi
  add ly,eax
  adc hy,edx

  ; 10.5) Draw zoomed last fractal if count%2==0
  mov ax,ycount
  and al,1
  jnz notthistime
    push es
    mov ax,0a000h
    mov es,ax
  ; Update zoom position
    mov yfracpos,0
    mov al,xdirection
    add xstart,al
    cmp ydirection,0
    je normaltime
    cmp ydirection,2
    jne ydirection1
    inc ystart
    jmp normaltime
    ydirection1:
    test ycount,2
    jz othertime
    inc ystart
    jmp normaltime
  
  othertime:
    mov yfracpos,8000h

  normaltime:
    cmp nodraw,0
    jne dontdraw
    call ZoomTexture
    dontdraw:
    pop es
    sub lfrac,1024

  notthistime:

  ; 11) If count>127, stop
  dec ycount
  jnz FracYLoop

pop es

pop edi
pop esi
pop edx
pop ecx
pop ebx
pop eax
ret

;====================================================================
; SWITCHTEXTURES - switch around the two buffers
;--------------------------------------------------------------------

; This just changes the two buffers when one has been finished; so
; that the new fractal becomes the one that gets drawn to screen, and 
; the old fractal will get written over by the one newly being
; calculated.

; This is a separate function, because if you decide to implement
; the 25% saving described above, you'll need to copy over those
; re-cycled pixels at some point, and this is a good time to do that.

; Source_____________________________________________________________

SwitchTextures:
push ax
push bx

mov ax,fractalseg
mov bx,textureseg
mov fractalseg,bx
mov textureseg,ax

pop bx
pop ax
ret

;====================================================================
;DOBACKGROUND - the background for lo-res part of demo
;--------------------------------------------------------------------

; Just draws the swirly background things, very simple.

DoBackground:
push ax
push bx
push cx
push di

push es

mov ax,0a000h
mov es,ax

mov bx,0        ; bh=y, bl=x

mov di,0
mov cx,64000
mov al,0
rep stosb

mov di,0

db_loop:
  mov al,bh
  mul bl
  and al,0fh
  add al,16
  mov es:[di],al
  inc di
  inc bx
  cmp bl,0
  jne notnextline
  add di,320-256
notnextline:
  cmp bx,256*193
  jb db_loop

mov si,0
mov di,256
push ds
push es
pop ds
mov dx,192

copy_loop:
  mov cx,32
  rep movsw
  add si,320-64
  add di,320-64
  dec dx
  jnz copy_loop

pop ds

;mov di,256*193
;mov cx,8*320
;mov al,0
;rep stosb

pop es

pop di
pop cx
pop bx
pop ax

ret

;====================================================================
;DRAWSQUARE - fills a square, for showing which way things are going
;--------------------------------------------------------------------

; I won't bother explaining this, you can all manage to draw a square
; by now...

DrawSquare:
push ax
push dx
push si
push di
push es

mov si,ax
mov ax,0a000h
mov es,ax

; bh=starty, ax(now si)=startx
; dx=width and height
; cl=colour
push dx
mov di,bx
shr di,8
mov ax,320
mul di
add ax,si
mov di,ax
pop dx

mov al,cl

mov si,dx
ds_yloop:
  mov cx,dx
  rep stosb
  add di,320
  sub di,dx
  dec si
  jnz ds_yloop

pop es
pop di
pop si
pop dx
pop ax
ret

;====================================================================
;DRAWDIRECTIONSQUARES - draw the motion direction indicators
;--------------------------------------------------------------------

; this is pretty trivial too.

DrawDirectionSquares:
push ax
push bx
push cx
push dx
push si
push di

; Clear all squares
mov bh,0        ; was 16
mov ax,0        ; was 16
mov cl,0
mov dx,32

mov si,3
dds_yloop:
  mov di,3
  dds_xloop:
    cmp di,2
    jne dds_drawit
    cmp si,2
    je dds_skipit

    dds_drawit:
    call DrawSquare

    dds_skipit:
    add ax,9*16
    dec di
    jnz dds_xloop
  mov ax,0      
  add bh,5*16   
  dec si
  jnz dds_yloop

; Draw chosen square
cmp newydirection,1
jne drawchosen
cmp newxdirection,1
je afterchosen

drawchosen:
mov ah,0
mov al,newydirection
imul ax,5*16    
mov bh,al
mov eax,0
mov al,newxdirection
mov si,9*16
mul si
mov dx,32               ; square side length
mov cl,1
call DrawSquare
add bh,4
add ax,4
sub dx,8
mov cl,0
call DrawSquare         ; clear the inside

afterchosen:
; Draw actual (current) square
cmp ydirection,1
jne drawcurrent
cmp xdirection,1
je aftercurrent

drawcurrent:
mov ah,0
mov al,ydirection
imul ax,5*16  
add ax,0        
mov bh,al
mov ah,0
mov al,xdirection
mov si,9*16
mul si
add bh,4
add ax,4                ; current square start now in bx.
mov dx,24               ; square side length
mov cl,2
call DrawSquare

aftercurrent:
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret

;====================================================================
;DOFRACTALSECTION - the controllable fractals part of the demo
;--------------------------------------------------------------------

; hopefully what with the background you have already read, this
; routine is self-explanatory.

DoFractalSection:
; Now setup fractal parameters
; Start at preplanned position
mov hxcentre,000000000h
mov lxcentre,04afadfffh
mov hycentre,0fffffffeh
mov lycentre,08f71bfffh

; and increment by 1/64 per pixel
mov hxi,0
mov lxi,1024*65536
mov hyi,0
mov lyi,1024*65536

mov screenstart,33*320+32

dfs_fracloop:

; Calculate new hxcentre etc depending on xdirection,ydirection
; (new position = FW/4*(xdirection+1),FH/4*(ydirection+1) on the display)

; xcentre=xcentre+fw/4*(xdirection-1)*xi 
cmp xdirection,1
je xchangedone
mov edx,FRACWIDTH/2
mov eax,lxi
mul edx
cmp xdirection,2
jne xchangeminus
  add lxcentre,eax
  adc hxcentre,edx
  jmp xchangedone
xchangeminus:
  sub lxcentre,eax
  sbb hxcentre,edx
xchangedone:

; Same for Y:
cmp ydirection,1
je ychangedone
mov edx,FRACHEIGHT/2
mov eax,lyi
mul edx
cmp ydirection,2
jne ychangeminus
  add lycentre,eax
  adc hycentre,edx
  jmp ychangedone
ychangeminus:
  sub lycentre,eax
  sbb hycentre,edx
ychangedone:

; Calculate start hxs,lxs hys,lys to keep hxcentre in middle (at 128,128)

; xs=xcentre-128*xi ys=ycentre-128*yi
mov eax,lxi
mov edx,FRACWIDTH/2
mul edx
mov ebx,eax     ; bx is l(xi*128)
mov ecx,edx     ; cx is h(xi*128)
xor ebx,0ffffffffh
xor ecx,0ffffffffh
inc ecx         ; cx:bx now negative'd
add ebx,lxcentre
adc ecx,hxcentre
mov lxs,ebx
mov hxs,ecx

; Same for Y:
mov eax,lyi
mov edx,FRACHEIGHT/2
mul edx
mov ebx,eax     ; bx is l(xi*128)
mov ecx,edx     ; cx is h(xi*128)
xor ebx,0ffffffffh
xor ecx,0ffffffffh
inc ecx         ; cx:bx now negative'd
add ebx,lycentre
adc ecx,hycentre
mov lys,ebx
mov hys,ecx

; Calculate next fractal while we zoom the last one
call Fractal

; Switch the texture buffers, including copying 1/4 of the pixels
call SwitchTextures

cmp nodraw,1
jne alreadydrawing
mov nodraw,0
call DoBackground
mov cx,0
alreadydrawing:

; Double magnification
mov eax,lxi
mov edx,hxi
shr eax,1
shr edx,1
mov lxi,eax
mov hxi,edx
mov lyi,eax
mov hyi,edx

; Update direction
mov al,newxdirection
mov xdirection,al
mov al,newydirection
mov ydirection,al

call DrawDirectionSquares

jmp dfs_fracloop

dfs_keyhit:

call Getch

cmp al,'7'
jne not7
mov newxdirection,0
mov newydirection,0
not7:

cmp al,'4'
jne not4
mov newxdirection,0
mov newydirection,1
not4:

cmp al,'1'
jne not1
mov newxdirection,0
mov newydirection,2
not1:

cmp al,'8'
jne not8
mov newxdirection,1
mov newydirection,0
not8:

cmp al,'5'
jne not5
mov newxdirection,1
mov newydirection,1
not5:

cmp al,'2'
jne not2
mov newxdirection,1
mov newydirection,2
not2:

cmp al,'9'
jne not9
mov newxdirection,2
mov newydirection,0
not9:

cmp al,'6'
jne not6
mov newxdirection,2
mov newydirection,1
not6:

cmp al,'3'
jne not3
mov newxdirection,2
mov newydirection,2
not3:

cmp al,27
je breakout

call DrawDirectionSquares

donethecentrechange:
jmp zt_afterkeyhit    

;====================================================================
;MAIN SECTION & MISC
;--------------------------------------------------------------------

Init:
push ax
push bx
; 1) Setup ES segment
mov ax,0a000h
mov es,ax
; 2) Allocate RAM
; This is a COM program, so we just set the segments to spare
; space in memory. (well, hopefully spare space :) 
push cs
pop ax
add ax,4096     ; textureseg is 64k above our segment
mov textureseg,ax
add ax,4096     ; and fractalseg is 128k above
mov fractalseg,ax
sub ax,4096
sub ax,2048     ; enlargebuffer is 1/2 way through our segment.
mov enlargebufferseg,ax
; 3) Do graphics mode
mov ax,0013h
int 10h
pop bx
pop ax
ret

Shutdown:
push ax
mov ax,0003h
int 10h
pop ax
ret

message db 'Thanks for watching the modified version of 4ge',39,'S XMaS 94 iNTRo.'
db 13,10,13,10
db 'Get 4ge-xmas.zip from ftp.cdrom.com for the full version, Tseng gfx only.',13,10,13,10,'$'

Start:
call Init
call DoFractalSection
breakout:
call Shutdown
mov ah,09h
mov dx,offset message
int 21h

int 20h

END

