; Board ad for The Manhattan Project by Patch (hamell@rigel.cs.pdx.edu)
; Bouncing screen in text mode
; One of my first ASM programs using direct register manipulation
; 1-??-93
; Call Dead Man's Hand at 503.288.9264 - USR 16.8k DS
; Programming source only

.model  tiny
.code
        org     100h

start:
                call    HideCursor
                call    SaveScreen
                mov     bp,offset palette
                call    SavePalette
                mov     ax,0501h                ;set video page to 1
                int     10h
                mov     ax,text_seg
                mov     es,ax
                xor     ax,ax
                mov     di,4000
                mov     cx,2000
                rep     stosw                   ;clear video page 1
                call    WaitRetrace
                xor     di,di
                mov     si,offset logo
                mov     cx,2000
                rep     movsw                   ;put logo on video page 0
Bounce:         call    PanScreenDown
                sub     [bounceval],05h
                cmp     [bounceval],00h
                jle     NoBounce
                call    PanScreenUp
                call    WaitRetrace
                jmp     Bounce
NoBounce:       call    GetKey
                mov     ax,0500h
                int     10h
                mov     bp,offset palette
                call    FadeOut
                call    RestoreScreen
                mov     bp,offset palette
                call    FadeIn
                call    ShowCursor
                mov     ah,09h
                mov     dx,offset message
                int     21h
                jmp     Exit

GetKey          PROC
                xor     ax,ax                   ; AH=0, wait for key
                int     16h                     ; perform KBD interrupt
                ret
GetKey          ENDP                

HideCursor      PROC
                mov     ax,0100h
                mov     cx,0800h
                int     10h
                ret
HideCursor      ENDP

ShowCursor      PROC
                mov     ax,0100h
                mov     cx,0607h
                int     10h
                ret
ShowCursor      ENDP                

SaveScreen      PROC
                push    ds                      ; push
                cld                             ; clear direction to add
                mov     ax,ds                   ; destination segment
                mov     es,ax                   ; can't load directly
                mov     di,offset screen        ; destination offset
                mov     ax,text_seg             ; source segment
                mov     ds,ax                   ; can't load directly
                xor     si,si                   ; source offset
                mov     cx,2000                 ; the entire screen, 80x25
                rep     movsw                   ; store them all
                pop     ds                      ; pop
                ret                             ; return
SaveScreen      ENDP                

RestoreScreen   PROC
                push    ds                      ; push
                cld                             ; clear direction to add
                mov     ax,text_seg             ; destination segment
                mov     es,ax                   ; can't load directly
                xor     di,di                   ; destination offset
                                                ; DS already points at DS
                mov     si,offset screen        ; source offset
                mov     cx,2000                 ; the entire screen, 80x25
                rep     movsw                   ; store them all
                pop     ds                      ; pop
                ret                             ; return
RestoreScreen   ENDP                          

WaitRetrace     PROC
                mov     dx,input1_reg           ;Input Status Register 1
Retrace:        in      al,dx                   ;read the port
                test    al,1000b                ;test bit 3, vertical retrace
                jnz     Retrace                 ;if not active, go back
NoRetrace:      in      al,dx                   ;read the port
                test    al,1000b                ;test bit 3, vertical retrace
                jz      NoRetrace               ;if active, go back
                ret
WaitRetrace     ENDP

FadeOut         PROC                    ; load BP with palette pointer first
                cli                             ; clear interrupts
                mov     cx,64                   ; values are 0-63, set to 63
     OneCycleO: xor     bx,bx                   ; 0 out for counter use
       DecRegO: cmp     BYTE PTR [bp+768],00h   ; is our palette value 0?
                je      ContinueO               ; if so, skip it
                dec     BYTE PTR [bp+768]       ; if not, decrement by 1
     ContinueO: inc     bp
                inc     bx                      ; increment counter
                cmp     bx,768                  ; have we done all 768 regs?
                jl      DecRegO                 ; if not, go back
                push    cx                      ; store 1st loop counter
                mov     cx,768                  ; we want to do all 768 regs
                sub     bp,768
                xor     bx,bx
                call    WaitRetrace             ; wait for retrace
                call    WaitRetrace
                mov     dx,03c8h                ; write address for start reg #
                xor     al,al                   ; start at register 0
                out     dx,al                   ; write to port
                mov     dx,03c9h                ; write address for actual dump
     DumpPortO: mov     al,BYTE PTR [bp+768]    ; store current array value
                out     dx,al                   ; write to port
                inc     bp
                inc     bx                      ; increment counter
                loop    DumpPortO               ; 768 done?  if not, go back
                pop     cx                      ; restore 1st loop counter
                sub     bp,768
                loop    OneCycleO               ; 64 done?  if not, go back
                sti                             ; set interrupts
                ret                             ; return
