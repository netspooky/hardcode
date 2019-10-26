

[ORG 0x100]
[BITS 16]

; SOME DEFINES

%idefine NULL 0x00000000
%idefine IRQ1 0x09
%idefine INT16h 88
%idefine INT8 0x1C
%idefine TRUE 1
%idefine FALSE 0
%idefine ENEMY 12



jmp @start

; VARIABLES

@old_irq1_handler: dd NULL
@old_int8_handler: dd NULL

@str_welcome:  
db 0xBA, "    <<< Welcome to Graindowars >>>    ", 0xBA, 0

@str_pres:  
db 0xBA, "    code : #ponce (www.adinpsz.org)   ", 0xBA, 0

@press_space:
db 0xBA, "   > Press SPACE to start the game <  ", 0xBA, 0
  
@game_is_finished: db FALSE

@player_pos_x: db 1
@player_pos_y: db 9

@display_page: db 0

@space_pressed: db 0
@up_pressed: db 0
@down_pressed: db 0
@left_pressed: db 0
@right_pressed: db 0
@cond : db 0

@women_x: times 32 db -1
@women_y: times 32 db -1

@missil: times 40 db -1 ; no missile

@gameover: db 1



@new_game: 
	mov byte [@player_pos_y], 9	
	mov byte [@player_pos_x], 1
	
	mov byte [@cond], 0
	
	mov si, 0
	@init_women:	
		
		mov byte [si + @women_x], 255
		mov byte [si + @women_y], 255
		
		inc si
		cmp si, 32
	jne @init_women
	
	mov si, 0
	@init_missil:
		mov byte [si + @missil], 255
		inc si
		cmp si, 40
	jne @init_missil
	mov byte[@gameover], 0
	
	ret
	
	
@flip:
	mov al, 1
	sub al, [@display_page]
	mov [@display_page], al  ; flip page
	mov ah, 0x05
	int 0x10
    ret
    
@get_buffer_seg:
	mov al, 1
	sub al, [@display_page]
	mov ah, 0
	mov cx, 0x80
	mul cx
	
	;mov ax, 0x80
	add ax, 0xB800
	mov es, ax	
	ret


@irq1_handler:
	pusha
	cli
	push ds
	push es
	push cs
	pop ds
	xor ax,ax
	mov es,ax
	in al,0x60 ; read the scan code
	push ax
	mov al,0x20 ; send EOI to PIC controller
	out 0x20,al
	pop ax
	
	; something to do with the scancode
	cmp al, 0x1 ; ESCAPE pressed
	jne @irq1_skip1
	mov byte [@game_is_finished], 1
	@irq1_skip1:
	
	cmp al, 57 ; SPACE pressed
	jne @irq1_skip2
	mov byte [@space_pressed], 1
	@irq1_skip2:
	
	cmp al, (57 + 0x80) ; SPACE released
	jne @irq1_skip3
	mov byte [@space_pressed], 0
	@irq1_skip3:
	
	cmp al, 72 ; UP pressed
	jne @irq1_skip4
	mov byte [@up_pressed], 1
	@irq1_skip4:
	
	cmp al, (72 + 0x80) ; UP released
	jne @irq1_skip5
	mov byte [@up_pressed], 0
	@irq1_skip5:
	
	cmp al, 80 ;down pressed
	jne @irq1_skip6
	mov byte [@down_pressed], 1
	@irq1_skip6:
	
	cmp al, (80 + 0x80) ; down released
	jne @irq1_skip7
	mov byte [@down_pressed], 0
	@irq1_skip7:
	
	cmp al, 75 ; left pressed
	jne @irq1_skip8
	mov byte [@left_pressed], 1
	@irq1_skip8:
	
	cmp al, (75 + 0x80) ; left released
	jne @irq1_skip9
	mov byte [@left_pressed], 0
	@irq1_skip9:
	
	cmp al, 77 ; right pressed
	jne @irq1_skip10
	mov byte [@right_pressed], 1
	@irq1_skip10:
	
	cmp al, (77 + 0x80) ; right released
	jne @irq1_skip11
	mov byte [@right_pressed], 0
	@irq1_skip11:	
	
	
	@finish:
	pop es
	pop ds
	popa
	iret
	
@int8_handler:
	pusha
	push ds
	push es
	push cs
	pop ds
	mov byte [@cond], 1
	mov al,0x20 ; send EOI to PIC controller
	out 0x20,al
	pop es
	pop ds
	
	popa
	iret

