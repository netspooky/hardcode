.MODEL SMALL
.STACK 0FFFh
.386



.DATA
cheezymessage DB 201,46 DUP (205),187,0Ah,0Dh
              DB 186,' FractalWarp-Interactive by Robert Fielding   ',186,0Ah,0Dh
              DB 204,46 DUP (205),185,0Ah,0Dh
              DB 186,' Press the left mouse button to continue...   ',186,0Ah,0Dh
              DB 186,' Left mouse changes the picture               ',186,0Ah,0Dh
              DB 186,' Moving the mouse changes the characteristics ',186,0Ah,0Dh
              DB 186,' Right+Left mouse exits                       ',186,0Ah,0Dh
              DB 200,46 DUP (205),188,0Ah,0Dh
              DB 0Ah,0Dh,'$'

warningmessage DB 'You must have a ms-compatible mouse, a VGA (or above), ',0Ah,0Dh
               DB 'and a 386 (or above) to run this program.',0Ah,0Dh
               DB 'Do you have a mouse, 386 (or above),and a VGA?',0Ah,0Dh
               DB '(Press N if you are from the stone-age...)',0Ah,0Dh
               DB 0Ah,0Dh,'$'
               
okaymessage    DB 0Ah,0Dh
               DB 'Okay. Press left mouse to continue, move it and watch....',0Ah,0Dh
               DB '(You will want to look for hot-spots in the designs.)',0Ah,0Dh,'$'

losermessage   DB 0Ah,0Dh,'You suck. :)  Goodbye.',0Ah,0Dh,'$'
.CODE


resetmouse MACRO
  xor ax,ax
  int 33h
ENDM

; bx=buttons,cx=column,dx=row
getmousestats MACRO
  mov ax,0003h
  int 33h
ENDM

; cx=horizontal,dx=vertical move the mouse cursor
movemouse MACRO
  mov ax,0004h
  int 33h
ENDM


LEFTMOUSE EQU 0001h
RIGHTMOUSE EQU 0002h


; corrupts al,dx
waitforretrace MACRO 
  mov dx,03DAh
@@wait:
  in al,dx
  and al,08h
  jnz @@wait
ENDM


; corrupts ax
graphmode MACRO
  mov ax,0013h
  int 10h
ENDM

;corrupts ax,dx
textmode MACRO
  mov ax,0003h
  int 10h
ENDM