FadeOut         ENDP

FadeIn          PROC                    ; load BP with palette pointer first
                cli                             ; clear interrupts
                mov     cx,64                   ; values are 0-63, set to 64
     OneCycleI: xor     bx,bx                   ; 0 out for counter use
       DecRegI: mov     dh,[bp]
                mov     dl,[bp+768]
                cmp     dl,dh                   ; is our palette value 64?
                je      ContinueI               ; if so, skip it
                inc     BYTE PTR [bp+768]       ; if not, increment by 1
     ContinueI: inc     bp
                inc     bx                      ; increment counter
                cmp     bx,768                  ; have we done all 768 regs?
                jl      DecRegI                 ; if not, go back
                push    cx                      ; store 1st loop counter
                mov     cx,768                  ; we want to do all 768 regs
                sub     bp,768
                xor     bx,bx
                call    WaitRetrace             ; wait for retrace
                call    WaitRetrace
                mov     dx,03c8h                ; write address for start reg #
                xor     al,al                   ; start at register 0
                out     dx,al                   ; write to port
                mov     dx,03c9h                ; write address for actual dump
     DumpPortI: mov     al,[bp+768]             ; store current array value
                out     dx,al                   ; write to port
                inc     bp
                inc     bx                      ; increment counter
                loop    DumpPortI               ; 768 done?  if not, go back
                pop     cx                      ; restore 1st loop counter
                sub     bp,768
                loop    OneCycleI               ; 64 done?  if not, go back
                sti                             ; set interrupts
                ret                             ; return
FadeIn          ENDP

SavePalette     PROC                    ; load BP with palette pointer first
                push    bp
                cli
                mov     cx,768          ; set up loop to get 256 RGB values
                mov     dx,03c7h        ; read address to set up register #
                xor     al,al           ; start with register 0
                out     dx,al           ; write to port
                mov     dx,03c9h        ; read address to set up read RGB values
      GrabNext: in      al,dx           ; grab the palette value
                and     al,3fh          ; mask off the upper 2 bits
                mov     BYTE PTR [bp],al       ; store value as save palette
                mov     BYTE PTR [bp+768],al   ; store value as temp palette
                inc     bp              ; increment counter
                loop    GrabNext        ; grab the next value
                sti
                pop     bp
                ret                     ; return
SavePalette     ENDP

RestorePalette  PROC                    ; load BP with palette pointer first
                push    bp
                cli
                mov     cx,768          ; set up loop to get 256 RGB values
                mov     dx,03c8h        ; write address to set up register #
                xor     al,al           ; start with register 0
                out     dx,al           ; write to port
                mov     dx,03c9h        ; address to dump RGB values
      DumpNext: mov     al,BYTE PTR [bp]
                out     dx,al           ; grab the palette value
                inc     bp              ; increment counter
                loop    DumpNext        ; grab the next value
                sti
                pop     bp
                ret                     ; return                
RestorePalette  ENDP

SetMemAdd       PROC                            ;set BX with address
                mov     dx,crtc_reg             ;set up CRTC reg
                mov     al,0ch                  ;0Ch = start address high
                mov     ah,bh                   ;store high byte
                out     dx,ax                   ;set index reg, high byte
                inc     al                      ;0Dh = start address low
                mov     ah,bl                   ;store low byte
                out     dx,ax                   ;set index reg, low byte
                ret
SetMemAdd       ENDP

PanScreenUp     PROC
                xor     ax,ax
                mov     al,[bounceval]
                mov     si,ax
                mov     di,offset bouncespeeds
                add     di,si
                mov     byte ptr [di-1],02h
                mov     byte ptr [di-2],04h
                mov     byte ptr [di-3],08h
StartPanUp:     sub     di,si
                cli                             ;turn interrupts off
                call    WaitRetrace             ;wait for display interval
PanUp:          mov     bx,[mem_add]            ;move value into BX
                add     [mem_add],80            ;set it to the next line
                call    SetMemAdd               ;set the memory address
                mov     bx,0008h                ;index 8, preset row scan
                                                ;start at 0
                mov     cx,0010h                ;character is 16 scan lines

