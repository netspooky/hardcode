; lil' 256byte drag racing game
;
; This is a 2 player game where each player hammers away at the shift keys
;  to race each other to the finish line.
;
;
;Features:
;  VGA graphics
;  multi-channel sounds
;
;
; Written by kenbo@donut.dialix.oz.au (Ken Chick)
;
;
;
; IMPORTANT: move the_player array around to where the offset address's
;       bit 3 is 0!!!  You can use ALIGN 8 to make sure it is.  This is
;       because of opcode modifying stuff in the game.
;
;
;* You can toggle the compiling options for different game styles(see below)
;
;* I was going to put 2 cars in it with computer player but I ran out of
;   space. :(
;


;********** Format of the car images at the end ********************
;
; 0000 0000
; ^^^^ ^^^^
; ³³À´ ÀÁÁÁÄÄÄÄ Length of the line
; ³³ ³
; ³³ ÀÄÄÄÄÄÄÄÄÄ Color of dot 0=invisible
; ³³
; ³ÀÄÄÄÄÄÄÄÄÄÄÄ Goes to next line if this bit is on
; ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄ End of sprite
;



;*******************
; Compiling options...
; fiddle around with these for different games

CAR_TYPE equ 1          ; 0=F1 car, 1=drag racing car
USE_BUTTON equ 2        ; 0=keyboard shifts, 1=mouse buttons
PRINT_WON equ 0         ; whether to print the "won" text string
FLICKER equ 1           ; flickering or not
FLUSH_KEY equ 1         ; flush keyboard on exit, turn this off to save space


CLIPPING equ 0          ; whether to use clipping or not

;*******************

HORZ_WIDTH equ 320
VERT_LENGTH equ 200
SCREEN_SIZE equ (HORZ_WIDTH*VERT_LENGTH)


FINISH_LINE equ 50      ; where the player finishes

.386
model small
smallstack

KEY_BUFFER equ 1000h    ; buffer to store keypresses
BADDIES_INFO equ 2000h  ; info on baddies





_CODE segment use16
ORG 100h

assume cs:_CODE,ds:_CODE


;********************************************************************

; in: si=sprite numbers, es= screen
; dx= y position, bx=x position
draw_sprite macro

ds_next_line:
inc dx
IF CLIPPING
cmp dx,VERT_LENGTH
jge ds_done
ENDIF
imul di,dx,320
add di,bx

    ds_loop:
        mov cl,[si]
        mov ah,cl
        mov al,cl
        and al,30h
        shr al,2
        and cx,0fh
        rep stosb
        inc si
        test ah,0c0h
        js ds_done
        jnz ds_next_line
        jmp ds_loop
ds_done:
endm



main proc

mov ax,13h      ; set video mode
int 10h


; setup

; setup globals

IF FLICKER eq 0
mov ax,cs
add ax,1000h            ; use next segment for video buffer
mov video_buffer,ax
ENDIF
cld





; start the sound!
in al,61h
or al,3
out 61h,al

main_loop:              ; do game

; clear screen
IF FLICKER
push 0a000h
pop es
mov di,(HORZ_WIDTH*FINISH_LINE)
ELSE
mov es,video_buffer
xor di,di
mov cx,(HORZ_WIDTH*FINISH_LINE)/2
xor ax,ax
rep stosw
ENDIF
mov cx,HORZ_WIDTH
mov al,1
rep stosb
xor ax,ax
mov cx,((SCREEN_SIZE)-((HORZ_WIDTH*FINISH_LINE)+1))/2
rep stosw


PLAYERS equ 2       ; amount of players

; do sound
mov al,0b6h
out 43h,al      ; pit control
sound_play_offset:
mov cx,word ptr the_players+2
neg cx
add cx,320+40
mov dx,12h
mov ax,34ddh
div cx
out 42h,al
mov al,ah
out 42h,al
xor byte ptr sound_play_offset+2,4


IF FLICKER
; wait vga retrace
mov dx,03dah
wait_retrace2: in al,dx
test al,80h
jz wait_retrace2
ENDIF

xor bp,bp
mov bx,offset the_players
draw_players:
    push bx
    mov dx,[bx+2]
    cmp dx,FINISH_LINE
    jl game_won
    mov bx,[bx]
    mov si,offset sprite_car
    draw_sprite            ; draw the player
    pop bx
    add bx,4
inc bp
cmp bp,PLAYERS
jl draw_players





IF FLICKER eq 0
; wait vga retrace
mov dx,03dah
wait_retrace2: in al,dx
test al,80h
jz wait_retrace2

; copy video buffer to screen
push 0a000h
pop es
mov ds,video_buffer
xor si,si
mov di,si
mov cx,8000h
rep movsw
push cs
pop ds
ENDIF



; mouse buttons
IF USE_BUTTON eq 1
    mov ax,3
    int 33h
    PLAYER1_BUTTON equ 1
    PLAYER2_BUTTON equ 2
ELSE
    xor ax,ax
    mov fs,ax
    mov bl,byte ptr fs:[417h]
    PLAYER1_BUTTON equ 2
    PLAYER2_BUTTON equ 1
ENDIF
test bl,PLAYER1_BUTTON
last_mouse_info1:
jz not_up1
    xor byte ptr last_mouse_info1,1
    dec word ptr the_players+2
not_up1:
test bl,PLAYER2_BUTTON
last_mouse_info2:
jz not_up2
    xor byte ptr last_mouse_info2,1
    dec word ptr the_players+2+4
not_up2:


no_mouse_buttons:   ; not mouse buttons changed

mov ah,1
int 16h
jz main_loop


IF FLUSH_KEY
xor ah,ah
int 16h
ENDIF
jmp short quit_game


game_won:       ; bp=player that won!

; print player won text

mov ax,bp
add al,'1'

IF PRINT_WON
mov player_won_text,al
mov dx,offset player_won_text
mov ah,9
int 21h
ELSE
mov dl,al
mov ah,2
int 21h
ENDIF

quit_game:

; turn the sound off
in al,61h
and al,not 3
out 61h,al

mov ax,4c00h    ; get outta here
int 21h
endp










;********************************************************************
; data...



IF FLICKER eq 0
video_buffer dw 0       ; segment where 320x200 video buffer is
ENDIF


;align 8
the_players:
dw 138,180         ; position of player1
dw 170,180            ; other player



; sprite for the car
sprite_car:
IF CAR_TYPE eq 1
; drag racing car
db 2,76h
db 4, 52h
db 2,22h,12h,62h    ; front wheels
db 2,22h,12h,62h    ; front wheels
db 4, 52h
db 4,52h
db 4,52h
db 3,54h
db 3,54h
db 3,54h
db 3,54h
db 23h,14h,63h    ; back wheels
db 23h,14h,63h    ; back wheels
db 23h,14h,63h    ; back wheels
db 4,52h
db 1,0f8h

ELSE
; F1 car
db 1,7ah              ; front bar
db 5h, 52h
db 2,23h,12h,63h    ; front wheels
db 2,23h,12h,63h    ; front wheels
db 4h, 54h
db 1,5ah
db 1,5ah
db 1,5ah
db 1,5ah
db 1,5ah
db 4h,54h
db 24h,14h,64h    ; back wheels
db 24h,14h,64h    ; back wheels
db 24h,14h,64h    ; back wheels
db 4h,54h
db 0fch
ENDIF

IF PRINT_WON
player_won_text db '1 won$'
ENDIF
        
ends

end main
