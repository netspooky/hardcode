; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Wait until the GMIDI device is ready to send/recieve
;
;  Input:
;      BL - 40h = recieve, 80h = send
;      DX - GMIDI baseport
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


IF ENABLE_MUSIC EQ 1

PROC gmidiWait

        push    ax                      ; Save ax

        xor     ax,ax                   ; Loopcounter for timeout
        inc     dx                      ; Use the statusport

@@wait:
        dec     ah                      ; Timeout?
        jz      @@timeout               ; Yes -> We're outta here

        in      al,dx                   ; Get GMIDI status

        and     al,bl                   ; Ready to recieve/send?
        jnz     @@wait                  ; Nope -> Loop

@@timeout:
        dec     dx                      ; Back to dataport

        pop     ax                      ; Restore ax

        ret

ENDP

ENDIF



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Write a byte to the GMIDI device
;
;  Input:
;      AL - Byte to write
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; NOTE: This routine doesn't destroy any registers!
; =================================================


IF ENABLE_MUSIC EQ 1

PROC gmidiWrite

        pusha                           ; Save all registers

        mov     dx,[gmidiPort]          ; Get the GMIDI baseport

        mov     bl,40h                  ; Check status for recieving
        call    gmidiWait

        out     dx,al                   ; Write byte

        popa                            ; Restore all regs

        ret

ENDP

ENDIF



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Initialize the GMIDI device
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


IF ENABLE_MUSIC EQ 1

PROC gmidiInitialize

        mov     dx,[gmidiPort]          ; GMIDI baseport

        mov     al,0ffh                 ; Reset device
        out     dx,al

        mov     bl,80h                  ; Check status for sending
        call    gmidiWait

        in      al,dx                   ; Get acknowledge

        mov     bl,40h                  ; Check status for recieving
        call    gmidiWait

        mov     al,3fh                  ; Set to UART mode
        inc     dx
        out     dx,al

        mov     si,OFFSET midiInitString ; Initilization bytes to send

@@loop:
        lodsb                           ; Get byte to send

        cmp     al,255                  ; Byte was 255?
        je      @@quit                  ; Yes -> Quit

        call    gmidiWrite              ; Send the byte

        jmp     @@loop                  ; Loop

@@quit:
        ret

ENDP

ENDIF



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Turn off all notes on all GMIDI channels
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


IF ENABLE_MUSIC EQ 1

PROC gmidiShutUp

        xor     bx,bx                   ; Initial channel
        mov     cx,GMIDI_CHANNELS       ; Loopcounter

@@loop:
        mov     ax,bx                   ; Get channel number
        add     al,0b9h                 ; Control change (+ fix channel)
        call    gmidiWrite

        mov     al,123                  ; Turn off all notes
        call    gmidiWrite

        xor     al,al
        call    gmidiWrite

        inc     bx                      ; Next channel

        loop    @@loop                  ; Loop (got it!)

        ret

ENDP

ENDIF



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Play one tick of music
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


IF ENABLE_MUSIC EQ 1

PROC playMusic

        xor     bx,bx                   ; Initial channel (channel 10)

@@channel_loop:
        mov     bp,bx                   ; bp = bx*2 (used in word-size
        add     bp,bp                   ;            memory accesses)

        dec     [chnl_delay+bx]         ; Decrease delay time
        jnz     @@next_channel          ; Delay still on -> Next channel

        mov     ax,bx                   ; Set the channel number
        add     al,0b9h                 ; Control change (+ fix channel)
        call    gmidiWrite              ; Send

        mov     al,123                  ; Turn all notes off
        call    gmidiWrite
        call    gmidiWrite

        mov     si,[chnl_on+bp]         ; Start playing notes from here

@@note_loop:
        lodsb                           ; Get the note to play

        cmp     al,128                  ; Was the number a delay instead?
        jae     @@notes_done            ; Yes -> Outta this loop

        push    ax                      ; Save the note

        mov     ax,bx                   ; Set the channel number
        add     al,99h                  ; Turn note on (+ fix channel)
        call    gmidiWrite              ; Send

        pop     ax                      ; Send the note number
        call    gmidiWrite

        mov     al,[chnl_volume+bx]     ; Send volume
        call    gmidiWrite 

        jmp     @@note_loop             ; Loop through all notes

@@notes_done:
        sub     al,128                  ; Save the number of ticks to delay
        mov     [chnl_delay+bx],al

        mov     [chnl_on+bp],si         ; Start playing here on next tick

        cmp     [BYTE si],0             ; End of the pattern?
        jne     @@next_channel          ; Nope -> Handle next channel

@@order_loop:
        add     [WORD chnl_order+bp],2  ; Next order

        mov     si,[chnl_order+bp]      ; Offset to the new pattern
        mov     si,[si]                 ; Get offset to the new pattern

        mov     [chnl_on+bp],si         ; Save the pattern offset

@@next_channel:
        inc     bx                      ; Next channel

        cmp     bx,GMIDI_CHANNELS       ; All channels done?
        jne     @@channel_loop          ; Nope -> Loop

        ret

ENDP

ENDIF



