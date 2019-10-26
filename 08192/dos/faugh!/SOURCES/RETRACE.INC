MASM
COMMENT *
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Retrace.inc     Vertical and Horizontal retrace code (to sync to VGA)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  Revision 0.1a   Copyright 1993 Phil Carlisle

  Description -- Offers the usual Vertical Sync and Horixontal sync procs

  History

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*

WaitVsyncStart proc                  ; wait for vertical rt sync. start

        push    ax
        push    dx

        mov     dx, 03dah
@@11:
        in      al,dx
        test    al,08h
        jnz     @@11
@@22:
        in      al,dx
        test    al,08h
        jz      @@22

        pop     dx
        pop     ax
        ret
ENDP

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

WaitVsyncEnd    proc                    ; wait for vert. rt sync end

        pusha

        mov     dx,03dah                ; ie display enable period
@@33:
        in      al,dx
        test    al,08h
        jz     @@33
@@44:
        in      al,dx
        test    al,08h
        jnz      @@44

        popa
        ret
ENDP

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

IDEAL
