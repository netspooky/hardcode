stak    segment stack 'stack'
stak    ends
code    segment
code    ends
buf     segment para
buf     ends

stak    segment stack 'stack'
        assume cs:code, ss:stak
        dw 40h dup(?)
stak    ends

code    segment
        assume cs:code, ds:code, ss:stak
        org     0

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
; DATA
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
NRF=72
CCYCWAIT=16

errmsg0 db      'VGA card not found!!!$'
errmsg1 db      'Not enough memory!!!$'

oirqm           db      ?,?
oirq1           dw      ?,?

doneflag        db      0

charmap db      0,0,0,0, 192,240,248,248, 252,252,252,252, 124,124,60,60
        db      60,60,124,124, 252,252,252,252,248,248,240,192, 0,0,0,0
        db      24,60,60,60, 60,60,60,60, 60,60,60,24, 0,0,0,0
        db      0,0,0,0, 60,126,255,255, 255,255,126,60, 0,0,0,0
        db      96,240,240,248, 248,120,124,60, 60,62,30,31, 31,15,15,6
        db      16 dup(60)
        db      11 dup(60), 24, 0,0,0,0
        db      0,0,0,0, 24, 11 dup(60)
        db      0,0,0,0, 252,254,255,255, 255,255,254,252, 0,0,0,0
        db      60,60,124,124, 252,252,252,252, 252,252,252,252, 124,124,60,60
        db      0,0,0,0, 3,15,31,31, 63,63,63,63, 62,62,60,60
        db      60,60,62,62, 63,63,63,63, 31,31,15,3, 0,0,0,0
        db      0,0,0,0, 63,127,255,255, 255,255,127,63, 0,0,0,0
        db      60,60,62,62, 63,63,63,63, 63,63,63,63, 62,62,60,60

renlogo db      192,182,32,192,190,32,189,32, 189,32,192,182,32,189,32,192,190,32,192,190,32,192,182,32,189,32, 189,32,192,190,32,192,190
        db      195,183,32,187,185,32,187,186,187,32,195,191,32,187,32,193,182,32,193,182,32,195,191,32,187,186,187,32,187,32, 32,187,185
        db      188,184,32,193,190,32,188,32, 188,32,188,188,32,188,32,194,183,32,194,183,32,188,188,32,188,32, 188,32,193,190,32,193,190

bardata dw      1,calcbufcar1,_ret,_ret,_ret,calcbufcsr1,_ret,_ret,_ret
        dw      6,calcbufcar1,_ret,_ret,_ret,calcbufcsr1,_ret,_ret,_ret
        dw      11,calcbufcar1,_ret,calcbufcar1,_ret,calcbufcsr1,_ret,calcbufcsr1,_ret
        dw      16,calcbufcar1,_ret,calcbufcar1,_ret,calcbufcsr1,_ret,calcbufcsr1,_ret
        dw      21,calcbufcar1,calcbufcar1,calcbufcar1,_ret,calcbufcsr1,calcbufcsr1,calcbufcsr1,_ret
        dw      26,calcbufcar1,calcbufcar1,calcbufcar1,_ret,calcbufcsr1,calcbufcsr1,calcbufcsr1,_ret
        dw      31,calcbufcar1,calcbufcar1,calcbufcar1,calcbufcar1,calcbufcsr1,calcbufcsr1,calcbufcsr1,calcbufcsr1
        dw      36,calcbufcar2,calcbufcar1,calcbufcar1,calcbufcar1,calcbufcsr2,calcbufcsr1,calcbufcsr1,calcbufcsr1
        dw      41,calcbufcar2,calcbufcar1,calcbufcar2,calcbufcar1,calcbufcsr2,calcbufcsr1,calcbufcsr2,calcbufcsr1
        dw      46,calcbufcar2,calcbufcar2,calcbufcar2,calcbufcar1,calcbufcsr2,calcbufcsr2,calcbufcsr2,calcbufcsr1
        dw      51,calcbufcar2,calcbufcar2,calcbufcar2,calcbufcar2,calcbufcsr2,calcbufcsr2,calcbufcsr2,calcbufcsr2
        dw      0

rlltbl  dw      80,-80,2560,2560+80,2560-80,-2560,-2560+80,-2560-80
        dw      -1280-120,-1280-40,-1280+40,-1280+120,1280-120,1280-40,1280+40,1280+120
        dw      -3840-120,-3840-40,-3840+40,-3840+120,3840-120,3840-40,3840+40,3840+120
        dw      5120,5120+80,5120-80