PanSpeedUp:     mov     bh,byte ptr [di]
                dec     bh                      ;at first panspeed line

NextUBit:       call    WaitRetrace
                mov     dx,crtc_reg             ;CRTC register
                mov     ax,bx                   ;move index and value
                out     dx,ax                   ;dump it to the port
                add     bh,byte ptr [di]
                sub     cl,byte ptr [di]
                inc     cl                      ;and adjust for loop dec
                loop    NextUBit                ;do it again

                inc     di
                dec     si
                jnz     PanUp                   ;if not, do it again

                sub     [mem_add],80
                sti                             ;turn interrupts on
                ret
PanScreenUp     ENDP

PanScreenDown   PROC
                xor     ax,ax
                mov     al,[bounceval]
                mov     si,ax
                mov     ax,ds
                mov     es,ax
                mov     di,offset bouncespeeds
                mov     cx,si
                cld
                mov     al,16
                rep     stosb
                sub     di,si
                mov     byte ptr [di],02h
                mov     byte ptr [di+1],04h
                mov     byte ptr [di+2],08h
                cli                             ;turn interrupts off
                call    WaitRetrace             ;wait for display interval
PanDown:        mov     bx,[mem_add]            ;move it into BX
                sub     [mem_add],80            ;subtract 80 for next line
                call    SetMemAdd               ;set the memory address

                mov     bx,0f08h                ;index 8, preset row scan
                                                ;start at 15
                mov     cx,0010h                ;character is 16 scan lines
PanSpeedDown:   sub     bh,byte ptr [di]
                inc     bh                      ;at first panspeed line

NextDBit:       call    WaitRetrace             ;wait for vertical retrace
                mov     dx,crtc_reg             ;CRTC register
                mov     ax,bx                   ;move index and value
                out     dx,ax                   ;dump it to the port
                sub     bh,byte ptr [di]
                sub     cl,byte ptr [di]
                inc     cl                      ;and adjust for loop dec
                loop    NextDBit                ;do it again

                inc     di
                dec     si
                jnz     PanDown
                add     [mem_add],80
                sti                             ;turn interrupts on
                ret
PanScreenDown   ENDP

Exit:           mov     ax,4c00h
                int     21h

;data defines

