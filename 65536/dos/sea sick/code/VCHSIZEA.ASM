        dosseg
        .286
        Locals

        MWAIT equ 080h
        CLEARLINE EQU 185

stacks  segment byte stack 'stack'
  thestak      db      256 dup (0)
stacks  ends

data    segment para public 'data'
        Font05          db      18819 dup (0)
        vla2cmp         db      10735 dup (0)
data    ends

code    segment byte public 'code'
           assume  cs:code, ds:code, es:code, ss:stacks
        
start:  
        cli
        mov     bx,seg stacks
        mov     ss,bx
        mov     sp,200h
        sti
        mov     ax,es           ;set up all the segs
        mov     cs:[dseg],ax
        add     bx,20h
        mov     cs:[backupseg],bx
        add     bx,4000
        mov     cS:[overlayseg],bx
        add     bx,600*2
        mov     cs:[textseg],bx
        add     bx,600*2
        mov     cs:[textoverlayseg],bx
        
        jmp    main
        
;======- DATA -======

        Instruct db     "                                  ",13,10      
                db      "  KEYS:  +/- Change scroll speed  ",13,10
                db      "         [SPACE] Hurry scroll     ",13,10
                db      "         [ENTER] Next message     ",13,10
                db      "                                  ",13,10
                DB      "         1-4 Set Detail Level     ",13,10
                db      "                                  ",13,10      
                db      " This version should work better. ",13,10      
                db      "                                  ",13,10,0,"$"

        CENTERX equ     160
        CENTERY equ     100

        MESSAGEWIDTH equ 25

        Numtextlines EQU 8
        CmpValue db     10
        CurTextline dw  1
        curtextlineoffset dw offset textlines2+2
        Textlinesoffset dw offset textlines1,offset textlines2,offset textlines3
                dw      offset textlines4,offset textlines5,offset textlines6
                dw      offset textlines7,OFFSET TEXTLINES8
        setvalue db 20

        textlines1 db   20,5            ;number of lines, line to change msg
                db      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,1,2,3,4,5,6,8,9,10,11,12,14,15,16,17,18,19, 0
                db      0,0,0,2,3,4,5,7,8,10,11,13,14,16,17,19, 0, 0, 0
                db      0,0,0,0,0,0,2,5,7,10,13,16,19, 0, 0, 0, 0, 0, 0
                db      0,0,0,0,0,0,0,0,3,10,16, 0, 0, 0, 0, 0, 0, 0, 0
                db      0,0,0,0,0,0,0,0,0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db      0,0,0,0,0,0,0,0,16,10,3, 0, 0, 0, 0, 0, 0, 0, 0
                db      0,0,0,0,0,0,19,16,13,10,7,5,2, 0, 0, 0, 0, 0, 0
                db      0,0,0,19,17,16,14,13,11,10,8,7,6,5,4,3, 0, 0, 0
                db      0,19,18,17,16,15,14,12,11,10,9,8,6,5,4,3,2,1, 0
                db      19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
                db      0,19,18,17,16,15,14,12,11,10,9,8,6,5,4,3,2,1, 0
                db      0,0,0,19,17,16,14,13,11,10,8,7,6,5,4,3, 0, 0, 0
                db      0,0,0,0,0,0,19,16,13,10,7,5,2, 0, 0, 0, 0, 0, 0
                db      0,0,0,0,0,0,0,0,16,10,3, 0, 0, 0, 0, 0, 0, 0, 0
                db      0,0,0,0,0,0,0,0,0,9,0, 0, 0, 0, 0, 0, 0, 0, 0
                db      0,0,0,0,0,0,0,0,3,10,16, 0, 0, 0, 0, 0, 0, 0, 0
                db      0,0,0,0,0,0,2,5,7,10,13,16,19, 0, 0, 0, 0, 0, 0
                db      0,0,0,2,3,4,5,7,8,10,11,13,14,16,17,19, 0, 0, 0
                db      0,1,2,3,4,5,6,8,9,10,11,12,14,15,16,17,18,19, 0
        Textlines2 db   20,10
                db      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      1,2,3,4,5,6,7,8,9, 0,11,12,13,14,15,16,17,18,19
                db      1,2,3,4,5,6,7,8,0, 0, 0,12,13,14,15,16,17,18,19
                db      1,2,3,4,5,6,7,0,0, 0, 0, 0,13,14,15,16,17,18,19
                db      1,2,3,4,5,6,7 dup (0),14,15,16,17,18,19
                db      1,2,3,4,5,9 dup (0),15,16,17,18,19
                db      1,2,3,4,11 dup (0),16,17,18,19
                db      1,2,3,13 dup (0),17,18,19
                db      1,2,15 dup(0),18,19
                db      1,17 dup (0),19
                db      19 dup (0)
                db      1,17 dup (0),19
                db      1,2,15 dup(0),18,19
                db      1,2,3,13 dup (0),17,18,19
                db      1,2,3,4,11 dup (0),16,17,18,19
                db      1,2,3,4,5,9 dup (0),15,16,17,18,19
                db      1,2,3,4,5,6,7 dup (0),14,15,16,17,18,19
                db      1,2,3,4,5,6,7,0,0, 0, 0, 0,13,14,15,16,17,18,19
                db      1,2,3,4,5,6,7,8,0, 0, 0,12,13,14,15,16,17,18,19
                db      1,2,3,4,5,6,7,8,9, 0,11,12,13,14,15,16,17,18,19
        Textlines3 db   20,10
                db      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18,19
                db      0,0,1,2,3,4,5,6,7,8,12,13,14,15,16,17,18,19,0
                db      0,0,0,1,2,3,4,5,6,7,13,14,15,16,17,18,19,0,0
                db      0,0,0,0,1,2,3,4,5,6,14,15,16,17,18,19,3 dup (0)
                db      5 dup (0),1,2,3,4,5,15,16,17,18,19,4 dup (0)
                db      6 dup (0),1,2,3,4,16,17,18,19,5 dup (0)
                db      7 dup (0),1,2,3,17,18,19,6 dup (0)
                db      8 dup (0),1,2,18,19,7 dup (0)
                db      9 dup (0),1,19,8 dup (0)
                db      19 dup (0)
                db      9 dup (0),1,19,8 dup (0)
                db      8 dup (0),1,2,18,19,7 dup (0)
                db      7 dup (0),1,2,3,17,18,19,6 dup (0)
                db      6 dup (0),1,2,3,4,16,17,18,19,5 dup (0)
                db      5 dup (0),1,2,3,4,5,15,16,17,18,19,4 dup (0)
                db      0,0,0,0,1,2,3,4,5,6,14,15,16,17,18,19,3 dup (0)
                db      0,0,0,1,2,3,4,5,6,7,13,14,15,16,17,18,19,0,0
                db      0,0,1,2,3,4,5,6,7,8,12,13,14,15,16,17,18,19,0
                db      0,1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,18,19
        Textlines4 db   20,10
                db      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14
                db      7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13
                db      8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12
                db      8,8,9,9,9,9,9,10,10,10,10,10,11,11,11,11,11,12,12
                db      9,9,9,9,9,9,10,10,10,10,10,10,11,11,11,11,11,11,12
                db      9,9,9,9,9,9,10,10,10,10,10,10,10,11,11,11,11,11,11
                db      9,9,0,9,9,0,10,10, 0,10,10, 0,10,11,00,11,11,00,11
                db      9,0,0,0,9,0,10,00, 0,00,10,00,10,00,00,00,11,00,11
                db      0,0,0,0,9,0,00,00,00,00,10,00,00,00,00,00,11,00,00
                db      19 dup (0)
                db      0,0,0,0,9,0,00,00,00,00,10,00,00,00,00,00,11,00,00
                db      9,0,0,0,9,0,10,00, 0,00,10,00,10,00,00,00,11,00,11
                db      9,9,0,9,9,0,10,10, 0,10,10, 0,10,11,00,11,11,00,11
                db      9,9,9,9,9,9,10,10,10,10,10,10,10,11,11,11,11,11,11
                db      9,9,9,9,9,9,10,10,10,10,10,10,11,11,11,11,11,11,12
                db      8,8,9,9,9,9,9,10,10,10,10,10,11,11,11,11,11,12,12
                db      8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12
                db      7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,13
                db      5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14
        Textlines5 db   40,20
                db      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,1,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,2,1,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,0,3,2,1,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,0,0,4,3,2,1,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,0,0,0,5,4,3,2,1,10,11,12,13,14,15,16,17,18,19
                db      0,0,0,0,0,6,5,4,3, 2, 1,12,13,14,15,16,17,18,19
                db      0,0,0,0,0,0,7,6,5, 4, 3, 2, 1,14,15,16,17,18,19
                db      0,0,0,0,0,0,0,8,7, 6, 5, 4, 3, 2, 1,16,17,18,19
                db      0,0,0,0,0,0,0,0,9, 8, 7, 6, 5, 4, 3, 2, 1,18,19
                db      0,0,0,0,0,0,0,0,0,10, 9, 8, 7, 6, 5, 4, 3, 2, 1
                db      0,0,0,0,0,0,0,0,0, 0,11,10, 9, 8, 7, 6, 5, 4, 3
                db      0,0,0,0,0,0,0,0,0, 0, 0,12,11,10, 9, 8, 7, 6, 5
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0,13,12,11,10, 9, 8, 7
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0,14,13,12,11,10, 9
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0,15,14,13,12,11
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0,16,15,14,13
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0,17,16,15
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0,18,17
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0,19                
                DB      19 dup (0)
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0,19
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0,18,17
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0,17,16,15
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0,16,15,14,13
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0,15,14,13,12,11
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0, 0,14,13,12,11,10, 9
                db      0,0,0,0,0,0,0,0,0, 0, 0, 0,13,12,11,10, 9, 8, 7
                db      0,0,0,0,0,0,0,0,0, 0, 0,12,11,10, 9, 8, 7, 6, 5
                db      0,0,0,0,0,0,0,0,0, 0,11,10, 9, 8, 7, 6, 5, 4, 3
                db      0,0,0,0,0,0,0,0,0,10, 9, 8, 7, 6, 5, 4, 3, 2, 1
                db      0,0,0,0,0,0,0,0,9, 8, 7, 6, 5, 4, 3, 2, 1,18,19
                db      0,0,0,0,0,0,0,8,7, 6, 5, 4, 3, 2, 1,16,17,18,19
                db      0,0,0,0,0,0,7,6,5, 4, 3, 2, 1,14,15,16,17,18,19
                db      0,0,0,0,0,6,5,4,3, 2, 1,12,13,14,15,16,17,18,19
                db      0,0,0,0,5,4,3,2,1,10,11,12,13,14,15,16,17,18,19
                db      0,0,0,4,3,2,1,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,0,3,2,1,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,2,1,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      0,1,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
        Textlines6 db   10,5
                db      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      1,2,3,0,5,6,7,8,0,10,11,12,13,00,15,16,17,18,00
                db      1,2,0,0,5,6,7,0,0,10,11,12,00,00,15,16,17,00,00
                db      1,0,0,0,5,6,0,0,0,10,11,00,00,00,15,16,00,00,00
                db      0,0,0,0,5,0,0,0,0,10,00,00,00,00,15,00,00,00,00
                DB      19 dup (0)
                db      0,0,0,0,5,0,0,0,0,10,00,00,00,00,15,00,00,00,00
                db      1,0,0,0,5,6,0,0,0,10,11,00,00,00,15,16,00,00,00
                db      1,2,0,0,5,6,7,0,0,10,11,12,00,00,15,16,17,00,00
                db      1,2,3,0,5,6,7,8,0,10,11,12,13,00,15,16,17,18,00
        Textlines7 db   39,20
                db      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                db      2,4,5,6,7,8,9,9,10,10,11,11,12,13,14,15,16,17,19
                db       2, 5, 7, 8, 8, 9, 9, 9,10,10,10,11,11,11,12,12,13,15,18
                db       3, 6, 8, 9, 9,10,10,10,11,11,11,12,12,12,13,13,14,16,19
                db       4, 7, 9,10,10,11,11,11,12,12,12,13,13,13,14,14,15,17,0
                db       5, 8,10,11,11,12,12,12,13,13,13,14,14,14,15,15,16,18,0
                db       6, 9,11,12,12,13,13,13,14,14,14,15,15,15,16,16,17,19,0
                db       7,10,12,13,13,14,14,14,15,15,15,16,16,16,17,17,18, 0,0
                db       8,11,13,14,14,15,15,15,16,16,16,17,17,17,18,18,19, 0,0
                db       9,12,14,15,15,16,16,16,17,17,17,18,18,18,19,19, 0, 0,0
                db      10,13,15,16,16,17,17,17,18,18,18,19,19,19,5 dup (0)
                db      11,14,16,17,17,18,18,18,19,19,19,8 dup (0)
                db      12,15,17,18,18,19,13 dup (0)
                db      13,16,18,19,19,14 dup (0)
                db      14,17,19,16 dup (0)
                db      15,18,17 dup (0)
                db      16,19,17 dup (0)
                db      17,18 dup (0)
                db      18,18 dup (0)
                db      19,18 dup (0)
                db      19 dup (0)
                db      19,18 dup (0)
                db      18,18 dup (0)
                db      17,18 dup (0)
                db      16,19,17 dup (0)
                db      15,18,17 dup (0)
                db      14,17,19,16 dup (0)
                db      13,16,18,19,19,14 dup (0)
                db      12,15,17,18,18,19,13 dup (0)
                db      11,14,16,17,17,18,18,18,19,19,19,8 dup (0)
                db      10,13,15,16,16,17,17,17,18,18,18,19,19,19,5 dup (0)
                db       9,12,14,15,15,16,16,16,17,17,17,18,18,18,19,19, 0, 0,0
                db       8,11,13,14,14,15,15,15,16,16,16,17,17,17,18,18,19, 0,0
                db       7,10,12,13,13,14,14,14,15,15,15,16,16,16,17,17,18, 0,0
                db       6, 9,11,12,12,13,13,13,14,14,14,15,15,15,16,16,17,19,0
                db       5, 8,10,11,11,12,12,12,13,13,13,14,14,14,15,15,16,18,0
                db       4, 7, 9,10,10,11,11,11,12,12,12,13,13,13,14,14,15,17,0
                db       3, 6, 8, 9, 9,10,10,10,11,11,11,12,12,12,13,13,14,16,19
                db       2, 5, 7, 8, 8, 9, 9, 9,10,10,10,11,11,11,12,12,13,15,18
                db      2,4,5,6,7,8,9,9,10,10,11,11,12,13,14,15,16,17,19
        Textlines8 db   20,10
                db      1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
                DB      0,2,3,4,5,6,7,8,9,10, 0,12,13,14,15,16,17,18,19
                DB      0,2,3,4,5,6,7,0,9,10, 0,12,13,14, 0,16,17,18,19
                DB      0,2,3,0,5,6,7,0,9,10, 0,12,13,14, 0,16, 0,18,19
                DB      0,2,3,0,5,0,7,0,9,10, 0,12, 0,14, 0,16, 0,18,19
                DB      0,2,0,0,5,0,7,0,9,10, 0,12, 0,14, 0,16, 0,18, 0
                DB      0,2,0,0,5,0,7,0,9, 0, 0,12, 0,14, 0, 0, 0,18, 0
                DB      0,2,0,0,5,0,0,0,9, 0, 0, 0, 0,14, 0, 0, 0,18, 0
                DB      0,0,0,0,5,0,0,0,9,0,0,0,0,14,0,0,0,0,0
                DB      0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0
                DB      19 DUP (0)
                db      1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0
                db      1,0,3,0,0,0,0,0,0,0,11,0,0,0,0,16,0,0,0
                db      1,0,3,0,0,0,7,0,0,0,11,0,0,0,0,16,0,18,0
                db      1,0,3,0,0,0,7,8,0,0,11,0,13,0,0,16,0,18,0
                db      1,0,3,0,0,0,7,8,0,10,11,0,13,0,0,16,0,18,19
                db      1,0,3,0,5,0,7,8,0,10,11,0,13,14,0,16,0,18,19
                db      1,0,3,4,5,0,7,8,9,10,11,0,13,14,0,16,0,18,19
                db      1,2,3,4,5,0,7,8,9,10,11,0,13,14,15,16,0,18,19
                db      1,2,3,4,5,0,7,8,9,10,11,12,13,14,15,16,17,18,19
                
        dseg    dw      0
        vgaseg  dw      0a000h
        backupseg dw    0
        overlayseg dw   0
        Textseg dw      0
        Textoverlayseg dw       0        
        
        Specialtextflag db 0

        Xsize dw        250
        Ysize   dw      105
        
        ByteValue dw    0
        Resultstring db "00000"
        resultstringend db "$"

        Header  db      "VGACHR"
        Sizex   db      18
        Sizey   db      19
        Numchars db     66

        Fadestep db     0
        Distance dw     110h+10
        opDist  dw      110h+10
        Velocity dw     9
        Acceleration dw 1

        RightSide db    0

        XYsize  dw      18*19
        pal     db      768 dup (0)
        PALTMP  DB      768 DUP (0)
        palstep  db     768 dup (0)
        palstep2 db     768 dup (0)
        redstep db      80*3 dup (0)
        redstep2 db     80*3 dup (0)
        redbluepal  db  80*3 dup (0)

        Count   dw      1
        CharCount db    1

        Xstart  dw      -145
        ScrollCOunt db  1
        ScrollSpeed db  4

        MSGPAUSE        DW      10

        ErrorMessage db "File Error.  Program Aborted.",13,10,"$"

                        ; 1 IS CHANGE COLOR TO NEXT BYTE
        TextMsg2 db     (320-15*18)/2,1,0,"CODED ",1,24,"BY @",1,8,"DRAEDEN",1,24,"@ ",1,0,0
        
                ;1 IS COLOR - 0 IS END OF MESSAGE
                ;21 CHARS EACH MSG or less!

        Msg1    db      (320-15* 9)/2,1, 32,"@ V L A @       ",0
        MSG2    DB      (320-15* 9)/2,1,136,"P",1,128,"R",1,136,"E",1,128,"S",1,136,"E",1,128,"N",1,136,"T",1,128,"S",1,136,":",0
        MSG3    DB      (320-15*11)/2,1, 48,"-",1,32," SEASICK",1,48," -",0
        MSG4    DB      (320-15*17)/2,1, 40,"@ ",1,32,"*",1,40," @",1,32," *",1,40," @",1,32," *",1,40," @ ",1,32,"* ",1,40,"@",0
        MSG5    DB      (320-15*20)/2,1, 32,"CURRENT MEMBERS ARE:",0
        MSG6    DB      (320-15*20)/2,1, 32,"DRAEDEN ",1,40,"@",1,48," MAIN CODER",0
        MSG61   DB      (320-15*10)/2,1, 48,"AND ARTIST",0
        MSG7    DB      (320-15*19)/2,1, 40,"THE KABAL",1,32," @",1,48," ARTIST?",0
        MSG8    DB      (320-15*17)/2,1, 48,"LITHIUM ",1,32,"*",1,40," PERHAPS",0
        MSG9    DB      (320-15*15)/2,1, 40,"ALSO AN ARTIST?",0
        MSG10   DB      (320-15*21)/2,1, 32,"OR MAYBE COORDINATOR?",0
        MSG13   DB      (320-15*19)/2,1, 48,"$ UNTIL NEXT TIME $",0
        MSG14   DB      (320-15*20)/2,1,128,"REMEMBER:",1,8," THE GNAT..",0
        MSG15   DB      (320-15*19)/2,1, 32,"ALWAYS FLIES EAST..",0
        MSG16   DB      (320-15*12)/2,1, 48,"WHEN IN HEAT",0
        MSG17   DB      (320-15*12)/2,1, 40,"OR SOMETHING",0 
        MSG18   DB      (320-15*10)/2,1, 32,"LIKE THAT?",0
        MSG19   DB      (320-15*17)/2,1,128,"*",1,136,"@",1,8," BYE FOR NOW",1,136," @",1,128,"*",0
        MSG20   DB      (320-15* 3)/2,1,128," ",0
        MSG21   DB      (320-15*12)/2,1, 32,"IT'S OVER...",0
        MSG22   DB      (320-15* 8)/2,1, 40,"GO AWAY",1,128,"!",0
                                          

        MSGOFFSETS Dw   OFFSET MSG1,OFFSET MSG2,OFFSET MSG3,OFFSET TEXTMSG2
                DW      OFFSET MSG4,OFFSET MSG5,OFFSET MSG6,OFFSET MSG61,OFFSET MSG7
                DW      OFFSET MSG8,OFFSET MSG9,OFFSET MSG10
                DW      OFFSET MSG13,OFFSET MSG14,OFFSET MSG15
                DW      OFFSET MSG16,OFFSET MSG17,OFFSET MSG18,OFFSET MSG19
                DW      OFFSET MSG20,OFFSET MSG20,OFFSET MSG21,OFFSET MSG22
                DW      OFFSET MSG20,OFFSET MSG20,OFFSET MSG22,OFFSET TEXTMSG2
        NUMMSG  DB      27
        msgcount db     0

        TextLength       db 0
        Letstart dw      0
        printIt db      0
        cOLOR   DB      0
                                               
        CAPSCOLOR equ 0
        LOWERCOLOR equ 128
                                                ;
        TextMsg db      "                      ",34,"SEASICK",34,"    BY *draeden* OF vla..."
                DB      " OUR LITTE GROUP IS STILL IN NEED OF A COUPLE MORE ASSEMBLER CODERS,"
                DB      " ARTIST OR SOMEONE WHO WOULD KNOW HOW TO GET MUSIC TO WORK... "
                DB      " WE'RE STILL WORKING ON A FEW MORE LOADER TRYING DIFFERENT STUFF "
                DB      "LIKE A SCROLL THAT APPEARS TO BE 3D - SORT OF LIKE I HAVE HERE... "
                DB      "LOOK FOR IT IN ABOUT A MONTH... BY THEN WE'LL PROBABLY HAVE SOUND FOR THESE THINGS.   "
                db      " OH, YEAH A mega THANKS TO *thg* FOR THIS FONT! "
                DB      " AND I'VE REVISED MY FADER ROUTINES * CHECK IT OUT * "
                DB      " NOTICE HOW THE COLORS KEEP THEIR COLOR WHEN THEY FADE *@* :) "
                db      " DO YOU REALIZE THAT YOUR LOOKING AT THE RESULT OF ABOUT 1200 LINES OF CODE?"
                DB      " NO? OH WELL...  $ "
                DB      " UNTIL NEXT TIME, ADIOS! *@VLA@vla@VLA@vla@VLA@vla@VLA@vla@*",0

        Dist    dw      256 dup (100h)
        DistCnt db      0
        DistCnt2 db     0
        redorblue db    0        
        rbfade  db      32

        Detaillevel db  3

