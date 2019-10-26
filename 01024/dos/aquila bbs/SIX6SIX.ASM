                code    segment
                org     100h
                assume  cs:code, ds:code, es:code, ss:code
                .286                            ; 286 or higher required

TekstCol        equ     34
Start:          call    SetVoices
                mov     di,offset StarTable
                mov     cl,200
IniLop:         call    Random
                mov     [di],dx
                mov     [di+4],ah
                add     di,5
                loop    IniLop

                mov     al,13h
                int     10h
                mov     ax,1124h
                mov     bl,1
                int     10h
                mov     ax,0A000h
                mov     es,ax

Lopje:          mov     dx,3DAh
Trace1:         in      al,dx
                test    al,8
                jz     Trace1


                mov     di,offset StarTable
                xor     si,si
                mov     cx,200
StarLus:        mov     bx,[di]
                cmp     byte ptr es:[si][bx],TekstCol
                je      NoWipe
                mov     al,[di+4]
                mov     es:[si][bx],al
NoWipe:         mov     ax,[di+2]
                sub     bx,ax
                jnc     StarLus1
                add     bx,320
                call    Random
StarLus1:       mov     [di],bx
                mov     ah,es:[si][bx]
                mov     [di+4],ah
                or      ah,ah
                jnz     NoDot
                shl     al,1
                add     al,14
                mov     es:[si][bx],al
NoDot:          add     di,5
                add     si,320
                loop    StarLus

                call    Text
                call    PlayBMF
                mov     ah,1
                int     16h
                jz      Lopje
                mov     ah,0
                int     16h
                mov     ax,3
                int     10h
                ret

Random:         mov     ax,23452
                org     $-2
Rand1           dw      23452
                rol     ax,3
                add     ax,7
                mov     Rand1,ax
                add     ax,13753
                org     $-2
Rand2           dw      13753
                add     Rand2,41125
                ror     Rand2,7

                xor     dx,dx
                mov     bp,320
                div     bp
                and     ax,7
                inc     ax
                mov     [di+2],ax
                ret

Text            proc    near
                inc     TextTel
                and     TextTel,3
                jnz     Text4
                mov     si,TekstPtr
Text1:          lodsb
                or      al,al
                jnz     Text3
                mov     si,offset ReturnPtr
                lodsb
Text3:          cmp     al,32
                jae     Text2
                mov     ah,al
                lodsb
                mov     dx,ax
                mov     ah,2
                xor     bh,bh
                int     10h
                lodsb
Text2:          mov     TekstPtr,si
                mov     bx,TekstCol
                mov     ah,0Eh
                int     10h
Text4:          ret
Text            endp

TekstPtr        dw      offset Tekst
Tekst           db      3,17,'AQUILA'
                db      6,13,'RAZOR 1911 EHQ'
                db      7,12,'Sysop: THE BRAIN'
                db      8,11,'Co''s: MASE & NAiLZ'

ReturnPtr       db      4,17,'שתשתש‏'
                db      4,18, 'שת‏ '
                db      4,17,'ת‏ שתת'
                db      0

;------------------------------------------------------------------------------
;                         Pretty small music routine ...
;------------------------------------------------------------------------------

Channels        equ     3

Voice00         db      224, 32, 33,  0,195,182,245,246,  3,  3,  2
Voice01         db       64,  0,  0,  0,250,217, 55,  4,  0,  0,  0

Chan2           db      80h    ; ...
                db      80h+4  ; Wait 4
Chan1           db      252,8  ; Repeat 8
                db      153    ;  / D#2 ????????????????
                db      33     ;  \ Modulation 49
                db      165    ;  / ???
                db      30     ;  \ Modulation 52
                db      153    ;  /
                db      27     ;  \ Modulation 54
                db      163    ;  /
                db      24     ;  \ Modulation 56
                db      165    ;  /
                db      21     ;  \ Modulation 58
                db      153    ;  /
                db      33     ;  \ Modulation 52
                db      165    ;  /
                db      40     ;  \ Modulation 48
                db      153    ;  /
                db      47     ;  \ Modulation 44
                db      125    ; Next
                db      254    ; End of channel
Chan3           db      252,4  ; Repeat 4
                db      128    ;  / ...
                db      80h+64 ;  \ Wait 64
                db      125    ; Next
                db      252,16 ; Repeat 4*4
                db      141    ;  / C-1
                db      80h+16 ;  \ Wait 16
                db      125    ; Next
                db      254    ; End of channel
ChnStart        dw      Chan1,Chan1,Chan3
ChnPtr          dw      Chan1,Chan2,Chan3