LOGO    DB      'Û',8,'Û',8,'Û',8,'Û',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8
        DB      'ß',8,'ß',8,'Û',8,'Û',8,'Û',8,'ß',8,'ß',8,'ß',8,'ß',8
        DB      'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,'ß',8,'ß',8,'ß',8,'Û',8,'Û',8,'Û',8
        DB      'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8
        DB      'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8
        DB      'ß',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'ß',8,'ß',8
        DB      'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,' ',8,'Û',8,'ß',8,'ß',8,'ß',8,'Û',8
        DB      'Ü',8,'Ü',8,'Ü',8,'Ü',8,' ',8,'Û',8,'ß',8,'ß',8,'ß',8
        DB      'ß',8,'ß',8,'Û',8,' ',8,'Ü',8,'Ü',8,'Ü',8,'Ü',8,'Ü',8
        DB      'Ü',8,'Ü',8,' ',8,'Û',8,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,'Û',8,' ',8,'Û',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'Û'
        DB      8,' ',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'Û',8,' '
        DB      8,'Ü',8,'Ü',8,'Ü',8,'Ü',8,'Ü',8,'Ü',8,' ',8,'Û',8,'ß'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'Û',8,' ',8,'Ü',8,'Ü',8,'Ü'
        DB      8,'Ü',8,'Ü',8,'Ü',8,'Ü',8,' ',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,' ',8,'Û',8,' ',8,' ',8,' ',8,'Û',8,' '
        DB      8,' ',8,' ',8,'Û',8,' ',8,'Û',8,' ',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'Û',8,' ',8,'Û',8,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,'Û',8,' ',8,'Û',8,' ',8,'ß',8,'ß',8,'ß',8,'ß',8
        DB      'Û',8,' ',8,'Û',8,' ',8,'ß',8,'ß',8,'ß',8,'ß',8,'Û',8
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'Û',8
        DB      ' ',8,'Û',8,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      'Û',8,' ',8,'ß',8,'ß',8,'ß',8,'ß',8,'Û',8,' ',8,'Û',8
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,'Û',8,' ',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,' ',8,'Ü',127,' ',15,' ',15
        DB      ' ',15,'Ü',127,' ',15,' ',15,' ',15,'Ü',127,' ',15,'Ü'
        DB      127,' ',15,' ',15,' ',15,' ',15,' ',15,'Ü',127,' ',15
        DB      'Ü',127,' ',15,' ',15,' ',15,' ',15,' ',15,'Ü',127,' '
        DB      15,'Ü',127,' ',15,' ',15,' ',15,' ',15,' ',15,'Ü',127
        DB      ' ',15,'Ü',127,' ',15,' ',15,' ',15,' ',15,' ',15,'Ü'
        DB      127,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'Ü'
        DB      127,' ',15,'Ü',127,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,'Ü',127,' ',15,' ',15,' ',15,' ',15,' ',15,'Ü'
        DB      127,' ',15,'Ü',127,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      'Ü',127,' ',15,'Û',8,'Û',8,'Û',8,' ',8,'Ü',5,'Ü',13,'Ü'
        DB      13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü'
        DB      13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü'
        DB      13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü'
        DB      13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü'
        DB      13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü'
        DB      13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü'
        DB      13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü'
        DB      13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü'
        DB      13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü',13,'Ü'
        DB      13,'Ü',13,' ',13,'Û',8,'Û',8,' ',8,'Û',8,'Û',5,'P',95
        DB      ' ',95,' ',95,' ',95,' ',95,'Û',5,' ',85,' ',85,' ',85
        DB      ' ',85,' ',85,' ',85,'R',95,' ',95,'Û',5,' ',85,' ',85
        DB      ' ',85,' ',85,' ',85,' ',85,' ',85,' ',85,'O',95,' ',95
        DB      ' ',95,' ',95,'Û',5,' ',85,' ',85,' ',85,' ',85,' ',85
        DB      ' ',85,' ',85,'J',95,' ',95,' ',95,' ',95,' ',95,'Û',5
        DB      ' ',85,' ',85,' ',85,' ',85,' ',85,' ',85,'E',95,' ',95
        DB      ' ',95,' ',95,'Û',5,'Û',5,' ',85,' ',85,' ',85,' ',85
        DB      ' ',85,' ',85,'C',95,' ',95,'Û',5,' ',85,' ',85,' ',85
        DB      ' ',85,' ',85,' ',85,' ',85,' ',85,' ',85,'T',95,'Û',5
        DB      'Û',13,' ',13,'Û',8,'Û',8,' ',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      5,' ',5,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,'ß'
        DB      8,'ß',8,'ß',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'ß',8,' ',8,'Ü'
        DB      9,'ß',25,'ß',25,'ß',25,'ß',25,'ß',25,'ß',25,'ß',25,'ß'
        DB      25,'ß',25,'Ü',9,' ',9,'ß',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,' ',8,'Ú',12,'Ä',12,'Ä',8,'Ä',12,'Ä',12,'Ä',8,'Ä',12
        DB      'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8
        DB      'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8
        DB      'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'¿',8,' ',8
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'ß',8,' ',8,'Ü',9,'ß',25
        DB      'ß',1,' ',1,'Ü',2,'Ü',2,'Ü',2,'Ü',2,'Ü',2,'Ü',2,'Ü',2
        DB      ' ',2,'ß',1,'ß',25,'Ü',9,' ',9,'ß',8,'ß',8,'ß',8,'ß',8
        DB      'ß',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      ' ',8,'³',12,' ',12,'þ',10,' ',10,'T',14,'h',14,'e',14
        DB      ' ',14,'M',14,'a',14,'n',14,'h',14,'a',14,'t',14,'t',14
        DB      'a',14,'n',14,' ',14,'P',14,'r',14,'o',14,'j',14,'e',14
        DB      'c',14,'t',14,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,'³',8,' ',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'ß',8,' ',8,'Ü',9
        DB      'ß',25,'ß',1,' ',1,'Ü',2,'Ü',42,'Ü',10,'ß',2,'ß',42,'Û'
        DB      42,'Û',42,'Û',42,'Û',42,'Ü',42,'Ü',2,' ',2,'ß',1,'ß',25
        DB      'ß',25,'ß',25,'ß',25,'Û',9,' ',9,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,' ',8,'Ã',8,'Ä',8,'Ä',8,'Ä'
        DB      8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä'
        DB      8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä'
        DB      8,'Ä',12,'Ä',12,'Ä',8,'Ä',12,'Ä',8,'Ä',12,'Ä',12,'Ä',12
        DB      'Ä',8,'Ä',12,'´',12,' ',12,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'ß',8,' ',8,'Ü',9,'ß'
        DB      25,'ß',1,' ',1,'Ü',2,'Ü',42,'Û',42,'Û',42,'Û',42,'Û',10
        DB      'Ü',2,'ß',2,'ß',42,'Û',42,'Û',42,'Û',42,'Û',42,'Ü',42
        DB      'Ü',2,' ',2,'Ü',2,' ',2,'Û',1,'Û',9,' ',9,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,' ',8,'³',8,' ',8
        DB      'þ',10,' ',10,'F',14,'L',14,'T',14,' ',14,'M',14,'e',14
        DB      'm',14,'b',14,'e',14,'r',14,' ',14,'B',14,'o',14,'a',14
        DB      'r',14,'d',14,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'³',12,' ',12
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,' ',8,'Ü',9,'Ü',9,'Ü',9
        DB      'Ü',9,'Ü',9,'Û',9,'Û',1,' ',1,'Ü',2,'Ü',42,'Û',42,'Û'
        DB      42,'Û',42,'Û',42,'ß',42,'ß',2,' ',2,' ',2,' ',2,'ß',2
        DB      'ß',42,'Û',42,'Û',42,'Û',42,'Û',42,'Ü',42,'Û',2,' ',2
        DB      'Û',1,'Û',9,'Ü',9,' ',9,'ß',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,' ',8,'³',8,' ',8,'þ',10,' ',10,'F',14,'L'
        DB      14,'T',14,' ',14,'T',14,'r',14,'a',14,'i',14,'n',14,'e'
        DB      14,'r',14,'s',14,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,'³',8,' ',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,' ',8,'Û',9,'Û',1,'ß',1,'ß',1,'ß',1,'ß',1,'ß',1,' '
        DB      1,' ',1,'ß',2,'ß',42,'Û',42,'ß',42,'ß',2,' ',2,'Ü',7,'Ä'
        DB      7,'Ä',7,'Ä',7,'Ü',7,' ',7,'ß',2,'ß',42,'Û',42,'Û',42,'Û'
        DB      42,'Û',2,' ',2,'ß',1,'ß',1,'ß',1,'ß',25,'Ü',9,' ',9,'ß'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,' ',8,'³',8,' ',8,'þ',10,' '
        DB      10,'T',14,'R',14,'W',14,'S',14,' ',14,'D',14,'i',14,'s'
        DB      14,'t',14,'r',14,'i',14,'b',14,'u',14,'t',14,'i',14,'o'
        DB      14,'n',14,' ',14,'S',14,'i',14,'t',14,'e',14,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,'³',12,' ',12,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'ß',8,' ',8,'Û',9,'Û',1,' ',1,'ß',2,'Û'
        DB      2,'Ü',42,'Ü',42,'Ü',42,'Û',2,' ',2,' ',2,'ß',2,' ',2,' '
        DB      2,'Û',8,'Û',7,'Ü',7,'Ü',7,'Ü',7,'Û',7,' ',7,'ß',2,'ß'
        DB      2,'ß',2,'ß',2,'ß',2,'ß',2,' ',2,'Ü',2,'Ü',42,'Ü',2,' '
        DB      2,'ß',1,'ß',25,'Ü',9,' ',9,'ß',8,'Û',8,'Û',8,' ',8,'³'
        DB      8,' ',8,'þ',10,' ',10,'M',14,'A',14,'L',14,'i',14,'C'
        DB      14,'E',14,' ',14,'D',14,'i',14,'s',14,'t',14,'r',14,'i'
        DB      14,'b',14,'u',14,'t',14,'i',14,'o',14,'n',14,' ',14,'S'
        DB      14,'i',14,'t',14,'e',14,' ',14,' ',15,' ',15,' ',15,'³'
        DB      8,' ',8,'Û',8,'Û',8,'ß',8,' ',8,'Ü',9,'ß',25,'ß',1,' '
        DB      1,'Ü',2,'Ü',42,'Û',10,'Û',10,'Û',10,'Û',10,'Û',2,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,'Û',8,'Û',7,'Û',127,'Û',127
        DB      'Û',127,'Û',7,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      'Ü',2,'Ü',42,'Û',42,'Û',42,'Û',42,'Ü',42,'Ü',2,' ',2,'ß'
        DB      1,'ß',25,'Ü',9,' ',9,'ß',8,' ',8,'³',8,' ',8,'þ',10,' '
        DB      10,'A',14,'C',14,'i',14,'D',14,' ',14,'O',14,'r',14,'e'
        DB      14,'g',14,'o',14,'n',14,' ',14,'O',14,'u',14,'t',14,'p'
        DB      14,'o',14,'s',14,'t',14,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',14,' ',14,' ',14,'³',8,' ',8,'Û',8,'Û',8
        DB      'Ü',9,'ß',25,'ß',1,' ',1,'Ü',2,'Ü',42,'Û',10,'Û',10,'Û'
        DB      10,'Û',10,'ß',42,'ß',2,'Û',114,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,'ß',8,'ß',8,'ß',8,'ß',8,'ß',8,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'ß',2,'ß',42
        DB      'Û',42,'Û',42,'Û',42,'Û',42,'Ü',42,'Ü',2,' ',2,'ß',1,'ß'
        DB      25,'Ü',9,' ',9,'³',12,' ',12,'þ',10,' ',10,'5',14,'0'
        DB      14,'3',14,'.',14,'X',14,'X',14,'X',14,'.',14,'X',14,'X'
        DB      14,'X',14,'X',14,' ',14,'-',14,' ',14,'1',14,'6',14,'.'
        DB      14,'8',14,'k',14,' ',14,'D',14,'u',14,'a',14,'l',14,' '
        DB      15,' ',15,' ',15,'³',8,' ',8,'Û',120,'²',120,'Û',9,'Û'
        DB      1,' ',1,'ß',2,'ß',42,'Û',10,'Û',42,'Û',10,'ß',42,'ß',2
        DB      'Ü',2,'Ü',2,'Ü',2,'Ü',2,'Ü',2,'Ü',2,'Ü',2,'Ü',2,'Ü',2
        DB      'Ü',2,'Ü',2,' ',2,' ',2,' ',2,'Ü',2,'Ü',42,'Ü',2,'Ü',2
        DB      'Ü',2,'Ü',2,'Ü',2,'Ü',2,'Ü',2,'ß',2,'ß',42,'Û',42,'Û'
        DB      42,'Û',42,'ß',42,'ß',2,' ',2,'Ü',1,'Û',9,' ',9,'³',8,' '
        DB      8,'þ',10,' ',10,'5',14,'0',14,'3',14,'.',14,'X',14,'X'
        DB      14,'X',14,'.',14,'X',14,'X',14,'X',14,'X',14,' ',14,'-'
        DB      14,' ',14,'1',14,'6',14,'.',14,'8',14,'k',14,' ',14,'D'
        DB      14,'u',14,'a',14,'l',14,' ',14,' ',14,' ',14,'³',8,' '
        DB      8,'²',120,'±',120,' ',15,'ß',9,'Ü',25,'Ü',1,' ',1,'ß'
        DB      2,'ß',42,'ß',2,'Ü',10,'Û',10,'Û',10,'Û',10,'Û',10,'Û'
        DB      10,'Û',10,'Û',10,'Û',10,'Û',10,'Û',10,'Û',10,'Û',2,' '
        DB      2,'Ü',2,'Ü',42,'Û',42,'Û',42,'Û',42,'Û',42,'Û',42,'Û'
        DB      42,'Û',42,'Û',42,'Û',42,'Û',10,'Ü',10,'ß',2,'ß',42,'ß'
        DB      2,' ',2,'Ü',1,'Ü',25,'ß',9,' ',9,' ',9,'³',12,' ',12,'þ'
        DB      10,' ',10,'P',14,'r',14,'o',14,'D',14,'o',14,'o',14,'r'
        DB      14,' ',14,'/',14,' ',14,'P',14,'r',14,'o',14,'L',14,'o'
        DB      14,'g',14,'o',14,'n',14,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',14,' ',14,' ',14,'³',8,' ',8,'±'
        DB      120,'°',120,'Û',8,'Ü',8,' ',8,'ß',9,'Ü',25,'Ü',1,' ',1
        DB      'ß',2,'ß',42,'ß',42,'ß',42,'ß',42,'ß',42,'ß',42,'ß',42
        DB      'ß',42,'ß',42,'ß',42,'ß',42,'ß',42,'Û',2,' ',2,' ',2,'ß'
        DB      2,'ß',42,'Û',42,'ß',42,'ß',42,'ß',42,'ß',42,'ß',42,'ß'
        DB      42,'ß',42,'ß',42,'ß',42,'ß',2,' ',2,'Ü',1,'Ü',25,'ß',9
        DB      ' ',9,'Ü',8,'Û',8,' ',8,'³',8,' ',8,'þ',10,' ',10,'5'
        DB      14,'5',14,'0',14,' ',14,'M',14,'e',14,'g',14,'s',14,' '
        DB      14,'O',14,'n',14,'l',14,'i',14,'n',14,'e',14,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,'³',8,' ',8,'°',120,' ',120,'Û'
        DB      8,'Û',8,'Û',8,'Ü',8,' ',8,'ß',9,'Ü',25,'Ü',1,'Ü',1,'Ü'
        DB      1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü'
        DB      1,'Ü',1,'Ü',1,'Ü',1,'Ü',25,'Ü',1,' ',1,'ß',2,' ',2,'Ü'
        DB      1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü',1,'Ü'
        DB      25,'ß',9,' ',9,'Ü',8,'Û',8,'Û',8,'Û',8,' ',8,'³',12,' '
        DB      12,'þ',10,' ',10,'S',14,'y',14,'s',14,'o',14,'p',14,':'
        DB      14,' ',14,'R',14,'i',14,'f',14,'l',14,'e',14,'m',14,'a'
        DB      14,'n',14,' ',14,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'³',8,' '
        DB      8,' ',120,'±',127,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Ü',8
        DB      ' ',8,'ß',9,'ß',9,'ß',9,'ß',9,'ß',9,'ß',9,'ß',9,'ß',9
        DB      'ß',9,'ß',9,'ß',9,'ß',9,'ß',9,'ß',9,'ß',9,' ',9,'ß',9
        DB      'Ü',25,'Ü',25,'Ü',25,'Û',9,'ß',9,'ß',9,'ß',9,'ß',9,'ß'
        DB      9,'ß',9,'ß',9,'ß',9,' ',9,'Ü',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,' ',8,'³',12,' ',12,'þ',10,' ',10,'C',14,'o',14
        DB      ' ',14,' ',14,' ',14,':',14,' ',14,'P',14,'a',14,'t',14
        DB      'c',14,'h',14,' ',14,' ',14,' ',14,' ',14,' ',14,' ',14
        DB      ' ',14,' ',14,' ',14,' ',14,' ',14,' ',14,' ',14,' ',14
        DB      ' ',14,' ',14,'³',12,' ',12,'°',127,'±',127,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Ü',8,'Ü',8,'Ü',8,'Ü',8,'Ü',8,'Ü'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,' ',8,'³',12,' ',12,'þ'
        DB      10,' ',10,'A',14,'n',14,'s',14,'i',14,' ',14,':',14,' '
        DB      14,'S',14,'p',14,'e',14,'e',14,'d',14,' ',14,'D',14,'e'
        DB      14,'m',14,'o',14,'n',14,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,'³',12,' ',12,'±'
        DB      127,'²',127,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8
        DB      ' ',8,'À',12,'Ä',12,'Ä',8,'Ä',12,'Ä',12,'Ä',12,'Ä',12
        DB      'Ä',12,'Ä',8,'Ä',12,'Ä',12,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä'
        DB      8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä',8,'Ä'
        DB      8,'Ä',12,'Ä',8,'Ä',12,'Ä',12,'Ä',8,'Ä',12,'Ä',12,'Ù',12
        DB      ' ',12,'²',127,'Û',127,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û',8,'Û'
        DB      8,'Û',8,'Û',8,'Û',8,'²',120,'±',120,'°',120,' ',120,'°'
        DB      127,'±',127,'²',127,'Û',15

attr_reg        equ     03c0h
crtc_reg        equ     03d4h
input1_reg      equ     03dah
text_seg        equ     0b800h
mem_add         dw      1920
bounceval       db      25
bouncespeeds    db      25 dup(16)
startx          db      ?
starty          db      ?
palette         db      768*2 dup(?)
screen          db      4000 dup(?)
message         db      13,10
                db      'ÚÄÄÄÄÄÄÄ Coding by Patch ì FLT Cheats ÄÄÄÄÄÄÄÄ¿',13,10
                db      'À Written 100% in Assembly - uses smooth pans Ù',13,10,'$'

                END     start