;======SUBROUTINES================

Calcforrb proc near
        mov     ax,cs
        mov     es,ax
        mov     ds,ax
        mov     bx,80*3
        xor     ah,ah
Fsu2:
        mov     al,[redbluepal+bx]
        sub     al,[paltmp+bx+128*3]
        cmp     al,64
        jb      noneg
        neg     al
noneg:
        shl     ax,2
        mov     [redstep+bx],al
        dec     bx
        jne     fsu2
        mov     di,offset redstep2
        xor     al,al
        mov     cx,80*3
        rep     stosb
        ret
calcforrb endp

Fadered proc near
        cld
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     bx,80*3
        xor     ch,ch
rfloop:
        mov     al,[redstep+bx]
        xor     ah,ah
        mov     cl,[redstep2+bx]
        add     ax,cx
        mov     [redstep2+bx],al
        or      ah,ah
        je      rnoinc

        mov     al,[paltmp+bx+128*3]
        cmp     al,[redbluepal+BX]
        je      rnoinc
        jb      rbinc
        dec     paltmp[bx+128*3]
        jmp     rnoinc
rbinc:
        inc     paltmp[bx+128*3]
rnoinc:
        dec     bx
        jne     rFloop
            
        mov     dx,03dah
var:    in      al,dx
        and     al,08
        jz      var

        mov     dx,03c8h
        mov     al,0
        out     dx,al
        inc     dx
        mov     cx,128*3+80*3
        mov     si,offset paltmp
        rep     outsb        
        ret
