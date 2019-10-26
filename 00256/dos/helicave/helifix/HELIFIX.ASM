.model  tiny
.386
.code
org     100h

code_begin      label   near
        mov     ah, 9
        mov     dx, offset message
        int     21h
        mov     ah, 4ah
        mov     bx, ((offset code_end - offset code_begin) + 20fh) shr 4
        mov     sp, ((offset code_end - offset code_begin) + 1ffh) and -2
        int     21h
        mov     bx, offset exec_block
        mov     word ptr ds:[bx + 4], cs
        mov     word ptr ds:[bx + 8], cs
        mov     word ptr ds:[bx + 0ch], cs
        mov     ax, 4b01h
        mov     dx, offset helicave_com
        mov     bp, bx
        int     21h
        mov     ah, 62h
        int     21h
        mov     ds, bx
        mov     es, bx
        mov     cx, offset patch_end - offset patch_beg
        mov     si, offset patch_beg
        mov     di, 100h - (offset patch_end - offset patch_beg)
        rep     movs byte ptr [di], byte ptr cs:[si]
        mov     dword ptr ds:[112h], 29ffd9e8h
        mov     dword ptr ds:[1a2h], 0b4ff56e8h
        mov     dword ptr ds:[1c2h], 90ff31e8h
        mov     ss, word ptr cs:[bp + 10h]
        mov     sp, 0fffeh
        cbw
        cwd
        mov     cl, 0ffh
        mov     bx, 7
        mov     bp, 91ch
        mov     si, 100h
        mov     di, sp
        push    ds
        push    si
        retf

patch_beg       label   near
        db      31h, 0dbh, 0fh, 0b5h, 0fh, 0c3h
        db      30h, 0e4h, 0cdh, 1ah, 84h, 0d2h, 0c3h
        db      75h, 2, 89h, 0c8h, 0c3h
patch_end       label   near
helicave_com    db      "helicave.com", 0
exec_block      dw      0, 80h, 0, 5ch, 0, 6ch, 0

message         db "DOSBox fix for HeliCave", 0dh, 0ah
                db "by Peter Ferrie (peter_ferrie@hotmail.com)", 0dh, 0ah, "$"

code_end        label   near
end             code_begin