@rand18: ; return in al, modify eax, edx
	rdtsc
	
	and al, 15
	and ah, 1	
	add al, 1
	add al, ah
	ret

@start:
	
	



@hook_keyboard_start:

	xor ax,ax
	mov es,ax
	mov eax,[es:IRQ1 * 4]           ; store previous hook
	mov [@old_irq1_handler],eax
	cli ; install keyboard hook
	mov word [es:IRQ1 * 4 + 2],cs
	mov word [es:IRQ1 * 4 ], @irq1_handler
	sti
	
	
@set_mode_texth:

	mov ax, 0x1
	int 0x10

; hide cursor	
	mov ch, 32
   	mov ah, 1
   	int 10h
   	
; disable blinking
	mov ax, 0x1003
	mov bx, 0   
	int 0x10


	
	call @new_game
	call @fill
	call @flip
	
	xor ax,ax
	mov es,ax
	mov eax,[es:INT8 * 4]           ; store previous hook
	mov [@old_int8_handler],eax
	cli ; install keyboard hook
	mov word [es:INT8 * 4 + 2],cs
	mov word [es:INT8 * 4 ], @int8_handler
	sti
	
; MAIN LOOP
@main_loop:


	
	call @fill	
	
	cmp byte[@gameover], 0
	jne @skip_game	

		; move
		
		cmp byte [@down_pressed], 1
		jne @main_skip1
			mov al, byte[@player_pos_y]
			cmp al, 17
			jge @main_skip11
				inc al
				mov byte[@player_pos_y], al
			@main_skip11:
		@main_skip1:
			
		cmp byte [@up_pressed], 1	
		jne @main_skip2
			mov al, byte[@player_pos_y]
			cmp al, 1
			jle @main_skip21
				dec al
				mov byte[@player_pos_y], al
			@main_skip21:
		@main_skip2:
		
		cmp byte [@left_pressed], 1	
		jne @main_skip8
			mov al, byte[@player_pos_x]
			cmp al, 0
			jle @main_skip81
				dec al
				mov byte[@player_pos_x], al
			@main_skip81:
		@main_skip8:
		
		cmp byte [@right_pressed], 1	
		jne @main_skip9
			mov al, byte[@player_pos_x]
			cmp al, 37
			jge @main_skip91
				inc al
				mov byte[@player_pos_x], al
			@main_skip91:
		@main_skip9:
		
		; move women	
		mov di, 0
		@loop_women_1:	
			mov al, [di + @women_x]
			cmp al, 0
			
			jns @loop_women_11
				
			@restart_women:
				mov bl, 40
				call @rand18
				add bl, al
				call @rand18
				add bl, al
				mov [di + @women_x], bl
				
				call @rand18
				mov [di + @women_y], al
	
				jmp @endif_women
				
			@loop_women_11:
				
				cmp al, 40
				jge @no_collision				
					mov ah, [di + @women_y]
					movzx si, al
					cmp ah, [si + @missil]
					jne @ca_passe1
					
					mov byte [si + @missil], 255
					jmp @restart_women
					
					@ca_passe1:		
					
					pusha
					call @checkcollisionwithplayer 
					popa
					
				@no_collision :
				
				
					
				dec al
				
				cmp al, 40
				jge @no_collision2				
				or al, al
				js @no_collision2			
					mov ah, [di + @women_y]
					movzx si, al
					cmp ah, [si + @missil]
					jne @ca_passe2
					
					mov byte [si + @missil], 255
					jmp @restart_women
					
					@ca_passe2:										
					pusha
					call @checkcollisionwithplayer 
					popa
				@no_collision2:
				
				
				
				mov [di + @women_x], al
			@endif_women:
			
			inc di
			cmp di, 32
		jne @loop_women_1	
		
		; move missiles
		mov di, 39
		@loop_missil_1:	
			dec di
			mov al, [di + @missil]
			mov [di + @missil + 1], al		
			cmp di, 0
		jne @loop_missil_1
		
		mov byte [@missil], 255
		
		
		call @draw_women
		call @draw_missile
		call @draw_player
		
		cmp byte [@space_pressed], 1
		jne @main_skip3
			call @create_missile
		@main_skip3:
	
	jmp @end_main_if
	
	@skip_game:
	
		cmp byte [@space_pressed], 1
		jne @main_skip4
			call @new_game
		@main_skip4:
		
	
	@end_main_if:
	
	; wait a bit to slow down things
	
	call @flip
	
	; wait timer
	
	@active_wait:
	
	cmp byte [@cond], 0
	pause
	je @active_wait
	mov byte [@cond], 0
		
	
	cmp byte [@game_is_finished], TRUE
	jnz @main_loop