fadered endp

DeCompressit proc near
        mov     ax,0a000h
        mov     es,ax
        mov     ax,seg data
        mov     ds,ax

        mov     di,40*320+35
        mov     si,776
        add     si,offset vla2cmp
                        
        mov     cx,cs:[xsize]
        mov     bx,cs:[ysize]
        mov     dl,0feh
        push    di
TrAgain:
        lodsb
        cmp     al,dl
        je      decodeloop
        stosb
jumphere:
        dec     cx
        jne     tragain
        mov     cx,cs:[xsize]
        pop     di
        add     di,320
        push    di
        dec     bx
        jne     tragain
        jmp     alldone

DECODELOOP:
        lodsb                   ;gets byte to repeat 
        mov     ah,ds:[si]
        inc     si              ;ah=# of times: al= byte to repeat
        stosb
        jmp     dcskip
Bigloop:
        stosb
        dec     ah
        je      jumphere
dcskip:
        dec     cx
        jne     Bigloop
        mov     cx,cs:[xsize]
        pop     di
        add     di,320
        push    di
        dec     bx
        jne     Bigloop
        jmp     alldone
AllDone:
        pop     di
        mov     ax,cS:[overlayseg]
        mov     es,ax
        mov     ax,0a000h
        mov     ds,ax
        mov     si,40h*320
        mov     di,0
        mov     cx,19*320     
        rep     movsw
        ret
