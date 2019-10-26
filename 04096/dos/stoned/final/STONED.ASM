;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Assembly 1994 4KB Intro Competition Winner 'STONED' Sourcecode
; Copyright (C) 1994, 1995 by Markus Stein alias Stone/Dust
; Contact: steinm@olymp.informatik.uni-bonn.de
;
; For further comments on the sourcecode read 'STONED.DOC' which should have
; come along with this file.
;
; Remember to give credits to me if you should use any of this.
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

code    segment
        assume cs:code,ds:code
        org 100h
        locals
        .386
;-----------------------------------------------------------------------------

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Main Program
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

;NOTE: MUCH better would have been to have HIMEM.SYS allocate free memory
;      instead of using a constant. If booted clean, all memory above 100000h
;      can be assumed as being free, so this constant works OK for that.
HIMEMSTART  equ 130000h           ;start address of free memory above 1MB
HIMEMNEED   equ 2496              ;amount of himem that will be used (in KB)
;-----------------------------------------------------------------------------

;ESCENABLE   equ 1                ;enable/disable ESC key to break execution
;-----------------------------------------------------------------------------

;NOTE: These first few lines have to stay exactly the same in order to have
;      the .COM-file postprocessor work correctly. It reads offsets and data
;      size from here
START:  cld                       ;clear direction flag
        mov di,offset zero_data_start
        mov cx,offset zero_data_end - zero_data_start
        push ds
        pop es
        xor al,al
        rep stosb                 ;init zeroed data (s. postprocessor)

        pushf                     ;386 processor check
        pop bx
        mov dx,bx
        xor dh,0f0h
        push dx
        popf
        pushf
        pop dx
        cmp bx,dx
        je exit
        .386p                     ;test v8086 mode
        smsw ax
        .386
        test ax,1
        jnz exit
        mov ax,4300h              ;himem driver installed?
        int 2fh
        cmp al,80h
        je short @@mem1

;NOTE: The A20 line can be assumed enabled if a himem driver has been
;      detected. If booted clean, it has to be enabled:
        pushf                     ;enable A20 line ('inspired' from HIMEM.SYS)
        cli
        in al,92h
        or al,2
        jmp short $+2
        jmp short $+2
        jmp short $+2
        out 92h,al
        in al,64h
        test al,1
        jz short @@h1
        jmp short $+2
        in al,60h
@@h1:   call a20_wait_short
        jnz short @@h2
        mov al,0d0h
        out 64h,al
        call a20_wait_short
        jnz short @@h2
        mov cx,0ch
@@h3:   push cx
        xor cx,cx
@@h5:   jmp short $+2
        in al,64h
        test al,1
        loopz @@h5
        pop cx
        loopz @@h3
        jz short @@h2
        in al,60h
        mov ah,0ch
        and ah,al
        or ah,0d3h
        jmp short @@h4
@@h2:   mov ah,0dfh
        call a20_wait_short
        jnz short @@h6
@@h4:   mov al,0d1h
        out 64h,al
        call a20_wait_short
        jnz short @@h6
        mov al,ah
        out 60h,al
        call a20_wait_short
@@h6:   popf

;NOTE: This assumes that there are 448kb of free base memory right after the
;      .COM file (dirty!). That's why it needs 512kb base memory altogether.
;      It may run with less but probably crash afterwards
@@mem1: mov ax,cs                 ;limit code size to 64kb
        add ax,4096
        mov seggfx,ax             ;64kb virtual screen
        add ax,4096
        mov segtube,ax            ;128kb for tube graphics
        add ax,8192
        mov segcode,ax            ;256kb for tube displaying code

        mov di,offset rotate_zoom_inner_loop
        mov eax,0868a6765h        ;create rotate-zoom inner loop
        mov ebx,0a68a6765h
        mov dx,24
        mov cx,68
@@rz1:  mov [di],eax
        mov [di]+8,ebx
        mov [di]+16,dword ptr 010e0c166h
        mov [di]+20,eax
        mov [di]+28,ebx
        mov [di]+36,dword ptr 000858966h
        mov [di]+39,dx
        add dx,4
        add di,41
        loop @@rz1
        mov [di],byte ptr 0c3h

        mov ax,3                  ;show 'compo delayed' message
        int 10h
        mov ah,2
        xor bh,bh
        mov dx,0c17h
        int 10h
        mov ah,9
        mov dx,offset delayed
        int 21h
        mov dx,3d4h               ;cursor off
        mov al,0ah
        out dx,al
        inc dx
        in al,dx
        or al,32
        out dx,al
                                  ;call initialization code
        call setup_frm            ;setup 'flat real mode'
        call keyboardirqset
        call vblankirqon
                                  ;precalulations
        call generate_taylor_sinetab
        call mandelbrot
        call tube_init
        call water_init

        mov ax,13h                ;it's all in MCGA 320*200*256 at 70Hz
        int 10h

        call zoom_text            ;1st part: zooming text
        mov retrace,0
@@wait1:cmp retrace,30
        jne @@wait1

        call init_palette1        ;2nd part: rotating & zooming mandelbrot
        mov partlength,0
        mov rz_firstrow,99         ;NOTE: each part has it's own timer routine
        mov timerjump+1,offset timermode2-offset timerjump-3
@@frac: call rotate_zoom
        cmp rz_firstrow,16         ;scroll the screen
        je short @@frac3
        dec rz_firstrow
@@frac3:
    ifdef ESCENABLE
        cmp ESChit,1
        je short @@frac2
    endif
        cmp partlength,2545        ;measure time the part is running
        jbe short @@frac
@@frac2:mov timerjump+1,offset timermodeend-offset timerjump-3
        call clear_screen
    ifdef ESCENABLE
        mov byte ptr ESChit,0
    endif

        call init_palette2
        call tube_show            ;3rd part: plasma tube
    ifdef ESCENABLE
        mov byte ptr ESChit,0
    endif

        call init_palette1        ;4th part: water drops
        call water_show

        call vblankirqoff         ;de-initialization code
        call keyboardirqclear
        inc word ptr frmgdtblock+38
        call leave_frm            ;back to 'real mode'

EXIT:   mov ax,3                  ;textmode
        int 10h
        mov ah,4ch                ;and back to DOS
        int 21h
;-----------------------------------------------------------------------------

A20_WAIT_SHORT proc               ;subroutine to clear the A20 line; just to
        xor cx,cx                 ;make the code smaller (used quite often)
@@22:   jmp short $+2
        in al,64h
        and al,2
        loopnz @@22
        ret
A20_WAIT_SHORT endp
;-----------------------------------------------------------------------------

DELAYED      db "The PC 4KB-Intro Compo is delayed!$"
;-----------------------------------------------------------------------------

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Effects Code (Precalculations, Initialization and Run-Time-Code)
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Water Initialization
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

WATERMEM1    equ himemstart+200000h ;abs. start of maps for 1st drop
WATERMEM2    equ watermem1+20000h   ;                       2nd
;-----------------------------------------------------------------------------

