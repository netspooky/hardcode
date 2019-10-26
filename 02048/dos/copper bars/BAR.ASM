; Copper bars by Patch (hamell@rigel.cs.pdx.edu)
; Uses raster method
; 4-9-93
; Call Dead Man's Hand at 503.288.9264 - USR 16.8k DS
; Programming source only

.model tiny
.286
JUMPS

.code
                org     100h

start:          mov     ax,0013h
                int     10h

                in      al,21h                          ; get IRQ mask
                mov     [irqsave],al                    ; save it
                mov     al,11111101b                    ; all but kbd off
                out     21h,al                          ; set new IRQ mask
                in      al,0a1h                         ; get NMI mask
                mov     [nmisave],al                    ; save it
                mov     al,11111111b                    ; ?
                out     0a1h,al                         ; set new NMI mask

                mov     dx,03c8h
                mov     al,01h
                out     dx,al
                xor     al,al
                inc     dx
                out     dx,al
                out     dx,al
                out     dx,al

                push    0a000h
                pop     es
                xor     di,di
                mov     ax,0101h
                mov     cx,32000
                cld
                rep     stosw

                push    ds
                pop     es
                mov     bx,offset barline
startbar:       cli                                     ; don't poll keyboard
                mov     si,offset palette               ; set up pointer
                mov     bp,01h                          ; bar num = 1
palsetup:
                push    bp
                mov     di,[bx]
                mov     al,sintable[di]                 ; top bar line

                mov     di,offset barpal
                dec     al                              ; dec for 0th index element
                xor     ah,ah                           ; clear high byte
                mov     cx,ax
                shl     ax,1
                add     ax,cx
                add     di,ax
                add     di,ax
                mov     bp,offset barpriority           ;
                add     bp,cx                           ; set to proper spot in priority check
                mov     cx,[barheight]
checkline:
                cmp     byte ptr [bp],00h               ; is the line empty?
                jne     nodrawline                      ; if not, jump
                mov     byte ptr [bp],01h               ; it's full now
                movsw
                movsb
                sub     si,3
                movsw
                movsb
                jmp     nextpriority

nodrawline:     add     si,3                            ; increment palette pointer
;                add     si,6
                add     di,6                            ; increment bar palette
nextpriority:   inc     bp                              ; next priority line
                loop    checkline

barspot:        add     word ptr [bx],03h               ; increment table index
                cmp     word ptr [bx],359               ; end of table?
                jle     nextbar
resetbarspot:   mov     word ptr [bx],00h               ; reset table index

nextbar:
                pop     bp                              ; restore bar num
                inc     bx                              ; next bar line address
                inc     bx                              ; word size = + 2
                inc     bp                              ; increment bar counter

                cmp     bp,[barcount]                   ; bar count at max?
                jle     palsetup                        ; if <= , go back

                mov     si,offset barpal
                mov     cx,400
                        mov     dx,03dah                ; set up Input Status 1 reg
        VRetrace:       in      al,dx
                        test    al,00001000b            ; test bit 3, vertical retrace
                        jnz     VRetrace                ; if active, go back
        VNoRetrace:     in      al,dx
                        test    al,00001000b            ; test bit 3, vertical retrace
                        jz      VNoRetrace              ; if active, go back

paldump:
                mov     al,01h
                mov     dx,03c8h
                out     dx,al
                inc     dx
                outsb                                   ; dump it out
                outsb
                mov     dx,03dah
puck1:
                in      al,dx
                test    al,00000001b
                jz      puck1

                mov     dx,03c9h
                outsb

                        mov     dx,03dah                ; set up Input Status 1 reg
        HRetrace:       in      al,dx
                        test    al,00000001b            ; test bit 1, horiz retrace
                        jnz     HRetrace                ; if not active, go back
;        HNoRetrace:     in      al,dx
;                        test    al,00000001b            ; test bit 1, horiz retrace
;                        jz      HNoRetrace              ; if active, go back

;                mov     dx,03dah
                loop    paldump

                mov     di,offset barpriority
                mov     cx,100                          ; 100 of them WORD sized
                xor     ax,ax                           ; AH = 0, AL = 0
                rep     stosw                           ; zero them all out

                mov     di,offset barpal
                mov     cx,600
                xor     ax,ax
                rep     stosw

                sub     bx,[barcount]                   ; reset bar line address
                sub     bx,[barcount]                   ; twice for word size

                sti                                     ; ok, poll keyboard
                mov     ah,01h
                int     16h
                jnz     exit
                jmp     startbar

exit:
                mov     al,[irqsave]                    ; get old IRQ mask
                out     021h,al                         ; restore IRQ mask
                mov     al,[nmisave]                    ; get old NMI mask
                out     0a1h,al                         ; restore NMI mask
                mov     ax,0003h
                int     10h
                mov     ax,4c00h
                int     21h

