;       TextMode BBS-Addy for Parental Advisory -Sysop:KRASh
;       ASM-Version by FuSi0N - original concept by KRASh
;       (c) 1996 by Daniel Vollmer. Credit me if you use something!.
;----------------------------------------------------------------------------)
.model tiny
code segment
org 100h
jumps
assume  cs:code, ds:code, es:code, ss:code
.286
NumStar equ      2048
Groesse equ      4096
Tiefe   equ      1024
XShift  equ      3
YShift  equ      3
;----------------------------------------------------------------------------)
xcalc macro
   mov  bx,cx
   add  bx,word ptr a
   and  bx,255
   mov  ax,[offset sint+bx]
   mov  bx,dx
   add  bx,word ptr b
   and  bx,255
   add  ax,[offset cost+bx]
   mov  bx,cx
   add  bx,word ptr c
   add  bx,dx
   and  bx,255
   add  ax,[offset cost+bx]
   mov  bx,cx
   add  bx,word ptr d
   add  bx,dx
   and  bx,255
   add  ax,[offset cost+bx]
   mov  bx,cx
   add  bx,word ptr e
   add  bx,dx
   and  bx,255
   add  ax,[offset sint+bx]
endm

inittext macro
   mov ax,3h
   int 10h
endm
;----------------------------------------------------------------------------)
start:
      mov     ax,0100h
      mov     cx,0100h
      int     10h               ; No Cursor
;----------------------------------------------------------------------------)
      push      0b800h
      pop       es
      mov       cx,255
@moveloop:
      mov       si,80*50
      xor       di,di
@innermove:
      cmp       byte ptr es:[di],32
      jz        @weitah
      inc       byte ptr es:[di]
@weitah:
      inc di
      inc di                    ; is 1 byte shorter than add di,2
      dec       si
      jnz       @innermove
      call      retrace
      loop      @moveloop       ; fancy intro ... ;)
;----------------------------------------------------------------------------)
      inittext
      mov    ax,1112h
      xor    bl,bl
      int    10h                ; 80*50...
;----------------------------------------------------------------------------)
      cld
      lea    si,pal
      mov    dx,3c8h
      mov    al,1               ; first reg to set...
      out    dx,al
      inc    dx
      mov    cx,20*3            ; numbers of colors
      rep    outsb              ; setpal
;----------------------------------------------------------------------------)
        mov     cx,49
pre_y:  mov     ax,160
        mov     bx,cx
        dec     bx              ; ok, this one is a bit dirty... but it works!
        add     bx,bx           ; it "shifts" the table one entry left...
        mul     cx              ; so we have row 1 at position 0.
        inc     ax              ; and we wanna have the atrribute...
        mov     [offset YTable+bx],ax
        loop    pre_y           ; PreCalc Y-Table
;----------------------------------------------------------------------------)
        mov     cx,50*80        ; no *2 because of stos->W<- ya see??
        xor     di,di
        mov     ax,223          ; this is the way how it is done (223=ß! hehe)
        rep     stosw           ; SPeCiaL (!) CLS
;----------------------------------------------------------------------------)
        mov  bx,366             ; length of strings...
@decode:xor  byte ptr [offset String1+bx],123
        dec  bx
        jns  @decode            ; decode Strings.... hehehehe
;----------------------------------------------------------------------------)
        push    es              ; changing es back to ds and then back to esÍ¸
        push    ds              ; is shorter than the Umweg ber ax ...      ³
        pop     es              ;                                            ³
        mov     ah,2            ;                                            ³
        xor     dx,dx           ;                                            ³
        xor     bh,bh           ;                                            ³
        int     10h             ;                                            ³
        lea     dx,String1      ;                                            ³
        mov     ah,09           ;                                            ³
        int     21h             ;                                            ³
        mov     ah,2            ;                                            ³
        mov     dx,3100h        ;                                            ³
        int     10h             ;                                            ³
        lea     dx,String2      ;                                            ³
        mov     ah,09           ;                                            ³
        int     21h     ;ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸                    ³
        pop     es ;<ÍÍÍÍ¾    write startstrings...     ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾
;----------------------------------------------------------------------------
again:
   inc  j
   dec  j2
   dec  j3
   inc  j4
   inc  j5
   call retrace
   call retrace
   xor  si,si
   xor  dx,dx
@yloop:
   call ycalc
   mov  cx,79
   mov  bx,si
   add  bx,bx
   mov  di,[offset Ytable+bx]
   mov  bp,79*2
@xloop1:
   xcalc
   shr  al,5
   mov  es:[di+bp],al
   dec  bp
   dec  bp
   dec  cx
   jns  @xloop1

   inc  dx
   call ycalc
   mov  cx,79
   mov  bp,79*2
@xloop2:
   xcalc
   db   0c0h,0e8h,1             ;shr  al,1
   and  al,11110000b
   or   es:[di+bp],al
   dec  bp
   dec  bp
   dec  cx
   jns  @xloop2

   inc  dx
   inc  si
   cmp  si,48
   jnz  @yloop
