;                                         
; PROTO256.COM : Protoplasm.256
;  Written Nov 27-Dec 10, '97 by Tektite of SYMBio.sys for the #coders
; 256-byte Christmas demo compo, Dec. 20, '97.
;
;  I've never taken an assembler course... In fact, I haven't read many
; docs either, so excuse my coding style if it sucks. I've tried to optimize
; this as much as possible, but I can't say it's perfect.  This code uses a
; routine that I have used in the past in my group, SYMBio.sys's Window demo.
; I call it the blend routine, it's kind of like a fire without any 'cooling'
; or upwards movement, this one with an increment to keep it going.  This
; creates an interesting effect when the values wrap up around 255 to 0.
; Sorry if this is common and I'm ignorantly using someone's algorithm, I did
; write this myself and the popular fire is the closest code I've ever
; seen that is similar to it. Actually, let me know if you find anything like
; it.
;
; History: This started as just the "blending" effect, but it was really small
; still so I put in the scrolly, optimized a bunch, and decided that I would
; put in another effect to "top" it off. I scrapped the following attempts:
;       1. Palette shifting using self-modifying code. *shudder* That failed
;         with many a crash. (but gave me ideas...)
;       2. Bouncing balls w/ an 8-byte bitmap... file was about 25 bytes too
;        big, I couldn't get it any smaller.
;       3. Pixels orbiting around the middle. Too big again, plus many bugs.
;       4. Big letters popping into the mix. Oh, that one was a nightmare
;        of unoptimizable code. (I almost made it, but it looked kinda bad)
;       5. Expanding screen on entry. I didn't get very far with this one.
;       6. PC speaker sound! I got it to work, but it wasn't very interesting
;         considering I could only fit about 4 notes in. Hard to make a decent
;         four-note melody.
;       7. Sine wave translation in the buf-to-screen copy. Looked bad and
;         pushed the size limit a bit.
;       8. Stick man bitmap across the top of the screen. That was just crap.
;
;   After this point I radically altered the palette (pink-green gradient is
; pretty disgusting after a while), formatted the screen better (equal space
; above & below main effect), and put the current effect at the top of the
; screen. It uses a pixel calculation that changes randomly every time the
; scrolly wraps past a certain point. The new pixel values aren't simply set,
; but half the distance between the current pixel and the new one is covered
; each redraw.  Due to bit loss through shifts, the value will sometimes get
; stuck 1 value away from it's destination, which makes each effect leave a
; little bit of an imprint on the next. I know, it's no breakthrough in new
; techniques, but it's kinda cool. Happy coding.
;       -Tektite (tektite@plateau.jammys.net)
;
; (PS: SYMBio.sys isn't a demo group, so don't go looking. I just happen to
; be a coder and it's somewhere for me to release stuff)

.model tiny
.486
.code

        org 100h

start:
        mov al,13h                      ; We'll be using my ever-so-favorite
        int 10h                         ; mode, 13H! 320*200*256.
        xchg bx,ax                      ; For palette, set 3C8 to starting (0)
        mov dx,03C8h                    ; color and write 256 "r,g,b"s to 3C9.
        out dx,al                       ; Color x will be Red=x*2,Green=-x
        inc dx                          ; and Blue=-x. 
palloop:
        push ax                         ; Save color number.
        push ax                         ; Twice.
        shl ax,1                        ; Double AX.
        out dx,al                       ; Red=x*2.
        pop ax                          ; (restore x)
        neg al                          ; Negify that color!
        out dx,al                       ; Green=-x.
        out dx,al                       ; Blue=-x.
        pop ax                          ; Restore again.
        inc al                          ; Increment color num.
        loop palloop                    ; CX=Codesize (256, convenient!)

        mov ch,0FAh                     ; 64000 bytes to blend. We don't 
                                        ; actually put 64000 on the screen,
                                        ; but it doesn't hurt any, plus we
                                        ; need some extra so we don't see the
                                        ; icky stuff at the top & bottom.
                                        ; My random number generator takes
                                        ; 2 words and mutates them with each
                                        ; other with a simple: "xor ax,bx",
                                        ; "add(c) bx,ax","rcl ax,3", but it
                                        ; gets pretty reasonable numbers.
        mov di,offset scrbuf            ; Get scrbuf offset. (ES=CS=DS still)
fillloop:
        xor ax,bx                       ; Here's the random stuff...
        adc bx,ax                       ; I've decided to use adc this time
        rcl ax,3                        ; I know! It's not REALLY random, but
        stosb                           ; it's not bad for 256 bytes.
        loop fillloop                   ; Loop this fill
        
        push 0A000h                     ; Init is done, we'll need a screen
        pop es                          ; seg to work with.
totalloop:
        std                             ; We'll blend backwards.
        mov cx,0FA00h                   ; 64000 blends.
        mov si,offset scrbuf + 64000    ; Point to end of buffer.(0FB00h)
        xor ax,ax                       ; Clear ah for blending. 
blendloop:
        xor dx,bx                       ; More random. We'll split off the
        add bx,dx                       ; last opcode to make the number
        mov di,dx                       ; in DI positive or negative.
        and di,06h                      ; DI= 0, 2, 4, or 6.
        mov di,[di+offset around]       ; Get 1,319,320 or 321. (see below)
        rcl dx,3                        ; Finish the random algo.
        jnc nonegofs                    ; If rnd(2)=1 is set (rcl carried)
        neg di                          ; We'll use a negative offset.
nonegofs:                               ; This saves 8 bytes of offsets.
        add di,si                       ; Add position to offset.
        movzx di,byte ptr [di]          ; Get pixel at offset+position.
        lodsb                           ; Get pixel at position and dec SI.
        add ax,di                       ; Add the two together.
        shr ax,1                        ; Divide by 2 to average.(blend)
        inc al                          ; Add 1 so the numbers wrap upwards.
        mov [si+3],al                   ; Store the new value 3 pels forward
        loop blendloop                  ; so that the blend "scrolls".
        cld                             ; The rest of my string operations
        mov dx,3DAh                     ; are forward. I'll wait for a
retraceloop:                            ; retrace here and then start my
        in al,dx                        ; on-screen stuff.
        test al,8                       ; Check for retrace.
        jz retraceloop                  ; Loop until there is one.
                                        ; Now we'll do the cool top-of-screen
                                        ; effect.
        xor di,di                       ; Point DI to top
        mov ch,30                       ; CX=03000h, which is 320*24.
        mov bx,320                      ; We'll be dividing by 320 in a sec.
topthingloop:
        mov ax,di                       ; Put offset in ax for division.
        cwd                             ; clear dx (ax<32768).                     
        div bx                          ; DX will now hold X position, AX
                                        ; will hold Y.
                                        ; The "tag" instruction is a 2-byte
tag:                                    ; opcode that will be changed.
        mov al,dl                       ; First effect is color=y.
        sub al,byte ptr es:[di]         ; Get the difference between old and
        sar al,1                        ; new values, divide by 2, then add
        add byte ptr es:[di],al         ; this to the pixel. In other words,
                                        ; The new pixel will be halfway from
                                        ; the old one to it's destination.
                                        ; Unfortunately, the bit lost when
                                        ; The difference is one means that
                                        ; some values will never "make it".
                                        ; (Maybe this is a good effect? :)
        inc di                          ; Go to the next offset.
        loop topthingloop               ; Loop 320*24 times, DI will come out
                                        ; being 320*24, SI points to the ofs
                                        ; of scrbuf still. (from blendloop)
        add si,di                       ; Start copying from 320*24 into the
        mov ch,05Fh                     ; buffer, and draw 48640 pixels. That
        rep movsw                       ; is, 320*(200-24{top}-24{bottom}).

        push ds                         ; Now the fun part... text scrolly!
        push es                         ; We need to preserve ds and set it
        pop ds                          ; to the screen seg to do the scroll.
        mov si,64000-320*24+2           ; SI is DI + 2. DI points to the 1st
        push di                         ; line after the blend part. Instead
        mov ch,10                       ; of some space-sucking adding, I'll
                                        ; just scroll the 8 empty lines above
                                        ; the blend too.
        rep movsw                       ; Scroll 5120 bytes (10*256,16*320)
        pop di                          ; Retrieve pointer to top of bottom.
        pop ds                          ; Make sense? And restore DS.
        xor ax,ax                       ; Now we cut off the 2 pixels at the
        mov cl,16                       ; left side of the screen so that the 
cleartextloop:                          ; text doesn't wrap.
        stosw                           ; Clear a word.
        add di,318                      ; Next line.
        loop cleartextloop              ; 16 lines (need last 8, but no adds)
        add bp,64                       ; BP is our text counter.
        in al,40h                       ; We (may) want a random value for
        xchg bx,ax                      ; the top effect. I'll do it here.
                                        ; I know 2 different ways of getting
                                        ; random numbers is redundant, but
                                        ; each of these ways work best for
                                        ; their seperate tasks.
        test bp,01000h                  ; If the text is wrapping, change to
        jz nochangetop                  ; a new random effect at the top.
        and bl,0110b                    ; BL is random. (will be 0,2,4 or 6)
        mov ax,[offset relations+bx]    ; Put the opcode in AX.
        mov word ptr [offset tag],ax    ; And store it over the old one.
nochangetop:
        and bp,00FC0h                   ; Limit BP (wrap the text string) 
        mov cx,bp                       ; Put BP in CX to split hi and lo.
        or cl,0                         ; If CL=0, then the "bp+64" has gone
        jnz noputchar                   ; by 4 times, and we need a new char.
        movzx di,ch                     ; CH is the letter to put. (hi BP)
        mov al,[di+offset string]       ; Get the char from the string.
        mov dx,1727h                    ; Write at position (39,23)
        mov bl,1                        ; Use color 1 for text.
        mov ah,2                        ; Use function 2 in Int 10h: Set
        int 10h                         ; Cursor Position.
        mov ah,0Ah                      ; INT 10,A: Write character at cursor
        mov cx,1                        ; Number of chars to write = CX = 1
        int 10h                         ; Write the character.
noputchar:
        mov ah,1                        ; Now we can check for a keypress.
        int 16h                         ; Using Int 16h, Func 1.
        jz totalloop                    ; If nothing was pressed, keep going.
        mov ax,3                        ; If not, set text mode using Int 10h
        int 10h                         ; function 0.
        ret                             ; All done, thanks for watching!

around: dw 320,1,319,321                ; These are the offsets randomly
                                        ; chosen to blend with. (Positive
                                        ; half of all-around screenwise)
relations:
        mul dl                          ; Color = x*y; {neat arc-like thing}
        add al,dl                       ; Color = x+y; {diagonal bars}
        and al,dl                       ; Color = x AND y;{Triangle fractal?}
        add al,al                       ; Color = x*2; {Looks like horizon}
string: db "y's rule! Scroll"           ; The scrolling text. It doesn't
                                        ; start at the beginning, it starts
                                        ; where BP points to first. (On my
                                        ; machine) Maybe this is wrong on
                                        ; others, but it doesn't really make
                                        ; a huge difference.)
scrbuf: db 64000 dup (?)                ; The screen buffer. Blending is slow
                                        ; and icky without buffering.
end start
