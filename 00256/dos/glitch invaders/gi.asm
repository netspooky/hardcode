org 100h

use16


mov al,13h
int 10h
;[bp]-tmp1
;[bp+2]tmp2


mov bh,80h
  mov [bp],bx
add bh,al
  mov [bp+2],bx

dointro:
 push dx
 inc word [bp+4]
 fldpi
 fimul word [bp+4]
 fidiv word [cs:c180]
 fsincos
 fimul word [cs:c3]
 fistp word [bp+6]

 fimul word [cs:c3]
 fistp word [bp+8]


        mov     ds, [bp+2]
        mov     es, [bp]

        xor     di, di
        mov bh,80h;mov     bx, 8000h
        mov     cx, 64h
        mov     si, [bp+6]
        add     si, 3

lp_y:
        push    cx
        push    si
        mov     dx, 8000h
        mov     cx, 0A0h
        mov     ax, si
        mov     si, [bp+8]
        shl     si, 1
        shl     ax, 7
        add     si, ax
        shl     ax, 2
        add     si, ax
        add     si, 6

lp_x:
        mov     ax, [si]
        mov     [es:di+140h], ax
        xchg    al, ah
        stosw
        add     dx, 0F666h
        adc     si, 1
        and     si, 0FFFEh
        loop    lp_x

        add     di, 140h
        pop si
        pop     cx
        add     bx, 0F0A3h
        adc     si, 0
        loop    lp_y


        mov     dx, 3DAh
waitr:
        in      al, dx
        test    al, 8
        jz      short waitr


  mov ds, [bp]
  push 0A000h
  pop es
  xor si, si
  xor di, di
  mov ch,0FAh
  rep movsb

  mov ax, [bp+2]
  xchg ax, [bp]
  mov [bp+2],ax

;draw si
 pop dx
 mov si,160+100*320
 mov di,160+100*320+16

 push dx
 mov ch,5
siy:
 mov cl,3
 push si
 push di
six:
 xor al,al
 shr dx,1
 jnc putsi
 ;in al, 40h
 mov al,0Fh
putsi:
 mov ah,al

 push ax
 push ax
 pop eax
; mov [ds:di+320*2],eax
 mov [ds:di+320],eax
 mov [ds:di],eax;stosd

; mov [ds:si+320+2],eax
 mov [ds:si+320],eax
 mov [ds:si],eax
 sub di,4
 lodsd;add di,4
 dec cl
 jne six

 pop di
 pop si
 mov bx,320*2
 add si,bx;320*2
 add di,bx;320*2
 dec ch
 jne siy
 pop dx

 dec byte [bp+10]
; cmp cx,word[bp+4]
 jne nonew
 xor dx, 0AA55h
 shl dx, 1
 adc dx, 118h
nonew:
; mov [cs:siv+1],dx
 
 in al,60h
 dec al
 jne dointro
 ret

c180: dw 256/2;180
c3:db 30
;
;word_3EE dw 0
;word_3F0 dw 0