pbarf   dw      pbarr0,pbarr1,pbarr2,pbarr3,pbarr4,pbarr5,pbarr6,pbarr7,pbarr7

xofftbl db      8,0,1,2,3,4,5,6,7

text    db      2,22,17h,'Greetings everyone from',0
        db      2,46,1fh,'Renaissance',0
        db      -2,30h
        db      2,22,17h,'                       ',0
        db      2,46,1fh,'           ',0
        db      1,23,17h,'Starring ... the',0
        db      1,40,1fh,'Renaissance',0
        db      1,52,17h,'crew:',0
        db      -2,10h
        db      3,10,1fh,'Tran',0
        db      3,20,17h,'- Main Coder',0
        db      4,10,1fh,'C.C.Catch',0
        db      4,20,17h,'- Muzician',0
        db      5,10,1fh,'Daredevil',0
        db      5,20,17h,'- Coder/Sysop/PR',0
        db      3,47,1fh,'White Shadow',0
        db      3,60,17h,'- Coder',0
        db      4,47,1fh,'Zeek',0
        db      4,60,17h,'- Coder',0
        db      5,47,1fh,'CyberStrike',0
        db      5,60,17h,'- Coder',0
        db      -2,40h
        db      1,23,17h,'                ',0
        db      1,40,1fh,'           ',0
        db      1,52,17h,'     ',0
        db      3,10,1fh,'    ',0
        db      3,20,17h,'            ',0
        db      4,10,1fh,'         ',0
        db      4,20,17h,'          ',0
        db      5,10,1fh,'         ',0
        db      5,20,17h,'                ',0
        db      3,47,1fh,'            ',0
        db      3,60,17h,'       ',0
        db      4,47,1fh,'    ',0
        db      4,60,17h,'       ',0
        db      5,47,1fh,'           ',0
        db      5,60,17h,'       ',0
        db      1,11,17h,'If you really must, you can contact us on',0
        db      1,53,1fh,'The Sound Barrier',0
        db      -2,10h
        db      3,25,1fh,'FidoNet',0
        db      3,44,17h,'- 1:2603/304',0
        db      4,25,1fh,'SBCNet',0
        db      4,44,17h,'- 13:420/0',0
        db      5,25,1fh,'Creativity DemoNet',0
        db      5,44,17h,'- 94:87/0',0
        db      6,25,1fh,'TSANNet',0
        db      6,44,17h,'- 66:718/6',0
        db      -2,30h
        db      3,25,1fh,'       ',0
        db      3,44,17h,'            ',0
        db      4,25,1fh,'      ',0
        db      4,44,17h,'          ',0
        db      5,25,1fh,'                  ',0
        db      5,44,17h,'         ',0
        db      6,25,1fh,'       ',0
        db      6,44,17h,'          ',0
        db      3,25,17h,'And ofcourse, the fone numbers:',0
        db      4,33,1fh,'(718)979-6629',0
        db      5,33,1fh,'(718)979-9406',0
        db      -2,20h
        db      1,11,17h,'                                         ',0
        db      1,53,1fh,'                 ',0
        db      3,25,17h,'                               ',0
        db      4,33,1fh,'             ',0
        db      5,33,1fh,'             ',0
        db      3,14,17h,'If you missed anything, this text will now repeat...',0
        db      -2,10h
        db      3,14,17h,'                                                    ',0
        db      -1

EVEN
ccycvals        dw      606h
ccycdeltas      dw      0ffffh
c0cycrout       dw      c0cycr0
c1cycrout       dw      c1cycr0
c0cycdelay      dw      720
c1cycdelay      dw      360
c0cycwait       db      CCYCWAIT
c1cycwait       db      CCYCWAIT

textrout        dw      txtdelay
textwait        dw      200
textptr         dw      text
textcharloc     dw      ?
textchar        db      ?
textattr        db      ?
textloc         dw      ?
textbltloc      dw      ?

textbltmap      db      82h,9,44h,50h,24h,9,90h,42h, 82h,9,44h,50h,24h,9,90h

;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
; CODE
;ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
nirq1:                                  ; Program KB handler
        push ax
        in al,60h
        cmp al,1
        jne short nirq1f0
        mov cs:doneflag,al
