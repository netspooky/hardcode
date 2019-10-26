;************
;* Readfont *
;************
;char *merkit=(char *)0xFFA6E;
;
;void readfonts(void){
;  short i,x,y,offs1,offs2;
;  char color;
;  char mask;
;  for (i=0;i<256;i++){
;    for (y=0;y<8;y++){
;      mask=128;
;      for (x=0;x<8;x++){
;        offs1=i*8+y;
;        color=((merkit[offs1]&mask)>0?1:0);
;        offs2=y*8+x;
;        font[i][offs2]=color;
;        mask>>=1;
;      }
;    }
;  }
;}
readfont:
        pusha
        push fs
        push es


        mov ax,0FFA6h
        mov fs,ax
        mov si,0000Eh
        mov ax,font
        mov es,ax
        xor di,di

        mov dx,256
        ;xor dl,dl
fontiloop:
        mov ch,8
fontyloop:
        mov cl,8
fontxloop:
        mov al,fs:[si]
        shr al,cl
        and al,1
        stosb
        dec cl
        jnz fontxloop
        inc si
        dec ch
        jnz fontyloop
        dec dx
        ;dec dl
        jnz fontiloop
        

        pop es
        pop fs
        popa
ret