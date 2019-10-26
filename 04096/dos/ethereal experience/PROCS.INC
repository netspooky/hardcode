;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
;  USEFUL PROCS                         ú
;  not just for the Ethereal demo,
;ú but as standard stuff...
;À-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Adjust memory block sizeÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns nothig
adjustmem   proc

        mov     bx, 1000h ;16384
        mov     ah, 4Ah
        int     21h
        push    cs
        pop     ds
        ret
endp    adjustmem


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Allocate memory ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns segment address in AX
alloc   proc

        ; allocate one segment (ffffh)
        mov     bx, 4096
        mov     ah, 48h
        int     21h
        ;returns segment pointer in AX
        ret

alloc   endp


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Generate pseudo random number ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú Uses global var "seed"
;úúúú Returns number in AX
random proc

        mov     ax, cs:[seed]
        xor     ax, 0AA55h
        shl     ax, 1
        adc     ax, 118h
        mov     cs:[seed], ax

        ; keep seed for next call and return number in AX
        ret

endp random


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Draws a character to the screen ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú Uses global vars "chary", "charx", "charac", "fontcol", "fontseg" and "fontoff"
;úúúú Returns nothing
gPutC   proc
        push    si
        push    ds

        mov     ax, cs:[chary]
        xor     bx, bx
        mov     bh, al
        shl     ax, 6
        add     bx, ax
        mov     di, bx
        add     di, cs:[charx]
        mov     bh, cs:[fontcol]
        mov     bl, bh
        mov     ah,0
        mov     al, cs:[charac]
        shl     AX, 3
        mov     si,cs:[fontoff]
        add     si,ax
        mov     ax,cs:[fontseg]
        mov     ds,ax
        mov     dx,8
@ooo:
        mov     cx,8
        mov     al,[si]
@nnn:
        shl     al,1
        jnc     @fSIGUE
        mov     es:[di],bx
        mov     es:[di+2],bx
        mov     es:[di+320],bx
        mov     es:[di+322],bx
@fSIGUE:
       add      di, 4
       loop     @nnn
       inc      si
       add      DI,608

       dec      dx
       jnz      @ooo

       pop      ds
       pop      si

       ret

gPutc   ENDP


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Draws a string to the screen ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú Uses global vars "stry", "strx", "string" and "strlen"
;úúúú Returns nothing
gPutS  proc  near
        push    si

        mov     di, cs:[strx]
        mov     cs:[charx], di

        xor     si,si
 @gPSBucle:

        mov     bx, cs:[string]
        mov     al, byte ptr cs:[bx+si]
        mov     cs:[charac], al
        mov     ax, cs:[stry]
        mov     cs:[chary], ax
        call    gPutC

        add     word ptr cs:[charx], 31
        cmp     word ptr cs:[charx], 289
        jg      @gPSBye

        inc     si
        dec     cs:[strlen]
        jnz     @gPSBucle

 @gPSBye:
        pop     si
        ret
gPutS  endp


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Gets font memory address ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú Uses nothing
;úúúú Returns segment in "fontseg" and offset in "fontoff"
get_font proc

        push    es
        push    bp
        mov     ax, 1130h
        mov     bh, 1
        int     10h
        mov     cs:[fontseg], es
        mov     cs:[fontoff], bp
        pop     bp
        pop     es

        ret

endp    get_font


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Waits for vertical retrace ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú Uses nothing
;úúúú Returns nothing
retrace proc
        push    dx ax
        mov     dx,03dah
@SINC0:
        in      al, dx
        test    al,  8
        jnz     @SINC0
@SINC1:
        in      al, dx
        test    al,  8
        jz      @SINC1

        pop     ax dx

        ret

endp    retrace


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Clears a 64000 bytes memory buffer ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú Receives segment in ax
;úúúú Returns nothing
clear_seg proc

        push    es

        mov     es, ax

        mov     cx, 0ffffh/2
        xor     di, di
        mov     ax, di
        rep     stosw

        pop     es

        ret

endp    clear_seg


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Copies 64000 bytes from mem to vga ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú Receives segments in "dumpsrc" and "dumpdst"
;úúúú Returns nothing
dumpscr proc

        push    ds
        push    es
        push    si
        push    di

        xor     di, di
        xor     si, si
        mov     es, cs:[dumpdst]
        mov     ds, cs:[dumpsrc]
        mov     cx, 0ffffh/2
        rep     movsw

        pop     di
        pop     si
        pop     es
        pop     ds
        ret
endp    dumpscr


;úúúú----ÄÄÄÄÄÄÄÄ Waits two seconds using retrace as delay ÄÄÄÄÄÄÄ-----úúúú
;úúúú No input params
;úúúú Returns nothing
wait_sec      proc

        mov     cx, 140
wst1:
        call    retrace
        loop    wst1

        ret

endp    wait_sec
