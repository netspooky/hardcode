;---------------------------------------------------------------------------
;By:Heikki Vesalainen
;setpal macro, sets the palette with the [number] of palette values (colors*3)
;starting from data:[mem].
;In: [number], [mem] ([mem] is a label, not offset)
;Out: the right palette!
;Uses:  DS:SI (points to the palette), AX, DX, CX
Setpal  MACRO   number, mem
        mov     cx, number

        mov     ax, @data
        mov     ds, ax
        mov     si, offset mem

        mov     dx, 3c8h
        mov     al, 0
        out     dx, al
        
        inc     dx
        rep     outsb
        ENDM        