WATER_LOOP1 label                  ;water inner loop 1st drop
        movzx bx,byte ptr gs:[ecx+edi]
        mov bh,byte ptr ds:watersine1+[bx]
        mov bl,byte ptr gs:[ebp+edi]
        movsx edx,word ptr ds:watermove+[bx]
        mov al,fs:[edi+edx]
        stosb
WATER_LOOP_LENGTH1 equ $-offset water_loop1
WATER_LOOP2 label                  ;water inner loop 2nd drop
        movzx bx,byte ptr gs:[ecx+edi]
        mov bh,byte ptr ds:watersine2+[bx]
        mov bl,byte ptr gs:[ebp+edi]
        movsx edx,word ptr ds:watermove+[bx]
        mov al,fs:[edi+edx]
        stosb
WATER_LOOP_LENGTH2 equ $-offset water_loop2
;-----------------------------------------------------------------------------

WATER_INIT proc
        mov edi,watermem1         ;generate one map containing radius and
        xor esi,esi               ;one containing distance from the middle
        mov ebp,8000h             ;of the drop
        xor cx,cx
@@01:   xor bx,bx
@@02:   mov eax,ebp
        imul dword ptr cosinetab+[bx]
        neg dx
        add dx,70
        cmp dx,16
        jl short @@04
        cmp dx,200-16
        jg short @@04
        imul si,dx,320
        mov eax,ebp
        imul dword ptr sinetab+[bx]
        add dx,100
        cmp dx,32
        jl short @@04
        cmp dx,320-32
        jg short @@04
        add si,dx
        mov ax,bx
        shr ax,7
        shl ax,1
        mov gs:[edi][esi]+10000h,al ;distance
        mov gs:[edi][esi],cl        ;angle
@@04:   add bx,4
        cmp bx,4096*4
        jne @@02
        add ebp,10000h
        inc cx
        cmp cx,256
        jne @@01

        mov di,offset watermove   ;refraction for each angle and direction
        mov ebp,-110000h
        mov ch,33
@@05:   xor bx,bx
        mov cl,128
@@03:   mov eax,ebp
        imul dword ptr cosinetab+[bx]
        imul si,dx,320
        mov eax,ebp
        imul dword ptr sinetab+[bx]
        add si,dx
        mov [di],si
        add di,2
        add bx,128
        dec cl
        jnz @@03
        add ebp,10000h
        dec ch
        jnz short @@05
                                  ;make inner loop 1 for water effect
        mov di,offset water_inner_loop1
        mov dx,256
        push cs
        pop es
@@06:   mov si,offset water_loop1
        mov cx,water_loop_length1
        rep movsb
        dec dx
        jnz short @@06
        mov [di],byte ptr 0c3h
                                  ;make inner loop 2 for water effect
        mov di,offset water_inner_loop2
        mov dx,256
        push cs
        pop es
@@08:   mov si,offset water_loop2
        mov cx,water_loop_length2
        rep movsb
        dec dx
        jnz short @@08
        mov [di],byte ptr 0c3h

        push cs                   ;init ripples
        pop es
        mov di,offset watersine1
        mov cx,512
        mov al,17
        rep stosb

        mov cx,64000              ;generate map for 2nd water drop
        mov esi,watermem1
        mov edi,watermem2+63999
@@07:   mov al,gs:[esi]
        mov gs:[edi],al
        mov al,gs:[esi]+10000h
        add al,128
        and al,254
        mov gs:[edi]+10000h,al
        inc esi
        dec edi
        loop @@07
        ret
WATER_INIT endp
;-----------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Water Effect
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

WATER_TEXT  db "Greetings to everyone at ASM'94",0
;-----------------------------------------------------------------------------

WATER_SHOW proc
        mov retrace,0

        mov fs,seggfx             ;copy part of fractal to seggfx
        mov es,segtube
        xor di,di
        mov esi,himemstart+520*1024+420
@@02:   mov cx,160
@@01:   mov ax,gs:[esi]
        mov fs:[di],ax
        mov es:[di],ax
        add esi,2
        add di,2
        loop @@01
        add esi,1024-320
        cmp di,64000
        jne @@02

        mov bx,offset water_text  ;write the text in the middle of the screen
        mov ax,1130h
        push bx
        mov bh,6
        int 10h
        pop bx
        mov di,320*84+36
@@16:   movzx si,byte ptr [bx]
        or si,si
        jz short @@19
        shl si,4
        add si,bp
        mov ch,16
@@17:   mov al,es:[si]
        mov cl,8
@@18:   shl al,1
        jnc short @@15
        mov fs:[di],byte ptr 80h
        mov fs:[di]+320,byte ptr 80h
@@15:   inc di
        dec cl
        jnz @@18
        inc si
        add di,632
        dec ch
        jnz @@17
        sub di,10232
        inc bx
        jmp short @@16

@@19:   mov partlength,0          ;drop upper left
        mov waterdrop1+6,250
@@07:   mov fs,seggfx
        mov ax,0a000h
        mov es,ax
        call @@water_display_1st
@@08:   cmp retrace,0
        je short @@08
@@09:   call @@water_1st
        dec retrace
        jnz short @@09
    ifdef ESCENABLE
        cmp ESChit,1
        je @@water_leave
    endif
        cmp partlength,800
        jbe short @@07

        mov partlength,0          ;drop lower right
        mov waterdrop2+6,20
@@11:   mov fs,seggfx
        mov ax,0a000h
        mov es,ax
        call @@water_display_2nd
@@12:   cmp retrace,0
        je short @@12
@@13:   call @@water_2nd
        dec retrace
        jnz short @@13
    ifdef ESCENABLE
        cmp ESChit,1
        je short @@water_leave
    endif
        cmp partlength,600
        jbe short @@11

        mov partlength,0          ;both drops together
        mov waterdrop1+6,1
        mov waterdrop2+6,50
@@14:   mov fs,seggfx
        mov es,segtube
        call @@water_display_1st
        mov fs,segtube
        mov ax,0a000h
        mov es,ax
        call @@water_display_2nd
@@06:   cmp retrace,0             ;aligned to maximum speed of full framerate
        je short @@06
        call @@water_1st
        call @@water_2nd
    ifdef ESCENABLE
        cmp ESChit,1
        je short @@water_leave
    endif
        cmp partlength,1450
        jbe short @@14

@@WATER_LEAVE:
        ret

@@WATER_DISPLAY_1ST:
        mov ecx,watermem1         ;show upper left drop
        mov ebp,watermem1+10000h
        mov ah,168
        mov edi,320*16+32
@@water_display_1st1:
        call water_inner_loop1
        add di,64
        dec ah
        jnz short @@water_display_1st1
        ret

@@WATER_DISPLAY_2ND:
        mov ecx,watermem2         ;show lower right drop
        mov ebp,watermem2+10000h
        mov ah,168
        mov edi,320*16+32
@@water_display_2nd1:
        call water_inner_loop2
        add di,64
        dec ah
        jnz short @@water_display_2nd1
        ret

