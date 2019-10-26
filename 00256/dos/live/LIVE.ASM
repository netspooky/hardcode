; Some really bad non-optimized code by me..... Shogun
; Sorry no comments with it... :(
.model tiny
.386

.data

S1      db      'LiVeZ a BiTcH... GeT a LiVe!!!'
S2      db      'ShOgUn / Da ThIrD FoUnDaTiOn'

.code
.startup

main    proc
        mov ax,3
        int 10h
        lea si,S1
        mov dl,13
        mov dh,15
        mov cx,25
        mov bx,12
        mov ax,30
        call putstring
        lea si,S2
        mov dl,13
        mov dh,15
        mov cx,26
        mov bx,13
        mov ax,28
        call putstring
        mov ah,2
        xor bh,bh
        mov dl,21
        mov dh,24
        int 10h
        .exit
main    endp

putstring       proc            ;puts a string (offset in si) on the screen
        push ax
        mov ax,0B800h
        mov es,ax
        pop ax
        mov di,bx
        shl di,7
        shl bx,5
        add di,bx
        shl cx,1
        add di,cx
        mov cx,ax
      @Loopje:
        mov bl,ds:[si]
        inc si
        mov es:[di],bl
        cmp bl,'A'
        jl  @Kleur2
        cmp bl,'Z'
        jg  @Kleur2
        mov al,dl
        jmp @GaDoor
       @Kleur2:
        mov al,dh        
       @GaDoor:
        inc di
        mov es:[di],al
        inc di
        loop @Loopje
        ret
putstring       endp

end
