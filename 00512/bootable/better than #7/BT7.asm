; Better Than #7 (BT7)
; asmcompo #8
; entry by : mov (c) 2004
; date     : 02/29/04



[bits 16]
[org 0x7C00]

start:
	xor ax, ax			        ;set segments
  mov ds, ax

	cli                    ; no ints
	mov ax, 0x9000         ; top of conv. mem.
	mov ss, ax
	mov sp, 0xFFFC         ; start stack at top
	sti                    ; ints plz
	
	mov ax, 0x0013         ; set mode 13h
	int 0x10               ; using int 10h
	
  xor ax, ax              ; set up palette
  mov dx, 0x3C8
  out dx, al
  inc dx
  mov cl, 0x00
	palette1:
    mov al, cl
    shr al, 2             ; two upper bits are not used
    out dx, al            ; set Red

    xor ax, ax            ; clear ax
    out dx, al            ; no Green
    out dx, al            ; no Blue

    inc cl
    cmp cl, 0x80          ; only go half-way
    jne palette1
  palette2:
    mov al, cl
    shr al, 2             ; two upper bits are not used
    out dx, al            ; set Red

    xor ax, ax            ; clear ax
    out dx, al            ; no Green
    out dx, al            ; no Blue

    dec cl
    jnz palette2          ; now go back to 0

  push word 0x4000        ; clear backbuf
  pop es
  call clearbuf

  mov bx, 320             ; x coord
  xor bp, bp

main:
  push word 0x4000        ; backbuf
  pop es
  call clearbuf           ; clear backbuf

  mov di, y_scroll_pos    ; y value
  mov ax, bp
  inc bp

  cmp bx, 0               ; scroll text (bx (mod 320))
  jnz bl_ok
  mov bx, 320
  bl_ok:
  dec bx
  
  push bx                 ; save bx (x value)

  mov cx, char_buf_len/2  ; since every character pointer is two bytes, divide
                          ; char_buf_len by 2 to get number of characters
 char_draw_loop:
  imul si, cx, 2          ; multiply cx by 2 and store in si
  neg si                  ; make negative (fetch characters from end of buf)
  mov si, [cs:char_buf+char_buf_len+si]  ; get pointer to character from buf
  call drawchar           ; draw character
  add bx, 9               ; make room for next character
  loop char_draw_loop     ; loop until cx = 0 (cx was the number of characters)


  pop bx                  ; restore bx

  mov dx, 0x3DA           ; vsync port
  vsync1:
    in al, dx
    test al, 8
    jz vsync1
  vsync2:
    in al, dx
    test al, 8
    jnz vsync2

  push es                 ; set up segments for cls and copy
  pop ds
  mov ax, 0xA000
  mov es, ax

  call clearbuf           ; clear screen
  
  mov cx, 16000           ; copy backbuf to screen
  xor di, di
  xor si, si
  rep movsd

  mov ah, 1               ; check for keypress
  int 0x16
  jz main
  jmp 0xFFFF:0x0000       ; reboot


clearbuf:
  xor di, di              ; clear buf at es
	xor eax, eax
  mov cx, 16000
	rep stosd
	ret

