.286
code segment
assume cs:code, ds:code
org 100h

entry:
      mov ax,13h
      int 10h
      
      mov ax,0A000h
      mov es,ax
    
      mov cx,63
pal:
      mov al,cl
      mov dx,3C8h
      out dx,al
      inc dx
      xor al,al
      out dx,al
      mov al,64
      sub al,cl
      out dx,al
      out dx,al
      
      loop pal

      push es
      push cs
      pop es
      xor bh,bh
      mov al,2
      lea bp,text
      mov cx,19
      mov dx,100Ah
      mov ah,13h
      int 10h
      pop es
k:
      mov cx,320
      mov di,64000

line:      
      push cx
      mov cx,255

      call random
      pop cx
      mov al,dl
      
      stosb
      loop line 
      
      call smooth

      in  al,60h
      cmp al,1
      jnz k
      
      mov ax,3
      int 10h
      ret

smooth:
      pusha
      mov cx,48000
s:    
      mov bx,cx
      mov al,es:[bx]
      dec bx
      add al,es:[bx]
      inc bx
      add al,es:[bx]
      sub bx,320
      add al,es:[bx]
      shr al,2
      or al,al
      jz zero
      dec al
zero:
      mov es:[bx],al
      mov dx,bx
      mov bx,64000
      sub bx,dx
      mov es:[bx],al      
      inc cx
      cmp cx,64320
      jnz s
      popa
      ret

random:
                push ax
                push bx
                mov ax,cs:[seed]
                mov bx,9821
                imul bx
                inc ax
                ror al,1
                add ax,8191
                rol ah,1
                mov cs:[seed],ax
                xor dx,dx
                div cx
                pop bx
                pop ax
                ret
seed dw 9821
text db 'b9y8 7s6c5r4E3E2E1n0 1a2n3d4 5C6Y7C809'
code ends
        end entry