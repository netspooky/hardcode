; 4 best result compile by TASM with /m2 options
.model tiny
.286
.data
nejm db "FLASH2K!"
pal db 768 dup(?)
virtscr db 64000 dup(?)
.code
org 100h



start:

 lea di,virtscr-320                       ; VYMAZAT VIRT-SCREEN
; xor ax,ax   ; AX = 0 (snad)
 mov cx,32000+160
 rep stosw

 mov ax,13h                               ; NASTAVIT 320x200x8b
 int 10h
 xor ax,ax

 mov dx, 3c8h                             ; NASTAVIT BARVY 1..63
 out dx,al
 inc dx
 @nextcolor1:
  inc ax
  out dx,al
  out dx,al
  out dx,al
  cmp al,63
 jne @nextcolor1

  mov cx, 576 ;(256-64)*3                 ; NASTAVIT BARVY 64..255
 @nextcolor2:
  out dx,al
  loop @nextcolor2

 push 0A000h
 pop es

 @nf:
  mov bl,50
  call rnd
  jnz @esc
   xor di,di                              ; POKUD RND(50)=0, PAK ZJASNIT O 15
  @lup:
   mov al,byte ptr es:[di]
   add al,15
  stosb
  cmp di,64000
  jnz @lup

  mov bl,255       ; prvni bod blesku     ; DEFINUJEME PRVNI BOD BLESKU [CX,DX]
  call rnd
  add ax,32
  xchg cx, ax

  xor dx,dx

  call line

 @esc:

  mov si,63679+offset virtscr             ; BLUR
  @lup1:
  push ax
  xor ax,ax
  xor bx,bx
  mov al,byte ptr ds:[si-320]
  mov bl,byte ptr ds:[si+1]
  add ax,bx
  mov bl,byte ptr ds:[si-1]
  add ax,bx

  db 08Ah,09Ch   ; \
  x320:          ;  \
  dw 320         ;  /  mov bl,byte ptr ds:[si+320]

  add ax,bx
  shr ax,2
  mov byte ptr ds:[si],al
  pop ax
  dec si
  cmp si, offset virtscr
  jne @lup1

  call wait_r                             ; CEKANI NA PAPRSEK

  sub di, di                              ; VIRT-SCREEN -> VRAM
  mov cx,32000;31840
  rep movsw

  in al,60h                               ; CEKANI NA STISK KLAVESY
  and al,al
  js @nf

; mov ax,3
; int 10h

 ret                                      ; KONEC (misto int 20h)

wait_r proc near
 mov  dx,3dah
@1: in   al,dx
    test al,8
   jz   @1
@2: in   al,dx
    test al,8
   jnz  @2
retn
endp


rnd proc ; bl <- max.cislo
         ; random -> al;  0 -> ah
         ; pokud al=0, nastavena ZF
    xor ax,ax
    out 43h,al
    in al,40h
    xchg al,ah
    out 43h,al
    in al,40h
    xor al,ah
    xor ah,ah
    div bl
    shr ax,8    ; pokud al = 0; ZF=1
    ret
endp rnd

  line:          ; cx = x   dx = y

   mov bl,150
   call rnd
    jnz @neodnoz
     pusha ; push cx ; push dx
      mov bl,2
      call rnd
      xchg ax,si
      call line ; rekurze !              ; REKURZIVNE RESENE ODNOZE
     popa  ; pop dx ; pop cx
   @neodnoz:

   mov bl,3
   call rnd
   dec cx
   add cx,ax

   push dx
   xchg ax, dx
   mul word ptr [x320]
   add ax,cx
   pop dx
   push ax
   pop di
    mov bl,80
    call rnd
    cmp sp,0FFFCh                   ; POKUD JSME V REKURZI-ODNOZI, VYKRESLIT
    push ax                         ; SLABE
    jne @odbocka
     pop ax
     add al,100
     push ax
     jmp @movuj
    @odbocka:
     mov bl,3
     call rnd
     jnz @movuj
     and si,si ;     cmp si,0
     jz @dek   ;     je @dek
      inc cx
      jmp @movuj
     @dek:
      dec cx
  @movuj:
  pop ax
  mov byte ptr ds:[di+offset virtscr],al    ;Mem[segA000:w1+w2*320] := 100+random(80);
  inc dx
  cmp dl,199
  jne line
  ret



end start


code ends





