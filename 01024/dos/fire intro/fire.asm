.model tiny
.386
 locals %%
.code
 org 100h
begin:
 ;set_vga_mode
 mov al,13h
 int 10h
 ;reset memory size
 mov sp,program_size+psp_size+stack_size
 mov ah,4ah
 mov bx,(program_size+psp_size+stack_size) shr 4+1
 int 21h
 ;create buffers
 mov cl,3
 mov di,offset buffer_video
 mov bx,buffer_size shr 4+1
 %%create_buffers:
  mov ah,48h
  int 21h
  push cs
  pop es
  stosw
  pusha
  mov es,ax
  xor ax,ax
  xor di,di
  mov ch,7dh
  rep stosw
  popa
 loop %%create_buffers
 ;get_font_ptr
 mov ax,1130h
 mov bh,03h
 int 10h
 mov word ptr font_addr,bp
 mov word ptr font_addr+2,es
 ;set_fire_palette
 mov bl,max_fire_color+64
 mov bh,64
 mov cl,bh
 mov ch,bh
 %%set_b:
  dec bl
  dec cl
  sub ch,2
  sub bh,2
  call screen_set_rgb_palette
  cmp bl,max_fire_color+64-32
 jnz %%set_b
 %%set_r:
  dec bl
  dec cl
  call screen_set_rgb_palette
  cmp bl,max_fire_color
 jnz %%set_r
 mov bh,63
 mov cl,bh
 mov ch,bh
 %%set_123:
  dec bl
  dec ch
  call screen_set_rgb_palette
  cmp bl,63*2
 jnz %%set_123
 %%set_12:
  dec bl
  dec cl
  call screen_set_rgb_palette
  cmp bl,bh
 jnz %%set_12
 %%set_3:
  dec bh
  call screen_set_rgb_palette
  dec bl
 jnz %%set_3
 mov cx,1
 xor di,di
 ;push di=0 (for retn)
 push di
 %%repeat:
  dec cx
  jnz %%next
  push cs
  pop ds
  mov es,buffer_text
  mov si,offset string
  add si,di
  mov ah,text_color
  mov cx,text_x
  mov dx,text_y
  mov bl,text_scale
