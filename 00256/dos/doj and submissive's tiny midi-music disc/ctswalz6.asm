
; ctswalz version 6 (179 bytes) by Jens.Hohmuth@fh-zwickau.de
; changed ... a lot !

; ctswalz version 5 (186 bytes) by doj
; changed line 97

; ctswalz version 4 (189 Bytes) by Jens.Hohmuth@fh-zwickau.de
; changed line 139

;          +----------------------------------------------------+
;          | doj and submissive's tiny midi-music disc.         |
;          |                                                    |
;          | Plays the blue danube waltz using the midi-port    |
;          | (at least it works with MegaEm and GUS)            |
;          |                                                    |
;          |                        a cubic & $eeN release 1997 |
;          |                               http://www.cubic.org |
;          +----------------------------------------------------+
;
; the original idea from doj and submissive appeared on a thursday after
; sub wanted to test his new midi playback routine.
; we tested it with the famous german song "alle meine entchen", but this
; song totally sucked after we heard it four or five times. So doj decided
; to track a new melody. As we are both elite fans we hacked the donaube
; walz into our editor and were totally satisfied.
;
; after some percussion was added we started the tough job and make
; the midi routine some bytes smaller. Everything ended about 18h later when
; we crunched the playroutine + data to a total of 256 bytes and went to bed.
;
; During the next week doj and sub were able to compress the com down to 200 bytes.
; now we finally decided to release this stuff and submissive included a
; uu-encoded version in his email footer. Jens Hohmuth asked submissive
; for the source code and two days later he sent us a 195 bytes version back.
;
; he restructured the source completely and we needed some hours to follow his
; ideas. however doj and sub felt challenged now.
;
; so this is version nr. 3 with a total of 190 bytes and we decide to release
; it at this point and let someone other do version nr. 4!
;
; if you can make this smaller without: 1) removing or shrinking the text
;                                          (you can supply a different, but
;                                           with equal size 24 bytes)
;                                       2) altering the melody and drums
;                                          (you can store it differently)
;                                       3) assume state of registers at start
; you are welcome to mail us your results. your result will be published in
; or sourcerer archive.
;
; email: submissive@cubic.org


.286
.model tiny

g4 equ 55-48           ; removed note-decoding !
a4 equ 57-48           ; now: storing midi-notes for octaves 0..2 and convert
h4 equ 59-48           ; to 4..6 with a simple add 48.

c5 equ 60-48
d5 equ 62-48
e5 equ 64-48
g5 equ 67-48
h5 equ 71-48

c6 equ 72-48
d6 equ 74-48
e6 equ 76-48
g6 equ 79-48           ; = 00011111b

pp  equ 0              ;  c4 is not used in the walz, using it as play-pause.
EOM equ 1              ; c#4 is also available... End Of Music
                       ; warning: experts only beyond this point !

pau1 equ 00100000b     ; bitfield definitions for note-compression
pau2 equ 01000000b     ; you can or a pau to each note!
pau3 equ 01100000b

;rep1 equ 01000000b    ; rep1 is history (only used once).
;rep3 equ 11000000b    ; rep3 was never used.

rep2 equ 10000000b     ; or a rep2 to a note to play it 3 times.

drumsize equ 5

.code
org 100h

start:
                mov  ah,9
                mov  dx,offset msg
                int  21h                    ; print our headerstring

                mov  dx,0330h               ; gus midi megaem -port
                mov  si,offset music_code   ; start of music data

mainloop:

    ; get new note (melody)

                xor  bp,bp                  ; bp= repeat-counter

                lodsb                       ; get a new note
                cmp  al, EOM                ; check for end
                jne  continue
                ret

continue:
                jns  no_rep2                ; check for rep2-Bit
                inc  bp
                inc  bp                     ; "build" repeat-counter

no_rep2:
                push ax                     ; save the note for pause

    ; "convert" to midi-note

                and  al,00011111b
                jz   skip_pp                ; check pp, keep it 0
                add  al,48                  ; fix-up oktave

skip_pp:
                xchg ax,bx                  ; bl= midi-note

play_again:
                mov  cl,3
                push cx                     ; patch program (3= piano)
                push 0c8h                   ; program change, channel 9

    ; wait (cx:dx) times

                mov  ah,86h                 ; wait a little bit
                int  15h

    ; prepare drums

                dec  di                     ; get the current drum
                jns  no_drum_underflow
                mov  di,drumsize

no_drum_underflow:

    ; play drum

                push dx                     ; volume drum
                push [word ptr drumtrk+di]  ; note   drum
                mov  al,99h
                push ax                     ; play channel 10

    ; play melody

                push dx                     ; volume melody
                push bx                     ; note   melody

                dec  ax                     ; replaces dec al :)

                push ax                     ; play channel 9

    ; send data to midi-port

                mov  cl,8                   ; we have to send 8 bytes

play_loop:
                pop  ax                     ; get the midi event
                out  dx,al                  ; and send it
                loop play_loop

    ; repeat "bp" times

                dec  bp                     ; repeat the note
                jns  play_again

    ; check and "play" pause

                xor  bx,bx                  ; clear the note, so we can hear
                                            ; a pause
    ; decode pause value

                pop  ax
                test al,01100000b
                jz   mainloop               ; no pause, get next note

    ; decrement pause value and save on stack

                sub  al,20h
                push ax
                jmp  play_again             ; and play next drum

; don't change the order of the following data, it is heavily crosslinked !
music_code      db pp or rep2

                db g4 or rep2 or pau1
                db h4 or pau1, d5 or pau1, d5 or pau3
                db d6 or pau1, d6 or pau3, h5 or pau1, h5 or pau3

                db g4 or rep2 or pau1
                db h4 or pau1, d5 or pau1, d5 or pau3
                db d6 or pau1, d6 or pau3, c6 or pau1, c6 or pau3

                db a4 or rep2 or pau1
                db c5 or pau1, e5 or pau1, e5 or pau3
                db e6 or pau1, e6 or pau3, c6 or pau1, c6 or pau3

                db a4 or rep2 or pau1
                db c5 or pau1, e5 or pau1, e5 or pau3
                db e6 or pau1, e6 or pau3, h5 or pau1, h5 or pau3

                db g4 or rep2 or pau1
                db h4 or pau1, g5 or pau1, g5 or pau3
                db g6 or pau1, g6 or pau3, d6 or pau1, d6 or pau3

                db g4 or rep2 or pau1
                db h4 or pau1, g5 or pau1, g5 or pau3
                db g6 or pau1, g6 or pau3, e6 or pau1, e6 or pau3

                db a4 or rep2 or pau1
                db c5 or pau1, e5 or pau1, e5 or pau3, pp or pau3
                db c5 or pau1, e5 or pau1, h5 or pau3, pp or pau3, d5 or pau1

                db h4 or pau1, h4 or pau3
                db a4 or pau1, e5 or pau3
                db d5 or pau1, g4 or pau2

;                db g4 or rep1 or pau1
; replace this last "rep1"-note with two (equal-sounding) notes
                db g4
                db g4 or pau1

msg             db EOM, 'Docking Station',10,'doj&sub'
drumtrk         db 36, 42, 38, 42, 38, 59  ; reversed order to save some bytes !

end start
