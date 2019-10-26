assume ds:CsSeg
CalcSQRTab:
     xor di,di
     mov dx,-128
cqtl1:
     mov cx,-128
     mov word ptr Ys,dx
cqtl2:
     call CalUse
     not al
     mov byte ptr gs:[di],al
     inc di
     inc cx
     cmp cx,128
     jnz cqtl2
     inc dx
     cmp dx,128
     jnz cqtl1
     ret

CalcSTab:
     xor di,di
     mov dx,-60
cStl1:
     mov cx,-200
     mov word ptr Ys,dx
cStl2:
     call CalUse
     inc al
     stosb
     inc cx
     cmp cx,120
     jnz cStl2
     inc dx
     cmp dx,140
     jnz cStl1
     ret

CalUse:
     mov word ptr Xs,cx
     fild word ptr Xs
     fimul word ptr Xs
     fild word ptr Ys
     fimul word ptr Ys
     fadd
     fsqrt
     fistp word ptr Dat
     mov ax,word ptr Dat
     ret

;dh:dl - x,y in Tab
assume es:FsSeg
PutSpot:
     mov si,offset sMap+256

     mov di,offset lMap
     mov cx,61
psl1:
     xor al,al
     mov bl,byte ptr fs:[si+1]
     sub bl,byte ptr fs:[si-1]
     add bl,dl
     add bl,ch
     mov bh,byte ptr fs:[si+256]
     sub bh,byte ptr fs:[si-256]
     add bh,dh
     add bh,cl
     mov al,byte ptr gs:[bx]
psl2:
     stosb
     inc si
     dec ch
     jnz psl1
     dec cl
     jnz psl1
     ret

WaitVB:
     mov dx,3dah
wl1:
     in al,dx
     test al,8
     jnz wl1
wl2:
     in al,dx
     test al,8
     jz wl2
     ret