deCompressit endp

newFadeIn proc near
        cld
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     bx,768
        xor     ch,ch
Nfiloop:
        mov     al,[palstep+bx]
        xor     ah,ah
        mov     cl,[palstep2+bx]
        add     ax,cx
        mov     [palstep2+bx],al
        or      ah,ah
        je      nnoinc
        mov     al,paltmp[bx]
        cmp     al,pal[BX]
        je      nnoinc
        inc     paltmp[bx]
nnoinc:
        dec     bx
        jne     nFIloop
        
writetopal:
        mov     dx,03dah
vrrr:    in      al,dx
        and     al,08
        jz      vrrr

        mov     dx,03c8h
        mov     al,0
        out     dx,al
        inc     dx
        mov     cx,768
        mov     si,offset paltmp
        rep     outsb        
        ret
newFadeIn endp

newFadeout proc near
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     bx,768
        xor     ch,ch
Nfoloop:
        mov     al,[palstep+bx]
        xor     ah,ah
        mov     cl,[palstep2+bx]
        add     ax,cx
        mov     [palstep2+bx],al
        or      ah,ah
        je      nnodec
        cmp     paltmp[Bx],0
        je      nnodec
        dec     paltmp[bx]
nnodec:
        dec     bx
        jne     nFoloop
        jmp     writetopal
