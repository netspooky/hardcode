; Galaxy type demoeffect in 256 bytes by Spock / Wild Bits
; Comments and feedback to portela@grupobbva.net
; Spock's web on   http://kiss.to/spock

.386
.MODEL TINY
ASSUME CS:INTRO,DS:INTRO

INTRO SEGMENT PARA USE16
   org  0100h

STARTUPCODE
seed:
   mov al,13h
   int 10h
   mov bh,0a0h
   mov es,bx
   mov bh,0fah
clearnext:
   dec bx
   mov ds:[vs+bx],0
   jnz clearnext
   mov bh,02h
initstarsnext:
   mul bx
   inc ax
   mov word ptr seed,ax
   xor dx,dx
   mov cl,49
   div cx
   mov x,dx
   fild word ptr seed
   fsincos
   fimul x
   fistp ds:[stars+bx-2]
   fimul x
   sub  bx,4
   fistp ds:[stars+bx]
   jnz  initstarsnext
espera:
   mov  bh,02h
next:
   fld  cons
   fimul angle
   fsincos
   fstp sine
   fst cosin
   fimul ds:[stars+bx-4]
   fld sine
   fimul ds:[stars+bx-2]
   fadd
   fistp x
   fild ds:[stars+bx-4]
   fmul sine
   fild ds:[stars+bx-2]
   fmul cosin
   fsub
   fistp z
   mov di,z
   mov cx,di
   sar cx,2
   add cx,x
   mov dx,cx
   add cx,di
   neg cx
   mov si,cx
   sar cx,2
   add cx,120
   add cx,di
   mov ax,256
   imul dx
   idiv cx
   add ax,27678
   mov di,ax
   mov ax,128
   imul si
   idiv cx
   mov dx,320
   mul dx
   add di,ax
   mov cx,03f3fh
   mov word ptr ds:[vs+di],cx
   mov word ptr ds:[vs+di-320],cx 
   sub bx,4
   jnz next
   mov bh,0f7h
framenext:
   mov al,ds:[vs+bx]
   add al,al
   add al,ds:[vs+bx+1]
   add al,ds:[vs+bx-1]
   shr al,2
   mov ds:[vs+bx],al
   sar al,2
   add al,16
   mov es:[bx],al
   dec bx
   cmp bx,640
   jne framenext
   inc angle
   in  al,60h
   dec al
   jnz  espera
   mov  ax,3h
   int  10h
   ret

   cons  dd 0.01745
   angle dw ?
   sine  dq ?
   cosin dq ?
   x     dw ?
   z     dw ?
   stars dw 256   dup(?)
   vs    db 64000 dup(?)

INTRO ENDS
      END
