;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;          Adlib Detection routine, returns CF set on error
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; A joint venture by Phil Carlisle pc@espr.demon.co.uk and Lee Hamill...
; i.e. I posted some code, and he posted the correct code :))
; idea by someone else entirely....
; its tested and seems to work...

PROC Detectadlib                              ;proc to detect adlib
                stc                           ;set the carry flag (default)
                pusha                         ;preserve regs
                mov     dx,0388h              ;use the code posted by lee
                in      al,dx                 ;someone else suggested it...
                cmp     al,0                  ;seems to work
                je      @@there               ;adlib present, clear carry flag
                cmp     al,6                  ;adlib not present if al<>0 OR 6
                jne     @@carryon             ;and again...
                                              ;
@@there:        clc                           ;clear cf, adlib is there
@@carryon:
                popa                          ;restore our regs
                ret                           ;return
ENDP                                          ;end of detect adlib proc


