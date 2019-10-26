;
;                           !!!! ATTENTION !!!!
;
; This sources distributed as freeware but if you'd like to use them in
; your intro/proggie, do NOT forget to remind us/write us greets in your
; stuff.
;

        IDEAL

        Perspective     equ     200     ;350
        NumberOfFireDots        equ     3000
        MaxDots         equ     300
        FireBrightness  equ     3fh     ;03fh   ;05fh
        FirePaletteStart        equ     60h

        Fading          equ     4
        Color           equ     1
        TextOffset      equ     0

        AgO_Sign_Offs   equ     191*320+320-65

model tiny
p386
CODEseg

org 100h

WAVECUBE:

        mov ah,4ah
        mov bx,1000h
        int 21h

        mov ah,48h
        mov bx,65536/16
        int 21h
        mov fs,ax               ;Allocate buffer #1


        mov ah,48h
        mov bx,65536/16
        int 21h
        jnc EnoughMemory
        ret
EnoughMemory:

        mov gs,ax               ;Allocate buffer #2

        xor eax,eax
        mov cx,64000/4
        xor di,di
Clear1:
        mov [fs:di],eax
        add di,4
        loop Clear1

        mov cx,64000/4
        xor di,di
Clear2:
        mov [gs:di],eax
        add di,4
        loop Clear2

;Clear fire dots coordinates
        mov di,offset FireDotsX
        xor eax,eax
        mov cx, NumberOfFireDots*5/2
        rep stosd

        call Randomize  ;Initialize random

;Load font from BiOS
        mov ax,1130h
        mov bh,06h
        int 10h
        push es
        pop ds
        push cs
        pop es
        mov si,bp
        mov cx,4096/2
        mov di,offset Font
        rep movsw

        push cs
        pop ds

        mov ax, 13h
        int 10h         ;Init mode 320x200

        mov di,offset PaletteNorm
        push cs
        pop es

        push cx

        mov cx,10h      ;0fh
Pal:
        xor al,al
        stosb
        mov al,cl
        not al
        dec al
        add al,al
        mov ah,al
        shr al,1
        add al,ah
        add al,8h       ;*5+6h
        and al,3fh
        stosb
        stosb
        loop Pal

        mov cx,0fh
Pal2:
        mov al,cl
        not al
        add al,al
        and al,3fh
        stosb
        mov al,3fh
        stosb
        stosb
        loop Pal2

        mov cx,41h*3h   ;31h
        mov al,3fh
        rep stosb

;Fire palette
        mov cx,10h
Pal4:
        mov al,cl
        neg al
        add al,al
        and al,3fh
        stosb
        xor al,al
        stosb
        stosb
        loop Pal4

        mov cx,10h
Pal5:
        mov al,3fh
        stosb
        mov al,cl
        neg al
        shl al,2
        and al,3fh
        stosb
        xor al,al
        stosb
        loop Pal5

;Prepare palette arrays
;       mov di,offset PaletteNorm
;       mov dx,3c7h
;       xor al,al
;       out dx,al
;       mov dx,3c9h
;       mov cx,128*3
;       rep insb

        mov dx,3c8h
        xor al,al
        out dx,al
        inc dx
        mov cx,256*3
BlackPal:
        out dx,al
        loop BlackPal

        push 0A000h
        pop es
;Display AgO sign before cycle (for fading in)
        mov si,offset AgO_Sign
        mov di,AgO_Sign_Offs
        mov cx,8
Sign_Y2:
        push cx
        mov cx,64
        rep movsb
        add di,320-64
        pop cx
        loop Sign_Y2

        push cs
        pop es

;Fade in!
        mov cx,63
FadeIn:
        push cx
        mov bl,cl
        dec bl  ;bl - minus brightness
        mov si,offset PaletteNorm
        mov dx,3c8h
        xor al,al
        out dx,al
        inc dx
        mov cx,128*3
FadeIn2:
        lodsb
        sub al,bl
        jnc @NotBlack
        xor al,al
@NotBlack:
        out dx,al
        loop FadeIn2
        mov dx,3dah