; corrupts ax (Don't use al or dx as a register!!!!)
pokecolor MACRO reg,red,green,blue
  mov dx,03C8h
  mov al,reg
  out dx,al
  mov dx,03C9h
  mov al,red
  out dx,al
  mov al,green
  out dx,al
  mov al,blue
  out dx,al
ENDM

;leave components in: ah=red,dl=green,al=blue
peekcolor MACRO reg
  mov dx,03C7h
  mov al,reg
  out dx,al
  mov dx,03C9h
  in  al,dx
  mov ah,al       ;ah=red
  in  al,dx
  push ax
  in  al,dx       ;al=blue
  pop dx          ;dl=green
ENDM


; corrupts ax,bx (do not use ax/bx for args!!!)
putpixel MACRO x,y,c
  mov ax,y
  mov bx,ax
  shl bx,8
  shl ax,6
  add bx,ax
  add bx,x
  mov es:[bx],c
ENDM

; This is the map used for pallete rotating...
;  a(i,j) = i*j  mod 256
;
;
dopic1 PROC
  LOCALS
  mov si,320
  mov di,200     
  xor bx,bx
@@yloop:
  mov cx,si
    @@xloop:
      movzx eax,di
      and ecx,0000FFFFh   ;Clear the high part of cx 
      mul ecx             ;The color we want is in al now
      mov es:[bx],al      ;Plot the point
      inc bx              ;Next pixel is ready....
      loop @@xloop
  dec di
  cmp di,0000h
  jnz @@yloop                         
  ret
ENDP


; This is the map used for pallete rotating...
;  a(i,j) = i+j ^i ^j mod 256
;
;
dopic5 PROC
  LOCALS
  mov si,320
  mov di,200     
  xor bx,bx
@@yloop:
  mov cx,si
    @@xloop:
      mov ax,di
      add ax,cx
      xor ax,si
      xor ax,di
      mov es:[bx],al      ;Plot the point
      inc bx              ;Next pixel is ready....
      loop @@xloop
  dec di
  cmp di,0000h
  jnz @@yloop                         
  ret
ENDP



; This is the map used for pallete rotating...
;  a(i,j) = (i-160)*(i-160) + (j-100)*(j-100)  mod 256
;
;
dopic6 PROC
  LOCALS
  mov si,320
  mov di,200     
  xor bx,bx
@@yloop:
  mov cx,si
    @@xloop:
      push bx
      push cx
        and ebx,0000FFFFh
        sub ebx,100             ; center y

        and ecx,0000FFFFh
        sub ecx,160              ;  center x
                      
        mov   eax,ebx
        imul  ebx
        mov   ebx,eax

        mov   eax,ecx
        imul  ecx        ;x*x + y*y     
        add   eax,ebx    ; is in eax
        shr eax,8
      pop cx  
      pop bx
      mov es:[bx],ah      ;Plot the point
      inc bx              ;Next pixel is ready....
      loop @@xloop
  dec di
  cmp di,0000h
  jnz @@yloop                         
  ret
ENDP


; This produces serpinski triangles....this was an accident!
;  a(i,j) = i&j  mod 256
;  (i^j) and (i|j) produce similar pictures
;
dopic2 PROC
  LOCALS
  mov si,320
  mov di,200     
  xor bx,bx
@@yloop:
  mov cx,si
    @@xloop:

      push cx
      movzx eax,di
      and ecx,0000FFFFh   ;Clear the high part of cx 
      mul ecx             
      pop cx
  
      mov ax,cx
      and ax,di
      mov es:[bx],al      ;Plot the point
      inc bx              ;Next pixel is ready....
      loop @@xloop
  dec di
  cmp di,0000h
  jnz @@yloop                         
  ret
ENDP

; Hmm....
;  a(i,j) = i*i*j  mod 256
;
;
dopic3 PROC
  LOCALS
  mov si,320
  mov di,200     
  xor bx,bx
@@yloop:
  mov cx,si
    @@xloop:
      movzx eax,di
      and ecx,0000FFFFh   ;Clear the high part of cx 
      mul ecx             ;The color we want is in al now
      mul ecx
      mov es:[bx],al      ;Plot the point
      inc bx              ;Next pixel is ready....
      loop @@xloop
  dec di
  cmp di,0000h
  jnz @@yloop                         
  ret
ENDP


; Hmm....
;  a(i,j) = i*j*j  mod 256
;
;
dopic4 PROC
  LOCALS
  mov si,320
  mov di,200     
  xor bx,bx
@@yloop:
  mov cx,si
    @@xloop:
      movzx eax,di
      and ecx,0000FFFFh   ;Clear the high part of cx 
      mul eax             ;The color we want is in al now
      mul ecx
      mov es:[bx],al      ;Plot the point
      inc bx              ;Next pixel is ready....
      loop @@xloop
  dec di
  cmp di,0000h
  jnz @@yloop                         
  ret
ENDP


; Puts the color i*j/ (mouseX*mouseY) mod 64 into the pallete
; or something like that....
;
;
rotPal1 PROC
  LOCALS
  xor di,di
@@outerloop:  
  xor si,si
    ;loop through the pallete registers.....
    @@innerloop:
      ;Store mouseX * mouseY in ecx
      getmousestats
      shr cx,1
      inc cx
      shr dx,1
      inc dx
      movzx eax,cx
      and   edx,0000FFFFh
      mul   edx
      mov   ecx,eax         
      
      ;Store currX * currY in eax
      movzx eax,si
      movzx edx,di
      mul   edx
      
      ;Compute: currX*currY / mouseX*mouseY : mouseX*mouseY != 0
      cmp ecx,00000000h
      jne @@okay
      inc cx
    @@okay:
      div ecx
      mov bx,si
      pokecolor bl,00h,00h,ah
      inc si          
      cmp si,00FFh    
      jl @@innerloop         
  inc di               
  getmousestats        
  test bx,LEFTMOUSE   
  jz @@outerloop       
  ret
ENDP


; Puts the color i*j/ (mouseX*mouseY) ^i ^j mod 64 into the pallete
; or something like that....
;
;
rotPal4 PROC
  LOCALS
  xor di,di
@@outerloop:  
  xor si,si
    ;loop through the pallete registers.....
    @@innerloop:
      ;Store mouseX * mouseY in ecx
      getmousestats
      shr cx,1
      inc cx
      shr dx,1
      inc dx
      movzx eax,cx
      and   edx,0000FFFFh
      mul   edx
      mov   ecx,eax         
      
      ;Store currX * currY in eax
      movzx eax,si
      movzx edx,di
      mul   edx
      xor ax,si
      xor ax,di

      ;Compute: currX*currY / mouseX*mouseY : mouseX*mouseY != 0
      cmp ecx,00000000h
      jne @@okay
      inc cx
    @@okay:
      div ecx
      mov bx,si
      pokecolor bl,00h,00h,ah
      inc si          
      cmp si,00FFh    
      jl @@innerloop         
  inc di               
  getmousestats        
  test bx,LEFTMOUSE   
  jz @@outerloop       
  ret
ENDP



; slightly different....it changes color without mixing r,g,b
;
;
;
rotPal3 PROC
  LOCALS
  xor di,di
@@outerloop:  
  xor si,si
    ;loop through the pallete registers.....
    @@innerloop:
      ;Store mouseX * mouseY in ecx
      getmousestats
      shr cx,1
      inc cx
      shr dx,1
      inc dx
      movzx eax,cx
      and   edx,0000FFFFh
      mul   edx
      mov   ecx,eax         
      
      ;Store currX * currY in eax
      movzx eax,si
      movzx edx,di
      mul   edx
      
      ;Compute: currX*currY / mouseX*mouseY : mouseX*mouseY != 0
      cmp ecx,00000000h
      jne @@okay
      inc cx
    @@okay:
      div ecx
      mov bx,si
      
      test eax,00040000h
      jz @@noblue
      pokecolor bl,00h,00h,ah
      jmp @@colorselected
    @@noblue:
      test eax,00080000h
      jz @@nogreen
      pokecolor bl,00h,ah,00h
      jmp @@colorselected
    @@nogreen:
      pokecolor bl,ah,00h,00h
    @@colorselected:
      inc si          
      cmp si,00FFh    
      jl @@innerloop  
  
  inc di               
  getmousestats        
  test bx,LEFTMOUSE   
  jz @@outerloop       
  ret
ENDP


;
;  This one mixes r,g,and b when it changes
;
;
rotPal2 PROC
  LOCALS
  xor di,di
@@outerloop:  
  xor si,si
    ;loop through the pallete registers.....
    @@innerloop:
      ;Store mouseX * mouseY in ecx
      getmousestats
      shr cx,1
      inc cx
      shr dx,1
      inc dx
      movzx eax,cx
      and   edx,0000FFFFh
      mul   edx
      mov   ecx,eax         
      
      ;Store currX * currY in eax
      movzx eax,si
      movzx edx,di
      mul   edx
      
      ;Compute: currX*currY / mouseX*mouseY : mouseX*mouseY != 0
      cmp ecx,00000000h
      jne @@okay
      inc cx
    @@okay:
      div ecx
      mov bx,si
      
      test eax,00040000h
      jnz @@noblue
      mov cx,ax
      shr cx,8
      mov ch,bl
      peekcolor ch
      pokecolor ch,ah,dl,cl
      jmp @@colorselected
    @@noblue:
      test eax,00080000h
      jnz @@nogreen
      mov cx,ax
      shr cx,8
      mov ch,bl
      peekcolor ch
      pokecolor ch,ah,cl,al
      jmp @@colorselected
    @@nogreen:
      mov cx,ax
      shr cx,8
      mov ch,bl
      peekcolor ch
      pokecolor ch,cl,dl,al
    @@colorselected:
      inc si          
      cmp si,00FFh    
      jl @@innerloop  
  
  inc di               
  getmousestats        
  test bx,LEFTMOUSE   
  jz @@outerloop       
  ret
ENDP






 ;;;
 ;;;
 ;;;   main procedure
 ;;;
 ;;;     
main PROC
  LOCALS

  mov ax,@data    ;Data seg is set up
  mov ds,ax

  resetmouse
  movemouse 2,2

  ;Display acknowledgement and instructions to the screen...
  mov ah,09h
  mov dx,OFFSET cheezymessage
  int 21h

  ;Let the user escape if no VGA, or MOUSE
  mov ah,09h  ;Put string
  mov dx,OFFSET warningmessage
  int 21h

  mov ah,01h  ;Get char
  int 21h
  cmp al,'y'
  je @@yesmousevga
  cmp al,'Y'
  je @@yesmousevga
  
  mov ah,09h
  mov dx,OFFSET losermessage
  int 21h
  jmp @@bye

@@yesmousevga:  
  mov ah,09h
  mov dx,OFFSET okaymessage
  int 21h

@@waitformousepress:  
  getmousestats
  test bx,LEFTMOUSE
  jz @@waitformousepress

  mov ax,0A000h   ;Graphics creen seg is set up
  mov es,ax
  waitforretrace
  graphmode
@@begin:
  
  ;Check to see if the user wants out....
  getmousestats
  test bx,RIGHTMOUSE
  jnz @@end

  call dopic1
  call rotpal2

  call dopic2
  call rotpal3

  call dopic3
  call rotpal1

  call dopic4
  call rotpal2

  call dopic6
  call rotpal2

  call dopic5
  call rotpal2

  call dopic1
  call rotpal1

  call dopic2
  call rotpal4

  call dopic3
  call rotpal3

  call dopic1
  call rotpal3
  
  call dopic2
  call rotpal2

  call dopic3
  call rotpal1

  jmp @@begin
@@end:
  textmode
@@bye:  
  mov ax,4C00h
  int 21h
  ret
ENDP

END main
