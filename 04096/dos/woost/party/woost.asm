;  Woost 2k2 4k-Intro
; Released @ Woest 2k2-Party
;   Blerick, Netherlands

; (c)oded @ the partyplace

;      NEBULA

; code:  east & zaxe 
; music: louk

;   www.nebulahq.com

bits 16

;################
; MIDI
;################
%define GMPORT		0331h
%define GMSEND		080h
%define GMRECV		040h

%define GMC_NOTEOFF                     080h
%define GMC_NOTEON                      090h
%define GMC_KEYPRESSURE			0A0h
%define GMC_PARAMETER			0B0h
%define GMC_PROGRAM                     0C0h
%define GMC_CHANNELPRESSURE		0D0h
%define GMC_PITCHWHEEL			0E0h

segment .bss

;################
; JULIA
;################
wC			resw 1
a_r			resd 1
a_i			resd 1

;################
; ROTOZOOMER
;################
pSinT2      resw    256     ; sine table (amp[-256..256] d[0..255])

dx_x        resw    1
dy_x        resw    1
dx_y        resw    1
dy_y        resw    1
x0          resw    1
y0          resw    1

;################
; PLASMA
;################
pSinT       resb    1024    ; sine table (amp[0..64], d[0..1024])
pDT         resb    16000
dwX         resd    1
dwY         resd    1
pXV         resb    320     ; x value array (plasma)
pYV         resb    200     ; y value array (plasma)

;################
; 3D
;################
Time resw 1
wSin resw 1
wCos resw 1

MPosition resw 32
MSrc1 resw 32
MSrc2 resw 32
MDest resw 32
Text3D resw 1836
Text3Dtf resw 1836
Bol3D   resw 528
Bol3Dtf resw 528

wBV resw 1

wP resw 1
wNV resw 1
w1 resw 1
w2 resw 1
saturate resw 1

Pic
resb 256

segment .data

;################
; JULIA
;################
r_s			dd	0.3
i_s			dd	0.6
r_d         dd  2.5e-2
i_d         dd  3.66e-2

js_r		dd	-2.0
js_i		dd	-1.5

p_r			dd	-2.0
p_i			dd	-1.5

p_r_b       dd  -2.0
p_i_b       dd  -1.5

c2			dw	2

f_t         dd  0
d_t         dd  2.0e-2

wST dw 0
wX dw 0
wY dw 0

times 111 db 0
szScroll
db ":: aardbei :: farbrausch :: sunflower :: bomb :: blasphemy :: haujobb "
db ":: 3state :: revolution :: pulse :: no attitude :: xam :: oldskool 4 ever"
times 111 db 0
szScrolllen dw $-szScroll - 111

;################
; ROTOZOOMER
;################
wRot        dw  128         ; rotozoomer rotation
wDist       dw  64          ; rotozoomer distance
bDR         db  1           ; rotozoomer delta rotation
bDD         db  3           ; rotozoomer delta distance

sx          dw  0
sy          dw  0

wT          dw  0           ; time counter
wST_r       dw  0
wMT         dw  0
wLT         dw  0

bTile
; WOEST self designed thingy
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Bh, 000h, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 009h, 00Ah, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ah, 007h, 00Bh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 007h, 001h, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 007h, 005h, 00Ch, 003h, 00Fh, 00Fh, 000h, 00Ch, 00Ch
db 009h, 00Eh, 00Fh, 00Eh, 00Ah, 00Ch, 00Bh, 003h, 001h, 000h, 00Ch, 007h, 001h, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 009h, 00Ch, 004h, 005h, 00Ch, 003h, 005h, 007h, 00Fh, 00Dh, 00Fh, 00Fh, 00Bh, 00Ch
db 001h, 00Fh, 001h, 00Fh, 003h, 00Ch, 002h, 00Fh, 00Fh, 00Fh, 00Ah, 00Fh, 00Dh, 007h, 00Ch, 00Ch
db 00Ch, 009h, 008h, 00Ch, 001h, 001h, 00Ch, 001h, 002h, 004h, 00Dh, 00Bh, 007h, 00Fh, 002h, 00Ah
db 00Fh, 005h, 00Ch, 005h, 00Fh, 00Ch, 001h, 004h, 00Ah, 00Dh, 005h, 004h, 00Eh, 005h, 00Ch, 00Ch
db 00Ch, 00Ch, 00Fh, 00Ch, 00Fh, 008h, 00Ch, 00Eh, 007h, 00Eh, 005h, 00Ch, 00Ch, 00Dh, 003h, 007h
db 00Fh, 00Ah, 00Ch, 00Ah, 00Fh, 007h, 001h, 005h, 00Ch, 005h, 005h, 007h, 001h, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 008h, 009h, 00Dh, 00Fh, 00Ch, 00Fh, 00Bh, 00Fh, 007h, 00Ch, 00Ch, 003h, 001h, 005h
db 00Fh, 00Ch, 00Ch, 00Ch, 00Fh, 000h, 001h, 00Dh, 007h, 00Ch, 00Ch, 007h, 001h, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 004h, 005h, 001h, 00Fh, 000h, 00Fh, 00Ch, 00Fh, 007h, 00Ch, 00Ch, 005h, 001h, 005h
db 00Fh, 00Fh, 00Fh, 00Fh, 00Fh, 005h, 005h, 00Fh, 00Fh, 003h, 00Bh, 007h, 001h, 00Ch, 00Ch, 00Ch
db 00Ah, 00Ch, 005h, 008h, 003h, 008h, 003h, 001h, 00Ch, 00Fh, 007h, 00Ch, 00Ch, 005h, 001h, 005h
db 00Fh, 00Fh, 00Fh, 00Fh, 00Fh, 005h, 00Bh, 004h, 00Fh, 00Fh, 003h, 007h, 001h, 00Ch, 00Ch, 00Ch
db 005h, 002h, 000h, 00Fh, 005h, 001h, 008h, 003h, 00Ch, 00Fh, 007h, 00Ch, 00Ch, 005h, 001h, 005h
db 008h, 007h, 007h, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 009h, 008h, 001h, 007h, 001h, 00Ch, 003h, 00Ch
db 00Bh, 000h, 007h, 00Fh, 000h, 006h, 00Fh, 005h, 00Ch, 00Fh, 000h, 00Ch, 00Ch, 003h, 001h, 005h
db 00Fh, 00Ch, 00Ch, 00Ch, 005h, 00Ah, 006h, 009h, 00Ch, 007h, 001h, 007h, 00Dh, 000h, 00Eh, 00Ch
db 00Ch, 00Ch, 00Ch, 00Fh, 007h, 005h, 00Fh, 007h, 00Ch, 008h, 006h, 00Ch, 00Ch, 00Dh, 003h, 000h
db 00Fh, 00Ah, 00Ch, 00Ah, 00Fh, 007h, 00Eh, 006h, 00Ch, 006h, 004h, 007h, 00Fh, 002h, 00Bh, 00Ch
db 00Ch, 00Ch, 00Ch, 000h, 00Ch, 000h, 00Fh, 00Ah, 00Ch, 003h, 00Eh, 009h, 000h, 00Fh, 002h, 00Ah
db 00Fh, 003h, 00Ch, 006h, 00Fh, 00Bh, 004h, 00Eh, 001h, 00Fh, 000h, 00Ch, 007h, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ah, 003h, 00Ch, 00Ch, 00Ah, 00Fh, 00Fh, 00Fh, 00Eh, 00Bh, 00Ch
db 001h, 00Fh, 00Dh, 00Fh, 001h, 00Ch, 007h, 00Fh, 00Fh, 003h, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 000h, 00Fh, 00Fh, 000h, 00Ch, 00Ch
db 009h, 00Eh, 00Fh, 00Eh, 009h, 00Ch, 00Ch, 009h, 009h, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ah, 007h, 00Bh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 007h, 007h, 009h, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ah, 007h, 007h, 00Bh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Bh, 005h, 00Eh, 008h, 001h, 00Fh, 008h, 00Bh, 00Ch, 00Eh, 005h, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 003h, 00Fh, 00Dh, 008h, 00Fh, 003h, 00Ah, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 004h, 00Eh, 007h, 00Ch, 00Ch, 000h, 00Fh, 007h, 00Ch, 00Fh, 005h, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ah, 00Fh, 006h, 00Ch, 00Ch, 009h, 00Dh, 00Eh, 00Ah, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 003h, 00Fh, 009h, 007h, 00Fh, 000h, 00Ch
db 009h, 001h, 004h, 00Ah, 005h, 007h, 00Ch, 00Ch, 00Ch, 005h, 00Fh, 005h, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Bh, 000h, 00Dh, 00Fh, 003h, 00Ch, 002h, 00Fh, 007h, 009h
db 00Eh, 00Eh, 009h, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Bh, 00Dh, 00Fh, 007h, 00Ch, 00Ch, 00Ch, 00Ch
db 007h, 000h, 005h, 005h, 004h, 008h, 00Fh, 00Fh, 004h, 007h, 00Ch, 00Ch, 006h, 00Fh, 003h, 00Fh
db 008h, 00Bh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Bh, 008h, 00Fh, 006h, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Fh, 00Fh, 00Dh, 001h, 003h, 005h, 007h, 00Bh, 00Ch, 00Ch, 00Ch, 00Ch, 001h, 00Fh, 00Fh, 00Fh
db 001h, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 004h, 00Fh, 003h, 00Ch, 00Ch, 00Ch, 009h, 003h, 004h
db 003h, 00Fh, 00Fh, 004h, 000h, 00Bh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Fh, 00Fh, 002h, 001h
db 00Fh, 003h, 00Ch, 00Ch, 00Ch, 00Ch, 006h, 00Fh, 008h, 00Bh, 009h, 002h, 00Dh, 00Fh, 00Eh, 005h
db 00Ch, 00Ah, 005h, 00Dh, 00Fh, 00Fh, 008h, 005h, 000h, 00Bh, 00Ch, 007h, 00Fh, 008h, 00Ch, 00Bh
db 00Dh, 00Fh, 003h, 00Ch, 00Ch, 00Ah, 00Fh, 00Fh, 001h, 00Dh, 00Fh, 00Fh, 008h, 000h, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 000h, 006h, 00Dh, 00Fh, 00Fh, 007h, 00Ch, 002h, 00Fh, 001h, 00Ch, 00Ch
db 009h, 00Eh, 00Fh, 001h, 00Bh, 005h, 00Fh, 00Fh, 00Fh, 008h, 002h, 00Ah, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ah, 000h, 00Ch, 00Ch, 003h, 00Fh, 003h, 00Ch, 00Ch
db 00Ch, 009h, 00Eh, 00Fh, 001h, 000h, 005h, 000h, 00Bh, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch
db 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch, 00Ch

