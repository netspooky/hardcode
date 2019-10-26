;source code lost, than grabbed by hiew :-)
;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ IMPORTANT NOTE: ONLY FOR SOUNDBLASTER 1.0 ๖ 3.0 at PORT 220h WITH DMA 1! บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
;if you have different variables of your SoundBlaster, you have to
;set them here in the source program and compile it again (in tasm).
;
.model TINY
.486
.code
org 100h

BASEPORT        EQU 220h
DMA             EQU 1

DSP_RESET       EQU 06h
DSP_READ_DATA   EQU 0Ah
DSP_WRITE_DATA  EQU 0Ch
DSP_DATA_AVAIL  EQU 0Eh

IF DMA EQ 0
  DMA_PAGE_REGISTER     EQU     87h
ELSEIF DMA EQ 1
  DMA_PAGE_REGISTER     EQU     83h
ELSEIF DMA EQ 2
  DMA_PAGE_REGISTER     EQU     81h
ELSEIF DMA EQ 3
  DMA_PAGE_REGISTER     EQU     82h
ENDIF

start:

 push   0040h
 pop    fs
 inc    al
 mov    dx,BASEPORT+DSP_RESET
 out    dx,al
 mov    cl,al
 call   @WaitTicks
 xor    al,al
 out    dx,al
 mov    cl,02h
 call   @WaitTicks
 mov    dx,BASEPORT+DSP_DATA_AVAIL
 in     al,dx
 test   al,80h
 je     @ExitLine
 mov    dx,BASEPORT+DSP_READ_DATA
 in     al,dx
 cmp    al,0AAh
 jne    @ExitLine
 mov    al,01h
 mov    ah,0D1h         ;speakers on
 call   @sbWriteDSP
 mov    di,00300h
 mov    ch,0Ch
 pusha
 mov    eax,80908070h
 repe   stosd
 popa
 mov    si,offset dataz
@mainloop:
 mov    cx,dx
 lodsb
 mov    ah,al
 shr    ah,06h
 inc    al
 jz     @ExitLine
 and    al,3Fh
 shl    al,1
 call   @sbPlay
 push   cx
 mov    cl,ah
 mov    ch,05h
 shl    ch,cl
 shr    cx,08h
 call   @WaitTicks
 pop    cx
 in     al,60h
 dec    al
 jne    @mainloop
@ExitLine:
 retn

@WaitTicks:
 mov    bx,006Ch
@WaitTicks1:
 mov    ah,fs:[bx]
@WaitTicks2:
 cmp    ah,fs:[bx]
 je     @WaitTicks2
 loop   @WaitTicks1
 retn

@sbWriteDSP:
 mov    dx,BASEPORT+DSP_WRITE_DATA
@sbWriteDSP1:
 in     al,dx
 test   al,80h
 jnz    @sbWriteDSP1
 mov    al,ah
 out    dx,al
 retn

@sbPlay:
 pusha
 push   ax
 push   cx
 mov    al,05h  ;port[0Ah]:=5
 out    0Ah,al
 mov    al,00h  ;port[0Ch]:=0
 out    0Ch,al
 mov    al,49h  ;port[0Bh]:=49h
 out    0Bh,al
 mov    ax,es
 shl    ax,04h
 add    ax,di
 out    DMA*2,al  ;send offset to port[DMA*2]
 mov    al,ah
 out    DMA*2,al
 mov    ax,di
 shr    ax,04h
 mov    si,es
 add    ax,si
 shr    ax,0Ch  ;send to page register a page ie. (offset >> 4 + seg) >> 12
 out    DMA_PAGE_REGISTER,al
 pop    ax
 mov    si,ax
 out    DMA*2+1,al  ;send size to port[DMA*2+1]
 mov    al,ah
 out    DMA*2+1,al
 mov    al,01h
 out    0Ah,al  ;port[0Ah]:=1
 mov    ah,40h
 call   @sbWriteDSP
 pop    ax
 mov    ah,al
 call   @sbWriteDSP     ;writes time constant to DSP
 mov    ah,14h
 call   @sbWriteDSP
 mov    ax,si
 mov    ah,al
 call   @sbWriteDSP     ;writes size to DSP
 mov    ax,si
 call   @sbWriteDSP
 popa
 retn

dataz:
 db 00000011b ;000h koc-
 db 00001100b ;00Ch ka
 db 00011000b ;018h le-
 db 00011111b ;01Fh ze
 db 01101011b ;06Bh dก-
 db 01101011b ;06Bh rou,
 db 01110011b ;073h pes
 db 01110011b ;073h ok-
 db 10101011b ;0ABh nem,
 db 01110011b ;073h pes
 db 01110011b ;073h ok-
 db 10101011b ;0ABh nem,
 db 00011111b ;01Fh ne-
 db 00011111b ;01Fh bu-
 db 00011111b ;01Fh de-
 db 00011111b ;01Fh -li
 db 01011000b ;058h pr-
 db 01011000b ;058h set,
 db 01001100b ;04Ch nez-
 db 01001100b ;04Ch mok-
 db 10101011b ;0ABh nem,
 db 00011111b ;01Fh ne-
 db 00011111b ;01Fh bu-
 db 00011111b ;01Fh de-
 db 00011111b ;01Fh -li
 db 01011000b ;058h pr-
 db 01011000b ;058h set,
 db 01001100b ;04Ch nez-
 db 01001100b ;04Ch mok-
 db 00000011b ;080h nem.
 db 11111111b ;0FFh

END start
