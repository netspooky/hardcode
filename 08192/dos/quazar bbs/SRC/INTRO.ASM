CopyFont:
     xor si,si
     mov cx,320*110
cfl1:
     mov al,byte ptr es:[si]
     or al,al
     jz cfl2
     mov byte ptr gs:[si],al
;     call Random
;     or al,al
;     js cfl2
;     call Random
;     and ax,3
;     shl ax,1
;     mov di,ax
;     mov di,word ptr cs:YTab[di]
;     add di,si
;     cmp byte ptr gs:[di],3fh
;     jz cfl2
;     mov byte ptr gs:[di],3fh
;     push cx
;     mov ax,gs
;     mov cx,1
;     inc di
;     mov bp,320
;     call Smooth
;     pop cx
cfl2:
     inc si
     dec cx
     jnz cfl1
     ret

Intro:
     push es
     push fs
     push gs
;     jmp iex
     call SetPal
     push TxtSeg
     pop es
     push TempSeg
     pop gs
     mov word ptr cs:TOffs,offset ITxt
ivl3:
     call ShowPage
     jc ivl2
     call Show
     mov word ptr cs:TOffs,bx
     mov cx,5
ivl1:
     call WaitVB
     loop ivl1
     jmp ivl3
ivl2:
     mov dx,3c8h
     xor ax,ax
     mov cx,768
     out dx,al
     inc dx
il5:
     out dx,al
     loop il5

     push 0a000h
     pop es
     call CalcSTab

     mov bp,1
il4:
     mov dx,3c8h
     mov ax,bp
     mov bh,32
     cmp ax,100h-32
     jl il6
     mov bh,1
il6:
     out dx,al
     mov al,03fh
     inc dx
il1:
     out dx,al
     out dx,al
     out dx,al
     mov bl,0a0h
il2:
     imul cx,ax,100
     dec bl
     jnz il2
     sub al,2
     dec bh
     jnz il1
     inc bp
     cmp bp,100h
     jnz il4
     xor di,di
     xor eax,eax
     mov cx,16000
     rep stosd
iex:
     pop gs
     pop fs
     pop es
     call SetPal
     ret
