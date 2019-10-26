; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Calculate the color-to-grayscale -table
;
;  Input:
;      SI - Offset to the palette
;      DI - Offset of the destination
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC calcGrayTable

        mov     cx,256                  ; Calculate 256 colors

@@loop:
        lodsb                           ; Get R-component
        movzx   bx,al

        lodsb                           ; Get G-component
        add     bl,al
        add     bl,al

        lodsb                           ; Get B-component
        add     bl,al

        mov     ax,bx                   ; Calculate average
        shr     ax,2

        stosb                           ; Store intensity

        loop    @@loop                  ; Loop through all colors

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Calculate the color-mixing -table needed for motion-blur
;
;  Input:
;      SI - Offset to the palette to be used
;      ES - Destination segment (the table takes full 64Kb's)
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC calcMixTable

; Initialize the gauge ------------------------------------------------------

        mov     ax,0a000h               ; fs = a000
        mov     fs,ax

        mov     di,320*100+32           ; Initial offset
        mov     cx,256                  ; Gauge width

@@gauge_init:
        mov     [BYTE fs:di],220          ; Draw the "empty" gauge
        mov     [BYTE fs:di+320],220

        inc     di                      ; Advance di
        
        loop    @@gauge_init            ; Loop


; Calculate the table -------------------------------------------------------

        mov     [count],0               ; Start mixing from here

@@mainloop:
        mov     ax,[count]              ; Get the two colors to mix

        movzx   bx,al                   ; Get the first color
        imul    bx,3                    ; Offset to it's RGB-data
        add     bx,si

        movzx   di,ah                   ; Get the second color
        imul    di,3                    ; Offset to it's RGB-data
        add     di,si

        mov     cx,3                    ; Loop through 3 components (R/G/B)

@@mixloop:
        movzx   ax,[BYTE bx]            ; Get color component from color #1
        movzx   dx,[BYTE di]            ; Get color component from color #2

        imul    ax,MIX_RATIO            ; Mix components together
        imul    dx,32-MIX_RATIO
        add     ax,dx             
        shr     ax,5

        push    ax                      ; Save the result

        inc     bx                      ; Next component
        inc     di

        loop    @@mixloop               ; Loop

        pop     dx                      ; Get all three mixed components
        pop     cx                      ; from the stack
        pop     bx

        mov     dh,cl                   ; Move GREEN to it's place

        push    si                      ; Save the offset to the palette

        mov     ch,0ffh                 ; Initialize error


; Registers in the following loop:

;    BL - Mixed R-component
;    BH - Loopcounter (initially 0 = 256 loops)
;    CL - Current error (difference)
;    CH - Current smallest error
;    DH - Mixed G-component
;    DL - Mixed B-component
;    BP - Current best choise

@@findloop:
        lodsb                           ; Get R-component from the palette
        sub     al,bl                   ; Calculate the difference

        cbw                             ; Loose the sign :-D
        xor     al,ah                   ; (take the absolute value of al)
        sub     al,ah

        mov     cl,al                   ; Save the difference to cl

        lodsb                           ; Get G-component from the palette
        sub     al,dh                   ; Calculate the difference

        cbw                             ; Loose the sign
        xor     al,ah
        sub     al,ah

        add     cl,al                   ; Add the difference to cl

        lodsb                           ; Get B-component from the palette
        sub     al,dl                   ; Calculate the difference

        cbw                             ; Loose the sign
        xor     al,ah
        sub     al,ah

        add     cl,al                   ; Add the difference to cl

        cmp     ch,cl                   ; Is current error smallest so far?
        jb      @@nomatch               ; Nope -> Keep looping...

        movzx   bp,bh                   ; Yepp -> Save the color index
        mov     ch,cl                   ; Save the smallest error

@@nomatch:
        inc     bh                      ; Loop
        jnz     @@findloop

        pop     si                      ; Restore the ptr to the palette

        mov     bx,[count]              ; Get the current offset to the table

        mov     ax,bp                   ; Save the best matching color
        mov     [es:bx],al


; Draw the progress-gauge ---------------------------------------------------

        mov     di,[count]              ; Calculate gauge position
        shr     di,8
        add     di,320*100+32

        mov     [BYTE fs:di],15         ; Draw pixel
        mov     [BYTE fs:di+320],15

        inc     [count]                 ; Next two colors to mix
        jnz     @@mainloop              ; Loop

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Calculate the displacement-map
;
;  Input:
;      ES - Destination segment (the table takes full 64Kb's)
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC calcDisplaceMap

        xor     di,di                   ; Destination offset
        mov     cx,32768                ; Clear the whole table
        xor     ax,ax

        rep stosw                       ; Clear

        mov     di,320*12               ; Initial offset
        mov     edx,1d6c78a5h           ; Random-number root

        mov     eax,0d0d0d0dh           ; Draw the dots with this value

        mov     si,316                  ; Adder

@@dotloop:
        rol     edx,3                   ; Calculate random number
        xor     dx,bp
        inc     bp

        mov     bx,dx                   ; Advance di by a random number
        and     bx,31
        add     di,bx

        push    di                      ; Save destination address

        stosd                           ; Draw a dot (4x4 pixels)
        add     di,si
        stosd
        add     di,si
        stosd
        add     di,si
        stosd

        pop     di                      ; Restore destination address

        cmp     di,185*320
        jb      @@dotloop               ; Loop

        mov     dx,16                   ; Smooth 16 times

@@smoothloop:
        xor     di,di                   ; Starting offset
        mov     cx,64000                ; Loop through the whole segment

@@smooth:
        mov     ax,[es:di]              ; Get 2 pixels
        mov     bx,[es:di+320]          ; Get 2 more pixels

        add     al,bl                   ; Calculate the average
        add     ah,bh
        add     al,ah
        shr     al,2

        stosb                           ; Store smoothed pixel

        loop    @@smooth                ; Loop

        dec     dx                      ; Smooth three times
        jnz     @@smoothloop

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Get current palette
;
;  Input:
;      DI - Destination offset for the full palette (768 bytes)
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Gets the full 256-color palette from VGA.


PROC getPalette

        mov     dx,3c7h                 ; Start from color 0
        xor     al,al
        out     dx,al

        add     dl,2                    ; Output to port 3C9
        mov     cx,768                  ; Get 768 registers

        rep insb                        ; Get all DAC:s

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Make necessary changes to the default palette
;
;  Input:
;      DI - Offset to the palette
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC modifyPalette

        mov     [WORD di+6],0b08h       ; Modify color #2 (ground)

        add     di,192*3                ; Start from color #192

        xor     ax,ax                   ; AL = initial red, AH = intial green
        xor     bl,bl                   ; BL = intial blue

        mov     dx,0102h                ; DL = delta red, DH = delta green
        mov     bh,0                    ; BH = delta blue

        mov     cx,32                   ; Make a slide of 32 colors (the sky)

@@loop:
        stosw                           ; Store red and green components
        mov     [di],bl                 ; Store blue component
        inc     di                      ; Advance destination
        
        add     ax,dx                   ; Add deltas to RGB-values
        add     bl,bh

        loop    @@loop                  ; Loop

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Create full sincos-table using the FPU
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Creates a 1024-degree sinetable using the FSIN command. Not very
; fast but who cares, this only has to be done once. The good thing
; about this is that since we're using the FPU, the table will be
; very accurate and this routine is really small.


PROC createSincosTable

        mov     [count],0               ; Reset angle
        mov     di,OFFSET sincosTable   ; Destination address

        finit                           ; Initialize FPU

        mov     cx,1024                 ; Calculate 1024 angles

@@loop:
        fild    [count]                 ; Load our angle to the FPU
        fdiv    [radConversion]         ; Convert it to radians
        fsin                            ; Get it's sine
        fmul    [real16384]             ; Convert it to fixed-point (18.14)

        fistp   [DWORD di]              ; Store value
        add     di,4

        inc     [count]                 ; Next angle

        loop    @@loop                  ; Loop until done

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Get EGA 8x14 system font
;
;  Input:
;      DI - Destination offset for the font
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC getEGAfont

        push    ds                      ; Save segregs
        push    es

        mov     ax,1130h                ; BIOS Return charset info
        mov     bh,2                    ; Return ptr to 8x14 font
        int     10h

        push    es                      ; ds = es
        pop     ds

        pop     es                      ; Restore es

        mov     si,bp                   ; Source offset
        mov     cx,256*14               ; Copy this many bytes

        rep movsb                       ; Copy font

        pop     ds                      ; Restore ds

        ret

ENDP