;buffer_write_string
  %%write:
   push cs
   pop ds
   lodsb
   test al,al
   jz %%exit
   push bx
   ;buffer_write_char
   pusha
   lds si,font_addr
   push ax
   xor ah,ah
   shl ax,3
   add si,ax
   xor di,di
   add di,cx
   mov ax,dx
   shl ax,8
   add di,ax
   mov ax,dx
   shl ax,6
   add di,ax
   pop ax
   mov dl,bl
   mov bh,bios_font_size
   xor dh,dh
   %%draw_char:
    lodsb
    mov bl,bios_font_size
    %%draw_line:
     shl al,1
     jnc %%nl
      push ax
      push di
      xchg ah,al
      mov ah,dl
      %%draw:
       mov cl,dl
       xor ch,ch
       rep stosb
       add di,max_x
       sub di,dx
       dec ah
      jnz %%draw
      pop di
      pop ax
     %%nl:
     add di,dx
     dec bl
    jnz %%draw_line
    push dx
    %%l2:
     add di,max_x-bios_font_size
     dec dl
    jnz %%l2
    pop dx
    dec bh
   jnz %%draw_char
   popa
   pop bx
   push bx
   %%l:
    add cx,bios_font_size
    dec bl
   jnz %%l
   pop bx
  jmp short %%write
  %%exit:
   add di,text_string_size
   cmp di,last_string
   jl %%not_last_string
    xor di,di
   %%not_last_string:
   mov cx,text_show_delay
  %%next:
  ;draw_random_line
  pusha
  mov ds,cs:buffer_fire
  mov bx,fire_draw_count
  %%draw_rl:
   mov cx,max_x
   call random
   mov di,dx
   mov byte ptr [di+buffer_size-max_x],max_fire_color
   dec bx
  jnz %%draw_rl
  ;blur
  mov cx,buffer_size
  xor di,di
  xor ah,ah
  %%blur_f:
   mov al,[di+max_x-1]
   mov bx,ax
   mov al,[di+max_x+1]
   add bx,ax
   mov al,[di+1]
   add bx,ax
   mov al,[di-1]
   add bx,ax
   shr bx,2
   mov al,[di]
   add bx,ax
   shr bx,1
   jz %%skip
    dec bx
   %%skip:
   mov [di+fire_filter_parallax],bl
   inc di
  loop %%blur_f
  mov ds,cs:buffer_text
  mov di,max_x
  xor ah,ah
  mov cx,buffer_size-2*max_x
  %%blur_text:
   mov al,[di+max_x]
   mov bx,ax
   mov al,[di-max_x]
   add bx,ax
   mov al,[di+1]
   add bx,ax
   mov al,[di-1]
   add bx,ax
   shr bx,2
   mov al,[di]
   add bx,ax
   shr bx,1
   mov [di+text_filter_parallax],bl
   inc di
  loop %%blur_text
  mov es,cs:buffer_video
  mov ds,cs:buffer_fire
  call buffer_move
  mov es,cs:buffer_video
  mov ds,cs:buffer_text
  ;buffer_zero_move
  xor di,di
  xor si,si
  %%move:
   lodsb
   test al,al
   jnz %%not_zero
    inc di
    jmp short %%nxt
   %%not_zero:
    add al,true_text_color
    stosb
   %%nxt:
   cmp di,buffer_size
  jnz %%move
  ;wait_retrace
  mov dx,3dah
  %%v1:
   in al,dx
   test al,8
  jz %%v1
  %%v2:
   in al,dx
   test al,8
  jnz %%v2
  mov ds,cs:buffer_video
  push video_memory
  pop es
  call buffer_move
  ;clear_random_line
  mov ds,cs:buffer_fire
  mov bx,fire_clear_count
  %%clear_rl:
   mov cx,max_X
   call random
   mov di,dx
   mov byte ptr [di+buffer_size-max_x],ah
   dec bx
  jnz %%clear_rl
  popa
  in al,60h
  das
 jc %%repeat
 ;set_text_mode
 mov ax,0003h
 int 10h
 ;the end
 buffer_move proc near;ds,es<-source_buffer,dest_buffer
  xor si,si
  xor di,di
  mov ch,7dh
  rep movsw
  retn
 buffer_move endp
 screen_set_rgb_palette proc near ;bl,bh,cl,ch<-color,rgb.
  pusha
  mov dx,3c8h
  mov al,bl
  out dx,al
  inc dx
  mov al,bh
  out dx,al
  mov al,cl
  out dx,al
  mov al,ch
  out dx,al
  popa
  retn
 screen_set_rgb_palette endp
 random proc near
  mov ax,cs:seed
  add ax,1234
  xor al,ah
  mov cs:seed,ax
  xor dx,dx
  div cx
  retn
 random endp
 max_x equ 320
 max_y equ 200
 psp_size equ 100h
 stack_size equ 100h
 buffer_size equ 320*200
 video_memory equ 0a000h
 text_show_delay equ 80
 text_scale equ 3
 max_fire_color equ 3*63
 bios_font_size equ 8
 text_color equ 62
 true_text_color equ 3*63
 text_string_size equ 13
 text_x equ (max_x-bios_font_size*text_scale*(text_string_size-1))/2
 text_y equ 200/2-2*bios_font_size*text_scale
 fire_draw_count equ 90
 fire_clear_count equ 70
 text_filter_parallax equ 0
 fire_filter_parallax equ -max_x
 string db ' Fire intro ',0
        db '     by     ',0
        db 'Tyler Durden',0
        db '   email :  ',0
        db '@tylerdurden',0
        db '  .net.ru   ',0
        db '   site :   ',0
        db '     www    ',0
        db '.tylerdurden',0
        db '  .net.ru   ',0
 last_string equ $-offset string
 buffer_video dw ?
 buffer_fire dw ?
 buffer_text dw ?
 font_addr dd ?
 seed dw ?
 program_size equ $-offset begin
end begin
