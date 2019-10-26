;
; TPP's official intro (er...) #1  -  (C)1996 TPP Devlopments
;
;  NOTE: This sourcecode is now public domain. Please try to learn something
;        from it and don't just go ripping routines...
;

.286
include wvr.inc
AproxEXESize       equ  <50000>
HorizontalBarSize  equ  <30>
VerticalBarSize    equ  <73>
BarPlotSpeed       equ  <2>
BigCharSizeX       equ  <23>
BigCharSizeY       equ  <23>
SmallCharSizeX     equ  <6>
SmallCharSizeY     equ  <7>
PlotTextOffset     equ  <(320*70)+88>
CursorColor        equ  <31>
TextDelay          equ  <9>
TextDeleteCycles   equ  <(((SmallCharSizeY+2)*11)*320)+(320*70)+88>
BallNumber         equ  <2>
BallColor          equ  <155>
BallSizeXY         equ  <20>
SinesNumber        equ  <30>
                           
segment PCode
assume cs:PCode, ds:PData

          include pfiller.inc
          cli
          call Startup              ; Mode 13h, mem allocs, etc, etc.
          cmp [OldVideoMode],0
          je Exit

MainLoop: mov ah,1
          int 16h
          jnz MainExit

          WVR
;          RasterTime 33
          call PlotBalls
          call PlotTexts
          call PlotTitle
;          RasterTime 0

          jmp MainLoop

MainExit: xor ah,ah
          int 16h
          xor ax,ax                  
          mov al,[OldVideoMode]
          int 10h                    
Exit:     sti
          mov ah,4ch
          int 21h

endp

proc PlotBalls near
          mov bp,offset BallData      ; Erase old balls
          mov dx,BallNumber
BErsLoop: dec dx
          mov si,bp
          mov di,[si]
          add di,[si+2]
          xor ax,ax
          mov bx,BallSizeXY
BUnPlotY: dec bx
          mov cx,BallSizeXY
ErsLoop:  cmp byte ptr es:[di],BallColor
          jne NoErase
          stosb
          jmp CErase
NoErase:  inc di
CErase:   loop ErsLoop
          add di,320-BallSizeXY
          or bx,bx
          jnz BUnPlotY
          mov di,[si]                 ; DI = X pos (VGA concurrent)
          mov cx,[si+2]               ; CX = Y pos (VGA concurrent)
          mov al,[si+4]               ; AL = X & Y increment
          cmp di,VerticalBarSize+1    ; Check if exceed is done
          jne NoByLft
          xor al,00000010b
          jmp NoByRgt
NoByLft:  cmp di,320-BallSizeXY
          jne NoByRgt
          xor al,00000010b
NoByRgt:  cmp cx,320*HorizontalBarSize
          jne NoByUp
          xor al,00000001b
          jmp NoByDown
NoByUp:   cmp cx,320*(200-BallSizeXY)
          jne NoByDown
          xor al,00000001b
NoByDown: test al,00000010b           ; Add with sign
          jne Sub1
          add di,4
Sub1:     sub di,2
          test al,00000001b
          jne Sub2
          add cx,640*2
Sub2:     sub cx,640
          mov [si],di
          mov [si+2],cx
          mov [si+4],al
          add di,cx
          mov si,offset BallGFX+3     ; Plot balls
          mov bl,BallSizeXY
BallPlot: dec bl
          mov cx,BallSizeXY
BPlLoop:  lodsb
          mov ah,es:[di]
          or ah,ah
          jnz PSkp
          or al,al
          jz PSkp
          mov es:[di],al
PSkp:     inc di
          loop BPlLoop
          add di,320-BallSizeXY
          or bl,bl
          jnz BallPlot
          add bp,5
          or dx,dx
          jz BallEnd
          jmp BErsLoop
BallEnd:  ret
endp

proc PlotTexts near
          cmp [TextCycle],0
          jne CText
          cmp [TextDelayCycle],0
          je NoDelay1                  ; Delay needed?
          dec TextDelayCycle
          ret
NoDelay1: cmp [TextErase],(320*69)+88  ; Erasing needed?
          je NoDelay3
          xor ax,ax
          mov di,[TextErase]
          mov cx,((SmallCharSizeX+1)*32)/2
          rep stosw
          mov di,TextDeleteCycles
          sub di,[TextErase]
          add di,(320*70)+88
          mov cx,((SmallCharSizeX+1)*32)/2
          rep stosw
          sub TextErase,320*2
          ret
NoDelay3: cmp byte ptr [ExtraDelay],0
          je NoDelay2                  ; Delay needed?
          dec byte ptr ExtraDelay
          ret
CText:    jmp ContText
NoDelay2: mov byte ptr ExtraDelay,70*3
          mov TextCycle,32*10
          mov TextErase,TextDeleteCycles
          mov TextPlotOffset,PlotTextOffset
          mov TextDelayCycle,70*TextDelay
          mov si,[MessageOffset]
          cmp byte ptr [si],0
          jne NoEnded
          mov si,offset MainMsg
          mov MessageOffset,si
          call LoadTitle
