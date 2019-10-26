;
; Wormsúinú256bytes
;
; (c) 1997 George Manolaros aka Emc/dEUS
;
; ~contact : gmanol@physics.upatras.gr
;            http://www.kapatel.gr/matrix/users/mot/deus.htm
;
; ~controls :
;
;  Player 1        Player 2
;
;     W               8
;   A + D           4 + 6
;     X               2
;

p1_up    = 17
p1_down  = 45
p1_left  = 30
p1_right = 32

p2_up    = 72
p2_down  = 80
p2_left  = 75
p2_right = 77

p_color = 9     ; (0 --> 14)

game_speed = 2

MaxLoop = 16

codestuff       segment
        assume  cs:codestuff,ds:codestuff
        org 100h
.486
main:
        xor     ax,ax
        mov     fs,ax

        mov     al,13h
        int     10h

        mov     bx,9*4                  ; new keyboard handler
        push    dword ptr fs:[bx]       ; save
        mov     word ptr fs:[bx],offset newint9
        mov     fs:[bx+2],cs

        push    0a000h
        pop     es

        mov     al,8
next:

   cli
        xor     cx,cx
        dec     cx              ; cx=0ffffh
        rep     stosb           ; cx = 0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Draw fractal (Zeleps method)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        mov     di,320
        mov     cl,198          ; ch=0
next_y:
        stosb                   ; draw border
push ax

        mov     bp,-(320-2)
next_x:

        xor     ax,ax
        xor     bx,bx
        push    di
        mov     di,maxloop
repeatl:
        movsx   esi,bx
        imul    bx,ax
        cwde
        imul    eax
        mov     edx,eax
        imul    esi,esi
        sub     eax,esi

        sar     eax,7

        sub     ax,bp
        sub     ax,256

        sar     bx,6

        sub     bx,cx
        add     bx,100
        add     edx,esi

        shr     edx,16
        jnz     plot

        dec     di
        jnz     repeatl

plot:
        mov     ax,di
        add     al,16
        pop     di

        stosb
        inc     bp
        jnz     next_x

pop ax
        stosb                   ; draw border
        loop    next_y

   sti

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Game
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        mov     di,99*320+40
        mov     si,99*320+320-40

        mov     bp,dx           ; dx=1
        mov     bx,-1

again:
        inc     ah
        mov     cl,game_speed
delay:
        mov     dx,3dah
        in      al,dx
        test    al,8
        jnz     $-3
        in      al,dx
        test    al,8
        jz      $-3
loop    delay

        mov     al,p_color
        cmp     es:[di],byte ptr 15
        stosb
        jbe     next
        dec     di

        inc     al
        cmp     es:[si],byte ptr 15
        mov     es:[si],al
        jbe     next

        add     di,bp
        add     si,bx

        dec     ah
        jnz     again

        pop     dword ptr fs:[9*4]      ; restore keyboard

        mov     al,3h            ; ah=0
        int     10h

        ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Keyboard Handler
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NewInt9         proc    near
        in      al,60h

        mov     ah,al

        cmp     al,p1_down
        jnz     sk1
        mov     bp,320
sk1:
        cmp     al,p1_up
        jnz     sk2
        mov     bp,-320
sk2:
        cmp     al,p1_left
        jnz     sk3
        mov     bp,-1
sk3:
        cmp     al,p1_right
        jnz     sk4
        mov     bp,1
sk4:
        cmp     al,p2_down
        jnz     sk1b
        mov     bx,320
sk1b:
        cmp     al,p2_up
        jnz     sk2b
        mov     bx,-320
sk2b:
        cmp     al,p2_left
        jnz     sk3b
        mov     bx,-1
sk3b:
        cmp     al,p2_right
        jnz     sk4b
        mov     bx,1
sk4b:

        mov     al,20h
        out     20h,al
        iret
NewInt9         endp
codestuff       ends
end     main
