;
;  SPiRAL
;
;  256b intro
;
;  spOOL^3L
;
;  (c)2001
;
cseg segment
        assume cs:cseg, ds:cseg, ss:cseg
        org 100h
        .386

INIT:    std
         mov ax,13h          ; 320x200x256colors
         int 10h

        ; -------------------
        ; PALETTA
        ; -------------------

         mov cl,0ffh         ; 256
PALMAKE: mov al,cl
         mov dx,03c8h
         out dx,al
         shr al,2
         inc dx
         out dx,al
         out dx,al
         mov bl,al
         mov al,255
         sub al,bl
         out dx,al
         loop PALMAKE

        ; --------------
        ;  TEXT
        ; --------------
        
        mov ax,1300h
        mov cx,6
        mov dh,10
        mov dl,25
        mov bl,200
        mov bh,0
        mov bp, offset LOGO
        int 10h

        mov cx,9
        mov dh,11
        mov dl,28
        mov bl,90
        mov bp, offset AUTOR
        int 10h

        mov ax,0a000h
        mov es,ax

; -------------------------------------------
;         LOOP BEGIN
; -------------------------------------------

BEGIN :

; ---------------------------------
; SPiRAL MAIN LOOP
; ---------------------------------

         mov cx,200
         mov ax,TEMP
         inc TEMP
         mov UHEL1,ax

SPIRAL:
      ; ---------
      ;  X START
      ; ---------
         mov ax,cx
         shr ax,2
         mov KRAT, ax

         finit
         fild UHEL1
         fld RADIAN
         fmul st(0),st(1)
         fsin
         fild KRAT
         fmul st(0),st(1)
         fist XS
         add XS,50

      ; -------
      ;  X END
      ; -------
         mov ax, XS
         mov XE, ax
         add XE, cx

       ; ------
       ;  LINE
       ; ------

         mov dx,cx
         push cx
         mov ax,dx
         mov bx,320
         mul bx
         mov si,ax
         add si,XS   ; line offset done
         mov al,0
         mov es:[si-1],al
         mov cx,XE
         sub cx,XS   ; loop done
         mov bx,XE
LINE :   mov bl,210
         sub bl,cl
         mov al,bl
         mov es:[si],al
         inc si
         loop LINE

         mov es:[si+1], 00h

         pop cx

         mov ax, cx
         shr ax, 4
         add UHEL1, ax

        loop SPIRAL

       ; --------------
       ;  WAIT RETRACE
       ; --------------

         mov dx,03dah          ; wait retrace
L1:      in  al,dx
         and al,08h
         jz L1


WAITKEY: in al,060h
         cmp al,1
         je KONEC
         jmp BEGIN
KONEC:   mov ax,03h
         int 10h
         ret

LOGO     db   "SPiRAL"
AUTOR    db   "spool^3el"
XS       dw   0   ; x-start
XE       dw   0   ; x-end
KRAT     dw   40  ; amplituda
UHEL1    dw   2
TEMP     dw   1
RADIAN   dq   0.017453292  ; pi/180

cseg ends
        end INIT