newFadeout endp

        ;es:di = seg to write to
DisplayText proc near

        mov     bx,dx           ;string location
displayloop:
        mov     al,cs:[bx]
        or      al,al
        je      Textdone

        CMP     al,1
        jne     ncsc
        inc     bx
        mov     al,cs:[bx]
        mov     cs:[color],al
        inc     bx
        jmp     displayloop
ncsc:
        sub     al,' '
        cmp     al,cS:[numchars]
        ja      skipit

        call    putchar         ;al= frame # es:di is dest
        mov     cl,cs:[sizex]
        xor     ch,ch
        add     di,cx
skipit:
        inc     bx
        jmp     displayloop
TextDone:
        ret
DisplayText endp

        ;Destroys AX, DX, CX
PutChar proc near
        push    ds
        push    si
        push    di

        xor     ah,ah
        mov     dx,cs:[xysize]
        mul     dx
        mov     si,ax
        add     si,9
        mov     ax,seg data
        mov     ds,ax
        mov     cl,cs:[sizex]
        mov     ch,cs:[sizey]
        push    di
putloop:
        lodsb
        or      al,al
        je      @@s
        add     al,cs:[color]
        stosb
        jmp     @@d
@@s:
        inc     di
@@d:
        dec     cl
        jne     putloop
        mov     cl,cs:[sizex]
        pop     di        
        add     di,320
        push    di
        dec     ch
        jne     putloop

        pop     ax
        pop     di
        pop     si
        pop     ds
        ret
PutChar endp

                        ;[xsize] and [ysize] must be set (of source) <255
                        ;bp is dist upon entry
Sizer   proc near       ;needs Ds:si set up to source ES:di to dest
        xor     cx,cx
        xor     ax,ax
        xor     dh,dh
        add     si,9
        push    si
        push    di      ;make a copy so we know where to start
        cmp     cs:[rightside],1
        jne     sizeloop
        jmp     sizeloop2
sizeloop:
        push    ax
        lodsb
        or      al,al
        je      @@s
        ADD     al,cs:[color]
        stosb
        jmp     @@d