nirq1f0:
        mov al,20h
        out 20h,al
        pop ax
;       jmp dword ptr cs:oirq1
        iret

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
vidmemm0:                               ; Vidmem mode 0 (character bitmap dat)
        mov dx,3c4h
	mov ax,00402h
        out dx,ax
        mov ax,00604h
        out dx,ax
        mov dx,3ceh
	mov ax,00005h
        out dx,ax
        mov ax,00c06h
        out dx,ax
        mov ax,00204h
        out dx,ax
        ret
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
vidmemm1:                               ; Vidmem mode 1 (screen character dat)
        mov dx,3c4h
        mov ax,00302h
        out dx,ax
        mov ax,00204h
        out dx,ax
        mov dx,3ceh
        mov ax,01005h
        out dx,ax
        mov ax,00e06h
        out dx,ax
        mov ax,00004h
        out dx,ax
        ret

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
start:                                  ; Program starts here
        cld
        mov ax,cs
        mov ds,ax

        xor bx,bx                       ; Chek for VGA
        mov ax,01a00h
        int 10h
        cmp bl,7
        jae short startf0
exiterr0:
        mov dx,offset errmsg0
exiterr:
        mov ah,9
        int 21h
        mov ax,4cffh
        int 21h
startf0:
        cmp bl,0ch
        ja short exiterr0

        mov ax,word ptr es:[2]          ; Chek for memory
        sub ax,buf
        cmp ax,NRF*4bh
        mov dx,offset errmsg1
        jb exiterr

        mov ax,3                        ; Text mode 3
        int 10h

        call calcbuf                    ; Calculate raster bar buffers

        in al,21h                       ; Mask off ALL IRQs except 1
        mov oirqm[0],al
        mov al,0fdh
        out 21h,al
        in al,0a1h
        mov oirqm[1],al
        mov al,0ffh
        out 0a1h,al

        mov ax,3509h                    ; Set new keyboard handler
        int 21h
        mov oirq1[0],bx
        mov oirq1[2],es
        mov dx,offset nirq1
        mov ax,2509h
        int 21h

        mov ax,cs                       ; Set character set for ren logo
        mov es,ax
        mov bp,offset charmap
        mov ax,1100h
        mov bx,1000h
        mov cx,14
        mov dx,182
        int 10h

;-----------------------------------------------------------------------------
                                        ; Prepare for main part
        mov ax,0b800h                   ; Clear screen
        mov es,ax
        xor di,di
        mov cx,4000h
        mov ax,1020h
        rep stosw

        mov ah,1eh                      ; Put renaissance logo
        mov si,offset renlogo
        mov di,8232
        mov dl,3
startl0:
        mov cx,33
startl1:
        lodsb
        mov bp,offset rlltbl
startl2:
        mov bx,ds:[bp]
        add bp,2
        mov es:[di+bx],ax
        cmp bx,5120-80
        jne startl2
        stosw
        loop startl1
        add di,254
        dec dl
        jnz startl0

        mov dx,3dah                     ; Set PEL resetting on line compare
        in al,dx
        mov dx,3c0h
        mov al,30h
        out dx,al
        mov al,2ch
        out dx,al

        mov dx,3d4h                     ; Set up for line compare split
        mov ax,0e11h
        out dx,ax
        mov ax,0f09h
        out dx,ax
        mov ax,1f07h
        out dx,ax
        mov ax,5013h                    ; Set double screen width
        out dx,ax
        mov ax,800eh                    ; Hide cursor
        out dx,ax

        mov ax,buf                      ; Set ptr to raster bar buffer

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
mainloop0:                              ; Set raster bar buffer ptr
        add ax,4bh
        cmp ax,buf+(NRF*4bh)
        jb short mainloop
        mov ax,buf

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
mainloop:                               ; Main loop
        mov es,ax

        mov dx,3dah                     ; Wait for negative vertical retrace
        in al,dx
        test al,8
        jnz $-3

        db 0b8h                         ; Do upper part flying around on X
upxl    dw 0
        add al,ah
        cmp al,112
        ja short mainloopf4
        inc ah
        jmp short mainloopf5
mainloopf4:
        dec ah
mainloopf5:
        mov upxl,ax
