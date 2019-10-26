; fr-0.1: constant evolution (a tribute to baze)
; ryg/farbrausch 2003
;
; documented version

bits    16
org     100h

start   mov     al, 0x13        ; setup for mode 0x13. later also used as frame counter.
                                ; oh, and it happens to be the low bits of the mantissa
                                ; of our scaling value, too.
        cmc                     ; high bits of scaling mantissa and lowest bit of exponent.
                                ; that it also happens to complement the carry flag is irre-
                                ; levant :)
        inc     dx              ; another irrelevant opcode. this time the high bits and sign
                                ; of our scaling value.
        int     0x10            ; set mode 13h
        push    word 0xa000     ; load vram segment into es.
        pop     es
        
pix     mul     bx              ; bx=0 at start of execution of a .COM program, and is
                                ; never (permanently) changed during the run of the
                                ; program. thus "mul bx" is just a shorter way of writing
                                ; "xor ax,ax"/"xor dx,dx" here.
        inc     ax              ; ...ax is now 1
        add     ax, di          ; this will overflow exactly once per frame: when di=65535,
                                ; i.e. at the end of mode13 video memory. it sets the carry to 1
                                ; on that occassion, else to 0.
        adc     [si], bx        ; as said, bx is always zero. si is 0x100 (i.e. program start
                                ; address) at the beginning of execution and is never changed.
                                ; so this effectively abuses our mov al, 0x13 as frame counter;
                                ; (that location is now used three times, as executable code, frame
                                ; counter and low bits of UV scaling mantissa - whoa).
        div     word [si+12]    ; dx is still 0, ax=di+1, i.e. the vram offset of the *next* pixel to
                                ; be processed. the +12 is actually an offset into the code, and the
                                ; opcodes at that point are "inc ax"/"add ax,di". "inc ax" is 0x40,
                                ; "add ax,di" starts with byte 0x01, together that's 0x40 0x01, or
                                ; 0x140 when read as little-endian word. 0x140=320=number of pixels
                                ; per screenline :). after this divide dx=x coordinate of next pixel
                                ; and ax=y coordinate.

clp     fmul    dword [si]      ; those two instructions scale and scroll the uv coordinates
        fiadd   word [si]       ; (both of them). which uv coordinates? well, at the first run
                                ; of the loop, there's nothing on the fpu stack here, so this
                                ; produces undefined behavior. what's going on? well, the loop
                                ; runs actually delayed by one pixel, because the respective
                                ; values are loaded AFTER this loop. that's why it works even
                                ; though the pixel address we computed is actually off-by-one.
                                ; actual computation is simple: 0x100, is, again, start of the
                                ; program, our modeset/framecounter/uvscale thing.
                                ; coordinate = (st(0) * approx_uvscale) + framecounter
                                ; this scales the values properly and also scrolls the texture.
        fistp   word [bx]       ; store the tex coordinate at [bx]
        sub     ax, 130         ; subtract 130 from the current coordinate to position the tunnel
        xchg    ax, [bx]        ; store the current coordinate into [bx] and get the tex coordinate
                                ; from there in one step
        xor     cx, ax          ; cx is our color accumulator. xor the coordinate into it.
                                ; (the "texture" is u xor v, so this works as long as cx always has
                                ; the same starting value for each pixel)
        fild    word [bx]       ; load the current pixel coordinate
        fmul    st0             ; square it
        xor     bx, bp          ; bx is 0 at start, so in the first run, bx becomes bp, and in the
                                ; second run, it becomes 0 again. this is because we want the two
                                ; coordinates to end up at distinct places in memory for obvious
                                ; reasons; it also serves as 2-run-loop as a byeffect :)
        xchg    ax, dx          ; exchange input x and y coordinates, so we can use the same scaling/xor
                                ; /etc code for both coordinates equally.
        fxch    st1             ; also change x and y coordinates on fpu stack for the same reason.
        jnz     clp             ; this works in conjunction with the xor to perform the calculation.
    
        faddp   st1, st0        ; fpu stack now contains (squared) input x and input y coordinates.
                                ; add them...
        fsqrt                   ; square root. we now got the distance between the input pixel and our
                                ; origin at 130/130, which also nicely works as 1/z (or 1/v) for our
                                ; tunnel calculation...
        fdivr   [si]            ; this divides 1/z by our favourite uv scaling value. scale/(1/z)
                                ; =scale*z (or scale*v): exactly what we want.
    
        fild    word [bx]       ; load our x coordinate again, this time non-squared.
        fild    word [bp]       ; same for the y coordinate.
        fpatan                  ; compute atan2(x,y) - our u coordinate.
    
        ; by now, we got our actual u and v coordinates for the next pixel on the fpu stack, waiting to
        ; be read by the tunnel loop in the next run to compute the pixel's color. whew.
    
        salc                    ; set al to carry (undocumented 8086 opcode). does exactly that. here
                                ; abused as cheap way to set the low half of ax to a reliable value,
                                ; because it'll soon get swapped into cx, which needs it:
        xchg    ax, cx          ; here's the swap - now we have our current color accumulator in ax
                                ; and a nice starting value for the next pixel in cl.
        or      al, 0x87        ; make the colors a tad nicer :)
        stosb                   ; store the color into screen mem
        jmp     short pix       ; and loop!
