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
; So this is version nr. 3 with a total of 190 bytes and we decide to release
; it at this point and let someone other do version nr. 4!
;
; News:  Jens stroke back.... Again he was able to beat us (how can he dare..).
;        He replaced a DEC AL with a DEC AX (which is one byte smaller) and
;        thus saved one additional byte.. Now he's down to 189 bytes.
;
;                       JENS WE HATE YOU FOR DOING THIS!
;
; Version 3 is history... this is Version 4!
;
; if you can make this smaller without: 1) removing or shrinking the text
;                                          (you can supply a different, but
;                                           with equal size 24 bytes)
;                                       2) altering the melody and drums
;                                          (you can store it differently)
;                                       3) assume state of registers at start
;
; you are welcome to mail us your results. your result will be published in
; or sourcerer archive.
;
; email: submissive@cubic.org


.286
.model tiny

h4   equ 0             ; note definitions
g4   equ 1
a4   equ 2
c5   equ 3
d5   equ 4
e5   equ 5
g5   equ 6
h5   equ 7
c6   equ 8
d6   equ 9
e6   equ 10
g6   equ 11
pp   equ 12
EOM  equ 3Fh           ; End Of Music
                       ; warning: experts only beyond this point !

pau1 equ 00010000b     ; bitfield definitions for note-compression
pau2 equ 00100000b     ; you can or a rep and a pau to each note!
pau3 equ 00110000b
rep1 equ 01000000b
rep2 equ 10000000b
rep3 equ 11000000b

drumsize equ 5

.code
org 100h

start:
                mov ah,9
                mov dx,offset msg
                int 21h                     ; print our headerstring

                mov dx,0330h                ; gus midi megaem -port
                mov si,offset music_code    ; start of music data

mainloop:

    ; get new note (packed melody)

                lodsb                       ; get a new packed note
                cmp al, EOM                 ; check for end
                jne  continue
                ret
continue:
                push ax                     ; save the note for pause
                mov  ah, al                 ; save repeat value
                shr  ah, 6                  ; shift it to the correct position


    ; decode it (first: note-value)

                mov bx,offset notetable
                and al,0fh                  ; get only the note information
                xlatb                       ; get midi-note using xlatb
                xchg ax,bx                  ; bx= midi-note

play_again:

                mov cl,3
                push cx                     ; patch program (3= piano)
                push 0c8h                   ; program change, channel 9

    ; wait (cx:dx) times

                mov ah,86h                  ; wait a little bit
                int 15h

    ; prepare drums

                dec di                      ; get the current drum
                jns no_drum_underflow
                mov di,drumsize

no_drum_underflow:

    ; play drum

                push dx                     ; volume drum
                push [word ptr drumtrk+di]  ; note   drum
                mov al,99h
                push ax                     ; play channel 10

    ; play melody

                push dx                     ; volume melody
                push bx                     ; note   melody
                dec  ax                     ; Jens lates byte trick...
                push ax                     ; play channel 9

    ; send data to midi-port

                mov cl,8                    ; we have to send 8 bytes

play_loop:
                pop ax                      ; get the midi event
                out dx,al                   ; and send it
                loop play_loop

    ; repeat "bp" times

                dec bh                      ; repeat the note
                jns play_again

    ; check and "play" pause

                xor bl,bl                   ; clear the note, so we can hear
                                            ; a pause
    ; decode pause value

                pop ax
                test al,00110000b
                jz mainloop                 ; no pause, get next note

    ; decrement pause value and save on stack

                sub al,10h
                push ax
                jmp play_again              ; and play next drum (if any)

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
                db d5 or pau1, g4 or pau2, g4 or rep1 or pau1

msg             db '?Docking Station',10,'doj&sub'
drumtrk         db 36, 42, 38, 42, 38  ; reversed order to save some bytes !
notetable       db 59, 55, 57, 60, 62, 64, 67, 71, 72, 74, 76, 79

end start

