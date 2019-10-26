; BALLZ by SHoGuN / (C) The Third Foundation 1998
; Coded for the XMas 256b compo...
;
; Contact: p.gnodde@st.hanze.nl
;          gnoddep@convertis.nl

.model tiny
.386

.data
_Ball1x dw 130          ; contains x of flare 1
_Ball1y dw 99           ; contains y of flare 1
_Ball2x dw 180          ; same as above but then for flare 2
_Ball2y dw 100

.code
.startup

main    proc

        mov ax,0A000h   ; Load video segment
        mov es,ax       ; in es
        sub ah,10h      ; Load some segment for buffer
        mov fs,ax       ; in fs

        mov ax,13h      ; Set mode 320x200 256colors
        int 10h

        mov dx,3c8h     ; set pallette to cute purple colors
        mov cl,255
        xor ax,ax
@set_pal_loop:
        mov al,cl
        out dx,al       ; Select color
        inc dx
        cmp al,64
        jb  short @Hmmm
        mov al,63
@Hmmm:
        out dx,al       ; Give red value
        xchg al,ah
        out dx,al       ; Give green value
        xchg al,ah
        out dx,al       ; Give blue value
        dec dx
        loop short @set_pal_loop

        mov dx,0101h    ; These are the bounce-move-thingie-bits :-)
        push dx
@Main_loop:
        push es
        push fs
        pop es
        xor di,di
        mov cx,16000
        mov eax,01010101h
        rep stosd               ; Clear buffer
        pop es

        lea si,_Ball1x
        mov cx,2
@Loop1:
        push cx
        mov ax,90               ; x of buffer
        mov bx,55               ; y of buffer

@Calc:
        push ax
        push bx
        sub ax,[si]             ; ax = ax-_Ball?x
        sub bx,[si+2]           ; bx = ax-_Ball?y
        mul ax                  ; ax^2
        imul bx,bx              ; bx^2
        add bx,ax
        cmp bx,0
        jne short @Ok1
        mov bx,1
@Ok1:
        xor dx,dx
        mov ax,0FFFh            ; this is a lot faster then sqrt
        div bx                  ; and a lot less accurate
        cmp ax,63
        ja  short @Ok2
        mov cl,al
        jmp short @Put_pix
@Ok2:
        mov cl,63

@Put_pix:
        pop bx
        pop ax
        push bx
        imul bx,320
        add bx,ax
        add cl,fs:[bx]
        mov fs:[bx],cl       ; Put pixel in buffer
        pop bx

        inc ax
        cmp ax,230
        jb  @Calc
        xor ax,ax
        inc bx
        cmp bx,145
        jb  @Calc
        pop cx
        add si,4
        loop @Loop1

        pop dx
        cmp _Ball1x,110                 ; Check if flare should bounce
        jbe short @BounceX              ; of x-walls
        cmp _Ball1x,210
        jb  short @Verder1
@BounceX:
        neg dl

@Verder1:
        cmp _Ball1y,65                  ; Check if flare should bounce
        jbe short @BounceY              ; of y-walls
        cmp _Ball1y,135
        jb  short @Verder2
@BounceY:
        neg dh

@Verder2:
        add byte ptr _Ball1x,dl         ; move the flares
        sub byte ptr _Ball2x,dl
        add byte ptr _Ball1y,dh
        sub byte ptr _Ball2y,dh
        push dx

        mov dx,3DAh                     ; wait for retrace
@l1:
        in  al,dx
        and al,08h
        jz  short @l1

        push ds
        push fs
        pop ds
        xor si,si
        xor di,di
        mov cx,16000
        rep movsd                       ; Flip buffer to screen
        pop ds

        in  al,60h                      ; Check for keypressed
        cmp al,80h
        ja  @Main_loop

        mov ax,3        ; Set textmode 80x25 16colors
        int 10h
        .exit           ; Quit
main    endp

end
