; An optimized fire-routine in pure ASM (real mode).
; I have no idea where the pushed values ends up since there's no stack, it works-
; anyway so why bother...
; The random number generator was not written by me, I just modified it to work in
; real mode. It's probably pretty slow, but at least it works...
; Press [ESC] to exit the program.
;
; How to compile:
;  tasm /m fireopt.asm
;  tlink /t fireopt.obj
;

 
.model tiny		;Not neccesary, but it's the correct way to do it
.386			;Enable 386 instructions	
code segment use16	;Set up the 64k segment in wich all code/data will reside
assume cs:code, ds:code	;Point cs and ds to this segment
org 0100h		;This line must be present in a .COM file

;*** <Main code> ***
start:		; <-- execution starts here 
mov al,13h	;set mode 19
int 10h

;*** <Palette stuff> ***
 mov cx,32 
 ;*** Calculate the palette ***
  palloop:

   mov dx,3c8h
   mov al,cl
   out dx,al
   shl al,1
   dec ax	;16-bit dec/inc takes only 1 byte, 8-bit versions takes 2 bytes
  
   mov bl,al

   inc dx
   out dx,al
   xor al,al
   out dx,al
   out dx,al

   dec dx
   mov al,cl
   add al,32
   out dx,al
   inc dx
   mov al,63
   out dx,al
   mov al,bl
   out dx,al
   xor al,al
   out dx,al

   dec dx
   mov al,cl
   add al,64
   out dx,al
   inc dx
   mov al,63
   out dx,al
   out dx,al
   mov al,bl
   out dx,al
 loop palloop
  dec dx
  mov al,97
  out dx,al
  inc dx
  mov al,63
  mov cx,477
  palloop2:
   out dx,al
  loop palloop2
 
;*** set es to point at VGA video memory ***
 push 0a000h
 pop es

mov dl,58 
mov bp,318

mainloop:
 mov dh,160
 mov si,12798		;(y*320)+x-2  	(x=0, y=40)
 mov di,12160		;((y-2)*320)+x 	(x=0, y=40)

;*** Draw column by column, left to right ***
 xloop:

  push di
  push si
  push ds
  push es
  pop ds
  mov ch,82		;Start at y=40
  yloop:
   xor ah,ah
   lodsb			;si=(y*320)+x-2
   mov bx,ax
   inc si
   lodsb			;si=(y*320)+x
   add bx,ax
   inc si
   lodsb			;si=(y*320)+x+2
   add bx,ax
   mov al,[si+639]
   add ax,bx
   shr ax,2
   je short nopixeldec
    dec ax		; color=color-1		
   nopixeldec:		;end if
   mov ah,al
   stosw
   add di,bp
   stosw
   add si,635
   add di,bp		;di = last di + 640
   dec ch
   jnz short yloop
   sub di,640
   pop ds
  

  mov si,OFFSET random16
  xor bh,bh
  mov bl,dl
  mov ax,[si+bx]
  mov bl,cl
  add si,bx
  add ax,[si]
  mov [si],ax
  inc dx
  inc cx
  inc dx
  inc cx
  and dl,62 
  and cl,62 
  and ax,0bfh		;Cut ax to be max 191
  pop si 

  add al,10		;Add 10 to random number
  stosb 
  pop di
  inc si		;Add 2 to read-offset
  inc di
  inc si 
  inc di
  dec dh
 jnz xloop

 in al,60h		;Check for ESC key
 dec al
jz short quit	;Continue
jmp mainloop


 quit:
 mov al,03h		;Set textmode
 int 10h

 mov ah,04ch		;Exit to DOS
 int 21h
;*** </Main code> ***



;*** <Data> ***
 ;31 random 16-bit numbers for use with the random-number generator
 random16 dw 25662,56977,36314,46707
          dw 56747,47936,28467,50155
          dw 54470,9126,19191,26274
          dw 27205,13469,6769,48786
          dw 43195,17969,58549,13097
          dw 9962,26613,60724,25428
          dw 44416,43884,31777,40699
          ;;dw 4280,32767,31882,41912
          ;;dw 19050,42386,38267,39411
          ;;dw 11739,36780,10921,43911
          ;;dw 7473,38901,28614,62047
          ;;dw 25094,22064,16149,14666
          ;;dw 46209,34643,30017,25842
          ;;dw 64242,3527,34102,35358
          ;;dw 2277,3678,16479,3431
          dw 36135,63741,11311

;*** </Data> ***

code ends	;Segment ends here
END start	;End of program


;/Mic, stabmaster_@hotmail.com
