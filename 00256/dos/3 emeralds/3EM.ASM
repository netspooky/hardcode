; Three Emeralds       (3EM)              Coded By Ufix/dSK!
; ''''''''''''''
; nice name.. is it related to the demo?? ..emm.. maybe the colour :)
;
;  This demo consists basically in three effects (in fact there are four, but
; the fourth one does nothing). At the end I have also added one bonus
; effect (TV out of order).
;
;  It does check for the vertical retrace, but it doesn't check for the
; ESC keypressed... so please wait until it ends.
;
;  It uses a primitive self-modifying code to change the effects.
; It isn't fully optimized.. but heck it is only 256 bytes and runs quite
; fast.
;
.MODEL TINY
.486
.CODE

ORG 100h
start:
        mov al,13h
        int 10h

start2: push ax
        mov al,255
pcol:
        mov dx,3c8h
        out dx,al
        inc dx
        xchg ax,bx
        out dx,al
        xchg ax,bx
        out dx,al
        out dx,al
        dec ax
        jnz pcol

        mov ax,cs
        add ax,1000h
        mov es,ax
        mov fs,ax

        mov al,1fh
        mov cx,32000
        rep stosw

        mov bp,1000
Aloop:
        mov cx,3000
        call vsyncpy
randloop:
        call Random
        add di,ax
        and ax,0Fh
        add ax,0fh
        mov fs:[di],al
        loop randloop
        call smooth
        dec bp
        jnz Aloop

        dec cl
Bloop:   
        call vsyncpy
        mov bx,320
rdline: call random
        and al,3Fh
        mov fs:[bx+64000-320],al
        dec bx
        jnz rdline
        call smooth
        loop Bloop
        pop ax
        cmp ax,13h
        jne finito
        xor ax,ax
        mov word ptr [offset notbx],9090h
        jmp start2
      
finito:
        mov ax,13h
        int 10h

        mov bl,80
ltv2:   call vsyncpy
        dec cx
ltv1:   call Random
        add di,ax
        and al,0fh
        add al,0fh
        mov fs:[di],al
        loop ltv1
        dec bx
        jnz ltv2

exit:   mov ax,03h
        int 10h
;        mov ax, 4c00h
;        int 21h
        ret

Random          PROC
        push bx
        mov bx,[rnd1]
        mov ax,[rnd2]
        add ax,bx
        ror ax,1
        mov [rnd1],ax
        mov [rnd2],bx
        pop bx
        ret
Random          ENDP

Smooth         PROC
        pusha
        mov bx,64000
        xor cx,cx
bukle:
        mov bp,bx
notbx:  not bx
        add bx,64000
        xor ax,ax
        xor dx,dx
        mov al,fs:[bx-1]
        mov dl,fs:[bx]
        add ax,dx
        mov cl,fs:[bx+1]
        mov dl,fs:[bx+320]
        add dx,cx
        add ax,dx
        shr ax,2
        mov fs:[bx-640],al
        mov bx,bp
        dec bx
        jnz bukle
        popa
        ret
smooth        endp
vsyncpy       proc
        pusha
        mov  dx,3DAh
wvr:
        in   al,dx
	test al,8
        jz   wvr

        push 0a000h
        xor di,di
        xor si,si
        pop es
        mov ax,fs
        mov ds,ax
        mov cx,16000
        rep movsd
        push cs
        pop ds
        popa
        ret
vsyncpy         endp

rnd1 DW     3224h
rnd2 DW     7F3Ah

END start
