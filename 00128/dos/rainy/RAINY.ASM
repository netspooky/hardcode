; Rainy
;        written for the #asm-128bytes-compo <asmcompo.cjb.net>
;                            by Olaf Kaehler <thorin@mailto.de>
;                                     on 30th/31st January 2000
;
; The cause for there is no single fsin or fcos is one specific
; properity of waves: The velocity is the same as the amplitude
; of pi/2 before the current position in the wave-cycle.
; I therefore save 2 cycles of the waves in ds and fs. Each new
; cycle the waves are basically the smoothed waves of one cycle
; before with a subtraction of the amplitude 2 cycles before.
; This of course should be possible in 128 bytes. Actually most
; operations are initialisation.
; The basic of the algorithm was not really my idea. I found it
; on  "The good-looking textured light-sourced bouncy fun smart
; and stretchy page" <http://freespace.virgin.net/hugo.elias>.
; All implementation (and optimisation, whew) is mine, and...
;  (c) copyright blablabla...
;
; Bugs or "not optimals":
;    1. Endless loop... 128 bytes are quiet few... :)
;    2. A pitty of a random-number-generator...
;       but therefore only 2 instructions!
;    3. It's a little too fast... I think... :)
;    4. The palette-init is little extensive...
;    5. Also I'd prefere having it in blue, instead of gray
;    6. Usually I'd add some random-background, and lots more,
;       but 128 bytes is really not too much...
;
; PS: Compiles with Pass32, but should also work with TASM
; PPS: hmmm... this is my first participation in a compo...
;      Have I forgotten anything?

.MODEL TINY
.CODE
        mov ax,0013h            ; <--- enter videomode
        int 10h

        mov dx,3C8h             ; <--- setup pallete
        xor al,al
        out dx,al
        sub al,32
        inc dx
@set_pal:
        out dx,al
        out dx,al
        out dx,al
        inc al
        cmp al,-32
        jnz @set_pal

        mov dx,cs               ; <--- organize segments
        add dh,10h              ;      ds -> old waves (2 cycle)
        mov ds,dx               ;      fs -> old waves (1 cycles)
        add dh,10h              ;      es -> segA000 
        mov fs,dx
        push 0A000h
        pop es

        xor al,al               ; <--- initialize (clear) segments
        xor di,di
@clear_loop:
        mov ds:[di],ax
        mov fs:[di],ax
        inc di
        inc di
        jnz @clear_loop


        mov bl,1                ; <--- initialize random-number-generator
        xor si,si

@mainloop:

        imul bx,61657           ; <--- add drops / random-generator
        cmp bl,64
        jnb @dont_add_drop_now
        mov dl,bl
        xor bx,0AAAAh
        sub fs:[bx],dl
@dont_add_drop_now:

@water_loop:                    ; <--- "move" waves
        mov al,BYTE PTR ds:[si-1]
        add al,BYTE PTR ds:[si+1]
        add al,BYTE PTR ds:[si-320]
        add al,BYTE PTR ds:[si+320]
        sar al,1
        sub al,fs:[si]
        mov dl,al
        sar dl,4
        sub al,dl
        mov fs:[si],al
        inc si
        jnz @water_loop

        push fs                 ; <--- exchange the two buffers
        push ds
        pop fs
        pop ds

        dec cx                  ; <--- it's less code that way... :)
        rep movsb
        movsb

;        mov ax,0100h            ; <--- wait for key
;        int 16h
;        jz @mainloop
        jmp @mainloop            ; <--- CHANGE THIS TO END ON KEYPRESS!!!

;        mov ax,0003h            ; <--- terminate
;        int 10h
;        mov ax,4c00h
;        int 21h
END