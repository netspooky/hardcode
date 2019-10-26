adlibthere      db      0                     ;byte to store adlib flag
include "macros.inc"              ;include my macro's
include "adlibtst.inc"            ;and the adlibdetect proc


Equalizers      db      9 dup (0)             ;where to put the equ data!
                                              ;not really needed but I use it
                                              ;because I wasnt sure what I was
                                              ;doing with hsc at first...


PROC Startmusic                               ;called to start FM music

     call      Detectadlib                    ;detect CF=Set on not there...
     jc        @@notmusic                     ;carry flag set, no music
@@noprob:                                     ;
     mov       [cs:adlibthere],1              ;store a flag about music
     mov       bx,seg Music                   ;adlibthere=1 = music ok...
     mov       si,offset Music
     mov       ax,si
     and       si,0fh
     shr       ax,4
     add       bx,ax
     mov       es,bx                          ;point es to segment of music-

     mov       ah,0                           ;zero ah (Use XOR next time! )
     mov       bx,0                           ;and bx
     call      far hscplayer                      ;call music routine
@@notmusic:                                   ;jmp here if no music allowed
     ret                                      ;return from proc
ENDP                                          ;end of proc

; -----------

PROC Dobars                                   ;equalizer bars for hscplayer
     pusha                                    ;save regs
     mov        bp,0

@@equloop:

     in         al,60h                        ;check keyboard
     cmp        al,01                         ;is esc pressed?
     jne        @@equloop                     ;no, so loop...
     popa                                     ;restore regs
     ret                                      ;end it all.. :)
ENDP                                          ;end of proc..


PROC FadeOutMusic                              ;de initialise FM and free timers
     cmp        [adlibthere],1                ;if no adlib there dont bother
     jne        @@dontbother                  ;otherwise
     mov        ah,3                          ;use function 2
     call       hscplayer                     ;of FM routines to free timers
@@dontbother:                                 ;etc....
     ret                                      ;end

ENDP

PROC Deinitmusic                              ;de initialise FM and free timers
     cmp        [adlibthere],1                ;if no adlib there dont bother
     jne        @@dontbother                  ;otherwise
     mov        ah,2                          ;use function 2
     call       hscplayer                     ;of FM routines to free timers
@@dontbother:                                 ;etc....
     ret                                      ;end

ENDP

IDEAL    ; dont we all wish life was more ideal?? :)

