컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;
;     TITLE: Horizontal Star field
;WRITTEN BY: DRAEDEN
;      DATE: 04/16/93
;
;     NOTES: Need 286+ to execute.
;
;ASSOCIATED FILES:
;
;       HSTAR.ASM   =>  This file
;
;       HSTAR.BAS   =>  Basic program that generates a set of 'random' star
;                       locations.  Creates the file 'HSTARS.DW'
;
;       HSTAR.TXT   =>  The text file that explains Horizontal "starfields"
;
;       HSTARS.DW   =>  Holds the star location data (the structured info)
;
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

    DOSSEG
    .MODEL SMALL
    .STACK 200h
    .CODE
    .286
    ASSUME CS:@CODE, DS:@CODE
    LOCALS

    Ideal

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

ScreenWidth  EQU 320
ScreenHeight EQU 200

STRUC Star
    XPos    dw  0
    YPos    dw  0
    OldDi   dw  0
ENDS Star

Level1  EQU 40      ;40 level 1's
Level2  EQU 70      ;30 level 2's
Level3  EQU 90      ;20 level 3's
Level4  EQU 100     ;10 level 4's -the index of the last of that level

VLevel1 dw  1       ;far ones go slow
VLevel2 dw  2
VLevel3 dw  3       
VLevel4 dw  4       ;closest ones go fastest

CLevel1 db  4       ;darkest
CLevel2 db  3
CLevel3 db  2       
CLevel4 db  1       ;nearest goes last- over writes others

Palette db  63,63,63    ;color for closest star
        db  40,40,40
        db  30,30,30
        db  20,20,20

INCLUDE "Hstars.dw"

LABEL YposChart WORD    ;chart used to lookup Offset of a Y position
    i=0
    REPT ScreenHeight
        dw i*ScreenWidth
        i=i+1
    ENDM
컴컴

VgaSeg  dw  0A000h      ;VGA segment for mode 13h

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
PROC DisplayAndMoveStars
    pusha
    push    es ds

    mov     ax,cs
    mov     ds,ax
    mov     es,[VgaSeg]

    mov     si,0
    mov     bp,[VLevel1]                        ;grab velocity
    mov     al,[CLevel1]                        ;grab color
Loop1:
    mov     di,[si + TheStars.OldDi]            ;erase old star
    mov     [byte es:di],0

    mov     di,[si + TheStars.Ypos]     
    add     di,di
    mov     di,[di + YposChart]                 ;calculate Y pos offset

    add     [si + TheStars.Xpos],bp             ;advance the star
    cmp     [si + TheStars.Xpos],ScreenWidth    ;check range- upper
    jl      NoWrap1
    sub     [si + TheStars.Xpos],ScreenWidth
NoWrap1:
    cmp     [si + TheStars.Xpos],0              ;check range- lower
    jge     NoWrap1b
    add     [si + TheStars.Xpos],ScreenWidth
NoWrap1b:
    add     di,[si + TheStars.Xpos]             ;add in the Xpos

    mov     [es:di],al                          ;write dot to screen
    mov     [si + TheStars.OldDi],di            ;save old di
    
    add     si,size Star                        ;see if we are done
    cmp     si,(size Star)*Level1
    jb      loop1

    mov     bp,[VLevel2]                        ;same as above, just repeated
    mov     al,[CLevel2]
Loop2:
    mov     di,[si + TheStars.OldDi]
    mov     [byte es:di],0

    mov     di,[si + TheStars.Ypos]
    add     di,di
    mov     di,[di + YposChart]

    add     [si + TheStars.Xpos],bp
    cmp     [si + TheStars.Xpos],ScreenWidth
    jl      NoWrap2
    sub     [si + TheStars.Xpos],ScreenWidth
NoWrap2:
    cmp     [si + TheStars.Xpos],0
    jge     NoWrap2b
    add     [si + TheStars.Xpos],ScreenWidth
NoWrap2b:

    add     di,[si + TheStars.Xpos]

    mov     [es:di],al
    mov     [si + TheStars.OldDi],di
    
    add     si,size Star
    cmp     si,(size Star)*Level2
    jb      loop2

    mov     bp,[VLevel3]            ;same.. just a repeat for level 3
    mov     al,[CLevel3]
Loop3:
    mov     di,[si + TheStars.OldDi]
    mov     [byte es:di],0

    mov     di,[si + TheStars.Ypos]
    add     di,di
    mov     di,[di + YposChart]

    add     [si + TheStars.Xpos],bp
    cmp     [si + TheStars.Xpos],ScreenWidth
    jl      NoWrap3
    sub     [si + TheStars.Xpos],ScreenWidth
NoWrap3:
    cmp     [si + TheStars.Xpos],0
    jge     NoWrap3b
    add     [si + TheStars.Xpos],ScreenWidth
NoWrap3b:

    add     di,[si + TheStars.Xpos]

    mov     [es:di],al
    mov     [si + TheStars.OldDi],di
    
    add     si,size Star
    cmp     si,(size Star)*Level3
    jb      loop3

    mov     bp,[VLevel4]            ;repeat for level 4
    mov     al,[CLevel4]
Loop4:
    mov     di,[si + TheStars.OldDi]
    mov     [byte es:di],0

    mov     di,[si + TheStars.Ypos]
    add     di,di
    mov     di,[di + YposChart]

    add     [si + TheStars.Xpos],bp
    cmp     [si + TheStars.Xpos],ScreenWidth
    jl      NoWrap4
    sub     [si + TheStars.Xpos],ScreenWidth
NoWrap4:
    cmp     [si + TheStars.Xpos],0
    jge     NoWrap4b
    add     [si + TheStars.Xpos],ScreenWidth
NoWrap4b:

    add     di,[si + TheStars.Xpos]

    mov     [es:di],al
    mov     [si + TheStars.OldDi],di
    
    add     si,size Star
    cmp     si,(size Star)*Level4
    jb      loop4

    pop     ds es
    popa
    ret
ENDP DisplayAndMoveStars

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

START:
    mov     ax,13h
    int     10h

    mov     ax,cs
    mov     es,ax
    mov     ds,ax

    mov     dx,offset Palette       ;ES:DX points to palette data
    mov     ax,1012h                ; WRITE palette 
    mov     bx,1                    ;start at color 1
    mov     cx,4                    ; and write 4 of 'em
    int     10h

MainLoop:

    mov     dx,3dah
@@VRT:
    in      al,dx
    test    al,8
    jnz     @@VRT         ;wait until Verticle Retrace starts
@@NoVRT:
    in      al,dx
    test    al,8
    jz      @@NoVRT       ;wait until Verticle Retrace Ends

    call    DisplayAndMoveStars                        

    mov     ah,1
    int     16h
    jz      MainLoop

    xor     ah,ah
    int     16h
    cmp     al," "
    jne     ByeBye

    neg     [VLevel1]
    neg     [VLevel2]
    neg     [VLevel3]
    neg     [VLevel4]
    jmp     MainLoop

ByeBye:
    mov     ax,3
    int     10h
    mov     ax,4c00h
    int     21h

END Start
