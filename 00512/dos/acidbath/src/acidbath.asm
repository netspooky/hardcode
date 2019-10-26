%define MESSAGE_LEN 129

org 100h
_start:
    
; DOS .com files are allocated the largest contiguous block of memory when
; they start. We'll use the segment 64k after DS. This is easier than
; dynamically allocating memory via int 21h calls for the double buffer.
; This requires about 128k of continguous memory to be available when the 
; program is executed.
    
; Get the address of the next segment
    mov bx, ds
    add bx, 0x1000
    mov gs, bx ; We'll keep the segment here, don't change it!
    
; Initiailize mode 13h graphics
    mov ax, 13h
    int 10h
    
; We'll use di for the frame counter.
    xor di, di
    
; Push current timer
    push byte 40h
    pop fs
    push word [fs:6Ch]

; We'll use si for the scroller position
    mov si, 320

; Set the palette to grayscale    
;    mov cx, 255
;    palette:
;        mov dx, 0x3C8
;        mov ax, cx
;        out dx, al
;        inc dx
;        out dx, al
;        out dx, al
;        out dx, al
;        loop palette
  
render_loop:    

; Render the next frame to the buffer
    push di
    push si

    mov si, di
    inc si
    mov cx, 64000
    effects.loop:
        push cx
        mov ax, cx
        mov bx, 320
        xor dx, dx
        div bx
        cmp ax, 12
        jl effects.white_bar
    
        mov si, di
        shr si, 9 ; Run each effect for 2^9 frames
        and si, 3 ; 4 Effects
        shl si, 5 ; Each effect is 2^5 bytes
        add si, effects
        jmp si

    effects:
    
        %include "effect1.asm"
        jmp word effects.draw
        times 32 - ($ - effect1) nop    
    
        %include "effect2.asm"
        jmp word effects.draw
        times 32 - ($ - effect2) nop    
    
        %include "effect3.asm"
        jmp word effects.draw
        times 32 - ($ - effect3) nop    
    
        %include "effect4.asm"

    effects.draw:
        pop cx
        mov bx, cx
        mov [gs:bx], al
        jmp effects.end

    effects.white_bar:
        pop cx
        mov bx, cx
        mov byte [gs:bx], al

    effects.end:
        dec cx
        jnz effects.loop
        
    pop si  ; Restore scroller position in case it was changed by an effect
    push si
    %include "scroller.asm"

; Wait for vertical retrace
    mov dx, 3DAh
L1: in al, dx
    and al, 8
    jnz L1
L2: in al, dx
    and al, 8
    jz L2

; Flip the buffer to the VGA segment 0xA000
    ; Copy buffer to VGA segment    
    mov bx, ds
    push gs
    pop ds
    push 0xA000
    pop es
    cld
    xor si, si
    xor di, di
    xor cx, cx
    dec cx
    rep movsb
    mov ds, bx
    
; Update frame counter and quit if user hit Escape
    pop si ; Scroller position
    pop di ; Frame counter
    pop bx ; Timer count
    
    ; Add difference between last timer count and current timer to frame
    ; counter and subtract it from the scroller position
    mov dx, word [fs:6Ch]
    sub bx, dx
    sub di, bx
    add si, bx

    
    ; If scroller has run its course, loop it
    cmp si, MESSAGE_LEN * -8
    jg dont_loop
    mov si, 320
dont_loop:
    
    push dx
    
    ; Quit on Escape
    in al, 60h
    dec al
    jnz render_loop

; Bail
    ; Fix the stack
    pop dx
    
    ; Return to text mode
    mov ax, 3h
    int 10h
    ret

message: 
db "ACIDBATH by orbitaldecay for DemoJS 2014. Greets to sensenstahl, frag, YOLP, T$, Pirx, p01, g0blinish, and HellMood. FUCK JS!", 0
    