NoEnded:  cmp byte ptr [si],1
          jne ContText
          inc MessageOffset
          call LoadTitle
ContText: mov si,[MessageOffset]
          mov bh,byte ptr [si]
          cmp byte ptr [XVar],0        ; Check if cursor needed
          jne OpCursor
          mov byte ptr XVar,1
          mov al,CursorColor
          mov ah,al
          mov di,[TextPlotOffset]
          mov cx,SmallCharSizeY
CrsrPlt:  stosw                        ; Plot the 6 pixels wide cursor
          stosw
          stosw
          add di,320-SmallCharSizeX
          loop CrsrPlt
          ret
OpCursor: dec TextCycle                ; Wipe cursor and draw char
          mov si,offset SmallFontTable
SScan:    cmp [si],bh                  ; Scan the table
          je SFinded
          add si,3
          jmp SScan
SFinded:  inc si
          mov ax,[si]
          mov si,ax
          mov di,TextPlotOffset
          mov cx,SmallCharSizeY
ChrPlot:  movsw
          movsw
          movsw
          add di,320-SmallCharSizeX
          loop ChrPlot
          dec byte ptr TextLineCounter
          mov bp,[TextPlotOffset]
          add bp,SmallCharSizeX+1
          cmp byte ptr [TextLineCounter],0
          jne StllLine
          sub bp,((SmallCharSizeX+1)*32)-((SmallCharSizeY+2)*320)
          mov byte ptr TextLineCounter,32
StllLine: mov TextPlotOffset,bp
          inc MessageOffset
          mov byte ptr XVar,0
          ret
endp

proc PlotTitle near
; Plots the title with sine wobbling (wipes the old image at the time)
          mov bx,[SineOffset]
          mov ax,85+(320*((HorizontalBarSize-BigCharSizeY)/2))
          mov bp,offset TitleBuffer
          mov dl,BigCharSizeY
PltLp:    dec dl
          mov si,bx
          mov di,[si]
          add di,ax
          mov si,bp
          add ax,320
          mov cx,((BigCharSizeX+1)*9+2)/2
          rep movsw
          mov bp,si
          add bx,2
ContLoop: or dl,dl
          jnz PltLp
          sub bx,(BigCharSizeY*2)-2
          cmp bx,offset SineTable + 62
          jne NoExceed
          mov bx,offset SineTable
NoExceed: mov SineOffset,bx
          ret
endp

proc LoadTitle near
; Loads a title in the main title buffer, starting at the message offset
          mov ax,ds
          mov es,ax
          mov bp,offset TitleBuffer+1
          mov dh,9                    ; Number of chars to add
LoadLoop: dec dh
          mov si,[MessageOffset]
          mov bh,byte ptr [si]
          inc MessageOffset
          mov si,offset BigFontTable
BScan:    cmp [si],bh                 ; Scan the table
          je BFinded
          add si,3
          jmp BScan
BFinded:  inc si
          mov ax,[si]
          mov si,ax
          mov di,bp
          mov dl,BigCharSizeY
PlotLoop: dec dl
          mov cx,(BigCharSizeX-1)/2
          rep movsw
          movsb
          add di,(((BigCharSizeX+1)*9)+2)-BigCharSizeX
          or dl,dl
          jnz PlotLoop
          add bp,BigCharSizeX+1
          cmp dh,0
          jne LoadLoop
          mov ax,0a000h
          mov es,ax
          ret
endp


proc ExplodeWithLogo near
           mov cx,35                 ; Delay 35/70 second(s)
Delay1:    WVR
           loop Delay1
           mov dx,3c8h               ; White out the screen
           xor al,al
           out dx,al
           mov dx,3c9h
           mov al,63
           mov cx,256 * 3
White:     out dx,al
           loop White
           mov ax,0a000h
           mov es,ax
           mov si,offset GFX1         ; Plot main logo
           mov di,(320*5)+3
           call PlotGFX
           mov si,offset GFX2
           mov di,(320*60)+3
           call PlotGFX
           mov si,offset GFX2
           mov di,(320*115)+3
           call PlotGFX
           mov si,offset GFX3
           mov di,(320*175)+8
           call PlotGFX                ; Now fade in palette
           mov ax,ds
           mov es,ax
           mov di,offset PaletteBuffer
           mov al,63
           mov cx,256 * 3
           rep stosb
           mov byte ptr XVar,64
FadeLoop:  dec byte ptr XVar
           mov ax,ds
           mov es,ax
           mov si,offset PaletteBuffer
           mov di,offset Palette
           mov cx,256 * 3
CmpLoop:   cmpsb
           je Skip
           dec si
           dec byte ptr [si]
           inc si
Skip:      loop CmpLoop
           mov ax,0a000h
           mov es,ax
           WVR
           mov dx,3c8h
           xor al,al
           out dx,al
           mov dx,3c9h
           mov si,offset PaletteBuffer
           mov cx,256 * 3
           rep outsb
           cmp byte ptr [XVar],0
           jne FadeLoop
           mov cx,35                   ; Delay 35/70 second(s)