WaitVR:
        in al,dx
        test al,8
        jne WaitVR
WaitVR2:
        in al,dx
        test al,8
        je WaitVR2
        pop cx
        loop FadeIn

;Clear current palette values
        mov si,offset PaletteNorm
        mov di,offset PaletteCur
        mov cx,128*3
        rep movsb

        mov si,offset PaletteNorm
        mov di,offset PaletteTarg
        mov cx,128
        rep movsb





;-------------- Main loop! ---------------------------------------------------
Main:

;Time passes! :)
        mov dx,[Time]
        inc dx
        cmp dx,255
        jne NotRecycle
        xor dx,dx
NotRecycle:
        mov [Time],dx

        cmp [Time],10
        jne NotShowText
        mov di,offset PaletteTarg
        mov cx,128*3
        mov al,3fh
        rep stosb
NotShowText:

        cmp [Time],180
        je HideText
        cmp [Time],258  ;Exiting...
        jne NotHideText
HideText:
        mov si,offset PaletteNorm
        mov di,offset PaletteTarg
        mov cx,128*3
        mov al,3fh
        rep movsb
NotHideText:

        cmp [Time],3
        jne NotNewText

;-------------- Display text -------------------------------------------------
        mov bx,[PageNumber]
        inc bx
        cmp bx,TotalPages
        jne NotWrap
        xor bx,bx
NotWrap:
        mov [PageNumber],bx
        mov si,bx
        add si,si
        mov ax,[PagesOffs+si]
        mov si,ax

        mov di,TextOffset
        mov bp,di
DisplayText:
        lodsb
        cmp al,1
        je NoMoreText
        or al,al
        jnz NotNewString
        add bp,320*16*2
        mov di,bp
        jmp DisplayText
NotNewString:
        push si
        xor ah,ah
        shl ax,4        ;*16 (font size)
        mov si,ax
        add si,offset Font
        mov cx,16
Font_Ver:
        push cx
        lodsb
        mov cx,8
Font_Hor:
        mov ah,80h
        rol al,1
        test al,1
        jne Font_White
        xor ah,ah
Font_White:
        mov dl,ah
        mov dh,ah
        mov [fs:di],dx
        mov [fs:di+320],dx
        add di,2
        loop Font_Hor
        pop cx
        add di,320*2-8*2
        loop Font_Ver
        add di,-320*16*2+16
        pop si

        jmp DisplayText
NoMoreText:

NotNewText:

        cmp [Time],2
        jne NotNewObject
;Make new object
;Prepare random object parameters:
        call Random
        and ax,6        ;use 2nd & 3rd bit as random
        mov bx,ax
        mov ax,[ObjectsNDots+bx]
        mov [NumberOfDots],ax
        mov ax,[ObjectsNLines+bx]
        mov [NumberOfLines],ax
        mov ax,[ObjectsDots+bx]
        mov [Object_D],ax
        mov ax,[ObjectsLines+bx]
        mov [Object_L],ax

;Select point to fly out from:
        call Random
        test ax,4
        jne MoveFromRight
        mov [ObjectX],200
        mov [ObjectY],0
        jmp NextChoice
MoveFromRight:
        mov [ObjectX],0
        mov [ObjectY],160
NextChoice:
        call Random
        test ax,2
        jne NotOpposite
        not [ObjectX]
        not [ObjectY]
NotOpposite:
        add [ObjectX],160
        add [ObjectY],100

NotNewObject:

;Convert coordinates of vertex to coordinates & speeds of fire dots
;(Explode object)
        mov si,offset Object2D
        xor di,di
        xor bx,bx       ;bx - number of point in the 3d object
        cmp [Time], 0
        je Explode
        cmp [Time],257  ;Exiting...
        jne DontExplode

Explode:
        mov cx,NumberOfFireDots