@end_of_game:

; restore previous hook
	mov eax,[@old_irq1_handler] 
	mov [es:IRQ1 * 4],eax
	
; restore previous hook
	mov eax,[@old_int8_handler] 
	mov [es:INT8 * 4],eax
	
	ret
	
	
@print: ; give it a string in ds:si, attribute in AH
	mov al, [si]
	inc si
    cmp al, 0
    jz @print_finished
    stosw ; print it    
    jmp @print ; and loop until 0
    
@print_finished:
	ret
	
@create_missile:

	mov al, [ @player_pos_y ]
	movzx si, byte [@player_pos_x]
	mov [@missil+2+si], al
	ret
	
@checkcollisionwithplayer: ; AL = X AH = Y

	mov bl, [@player_pos_x]
	mov bh, [ @player_pos_y ]
	cmp ax, bx
	je @boom
	inc bh
	cmp ax, bx
	je @boom
	sub bh, 2
	cmp ax, bx
	je @boom
	inc bh
	inc bl
	cmp ax, bx
	je @boom
	inc bl
	cmp ax, bx
	je @boom
	
	jmp @no_soucy
	@boom:
		mov byte[@gameover], 1
		
	@no_soucy:
	ret
	
@draw_missile:

	call @get_buffer_seg
	
	mov si, 0
	@loop_draw_missile_1:	
		
		mov dl, [si + @missil]
		
		cmp dl, 0
		js @skip_draw_missile
		
		mov di, (3 * 40 * 2)
		movzx ax, dl
		mov cx, 80
		mul cx
		add di, ax
		
		movzx dx, dl
		add di, si
		add di, si		
		
		; draw a missile
		mov ah, 0x4F
		mov al, '-'
		stosw
		
		@skip_draw_missile:
		
		inc si
		cmp si, 40
	jne @loop_draw_missile_1	
	
	ret	
	
@draw_women:
	call @get_buffer_seg
	
	mov si, 0
	@loop_draw_women_1:	
		
		mov dl, [si + @women_x]
		mov dh, [si + @women_y]
		
		cmp dl, 0
		js @skip_draw_women
		
		cmp dl, 38
		jg @skip_draw_women
		
		mov di, (3 * 40 * 2)
		movzx ax, dh
		mov cx, 80
		mul cx
		add di, ax
		
		mov dl, [si + @women_x]
		movzx dx, dl
		add di, dx
		add di, dx
	;	add di, 2
		
		; draw a women
		mov ah, 0x4C
		mov al, 12
		stosw
		
		@skip_draw_women:
		
		inc si
		cmp si, 32
	jne @loop_draw_women_1	
	
	ret

@draw_player:
	
	call @get_buffer_seg
	
	mov di, (3 * 40 * 2)
	movzx ax, byte [ @player_pos_y ]
	mov cx, 80
	mul cx
	add di, ax
	movzx ax, byte [ @player_pos_x ]
	add di, ax
	add di, ax
	
	; draw a cock
	mov ah, 0x4D
	
	mov al, 0xDB
	stosw
	stosw
	mov al, 0x10
	stosw
	sub di, 86
	mov al, 'O'
	stosw
	add di, 158
	mov al, 'O'
	stosw
	
	ret	
	

@fill:  

	call @get_buffer_seg
	
	mov di, 0
	
	; color of border
	mov ah, 0x4E
	
	mov al, 0xC9
	stosw
	
	mov al, 0xCD
	mov cx, 38
	rep stosw
	
	mov al, 0xBB
	stosw
	
	mov si, @str_welcome
	call @print
	
	mov al, 0xC8
	stosw
	
	mov al, 0xCD
	mov cx, 38
	rep stosw
	
	mov al, 0xBC
	stosw
	
	mov dx, 19
	@fill_loop:
		
		mov al, ' '
		mov cx, 40
		rep stosw
		dec dx
	jnz @fill_loop
	
	mov al, 0xC9
	stosw
	
	mov al, 0xCD
	mov cx, 38
	rep stosw
	
	mov al, 0xBB
	stosw
	
	mov si, @str_pres
	cmp byte[@gameover], 0
	je @right_msg
	mov si, @press_space
	@right_msg:
	call @print
	
	mov al, 0xC8
	stosw
	
	mov al, 0xCD
	mov cx, 38
	rep stosw
	
	mov al, 0xBC
	stosw
	ret
	
	
	
