; plasmoid 171b intro for cc'15 winter - 09.01.2015
; by artem vasilev | wormsbiysk | wbc ^ b-state (ex-LSA)
; sorry for nosound ;)

safever   equ 1 ; change this for safe version generating

format binary
org    100h

start:
    cld
    mov   bh, 0A0h
    mov   es, bx
    
    mov   bh, 80h
    mov   ds, bx

    mov   al, 13h
    int   10h

    xor   bx, bx
if safever
    xor   cx, cx 
@@loop:
    mov   al, byte [cs:sintable+bx]
    mov   byte [ds:di], al
    inc   di
    inc   bl
    loop  @@loop
    
; sin calculation routine
; taken from g0blinsh "ad astra" intro 
; uses FPU and works only under DOSBox
else
sinlp:
    fldpi
    fidiv [cs:len]
    mov   [cs:tmp],bx
    fimul word [cs:tmp]
    fsin
    fimul [cs:amp]
    fist  word [cs:tmp]
    mov   al,byte [cs:tmp]
    xor   al, 128
    mov   [ds:bx],al
    inc   bx
    jnz   sinlp
end if 
 
    mov   dx, 3C8h
    xor   ax, ax
    out   dx, al
    inc   dl
    mov   cx, 256
    xor   si, si
@palloop:
    ; play with ops for changing of palette ;)
    lodsb
    mov   bx, ax
    shr   al, 2
    out   dx, al
    mov   al, byte [ds:bx]
    shr   al, 2
    out   dx, al
    shl   al, 1
    out   dx, al
    loop  @palloop
    
frame:
    mov   dx, 3DAh
retr2:
    in	  al, dx
    and   al, 8
    jnz   retr2    
retr1:
    in	  al, dx
    and   al, 8
    jz	  retr1
    
    xor   di, di
    mov   cx, 200
@y_cycle:
    push  cx
    xor   ax, ax
    
    mov   si, bp
    shl   si, 1
    add   si, cx
    ;and   si, 255
    lodsb
    xor   al, 128
    cbw
;    shr   ax, 1
    mov   bx, ax
    
;    mov   bx, 100
    add   bx, 100     ; 100 - Screen_y / 2
    sub   cx, bx
    mov   ax, cx
    imul  cx          ; AX = (y - my) * (y - my) 
    
    mov   bx, 25600   ; 160 ^ 2, 160 - Screen_x / 2
    add   bx, ax      ; BX  - radius
    mov   dx, -320    ; DX  - dr
    
    mov   cx, 320
@x_cycle:
    add   dx, 2
    add   bx, dx
    
    mov   si, bx      ; sinetable is located on segment start
    shr   si, 8
    add   si, bp
    ;and   si, 255
    movsb
    loop  @x_cycle
    
    pop   cx
    loop  @y_cycle
    

    add   bp, 2          ; BP - frame counter
    
    mov   ah, 1
    int   16h
    jz	  frame
    
    ret

if safever
; link sintable ;)
sintable:
db 128 , 131 , 134 , 137 , 140 , 144 , 147 , 150
db 153 , 156 , 159 , 162 , 165 , 168 , 171 , 174
db 177 , 179 , 182 , 185 , 188 , 191 , 193 , 196
db 199 , 201 , 204 , 206 , 209 , 211 , 213 , 216
db 218 , 220 , 222 , 224 , 226 , 228 , 230 , 232
db 234 , 235 , 237 , 239 , 240 , 241 , 243 , 244
db 245 , 246 , 248 , 249 , 250 , 250 , 251 , 252
db 253 , 253 , 254 , 254 , 254 , 255 , 255 , 255
db 255 , 255 , 255 , 255 , 254 , 254 , 254 , 253
db 253 , 252 , 251 , 250 , 250 , 249 , 248 , 246
db 245 , 244 , 243 , 241 , 240 , 239 , 237 , 235
db 234 , 232 , 230 , 228 , 226 , 224 , 222 , 220
db 218 , 216 , 213 , 211 , 209 , 206 , 204 , 201
db 199 , 196 , 193 , 191 , 188 , 185 , 182 , 179
db 177 , 174 , 171 , 168 , 165 , 162 , 159 , 156
db 153 , 150 , 147 , 144 , 140 , 137 , 134 , 131
db 128 , 125 , 122 , 119 , 116 , 112 , 109 , 106
db 103 , 100 , 97 , 94 , 91 , 88 , 85 , 82
db 79 , 77 , 74 , 71 , 68 , 65 , 63 , 60
db 57 , 55 , 52 , 50 , 47 , 45 , 43 , 40
db 38 , 36 , 34 , 32 , 30 , 28 , 26 , 24
db 22 , 21 , 19 , 17 , 16 , 15 , 13 , 12
db 11 , 10 , 8 , 7 , 6 , 6 , 5 , 4
db 3 , 3 , 2 , 2 , 2 , 1 , 1 , 1
db 1 , 1 , 1 , 1 , 2 , 2 , 2 , 3
db 3 , 4 , 5 , 6 , 6 , 7 , 8 , 10
db 11 , 12 , 13 , 15 , 16 , 17 , 19 , 21
db 22 , 24 , 26 , 28 , 30 , 32 , 34 , 36
db 38 , 40 , 43 , 45 , 47 , 50 , 52 , 55
db 57 , 60 , 63 , 65 , 68 , 71 , 74 , 77
db 79 , 82 , 85 , 88 , 91 , 94 , 97 , 100
db 103 , 106 , 109 , 112 , 116 , 119 , 122 , 125
end if    
    
len dw 128
amp dw 127
tmp dw ?    
