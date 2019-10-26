;fs:si - Buff
CalcPic:
assume ds:CsSeg
     xor si,si
     xor bx,bx
cpl3:
     mov ah,8
     mov al,byte ptr ds:QPic[bx]
cpl2:
     mov byte ptr fs:[si],0
     mov byte ptr fs:[si+256*61],0
     test al,80h
     jz cpl1
     mov byte ptr fs:[si],32
     mov byte ptr fs:[si+256*61],0ffh
cpl1:
     inc si
     shl al,1
     dec ah
     jnz cpl2
     inc bx
     cmp bx,256*61/8
     jnz cpl3

     mov bx,6
cpl5:
     mov bp,256
     mov di,bp
     mov ax,fs
     mov cx,256*60*2
     call Smooth
     dec bx
     jnz cpl5
cex:
     ret
