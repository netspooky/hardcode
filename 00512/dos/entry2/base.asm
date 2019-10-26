

;00xxxxxx
;00xxyyyy
;00yyyyzz
;00zzzzzz
;Audiovault, Saw PLUS and Cool Edit Pro

;assumes on startup:
;ax ....... 0000h    ds ....... == cs
;bx ....... 0000h    es ....... == cs
;cx ....... 00ffh    ss ....... == cs
;dx ....... == cs    sp ....... fffeh
;si ....... 0100h    ss:sp ....     0
;di ....... fffeh    bp ....... 09xxh
;DF .......     0    PSP:0 .... cd20h

[BITS 16]
[ORG 0x100]

;push word 0x2020
;pop ax
;and ax, 0x4040
;push ax
;pop bx
; bx 0

;push bx
;pop bp


; set di+0x20 = 0x300
push word 0x2320
pop ax
sub ax, word 0x2040
push ax
pop di


; set si+0x20 = code:
push word code+0x217e-0x20 ; 0x2229
pop ax
sub ax, word 0x217e
push ax
pop si


push byte 0x22
push bx
inc sp
pop ax
inc sp
sub ax, word 0x2070
sub al, byte 0x3c

push ax
pop bp
; now bp 0x154

; setup ch for patching
push word 0x2020
pop cx


; stetup dh for patching
push bx
pop ax
dec ax
xor ax, 0x2020
push ax
pop dx


xor [byte f1+3+bp-0x154], ch ; fix1
xor [byte f2+1+bp-0x154], ch ; fix2
xor [byte f3+3+bp-0x154], ch ; fix3
xor [byte f4+1+bp-0x154], ch ; fix4
xor [byte f5+3+bp-0x154], ch ; fix5
xor [byte f6+2+bp-0x154], ch ; fix6
xor [byte f7+1+bp-0x154], ch ; fix7

xor [byte f78+0+bp-0x154], dh ; fix78a
xor [byte f78+2+bp-0x154], ch ; fix78c

xor [byte f77+0+bp-0x154], dh ; fix77a
xor [byte f77+1+bp-0x154], dh ; fix77b
xor [byte f77+2+bp-0x154], dh ; fix77c

push bx
pop bp

; start decodeing

start:

;clear dest

and [di+0x20], bx
and [di+0x22], bx

; do x...

push bx
pop ax
xor al, [si+0x20]
sub al, 0x3f

xor [di+0x20], al
inc si


push bx
pop ax

xor al, [si+0x20]
sub al, 0x3f
and al, 0x30

and [bp+0x20], bx
xor [bp+0x20], al

f1:
imul ax, [bp+0x20], byte 0x24        ; fix1 - xor 20

xor [di+0x20], al
inc di

;-  got xxxxxxxx


push bx
pop ax

xor al, [si+0x20]
sub al, 0x3f
f2:
and al, 0x2f                         ; fix2 - xor 20

xor [di+0x20], al
inc si

push bx
pop ax

xor al, [si+0x20]
sub al, 0x3f
and al, 0x3c

and [bp+0x20], bx
xor [bp+0x20], al

f3:
imul ax, [bp+0x20], byte 0x24        ; fix3 - xor 20

xor [di+0x20], al
inc di


;- got yyyyyyyy


push bx
pop ax

xor al, [si+0x20]
sub al, 0x3f
f4:
and al, 0x23                         ; fix4 - xor 20

xor [di+0x20], al
inc si

push bx
pop ax

xor al, [si+0x20]
sub al, 0x3f
and al, 0x3f

and [bp+0x20], bx
xor [bp+0x20], al

f5:
imul ax, [bp+0x20], byte 0x24        ; fix5 - xor 20

xor [di+0x20], al
inc si
inc di

;- got zzzzzzzz

push di
pop ax

f6:
cmp ax, word 0x2420                  ; fix6 - xor 20

f7:
jb gostart+0x20                      ; fix7 - xor 20

f78:
;jmp code
 db 0x36, 0x34, 0x21                 ; fix78 - special

gostart:
;jmp start
f77:
db 0x36                             ; fix77 - special
dw 0xff82^0xffff^0x2020 ; 0x205d  start^0x2020

;  db '-Coded by HeBD-', 0

code:
;mov ax, bx

; 295 bytes encoded code