mPal
db 052h, 06Fh, 091h, 01Fh, 02Ah, 037h, 046h, 060h, 07Ch, 02Fh, 040h, 053h, 027h, 035h, 045h, 03Fh
db 056h, 06Fh, 037h, 04Bh, 061h, 060h, 081h, 0A5h, 018h, 020h, 029h, 06Eh, 08Ch, 0ADh, 07Ah, 096h
db 0B4h, 089h, 0A1h, 0BCh, 097h, 0ACh, 0C4h, 010h, 016h, 01Ch, 008h, 00Bh, 00Eh, 000h, 000h, 000h

;################
; 3D            
;################
NText1 db "Nebula"
NText2 db "@ Woest"
NText3 db "presents"
NText4 db "4k-intro"

EText1 db "east"
EText2 db "zaxe"
EText3 db "Louk"
EText4 db "3509b"
EText5 db "Nebula"

Time2 dw 0

Period dw 270

Shift dw 512

bFlat db 0

SC
times 8 db 55

Bol3Dp
db 0,0,80,0,0,80,0,0,80,0,0,80,0,0,80,0,0,80,0,0,80,0,0,80,0,0,80,0,0,80,0,0,80,47,0,64,38
db 27,64,14,44,64,-14,44,64,-38,27,64,-47,0,64,-38,-27,64,-14,-44,64,14,-44,64,38,-27,64,47
db 0,64,76,0,24,61,44,24,23,72,24,-23,72,24,-61,44,24,-76,0,24,-61,-44,24,-23,-72,24,23,-72
db 24,61,-44,24,76,0,24,76,0,-24,61,44,-24,23,72,-24,-23,72,-24,-61,44,-24,-76,0,-24,-61
db -44,-24,-23,-72,-24,23,-72,-24,61,-44,-24,76,0,-24,47,0,-64,38,27,-64,14,44,-64,-14,44
db -64,-38,27,-64,-47,0,-64,-38,-27,-64,-14,-44,-64,14,-44,-64,38,-27,-64,47,0,-64,0,0,-80
db 0,0,-80,0,0,-80,0,0,-80,0,0,-80,0,0,-80,0,0,-80,0,0,-80,0,0,-80,0,0,-80,0,0,-80


;################
; MIDI
;################

frskip dw 8

m9ns
; select your drum sample!
db 37, 43, 47, 43, 40, 37, 45, 47, 43
;db 36, 42, 46, 42, 36, 44, 46, 42
m9len dw $-m9ns

m0ns
db 52, 0, 67, 0, 66, 0, 64, 71, 0, 0, 71, 0, 52, 71, 0, 71
m0len dw $-m0ns

m1ns
db 50, 0, 52, 0, 0, 0, 52, 0, 0, 0, 52, 0, 52, 50, 0, 52
m1len dw $-m1ns

m2ns
db 67, 71, 52, 0, 0, 0, 64, 69, 48, 62, 66, 47
m2len dw $-m2ns

m3ns
db 40, 0, 0, 0
m3len dw $-m3ns

m0ptr  dw 0
m0lst  db 0
m0cnt  dw 1

m9ptr  dw 0
m9lst  db 0

m3ptr  dw 0
m3lst dw 0

m2ptr  dw 0
m2lst0 dw 0
m2lst1 dw 0
m2lst2 dw 0

m1ptr  dw 0
m1lst  dw 0

wMC    dw 0
wMB    dw 0
wME    dw 0

segment .text

org 100h

ENTRY:
	finit					; initialize FPU (coprocessor)
	mov ax, 013h
	int 010h

	push word 0A000h		; screen address segment
	pop es					; move to es

    mov ax, cs
    add ax, 4096
    push ax
    pop fs

;################
; MIDI
;################

  call ResetGM                  ; initialize midi interface

  mov al, 0                     ; channel 0
  or al, GMC_PROGRAM            ; change program (instrument) command
  call WriteGM                  ; issue command
  mov al, 87                    ; load instrument value
  call WriteGM                  ; write data

  mov al, 1                     ; channel 1
  or al, GMC_PROGRAM            ; change program (instrument) command
  call WriteGM                  ; issue command
  mov al, 67                    ; load instrument value
  call WriteGM                  ; write data

  mov al, 2                     ; channel 2
  or al, GMC_PROGRAM            ; change program (instrument) command
  call WriteGM                  ; issue command
  mov al, 0                     ; load instrument value
  call WriteGM                  ; write data

  mov al, 3                     ; channel 3
  or al, GMC_PROGRAM            ; change program (instrument) command
  call WriteGM                  ; issue command
  mov al, 51                    ; load instrument value
  call WriteGM                  ; write data

;**************************************
; Build sine table for fSine
;**************************************
    xor cx, cx              ; counter = 0
    mov bx, pSinT           ; load sine table address
