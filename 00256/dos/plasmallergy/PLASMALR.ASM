.486

code segment use16
assume cs:code,ds:code,es:code,fs:code
org 100h

start:

mov al,13h
int 10h

mov ah,4ah
mov bh,10h
int 21h
mov ah,48h
int 21h
mov ds,ax
mov es,ax

dec cx
mov al,0
rep stosb
	
;----------------------------------------------------------------------------
;// creation de l'image

mov ch,6

_pc:
  in al,40h
  mov ah,al
  in al,40h
  xchg di,ax

  mov al,32
  _pcl:
    mov bl,32 
    _pcc:
      add byte ptr [bx+di],4
      dec bx
    jnz _pcc
    add di,320
    dec al
  jnz _pcl
loop _pc



;moyenne

mov cl,11
_pm:
  xor di,di
  _pmi:
    mov al,[di-1]
    add al,[di+1]

    mov bl,[di+320]
    add ax,bx
    mov bl,[di-320]
    add ax,bx
    shr ax,2
    stosb
    inc di
    inc di
  jnz _pmi
loop _pm

;----------------------------------------------------------------------------
;// principal (plasma)

push 0a000h
pop es

mloop:
	
  ml1:
    mov al,[di+bx]
    mov si,ax

    push bx
    mov bx,cx
    mov al,[di+bx]
    add si,ax

    mov bx,dx
    mov al,[di+bx]
    add ax,si
    pop bx

    shr ax,1
    sub al,40				; pour les couleurs
    stosb
    dec di
    inc di
  jne ml1
  
  inc bx
  dec cx
  add dx,320
  push dx
  call vbe
  pop dx

  in al,60h
  das
jc mloop

mov ah,0
int 16h


;----------------------------------------------------------------------------
;// fin

push es
pop ds


; [ÛÛÛ] --> [ÄÄÄ]
mov bl,100

mov si,64000
fin1:
  mov cx,320
  push cx
  xor ax,ax
  rep stosb
  pop cx
  fin2:
    mov [si],al
    inc si
  loop fin2
  sub si,640

  call vbe

  dec bl
jnz fin1

; [ÄÄÄ]  -> [ ú ]
mov si,32319

mov cl,80
fin3:
  xor ax,ax
  stosw
  mov [si],ax
  dec si
  dec si
  call vbe
loop fin3

; [ ú ] -> [   ]
mov bl,31
fin4:
  mov [di],bl

  mov cl,6
  fin5:
    call vbe
  loop fin5
  
  dec bx
  test bl,16
jne fin4

mov al,3
int 10h

mov ah,9h
push cs
pop ds
lea dx,msg
int 21h


vbe:
  mov dx,3dah
  in al,dx
  test al,8
  jnz $-3
  in al,dx
  test al,8
  jz $-3
ret


msg db "PlasmAllergy : 256b compo$"
code ends
end start