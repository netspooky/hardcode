;
; BlobZ
;
; emc/d. Jul 2003
;
; Korilla round #1
;
; http://welcome.to/deus
;

NOFBLOBS=7
MAXBLOBS=16
MINIME=1
RNDSEED=110h

        .MODEL  TINY
        .486

        .CODE
        org     100h

MAIN:

; ------------------------------------------ Init

        mov     al,13h                  ;2
        int     10h                     ;2

blobsize=$+1

        mov     dx,3c9h                 ;3

@nxtPalEntry:

        mov     al,bh                   ;2

        out     dx,al                   ;1
        out     dx,al                   ;1
        out     dx,al                   ;1

        add     bx,40h                  ;3
        jnz     @nxtPalEntry            ;2

        push    0a000h                  ;3
        pop     es                      ;1

IF MINIME EQ 0
        fld1                            ;2
ENDIF

anglespeed=$+1
        fldz                            ;2

@nxtFrame:

; ------------------------------------------ Draw

        xor     di,di                   ;2
        mov     dx,200                  ;3
@nxtRow:
        mov     bp,320                  ;3

@nxtCol:

        fldz                            ;2 sum=0
        mov     cl,NOFBLOBS             ;2


        db      0beh                    ;1 mov si,offset blobxy+1
@nxtBlob:
        dec     si                      ;1 overlay opcodes
        dec     si                      ;1 

        mov     bx,bp                   ;2
@execTwice:
        inc     si                      ;1 pointer to MSB
        lodsb                           ;1 load MSB
        cbw                             ;1

        add     ax,120                  ;3
        sub     ax,bx                   ;2

        push    ax                      ;1
        fild    word ptr ss:[esp]       ;4
        pop     ax                      ;1 dummy pop - restore sp

        fmul    st,st                   ;2
        mov     bx,dx                   ;2

        neg     cx                      ;2
        jl      @execTwice              ;2 execute twice

        faddp   st(1)                   ;2
        fdivr   dword ptr blobsize      ;4
        fsubp   st(1)                   ;2 blobsize is negative

        loop    @nxtBlob                ;2


        push    ax                      ;1 dummy push
        fistp   word ptr ss:[esp]       ;4 save data into the stack
        pop     ax                      ;1 retrieve ax

        neg     ah                      ;2 saturate ah to 255
        sbb     ah,ah                   ;2
        or      al,ah                   ;2

        stosb                           ;1
        dec     bp                      ;1
        jnz     @nxtCol                 ;2

        dec     dx                      ;1
        jnz     @nxtRow                 ;2

             
; ------------------------------------------ Move 
; di=64000 => di+1536=0

        mov     cl,NOFBLOBS*2           ;2

@moveit:

IF MINIME EQ 0
        fxch    st(1)                   	;2
ENDIF
        fadd    dword ptr anglespeed    	;4
        fld     st                      	;2
        fcos                            	;2
        fild    word ptr [blobxyi+di+1536]      ;4
        fmulp   st(1),st                        ;2
        fistp   word ptr [blobxy+di+1536]       ;4

        scasw                           	;1 di=di+2
        loop    @moveit                 	;2

; ------------------------------------------ Loop

        mov     dx,3dah                 ;3
@vsync:
        in      al,dx                   ;1
        test    al,8                    ;2
        jnz     @vsync                  ;2


        in      al,60h                  ;2
        dec     ax                      ;1
        jnz     @nxtFrame               ;2

        mov     al,3h                   ;2
        int     10h                     ;2

        ret                             ;1

org 4e4eh
	blobxy dw MAXBLOBS dup (?,?)

org RNDSEED
	blobxyi dw MAXBLOBS dup (?,?)        ;(x,y) * MAXBLOBS

END     MAIN
