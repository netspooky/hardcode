temppal db  768 dup (0)
waitvrc macro
local w1, w2
      mov dx, 3dah
w1:
      in  al, dx
      test  al, 8
      jnz w1
w2:
      in  al, dx
      test  al, 8
      jz w2
endm

fadeall macro r,g,b,step,count
local loop1, loop2, decr, incr, decg, incg, decb, incb, rb, gb, bb, endma

        mov     cx, count


        push    cx
        mov     dl, r
        mov     dh, g
        mov     bl, b
        push    dx
        mov     ax, seg temppal
        mov     es, ax
        mov     ds, ax
        mov     di, offset temppal
        mov     dx, 3c7h
        mov     al, 0
        out     dx, al
        mov     dx, 3c9h
        mov cx, 3*256

        rep     insb
        pop     dx
        pop     cx

loop1:
        push    cx
        mov     cx, 256
        mov     si, offset temppal
loop2:
        mov     al, ds:[si]
        cmp     al, dl
        ja      decr
        cmp     al, dl
        jb      incr
rb:
        mov     ds:[si], al
        inc     si

        mov     al, ds:[si]
        cmp     al, dh
        ja      decg
        cmp     al, dh
        jb      incg
gb:
        mov     ds:[si], al
        inc     si

        mov     al, ds:[si]
        cmp     al, bl
        ja      decb
        cmp     al, bl
        jb      incb

bb:
        mov     ds:[si], al
        inc     si

        loop    loop2

    pusha
        waitvrc
    popa
        mov cx, 256*3
        mov     ax, seg temppal
        mov     ds, ax
    push  dx
        mov     si, offset temppal
        mov     dx, 3c8h
        mov     al, 0
        out     dx, al
        inc     dx
        rep     outsb
    pop dx
        pop     cx
        loop    loop1
        jmp endma
decr:
        sub al, step
        jmp rb
incr:
        add al, step
        jmp rb
decg:
        sub al, step
        jmp gb
incg:
        add al, step
        jmp gb
decb:
        sub al, step
        jmp bb
incb:
        add al, step
        jmp bb



endma:
        endm