; xflipv  dw 9090h
        xor ah,ah
        xor dx,dx
        mov bx,9
        div bx
        mov cx,ax
        mov bl,dl
        mov ah,xofftbl[bx]
        mov al,33h
        mov dx,3c0h
        out dx,al
        mov al,ah
        out dx,al

        db 0b8h                         ; Do upper part flying around on Y
upyl    dw 0
        add ah,al
        cmp ah,96
        ja short mainloopf2
        inc al
        jmp short mainloopf3
mainloopf2:
        dec al
mainloopf3:
        mov upyl,ax
; yflipv  db 90h,90h,90h,90h,90h
        mov bl,ah
        and bl,0f0h
        and ax,0f00h
        mov al,8
        mov dx,3d4h
        out dx,ax
        mov al,10
        mul bl
        add cx,ax
        add cx,2000
        mov al,0ch
        mov ah,ch
        out dx,ax
        inc al
        mov ah,cl
        out dx,ax

        db 0b8h
lcsl    dw 1                            ; Do line compare bobbing
        add ah,al
        jz short mainloopf0
        cmp ah,48
        jne short mainloopf1
mainloopf0:
        neg al
mainloopf1:
        mov lcsl,ax
        mov al,18h
        out dx,ax

;       xor xflipv,6fa4h                ; Do screen flip xors
;       xor word ptr yflipv[0],7c10h
;       xor word ptr yflipv[2],6640h
;       xor byte ptr yflipv[4],4ch

        call textrout                   ; Do text on lower part of screen

        call c0cycrout                  ; Phade bars in and out
        call c1cycrout

        mov bx,400                      ; Prepare for loop
        xor si,si
        mov al,byte ptr lcsl[1]
        mov ah,1
        mov di,400
        sub di,ax
        mov cx,ccycvals

        mov dx,3dah                     ; Wait for vertical retrace
        in al,dx
        test al,8
        jz $-3

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
mainloop2:                              ; Secondary main loop
        mov dx,3c8h                     ; Prepare color write
        mov al,1
        out dx,al
        inc dx

        cmp bx,di                       ; Special routine maybe
        je short mainloop2s

        lods byte ptr es:[si]
        xchg cl,ch
        shr al,cl
        xchg cl,ch
        out dx,al
        lods byte ptr es:[si]
        out dx,al

        mov dx,3dah                     ; Wait for display interval
        in al,dx
        test al,1
        jnz short $-3
        in al,dx                        ; Wait for horizontal retrace
        test al,1
        jz short $-3

        mov dx,3c9h                     ; Set last byte of color
        lods byte ptr es:[si]
        shr al,cl
        out dx,al

mainloop2c:
        dec bx
        jnz mainloop2

        cmp doneflag,1                  ; Done?
        je short done

        mov ax,es                       ; Increment buffer ptr
        jmp mainloop0

;-----------------------------------------------------------------------------
mainloop2s:                             ; Special split loc routine
        mov al,3fh
        out dx,al
        out dx,al

        mov dx,3dah                     ; Wait for display interval
        in al,dx
        test al,1
        jnz short $-3
        in al,dx                        ; Wait for horizontal retrace
        test al,1
        jz short $-3

        mov dx,3c9h                     ; Set last byte of special color
        mov al,3fh
        out dx,al

        add cx,101h
        jmp mainloop2c

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
done:                                   ; Program done
        mov al,oirqm[0]                 ; Reset IRQ masks
        out 21h,al
        mov al,oirqm[1]
        out 0a1h,al
        lds dx,dword ptr oirq1          ; Reset keyboard vektor
        mov ax,2509h
        int 21h
        mov ax,3                        ; Text mode 3
        int 10h
        mov ax,4c00h                    ; Quit to DOS
        int 21h

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
c0cycr0:                                ; Cycle blue bar delay
        dec c0cycdelay
        jz short c0cycr0f0
        ret
c0cycr0f0:
        mov c0cycrout,offset c0cycr1
__ret:
        ret
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
c0cycr1:                                ; Cycle blue bar change
        dec c0cycwait
        jnz __ret
        mov c0cycwait,CCYCWAIT
        mov ax,ccycvals
        mov bx,ccycdeltas
        add al,bl
        jz short c0cycr1f0
        cmp al,6
        jnz short c0cycr1f1
c0cycr1f0:
        neg bl
        mov c0cycdelay,720
        mov c0cycrout,offset c0cycr0