@@WATER_1ST:
        cmp waterdrop1+6,0        ;animate upper left (1st) drop
        je short @@water_1st1
        dec waterdrop1+6
        jnz short @@water_1st2
        mov waterdrop1+2,15
        jmp short @@water_1st2
@@water_1st1:
        mov si,offset watersine1+254
        mov di,offset watersine1+255
        mov cx,255
        push cs
        pop es
        std
        rep movsb
        cld
        mov eax,dword ptr waterdrop1
        mov bx,waterdrop1+4
        imul dword ptr sinetab+[bx]
        add dl,17
        mov watersine1,dl
        add waterdrop1+4,640
        and waterdrop1+4,4*4095
        cmp dword ptr waterdrop1,0
        jz short @@water_1st2
        sub dword ptr waterdrop1,1000h
@@water_1st2:
        ret

@@WATER_2ND:
        cmp waterdrop2+6,0        ;animate lower right (2nd) drop
        je short @@water_2nd1
        dec waterdrop2+6
        jnz short @@water_2nd2
        mov waterdrop2+2,15
        jmp short @@water_2nd2
@@water_2nd1:
        mov si,offset watersine2+254
        mov di,offset watersine2+255
        mov cx,255
        push cs
        pop es
        std
        rep movsb
        cld
        mov eax,dword ptr waterdrop2
        mov bx,waterdrop2+4
        imul dword ptr sinetab+[bx]
        add dl,17
        mov watersine2,dl
        add waterdrop2+4,640
        and waterdrop2+4,4*4095
        cmp dword ptr waterdrop2,0
        jz short @@water_2nd2
        sub dword ptr waterdrop2,1400h
@@water_2nd2:
        ret
WATER_SHOW endp
;-----------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Tube Initialization
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

RINGMAX      equ 125
RADOFFS      dw offset radien
;-----------------------------------------------------------------------------

TUBE_INIT proc
        call clear_seggfx         ;generates displaying routines for tube
        mov fs,segcode
        xor si,si
        mov ebp,8000h
@@01:   mov bx,si
        shr bx,4
        mov ax,fs
        add ax,bx
        mov fs,ax
        and si,0000fh
        mov bx,radoffs            ;jump-in addresses
        mov [bx],si
        mov [bx]+2,fs
        add radoffs,4
        xor bx,bx
        mov cl,7fh
        mov fs:[si],dword ptr 0d28ed38ch ;mov bx,ss & mov ss,dx
        add si,4
@@02:   mov eax,ebp               ;draw circles
        imul dword ptr cosinetab+[bx]
        neg dx
        add dx,100
        cmp dx,21-9               ;watch border
        jl short @@04
        cmp dx,179+10
        jg short @@04
        imul di,dx,320
        sub di,32000
        mov eax,ebp
        imul dword ptr sinetab+[bx]
        cmp dx,52-160
        jl short @@04
        cmp dx,268-160
        jg short @@04
        add di,dx                 ;use a screen koordinate only once
        cmp es:[di]+32160,byte ptr 0
        jne short @@04
        mov ax,bx
        shr ax,6
        sub al,80h
        cmp al,cl
        je short @@03
        mov cl,al
        mov fs:[si],word ptr 0448ah    ;mov al,[si]+byte ptr offset
        mov fs:[si]+2,cl
        mov fs:[si]+3,word ptr 0c42ah  ;sub al,ah
        add si,5
@@03:   mov fs:[si],word ptr 08688h    ;mov ss:[bp]+word ptr offset,al
        mov fs:[si]+2,di
        add si,4                  ;mark position as already used
        mov es:[di]+32160,byte ptr 1
@@04:   add bx,4*2
        cmp bx,4096*4
        jne @@02
        mov fs:[si],dword ptr 0cbd38eh ;mov ss,bx & retf
        add si,3
        add ebp,10000h
        cmp ebp,ringmax*10000h+8000h
        jne @@01

        mov di,offset tubepers+2  ;calculate tube camera view
        mov ebx,10000h*1
@@00:   mov ebp,ebx
        add ebp,10000h*20
        mov eax,ebx
        mov cx,25
        call @@tubeopt1
        mov ebp,10000h*442
        mov cx,8
        call @@tubeopt1
        mov [di],ax
        add ebx,10000h
        add di,2
        cmp di,offset tubepers+ringmax*2
        jnz short @@00

        mov di,offset tubecols+48 ;calculate tube lighting
        xor ax,ax
        mov bx,20h
@@07:   mov [di],ah
        add ax,bx
        add bx,8
        inc di
        cmp di,offset tubecols+ringmax
        jne @@07

        call generate_plasma      ;generate circular plasma
        mov es,seggfx             ;move colors to upper 128 colors
        xor si,si
@@06:   shr byte ptr es:[si],1
        add byte ptr es:[si],128
        inc si
        jnz @@06
        mov ax,segtube            ;store as tube graphics
        push ds
        mov ds,seggfx
        xor si,si
@@05:   mov es,ax
        xor di,di
        mov cx,128
        rep movsw
        sub si,256
        mov cx,128
        rep movsw
        add ax,32
        or si,si
        jnz short @@05
        pop ds

        mov tsinX+10,59
        mov tsinY+10,62
        ret

@@TUBEOPT1:
        xor edx,edx               ;used to make camera view calc code smaller
@@tubeopt11:
        shl eax,1
        rcl edx,1
        loop short @@tubeopt11
        idiv ebp
        ret

TUBE_INIT endp
;-----------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Tube Effect
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

TSTARTX    dw 160                 ;position of tube's ì on screen X
TSTARTY    dw 100                 ;                               Y
;-----------------------------------------------------------------------------

TUBE_SHOW proc
        mov si,128
        mov retrace,0

@@t06:  mov eax,dword ptr tstartX ;start values
        mov dword ptr tposX,eax
        mov word ptr @@tl00+3,offset radien
        mov word ptr @@tl01+3,offset tubecols+ringmax-1
        xor di,di

@@t02:  mov cx,twobbX+[di]        ;wobble X        ;main displaying routine
        mov ax,1
        or cx,cx
        jns short @@t00
        neg cx
        neg ax
@@t00:  mov tmoveX,ax
        mov dx,twobbY+[di]        ;wobble Y
        mov ax,1
        or dx,dx
        jns short @@t01
        neg dx
        neg ax
@@t01:  mov tmoveY,ax
@@t03:  imul bp,tposY,320         ;display a piece of tube; consists of several
        add bp,tposX               ;rings with the same size & texture
        mov ax,tubezpos
        add ax,tubepers+[di]
        and ax,1feh
        shl ax,4
        add ax,segtube
        push dx
        mov dx,seggfx
        push ds
        mov ds,ax
@@tl01  label
        mov ah,cs:tubecols
@@tl00  label
        call dword ptr cs:radien
        pop ds
        pop dx
        mov ax,cx
        cmp ax,dx
        jae short @@t05
        or dx,dx
        jz short @@t04
        dec dx
        mov ax,tmoveY
        add tposY,ax
        jmp short @@t03
@@t05:  or cx,cx
        jz short @@t04
        dec cx
        mov ax,tmoveX
        add tposX,ax
        jmp short @@t03
