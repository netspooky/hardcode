
;
; 3d Rotation, coded by Ash [NLB/BD]
; Sorry that did'nt commented it too well :(
;


ideal
p386n

segment code
assume cs:code
org 100h

start:
                mov     ax,13h                  ; init vga
                int     10h
                push    0a000h
                pop     es

mainloop:       add     [xangle],1              ; increase x,y,z-angles
                and     [xangle],255
                add     [yangle],1
                and     [yangle],255
                add     [zangle],1
                and     [zangle],255

                mov     bx,[xangle]             ; get x,y,z,-sin/cos value
                movsx   bp,[sincos+bx]
                mov     [xsin],bp
                add     bx,64
                and     bx,255
                movsx   bp,[sincos+bx]
                mov     [xcos],bp
                mov     bx,[yangle]
                movsx   bp,[sincos+bx]
                mov     [ysin],bp
                add     bx,64
                and     bx,255
                movsx   bp,[sincos+bx]
                mov     [ycos],bp
                mov     bx,[zangle]
                movsx   bp,[sincos+bx]
                mov     [zsin],bp
                add     bx,64
                and     bx,255
                movsx   bp,[sincos+bx]
                mov     [zcos],bp

                xor     si,si
morepoints:     mov     ax,[coords+si+2]        ; do calculations
                imul    [xcos]
                mov     bp,ax
                mov     ax,[coords+si+4]
                imul    [xsin]
                sub     bp,ax
                mov     [yt],bp
                mov     ax,[coords+si+2]
                imul    [xsin]
                mov     bp,ax
                mov     ax,[coords+si+4]
                imul    [xcos]
                add     bp,ax
                mov     [zt],bp
                mov     ax,[yt]
                sar     ax,7
                mov     [y],ax
                mov     ax,[zt]
                sar     ax,7
                mov     [z],ax

                mov     ax,[coords+si]
                imul    [ycos]
                mov     bp,ax
                mov     ax,[z]
                imul    [ysin]
                sub     bp,ax
                mov     [xt],bp
                mov     ax,[coords+si]
                imul    [ysin]
                mov     bp,ax
                mov     ax,[z]
                imul    [ycos]
                add     bp,ax
                mov     [zt],bp
                mov     ax,[xt]
                sar     ax,7
                mov     [x],ax
                mov     ax,[zt]
                sar     ax,7
                mov     [z],ax

                mov     ax,[x]
                imul    [zcos]
                mov     bp,ax
                mov     ax,[y]
                imul    [zsin]
                sub     bp,ax
                mov     [xt],bp
                mov     ax,[x]
                imul    [zsin]
                mov     bp,ax
                mov     ax,[y]
                imul    [zcos]
                add     bp,ax
                mov     [yt],bp
                mov     ax,[xt]
                sar     ax,7
                mov     [x],ax
                mov     ax,[yt]
                sar     ax,7
                mov     [y],ax

                mov     ax,200
                imul    [x]
                mov     bp,[z]
                add     bp,200
                idiv    bp
                add     ax,160
                mov     cx,ax

                mov     ax,200
                imul    [y]
                mov     bp,[z]
                add     bp,200
                idiv    bp
                add     ax,100

		mov	di,ax
		shl	di,8
		shl	ax,6
		add	di,ax
		add	di,cx

                mov     [erase+si],di
                mov     [byte es:di],15

                add     si,6
                cmp     si,points
                jne     morepoints

                mov     dx,3dah
                in      al,dx
                test    al,8
                jne     $-3
                in      al,dx
                test    al,8
                je      $-3

                xor     si,si                   ; erase the points again
killem:         mov     di,[erase+si]
                mov     [byte es:di],0
                add     si,6
                cmp     si,points
                jne     killem

                in      al,60h
                cmp     al,1
                jne     mainloop

                mov     ax,3
                int     10h
                mov     ax,4c00h
                int     21h


  points        equ 200*3

  xangle        dw 0
  yangle        dw 0
  zangle        dw 0

  xsin          dw ?
  xcos          dw ?
  ysin          dw ?
  ycos          dw ?
  zsin          dw ?
  zcos          dw ?

  xt            dw ?
  yt            dw ?
  zt            dw ?

  x             dw ?
  y             dw ?
  z             dw ?

  include       "sincos.db"
  include	"coords.db"

  erase         dw points dup (?)

ends code
end start