@@s:
        inc     di
@@d:
        pop     ax
        dec     si
        xor     ah,ah
        add     ax,bp
        mov     dl,ah
        or      dl,dl
        je      Sizeloop        ;if the change is zero, why bother to add it?

        add     si,dx           ;add change to source
        add     cl,dl           ;cl counts xpos ch counts ypos (in source)
        cmp     cl,cs:[sizex]
        jb      sizeloop

        xor     cl,cl           ;we've just completed a line- on to the next
        xor     al,al
        pop     di
        pop     si
        add     di,320
        cmp     di,68*320
        ja      sizedone

        mov     al,cs:[sizex]   
        xor     bh,bh
        add     bx,bp           ;see how much to increase si
        mov     ah,bh
        add     ch,bh           ;inc ypos counter
        mul     ah              ;multilpy by xsize   
        add     si,ax           ;and add
        xor     ax,ax

        cmp     ch,cs:[sizey]   
        jae     sizedone

        push    si
        push    di              ;increase to next rows values
        jmp     sizeloop
sizedone:        
        ret
sizeloop2:
        push    ax
        cmp     byte ptr es:[di],0
        ;mov     al,es:[di]
        ;or      al,al
        jne     @@s2
        lodsb
        or      al,al
        je      @@na
        add     al,cs:[color]
        stosb
        jmp     @@d2
@@s2:
        inc     si
@@na:
        inc     di
@@d2:
        pop     ax
        dec     si
        xor     ah,ah
        add     ax,bp
        mov     dl,ah
        or      dl,dl
        je      Sizeloop2        ;if the change is zero, why bother to add it?

        add     si,dx           ;add change to source
        add     cl,dl           ;cl counts xpos ch counts ypos (in source)
        cmp     cl,cs:[sizex]
        jb      sizeloop2

        xor     cl,cl           ;we've just completed a line- on to the next
        xor     al,al
        pop     di
        pop     si
        add     di,320

        mov     al,cs:[sizex]   
        xor     bh,bh
        add     bx,bp           ;see how much to increase si
        mov     ah,bh
        add     ch,bh           ;inc ypos counter
        mul     ah              ;multilpy by xsize   
        add     si,ax           ;and add
        xor     ax,ax
        cmp     di,68*320
        ja      sizedone2
        
        cmp     ch,cs:[sizey]   
        jae     sizedone2

        push    si
        push    di              ;increase to next rows values
        jmp     sizeloop2
sizedone2:        
        ret
sizer endp

        
SetUpDist proc near
        xor     bx,bx
        mov     dh,0
        mov     dl,255
        mov     ax,cs:[distance]
        mov     cx,cs:[velocity]
        
BigSetUp:
        mov     bl,dl
        xor     bh,bh
        shl     bx,1

        add     ax,cx
        add     cx,cs:[acceleration]
        cmp     ax,cs:[opdist]
        jbe     movok
        sub     cx,cs:[acceleration]
        sub     cx,cs:[acceleration]
Movok:
        mov     cs:[dist+bx],ax
        inc     dl
        jne     BigSetup
        or      dh,dh
        jne     kkjo
        inc     dh
        jmp     bigsetup
kkjo:
        mov     cs:[distance],ax
        mov     cs:[velocity],cx
        mov     cs:[distCnt],255
        ret
SetUpDist endp  

scroll3d proc near
        mov     ax,cs:[backupseg]
        mov     es,ax
        xor     ax,ax
        xor     di,di
        mov     cx,32000
        rep     stosw
        
        mov     ax,seg data
        mov     ds,ax
        mov     ax,cS:[Backupseg]
        mov     es,ax

        mov     cs:[textlength],MESSAGEWIDTH

        mov     ax,cs:[letstart]
        mov     cs:[count],ax

        mov     al,cs:[distcnt]
        mov     cs:[distcnt2],al

        mov     cx,cs:[xstart]
        mov     al,cs:[scrollspeed]
        xor     ah,ah
        sub     cs:[xstart],ax
        push    cx

        add     cs:[scrollcount],al
        mov     cl,cs:[scrollcount]
        cmp     cl,cs:[sizex]
        jb      Disploop

        mov     cs:[scrollcount],0
        mov     cS:[xstart],-185
        inc     cs:[letstart]
        mov     bx,cs:[letstart]
        mov     al,cs:[textmsg+bx]
        or      al,al
        jne     disploop
        mov     cs:[letstart],0
Disploop:        
        mov     bx,cs:[count]
        inc     cS:[count]
        mov     al,cs:[textmsg+bx]
        or      al,al
        jne     notanend
        mov     cs:[count],0
        jmp     disploop
NotAnend:
        mov     cs:[color],CAPSCOLOR
        cmp     al,'a'
        jb      notcolor
        sub     al,32
        mov     cs:[color],LOWERCOLOR
Notcolor:
        dec     cs:[textlength]
        jne     notover
        pop     cx
        jmp     AlldoneHere
NotOver:
        xor     ah,ah
        sub     al,32
        mov     dx,cs:[xysize]
        mul     dx
        mov     si,ax

        pop     ax
        mov     dl,cs:[sizex]
        xor     dh,dh
        add     ax,dx
        push    ax
        mov     cs:[rightside],1
        cmp     ax,0700h
        jb      notoveryet
        mov     cs:[rightside],0
NotOverYet:
        inc     cs:[distcnt2]
        mov     bl,cs:[distcnt2]
        xor     bh,bh
        shl     bx,1
        mov     bp,cs:[dist+bx]
        
        push    -41              ;store ypos WAS -40

        mov     dx,100h         ;xpos*100h
        imul    dx
        idiv    bp              ;/distance
        mov     cx,ax
        add     cx,CENTERX      ;+160
        mov     ah,cs:[sizex]
        xor     al,al
        xor     dx,dx
        mov     bx,bp
        shl     bx,1
        div     bx
        sub     cx,ax           ;-xsize*100h/2*distance
        cmp     cx,310
        jb      @@c
        pop     ax
        jmp     disploop