;usage: mov si, char_offset
;       mov bx, x_coord
;       mov di, y_coord
;       mov al, byte_to_write
;       call drawchar
drawchar:
  push bp                       ; save regs
  push di
  push cx
  push dx
  
  imul di, 320                  ; multiply y coord by colums
  lea dx, [di+320]              ; set edge to coord(0, y+1)
  mod_bx:                       ; do bx (mod 30)
    cmp bx, 320                 ; if bx < 320
    jb bx_lessthan_320          ;   then don't do anything
    sub bx, 320                 ; else, subtract 320 from bx and
    jmp mod_bx                  ;   do over again
  bx_lessthan_320:
  add di, bx                    ; add x coord
  mov bp, si                    ; load bp
  add bp, 8                     ;   with end address of character
  drawchar_start:
    mov cl, [cs:si]             ; load byte at si (pointing to character)
    mov ch, 8                   ; set counter for bits in al
  drawchar_next_bit:
    cmp di, dx                  ; check if a pixel crosses the edge
    jnz drawchar_no_edge        ; if not, don't alter anything, just procede
    sub di, 320                 ; else, set y = y - 1 (<=> di = di - 320),
                                ;   printing on the same row and not the next one
  drawchar_no_edge:
    shl cl, 1                   ; shift out one bit
    jnc drawchar_background     ; if a 0 was shifted out, don't draw anything
    stosb                       ; if a 1 was shifted out, plot a pixel
    dec ch                      ; decrease cl's bit counter (bits left to process)
    jnz drawchar_next_bit       ; not done with this byte? continue with next bit
    jmp drawchar_next_byte      ; done with this byte? continue with the next
  drawchar_background:
    inc di                      ; increase drawing pointer, drawing a "blank" pixel
    dec ch                      ; decrease cl's bit counter
    jnz drawchar_next_bit       ; not done with this byte? continue with next bit
  drawchar_next_byte:
    mov di, dx                  ; di = start of next line +
    add di, bx                  ;      x coordinate  (simply coord(x, y+1))
    add dx, 320                 ; update left edge (y = y + 1 <=> dx = dx + 320)
    
    inc si                      ; increase pointer to character buf for next line
    cmp si, bp                  ; are we finished with the character?
    jne drawchar_start          ; not finished? get another byte then.
    
    pop dx                      ; restore registers
    pop cx
    pop di
    pop bp
    ret                         ; done? then return


char_m      db 0x00, 0x00, 0x5B, 0x6D, 0x49, 0x92, 0x92, 0x92
char_o      db 0x00, 0x00, 0x00, 0x38, 0x44, 0x44, 0x48, 0x30
char_v      db 0x00, 0x00, 0x44, 0x24, 0x24, 0x28, 0x28, 0x10
char_a      db 0x00, 0x00, 0x0C, 0x22, 0x0E, 0x34, 0x44, 0x38
char_G      db 0x0C, 0x12, 0x20, 0x40, 0x80, 0x8E, 0x42, 0x3E
char_e      db 0x00, 0x00, 0x18, 0x24, 0x48, 0x70, 0x44, 0x38
char_t      db 0x00, 0x00, 0x08, 0x3C, 0x10, 0x10, 0x24, 0x18
char_r      db 0x00, 0x00, 0x2C, 0x52, 0x10, 0x10, 0x10, 0x20
char_z      db 0x00, 0x00, 0x3C, 0x48, 0x10, 0x10, 0x22, 0x7C
char_s      db 0x00, 0x00, 0x38, 0x44, 0x20, 0x1C, 0x42, 0x3C
char_excl   db 0x10, 0x38, 0x38, 0x38, 0x10, 0x10, 0x00, 0x10
char_hash   db 0x12, 0x12, 0x7F, 0x24, 0x24, 0xFE, 0x48, 0x48
char_space  db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
char_A      db 0x1C, 0x22, 0x21, 0x21, 0x3F, 0x42, 0x42, 0x42
char_l      db 0x08, 0x08, 0x10, 0x10, 0x10, 0x20, 0x28, 0x10
char_y      db 0x00, 0x00, 0x22, 0x12, 0x0A, 0x04, 0x48, 0x30
char_b      db 0x10, 0x10, 0x20, 0x20, 0x38, 0x44, 0x44, 0x38
char_n      db 0x00, 0x00, 0x28, 0x34, 0x42, 0x42, 0x84, 0x84
char_g      db 0x00, 0x00, 0x18, 0x24, 0x1C, 0x04, 0x48, 0x30
char_u      db 0x00, 0x00, 0x22, 0x22, 0x44, 0x44, 0x4C, 0x34
char_colon  db 0x00, 0x18, 0x18, 0x00, 0x00, 0x18, 0x18, 0x00

char_buf  dw char_A, char_l, char_l, char_space
          dw char_y, char_o, char_u, char_r, char_space
          dw char_b, char_a, char_s, char_e, char_space
          dw char_a, char_r, char_e, char_space
          dw char_b, char_e, char_l, char_o, char_n, char_g, char_space
          dw char_t, char_o, char_space
          dw char_hash, char_a, char_s, char_m
          dw char_space, char_colon, char_colon
char_buf_len EQU $-char_buf


y_scroll_pos EQU 0x0064



times 510-($-$$) db 0	      ; pad sector
dw 0xAA55                   ; boot signature
