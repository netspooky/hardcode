comment #
/*****************************************************************************
                                  ATTENTION!
                           this source is VOTEWARE,
              you may only use it to the conditions listed below:

  -You may modify it, or use parts of it in your own source as long as
    this header stays on top of all files containing this source.
  -You must give proper credit to the author, Niklas Beisert / pascal.
  -You may not use it in commercial productions without the written
    permission of the author.
  -AND MOST IMPORTANT: you have to buy an Assembly '94 CD-ROM
    by Sound Solutions (if you don't have it already) and vote for VEX-InTrO
    in the PC-64k-Intro-Compo! (if you have already sent your voting card,
    buy another one and fill it out CORRECTLY!!!)
*****************************************************************************/
#



;// disables the keyboard, bug: leaves one pressed key in the buffer

.model large, c
.386
locals

.code

public InitKey
public CloseKey

oldirq db 0

InitKey proc
  in al,21h
  mov cs:oldirq,al
  or al,2
  out 21h,al
  ret
InitKey endp

CloseKey proc
@@2:
  in al,64h
  test al,1
  jz @@1
  in al,60h
  jmp @@2
@@1:
  mov al,cs:oldirq
  out 21h,al

@@flush:
    mov ah,11h
    int 16h
    jz @@ok
    mov ah,10h
    int 16h
  jmp @@flush
@@ok:

  ret
CloseKey endp

end
