;ds:bp - offset
ShowPage:
     mov bx,word ptr cs:TOffs
     cmp byte ptr cs:ShowTime,0
     jnz spl1
     cmp byte ptr cs:ClsTime,0
     jnz spl2
     call ClsFont
     mov ax,word ptr ds:[bx]
     cmp al,0ffh
     jz spl4
     mov word ptr cs:ShowTime,ax
     inc bx
     inc bx
     mov di,word ptr ds:[bx]
     inc bx
     inc bx
     call PutWord
     inc bx
spl1:
     dec byte ptr cs:ShowTime
     jz spl2
     mov ax,gs
     mov cx,320*110
     mov bp,320
     mov di,bp
     call Smooth
     call CopyFont
     ret
spl2:
     dec byte ptr cs:ClsTime
     jnz spl3
     ret
spl3:
     mov ax,gs
     mov cx,320*110
     mov bp,320
     mov di,bp
     call Smooth
     ret
spl4:
     stc
     ret

ShowTime 	db ?
ClsTime		db ?
TOffs		dw ?