BuildSinT:
    mov word[wC], cx;
    fldpi                   ; 0(pi)
    fimul word[wC]          ; 0(pi * x)
    mov word[wC], 512
    fidiv word[wC]          ; 0(pi * x / 512)
    fsin                    ; 0(sin(pi * x / 512)
    mov word[wC], 20
    fimul word[wC]          ; 0(32 * sin(pi * x / 512))
    mov word[wC], 21
    fiadd word[wC]          ; 0(32 + 32 * sin(pi * x / 512))
    fistp word[wC]          ; store to c

    mov dx, word[wC]        ; dx = 32 + 32 * sin(pi * x / 512)
    mov [bx], dl            ; pSinT[1024 - cx] = 32 + 32 * sin(pi * x / 512)
    inc bx
    inc cx                  ; c++
    cmp cx, 1024            ; check counter against 1024
    jnz BuildSinT           ; while (c < 1024) loop

;**************************************
; Build quarter distance table
;**************************************
    mov bx, pDT             ; load distance table
    mov word[wY], 0         ; for (y=0; y<100; y++)
    mov word[wX], 0         ; for (x=0; x<160; x++)
BuildDT:
    xor eax, eax            ; eax = 0
    mov ax, word[wX]                ; ax = x
    mul al                  ; ax = x^2
    mov cx, ax              ; cx = x^2
    mov ax, word[wY]                ; ax = y
    mul al                  ; ax = y^2
    add ax, cx              ; cx = x^2 + y^2
    mov dword[dwX], eax     ; dwX = long(x^2 + y^2) (eax coz of sign)
    fild dword[dwX]         ; 0(x^2 + y^2)
    fsqrt                   ; 0(sqrt(x^2 + y^2)
    fistp word[wC]          ; store to int wC
    mov ax, word[wC]        ; ax = (word)sqrt(x^2 + y^2)
    shl ax, 3               ; ax = (word)sqrt(x^2 + y^2) * 8
    call fSine              ; ax = fsin(sqrt(x^2 + y^2) * 8)

    mov [bx], al            ; write to distance table
    inc bx                  ; bx++

    inc word[wX]            ; x++
    cmp word[wX], 160       ; if (x > 160)
    jb BuildDTl0
    mov word[wX], 0         ; then x = 0
    inc word[wY]            ; and y++
BuildDTl0:
    cmp word[wY], 100       ; if (y < 100)
    jb BuildDT              ; then loop

;**************************************
; Build sine table for fSine2
;**************************************
    mov cx, 256
BuildSinT2:
    mov word[wC], cx
    fldpi                   ; 0(pi)
    fimul word[wC]          ; 0(pi * x)
    mov word[wC], 128
    fidiv word[wC]          ; 0(pi * x / 128)
    fsin                    ; 0(sin(pi * x / 128)
    mov word[wC], 256
    fimul word[wC]          ; 0(256 * sin(pi * x / 128))
    fistp word[wC]          ; store to c

    mov dx, word[wC]                ; dx = 256 * sin(pi * x / 128)
    mov bx, pSinT2          ; load sine table address
    add bx, 512             ; add 256 * sizeof(word)
    sub bx, cx
    sub bx, cx              ; substract cx * sizeof(word)
    mov [bx], dx            ; pSinT2[256 - cx] = 256 * sin(pi * x / 128)
    dec cx                  ; c--
    jnz BuildSinT2          ; while (c > 0) loop


;################
; Set Palette
;################
    xor ax, ax
    xor bx, bx
    mov dx, 03C8h
    out dx, al
    inc dx

Pal:
    mov ax, bx
    shr ax, 3

    out dx, al
    out dx, al
    shl ax, 1
    out dx, al

    inc bx
    cmp bx, 239
    jne Pal

    mov al, 255
    out dx, al
    out dx, al
    out dx, al 

;**************************************
; Build graphics palette
;**************************************
    mov al, 240
    mov dx, 03c8h
    out dx, al

    inc dx

    mov cx, 48
    mov bx, mPal
PalLoop:
    mov al, [bx]
    shr al, 2
    out dx, al
    inc bx
    loop PalLoop

;################
; 3D INIT
;################
	call CalcPic
	call CalcBol

	mov si, NText1
	mov cx, 6
	call ConstructText

;################
; MAIN LOOP
;################
MainSystem:

    inc word [wMT]
    mov ax, [wMT]
	
    cmp ax, 1050
    ja SC2
    push ax
    call PLASMA_MainLoop
    pop ax
    call BolScene
    jmp Continue
SC2:

    cmp ax,1600
    ja SC3
    mov word[frskip], 3
    call JULIA_MainLoop
    jmp Continue

SC3:
    cmp ax, 2150
    ja SC4
    mov word[frskip], 8
    
    call ROTO_MainLoop
    jmp Continue
SC4:
    push ax
    call PLASMA_MainLoop
    pop ax
    call ExtroScene
	
Continue:
    call MidiFunction

    call WaitRetrace        ; wait for vertical retrace

    xor bx, bx
CopyScreen:
    movq mm0, [fs:bx]
    movq [es:bx], mm0
    add bx, 8
    cmp bx, 64000
    jne CopyScreen

    xor bx, bx
    pxor mm0, mm0
ClrScr:
    movq [fs:bx], mm0
    add bx, 8
    cmp bx, 64000
    jne ClrScr

    emms

    mov ah, 01h
    int 16h                 ; check if key pressed
    jnz QuitKB              ; if so, end program

    jmp MainSystem          ; loop the loop!

QuitKB:

    mov ah, 00h
    int 16h                 ; remove keypress from buffer

QuitT:

    mov ax, 03h
    int 10h                 ; switch to screen mode 03h (text)

    ret                     ; terminate program

;##################################################################

ExtroScene:
        mov ax, word[wLT]
        cmp ax, 0
	jne ES1

        mov [wLT], word 0
	mov [bFlat], byte 1
	mov [Time], word -20
	mov si, EText1
	mov cx, 4
	call ConstructText
        jmp ES5
ES1:
        mov ax, word[wLT]
        cmp ax, 190
	jne ES2
	
	mov [Time], word -20
	mov si, EText2
	mov cx, 4
	call ConstructText
        jmp ES5

ES2:
        mov ax, word[wLT]
	cmp ax, 380
	jne ES3
	
	mov [Time], word -20
	mov si, EText3
	mov cx, 4
	call ConstructText
        jmp ES5

ES3:

        mov ax, word[wLT]
        cmp ax, 570
        jne ES4
	
	mov [Time], word -20
        mov si, EText4
        mov cx, 5
	call ConstructText
        jmp ES5
ES4:
        mov ax, word[wLT]
        cmp ax, 750
        jne ES5
	
	mov [Time], word -20
        mov si, EText5
        mov cx, 6
	call ConstructText


ES5:
        call DrawBars

        add word[wLT], 1
	add word[Time], 1
	call CM_YR
	call CM_XR
	call MulMatrix

	mov si, Text3D
	mov cx, [wNV]
	mov bx, Text3Dtf
	call RenderCoords	

	ret


; WaitRetrace - waits for vertical retrace
; removes flickering and limits to 60 fps
WaitRetrace
    push dx
    push ax                 ; don't mess up regs
    mov dx, 03DAh           ; address for cathode ray beam
wr0:
    in al, dx               ; check beam status
    test al, 8              ; on screen?
    jnz wr0                 ; wait until it's done
wr1:
    in al, dx               ; check beam status
    test al, 8              ; off screen?
    jz wr1                  ; wait unwill it's done
    pop ax
    pop dx                  ; restore regs
    ret

;################
; JULIA CODE
;################
JULIA_MainLoop:

    fld dword[f_t]          ; 0(t)
    fsin                    ; 0(sin(t))
    fld st0                 ; 0(sin(t)) 1(sin(t))
    fmul st0                ; 0(sin^2(t)) 1(sin(t))
    fmulp st1, st0          ; 0(sin^3(t))

    fld dword[f_t]          ; 0(t)
    fcos                    ; 0(sin(t))
    fld st0                 ; 0(sin(t)) 1(sin(t))
    fmul st0                ; 0(sin^2(t)) 1(sin(t))
    fmulp st1, st0          ; 0(sin^3(t))

    call Julia

    push dword[p_r_b]
    pop dword[p_r]
    push dword[p_i_b]
    pop dword[p_i]

    fstp st0
    fstp st0

    fld dword[f_t]          ; 0(t)
    fld dword[d_t]          ; 1(dt) 0(t)
    faddp st1, st0          ; 0(t + dt)
    fstp dword[f_t]         ; store into t (so basically t += dt)

    call SINESCROLL_MainLoop

    ret

Julia:
    mov bx, 18*320          ; screen address = 0

    mov ax, 18              ; y counter = 0
YLoop:
	xor cx, cx				; x counter = 0
XLoop:
	fld dword[p_i]			; 0(z_i) 1(a_r) 2(a_i)
	fld dword[p_r]			; 0(z_r) 1(z_i) 2(a_r) 3(a_i)
	xor dl, dl				; color = 0
CLoop:
	fld st1					; 0(z_i) 1(z_r) 2(z_i) 3(a_r) 4(a_i)
	fld st1					; 0(z_r) 1(z_i) 2(z_r) 3(z_i) 4(a_r) 5(a_i)

	fmul st0				; 0(z_r^2) 1(z_i) 2(z_r) 3(z_i) 4(a_r) 5(a_i)
	fxch st1				; 0(z_i) 1(z_r^2) 2(z_r) 3(z_i) 4(a_r) 5(a_i)
	fmul st0				; 0(z_i^2) 1(z_r^2) 2(z_r) 3(z_i) 4(a_r) 5(a_i)
	fsubp st1, st0			; 0(z_i^2-z_r^2) 1(z_r) 2(z_i) 3(a_r) 4(a_i)

	fld st3					; 0(a_r) 1(z_i^2-z_r^2) 2(z_r) 3(z_i) 4(a_r) 5(a_i)
	faddp st1, st0			; 0(z_r') 1(z_r) 2(z_i) 3(a_r) 4(a_i)
	fxch st5				; 0(?) 1(z_r) 2(z_i) 3(a_r) 4(a_i) 5(z_r')
	fstp st0				; 0(z_r) 1(z_i) 2(a_r) 3(a_i) 4(z_r')

	fild word[c2]			; 0(2) 1(z_r) 2(z_i) 3(a_r) 4(a_i) 5(z_r')
	fmulp st1, st0			; 0(2*z_r) 1(z_i) 2(a_r) 3(a_i) 4(z_r')
	fmulp st1, st0			; 0(2*z_r*z_i) 1(a_r) 2(a_i) 3(z_r')
	fld st2					; 0(a_i) 1(2*z_r*z_i) 2(a_r) 3(a_i) 4(z_r')
	faddp st1, st0			; 0(z_i') 1(a_r) 2(a_i) 3(z_r')
	fxch st4				; 0(?) 1(a_r) 2(a_i) 3(z_r') 4(z_i')
	fstp st0				; 0(a_r) 1(a_i) 2(z_r') 3(z_i')

	fxch st2				; 0(z_r') 1(a_i) 2(a_r) 3(z_i')
	fxch st1				; 0(a_i) 1(z_r') 2(a_r) 3(z_i')
	fxch st3				; 0(z_i') 1(z_r') 2(a_r) 3(a_i)
	fxch st1				; 0(z_r') 1(z_i') 2(a_r) 3(a_i)

	fld	st0					; 0(z_r') 1(z_i') 2(z_r') 3(a_r) 4(a_i)
	fmul st0				; 0(z_r'^2) 1(z_i') 2(z_r') 3(a_r) 4(a_i)
	fistp word[wC]			; 0(z_i') 1(z_r') 2(a_r) 3(a_i)
	cmp word[wC], 4
	ja ECLoop

	inc dl
    and dl, 15
	jnz CLoop
ECLoop:
    shl dl, 3
    and dl, dl
    jz xxx
    add dl, 96
    jmp yyy
xxx:
    mov dl, 238
yyy:

	fstp st0				; 0(z_i) 1(a_r) 2(a_i)
	fstp st0				; 0(a_r) 1(a_i)

	fld dword[p_i]
	fld dword[p_r]

	fld dword[r_d]			; 0(r_d) 1(a_r) 2(a_i)
	faddp st1, st0			; 0(a_r') 1(a_i)

	fstp dword[p_r]
	fstp dword[p_i]

    mov [fs:bx], dl
	inc bx
    mov [fs:bx], dl
    inc bx

	inc cx
    inc cx
	cmp cx, 320
	jb near XLoop

	fld dword[p_i]
	fld dword[p_r]

	fld dword[i_d]			; 0(i_d) 1(a_r) 2(a_i)
	faddp st2, st0			; 0(a_r) 1(a_i')

	fld dword[js_r]			; 0(r_s) 1(a_r) 2(a_i)
	fxch st1				; 0(a_r) 1(r_s) 2(a_i)
	fstp st0				; 0(a_r') 1(a_i)

	fstp dword[p_r]
	fstp dword[p_i]

	inc ax
    inc ax

    add bx, 320

    cmp ax, 182
	jb near YLoop

    ret

;**************************************
; Sine scroller
;**************************************
SINESCROLL_MainLoop:
    xor ax, ax              ; zero scroller-pixel position
SSMLoop0:
    mov dx, word[wST]
    shr dx, 1

    push ax
    add ax, dx
    shr ax, 3
    and ax, 0FFh
    mov word[wX], ax        ; scroller-position x
    pop ax

    push ax
    add ax, dx
    and ax, 7
    neg ax
    add ax, 8
    mov word[wY], ax        ; scroller position y
    pop ax

    xor cx, cx              ; in-character x position
SSMLoop1:

    push word 0FFA6h
    pop es

    xor dh, dh
    mov bx, szScroll
    add bx, word[wX]
    mov dl, [bx]            ; load current text character
    shl dx, 3               
    add dx, cx              ; compute bitarray offset

    mov bx, dx
    add bx, 0Eh

    mov dx, [es:bx]         ; fetch bitpattern
    push cx
    mov cx, word[wY]
    mov bx, 1
    shl bx, cl
    pop cx

    push word 0A000h
    pop es

    and dx, bx              ; mask bitpattern
    jz SSMLabel0
    mov dl, 239
    jmp SSMLabel1
SSMLabel0:
    mov dl, 0
SSMLabel1:

    mov bx, cx
    imul bx, bx, 320
    shl bx, 1
    push dx
    mov dx, ax
    shl dx, 2
    add bx, dx
    pop dx

    mov byte[fs:bx], dl
    mov byte[fs:bx+1], dl
    mov byte[fs:bx+2], dl
    mov byte[fs:bx+3], dl

    inc cx
    and cx, 7
    jnz near SSMLoop1

    inc ax
    cmp ax, 80
    jb near SSMLoop0

    inc word[wST]
    inc word[wST]
    and word[wST], 4095     ; 2 * 8 * strlen - 1

; Second scroller

    xor ax, ax              ; zero scroller-pixel position
SSMLoop02:
    mov dx, word[wST]
    shr dx, 1

    push ax
    add ax, dx
    shr ax, 3
    and ax, 0FFh
    mov word[wX], ax        ; scroller-position x
    pop ax

    push ax
    add ax, dx
    and ax, 7
    neg ax
    add ax, 8
    mov word[wY], ax        ; scroller position y
    pop ax

    xor cx, cx              ; in-character x position
SSMLoop12:

    push word 0FFA6h
    pop es

    xor dh, dh
    mov bx, szScroll
    add bx, word[szScrolllen]
    sub bx, word[wX]
    mov dl, [bx]            ; load current text character
    shl dx, 3               
    add dx, cx              ; compute bitarray offset

    mov bx, dx
    add bx, 0Eh

    mov dx, [es:bx]         ; fetch bitpattern
    push cx
    mov cx, word[wY]
    mov bx, 080h
    dec cl
    shr bx, cl
    pop cx

    push word 0A000h
    pop es

    and dx, bx              ; mask bitpattern
    jz SSMLabel02
    mov dl, 239
    jmp SSMLabel12
SSMLabel02:
    mov dl, 0
SSMLabel12:

    mov bx, cx
    add bx, 92
    imul bx, bx, 320
    shl bx, 1
    push dx
    mov dx, 80
    sub dx, ax
    shl dx, 2
    add bx, dx
    pop dx

    mov byte[fs:bx], dl
    mov byte[fs:bx+1], dl
    mov byte[fs:bx+2], dl
    mov byte[fs:bx+3], dl

    inc cx
    and cx, 7
    jnz near SSMLoop12

    inc ax
    cmp ax, 80
    jb near SSMLoop02

    inc word[wST]
    inc word[wST]
    and word[wST], 4095     ; 2 * 8 * strlen - 1

    ret

;**************************************
; ROTOZOOMER mainloop
;**************************************
ROTO_MainLoop:
    mov ax, word[wRot]
    add ax, 64
    call fSine2
    cwde
    xor ebx, ebx
    mov bx, word[wDist]
    imul ebx
    sar eax, 5
    mov word[dx_x], ax

    mov ax, word[wRot]
    call fSine2
    cwde
    xor ebx, ebx
    mov bx, word[wDist]
    imul ebx
    sar eax, 8
    mov word[dy_x], ax

    mov ax, word[wRot]
    add ax, 128
    call fSine2
    cwde
    xor ebx, ebx
    mov bx, word[wDist]
    imul ebx
    sar eax, 5
    mov word[dx_y], ax

    mov ax, word[wRot]
    add ax, 64
    call fSine2
    cwde
    xor ebx, ebx
    mov bx, word[wDist]
    imul ebx
    sar eax, 8
    mov word[dy_y], ax

    imul dx, word[dx_x], 160
    imul bx, word[dx_y], 100
    mov ax, word[sx]
    sub ax, dx
    sub ax, bx
    mov word[x0], ax

    imul dx, word[dy_x], 160
    imul bx, word[dy_y], 100
    mov ax, word[sy]
    sub ax, dx
    sub ax, bx
    mov word[y0], ax

    mov word[wY], 0
RotoY:
    mov ax, word[x0]
    mov dx, word[y0]

    mov word[wX], 0
RotoX:
    mov ch, dh
    mov cl, ah
    shr cx, 3
    and cx, 03FFh
    mov bx, bTile
    add bx, cx

    push dx
    mov dx, [bx]
    imul bx, word[wY], 320
    add bx, word[wX]
    add dx, 240
    mov [fs:bx], dx
    pop dx

    add ax, word[dx_x]
    add dx, word[dy_x]

    inc word[wX]
    cmp word[wX], 320
    jb RotoX

    mov ax, word[dx_y]
    mov dx, word[dy_y]
    add word[x0], ax
    add word[y0], dx

    inc word[wY]
    cmp word[wY], 200
    jb RotoY

    mov al, byte[bDR]
    cbw
    add word[wRot], ax
    and word[wRot], 0FFh

    mov al, byte[bDD]
    cbw
    add word[wDist], ax
    cmp word[wDist], 254
    jb NoDist
    neg byte[bDD]
    jmp NoDist2
NoDist:
    cmp word[wDist], 50
    ja NoDist2
    neg byte[bDD]
NoDist2:

    add word[sy], 512

    ret

;**************************************
; PLASMA mainloop
;**************************************
PLASMA_MainLoop:
    xor cx, cx              ; cx = 0
    mov bx, pXV             ; load pXV address
calcX:
    mov ax, cx              ; ax = x
    imul ax, 3              ; ax = 3 * x
    add ax, word[wT]                ; ax = 3 * x + t
    call fSine              ; ax = fsin(3 * x + t)
    mov [bx], al            ; pXV[x] = fsin(3 * x + t)

    mov ax, cx              ; ax = x
    shl ax, 2               ; ax = 4 * x
    sub ax, word[wT]        ; ax = 4 * x - t
    sub ax, word[wT]        ; ax = 4 * x - 2 * t
    call fSine              ; ax = fsin(4 * x - 2 * t)
    add [bx], al            ; pXV[x] = fsin(3 * x + t) + fsin(4 * x - 2 * t)

    inc cx                  ; x++
    inc bx
    cmp cx, 320
    jb calcX                ; while (x < 320)

    xor cx, cx              ; cx = 200
    mov bx, pYV             ; load pYV address
calcY:
    mov ax, cx              ; ax = y
    shl ax, 2               ; ax = 4 * y
    add ax, word[wT]                ; ax = 4 * y + t
    add ax, word[wT]                ; ax = 4 * y + 2 * t
    call fSine              ; ax = fsin(3 * y + t)
    mov [bx], al            ; pYV[y] = fsin(4 * y + 2 * t)

    mov ax, cx              ; ax = y
    shl ax, 1               ; ax = 2 * y
    sub ax, word[wT]                ; ax = 2 * y - t
    call fSine              ; ax = fsin(2 * y - t)
    add [bx], al            ; pYV[y] = fsin(4 * y + 2 * t) + fsin(2 * y - t)

    inc cx                  ; y++
    inc bx
    cmp cx, 200
    jb calcY                ; while (y < 200)

    mov cx, 0               ; pixel counter
    mov word[wX], 0         ; x counter
    mov word[wY], 0         ; y counter (inv: 320 * y + x == c)

ScreenLoop:
    xor dx, dx              ; start with color 0

    mov ax, word[wY]        ; ax = y
    shr ax, 1               ; ax = y / 2
    imul ax, 160            ; ax = 160 * (y / 2)

    mov bx, word[wX]                ; bx = x
    shr bx, 1               ; bx = x / 2
    add ax, bx              ; ax = 160 * (y / 2) + x / 2

    mov bx, pDT             ; load distance table
    add bx, ax              ; bx = &pDT + 160 * (y / 2) + x / 2
    mov dl, [bx]            ; read value, dx = fsin(sqrt(x^2 + y^2) / 8)

    mov bx, pXV             ; load pVX address
    add bx, word[wX]
    add dl, [bx]            ; add up to current color

    mov bx, pYV             ; load pVX address
    add bx, word[wY]
    add dl, [bx]            ; add up to current color

;    shr dx, 1               ; use lower part of palette

    inc word[wX]            ; x++
    cmp word[wX], 320       ; check x to 320
    jb SLNext               ; if >=,
    mov word[wX], 0         ; x = 0
    inc word[wY]            ; y++
SLNext:

    mov bx, cx              ; load pixel offset
    mov [fs:bx], dl         ; write pixel color
    inc cx                  ; go to next pixel
    cmp cx, 64000           ; check cx to 64000
    jb ScreenLoop           ; if <, do next pixel

    add word[wT], 4         ; t += 4
    and word[wT], 03FFh     ; t %= 1024

    ret


;################
; 3D START
;################

BolScene:
;******* SET MATRICES BOL ********

	cmp ax, 300
	jne Text1
	
	mov si, NText2
      mov cx, 7
	call ConstructText
	
Text1:
	cmp ax, 585
	jne Text2

      mov si, NText3
	mov cx, 8
	call ConstructText

Text2:
      cmp ax, 720
      jne Text3

      mov si, NText4
	mov cx, 8
	call ConstructText

Text3:

	call CM_YR
	
      sub word[Time], 1

	push word[Time]
	mov word[Time], 20

;****** 3D TEXT *******************

	call CM_XR
	call MulMatrix	

	mov si, Text3D
	mov cx, [wNV]
	mov bx, Text3Dtf
	call RenderCoords	

	pop word[Time]
	call CM_XR
	call MulMatrix

;******* BOL COORDS **************

	mov si, Bol3D
	mov cx, word 66
	mov bx, Bol3Dtf
	call RenderCoords

;******* BOL LINES ***************
	
	mov cx, 56
loop3:
	pusha
	mov ax, [bx+0]
	mov cx, [bx+8]
	mov dx, [bx+10]
	mov bx, [bx+2]
	call bline
	popa
	add bx, 8
	loop loop3
	
	mov bx, Bol3Dtf
	mov cx, word 55
loop5:
	pusha
	mov ax, [bx+0]
	mov cx, [bx+88]
	mov dx, [bx+90]
	mov bx, [bx+2]
	call bline
	popa
	add bx, 8
	loop loop5

	ret

;**********************************

RenderCoords:

	pusha

RC1:
	pusha
	call TransformCrd
	popa
	add bx, 8
	add si, 8
	loop RC1

	popa
	ret

CM_XR:					; ConstructMatrix::X-Rotation

    push bp
    mov bp, MSrc1
	call MakeSin
	
	mov [bp+8], bx
	mov [bp+10], ax
	mov [bp+12], dword 0

	mov [bp+0], ax		
	neg bx
	mov [bp+2], bx
	mov [bp+4], dword 0

	mov [bp+16], dword 0
        mov [bp+20], word 512
	mov [bp+22], word 0

	mov [bp+24], dword 0
	mov [bp+28], dword 0
    pop bp

	ret

CM_YR:					; ConstructMatrix::Y-Rotation

    push bp
    mov bp, MSrc2
	push word[Period]
	shr word[Period], 2

	call MakeSin
	
	mov [bp+8], word 0
        mov [bp+10], word 512
        mov [bp+12], dword 0

	mov [bp+16], bx
	mov [bp+18], word 0
	mov [bp+20], ax
	mov [bp+22], word 0

	mov [bp+0], ax		
	mov [bp+2], word 0
	neg bx
	mov [bp+4], bx
	mov [bp+6], word 0

	mov [bp+24], dword 0
	mov [bp+28], dword 0
	pop word[Period]
    pop bp

	ret

MakeSin:

	fldpi
	fimul word[Time]
	fidiv word[Period]
	fld st0
	fsin
	fimul word[Shift]
	fistp word[wSin]

	fcos
	fimul word[Shift]
	fistp word[wCos]

	mov ax, word[wCos]
	mov bx, word[wSin]
	
	ret
	
	
TransformCrd:				; WERKT, maar evt uitschr voor hele matrix ivm speed
					; src in bx
					; dest in ax
					; MPosition = matrix

	push bx

	movq mm0, [si]			; coordinaat in mm0
	mov eax, 0FFFFh			; word-bitmask in ax
	mov cx, 3			; 3 rows iteraten
	movd mm7, eax			; wordbitmask naar mm7
	pxor mm6, mm6			; mm6 := 0
	xor si, si
	
TFC1:
	movq mm1, mm0			; coordinaat in mm1
	pmaddwd mm1, [MPosition+si]	; dot product mm1 met mm5
	movq mm2, mm1			; 2 dw in mm1 --> mm2
	psrlq mm2, 32			; h.o. dw mm2 --> l.o. dw
	paddd mm1, mm2			; mm1 := mm1 + mm2 == result
	add si, 8			; volgende row
	psrlq mm1, 9			; terugshiften fixed point
	pand mm1, mm7			; &-en naar word
	psllq mm6, 16			; plaats maken in mm6
	por mm6, mm1			; nieuw word schrijven in mm6

	loop TFC1

	movq [bx], mm6			; en schrijven naar dest

	mov dx, [Shift]
	mov ax, [bx+4]			; vector.x in ax

	mov cx, [bx+0]			; vector.z in cx
      add cx, 1400

	push dx
	mov dl, byte[bFlat]
      and dl, dl
      jz near FLATZ
	sub cx, 300
FLATZ:
	pop dx
	imul dx

	idiv cx				; deel door z
	push ax				; ff opslaan
	add ax, 160
	mov [bx+0], ax

	mov dx, [Shift]
	mov ax, [bx+2]			; vector.y in ax

	imul dx

	idiv cx				; deel door z
	
	mov [bx+2], ax
	add [bx+2], word 100
	pop bx				; laad x in bx

	imul ax, 320	 		; mul ax (==y) met 320
	add bx, 32160

	add bx, ax			; x + y*320
        mov word[saturate], word 238
	call PutPicTrans
	
	emms

	pop bx
	
	ret
	

PlotCrd:				; plot transformed y, x 
	
	ret


;******* Put Transparent Pic **************

PutPicTrans:
	
	mov edx, Pic				; *src in edx

	mov cx, word 16				; height in cx

	mov ax, word 16				; width in ax
	mov si, ax 	    			; store width in si

	tsyloop:
	tsxloop:

	pusha
	mov al, [edx]				

	sub bx, 2568

	mov cl, [fs:bx]				

	add ax, cx
	cmp ax, word[saturate]
	cmova ax, word[saturate]

	mov [fs:bx], al				; store in buffer
	
	popa
	add edx, 1				; volgende 8
	add bx, 1

	dec ax
	jnz tsxloop

	mov ax, si				; reset ax
	add bx, 320				; volgende regel

	sub bx, ax				; terug naar begin bmp

	loop tsyloop

	ret


CalcPic:
	mov dx, 16
	xor bx, bx
CP1:
	mov cx, 16
CP2:
	push cx

	mov ax, cx
	sub ax, 8
	test ax, 128
	jz CP3
	neg ax
CP3:
	mul al
	mov word[w1], ax
	mov ax, dx
	sub ax, 8
	test ax, 128
	jz CP4
	neg ax
CP4:	
	mul al
	add word[w1], ax
	shl word[w1], 1
	fild word[w1]
	fsqrt
	
	fistp word[w1]
	mov ax, word[w1]
	neg ax
	add al, 8
	test ax, 128
	jz CP5
	xor ax, ax
CP5:		
	shl ax, 4
	mov [Pic+bx], al

	pop cx
	inc bx
	loop CP2

	dec dx
	jnz CP1

	ret	


bline
;trekt een lijn van (ax, bx) naar (cx, dx)
  	push bp
	push ax                       
  	push bx                       
  	mov bx,4340h                  
  	sub cx,ax                     
  	jns deltax_ok                 
  	neg cx                        
  	mov bl,48h                    
deltax_ok:
  	mov bp,sp                    
  	sub dx,[ss:bp]                
  	jns deltay_ok                 
  	neg dx                        
  	mov bh,4bh                    
deltay_ok:
  	mov si,dx                     
  	or si,cx                      
  	jne ok
  	add sp,6                     
  	ret
ok:
  	mov word [dist_pos],bx        
  	cmp cx,dx                    
  	jge deltax_grootte
  	xchg cx,dx                    
  	mov bl,90h                    
  	jmp constanten
deltax_grootte:
  	mov bh,90h                    
constanten:
  	mov word[dist_neg],bx         
  	shl dx,1                      
  	mov di,dx                     
  	sub dx,cx                     
  	mov bp,dx                     
  	mov si,bp                     
  	sub si,cx                     

  	pop bx                        ;opgeslagen waarden x0 en y0 terughalen
  	pop ax
loop_p:
  	push bx
  	push ax
  	imul bx, 320
  	add bx, ax
        mov byte [fs:bx], 238
  	pop ax
  	pop bx
  	or bp,bp                      
  	jns dist_pos
dist_neg:
  	inc ax                        
  	inc bx                        
 	add bp,di                     
  	loop loop_p                   
  	jmp ready                     
dist_pos:
  	inc ax                        
 	inc bx                        
  	add bp,si                     
  	loop loop_p                   
ready:
  	pop bp
  	ret

MulVector:
	

	;smc
	mov word [MulvSMC2], 0E908h
	mov byte [MulvSMC2+2], 0

MulMatrix:		; M1 * M2 = M3
			; M1 in Arg1
			; M2 in Arg2
			; M3 = MPosition

	mov cx, 3
	xor di, di
	mov si, word 26
	push di
ML0:			; dest column loop
	mov bp, MSrc1
ML1:			; di loop	
	pop bx		; offset bx = offs. di (== kolom)
	push bx
	xor dx, dx
ML2:			; bx loop	
	push dx
	mov ax, [bp]

    imul word [MSrc2+bx] 
	idiv word [Shift]
	
	pop dx
	add dx, ax

MulvSMC1:
	add bl, 8	; een row naar onder
	inc bp		; een veld naar rechts
	inc bp

	cmp bx, si	; alle rows gehad?
	jb ML2

	mov [MPosition+di], dx
	add di, 8	; dest veld --> volgende row
	cmp di, si
	jb ML1 	

MulvSMC2:
	nop
	nop
	nop

	inc si
	inc si

	pop di		; offset di loaden / resetten
	inc di
	inc di
	push di		; store voor later

	loop ML0
MulEND:
	pop di

	ret


CalcBol:

	xor di, di	; [bol3dp + di]
	xor bx, bx	; [bol3d  + bx]

	mov cx, 66

Bolloop:

	mov dx, 2

	mov al, byte [Bol3Dp + di + 0]
	cbw
	mul dx
	mov [Bol3D + bx + 2], ax

	mov dx, 2
	mov al, byte [Bol3Dp + di + 1]
	cbw
	mul dx
	mov [Bol3D + bx + 4], ax

	mov dx,2
	mov al, byte [Bol3Dp + di + 2]
	cbw
	mul dx
	mov [Bol3D + bx + 0], ax

	mov [Bol3D + bx + 6], word 0

	add di, word 3
	add bx, word 8

	loop Bolloop

	ret

;******* Construct 3D-Text ***********************
ConstructText:

	mov di, cx
	shl di, 5

	push word 0FFA6h
	pop gs

	mov word[wP],  0
	mov word[wNV], 0
	xor dx, dx
	mov word[wX], 0
;        mov cx, 6

PL0:
	push cx
	xor bh, bh
	xor dx, dx

	mov bl, [si]
	inc si
	shl bx, 3
	add bx, 14

PL1:
	mov al, [gs:bx]
	mov cx, 8

PL2:
	shr ax, 1
	jnc near PL3

	pusha			; save state

	mov bx, [wP]		; pointer
	push bx
	mov bx, dx
	shl bx, 2
	shl dx, 3
	add dx, bx
	pop bx

	sub dx, 48
	mov [Text3D+bx+2], dx	; write y

	shl cx, 3
	sub cx, 192
	add cx, word[wX]
	mov word[w1], cx
	add cx, 192

	sub cx, di

 	mov [Text3D+bx+0], cx		; write x
	mov [Text3D+bx+4], dword 0	; write z

	mov dl, byte[bFlat]
      and dl, dl
      jnz near FLAT

	fldpi
	fimul word[w1]
	mov word[w2], word 500
	fidiv word[w2]
	mov word[w1], word 192
	fld st0
	fsin
	fimul word[w1]
	fistp word[Text3D+bx+4]
	
	fcos
	fimul word[w1]
	fistp word[Text3D+bx+0]

FLAT:
;	mov [Text3D+bx+6], word 0
		
	add bx, 8
	mov [wP], bx
	mov bx, [wNV]
	inc bx
	mov word[wNV], bx	; inc NumVertices
	
	popa 			; restore
PL3:	
	dec cx
	jnz near PL2	

	inc bx
	inc dx
	cmp dx, 8
	jne near PL1

	add word[wX], 64
	pop cx
	dec cx
	and cx, cx
	jnz near PL0

	ret

;################
; 3D END
;################

; fSine - compute sine from precalculated table
; [ IN] ax = value (0..1023 as 0..2pi)
; [OUT] ax = fsin(ax), aka 31 * sin(pi * x / 512) + 32
fSine
    push bx
    and ax, 03FFh           ; ax %= 1024
    mov bx, pSinT           ; load sine table address
    add bx, ax              ; calculate element index address
    xor ah, ah              ; prepare high byte of ax
    mov al, [bx]            ; read value
    pop bx
    ret
; fSine2 - compute sine from precalculated table
; [ IN] ax = value (0..255 as 0..2pi)
; [OUT] ax = fsin2(ax), aka 256 * sin(pi * x / 128)
fSine2
    push bx
    and ax, 0FFh            ; ax %= 256
    shl ax, 1               ; ax *= sizeof(word)
    mov bx, pSinT2          ; load sine table address
    add bx, ax              ; calculate element index address
    mov ax, [bx]            ; read value
    pop bx
    ret

;################
; MIDI
;################
MidiFunction:
  mov ax, [wMC]                 ; load midi counter
  inc ax
  mov [wMC], ax
  sub ax, [frskip]
  jz DoMidi
  ret
DoMidi:
  mov word [wMC], 0

  mov ax, [wMB]
  inc ax
  cmp ax, 600
  jb MNR
  xor ax, ax
MNR:
  mov [wMB], ax

  mov word [wME], 018h
  cmp ax, 64
  jb sw1
  mov word [wME], 01Ah
sw1:
  cmp ax, 128
  jb sw2
  mov word [wME], 003h
sw2:
  cmp ax, 192
  jb sw3
  mov word [wME], 01Ch
sw3:
  cmp ax, 320
  jb sw4
  mov word [wME], 004h
sw4:
  cmp ax, 384
  jb sw5
  mov word [wME], 005h
sw5:
  cmp ax, 448
  jb sw6
  mov word [wME], 01Fh
sw6:

  mov dh, 9                     ; channel 9
  mov ah, 64                    ; load volume value
  mov dl, [m9lst]               ; load note value
  jz NoNote0                    ; if so, then don't play note
  call SetNoteOff               ; set note on
NoNote0:

  test word [wME], 16
  jz Label9

  mov dh, 9                     ; channel 9
  mov ah, 120                   ; load volume value
  mov bx, m9ns                  ; load note data address
  add bx, word [m9ptr]          ; add music pointer
  mov dl, [bx]                  ; load note value
  and dl, dl                    ; check if note to play is zero
  jz NoNote1                    ; if so, then don't play note
  call SetNoteOn                ; set note on
NoNote1:
  mov [m9lst], dl               ; set last note value

  mov ax, word [m9ptr]          ; load music pointer
  inc ax                        ; increase music pointer
  mov word [m9ptr], ax          ; write back music pointer
  sub ax, [m9len]               ; modulate music pointer
  jnz Label9                    ; if not zero then it's ok
  mov word [m9ptr], 0           ; else write zero to pointer
Label9:

  mov dh, 0                     ; channel 0
  mov ah, 64                    ; load volume value
  mov dl, [m0lst]               ; load note value
  and dl, dl
  jz NoNote2                    ; if so, then don't play note
  call SetNoteOff               ; set note on
NoNote2:

  test word [wME], 1
  jz Label0

  mov dh, 0                     ; channel 0
  mov ah, 127                   ; load volume value
  mov bx, m0ns                  ; load note data address
  add bx, word [m0ptr]          ; add music pointer
  mov dl, [bx]                  ; load note value
  and dl, dl                    ; check if note to play is zero
  jz NoNote3                    ; if so, then don't play note
  call SetNoteOn                ; set note on
NoNote3:
  mov [m0lst], dl               ; set last note value

  mov ax, word [m0ptr]          ; load music pointer
  inc ax                        ; increase music pointer
  mov word [m0ptr], ax          ; write back music pointer
  sub ax, [m0len]               ; modulate music pointer
  jnz Label0                    ; if not zero then it's ok
  mov word [m0ptr], 0           ; else write zero to pointer
  inc word [m0cnt]              ; increment channel 0 counter
Label0:

  mov dh, 1                     ; channel 1
  mov ah, 64                    ; load volume value
  mov dl, [m1lst]               ; load note value
  and dl, dl
  jz NoNote4                    ; if so, then don't play note
  call SetNoteOff               ; set note on
NoNote4:

  test word [wME], 2
  jz Label1

  mov dh, 1                     ; channel 1
  mov ah, 127                   ; load volume value
  mov bx, m1ns                  ; load note data address
  add bx, word [m1ptr]          ; add music pointer
  mov dl, [bx]                  ; load note value
  and dl, dl                    ; check if note to play is zero
  jz NoNote5                    ; if so, then don't play note
  call SetNoteOn                ; set note on
NoNote5:
  mov [m1lst], dl               ; set last note value

  mov ax, word [m1ptr]          ; load music pointer
  inc ax                        ; increase music pointer
  mov word [m1ptr], ax          ; write back music pointer
  sub ax, [m1len]               ; modulate music pointer
  jnz Label1                    ; if not zero then it's ok
  mov word [m1ptr], 0           ; else write zero to pointer
Label1:

  mov ax, [wMB]                 ; load beat counter
  and ax, 7                     ; check if modulo 8
  jnz Label2                    ; if not skip channel 2

  mov dh, 2                     ; channel 2
  mov ah, 64                    ; load volume value
  mov dl, [m2lst0]              ; load note value
  call SetNoteOff               ; set note on
  mov dl, [m2lst1]
  call SetNoteOff
  mov dl, [m2lst2]
  call SetNoteOff
NoNote6:

  test word [wME], 4
  jz Label2

  mov dh, 2                     ; channel 2
  mov ah, 127                   ; load volume value
  mov bx, m2ns                  ; load note data address
  add bx, word [m2ptr]          ; add music pointer
  mov dl, [bx]                  ; load note value
  call SetNoteOn                ; set note on
  mov [m2lst0], dl
  inc bx
  mov dl, [bx]
  call SetNoteOn
  mov [m2lst1], dl
  inc bx
  mov dl, [bx]
  call SetNoteOn
  mov [m2lst2], dl
NoNote7:

  mov ax, word [m2ptr]          ; load music pointer
  add ax, 3                     ; increase music pointer
  mov word [m2ptr], ax          ; write back music pointer
  sub ax, [m2len]               ; modulate music pointer
  jnz Label2                    ; if not zero then it's ok
  mov word [m2ptr], 0           ; else write zero to pointer
Label2:

  mov dh, 3                     ; channel 3
  mov ah, 127                   ; load volume value
  mov bx, m3ns                  ; load note data address
  add bx, word [m3ptr]          ; add music pointer
  mov dl, [bx]                  ; load note value
  and dl, dl                    ; check if note to play is zero
  jz NoNote9                    ; if so, then don't play note
  call SetNoteOn                ; set note on
NoNote9:
  mov [m3lst], dl               ; set last note value

  test word [wME], 8
  jz Label3

  mov ax, word [m3ptr]          ; load music pointer
  inc ax                        ; increase music pointer
  mov word [m3ptr], ax          ; write back music pointer
  sub ax, [m3len]               ; modulate music pointer
  jnz Label3                    ; if not zero then it's ok
  mov word [m3ptr], 0           ; else write zero to pointer
Label3:

  ret

; reset general midi interface
ResetGM:
  push dx                       ; store dx
  push ax                       ; store ax
  mov dx, GMPORT                ; general midi port
  mov al, 0FFh                  ; reset command
  out dx, al                    ; reset GM
  call ReadGM                   ; get ACK
  mov al, 03Fh                  ; switch to UART mode
  call WriteGMCommand           ; output command
  pop ax                        ; restore ax
  pop dx                        ; restore dx
  ret
  
; set midi note on
; dh = channel, dl = note, ah = volume
SetNoteOn
  push ax                       ; store ax
  mov al, dh                    ; load midi channel for note [0..16]
  or al, GMC_NOTEON             ; load command set_note_on
  call WriteGM                  ; write data
  mov al, dl                    ; load note [0..127]
  call WriteGM                  ; write data
  mov al, ah                    ; load volume [0..127]
  call WriteGM                  ; write data
  xor ax, ax
  call WriteGM
  call WriteGM
  pop ax                        ; restore ax
  ret

; set midi note off
; dh = channel, dl = note, ah = volume
SetNoteOff
  push ax                       ; store ax
  mov al, dh                    ; load midi channel for note [0..16]
  or al, GMC_NOTEOFF            ; load command set_note_off
  call WriteGM                  ; write data
  mov al, dl                    ; load note [0..127]
  call WriteGM                  ; write data
  mov al, ah                    ; load volume [0..127]
  call WriteGM                  ; write data
  xor ax, ax
  call WriteGM
  call WriteGM
  pop ax                        ; restore ax
  ret

; prepare for general midi writing
WriteGMPrep
  mov dx, GMPORT                ; load general midi port
;  push ax                       ; store ax
;  xor ax, ax                    ; loop 256 times
;WGMP_Loop0:
;  dec ah                        ; decrease counter
;  jz WGMP_Timeout               ; prevent timeout
;  in al, dx                     ; wait until GM is ready
;  and al, GMRECV                ; mask data with readymask
;  jnz WGMP_Loop0                ; wait if not ready
;WGMP_Timeout:
;  pop ax                        ; restore ax
  ret

; write command to GM
; al = data
WriteGMCommand
  push dx                       ; store dx
  call WriteGMPrep              ; prepare for midi data send
  out dx, al                    ; send command data
  pop dx                        ; restore dx
  ret

; write data to GM
; al = data
WriteGM
  push dx                       ; store dx
  call WriteGMPrep              ; prepare midi data send
  dec dx                        ; load data port
  out dx, al                    ; send GM data
  pop dx                        ; restore dx
  ret

; read data from GM, place in al
ReadGM
  push dx                       ; store dx
  mov dx, GMPORT                ; load general midi port
  push ax                       ; store ax
  xor ax, ax                    ; loop 256 times
RGM_Loop0:
  dec ah                        ; decrease counter
  jz RGM_Timeout                ; prevent timeout
  in al, dx                     ; read GM status
  and al, GMSEND                ; mask data with readymask
  jnz RGM_Loop0                 ; wait if not ready
RGM_Timeout:
  pop ax                        ; restore ax

  dec dx                        ; load data receive port
  in al, dx                     ; receive GM data
  pop dx                        ; restore dx
  ret


DrawBars

        pusha

        mov bx, word 3200
        mov cx, 400
        movq mm4, [SC]
DB1:
        movq mm5, [fs:bx]
        paddusb mm5, mm4
        movq [fs:bx], mm5
        add bx, 8
        loop DB1

        mov bx, word 57600
        mov cx, 400
DB2:
        movq mm5, [fs:bx]
        paddusb mm5, mm4
        movq [fs:bx], mm5
        add bx, 8

        loop DB2
        emms

        popa

        ret