@@t04:  add di,2
        dec word ptr @@tl01+3
        add @@tl00+3,4
        cmp @@tl00+3,offset radien+ringmax*4
        jne @@t02

@@t08:  cmp retrace,0             ;maximum speed is at maximum frame rate
        je short @@t08

        push si                   ;copy tube to screen
        push ds
        mov ax,0a000h
        mov es,ax
        mov ds,seggfx
        mov ah,151
        mov esi,66+25*320
@@00:   mov edi,esi
        mov cx,47
        rep movsd
        add esi,132
        dec ah
        jnz @@00
        pop ds
        pop si

@@t11:  sub tubezpos,2            ;zoom into tube
        sub si,128                ;rotate tube
        dec si
        and si,0ffh
        add si,128

        cmp palette2,56           ;fade colors from black to grey in the
        je short @@t07            ;beginning
        inc palette2
        call init_palette2

@@t07:  cmp tubezpos,-256*16      ;exit tube
        jae short @@t10
        cmp tubezpos,-256*16-384
        je @@t09
        mov ax,tubezpos
        and ax,1feh
        shl ax,4
        add ax,segtube
        mov es,ax
        xor di,di
        mov ax,8080h
        mov cx,256
        rep stosw

;NOTE: This part of the code is extremely messy, so don't bother trying to
;      understand it...
@@t10:  push si
        push cs
        pop es                    ;control code wobbling X
        mov ax,twobbX+(ringmax-1)*2
        add tstartX,ax
        mov si,offset twobbX+(ringmax-2)*2
        mov di,offset twobbX+(ringmax-1)*2
        mov cx,ringmax-1
        std
        rep movsw
        cld
        mov ax,tsinX+4
        shl eax,16
        mov ax,8000h
        mov bx,tsinX
        shl bx,2
        imul dword ptr sinetab+[bx]
        mov ax,dx
        sub dx,tsinX+6
        mov tsinX+6,ax
        mov twobbX,dx
        sub tstartX,dx
        mov ax,tsinX+10
        add tsinX,ax
        and tsinX,4095
        cmp tsinX+4,24
        je short @@t12
        add dword ptr tsinX+2,300h
@@t12:  cmp tsinX+10,21
        je short @@t13
        sub dword ptr tsinX+8,480h
                                  ;control code wobbling Y
@@t13:  mov ax,twobbY+(ringmax-1)*2
        add tstartY,ax
        mov si,offset twobbY+(ringmax-2)*2
        mov di,offset twobbY+(ringmax-1)*2
        mov cx,ringmax-1
        std
        rep movsw
        cld
        mov ax,tsinY+4
        shl eax,16
        mov ax,8000h
        mov bx,tsinY
        shl bx,2
        imul dword ptr sinetab+[bx]
        mov ax,dx
        sub dx,tsinY+6
        mov tsinY+6,ax
        mov twobbY,dx
        sub tstartY,dx
        mov ax,tsinY+10
        add tsinY,ax
        and tsinY,4095
        cmp tsinY+4,22
        je short @@t14
        add dword ptr tsinY+2,200h
@@t14:  cmp tsinY+10,11
        je short @@t15
        sub dword ptr tsinY+8,700h

@@t15:  pop si                    ;for all frames since last frame
        dec retrace
        jnz @@t11

    ifdef ESCENABLE
        cmp ESChit,1
        je short @@t09
    endif
        jmp @@t06

@@t09:  call clear_screen
        ret
TUBE_SHOW endp
;-----------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Pseudo random numbers
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

RANDOM proc
        mov eax,cs:random_seed    ;eax = random value [-16384...16383]
        xor eax,1036745819
        add eax,1876389621
        rol eax,7
        mov cs:random_seed,eax
        and eax,32767
        sub eax,16384
        ret
RANDOM endp
;-----------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Plasma Generator (recursive)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

GRAININESS      equ 128           ;plasma graininess (smaller = grainier)
;-----------------------------------------------------------------------------

x1      equ word ptr [bp]+14      ;pointers to local variables on stack
y1      equ word ptr [bp]+12
x2      equ word ptr [bp]+10
y2      equ word ptr [bp]+8
x       equ word ptr [bp]+2
y       equ word ptr [bp]
;-----------------------------------------------------------------------------