sintable        db      1,1,1,1,1,1,1,1,1,2,2,2
                db      3,3,3,4,4,5,5,6,6,7,7,8
                db      8,9,10,11,11,12,13,14,14,15,16,17
                db      18,19,20,21,22,23,24,25,26,27,29,30
                db      31,32,33,35,36,37,38,40,41,42,44,45
                db      46,48,49,51,52,54,55,57,58,60,61,63
                db      64,66,67,69,70,72,73,75,77,78,80,81
                db      83,84,86,88,89,91,93,94,96,97,99,101
                db      102,104,105,107,108,110,112,113,115,116,118,119
                db      121,122,124,125,127,128,130,131,133,134,136,137
                db      138,140,141,143,144,145,147,148,149,150,152,153
                db      154,155,156,158,159,160,161,162,163,164,165,166
                db      167,168,169,170,171,171,172,173,174,174,175,176
                db      177,177,178,178,179,179,180,180,181,181,182,182
                db      182,183,183,183,184,184,184,184,184,184,184,184         ; top to bottom palette values
                db      184,184,184,184,184,184,184,184,184,183,183,183
                db      182,182,182,181,181,180,180,179,179,178,178,177
                db      177,176,175,174,174,173,172,171,171,170,169,168
                db      167,166,165,164,163,162,161,160,159,158,156,155
                db      154,153,152,150,149,148,147,145,144,143,141,140
                db      139,137,136,134,133,131,130,128,127,125,124,122
                db      121,119,118,116,115,113,112,110,108,107,105,104
                db      102,101,99,97,96,94,93,91,89,88,86,84
                db      83,81,80,78,77,75,73,72,70,69,67,66
                db      64,63,61,60,58,57,55,54,52,51,49,48
                db      47,45,44,42,41,40,38,37,36,35,33,32
                db      31,30,29,27,26,25,24,23,22,21,20,19
                db      18,17,16,15,14,14,13,12,11,11,10,9
                db      8,8,7,7,6,6,5,5,4,4,3,3
                db      3,2,2,2,1,1,1,1,1,1,1,1                                 ; bottom to top palette values

palette         db       7, 7, 7                        ; gray bar start
                db      10,10,10
                db      13,13,13
                db      16,16,16
                db      19,19,19
                db      22,22,22
                db      25,25,25
                db      28,28,28
                db      31,31,31                        ; middle
                db      28,28,28
                db      25,25,25
                db      22,22,22
                db      19,19,19
                db      16,16,16
                db      13,13,13
                db      10,10,10
                db       7, 7, 7                        ; gray bar end
                db       7, 0, 0                        ; red bar start
                db      10, 0, 0
                db      13, 0, 0
                db      16, 0, 0
                db      19, 0, 0
                db      22, 0, 0
                db      25, 0, 0
                db      28, 0, 0
                db      31, 0, 0                        ; middle
                db      28, 0, 0
                db      25, 0, 0
                db      22, 0, 0
                db      19, 0, 0
                db      16, 0, 0
                db      13, 0, 0
                db      10, 0, 0
                db       7, 0, 0                        ; red bar end
                db       0, 7, 0                        ; green bar start
                db       0,10, 0
                db       0,13, 0
                db       0,16, 0
                db       0,19, 0
                db       0,22, 0
                db       0,25, 0
                db       0,28, 0
                db       0,31, 0                        ; middle
                db       0,28, 0
                db       0,25, 0
                db       0,22, 0
                db       0,19, 0
                db       0,16, 0
                db       0,13, 0
                db       0,10, 0
                db       0, 7, 0                        ; green bar end
                db       0, 0, 7                        ; blue bar start
                db       0, 0,10
                db       0, 0,13
                db       0, 0,16
                db       0, 0,19
                db       0, 0,22
                db       0, 0,25
                db       0, 0,28
                db       0, 0,31                        ; middle
                db       0, 0,28
                db       0, 0,25
                db       0, 0,22
                db       0, 0,19
                db       0, 0,16
                db       0, 0,13
                db       0, 0,10
                db       0, 0, 7                        ; blue bar end
                db       7, 7, 0                        ; yellow bar start
                db      10,10, 0
                db      13,13, 0
                db      16,16, 0
                db      19,19, 0
                db      22,22, 0
                db      25,25, 0
                db      28,28, 0
                db      31,31, 0                        ; middle
                db      28,28, 0
                db      25,25, 0
                db      22,22, 0
                db      19,19, 0
                db      16,16, 0
                db      13,13, 0
                db      10,10, 0
                db       7, 7, 0                        ; yellow bar end
                db       7, 0, 7                        ; purple bar start
                db      10, 0,10
                db      13, 0,13
                db      16, 0,16
                db      19, 0,19
                db      22, 0,22
                db      25, 0,25
                db      28, 0,28
                db      31, 0,31                        ; middle
                db      28, 0,28
                db      25, 0,25
                db      22, 0,22
                db      19, 0,19
                db      16, 0,16
                db      13, 0,13
                db      10, 0,10
                db       7, 0, 7                        ; purple bar end
                db       0, 7, 7                        ; cyan bar start
                db       0,10,10
                db       0,13,13
                db       0,16,16
                db       0,19,19
                db       0,22,22
                db       0,25,25
                db       0,28,28
                db       0,31,31                        ; middle
                db       0,28,28
                db       0,25,25
                db       0,22,22
                db       0,19,19
                db       0,16,16
                db       0,13,13
                db       0,10,10
                db       0, 7, 7                        ; cyan bar end
                db      18, 8, 1                        ; copper bar start
                db      23,13, 5
                db      28,18, 9
                db      33,23,13
                db      38,28,17
                db      43,33,21
                db      48,38,25
                db      53,43,29
                db      58,48,33                        ; middle
                db      53,43,29
                db      48,38,25
                db      43,33,21
                db      38,28,17
                db      33,23,13
                db      28,18, 9
                db      23,13, 5
                db      18, 8, 1                        ; copper bar end

barline         dw      175,150,125,100,75,50,25,0
;barline         dw      175,170,165,160,155,150,145,140
barpriority     db      200 dup(0)
barheight       dw      17
barcount        dw      8
barpal          db      400*3 dup(0)
irqsave         db      ?
nmisave         db      ?

        end     start
