.386p
code segment public use16 'code'
assume cs:code,ds:code,ss:code
;assume si:0100h
org 100h
start:
decompress:
        push    si
        pop     bx
        mov     bp,(offset data_start - offset start)*8
        mov     di,1100h                ; Destination offset

        push    di                      ; Push di for the final ret

; Main loop -----------------------------------------------------------------

main_loop:
        or      di,di                   ; EOF?
        js      quit                    ; Yepp -> Return to 100h

        xor     ax,ax
        bt      [bx],bp                 ; Compressed/uncompressed data next?
        inc     bp
        jc      compressed

        mov     cl,8                    ; Uncompressed -> Get next 8 bits
        call    get_data                ; Get byte
        stosb
        jmp     main_loop               ; Loop

compressed:

ll:     mov     cl,7h                   ; Maximum number of bits in a row
bit_loop:
        bt      [bx],bp                 ; Loop until CF = 0
        inc     bp
        jnc     c_getpos
        inc     ax
        loop    bit_loop

        call    get_huffman             ; Yepp -> Get huffman-coded lenght
c_getpos:
        xchg    cx,ax
        jcxz    lenght_1                ; Lenght 1? -> Do something else....

        push    cx                      ; Save lengt
        call    get_huffman             ; Get huffman-coded position
        pop     cx                      ; Restore lenght

c_copy:
        mov     si,di                   ; Calculate new source offset
        sub     si,ax

        inc     cx                      ; Fix lenght

        rep movsb                       ; Copy duplicate data

        jmp     main_loop               ; Loop

lenght_1:
        mov     cl,4
        mov     al,1
        call    get_data
        jmp     c_copy

; Get huffman-coded number --------------------------------------------------

; Returns:
;     ax - The number

get_huffman:
hl1:    mov     cl,5                    ; Assume 3 bits for the number
        mov     al,1

        bt      [bx],bp
        inc     bp
        jnc     get_data                ; Was 0 -> Values were correct

hl2:    mov     cl,9                    ; Was 1 -> 5 bits for the number
hf2:    mov     al,33                   ; Fix-up value


; Get n bits of data --------------------------------------------------------

; Input:
;     cx - Number of bits wanted
;     ax - Fix-up value to be added to the result

; Returns:
;     ax - The requested number

get_data:
        cwd
gd_loop:
        bt      [bx],bp
        inc     bp
        adc     dx,dx                   ; Store it
        loop    gd_loop                 ; Loop
        add     ax,dx                   ; Fix the value
quit:   ret


; Start of the compressed data ----------------------------------------------

data_start:

code ends
end start
