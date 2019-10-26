lightx equ -30*512
lighty equ -20*512
lightz equ 125

makephongpiccy:
		;Calculates the Phong picture (128 shades) at the 0ffffh buffer
		;located at es:ax.

  mov	  cx,0ffffh
  mov	  di,ax
  add	  di,cx
 @donextphongpiccy:
    movzx  ax,cl
    sub    ax,128	     ;x-coordinate
    imul   ax,ax
    movzx  bx,ch
    sub    bx,128	     ;y-coordinate
    imul   bx,bx
    add    bx,ax	     ; bx = y*y+x*x
    neg    bx
    add    bx,128*128-1;64
    jns   @itsnotzero
      xor    bx,bx
      jmp   @colorknown
   @itsnotzero:
    push   cx
    push   di
    shl    bx,2
    call   sqrt 		    ;ax=z-coordinate,0..127
    pop    di
    pop    cx

    imul   eax,lightz
    movzx  ebx,cl
    sub    ebx,128
    imul   ebx,lightx
    add    ebx,eax
    movzx  eax,ch
    sub    eax,128
    imul   eax,lighty
    add    ebx,eax
    jns   @itsnotzero2
    xor    ebx,ebx
   @itsnotzero2:
    mov    eax,ebx
    mul    ebx
    mov    bx,dx
			     ;bx contains color << 10
   @colorknown:
    cmp    bx,13 shl 10
    jns   @inphongspot
      mov    ax,bx
      cwd
      mov    bx,220
      idiv   bx
      add    al, 128
      mov    es:[di],al
      jmp   @pointphongdone
   @inphongspot:
      sub    bx,13 shl 10
      mov    ax,bx
      cwd
      mov    bx,60
      idiv   bx
      add    al,188
      mov    es:[di],al
   @pointphongdone:
    dec    di
    dec    cx
    jnz   @donextphongpiccy
  ret
