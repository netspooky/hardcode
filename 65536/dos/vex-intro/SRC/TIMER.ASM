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



; // a stupid timer, makes the clock go wrong.... ;)

.model large,c
.386
locals

.code

oldtimer dd 0
timerroutine dd 0
routinebusy db 0
timerrate dw 0
ticker dd 0
intcount dw 0
routcount dw 0

public tuInstall
public tuClose
public tuDisable
public tuEnable
public tuGetTimer
public tuResetTimer
public tuUpdate

timerhandler proc
  push eax

  movzx eax,timerrate
  add ticker,eax

  add intcount,ax
  jnc @@noint
  pushf
  call oldtimer
@@noint:

  mov al,20h
  out 20h,al

  add routcount,65535
  jnc @@norout
  cmp routinebusy,0
  jne @@norout
  inc routinebusy
  pushf
  call timerroutine
  dec routinebusy
@@norout:

  pop eax
  iret
endp

tuInstall proc uses ds
  mov intcount,1
  mov routinebusy,1
  mov ticker,0
  mov timerrate,65535
  mov ax,3508h
  int 21h
  mov word ptr cs:oldtimer,bx
  mov word ptr cs:oldtimer+2,es
  mov cs:ticker,0
  mov al,34h
  out 43h,al
  mov al,0ffh
  out 40h,al
  out 40h,al
  mov ax,2508h
  push cs
  pop ds
  mov dx,offset timerhandler
  int 21h
  ret
endp

tuClose proc uses ds
  mov al,34h
  out 43h,al
  mov al,00h
  out 40h,al
  out 40h,al
  mov ax,2508h
  mov dx,word ptr cs:oldtimer
  mov ds,word ptr cs:oldtimer+2
  int 21h
  ret
endp

tuDisable proc
  inc routinebusy
  ret
endp

tuEnable proc
  dec routinebusy
  ret
endp

tuUpdate proc
  cmp routinebusy,0
  jnz @@end
    inc cs:routinebusy
    pushf
    call cs:timerroutine
    dec cs:routinebusy
    mov cs:routcount,0
@@end:
  ret
endp

tuGetTimer proc
  mov al,00h
  out 43h,al
  in al,40h
  xchg al,ah
  in al,40h
  xchg al,ah
  movzx eax,ax
  neg eax
  add eax,ticker
  mov edx,3600
  mul edx
  shr eax,16
  ret
endp

tuResetTimer proc
  mov al,00h
  out 43h,al
  in al,40h
  xchg al,ah
  in al,40h
  xchg al,ah
  movzx eax,ax
  mov ticker,eax
  ret
endp

end