c0cycr1f1:
        mov ccycvals,ax
        mov ccycdeltas,bx
        ret

;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
c1cycr0:                                ; Cycle red bar delay
        dec c1cycdelay
        jz short c1cycr0f0
        ret
c1cycr0f0:
        mov c1cycrout,offset c1cycr1
        ret
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
c1cycr1:                                ; Cycle blue bar change
        dec c1cycwait
        jnz __ret
        mov c1cycwait,CCYCWAIT
        mov ax,ccycvals
        mov bx,ccycdeltas
        add ah,bh
        jz short c1cycr1f0
        cmp ah,6
        jnz short c1cycr1f1
c1cycr1f0:
        neg bh
        mov c1cycdelay,720
        mov c1cycrout,offset c1cycr0
c1cycr1f1:
        mov ccycvals,ax
        mov ccycdeltas,bx
        ret

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
txtdelay:                               ; Text delay routine
        dec textwait
        je short txtnext
        ret

;-----------------------------------------------------------------------------
txtsetdelay:                            ; Delay command in text
        mov al,ah
        xor ah,ah
        shl ax,1
        shl ax,1
        mov textwait,ax
        mov textrout,offset txtdelay
        mov textptr,si
        ret
;-----------------------------------------------------------------------------
txtreset:                               ; Reset text pointer
        mov textptr,offset text
;-----------------------------------------------------------------------------
txtnext:                                ; Get next text command
        mov si,textptr
        lodsw
        cmp al,-2
        je short txtsetdelay
        ja short txtreset
        mov bl,ah
        xor bh,bh
        shl bx,1
        xor ah,ah
        mov cx,320
        mul cx
        add ax,bx
        mov textloc,ax
        lodsb
        mov textattr,al
        mov textptr,si
        mov textrout,offset txtputr1
        ret

;-----------------------------------------------------------------------------
txtputr0:                               ; Replace old char with 7fh and attr
        push es
        mov ax,0b800h
        mov es,ax
        mov bx,textloc
        mov al,es:[bx]
        xor ah,ah
        mov cl,5
        shl ax,cl
        mov si,ax
        mov di,0fe0h
        call vidmemm0
        mov cx,10h
        db 26h
        rep movsw
        call vidmemm1
        mov al,7fh
        mov ah,textattr
        mov es:[bx],ax
        pop es
        ret
;-----------------------------------------------------------------------------
txtputr1:                               ; Start character bitblt routine
        mov si,textptr
        lodsb
        mov textptr,si
        or al,al
        jnz short txtputr1f0
        mov textrout,offset txtnext
        ret
txtputr1f0:
        mov textchar,al
        xor ah,ah
        mov cl,5
        shl ax,cl
        mov textcharloc,ax
        mov textrout,offset txtputr2
        mov textbltloc,8
        jmp txtputr0
;-----------------------------------------------------------------------------
txtputr2:
        push es
        mov ax,0b800h
        mov es,ax
        call vidmemm0
        mov si,textcharloc
        mov di,0fe0h
        mov bx,textbltloc
        mov bp,0fh
txtputr2l0:
        mov ah,textbltmap[bx]
        mov al,es:[si+bp]
        mov dl,es:[di+bp]
        and al,ah
        not ah
        and dl,ah
        not ah
        or al,dl
        mov es:[di+bp],al
        inc bx
        sub bp,1
        jnc txtputr2l0
        call vidmemm1
        sub textbltloc,1
        jnc short txtputr2d
        mov textrout,offset txtputr1
        mov bx,textloc
        mov al,textchar
        mov es:[bx],al
        add bx,2
        mov textloc,bx
txtputr2d:
        pop es
        ret

;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
; Calculate raster bar buffers
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
calcbuf:
        sub sp,16

        mov bx,buf                      ; Clear each frame
        xor ax,ax
        mov dx,NRF
calcbufl0:
        mov es,bx
        xor di,di
        mov cx,600
        rep stosw
        add bx,4bh
        dec dx
        jnz calcbufl0

        mov bp,sp                       ; Draw red moving bars
        mov si,offset bardata
calcbufl1:
        mov ax,ss
        mov es,ax
        lodsw
        or ax,ax
        jz calcbufl1d
        mov di,bp
        mov cx,8
        rep movsw
        mov cx,ax
        push si
        call calcbufr0
        pop si
        jmp calcbufl1
