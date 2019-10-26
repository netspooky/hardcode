;Yet Another Xor Pattern
;by fr33ke@gmail.com
;NASM syntax

%define SMALL   0
%define SMOOTH  1

%define ESCAPE      (! SMALL)
%define GLITCHY     (SMALL || SMOOTH)
%define MOVE        1
%define PALETTE     (! SMALL)
%define VTRACE      (! SMALL)
%define LAST_BYTE   (SMALL && SMOOTH)

;question: what initial register states can i count on?
;answer: ax==0, bx==0, ch==0, di==0fffeh, si==100h, directionflag==0.
;--Hugi size coding compo #1 faq

;Directives
use16
org 0x100

;Setup
%if GLITCHY
    lds dx, [bx]    ;ds ~= 0xA000
%else
    push 0xA000
    pop ds
%endif

mov al, 0x13
int 0x10        ;video mode 320x200

%if PALETTE
    ;Palette stuff
    xchg ax, bx
    mov  dx, 0x3c8
    out  dx, al
    inc  dx

    paletteloop:
    mov al, ch
    out dx, al
    shr al, 1
    out dx, al
    shr al, 1
    out dx, al
    inc ch
    jnz paletteloop

    %if VTRACE
        mov dl, 0xDA    ;3DA = vtrace port
    %endif
%endif

;Main loop
mainloop:
%if LAST_BYTE
    db 0xB1     ;mov cl
    outerloop:
    db 0xBB     ;~200 / mov bx,
    dw 0x013C   ;~320 / cmp al, 01
%else
    mov cl, 200-1   ;ch = 0
    outerloop:
    mov bx, 320-1
%endif
imul di, cx, 320
innerloop:

%if MOVE
    lea ax, [si+bx]
%else
    mov ax, bx
%endif
xor ax, cx
add ax, si

%if SMOOTH
    add [di+bx], al
    rcr byte [di+bx], 1
%else
    mov [di+bx], al
%endif

dec bx
jns innerloop
loop outerloop

inc si

%if VTRACE
    ;Wait for vertical retrace
    %if !PALETTE
        mov dx, 0x3DA
    %endif
    vtrace:
    in al, dx
    %if ESCAPE
        and ax, 8
    %else
        test al, 8
    %endif
    jz vtrace
%endif

%if ESCAPE
    in al, 60h               ;check for ESC
    %if VTRACE
        dec ax
    %else
        dec al
    %endif
    jnz mainloop
    ret
%else
    jmp mainloop
%endif

align 2
