;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 220 octets intro by Interface/glue ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; this is my very first coding release
;; for the demoscene (!!!), so that's the
;; explanation for this patetic code XP

;; assembled with Netwide-ASM (NASM)
;;      http://www.cryogen.com/Nasm/


;; greetings go to astharoth, k-pui0,
;; and specially to Vaw, Bp and Casty,
;; for their nice and suffered support  ;)))

;;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

org 0100h

POS     equ     1500   ; position of the logo
SIZE    equ     2000   ; size of the logo
COLS    equ     1520   ; number of columns in background
ROWS    equ     1510   ;  '' rows

        mov ax,0x0013    
        int 0x10         ;set mode 13h               

        mov ax, 0xa000   
        mov es, ax       ;show es where video is
        mov byte [SIZE], 1

        call background
        mov word[POS], 32330
        mov byte [SIZE], 20
        call draw_glue

mainloop:
        call kbhit          ;check if user is bored
        jmp mainloop

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;--    draw background               --
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

background:
       mov word [ROWS], 0
       mov word [COLS], 0
mos:   mov ax, word [COLS]
       shl ax, 4
       add ax, word [ROWS]
       mov word [1500], ax

         call draw_glue

       inc word [COLS]
       cmp word [COLS], 20  ;logos in each row (columns)
       jne mos
       mov word [COLS], 0
       add word [ROWS], 1600
       cmp word [ROWS], 64000-1600
       jne mos



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;-- draw GLUE LOGO at [POS] with [SIZE]     size --
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;bl= bit from the logo to draw
;bh= x coord. of the logo


draw_glue:
        xor     bx, bx
        mov     di, word [POS]

        xor     dh, dh
        xor     dl, dl    ; y= 0
.loop3  xor     bx, bx    ; x= 0

.loop2  movzx   si, dl
        shl     si, 1
        add     si, bx     ;(2*y)+x

        mov     ah, byte [glue_data+si]    ;data+(2*y)+x
        mov     cx, 8
.loop1  mov     al, ah
        and     al, 80h

      push dx
        mov     dh, 0   ;dh= ancho x del pixel

.lancho cmp     al, 0       ;transparency
        je      .nopaint
        mov     byte [es:di], al      ;;paint!!!
.nopaint inc     di
        inc     dh
        cmp     dh, byte[SIZE]   ; ancho=4
        jne     .lancho
      pop dx

        shl     ah, 1
        dec     cx
        jnz     .loop1

         ;-- next character at glue_data
        inc     bx
        cmp     bx, 1
        je      .loop2

      push ax
      push bx
        mov     bx, 320
        mov     ax, 16
        mul     byte [SIZE]
        sub     bx, ax
        add     di, bx       ;320-16*anchopixel
     pop bx
     pop ax
        inc     dh
        cmp     dh, byte[SIZE] ;alto del pixel=4
        jne     .loop3
        xor     dh,dh
        inc     dl
        cmp     dl, 4    ;four rows reached?
        jne     .loop3   ;next line/row

        ret      


kbhit: ;--------------------------
        mov     ah, 0x01
        int     0x16
        jnz     exit ; keypressed, exit!
        ret
exit:
        mov ax, 0003h
        int 10h      ;back to text mode
        mov ah, 0x4c
        int 21h

;***********************
;**       vbles       **
;***********************
   
glue_data db 0xE8,0xAE,0x88,0xAC,0xA8,0xA8,0xEE,0xEE   ;16x4



