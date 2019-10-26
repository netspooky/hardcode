; melody:
;  - precalc tracks after each pattern
;  q3
; drums: simple
; instruments:
;  - precalced drums
;  - realcalced bass & lead ?

hook_timer:
        push cs
	pop ds

	mov si,oldint
	lodsw ; ax=3508h
	int 21h

	lodsw ; ax=4000h
	mov word[si-4],bx
	mov word[si-2],es

	mov dx,timer_handler
	.addr equ $-2

set_timer:

	cli
        mov al,0x36
        out 0x43,al
	mov al,0
        out 0x40,al
	mov al,ah
        out 0x40,al
        mov ax,0x2508
        int 0x21
	sti
	ret

;timer_handler_sb:	; fake dma
;
;	pusha
;	push ds
;	cld
;
;	push cs
;	pop ds
;
;	mov si,666
;	.sbptr equ $-2
;
;	mov dx,0x22c	; direct sendbyte: command, wait
;	.sbwrite equ $-2
;.w0:	in al,dx
;	test al,al
;	js .w0
;	mov al,0x10
;	out dx,al
;.w1:	in al,dx
;	test al,al
;	js .w1
;
;	lodsw
;	sar ax,4         ; clip
;	add ax,128
;	test ah,ah
;	je .c0
;	  mov al,ah
;	  neg ax
;.c0:	out dx,al
;
;.c1:	mov [.sbptr],si
;
;	test si,0xff
;	jnz brkint
;
;	jmp timer_handler.posttape

timer_handler:

        pushad    ;po
	push ds  ;po
        push es
	cld	 ;po
	
	push cs  ;po
        push cs
	pop ds   ;po
        pop es

	;; koodia ;;

;.posttape:

	mov ax,0
	timer equ $-2
	inc word[timer]
        push ax

;;;;;;

        test al,7
        jne .kukko
	call player	; UNREM
        .kukko:
;        jmp brkint0

;        add dword [rotate_angles],0x030204
        add word [rotate_angles],0x0102

	add word[render_perspective.x0],1556
	add word[render_perspective.y0],663

	inc word[ifsparms+8*0]
	dec word[ifsparms+8*1]

tunnel_handler:

	add word[drawtunnel.offset],0x0104
	.tunspeed equ $-2

	mov ax,[drawtunnel.open]
	mov bx,0
	  .step equ $-2
	  
	  add al,bl
	  jnc .o0
              mov al,235
	      xor bx,bx
	  .o0:
	  sub al,bh
	  jnc .o1
	      mov al,1
	      xor bx,bx
	  .o1:
	  mov [drawtunnel.open],ax
	  mov [tunnel_handler.step],bx


curtain_polator: ;;;;;;;;;;;;;;;

       mov ax,[curtain.loc]
       cmp ah,al
       je .o3
       jc .o2
               sub ah,4
              jmp .o3
       .o2    add ah,4
       .o3    mov [curtain.loc],ax

palette_fader: ;;;;;;;;;;;;;;;;;

mov ax,0               ; palette fade cycles left
.fadeleft equ $-2
test ax,ax
jz .o0
      dec word [.fadeleft]

      mov si,palette_temp

      mov dx,0x3c8
      xor ax,ax
      out dx,al
      inc dx
      mov cx,768
.l0:  lodsb                   ; current
      mov ah,[si+768*2-1]     ; new
      add [si+768-1],ah       ; fraction+=new
.dir: sbb al,0       ;adc
      mov [si-1],al           ; cur+=fraxxonz overflow
      out dx,al
      loop .l0
.o0:

	;;;;;;;;;;;
brkint0:
        pop ax
	test al,3
brkint:	mov al,20h
	out 20h,al
        pop es
	pop ds
        popad
	jne ..@sk

	jmp 4000h:3508h
	oldint equ $-4

..@sk	iret

timer_off:

	push cs
	pop ds
	lds dx,[oldint]     
	xor ax,ax
	call set_timer

	mov ax,3		
	xor bx,bx
	int 0x10
	ret

;interpolate:
;
;        ; si=original
;        ; di=destination
;        ; dx=step
;        ; cx=numbytes
;
;.l0     lodsb
;        sub al,[di]
;        cbw
;        js .c0
;                ; [si]>[di] - [si]-[di] >=0
;                cmp ax,dx
;                jc .c1
;                        mov ax,dx
;                .c1:
;                sub [si-1],al
;                xor ax,ax
;
;                ; [di]>[si]
;        .c0     neg ax
;                cmp ax,dx   ; askel
;                jc .c2
;                        mov ax,dx
;                .c2:
;                add [si-1],al
;        inc di
;        loop .l0
;        ret
