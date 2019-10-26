_Code SEGMENT WORD PUBLIC 'CODE'
      ASSUME  cs:_Code, ds:_Code
      ORG     100h

.386
			  ;email: smart-bomb@msn.com
Start:
 mov ax, 0013h		  ;VGA video mode
 int 10h

 xor bx, bx		  ;clear Buffer
again0:
 mov Buffer[bx], 0
 inc bx
 cmp bx, 64000
 jnz again0

 mov dx, 03c7h		  ;create color palette
 xor bx, bx
again1:
 mov al, Color
 out dx, al
 add dx, 2
 mov al, Orange
 out dx, al
 shr al, 1
 out dx, al
 mov al, 0
 out dx, al
 inc Color
 test Color, 05h
 jz incOrange
next:
 inc bx
 sub dx, 2
 cmp bx, 255
 jnz again1
 jmp paldone
incOrange:
 inc Orange
 jmp next
paldone:

MainLoop:
 mov dx, 03dah		  ;wait for vertical retrace
wr1:
 in al, dx
 test al, 08h
 jnz wr1
wr2:
 in al, dx
 test al, 08h
 jz wr2

 mov bx, 63360		  ;create random bottom line
again2:
 in al, 40h
 mul bx
 add al, ah
 mov Buffer[bx], al
 inc bx
 cmp bx, 64000
 jnz again2

 mov bx, 640		  ;smudge Buffer
smudgepixel:
 xor ah, ah
 mov al, Buffer[bx+1]
 mov dx, ax
 mov al, Buffer[bx-1]
 add dx, ax
 mov al, Buffer[bx+320]
 add dx, ax
 mov al, Buffer[bx-319]
 add dx, ax
 shr dx, 2
 or  dl, dl
 jz nodec
 dec dl
nodec:
 mov Buffer[bx-320], dl
 mov Buffer[bx-640], dl
 inc bx
 cmp bx, 64000
 jnz smudgepixel

 push ds		  ;write Buffer to VGA
 mov ax, 0a000h
 mov es, ax
 xor di, di
again3:
 mov bx, di
 mov al, Buffer[bx]
 mov es:[di], al
 inc di
 cmp di, 63040
 jnz again3
 pop ds

 in al, 60h		  ;check for esc key
 cmp al, 01h
 jnz MainLoop

 mov ax, 0003h		  ;reset video mode
 int 10h

 mov ah, 09h		  ;display Credits
 mov dx, OFFSET Credits
 int 21h

 ret			  ;quit to dos

 Credits     DB "Coded by Legend",10,"$"
 Color	     DB 0
 Orange	     DB 0 DUP(?)
 Buffer      DB 0 DUP(?)

_Code ENDS
      END Start