GENERATE_PLASMA proc
        call clear_seggfx         ;make plasma (only border is used)
        push ds
        mov ds,seggfx
        call @@1

        push ds                   ;copy border for a circular plasma
        pop es                    ;(that's important!)
        mov si,001*256
        push si
        mov di,255*256
        mov cx,128
        rep movsw
        pop di
        inc di
        xor ax,ax
        mov bh,254
@@0:    mov bl,[di]
        mov [di]+254,bl
        mov cx,127
        rep stosw
        add di,2
        dec bh
        jnz short @@0

        call @@1                  ;make circular plasma
        pop ds
        ret

@@1:    push 0                    ;draw plasma
        push 0
        push 255
        push 255
        call plasma
        add sp,8
        ret
GENERATE_PLASMA endp
;-----------------------------------------------------------------------------

PLASMA proc
        push bp                   ;set up stack frame; local variables
        sub sp,4
        mov bp,sp

        mov ax,x2                 ;if ((x2-x1 > 1) or (y2-y1 > 0)) exit
        sub ax,x1
        cmp ax,1
        ja short @@0
        mov ax,y2
        sub ax,y1
        cmp ax,1
        jbe @@5

@@0:    mov ax,x1                 ;x = (x1+x2) >> 1
        add ax,x2
        shr ax,1
        mov x,ax
        mov ax,y1                 ;y = (y1+y2) >> 1
        add ax,y2
        shr ax,1
        mov y,ax

        push x                    ;if ((s = _get_pixel(x,y1) != 0) then gp_10
        push y1
        call @@get_pixel
        add sp,4
        or ax,ax
        jnz short @@1
        mov dx,x1                 ;s = (random-.5) * 256 * (x1-x) / grain
        sub dx,x
        call @@plasmaopt1
        call @@plasmaoptx1y1      ; + ((_get_pixel(x1,y1)+get_pixel(x2,y1) / 2)
        mov bx,ax
        call @@plasmaoptx2y1
        call @@plasmaopt2
        push x                    ;_set_pixel(x,y1,s)
        push y1
        call @@set_pixel
        add sp,4
@@1:    mov si,ax

        push x2                   ;if ((s = _get_pixel(x2,y) != 0) then gp_20
        push y
        call @@get_pixel
        add sp,4
        or ax,ax
        jnz short @@2
        mov dx,y1                 ;s = (random-.5) * 256 * (y1-y) / grain
        sub dx,y
        call @@plasmaopt1
        call @@plasmaoptx2y1      ; + ((_get_pixel(x2,y1)+get_pixel(x2,y2) / 2)
        mov bx,ax
        call @@plasmaoptx2y2
        call @@plasmaopt2
        push x2                   ;_set_pixel(x2,y,s)
        push y
        call @@set_pixel
        add sp,4
@@2:    add si,ax

        push x                    ;if ((s = _get_pixel(x,y2) != 0) then gp_30
        push y2
        call @@get_pixel
        add sp,4
        or ax,ax
        jnz short @@3
        mov dx,x1                 ;s = (random-.5) * 256 * (x1-x) / grain
        sub dx,x
        call @@plasmaopt1
        call @@plasmaoptx1y2      ; + ((_get_pixel(x1,y2)+get_pixel(x2,y2) / 2)
        mov bx,ax
        call @@plasmaoptx2y2
        call @@plasmaopt2
        push x                    ;_set_pixel(x,y2,s)
        push y2
        call @@set_pixel
        add sp,4
@@3:    add si,ax

        push x1                   ;if ((s = _get_pixel(x1,y) != 0) then gp_40
        push y
        call @@get_pixel
        add sp,4
        or ax,ax
        jnz short @@4
        mov dx,y1                 ;s = (random-.5) * 256 * (y1-y) / grain
        sub dx,y
        call @@plasmaopt1
        call @@plasmaoptx1y1      ; + ((_get_pixel(x1,y1)+get_pixel(x1,y2) / 2)
        mov bx,ax
        call @@plasmaoptx1y2
        call @@plasmaopt2
        push x1                   ;_set_pixel(x1,y,s)
        push y
        call @@set_pixel
        add sp,4
@@4:    add si,ax

        mov ax,si                 ;_set_pixel(x,y, s >> 2)
        shr ax,2
        push x
        push y
        call @@set_pixel
        add sp,4

        push x1                   ;generate_plasma(x1,y1,x,y)
        push y1
        push x
        push y
        call plasma
        add sp,8
        push x                    ;generate_plasma(x,y1,x2,y)
        push y1
        push x2
        push y
        call plasma
        add sp,8
        push x                    ;generate_plasma(x,y,x2,y2)
        push y
        push x2
        push y2
        call plasma
        add sp,8
        push x1                   ;generate_plasma(x1,y,x,y2)
        push y
        push x
        push y2
        call plasma
        add sp,8

@@5:    add sp,4                  ;free stack frame
        pop bp
        ret

@@GET_PIXEL:                      ;ax = pixel at gs:base + (xk, yk)
        push bp
        mov bp,sp
        mov di,[bp]+4
        shl di,8
        add di,[bp]+6
        movzx ax,byte ptr [di]
        pop bp
        ret

@@SET_PIXEL:                      ;pixel at gs:base + (xk, yk) = al
        push bp
        mov bp,sp
        mov di,[bp]+4
        shl di,8
        add di,[bp]+6
        mov [di],al
        pop bp
        ret

@@PLASMAOPT1:
        call random               ;calculate weight of random color
        shr eax,6
        imul dx
        mov bx,graininess
        idiv bx
        mov dx,ax
        ret

@@PLASMAOPT2:
        add bx,ax
        shr bx,1
        add bx,dx
        cmp bx,1                  ;s = [1..255]
        jge short @@plasmaopt21
        mov bx,1
        jmp short @@plasmaopt22
@@plasmaopt21:
        or bh,bh
        jz short @@plasmaopt22
        mov bx,255
@@plasmaopt22:
        mov ax,bx
        ret

@@PLASMAOPTx1y1:
        push x1                   ;four little routines save 5 bytes each
        push y1
        call @@get_pixel
        add sp,4
        ret

@@PLASMAOPTx2y1:
        push x2
        push y1
        call @@get_pixel
        add sp,4
        ret

@@PLASMAOPTx2y2:
        push x2
        push y2
        call @@get_pixel
        add sp,4
        ret

@@PLASMAOPTx1y2:
        push x1
        push y2
        call @@get_pixel
        add sp,4
        ret

PLASMA endp
;-----------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Zooming Text (VGA charset 8*16)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

TEXTS   db  1, 128-19, "Let's"    ;speed, position, text
        db  1, 128-11, "get"
        db  2, 128-12, "S"
        db  2, 128-09, "T"
        db  2, 128-06, "O"
        db  2, 128-03, "N"
        db  2, 128-00, "E"
        db  2, 128+03, "D"
        db  3, 128+06, "!"
        db  0
;-----------------------------------------------------------------------------

ZOOM_TEXT proc
        mov bx,offset texts

@@08:   xor eax,eax               ;clear 1MB virtual "screen"
        mov ecx,262144
        mov edi,himemstart+100000h
@@clrsc:mov gs:[edi],eax
        add edi,4
        dec ecx
        jnz @@clrsc

        mov ax,1130h              ;get address of VGA 8*16 charset
        push bx
        mov bh,6
        int 10h
        pop bx

@@07:   mov al,[bx]               ;set zooming speed
        or al,al
        jz short @@09
        mov mode1+1,al
        inc bx
        movzx edi,byte ptr [bx]   ;draw character by character
@@06:   add edi,516480+himemstart+100000h
@@04:   inc bx
        movzx si,byte ptr [bx]
        cmp si,3
        jbe short @@03
        shl si,4
        add si,bp
        mov ch,16
@@02:   mov al,es:[si]
        mov cl,8
@@01:   shl al,1
        setc gs:[edi]
        inc edi
        dec cl
        jnz @@01
        inc si
        add edi,1016
        dec ch
        jnz @@02
        sub edi,16376
        jmp short @@04

@@03:   push bx
        mov timerjump+1,offset timermode1-offset timerjump-3
        mov eax,10000h
        mov mode1,al
        mov zoom,eax
        mov angle,ax

        call wait_vblank
@@05:   call rotate_zoom
        cmp timerjump+1,offset timermodeend-offset timerjump-3
        jne @@05

        call clear_screen
        pop bx
        jmp @@08

@@09:   ret
ZOOM_TEXT endp
;-----------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Screen Rotator & Zoomer Subroutine
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

RZCENTER     dd himemstart+180200h  ;center of 1024*1024 bitmap
RZ_FIRSTROW  dw 16                  ;first row of displayed area
;-----------------------------------------------------------------------------

ROTATE_ZOOM proc                  ;displays rotated & zoomed bitmap
        mov bp,angle
        shl bp,2
        mov eax,sinetab+[bp]      ;calculate values on how to go over bitmap
        push eax
        neg eax
        call @@sizeopt01
        mov vstepx,eax
        mov eax,cosinetab+[bp]
        push eax
        call @@sizeopt01
        mov vstepy,eax
        pop eax
        call @@sizeopt02
        mov hstepx,eax
        pop eax
        call @@sizeopt02
        mov hstepy,eax

        imul ebx,hstepy,132       ;generate data into self-modificating code
        neg ebx                    ;code will display one row
        add ebx,8000h
        imul edx,hstepx,132
        neg edx
        add edx,8000h
        mov di,offset rotate_zoom_inner_loop+4
        mov cx,68
@@01:   call @@sizeopt03
        mov [di]+20,eax
        call @@sizeopt03
        mov [di]+28,eax
        call @@sizeopt03
        mov [di],eax
        call @@sizeopt03
        mov [di]+8,eax
        add di,41
        loop @@01

        call wait_vblank

        imul ebx,vstepy,84        ;now write each row directly into VRAM
        neg ebx
        add ebx,8000h
        imul edx,vstepx,84
        neg edx
        add edx,8000h
        mov cx,rz_firstrow
        imul di,cx,320
        shl cx,1
        neg cx
        add cx,200
        push ds
        mov ax,0a000h
        mov ds,ax
@@03:   shld esi,ebx,16
        movsx esi,si
        shl esi,10
        shld eax,edx,16
        movsx eax,ax
        add esi,eax
        add esi,cs:rzcenter
        call rotate_zoom_inner_loop
        add ebx,cs:vstepy
        add edx,cs:vstepx
        add di,320
        dec cx
        jnz @@03
        pop ds
        ret

@@SIZEOPT02:
        mov ecx,54613             ;adjust pixel ratio on screen
        imul ecx
        shrd eax,edx,16
@@SIZEOPT01:
        imul dword ptr zoom
        shrd eax,edx,16
        ret
@@SIZEOPT03:
        shld eax,ebx,16           ;calculate address out of X/Y = EDX/EBX
        movsx eax,ax
        shl eax,10
        shld ebp,edx,16
        movsx ebp,bp
        add eax,ebp
        add ebx,hstepy
        add edx,hstepx
        ret
ROTATE_ZOOM endp
;-----------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; MANDELBROT CALCULATIONS
; - fixed point integer math: 10b.22b
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

M_XSTART  equ -2430000            ;mandelbrot upper left corner
M_YSTART  equ -2450000
M_XADD    equ 320                 ;steps
M_YADD    equ 400
M_YCOUNT  dw 512                  ;counter pixels y
;-----------------------------------------------------------------------------

MANDELBROT proc
        mov ecx,m_ystart          ;lines to draw
        mov edi,himemstart        ;draw mandelbrot in himem (size: 1MB)

@@2:    mov ebx,m_xstart
        mov m_xcount,512          ;pixels per line

@@1:    push edi
        xor esi,esi
        xor edi,edi
        mov al,128                ;maximum iterations

@@3:    push ax                   ;calc  esi = esiý - ediý + xpos
        mov eax,esi               ;      ebp = esiý + ediý
        imul esi
        shld edx,eax,10
        push esi
        mov esi,edx
        mov ebp,edx
        mov eax,edi
        imul edi
        shld edx,eax,10
        sub esi,edx
        add esi,ebx
        add ebp,edx

        pop eax                   ;      edi = esi * edi + ypos
        imul edi
        mov edi,edx
        and edi,80000000h
        shld edx,eax,11
        or edi,edx
        add edi,ecx

        pop ax
        shr ebp,24                ;found a color?
        jnz short @@4
        dec al                    ;maximum of possible iterations?
        jnz @@3

@@4:    pop edi
        shl al,2
        shr al,1
        mov gs:[edi],al           ;set pixel; every fourth pixel is calculated,
        mov dh,ah                 ;the ones in between are interpolated
        add dh,al
        mov ah,al                 ; Û°Û°Û°Ûù  Â    "Û" are the calculated ones
        shr dh,1                  ; °°°°°°°ù  ³    "°" the interpolated ones
        mov gs:[edi]-1,dh         ; Û°Û°Û°Ûù  ³
        mov dh,al                 ; °°°°°°°ù  ³1024 pixels
        add dh,gs:[edi]-2050      ; ùùùùùùù   ù
        shr dh,1                  ; ÃÄÄÄÄÄÄù´ Á
        mov gs:[edi]-1025,dh      ;  1024 pixels
        mov dh,al
        add dh,gs:[edi]-2048
        shr dh,1
        mov gs:[edi]-1024,dh
        add edi,2

        add ebx,m_xadd            ;next column
        dec m_xcount
        jnz @@1
        add edi,1024              ;next row
        add ecx,m_yadd
        dec m_ycount
        jnz @@2
        ret
MANDELBROT endp
;-----------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; GENERATE SINE & COSINE LOOKUP-TABLE USING TAYLOR'S SERIES
; - fixed point integer math: 02b.30b
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

SINETAB_LENGTH  equ 4096          ;number of DWords sinetab will consist of
;-----------------------------------------------------------------------------

GENERATE_TAYLOR_SINETAB proc      ;GENERATE SINETABLE
        mov ebp,40000000h          ;ebp = 1.0
        xor esi,esi                ;variable x
        xor cx,cx                  ;index for destination in table

@@01:   push cx                   ;calculate taylor's series for both
        mov sinvalue,esi          ;sines and cosines
        mov cosvalue,ebp
        xor edi,edi
        inc di
@@02:   call @@sub
        sub cosvalue,eax
        call @@sub
        sub sinvalue,eax
        call @@sub
        add cosvalue,eax
        call @@sub
        add sinvalue,eax
        cmp di,13
        jne @@02
        pop cx

        mov eax,sinvalue          ;convert to 16b.16b
        sar eax,14
        mov ebx,cosvalue
        sar ebx,14
        mov di,offset sinetab     ;and store in table (sine and cosine values)
        add di,cx
        mov [di]+(sinetab_length/4*0)*4,eax
        mov [di]+(sinetab_length/4*1)*4,ebx
        mov [di]+(sinetab_length/4*4)*4,eax
        sub di,cx
        sub di,cx
        mov [di]+(sinetab_length/4*2)*4,eax
        mov [di]+(sinetab_length/4*1)*4,ebx
        mov [di]+(sinetab_length/4*5)*4,ebx
        neg eax
        neg ebx
        mov [di]+(sinetab_length/4*4)*4,eax
        mov [di]+(sinetab_length/4*3)*4,ebx
        add di,cx
        add di,cx
        mov [di]+(sinetab_length/4*2)*4,eax
        mov [di]+(sinetab_length/4*3)*4,ebx

        add esi,1921f6h           ;next x value (pi/(sintab_length/8*4)*2^30)
        add cx,4
        cmp cx,(sinetab_length/8) * 4
        jbe @@01
        ret

@@sub:  inc di                    ;calc: x ^ (++count) / (count!)
        mov eax,ebp               ;EAX <- result
        xor ebx,ebx
        inc bx
        mov ecx,edi
@@sub@1:imul esi
        shrd eax,edx,30
        imul ebx,ecx
        loop @@sub@1
        cdq
        idiv ebx
        ret
GENERATE_TAYLOR_SINETAB endp
;-----------------------------------------------------------------------------

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Various video stuff
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

PALETTE2  db 2
;-----------------------------------------------------------------------------

INIT_PALETTE1 proc
        mov dx,3c8h               ;palette setup fractal zoom & water ripples
        mov ax,101h
        out dx,al
        inc dx
        mov cx,63
        mov bx,3f3fh
        xor ah,ah
@@col1: call set_palette_entry
        dec bh
        loop @@col1
        mov cx,64
        inc bh
@@col2: call set_palette_entry
        inc bh
        loop @@col2
        mov al,63
        out dx,al
        out dx,al
        out dx,al
        ret
INIT_PALETTE1 endp
;-----------------------------------------------------------------------------

INIT_PALETTE2 proc
        mov bl,palette2           ;create grey-scale using upper 128 colors
        mov ax,384                ;PALETTE2 = brightest color [2..63]
        mov cx,ax
        mov bp,ax
        div bl
        mov bh,al
        mov dx,3c8h
        xor al,al
        out dx,al
        inc dx
@@col4: out dx,al
        loop short @@col4
@@col1: mov ah,bh
@@col2: out dx,al
        dec bp
        jz short @@col3
        dec ah
        jnz short @@col2
        inc al
        jmp short @@col1
@@col3: ret
INIT_PALETTE2 endp
;-----------------------------------------------------------------------------

SET_PALETTE_ENTRY proc
        mov al,ah                 ;set one palette entry R/G/B = AH/BH/BL
        out dx,al
        mov al,bh
        out dx,al
        mov al,bl
        out dx,al
        ret
SET_PALETTE_ENTRY endp
;-----------------------------------------------------------------------------

CLEAR_SEGGFX:                     ;clear SEGGFX buffer
        mov es,seggfx
        jmp short clear_seggfx2
CLEAR_SCREEN proc
        mov ax,0a000h             ;clear 320*200*256 graphic screen
        mov es,ax
CLEAR_SEGGFX2:
        xor di,di
        xor ax,ax
        mov cx,32768
        rep stosw
        ret
CLEAR_SCREEN endp
;-----------------------------------------------------------------------------

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; The different timers for the different parts
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

F_ZOOM_LOW   dd 22000h
;-----------------------------------------------------------------------------

TIMERROUTINE proc
        pushad                    ;restart timer
        push ds
        mov ax,cs
        mov ds,ax
        mov dx,3dah
@@timer:in al,dx
        and al,8
        jz @@timer
        mov al,30h
        call settimerandmodevga

TIMERJUMP label                   ;modificated here to alter vblank routines
        jmp timermodeend

TIMERMODE1:
        movzx cx,mode1+1          ;zooming text
@@m12:  mov dx,3c8h
        mov al,1
        out dx,al
        inc dx
        mov bh,mode1
        shr bh,1
        mov bl,bh
        xor ah,ah
        call set_palette_entry
        cmp bl,31
        je short @@m11
        inc mode1
@@m11:  sub dword ptr zoom,400h
        jz short @@modef
        loop @@m12
        jmp timermodeend
@@modef:mov timerjump+1,offset timermodeend-offset timerjump-3
        jmp timermodeend

;NOTE: This part of the code is extremely messy, so don't bother trying to
;      understand it...
TIMERMODE2:                       ;zooming and rotating fractal
        mov bx,f_rot_angl          ;rotation
        mov eax,f_rot_ampl
        imul dword ptr sinetab+[bx]
        and dx,4095
        mov angle,dx
        add f_rot_angl,64
        and f_rot_angl,4*4095
        add dword ptr f_rot_ampl,5000h
        mov bx,f_zoom_angl         ;zooming
        mov eax,f_zoom_ampl
        imul dword ptr sinetab+[bx]
        shld edx,eax,16
        add edx,f_zoom_low
        mov zoom,edx
        add f_zoom_angl,16
        and f_zoom_angl,2*4095
        add dword ptr f_zoom_ampl,05ah
        sub f_zoom_low,03ch
        mov bx,f_ym_angl           ;scrolling Y
        add f_ym_angl,4*21
        and f_ym_angl,4*4095
        mov eax,40000h
        sub eax,zoom
        shr eax,3
        imul dword ptr f_ym_ampl
        shrd eax,edx,16
        imul dword ptr sinetab+[bx]
        mov edi,edx
        shl edi,10
        add dword ptr f_ym_ampl,4000h
        mov bx,f_xm_angl           ;scrolling X
        add f_xm_angl,4*23
        and f_xm_angl,4*4095
        mov eax,40000h
        sub eax,zoom
        shr eax,3
        imul dword ptr f_xm_ampl
        shrd eax,edx,16
        imul dword ptr sinetab+[bx]
        add edi,edx
        add dword ptr f_xm_ampl,4800h
        add edi,himemstart+80200h
        mov rzcenter,edi
        jmp short timermodeend

TIMERMODEEND:
        inc retrace
        inc partlength
        mov al,20h
        out 20h,al
        pop ds
        popad
        iret
TIMERROUTINE endp
;-----------------------------------------------------------------------------

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Flat Real Mode Implementation Code
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

;NOTE: only GS is made a 4GB flat mode segment; everything else will just
;      stay like in normal real mode
SETUP_FRM proc                    ;set gdt registers for flat real mode
        mov byte ptr frmgdtblock+00,20h
        dec word ptr frmgdtblock+16
        mov byte ptr frmgdtblock+21,9ah
        dec word ptr frmgdtblock+24
        mov al,92h
        mov byte ptr frmgdtblock+29,al
        dec word ptr frmgdtblock+32
        mov byte ptr frmgdtblock+37,al
        dec word ptr frmgdtblock+38
LEAVE_FRM:
        mov ax,cs
        movzx eax,ax
        shl eax,4
        mov ebx,eax
        mov frmgdtblock+18,ax
        mov frmgdtblock+26,ax
        shr eax,16
        mov byte ptr frmgdtblock+20,al
        mov byte ptr frmgdtblock+28,al
        mov ax,offset frmgdtblock+8
        add ebx,eax
        mov dword ptr frmgdtblock+2,ebx
        cli                       ;disable all irqs (deadly)
        mov al,80h
        out 70h,al
        and ah,80h
        mov ch,ah
        .386p
        lgdt fword ptr frmgdtblock
        mov @@realm+2,cs
        mov bx,ds
        mov dx,ss
        mov eax,cr0
        or al,1
        mov cr0,eax
        db 0eah                   ;jmp cs:$+4 (cs is set to 8 -> gdt)
        dw $+4,8
        mov ax,10h                ;fill segment registers with gdt
        mov ss,ax
        mov ds,ax
        mov es,ax
        mov fs,ax
        mov ax,18h
        mov gs,ax
        mov eax,cr0
        and eax,not 1
        mov cr0,eax
        db 0eah                   ;jmp cs:$+4 (back to real mode)
@@realm dw $+4,0
        .386
        mov ss,dx                 ;init all segment registers
        mov ds,bx
        mov es,bx
        mov fs,bx
        xor ax,ax
        mov gs,ax
        out 70h,al
        sti
        ret
SETUP_FRM endp
;-----------------------------------------------------------------------------

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Miniature Keyboard Handler
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

KEYBOARDIRQSET proc
        mov ax,3509h              ;use own keyboard handling routine
        int 21h
        mov intvec_09h,bx
        mov intvec_09h+2,es
        push ds
        push cs
        pop ds
        mov dx,offset keyboardirq
        jmp short keyboardirqset2
KEYBOARDIRQSET endp
;-----------------------------------------------------------------------------

KEYBOARDIRQCLEAR proc
        push ds                   ;restore old one
        lds dx,dword ptr intvec_09h
KEYBOARDIRQSET2:
        mov ax,2509h
        int 21h
        pop ds
        ret
KEYBOARDIRQCLEAR endp
;-----------------------------------------------------------------------------

KEYBOARDIRQ proc
        push ax                   ;only key checked for is <ESC> (if enabled)
        in al,60h
    ifdef ESCENABLE
        cmp al,1
        sete cs:ESChit
    endif
        in al,61h
        mov ah,al
        or al,80h
        out 61h,al
        mov al,ah
        out 61h,al
        mov al,20h
        out 20h,al
        pop ax
        iret
KEYBOARDIRQ endp
;-----------------------------------------------------------------------------

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Vertical Blank Interrupts
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

;NOTE: Usually you should _count_ the ticks between two vertical retraces to
;      determine the exact value for a certain video mode
INTRCNT      equ 16767            ;timer1 counter for VGA 70Hz
;-----------------------------------------------------------------------------

VBLANKIRQON proc
        mov dx,3dah               ;init vertical blank interrupt
@@vb0:  in al,dx
        and al,byte ptr 8
        jnz @@vb0
@@vb1:  in al,dx
        and al,byte ptr 8
        jz @@vb1
        mov al,30h
        call settimerandmodevga
        cli
        xor ax,ax
        mov es,ax
        mov ax,es:[32]
        mov intvec_08h,ax
        mov ax,es:[34]
        mov intvec_08h+2,ax
        mov word ptr es:[32],offset timerroutine
        mov es:[34],cs
        sti
        ret
VBLANKIRQON endp
;-----------------------------------------------------------------------------

VBLANKIRQOFF proc
        cli                       ;deinit vertical blank interrupt
        xor ax,ax
        mov es,ax
        mov ax,intvec_08h
        mov es:[32],ax
        mov ax,intvec_08h+2
        mov es:[34],ax
        sti
        mov al,36h
        xor cx,cx
        call settimerandmode
        ret
VBLANKIRQOFF endp
;-----------------------------------------------------------------------------

SETTIMERANDMODEVGA:
        mov cx,intrcnt
SETTIMERANDMODE proc
        out 43h,al                ;set timer1 values
        mov al,cl
        out 40h,al
        mov al,ch
        out 40h,al
        ret
SETTIMERANDMODE endp
;-----------------------------------------------------------------------------

WAIT_VBLANK proc
        cmp retrace,0             ;synchronize program with monitor: just not
        je short wait_vblank      ;faster than 1 fps
        mov retrace,0
        ret
WAIT_VBLANK endp
;-----------------------------------------------------------------------------

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Data (it's all zero)
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

ZERO_DATA_START label
;-----------------------------------------------------------------------------

        align 4
;---------------------------------- MEMORY

SEGGFX       dw 0
SEGTUBE      dw 0
SEGCODE      dw 0
;---------------------------------- WATER

        align 4
WATERMOVE    dw 33*128 dup (0)    ;table for refraction
WATER_INNER_LOOP1 proc
             rept 256
             db water_loop_length1 dup (0)
             endm
             db 1 dup (0)         ;ret
WATER_INNER_LOOP1 endp
WATER_INNER_LOOP2 proc
             rept 256
             db water_loop_length2 dup (0)
             endm
             db 1 dup (0)         ;ret
WATER_INNER_LOOP2 endp
        align 4
WATERSINE1   db 256 dup (0)       ;refractions for 1st drop
WATERSINE2   db 256 dup (0)       ;                2nd
WATERDROP1   dw 0,0,0,0           ;refraction 1st move: rad l/h, angle, pause
WATERDROP2   dw 0,0,0,0           ;           2nd
;---------------------------------- TUBE

        align 4
TWOBBX       dw ringmax dup (0)   ;tube's wobbling X
TWOBBY       dw ringmax dup (0)   ;                Y
TSINX        dw 0,0,0,0,0,0       ;data for wobbling
TSINY        dw 0,0,0,0,0,0
TPOSX        dw 0                 ;used to center the tube
TPOSY        dw 0
TMOVEX       dw 0                 ;used to fill a piece of the tube
TMOVEY       dw 0
TUBEZPOS     dw 0                 ;Z position in tube
TUBEPERS     dw ringmax dup (0)   ;camera view
RADIEN       dw ringmax dup (0,0) ;jump-in addresses for tube-rings
TUBECOLS     db ringmax dup (0)   ;tube lighting
;---------------------------------- RANDOM NUMBERS

        align 4
RANDOM_SEED  dd 0
;---------------------------------- ROTATE-ZOOM

ZOOM         dd 0                 ;stretch-factor
ANGLE        dw 0                 ;angle to rotate bitmap

HSTEPX       dd 0                 ;steps to go over bitmap
HSTEPY       dd 0
VSTEPX       dd 0
VSTEPY       dd 0

ROTATE_ZOOM_INNER_LOOP proc
             rept 68
             db 8 dup (0)         ;mov al,gs:[esi]+(dword offset)
             db 8 dup (0)         ;mov ah,gs:[esi]+(dword offset)
             db 4 dup (0)         ;shl eax,16
             db 8 dup (0)         ;mov al,gs:[esi]+(dword offset)
             db 8 dup (0)         ;mov ah,gs:[esi]+(dword offset)
             db 5 dup (0)         ;mov [di]+(word offset),eax
             endm
             db 1 dup (0)         ;ret
ROTATE_ZOOM_INNER_LOOP endp
;---------------------------------- MANDELBROT

M_XCOUNT     dw 0                 ;counter pixels x
;---------------------------------- MANDELBROT ZOOM & ROTATE

F_ROT_ANGL   dw 0                 ;animation counters
F_ROT_AMPL   dd 0
F_YM_ANGL    dw 0
F_YM_AMPL    dd 0
F_XM_ANGL    dw 0
F_XM_AMPL    dd 0
F_ZOOM_ANGL  dw 0
F_ZOOM_AMPL  dd 0
;---------------------------------- SINETABLE

        align 4
SINVALUE     dd 0
COSVALUE     dd 0
SINETAB      dd sinetab_length/4 dup (0)
COSINETAB    dd sinetab_length dup (0)
             dd 0
;---------------------------------- FLAT REAL MODE GDT

        align 4
FRMGDTBLOCK  dw 0,0,0,0           ;gdtr
             dw 0,0,0,0           ;dummy descriptor
             dw 0,0,0,0           ;code
             dw 0,0,0,0           ;64KB data low memory
             dw 0,0,0,0           ;4GB data low & high memory
;---------------------------------- RETRACE

        align 4
RETRACE      dw 0                 ;counts vertical retraces
PARTLENGTH   dw 0                 ; -"-
MODE1        db 0,0               ;variables for zooming text
INTVEC_08h   dw 0,0               ;timer-interrupt old vector
;---------------------------------- KEYBOARD

INTVEC_09h   dw 0,0
    ifdef ESCENABLE
ESChit       db 0                 ;1=<ESC> pressed
    endif
;-----------------------------------------------------------------------------

ZERO_DATA_END label
;-----------------------------------------------------------------------------

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
code    ends
        end START