;----------------------------------------------------------------------------)
	mov  ah,1
	int  16h
        jz   again                              ; exit if keypressed...
        cmp  ah,79
        jz   special
;----------------------------------------------------------------------------)
        xor  ah,ah
        int  16h

        inittext
        push ds
        pop  es

        mov  ax,1301h
        mov  bx,0003h
        mov  cx,33
        lea  bp,ExString1
        mov  dx,0200h
        int  10h

        mov  bl,07h
        mov  cx,12
        lea  bp,ExString2
        inc  dh
        int  10h

        mov  bl,08h
        mov  cx,46
        lea  bp,ExString3
        inc  dh
        int  10h

        mov  bl,0Fh
        mov  cx,16
        lea  bp,ExString4
        add  dh,3
        int  10h

        mov  bl,0dh
        mov  cx,29
        lea  bp,ExString5
        add  dh,2
        int  10h

        mov  bl,02h
        mov  cx,6
        lea  bp,ExString6
        inc  dh
        int  10h

        mov ah,2
        mov  dx,0b00h
        int  10h

Ende:   mov  ax,4ch                             ; and bye-bye
	int  21h

special:
      xor    ah,ah
      int    16h

      mov       ax,13h
      int       10h

      cld
      mov    dx,3c8h
      mov    al,1               ; first reg to set...
      out    dx,al
      inc    dx
      mov    al,63              ; numbers of colors
@makepal:
      out    dx,al
      out    dx,al
      out    dx,al
      dec    al
      jnz    @makepal

      mov    bx,1
tableloop:
      mov    al,[offset sint+bx]
      dec    bx
      mov    cl,[offset sint+bx]
      inc    bx
      sub    al,cl
      mov    byte ptr [offset sint2+bx],al
      inc    bx
      cmp    bx,256
      jnz    tableloop
      mov    byte ptr [offset sint2],3

      mov    bx,1
tableloop2:
      mov    al,[offset cost+bx]
      dec    bx
      mov    cl,[offset cost+bx]
      inc    bx
      sub    al,cl
      mov    byte ptr [offset cost2+bx],al
      inc    bx
      cmp    bx,256
      jnz    tableloop2
      mov    byte ptr [offset cost2],0

        mov     cx,199
prey:   mov     ax,320
        mov     bp,cx
        add     bp,bp
        mul     cx
        mov     [offset YTable+bp],ax
        dec     cx
        jns     prey

        mov     bp,NumSTar*2
initloop:
        call    newstar
        dec     bp
        dec     bp
        jnz     initloop

        mov     ax,0a000h
        mov     es,ax
        xor     bh,bh
mainloop:
        mov     bp,NumStar*2
        call    retrace
Starloop:
        mov     di,[offset OldDi+bp]
        xor     al,al
        stosb

        mov     ax,ZSpeed
        sub     word ptr [offset StarsZ+bp],ax
        mov     ax,YSpeed
        sub     word ptr [offset StarsY+bp],ax
        mov     ax,XSpeed
        sub     word ptr [offset StarsX+bp],ax


        cmp     word ptr [offset StarsZ+bp],Tiefe
        jb      @RZOk1
        call    newstar
        jmp     @skip
@RZOk1:                                        ; hier kann z aber noch 0 sein!
        cmp     word ptr [offset StarsZ+bp],0
        jne     @RZOk2
        call    newstar
        jmp     @skip
@RZOk2:
        mov     ax,[offset StarsY+bp]
        add     ax,Groesse/2
        cmp     ax,Groesse
        jb      @RYOk
        call    newstar
        jmp     @skip
@RYOk:
        mov     ax,[offset StarsX+bp]
        add     ax,Groesse/2
        cmp     ax,Groesse
        jb      @RXOk
        call    newstar
        jmp     @skip
@RXOk:
        mov     ax,[offset StarsY+bp]
        shl     ax,4
        cwd
        mov     cx,[offset StarsZ+bp]
        idiv    cx
        add     ax,100
        cmp     ax,200
        jb      @Pyok
        call    newstar
        jmp     @skip
@PYOk:  mov     di,ax
        add     di,di
        mov     di,[offset YTable+di]

        mov     ax,[offset StarsX+bp]
        shl     ax,4
        cwd
        idiv    cx
        add     ax,160
        cmp     ax,320
        jb      @Pxok
        call    newstar
        jmp     @skip
@PXOk:  add     di,ax
        mov     [offset OldDi+bp],di

        mov     ax,[offset StarsZ+bp]
        shr     ax,4
        stosb
@skip:
        dec     bp
        dec     bp
        jnz     StarLoop

        inc     j
        mov     al,j
        mov     cl,8
        div     cl
        or      ah,ah
        jnz     @notinc
        inc     j4
        dec     j2
        dec     j3