calcbufl1d:

        mov word ptr [bp],8             ; Do blue perspective bars
        mov word ptr [bp+2],buf
calcbufl2:
        mov word ptr [bp+4],7
calcbufl3:
        mov ax,9
        mul word ptr [bp+4]
        add ax,[bp]
        mov si,ax
        shl si,1
        shl si,1
        add si,90
        mov cl,3
        shr ax,cl
        shl ax,1
        mov bx,ax

        mov ax,-90*193
        cwd
        idiv si
        add ax,200
        mov di,ax
        shl ax,1
        add di,ax
        call calcbufr2

        mov ax,90*192
        cwd
        idiv si
        add ax,200
        mov di,ax
        shl ax,1
        add di,ax
        call calcbufr2

        sub word ptr [bp+4],1
        jnc calcbufl3
        add word ptr [bp+2],4bh
        sub word ptr [bp],1
        jnc calcbufl2

        add sp,16
_ret:
        ret
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
calcbufr0:                              ; Calculate a bar across all frames
        xor di,di                       ; Set starting pointers
        xor si,si
        mov dx,buf
calcbufr0l0:                            ; Calculate back CX frames
        call calcbufr1
        loop calcbufr0l0
        mov bx,NRF                      ; Draw bars
calcbufr0l1:
        push di
        mov es,dx
        xor al,al
        mov cx,8
calcbufr0l2:
        stosb
        add di,2
        call [bp+0]
        stosb
        add di,2
        call [bp+2]
        stosb
        add di,2
        call [bp+4]
        stosb
        add di,2
        call [bp+6]
        loop calcbufr0l2
        mov cx,8
calcbufr0l3:
        call [bp+14]
        stosb
        add di,2
        call [bp+12]
        stosb
        add di,2
        call [bp+10]
        stosb
        add di,2
        call [bp+8]
        stosb
        add di,2
        loop calcbufr0l3
        pop di
        call calcbufr1
        add dx,4bh
        dec bx
        jnz calcbufr0l1
        ret
;-----------------------------------------------------------------------------
calcbufr1:                              ; Move bar one unit
        add di,si
        cmp di,170*3
        ja short calcbufr1f0
        add si,3
        jmp calcbufr1f1
calcbufr1f0:
        sub si,3
calcbufr1f1:
        ret
;-----------------------------------------------------------------------------
calcbufcar1:                            ; Color Add Routine 1
        inc al
        ret
;-----------------------------------------------------------------------------
calcbufcar2:                            ; Color Add Routine 2
        add al,2
        ret
;-----------------------------------------------------------------------------
calcbufcsr1:                            ; Color Sub Routine 1
        dec al
        ret
;-----------------------------------------------------------------------------
calcbufcsr2:                            ; Color Sub Routine 2
        sub al,2
        ret
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
calcbufr2:                              ; Draw a blue bar
        mov dx,[bp+2]
        mov cx,8
        xor ax,ax
calcbufr2l0:
        mov ds,dx
        add dx,2a3h
        call cs:pbarf[bx]
        loop calcbufr2l0
        mov ax,cs
        mov ds,ax
        ret
;-----------------------------------------------------------------------------
pbarr0:
        mov byte ptr [di-19],07h
        mov byte ptr [di+23],07h
;-----------------------------------------------------------------------------
pbarr1:
        mov byte ptr [di-16],0fh
        mov byte ptr [di+20],0fh
;-----------------------------------------------------------------------------
pbarr2:
        mov byte ptr [di-13],17h
        mov byte ptr [di+17],17h
;-----------------------------------------------------------------------------
pbarr3:
        mov byte ptr [di-10],1fh
        mov byte ptr [di+14],1fh
;-----------------------------------------------------------------------------
pbarr4:
        mov byte ptr [di-7],27h
        mov byte ptr [di+11],27h
;-----------------------------------------------------------------------------
pbarr5:
        mov byte ptr [di-4],2fh
        mov byte ptr [di+8],2fh
;-----------------------------------------------------------------------------
pbarr6:
        mov byte ptr [di-1],37h
        mov byte ptr [di+5],37h
;-----------------------------------------------------------------------------
pbarr7:
        mov byte ptr [di+2],3fh
        ret


code    ends
buf     segment para
buf     ends
        end start

