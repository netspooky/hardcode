

;-----------------------------------------------------------------------------
; Shade bobs
;                             
; Coded by NutCracker of The Immortal Syndicate 1994 
;
; This file is hereby released into the Public Domain so use it...
; Of course if this is put into a demo or some other production give me credit
; or else.... :)
;
; Sorry not many comments, i didn't have time....
;
;-----------------------------------------------------------------------------

                
                
                jumps
                .model  small,pascal
                .286

                dosseg
                .stack 1024

                global  BopShades:proc

;======================== Demo Equates and Data ==============================

TIMEOUT         equ     9000                    
MAXWIDTH        equ     320                     
MAXHEIGHT       equ     200
CENTERX         equ     160-25                  
CENTERY         equ     100-25
MAXBOPS         equ     250                     
RADIUSX         equ     170                     
RADIUSY         equ     180                     

                .data

                include shades.inc              
                include sincos.inc              

BopQueue        dw      MAXBOPS dup(?)          
BopHead         dw      ?                       
Angle           dw      ?                       
Phase1          dw      ?                       
Phase2          dw      ?                       
PhInc1          dw      ?
PhInc2          dw      ?
Frames          dw      ?                       

; Bob Routine

                .code

;*****************************************************************************
;ShowBop
;*****************************************************************************

ShowBop         proc near

                mov     ax,0A000h
                mov     es,ax
                xor     si,si
                mov     cx,BOPPTS
ShowLoop:       mov     al,[BopAddTab+si]
                shl     si,1
                mov     bx,[BopTab+si]
                shr     si,1
                add     es:[bx+di],al
                inc     si
                loop    ShowLoop
                ret

ShowBop         endp

;*****************************************************************************
;HideBop
;*****************************************************************************

HideBop         proc near

                mov     ax,0A000h
                mov     es,ax
                xor     si,si
                mov     cx,BOPPTS
HideLoop:       mov     al,[BopAddTab+si]
                shl     si,1
                mov     bx,[BopTab+si]
                shr     si,1
                sub     es:[bx+di],al
                inc     si
                loop    HideLoop
                ret

HideBop         endp

;*****************************************************************************
;Initbops
;*****************************************************************************

Initbops        proc near

                mov     ax,ds
                mov     es,ax
                lea     di,[BopQueue]
                mov     cx,MAXbops
                mov     ax,0FFFFh               
                cld                             
                rep     stosw                   
                mov     [BopHead],4             
                ret

Initbops        endp

;*****************************************************************************
;PutBop - Puts a new bopshade onto the Queue and updates the screen.
;*****************************************************************************

PutBop          proc near

                mov     di,dx
                imul    di,MAXWIDTH
                add     di,cx
                mov     bx,[BopHead]
                xchg    [BopQueue+bx],di
                cmp     di,MAXWIDTH*MAXHEIGHT
                jae     PutNewBop
                call    HideBop
PutNewBop:      mov     bx,[BopHead]
                mov     di,[BopQueue+bx]
                cmp     di,MAXWIDTH*MAXHEIGHT
                jae     SkipShow
                call    ShowBop
SkipShow:       add     [BopHead],2
                cmp     [BopHead],2*MAXbops            
                jb      ByePutBop
                mov     [BopHead],0
ByePutBop:      ret

PutBop          endp


;*****************************************************************************
;Start the shades
;*****************************************************************************

bopshades       proc

                mov     ax,13h
                int     10h

                mov     dx,3C8h
                xor     al,al  
                out     dx,al
                inc     dx
                mov     cx,256
                xor     ah,ah
SetPal:         xor     al,al                                     
                out     dx,al
                mov     al,ah  
                out     dx,al  
                xor     al,al  
                out     dx,al
                cmp     ah,62  
                jae     SetBrk
                inc     ah
SetBrk:         loop    SetPal

                call    Initbops

                mov     [Angle],0
                mov     [Phase1],2*1024
                mov     [Phase2],2*1024
                mov     [PhInc1],2
                mov     [PhInc2],3
                mov     [Frames],0

ShadesLoop:     mov     ax,[Angle]
                imul    [Phase1]
                mov     bl,ah
                mov     bh,dl
                shr     bx,2      
                xor     bh,bh
                mov     al,[CosTable+bx]
                mov     ah,RADIUSX
                imul    ah
                sar     ax,6                    
                add     ax,CENTERX
                mov     cx,ax

                mov     ax,[Angle]              
                imul    [Phase2]
                mov     bl,ah
                mov     bh,dl
                shr     bx,2                   
                xor     bh,bh
                mov     al,[SinTable+bx]
                mov     ah,RADIUSY
                imul    ah
                sar     ax,6                   
                add     ax,CENTERY
                mov     dx,ax

                call    PutBop                 

                mov     ax,[Angle]             
                inc     ax
                and     ax,1023
                mov     [Angle],ax

                mov     ax,[Phase1]            
                add     ax,[PhInc1]
                cwd
                mov     bx,1*2268              
                div     bx
                mov     [Phase1],dx

                mov     ax,[Phase2]            
                add     ax,[PhInc2]
                cwd
                mov     bx,1*2268              
                div     bx
                mov     [Phase2],dx

                inc     [Frames]               
                cmp     [Frames],TIMEOUT
                ja      ShadesBye

                mov     ah,1                   
                int     16h
                je      ShadesLoop

ShadesBye:      
                mov     cx,MAXbops             
HidesLoop:      push    cx
                mov     cx,0FFFFh
                mov     dx,cx
                call    PutBop
                pop     cx
                loop    HidesLoop

                mov     ax,03h
                int     10h
                ret

bopshades       endp



;*****************************************************************************
;Startup
;*****************************************************************************

Start           proc

                mov     ax,@Data
                mov     ds,ax
                call    bopshades
                mov     ax,4C00h
                int     21h

Start           endp

                end     Start



