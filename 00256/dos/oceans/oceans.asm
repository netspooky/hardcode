;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;    Oceans by Whizart
;;

org 100h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setup

mov al, 13h         ;; assume ah = 0
int 10h

push ax             ;; remember 13h for outro

xchg ax, bx         ;; assume bx = 0 => ax = 0

mov dx, 3c8h        ;; you should set color offset explicitely
out dx, al
inc dx

mov cx, 100h

mov di, sintable
push di

finit               ;; to be sure ...

set_palette:
    out dx, al
    out dx, al
    xor ax, cx
    out dx, al

make_sin_table:
    push di
    fild word [esp]                  ; s0 = di
    fmul dword [sin_table_factor]    ; s0 = di * ((2 * pi) / 255)   (f1)
    fsin                             ; s0 = sin(f1)
    fimul word [m]                   ; s0 = m * sin(f1)
    fiadd word [m]                   ; s0 = m * sin(f1) + m        (f2)
    fistp word [esp]                 ; stack empty
    pop ax                           ; ax = round(f2) = [0 .. 2m]  
    stosb    
    loop set_palette

mov ax, 1130h       ;; lookup 16x8 font location
mov bh, 6
int 10h
push es
pop fs
mov [di], bp        ;; di = sintable + 100h here -> already points to fontofs :)

pop bx              ;; set bx to sin table

push 0a000h
pop es

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; main loop

frame:
    pusha

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; moving text

    mov di, 320*5 + 5
    xchg ax, bp     ;; bp will not be used any more
    xlat
    cbw
    shl al, 1
    add di, ax
    mov si, text
txt:
    lodsb
    cmp al, eotchar
    jz plasma

    mov cl, textheight
    mul cx    
    xchg ax, bx
    add bx, word [fontofs]
  
chr:
    mov dh, byte [fs:bx]
    inc bx
    mov dl, textwidth
    
loc:
    shl dh, 1
    salc                    ;; al = -1 if carry
    neg ax                  ;; al =  1
    mul cl                  ;; al = cl
    shl al, 4               ;; al = 16 * cl
    stosb 
    dec dx
    jnz loc                 ;; after 8 iterations, dh = dl = 0 => dx = 0   
    
    xor ax, ax
    stosw

    add di, 320-10          ;; next column
    loop chr
    
    sub di, 320*16 - 10     ;; next char
    jmp txt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; plasma

plasma:
    popa
    inc bp
    inc dx
    mov di, 25*320

frame1:
    mov cl, 160
    cmp dh, 176
    je frame
    add di, 320

frame2:
    mov ax, 0cccdh
    mul di

; y
    mov al, dh
    shl ax, 1
    add ax, bp
    xlatb
    mov si, ax
     
; x
    mov al, dl
    shl al, 1
    add ax, bp
    xlatb
    add si, ax

; x + y
    mov ax, dx
    add al, ah
    sub ax, bp
    xlatb
    add si, ax
    
; x * y
    mov al, dl
    mul dh
    xchg al, ah
    add ax, bp
    xlatb
    add ax, si
    
    xor ah, ah
    stosw
    loop frame2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; check for ESC

in al, 60h
dec ax      ;; ah = 0
jnz frame1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; outro: clean up and say goodbye

pop bx                      ; bx = 13h

noiseclear: 
    in al, 40h
    shr byte [es:di], 1
    sub di, ax
    loop noiseclear
    
    dec bx
    jnz noiseclear

mov al, 3
int 10h

mov ah, 9                   ;; emit message again
mov dx, bye
int 21h

ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; constants and definitions

data:
    sin_table_factor    dd 0.0246399    ; (2 * pi) / 255
    m                   dw 31
    bye                 db eotchar
    text                db " OCEANS BY WHIZART ", eotchar, '$'

sintable    equ     200h        ;; padded to multiple of 256, after psp + code
fontofs     equ     300h        ;; after sin table
textheight  equ     16
textwidth   equ     8
eotchar     equ     10

;;                                                                           ;;
;; Oceans by Whizart                                                20.10.13 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
