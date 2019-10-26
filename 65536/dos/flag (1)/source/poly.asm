
; Program to draw filled triangles on the 256 colour screen

; By D.Hedley 28/6/92


						.model small,c

						public draw_filled_triangle

						extrn screen_seg:word

ssizex					equ 320
ssizey					equ 327

						.data

triangle                label word

						align 2

t_x1                    dw 0
t_y1                    dw 0
t_x2                    dw 0
t_y2                    dw 0
t_x3                    dw 0
t_y3                    dw 0

buffer                  dw 1000 dup(0)

						.code


draw_filled_triangle    proc near

						; draw_filled_triangle(x1,y1,x2,y2,x3,y3,colour);
						;

x1                      equ word ptr 4
y1                      equ word ptr 6
x2                      equ word ptr 8
y2                      equ word ptr 10
x3                      equ word ptr 12
y3                      equ word ptr 14
colour                  equ word ptr 16

.386

						push bp
						mov bp,sp

						cmp x1[bp],ssizex-1
						ja @@1
						cmp y1[bp],ssizey-1
						ja @@1
						cmp x2[bp],ssizex-1
						ja @@1
						cmp y2[bp],ssizey-1
						ja @@1
						cmp x3[bp],ssizex-1
						ja @@1
						cmp y3[bp],ssizey-1
						ja @@1

						push si
						push di
						push es

						push colour[bp]

						cld

						push ds

						mov ax,ds
						mov es,ax
						mov ax,ss
						mov ds,ax
						mov di,offset t_x1
						lea si,x1[bp]

						movsd
						movsd
						movsd

						pop ds

						mov es,screen_seg

						mov ax,t_y1
						cmp ax,t_y2
						jbe s_ok_1

						xchg ax,t_y2
						mov t_y1,ax
						mov ax,t_x1
						xchg ax,t_x2
						mov t_x1,ax

s_ok_1:

						mov ax,t_y2
						cmp ax,t_y3
						jbe s_ok_3

						xchg ax,t_y3
						mov t_y2,ax
						mov ax,t_x3
						xchg ax,t_x2
						mov t_x3,ax

s_ok_2:
						mov ax,t_y1
						cmp ax,t_y2
						jbe s_ok_3

						xchg ax,t_y2
						mov t_y1,ax
						mov ax,t_x1
						xchg ax,t_x2
						mov t_x1,ax

s_ok_3:
						mov bp,t_y3
						mov dx,t_x3
						mov ax,t_y1
						mov bx,t_x1
						mov di,offset buffer

						call calc_line

						mov bp,t_y2
						mov dx,t_x2
						mov ax,t_y1
						mov bx,t_x1
						mov di,offset buffer+2

						call calc_line

						mov bp,t_y3
						mov dx,t_x3
						mov ax,t_y2
						mov bx,t_x2

						call calc_line

						pop bx ; restore colour

						mov bp,t_y3
						sub bp,t_y1
						inc bp

						mov si,offset buffer

						mov al,bl

						imul dx,t_y1,ssizex/4
draw_next_line:
						mov di,[si]
						mov bx,[si+2]
						sub bx,di
						jnc width_pos

						add di,bx
						neg bx
width_pos:
						inc bx

						push ax
						push dx
						call draw_line
						pop dx
						pop ax

						add si,4
						add dx,ssizex/4
						dec bp
						jnz draw_next_line

end_draw_filled_triangle:

						pop es
						pop di
						pop si
@@1:
						pop bp
						ret


draw_filled_triangle   endp


calc_line               proc near

						; Calculates + stores stuff about the line passed to it

						xor cx,cx

						sub bp,ax
						inc bp

						sub dx,bx
						jnc dx_not_neg

						mov cx,2
						neg dx

dx_not_neg:
						inc dx
						mov ax,bx       ; Start address into ax

						mov bx,1        ; assume x major
						sub bx,cx       ; see if going backwards
						mov cx,bp

						cmp dx,bp       ; x major or y major?
						jbe x_major

						mov cx,dx       ; else y major
						xchg bp,dx

						mov si,bp
y_next_pixel:
						sub si,dx ; Dump = Dump - dy
						jnc y_positive

						add si,bp ; Dump = Dump + dx

						mov [di],ax
						add di,4

y_positive:
						add ax,bx ; Add increment
						dec cx
						jnz y_next_pixel

						sub ax,bx
						mov [di],ax
						add di,4

						jmp end_filled_triangle

x_major:

						mov si,bp
x_next_pixel:

						mov [di],ax
						add di,4

						sub si,dx ; Dump = Dump - dy
						jnc x_positive

						add ax,bx ; Add increment
						add si,bp ; Dump = Dump + dx

x_positive:
						dec cx
						jnz x_next_pixel

end_filled_triangle:
                        ret

calc_line               endp


draw_line               proc near

						mov cx,di
						shr di,2
						add di,dx

						and cx,3
						add bx,cx
						mov ch,al
						mov ax,0f02h
						shl ah,cl
						mov dx,03c4h
						sub bx,4
						jg not_same_nibble

						neg bl
						mov cl,bl
						mov bh,0fh
						shr bh,cl
						and ah,bh
						out dx,ax

						mov es:[di],ch
						ret


not_same_nibble:
						out dx,ax
						mov es:[di],ch
						inc di

						cmp bx,3
						jle skip_rep

						mov ax,0f02h
						out dx,ax
                        mov al,ch
                        mov cx,bx
                        shr cx,2

                        rep stosb

                        mov ch,al
skip_rep:
                        and bx,3
                        jz no_last_byte

                        mov cl,bl
                        mov ax,0f002h
                        rol ah,cl
                        out dx,ax

                        mov es:[di],ch

no_last_byte:
                        ret

draw_line               endp


						end



