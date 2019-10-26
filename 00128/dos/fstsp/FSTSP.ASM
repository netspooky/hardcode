;          FSTsp v0.7 by Necros (aka Dodger) & Protected Christmas
;
; ù DESCRIPTION: a VERY small sample player
; ù REQUIREMENTS: Sound Blaster at 220h, DMA 1 (ask for other configurations)
; ù SPECIAL FEATURES: - DMA transfers
;                     - EMM386 not needed :-D
;                     - Read the sample name from the command line
;                     - File error detection
;                     - 8086 instructions
;                     - Play up to 64k samples!
;                     - 11025 Hz samples
; ù SIZE: 84 bytes
;
; ù COMPILE:
;        TASM fstsp
;        TLINK /t fstsp
;
; ù PROGRAMMER'S EMAIL:
;        skoog@ibm.net   ( Protected Christmas )
;        fst0001@ibm.net ( Dodger )
;
        IDEAL
        MODEL   TINY
        CODESEG
        ORG     100h
init:
        mov     ah,30h
        push    ax
        out     02h,al          ; send low offset (DMA)
        out     02h,al          ; send high offset (DMA)
;-- get file name --
        mov     bl,82h
        mov     dx,bx
        add     bl,[bx-2]
        mov     [byte ptr bx-1],bh      ; convert to ASCIIZ
;-- open file --
        mov     ah,3Dh
        int     21h             ; ax=file handle
        jc      short exit      ; detect file error
        xchg    ax,bx
;-- read sample --
        not     cx
        xor     dx,dx
        pop     ds
        mov     ah,3Fh
        int     21h
        xchg    ax,bp
        mov     al,03h
        out     83h,al          ; send page (DMA)
;-- reset DSP --
        mov     dx,0226h
        out     dx,al           ; Sup. AL=01h
dsploop1:
        loop    short dsploop1
        dec     ax
        out     dx,al
dsploop2:
        loop    short dsploop2
        mov     dl,2Ch
        mov     al,0D1h
        out     dx,al           ; turn speaker on
        mov     al,49h
        out     0Bh,al          ; send playback code (DMA)
        mov     al,40h
        out     dx,al
wait2:
        loop    short wait2
        mov     al,0A5h         ; send high byte of sampling frequency
        out     dx,al
wait3:
        loop    short wait3
        mov     al,14h
        out     dx,al           ; set mode (8 bits DMA single-cycle)
        xchg    ax,bp
        out     03h,al          ; send low byte of sample length DMA
        out     dx,al           ; send low byte of sample length DSP
        mov     al,ah
        out     03h,al          ; send high byte of sample length DMA
        out     dx,al           ; send high byte of sample length DSP
        mov     al,01h
        out     0Ah,al          ; unmask channel 1 (DMA)
exit:
        ret                     ; nice way to quit
END init
