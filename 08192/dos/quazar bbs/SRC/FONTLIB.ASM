BlockSizeX	= 2
BlockSizeY	= 1

GetFontInfo:
     push es
     mov ax,1130h
     mov bx,300h
     int 10h
     mov word ptr cs:PutWord+1,es
     mov word ptr cs:pwls+1,bp
     pop es
     ret

;es:di - seg:offset in Vmem
;bx - offset of Text
;ax - w,h
PutWord:
     push 1000
     pop fs
pwls:
     mov bp,01000
     mov dl,3fh
     call Random
     and ax,101h
     add ax,101h
     call InitFont
pwl4:
     movzx si,byte ptr cs:[bx]
     or si,si
     jz pwe
     cmp si,20h
     jz Nline
Cont:
     push di
     shl si,3
     mov cl,8
     add si,bp
pwl1:
     lods byte ptr fs:[si]
;     lodsb
     push di
pwl2:
     or al,al
     jns pwl3
     xchg dl,al
     push di
     mov dh,BlockSizeY
pbl2:
     mov ch,BlockSizeX
pbl1:
     stosb
     dec ch
     jnz pbl1
smc3:
     add di,320-BlockSizeX
     dec dh
     jnz pbl2
     pop di
     xchg dl,al
pwl3:
     add di,BlockSizeX
     shl al,1
     jnz pwl2
     pop di
smc2:
     add di,320*BlockSizeY
     loop pwl1
     pop di
smc1:
     add di,BlockSizeX*8-3
     inc bx
     jmp pwl4
     pop di
pwe:
     ret

Nline:
     mov ax,word ptr cs:smc2+2
     shl ax,3
     add di,ax
     call Random
     and ax,1fh
     add ax,17h
     sub di,ax
     call Random
     and ax,101h
     add ax,101h
     call InitFont
     mov si,20h
     jmp Cont

InitFont:
     mov byte ptr cs:pbl2+1,al
     mov byte ptr cs:pbl2-1,ah
     mov byte ptr cs:pwl3+2,al
     xor cx,cx
     mov cl,ah
     mov si,cx
     shl si,1
     mov cx,word ptr cs:YTab[si]
     mov word ptr cs:smc2+2,cx
     mov cx,320
     sub cl,al
     sbb ch,0
     mov word ptr cs:smc3+2,cx
     xor cx,cx
     mov cl,al
     shl cl,3
     sub cl,3
     mov byte ptr cs:smc1+2,cl
     ret

;PutBlock:
;     xchg dl,al
;     mov al,3fh
;     push di
;     mov dh,BlockSizeY
;pbl2:
;     mov ch,BlockSizeX
;pbl1:
;     stosb
;     dec ch
;     jnz pbl1
;     add di,320-BlockSizeX
;     dec dh
;     jnz pbl2
;     pop di
;     xchg dl,al
;     ret
