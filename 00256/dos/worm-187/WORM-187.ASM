; Worm-187 by Shiru Otaku^IIpr 23.03.2005
; ??? ?????? ??????? ????? ???????? ? 187 ????

CODESG SEGMENT BYTE 'CODE'
       ASSUME CS:CODESG, DS:CODESG, SS:CODESG, ES:CODESG
       ORG    100H


MAIN   PROC   NEAR

      mov es,ax
      int 10h

      mov bh,0b8h
      mov ds,bx

gameStart:
      mov bh,09h
clearAttr:
      mov byte ptr[bx],011h
      dec bx
      jnz clearAttr

      mov bl,0a6h
fillFld0:
      mov cl,044h
fillFld1:
      mov byte ptr[bx],ch
      inc bx
      loop fillFld1
      add bx,12
      cmp bh,07h
      jb fillFld0

      mov bx,1000h
      mov dx,4
      inc si
      inc si
      mov cl,dl
initWorm:
      mov word ptr[bx],03e5h
      add bx,si
      loop initWorm

genPiece:

randSeed=$+1
      mov bx,0
        add bx,word ptr es:[046ch]
        and bh,07h
        mov word ptr cs:[randSeed],bx
      or bl,1
        cmp cl,byte ptr[bx]
        jne genPiece
       mov byte ptr[bx],0bbh

gameLoop:

      mov cl,2
waitLoop0:
      mov al,byte ptr es:[046ch]
waitLoop1:
      cmp al,byte ptr es:[046ch]
      je waitLoop1
      loop waitLoop0

      mov ah,ch
      mov cx,dx
      mov bx,0ffeh

drawWorm:
      inc bx
      inc bx
      mov di,word ptr[bx]
      mov word ptr[bx-2],di
      mov byte ptr[di],ah
      mov ah,0aah
      loop drawWorm

      cmp si,cx
      je gameStart

      mov ah,1
      int 16h
      jz inpTest3
      xor ah,ah
       int 16h

      mov al,ah
       cmp al,48h
       jne inpTest0
       mov si,0ffb0h
inpTest0:
         cmp al,50h
         jne inpTest1
         mov si,50h
inpTest1:
      cmp al,4bh
      jne inpTest2
      mov si,0fffeh
inpTest2:
      cmp al,4dh
      jne inpTest3
      mov si,2
inpTest3:

      add di,si
      mov word ptr[bx],di
      mov word ptr[bx+2],di

      mov al,byte ptr[di]
      cmp al,cl
      je inpTest4
      inc dx
      cmp al,0bbh
      je genPiece
      mov si,cx
inpTest4:
       cmp ah,1
       jne gameLoop

      mov ax,3
      int 10h

      ret

MAIN   ENDP
CODESG ENDS
       END  MAIN
