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



;// xmode routines...

.model large, c
.386
locals

.code

public vgaInit
public vgaClose
public vgaViewPage
public vgaWaitRetrace
public vgaFillScreen

vgaInit proc
  mov dx,3c4h
  mov al,4
  out dx,al
  inc dx
  in al,dx
  and al,0f7h
  or al,4
  out dx,al
  mov dx,3d4h
  mov al,14h
  out dx,al
  inc dx
  in al,dx
  and al,0bfh
  out dx,al
  dec dx
  mov al,17h
  out dx,al
  inc dx
  in al,dx
  or al,40h
  out dx,al

  ret
endp

vgaClose proc
  mov dx,3c4h
  mov ax,0F02h
  out dx,ax
  mov al,4
  out dx,al
  inc dx
  in al,dx
  or al,08h
  and al,not 04h
  out dx,al
  mov dx,3d4h
  mov al,14h
  out dx,al
  inc dx
  in al,dx
  or al,40h
  out dx,al
  dec dx
  mov al,17h
  out dx,al
  inc dx
  in al,dx
  and al,not 40h
  out dx,al
  ret
endp

vgaViewPage proc p:word
  mov al,0ch
  mov ah,byte ptr p
  shl ah,6
  mov dx,3d4h
  out dx,ax
  ret
endp

vgaWaitRetrace proc
  mov dx,3dah
@@l1:
  in al,dx
  and al,8
  jnz @@l1
@@l2:
  in al,dx
  and al,8
  jz @@l2
  ret
endp

vgaFillScreen proc uses di, p:word, col:word
  mov dx,3c4h
  mov ax,0f02h
  out dx,ax

  mov ax,0a000h
  mov es,ax
  mov al,byte ptr col
  mov ah,al
  mov bx,ax
  shl eax,16
  mov ax,bx
  mov di,p
  shl di,14
  mov cx,1000h
  rep stosd

  ret
endp

end