@@c:
        pop     ax              ;ax has ypos now
        push    cx              ;save result from above
        
        mov     dx,100h         ;ypos*100h
        imul    dx
        idiv    bp              ;/distance
        mov     cx,ax
        add     cx,CENTERY      ;+100
        mov     ah,cs:[sizey]
        xor     al,al
        xor     dx,dx
        mov     bx,bp
        shl     bx,1
        div     bx
        sub     cx,ax           ;-ysize*100h/2*distance
        
        imul    di,cx,320
        pop     cx              ;bring back screenxpos
        add     di,cx   

        call    sizer
        jmp     Disploop

AllDoneHere:
        mov     ax,cs:[distance]
        mov     bx,cs:[velocity]
        mov     cx,cs:[acceleration]
        add     ax,bx
        add     bx,cx
        cmp     ax,cs:[opdist]
        jbe     @@m
        sub     bx,cx
        sub     bx,cx
@@M:
        mov     cs:[velocity],bx
        inc     cs:[distcnt]
        mov     bl,cs:[distcnt]
        xor     bh,bh
        shl     bx,1
        mov     cs:[distance],ax
        mov     cs:[dist+bx],ax

        mov     ax,cs:[backupseg]
        mov     ds,ax
        mov     ax,0a000h
        mov     es,ax
        mov     bx,21           ;was 23

        mov     si,47*320+20            ;was 45 & 163 DRAEDEN
        mov     di,165*320+20
Copyloop:
        mov     cx,280/2
        rep     movsw
        add     si,40
        add     di,40
        dec     bx
        jne     copyloop

        mov     cx,280/2
        mov     al,3
        mov     ah,al
        rep     stosw
        add     di,40
        mov     al,5
        mov     ah,al
        mov     cx,280/2
        rep     stosw
        
        add     di,40
        mov     bx,15
Copyloop2:
        mov     cx,280/2
        mov     al,cs:[detaillevel]
        or      al,al
        je      Donescroll3d3d
        cmp     al,3
        jb      notdarkened
Copylp3:
        lodsw
        or      al,al
        je      noal
        inc     al
noal:
        or      ah,ah
        je      noah
        inc     ah
noah:
        stosw
        loop    copylp3
        ;rep     movsw
        sub     si,280+320*2
        add     di,40
        dec     bx
        jne     copyloop2
        ret
NotDarkened:
        mov     cx,280/2
        rep     movsw
        sub     si,280+320*2
        add     di,40
        dec     bx
        jne     notdarkened

donescroll3d3d:
        ret
Scroll3d endp

Calcforfade proc near
        mov     ax,cs
        mov     es,ax
        mov     ds,ax
        mov     si,offset pal
        mov     di,offset palstep
        mov     cx,768
        xor     ah,ah
Fsu:
        lodsb
        shl     ax,2
        stosb
        dec     cx
        jne     fsu
        mov     di,offset palstep2
        mov     cx,768/2
        xor     ax,ax
        rep     stosw
        ret
calcforfade endp

;======- End Subs -======

Main:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     dx,offset instruct
        mov     ah,9
        int     21h

        mov     dx,offset pal
        mov     ax,1017h                ; read palette
        mov     bx,0                    
        mov     cx,256                  
        int     10h                     
        mov     si,offset pal
        mov     di,offset paltmp
        mov     cx,768/2
        rep     movsw
        call    calcforfade
        mov     cs:[fadestep],64
foo1:
        mov     dx,03dah
vrr:    in      al,dx
        and     al,08
        jz      vrr
        call    newfadeout
        dec     cs:[fadestep]
        jne     foo1

        MOV     ax,cs
        mov     es,ax
        mov     ax,seg data
        mov     ds,ax

        mov     al,ds:[6]
        mov     cs:[sizex],al
        mov     ah,ds:[7]
        mov     cs:[sizey],ah
        mul     ah
        mov     cs:[xysize],ax
        mov     al,ds:[8]
        mov     cs:[numchars],al

        mov     si,offset vla2cmp + 8
        mov     di,offset pal
        mov     cx,768/2
        rep     movsw
        call    calcforfade

        mov     ax,es
        mov     ds,ax

        mov     ax,0013h
        int     10h

        mov     ax,cs
        mov     ds,ax
        mov     es,ax

        mov     si,offset pal
        mov     di,offset pal+128*3
        mov     cx,16*3/2
        rep     movsw

        mov     dx,offset paltmp
        mov     ax,1012h                ; WRITE palette (all zeros)
        mov     bx,0                    
        mov     cx,256                  
        int     10h                     
        push    ds
        push    es
        call    decompressit 
        pop     es
        pop     ds


        call    setupdist
        mov     cs:[fadestep],64
l1fi:        
;        mov     dx,03dah
;vr1:    in      al,dx
;        and     al,08
;        jz      vr1
        
        call    newfadein
        call    scroll3d
        dec     cs:[fadestep]
        jne     l1fi
        mov     cs:[fadestep],64
        
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        
        mov     bx,0
seblue:
        mov     al,[pal+128*3+bx]
        mov     ah,[pal+128*3+bx+1]
        mov     dl,[pal+128*3+bx+2]
        mov     [redbluepal+bx+2],al
        mov     [redbluepal+bx+1],ah
        mov     [redbluepal+bx],dl
        add     bx,3
        cmp     bx,80*3+1
        jb      seblue

        call    calcforrb
        mov     cs:[rbfade],64

        mov     ax,cs:[textseg]
        mov     es,ax
        xor     di,di
        xor     ax,ax
        mov     cx,320*20/2
        rep     stosw


mlp:
        call    scroll3d
        cmp     cs:[specialtextflag],0
        jne     continuespecial
        DEC     cS:[msgpause]
        je      newmessages
        jmp     nonewmessages
