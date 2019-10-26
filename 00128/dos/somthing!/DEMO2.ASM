;################################################################################
;# Somthing! =o) by Chazm
;# ######################
;#
;# This is just somthing I made to try and make somthing for the 128Byte
;# compo =o)
;# ######################
;# E-mail Me At:ChasmCoder@excite.com
;# Voice Mail Me At Toll-Free:1-888-excite2 ext.291-322-8301 =o) Bye!
;################################################################################
.model tiny
.code
org 100h
Start:
        mov ah,0a0h                     ;|
        mov es,ax                       ;|Let es = Video Memmory Segment

        mov ax,0013h                    ;|
        int 10h                         ;|Set video mode to 320x200x256 CG

        mov al,15                       ;Start with Color 15(0Fh)
Lop:

        mov es:[di],al                  ;Plot Pixel On Screen
        cmp al,31                       ;Compare color to 31
        jle N1
        mov al,15                           
        jmp N2
N1:
        inc X                           ;|Mutation
        cmp X,0Ah ;0Ah                  ;|
        jne N2
        inc al
        mov X,0
N2:
        push ax                         ;|
        mov DX,H                        ;|
        mov AX,H                        ;|
        mul DX                          ;|
        push AX                         ;|
        pop AX                          ;|
        mov BX,A                        ;|
        mov AX,A                        ;|Supposedly The Cosine Of a 90ø angle
        mul BX                          ;|
        push AX                         ;|
        pop BX                          ;|
        mov AX,DX                       ;|
        div BX                          ;|
        add di,bx                       ;<-Add to di(Cursor Pos...)
        mov ah,01h                      ;Look For Key
        int 16h
        jnz Ext                          ;Yes Exit!
        ;cmp al,27                       ;Is Key <ESC>?
        pop ax
        jmp Lop                         ;Loop
Ext:
        mov ah,0
        int 16h
        mov ax,0003h                    ;Set Video Mode 80x25x16 CT
        int 10h
        mov ah,09h                      ;|Print Good Bye Message!
        mov dx,offset M                 ;|
        int 21h                         ;|
        int 20h                      ;Terminate program.

;My data! Data
X       dw      ?
H       dw      25
A       dw      9
M       db      'Bye! 2-2-00',0ah,0dh,'-Chazm$'
end Start