Delay2:    WVR
           loop Delay2
           mov ax,ds                   ; Fade with title and balls...
           mov es,ax
           mov di,offset PaletteBuffer
           mov al,63
           mov cx,256 * 3
           rep stosb
           mov byte ptr XVar,64
FadeLoop2: dec byte ptr XVar
           mov ax,ds
           mov es,ax
           mov si,offset PaletteBuffer
           mov di,offset Palette
           mov cx,256 * 3
CmpLoop2:  cmpsb
           je Skip2
           dec si
           dec byte ptr [si]
           inc si
Skip2:     loop CmpLoop2
           mov ax,0a000h
           mov es,ax
           WVR
           call PlotBalls
           call PlotTitle
           mov dx,3c8h
           xor al,al
           out dx,al
           mov dx,3c9h
           mov si,offset PaletteBuffer
           mov cx,256 * 3
           rep outsb
           cmp byte ptr [XVar],0
           jne FadeLoop2
           ret
endp

proc PlotGFX near
           mov ax,[si]
           add si,2
           mov bl,byte ptr [si]
           inc si
           mov dx,320
           sub dx,ax
PltLoop:   dec bl
           mov cx,ax
           rep movsb
           add di,dx
           or bl,bl
           jnz PltLoop
           ret
endp

proc PlotBars near
           mov ax,0a000h
           mov es,ax
           mov bp,320
BrLoop:    mov bx,BarPlotSpeed
           WVR
BrLoop2:   dec bx
           dec bp
           mov al,16                 ; Plot horizontal bar
           mov di,bp
           mov cx,HorizontalBarSize
HLoop:     stosb
           add di,319
           loop HLoop
           cmp bp,199
           ja NoVert                  ; Check and plot horizontal bar
           mov di,bp
           shl di,8
           mov ax,di
           shr di,2
           add di,ax
           mov cx,VerticalBarSize/2
           mov ah,16
           mov al,16
           rep stosw
NoVert:    cmp bx,0
           jne BrLoop2
           cmp bp,0
           jne BrLoop
           ret
endp

proc Startup near
           mov ax,PData
           mov ds,ax
           mov ah,4ah                 ; Reduce program memory size
           mov bx,AproxEXESize/16
           int 21h
           mov ah,12h                 ; Search for videosystem
           xor al,al
           mov bl,36h
           int 10h
           cmp al,12h
           jnz NoVGA
           je VgaOk
NoVGA:     mov ah,9h
           mov dx,offset NoVGAMsg
           int 21h
           mov OldVideoMode,0
           ret
VgaOK:     mov ah,0fh
           int 10h
           mov OldVideoMode,al
           mov ax,0013h
           int 10h
           call LoadPalette           ; Initial effects
           call PlotBars
           call LoadTitle
           call ExplodeWithLogo
           ret
endp

proc LoadPalette near
; Loads the 256 palette (DS:[Palette])
           mov ax,ds
           mov es,ax
           mov si,offset Palette + 3  ; Skip first color
           mov dx,3c8h
           mov al,1
           out dx,al
           mov dx,3c9h
           mov cx,255 * 3
           rep outsb
           mov dx,3dah                ; Set background as 254 (black)
           in al,dx
           mov dx,3c0h
           mov al,11h
           out dx,al
           mov al,254
           out dx,al
           mov dx,3dah
           in al,dx
           mov dx,3c0h
           mov al,20h
           out dx,al
           mov cx,64                  ; Fade in first one
FadeLp:    mov si,offset PaletteBuffer
           mov di,offset Palette
           mov dx,3
DecLp:     dec dx
           cmpsb
           je Skp
           dec si
           inc byte ptr [si]
           inc si
Skp:       cmp dx,0
           jne DecLp
           WVR
           mov dx,3c8h
           xor al,al
           out dx,al
           mov dx,3c9h
           mov si,offset PaletteBuffer
           outsb
           outsb
           outsb
           loop FadeLp
           ret
endp
ends PCode

segment PData
PaletteBuffer   db (256*3) dup (0)
OldVideoMode    db 0
XVar            db 0
TextLineCounter db 32
TextDelayCycle  dw 70*TextDelay
ExtraDelay      db 70*3
MessageOffset   dw offset MainMsg
SineOffset      dw offset SineTable
TextCycle       dw 32*10
TextErase       dw TextDeleteCycles
TextPlotOffset  dw PlotTextOffset
TitleBuffer     db (((BigCharSizeX+1)*9)+2)*BigCharSizeY dup (16)
TitleWipeTable  dw BigCharSizeY dup (75+(320*((HorizontalBarSize-BigCharSizeY)/2)))
include msg.inc
include palette.inc
include 1gfx.inc
include 2gfx.inc
include 3gfx.inc
include font1.inc
include fonttbl1.inc
include font2.inc
include fonttbl2.inc
include sintbl.inc
include balldata.inc
include ball.inc
ends PData

segment PStack para Stack
 db 512 dup (?)
ends
end