newmessages:
        mov     cs:[msgpause],MWAIT
        mov     al,cS:[setvalue]
        mov     cs:[specialtextflag],al
        jmp     nonewmessages
Continuespecial:
        mov     ax,cS:[overlayseg]
        mov     ds,ax
        mov     ax,cs:[textoverlayseg]
        mov     es,ax
        mov     di,0
        mov     si,0
        mov     cx,19*160
        rep     movsw
        cld
        mov     ax,cs:[textseg]
        mov     ds,ax

        mov     bl,cS:[specialtextflag]
        dec     bl
        mov     al,19
        mul     bl
        mov     bx,ax
        add     bx,cs:[curtextlineoffset]
        mov     dx,19
        xor     di,di
copytextloop:
        mov     al,cs:[bx]
        or      al,al
        jne     thereissomething
        add     di,320
        jmp     donetextloop
Thereissomething:
        xor     ah,ah
        imul    si,ax,320
        mov     cx,320
hereboy:
        lodsb
        or      al,al
        je      downhere
        stosb
        dec     cx
        jne     hereboy
        jmp     donetextloop
downhere:
        inc     di
        dec     cx
        jne     hereboy

Donetextloop:
        inc     bx
        dec     dx
        jne     copytextloop

        mov     ax,0a000h
        mov     es,ax
        mov     ax,cs:[textoverlayseg]
        mov     ds,ax
        mov     di,40h*320
        xor     si,si
        mov     cx,19*320/2
        rep     movsw
        
        dec     cs:[specialtextflag]
        jne     notdoneyet
        inc     cS:[curtextline]
        cmp     cS:[curtextline],NUMTEXTLINES
        jb      textlinesok
        mov     cs:[curtextline],0
Textlinesok:
        mov     bx,cs:[curtextline]
        shl     bx,1
        mov     si,cs:[textlinesoffset+bx]
        mov     al,cs:[si]
        mov     ah,cs:[si+1]
        add     si,2
        mov     cs:[curtextlineoffset],si
        mov     cs:[cmpvalue],ah
        mov     cS:[setvalue],al
        jmp     nonewmessages
notdoneyet:
        mov     al,cS:[cmpvalue]
        cmp     cS:[specialtextflag],al
        jne     nonewmessages

        mov     bl,cs:[msgcount]      
        xor     bh,bh
        shl     bx,1
        mov     dx,cS:[msgoffsets+bx]
        mov     ax,cs:[textseg]
        mov     es,ax
        xor     di,di
        xor     ax,ax
        mov     cx,320*20/2
        rep     stosw
        mov     di,dx
        mov     bl,cs:[di]
        xor     bh,bh
        mov     di,bx
        inc     dx
        call    displayText
        inc     cs:[msgcount]
        mov     al,cs:[nummsg]
        cmp     cs:[msgcount],al
        jb      nonewmessages
        mov     cS:[msgcount],0
nonewmessages:
        cmp     cs:[detaillevel],2
        jb      nonewfade
        call    fadered
        dec     cS:[rbfade]
        jne     nonewfade
        mov     cs:[rbfade],64          ;NOTE ! WAS 64
        cmp     cs:[redorblue],0
        je      dorednow
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        
        mov     bx,0
settblue:
        mov     al,[pal+128*3+bx]
        mov     ah,[pal+128*3+bx+1]
        mov     dl,[pal+128*3+bx+2]
        mov     [redbluepal+bx+2],al
        mov     [redbluepal+bx+1],ah
        mov     [redbluepal+bx],dl
        add     bx,3
        cmp     bx,80*3+1
        jb      settblue

        mov     cs:[redorblue],0
        jmp     skipred
dorednow:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     di,offset redbluepal
        mov     si,offset pal
        mov     cx,16*3
        rep     movsb
        
        mov     si,offset pal +144*3
        mov     cx,64*3
        rep     movsb

        mov     cS:[redorblue],1
skipred:
        call    calcforrb
Nonewfade:
        mov     ah,1
        int     16h
        jnz      nomlp
        jmp     mlp
Nomlp:
        xor     ah,ah
        int     16h
        cmp     al," "
        jne     notspacebar
        inc     cs:[letstart]
        jmp     mlp
Notspacebar:
        cmp     al,13
        jne     notenter
        mov     cs:[msgpause],5
        jmp     mlp
NotEnter:
        cmp     al,"+"
        jne     notplus
        inc     cs:[scrollspeed]
        mov     al,cs:[sizex]
        cmp     cs:[scrollspeed],al
        jb      nottoobig
        dec     cs:[scrollspeed]
nottoobig:
        jmp     mlp
Notplus:
        cmp     al,"-"
        jne     notminus
        cmp     cs:[scrollspeed],0
        je      atzero
        dec     cs:[scrollspeed]
Atzero:
        jmp     mlp

Notminus:
        cmp     al,"1"
        jb      folp1
        cmp     al,"4"
        ja      folp1
        sub     al,"1"
        mov     cs:[detaillevel],al
        cmp     al,0
        je      noa1
        jmp     mlp
noa1:
        push    es
        mov     ax,0a000h
        mov     es,ax
        mov     di,CLEARLINE*320
        mov     cx,(200-CLEARLINE)*320/2
        xor     ax,ax
        rep     stosw
        pop     es
        jmp     mlp
folp1:
        mov     ax,cs
        mov     ds,ax
        mov     es,ax
        mov     si,offset paltmp +128*3
        mov     di,offset pal +128*3
        mov     cx,80*3
        rep     movsb

        call    calcforfade
folp:
;        mov     dx,03dah
;vr2:    in      al,dx
;        and     al,08
;        jz      vr2

        call    newfadeout
        call    scroll3d
        dec     cs:[fadestep]
        jne     folp
ByeBye:
byebye2:
        mov     ax,0003h
        int     10h
        mov     ax,4c00h
        int     21h

code ends
        end start 