@notinc:
        mov     bl,j
        mov     al,[offset sint2+bx]
        mov     bl,j4
        add     al,[offset cost2+bx]
        cbw
        mov     ZSpeed,ax

        mov     bl,j3
        add     bl,j2
        mov     al,[offset sint2+bx]
        mov     bl,j
        add     al,[offset cost2+bx]
        cbw
        shl     ax,YShift
        mov     YSpeed,ax

        mov     bl,j3
        add     al,[offset sint2+bx]
        sub     al,j
        mov     bl,al
        mov     al,[offset cost2+bx]
        cbw
        shl     ax,XShift
        mov     XSpeed,ax

        mov  ah,1
	int  16h
        jz   mainloop                           ; exit if keypressed...

        xor  ah,ah
        int  16h
        inittext
        mov  ah,09h
        lea  dx,Blabla
        int  21h
        jmp  Ende
;----------------------------------------------------------------------------)
ycalc proc
            mov bx,word ptr j
            add bx,dx
            and bx,255
            mov al,[offset sint+bx]
            mov a,al
            mov bx,dx
            add bx,word ptr j2
            and bx,255
            mov al,[offset cost+bx]
            mov b,al
            mov bx,dx
            add bx,word ptr j3
            and bx,255
            mov al,[offset cost+bx]
            mov c,al
            mov bx,dx
            add bx,word ptr j4
            and bx,255
            mov al,[offset sint+bx]
            mov d,al
            mov bx,dx
            add bx,word ptr j5
            and bx,255
            mov al,[offset cost+bx]
            mov e,al
            ret
ycalc endp

retrace proc
   mov dx,3dah
@@1:in al,dx
   test al,8
   jz @@1
@@2:in al,dx
   test al,8
   jnz @@2
   ret
retrace endp

Random proc
        MOV     AX,[RandSeed]
        MOV     cx,[RandSeed2]
        MOV     si,[RandSeed3]
        ADD     AX,0a137h
        ADD     cx,63f7h
        ADD     si,784Ah
        ROL     AX,2
        MOV     [RandSeed],AX
        ADD     cx,AX
        ROR     cx,1
        MOV     [RandSeed2],cx
        SUB     si,cx
        XOR     AX,si
        MOV     [RandSeed3],si
        ADD     aX,cx
        mul     dx              ;(input value) * (delta)
        mov     cx,-1
        cmp     dx,cx           ;verify divide will work
	jae	abort		;jmp if divide will not work
        div     cx              ;(input value) * (delta) / ffffh
abort:  RET
random  endp

newstar proc
        mov     dx,Groesse
        call    random
        sub     ax,Groesse/2
        mov     [offset StarsX+bp],ax
        mov     dx,Groesse
        call    random
        sub     ax,Groesse/2
        mov     [offset StarsY+bp],ax
        mov     dx,Tiefe
        call    random
        inc     ax
        mov     [offset StarsZ+bp],ax
        ret
newstar endp
;--------------------D-A-T-A-------------------------------------------------)
include sine.inc
include color.inc
include palett.inc
String1 db 48,155,200,200,91,156,19,149,91,22,157,156,19,155,228,157,224,16,247,148,92,91,43,155,153,149,148,156,155,200,91,233,31,13,247,144,146,153,34,130,130,91,190,79,66,86,78,196,196,86,79,66,76,66,134,134,214,91,83,196,76,86,134,72,19,82,91,86,40,230,40,146,43,65,91,48,41,233,40,19,95
String2 db "?÷[ü•È[¹•#¹6’?•[÷”¹)’[,›![6C[šæ[0)é([][=(÷–”‚‚[0›»»[”’,[=’)[¹’”![’=[,›)•!‚‚_"
ExString1 db "0›»»[”’,[’)[š[»›6•‚‚[[[[[[[üæ›ÖÖÖ"
ExString2 db " ›»»[šV=’)•A"
ExString3 db "»•¹[÷¹[)”<[†[¹÷6•![›”?[ü›»»[š›ü0[†[6÷”![»C)‚‚"
ExString4 db "›==÷»÷›¹•?[,÷¹3A"
ExString5 db ':–68[… =)6)[)6[<"(‚‚‚&…'
ExString6 db "-’?’"
BlaBla  db "vq.[4.[:[2>[>:>‚‚[>>[44D[@R[4>[4[[.[44Z_"
RandSeed     DW 348Bh
RandSeed2    DW 7F34h
RandSeed3    DW 32bfh
a       db ?
b       db ?
c       db ?
d       db ?
e       db ?
j       db ?
j2      db ?
j3      db ?
j4      db ?
j5      db ?
ZSpeed dw ?
YSpeed dw ?
XSpeed dw ?
cost2  db 256 dup (?)
sint2  db 256 dup (?)
Ytable dw 200 dup (?)
STarsX dw Numstar dup(?)
StarsY dw NumStar dup(?)
STarsZ dw NumStar dup(?)
ProjeX dw NumStar dup(?)
ProjeY dw NumStar dup(?)
OldDI  dw NumStar dup(?)

code ends
end start
