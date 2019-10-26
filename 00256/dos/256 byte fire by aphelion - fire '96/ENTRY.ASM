%TITLE "256 byte fire by Aphelion - Fire '96"

        IDEAL

        MODEL   tiny

        P386

XSize   =       320
YSize   =       150

        DATASEG

Scr     db      XSize*YSize     DUP     (?)

        CODESEG

        ORG     100h                    ; Standard .COM start address

Start:

        mov     al,13h
        int     10h                     ; MCGA 320x200x256c

        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx

@@PalLoop:                              ; ah=flag,bh=r,bl=g,ch=b

        jl      @@NoAdd
        add     bh,2

@@NoAdd:

        test    ah,ah
        jne     @@NoFlag
        cmp     cl,41                   
        jl      @@NoFlag
        inc     bl

@@NoFlag:

        xor     ah,1
        cmp     bh,63
        jl      @@BHOk
        mov     bh,63

@@BHOk:

        cmp     bl,63
        jl      @@BLOk
        mov     bl,63

@@BLOk:

        cmp     cl,189
        jg      @@SetRGB                
        inc     ch

@@SetRGB:

        mov     al,bh
        out     dx,al
        mov     al,bl
        out     dx,al
        mov     al,ch
        out     dx,al

        inc     cl
        cmp     cl,255
        jne     @@PalLoop

        push    0F000h                  
        pop     fs

        push    0000h
        pop     gs

@@MainLoop:

        test    [byte ptr gs:046Ch],30
        jnz     @@NoWrite
        lea     si,[0FA6Eh+8*"2"]
        lea     di,[Scr+320*85+64]
        call    Write
        lea     si,[0FA6Eh+8*"5"]
        lea     di,[Scr+8*8+320*85+64]
        call    Write
        lea     si,[0FA6Eh+8*"6"]
        lea     di,[Scr+8*8+8*8+320*85+64]
        call    Write

@@NoWrite:

        lea     si,[Scr+XSize*YSize-XSize]
        mov     cx,XSize

@@XLoop:                                ; Put 255 or 0 along bottom 2 lines

        mov     bx,2
        call    Random                         
        mov     ax,255
        mul     dl
        mov     [si-XSize],al
        mov     [si],al
        inc     si
        loop    @@XLoop

        lea     si,[Scr+XSize]
        mov     cx,XSize*YSize-XSize

@@Average:

        xor     ax,ax
        mov     al,[si]
        add     al,[si+XSize]
        adc     ah,0
        add     al,[si-1]
        adc     ah,0
        add     al,[si+1]
        adc     ah,0
        shr     ax,2
        jz      @@Zero
        dec     ax                      ; dec ax if > 0

@@Zero:

        mov     [si-XSize],al           ; al = x+(x+320)+(x-1)+(x+1) shr 2
        inc     si
        loop    @@Average

        lea     si,[Scr]
        mov     cx,XSize*YSize/4 - 640  ; Hide Bottom 2 lines
        push    0A000h
        pop     es
        mov     di,8000 + 640           ; Make up for bottom 2 lines
        rep     movsd                   ; Dump Scr to 0A000h

        mov     ah,01h
        int     16h                     ; Check for keypressed
        jz      @@MainLoop              ; Continue if no key is pressed

Exit:

        mov     ax,3h
        int     10h                     ; Set Text Mode
        ret                             ; Give control back to DOS

PROC    Random                          ; Returns a "random" number in dx

        xor     dx,dx                   
        in      al,40h                  
        add     ax,bp                   
        div     bx                      
        add     bp,ax                   
        ret                             

ENDP    Random


PROC    Write                            

        push    ds
        pop     es
        mov     dh,8*8

@@Loop1:

        mov     ah,[fs:si]              ; Load byte
        mov     dl,8

@@Loop2:

        rol     ah,1
        sbb     al,al                   ; Uses CF, 0=0, 1=FF
        mov     cl,8
        rep     stosb
        dec     dl
        jnz     @@Loop2                 
        add     di,XSize-8*8            ; Start at beginning of next line
        dec     dh
        test    dh,7                    ; Loop on dh every 8 bits
        jnz     @@Loop1                 
        inc     si
        test    dh,dh                   ; Smaller than cmp dh,0 
        jnz     @@Loop1
        ret

ENDP    Write

        END     Start