GenerateFireDots:

        lodsw
        add ax,[ObjectX]
        shl ax,2                ;*4
        mov [FireDotsX+di],ax
        lodsw
        add ax,[ObjectY]
        shl ax,2                ;*4
        mov [FireDotsY+di],ax
        call Random
        shr ax,11
        sub ax,10h              ;X speed
        mov [ds:FireDotsXs+di],ax
        call Random
        shr ax,10
        sub ax,20h              ;Y speed
        mov [FireDotsYs+di],ax
        mov [FireDotsB+di],FireBrightness
        add di,2

        inc bx
        cmp bx,[NumberOfDots]
        jne NotAgain
;Begin converting again from the beginning
        mov si,offset Object2D
        xor bx,bx
NotAgain:
        loop GenerateFireDots

        mov [NumberOfDots],0
        mov [NumberOfLines],0           ;No more object. :~(

DontExplode:

;-------------- Object rotations, transformations & so on. -------------------
        cmp [NumberOfLines],0
        jz No_Object
        mov cx,2
Shadows:
        push cs
        pop ds
        push cs
        pop es

;Rotate object
        add [XShaking],239
        add [YShaking],89
        add [ZShaking],197
        add [Waves],719
        add [XRot],329
        add [ZRot],531
        add [YRot],227

;Move object to the center of the screen
        mov dx,[ObjectX]
        cmp dx,160
        je DontMove1
MoveHor:
        mov ax,dx
        sub ax,160
        sar ax,4
        sub dx,ax
DontMove1:
        mov [ObjectX],dx

        mov dx,[ObjectY]
        cmp dx,100
        je DontMove2
MoveVert:
        mov ax,dx
        sub ax,100
        sar ax,4
        sub dx,ax
        jmp DontMove2
DontMove2:
        mov [ObjectY],dx

;Make waves
        push cx
        call Random
        mov si,[Object_D]
        mov di,offset Object2
        mov cx,[NumberOfDots]
        mov bl,[byte ptr Waves+1]
        call Waves3D

;Rotate object
        mov si,offset Object2
        mov di,offset Object2
        mov cx,[NumberOfDots]
        mov dh,[byte ptr XRot+1]
        mov dl,[byte ptr ZRot+1]
        mov bl,[byte ptr YRot+1]
        call Rotate3D

;Shake object
        mov si,offset Object2
        mov di,offset Object2
        mov cx,[NumberOfDots]
        mov bl,[Byte ptr XShaking+1]
        mov dl,[Byte ptr YShaking+1]
        mov dh,[Byte ptr ZShaking+1]
        call Shake3D

;Convert object to 2D

        mov si,offset Object2
        mov di,offset Object2D
        mov cx,[NumberOfDots]
        mov bx,Perspective
        call Convert3Dto2D




;Display object
        push fs
        pop es
        mov si,[Object_L]
        mov cx,[NumberOfLines]
DisplayObject:
        lodsw                   ;Start dot number
        push si
        mov di,ax
        lea si,[edi*4+Object2D]
        lodsw                   ;X
        mov bx,ax
        add bx,[ObjectX]
        rol ebx,16
        lodsw                   ;Y
        mov bx,ax
        add bx,[ObjectY]
        pop si
        lodsw                   ;End dot number
        push si
        mov di,ax
        lea si,[edi*4+Object2D]
        lodsw                   ;X
        mov dx,ax
        add dx,[ObjectX]
        rol edx,16
        lodsw                   ;Y
        mov dx,ax
        add dx,[ObjectY]

        push cx
        mov al,Color
        call DrawLine
        pop cx

        pop si

        loop DisplayObject

        pop cx
        dec cx
        jnz Shadows             ;End of displaying shadows loop

No_Object:

        push cs
        pop ds
        push cs
        pop es

;Display fire dots
        mov cx,NumberOfFireDots
        xor si,si
DisplayFireDots:
        mov ax,[FireDotsB+si]
        or ax,ax
        jz NextFireDot
        mov di,[FireDotsY+si]
        shr di,2
        cmp di,198
        jnb DotIsOut
        cmp di,1
        jb TooHigh
        lea di,[edi*4+edi]
        shl di,6
        mov ax,[FireDotsX+si]
        shr ax,2
        cmp ax,319
        jnl DotIsOut
        add di,ax
        mov ax,[FireDotsB+si]
        shr ax,1                ; brightness/2
        mov ah,al
        add al,FirePaletteStart
        and [byte ptr fs:di],80h
        or [byte ptr fs:di],al
        sub al,10h
        sub ah,10h
        jc TooDark
        and [byte ptr fs:di-1],80h
        or [byte ptr fs:di-1],al
        and [byte ptr fs:di+1],80h
        or [byte ptr fs:di+1],al
        sub al,10h
        sub ah,10h
        jc TooDark
        and [byte ptr fs:di-320],80h
        or [byte ptr fs:di-320],al
        and [byte ptr fs:di+320],80h
        or [byte ptr fs:di+320],al
TooDark:
TooHigh:

        mov ax,[FireDotsXs+si]
        add [FireDotsX+si],ax
        mov ax,[FireDotsYs+si]
        add [FireDotsY+si],ax
        inc [FireDotsYs+si]
        dec [FireDotsB+si]
        jmp NextFireDot
DotIsOut:
        mov [FireDotsB+si],0
NextFireDot:
        add si,2
        dec cx
        jnz DisplayFireDots

        push fs
        pop es

;Display AgO sign
        mov si,offset AgO_Sign
        mov di,AgO_Sign_Offs
        mov cx,8
Sign_Y:
        push cx
        mov cx,64
        rep movsb
        add di,320-64
        pop cx
        loop Sign_Y

        push cs
        pop es

;Display buffer

        push fs
        pop ds
        push gs
        pop es
        push 0A000h
        pop gs

        xor si,si
        xor di,di
        mov cx,16000
CompareAndCopy:
        repe cmpsd
        jcxz NothingToCopy
        mov eax,[ds:si-4]
        sub di,4
        mov [gs:di],eax
        stosd
        jmp CompareAndCopy
NothingToCopy:

        push cs
        pop ds
        push es
        pop gs
        push fs
        pop es

        xor di,di
        mov cx,64000/4
        mov eax,80808080h
ClearBuf:
        and [es:di],eax
        add di,4
        loop ClearBuf
;       rep stosd       ;Clear buffer

        push cs
        pop ds
        push cs
        pop es


;-------------- Change palette
        mov si,offset PaletteCur
        mov di,offset PaletteTarg
        xor dx,dx                       ;Is palette changed?
        mov cx,128*3
ChangePalette:
        cmpsb
        je DontChangeColor
        jl ColorLower
        dec [byte ptr ds:si-1]
        inc dx                          ;Palette changed
        jmp DontChangeColor
ColorLower:
        inc [byte ptr ds:si-1]
        inc dx                          ;Palette changed
DontChangeColor:
        loop ChangePalette


        cmp dx,0
        je PaletteNotChanged

        mov dx,3dah
Wait1:
        in al,dx
        test al,8
        je Wait1
Wait2:
        in al,dx
        test al,8
        jne Wait2

        mov dx,3c8h
        mov al,80h
        out dx,al
        inc dx
        mov si,offset PaletteCur
        mov cx,128*3
        rep outsb

PaletteNotChanged:

        cmp [Time],255
        ja AlreadyExiting       ;Skip keys checks if key is already pressed...
        in al,60h       ;Test if a key pressed
        test al,80h
        jne NotExit
        mov [Time],256
NotExit:
AlreadyExiting:
        cmp [Time],320  ;Exit!
        je Exit
        jmp Main
Exit:
        mov bl,64
FadeOut:
        mov dx,3c7h
        mov cx,256
l1:
        mov al,cl
        out dx,al
        add dl,2
        in al,dx
        mov ah,al
        in al,dx
        mov bh,al
        in al,dx
        or al,al
        jz a1
        dec al
a1:
        or ah,ah
        jz a2
        dec ah
a2:
        or bh,bh
        jz a3
        dec bh
a3:

        dec dl
        xchg cl,al
        out dx,al
        inc dl
        xchg al,cl
        xchg al,ah
        out dx,al
        mov al,bh
        out dx,al
        mov al,ah
        out dx,al

        sub dl,2
        loop l1
        mov dx,3dah
WaitVR3:
        in al,dx
        test al,8
        jne WaitVR3
WaitVR4:
        in al,dx
        test al,8
        je WaitVR4
        dec bl
        jnz FadeOut

        mov ax,3h
        int 10h
        ret

XRot    dw      0
YRot    dw      0
ZRot    dw      0
Waves   dw      0
XShaking        dw      0
YShaking        dw      0
ZShaking        dw      0

ObjectX dw      0
ObjectY dw      0

ObjectsNumber   equ     4
ObjectsDots     dw      offset Obj1_D, offset Obj2_D, offset Obj3_D, offset Obj4_D
ObjectsLines    dw      offset Obj1_L, offset Obj2_L, offset Obj3_L, offset Obj4_L
ObjectsNDots    dw      120, 195/3, 384/3, 144
ObjectsNLines   dw      120, 191, 384, 143

Time    dw      0

NumberOfDots    dw      0
NumberOfLines   dw      0
Object_D        dw      0
Object_L        dw      0

TotalPages      equ     5
PageNumber      dw      TotalPages-1
PagesOffs       dw      offset Page1, offset Page2, offset Page3, offset Page4
                dw      offset Page5
Page1   db      ' Sitting there in   ',0
        db      ' darkness... you    ',0
        db      ' probably want to   ',0
        db      ' get in another,    ',0
        db      ' better world, eh?  ',0
        db      ' Another reality... ',1
Page2   db      '                    ',0
        db      '  ... Hidden!       ',0
        db      '       !Reality ... ',0
        db      '                    ',0
        db      '  .!. t-REX HQ .!.  ',0
        db      '                    ',1
Page3   db      '€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€',0
        db      '€ +7[O95]-418-4281 €',0
        db      '€ 22.oo-6.3o gmt+3 €',0
        db      '€ PCB 15.22, 14.4k €',0
        db      '€    hdd 1.6 Gb    €',0
        db      '€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€',1

Page4   db      ' ..Controlled..by.. ',0
        db      '                    ',0
        db      '  Noob Saibot &     ',0
        db      '      Agent Orange  ',0
        db      '                    ',0
        db      ' ..Controlled..by.. ',1

Page5   db      '                    ',0
        db      '   Intro coded by   ',0
        db      '    Agent Orange.   ',0
        db      '                    ',0
        db      '   Greets goes to   ',0
        db      ' all Russian scene! ',0
        db      '                    ',1

Label   AgO_Sign Byte
Include "Wc_ago.Inc"

Include "Graph.Asm"
Include "3d.asm"
Include "Random.Inc"


Label   Obj1_L  Word                    ;Original object #1
Include "Cube_L.Inc"

Label   Obj1_D          Word            ;Original object #1
Include "Cube_D.Inc"

Label   Obj2_L  Word                    ;Original object #2
Include "O1_L.Inc"

Label   Obj2_D          Word            ;Original object #2
Include "O1_D.Inc"


Label   Obj3_L  Word                    ;Original object #3
Include "O2_L.Inc"

Label   Obj3_D          Word            ;Original object #3
Include "O2_D.Inc"

Label   Obj4_L  Word                    ;Original object #4
Include "H_L.Inc"

Label   Obj4_D          Word            ;Original object #4
Include "H_D.Inc"


Label   Object2         Word            ;Second buffer of coordinates
        dw MaxDots*3 dup (?)

Label   Object2D        Word            ;2d dots coordinates
        dw MaxDots*2 dup (?)

FireDotsX       dw      NumberOfFireDots dup (?)
FireDotsY       dw      NumberOfFireDots dup (?)
FireDotsXs      dw      NumberOfFireDots dup (?)
FireDotsYs      dw      NumberOfFireDots dup (?)
FireDotsB       dw      NumberOfFireDots dup (?)

Font    db      4096 dup (?)
PaletteNorm     db      128*3 dup (?)   ;normal palette
PaletteCur      dw      128*3 dup (?)   ;current palette
PaletteTarg     dw      128*3 dup (?)   ;target palette

End WAVECUBE