;------------------------------------------------------------------------------
;
PlayBMF         proc    near
                xor     MusWait,1
                jnz     short PlayBMF5
                xor     di,di            ; Play all channels
PlayBMF4:       call    PlayChannel
                inc     di
                cmp     di,Channels
                jne     short PlayBMF4
PlayBMF5:       ret
PlayBMF         endp


;------------------------------------------------------------------------------
; input: DI=channel (0-8)
;
PlayChannel     proc    near
                mov     bx,di
                shl     bx,1
                mov     si,ChnPtr[bx]       ; Get music pointer
                dec     ChnWait[di]         ; Exit if waiting (count>0)
                jnz     short PlayBMF5
                mov     ChnWait[di],8
PlayChannel1:   lodsb                       ; read tone/OFF/.../loop/end
                cmp     al,7Dh              ; END OF LOOP
                jne     short PlayChannel2
                dec     ChnLoopCnt[di]
                jz      short PlayChannel1
                mov     si,ChnLoopAdr[bx]
                jmp     short PlayChannel1
PlayChannel2:   cmp     al,0FCh             ; LOOP START
                jne     short PlayChannel3
                lodsb
                mov     ChnLoopCnt[di],al
                mov     ChnLoopAdr[bx],si
                jmp     short PlayChannel1
PlayChannel3:   cmp     al,0FEh             ; END OF DATA
                jne     short PlayChannel4
                mov     si,ChnStart[bx]
                jmp     short PlayChannel1
PlayChannel4:   push    ax
                lodsb                       ; read effect/wait count
                rol     al,1
                shr     al,1
                jnc     PlayChannel5
                mov     ChnWait[di],al
                jmp     short PlayChannel6
PlayChannel5:   mov     ah,al
                mov     al,40h
                call    SetFMRegDI
PlayChannel6:   pop     ax
                ; AL = tone to play         ; No note -> no action
                and     al,7Fh
                jz      short PlayChannel7

                push    ax
                mov     ah,ChnHigh[di]
                mov     al,0B0h
                call    SetFMRegDI
                pop     ax

                ; play tone
                dec     al
                xor     ah,ah
                mov     bl,12
                div     bl
                mov     bx,ax
                shr     bx,7
                shl     ax,10
                or      ax,FreqTab[bx]
                mov     ChnHigh[di],ah
                or      ah,020h
                mov     bl,al
                mov     al,0B0h
                call    SetFMRegDI
                mov     al,0A0h
                mov     ah,bl
                call    SetFMRegDI

PlayChannel7:   shl     di,1                ; Store music-pointer
                mov     ChnPtr[di],si
                shr     di,1
                ret
PlayChannel     endp

SetVoices:      mov     ax,2001h
                call    SetFMReg
                mov     ax,0008h
                call    SetFMReg
                mov     ax,0C0BDh
                call    SetFMReg
                xor     di,di
                mov     si,offset Voice00
                call    SetVoices1
                mov     byte ptr si[3],8
                call    SetVoices1
                mov     si,offset Voice01
SetVoices1:     xor     bx,bx
SetVoices2:     mov     al,RegList[bx]
                mov     ah,[si][bx]
                call    SetFMRegDI
                inc     bx
                cmp     bx,11
                jb      short SetVoices2
                inc     di
                ret

;------------------------------------------------------------------------------
; input: AL=register, AH=data
;
SetFMRegDI:     add     ax,di
SetFMReg        proc    near
                mov     dx,388h
                out     dx,al
                in      al,dx
                in      al,dx
                in      al,dx
                in      al,dx
                inc     dl
                mov     al,ah
                out     dx,al
                dec     dl
                mov     cx,20
SetFMReg1:      in      al,dx
                loop    short SetFMReg1
                ret
SetFMReg        endp


;------------------------------------------------------------------------------
;
FreqTab         dw      157h,16Bh,181h,198h,1B0h,1CAh,1E5h,202h,220h,241h,263h,287h
RegList         db      20h,23h,40h,43h,60h,63h,80h,83h,0E0h,0E3h,0C0h
MusWait         db      0                       ; Music Wait Counter
ChnWait         db      Channels dup(1)         ; Channel Wait counters
ChnHigh         db      Channels dup(0)         ; High freq byte
ChnLoopAdr      dw      Channels dup(?)         ; Loop address
ChnLoopCnt      db      Channels dup(?)         ; Loop counter


StarTable       db      200 dup(?,?,?,?,?)
TextTel         db      ?

                code    ends
                end     Start
