;bp - weidht
Smooth:
     push es
     push ax
     pop es
;     mov cx,320*110
     xor dx,dx
;     mov di,bp
;     inc di
sl1:
     mov dl,byte ptr es:[di-1]
     mov ax,dx
     mov dl,byte ptr es:[di+1]
     add ax,dx
     neg bp
     mov dl,byte ptr es:[di+bp]
     add ax,dx
     mov dl,byte ptr es:[di+bp+1]
     add ax,dx
     mov dl,byte ptr es:[di+bp-1]
     add ax,dx
     neg bp
     mov dl,byte ptr es:[di+bp]
     add ax,dx
     mov dl,byte ptr es:[di+bp+1]
     add ax,dx
     mov dl,byte ptr es:[di+bp-1]
     add ax,dx

     shr ax,3
;     adc ax,-1
;     js sl3
     or al,al
     jz sl3
     mov byte ptr es:[di],al
sl3:
     inc di
     loop sl1
     pop es
     ret