;
;
;

.model small,c

			public Plot, sn_tbl, SwapScreens, DoPlasma, GetRand
			public PlotProjection, screen, ClearMyScreen, view_screen
			public SetMyMode, Project, grid, rand_seed
			public pitch_sine,pitch_cosine,roll_sine,roll_cosine
			public PutGrid, GetGrid

			extrn roll:word, cpitch:word, cz:word, cy:word
			extrn gx:word, gy:word, gp:word, idx:word

EYEDIST		equ 8	; perspective factor
GRIDSIZE	equ 80
VIEWSIZE	equ 61  ; Must be odd
EXPAND		equ 5   ; distance between dots
ARRAYSIZE	equ (GRIDSIZE*GRIDSIZE)

DEPTH_CUTOFF	equ 1300 ; point at which depth cueing starts
DEPTH_SHIFT		equ 7 ; severity of depth cueing (high numbers = less severe)

.data

			align 2

vid_data	dw table_len

			dw 5f00h, 4f01h, 5002h, 8203h     ; CRTC Registers
			dw 5404h, 8005h,0bf06h, 1f07h
			dw 0008h, 0c009h, 000ah, 000bh
			dw 000ch, 000dh, 000eh, 000fh
			dw 9c10h, 8e11h, 8f12h, 2813h
			dw 0014h, 9615h,0b916h,0E317h

table_len   equ ($-vid_data-1)/2

sn_tbl		dw (360+90) dup(0)

			align 2

point_size	equ 6

mx			dw 0
my			dw 0
gridptr		dw 0

point_grid	dw (VIEWSIZE*point_size) dup(0)

point_x		equ word ptr 0
point_y		equ word ptr 2
point_col	equ word ptr 4

rand_seed	dw 0

			align 4

screen		dd 0a0004000h
view_screen dd 0a0000000h

pitch_sine	dd 0
pitch_cosine dd 0
roll_sine 	dd 0
roll_cosine	dd 0

grid		db ARRAYSIZE dup(0)
grid_end	equ $

.code

.386

shift		equ 14


param1		equ [bp+4]
param2		equ [bp+6]
param3		equ [bp+8]
param4		equ [bp+10]
param5		equ [bp+12]
param6		equ [bp+14]
param7		equ [bp+16]
param8		equ [bp+18]
param9		equ [bp+20]

RandPixel	proc near

x			equ word ptr param1
y			equ word ptr param2
x1			equ word ptr param3
y1			equ word ptr param4
x2			equ word ptr param5
y2			equ word ptr param6

			push bp
			mov bp,sp

			mov ax,x
			sub ax,x1
			cwd
			xor ax,dx
			sub ax,dx

			mov bx,ax

			mov ax,y
			sub ax,y1
			cwd
			xor ax,dx
			sub ax,dx

			add bx,ax

			call GetRand
			xor ah,ah
			sub ax,128

			imul bx
			mov bx,GRIDSIZE/6
			idiv bx

			push ax

			mov bx,y1
			mov ax,x1
			call GetGrid

			push ax

			mov bx,y2
			mov ax,x2
			call GetGrid

			pop bx
			add ax,bx
			sar ax,1

			pop bx
			add ax,bx
			cmp ax,1
			jge rp_s1

			mov al,1
rp_s1:
			cmp ax,255
			jle rp_s2

			mov al,255
rp_s2:
			xor ah,ah
			push ax

			mov cl,al
			mov bx,y
			mov ax,x
			call PutGrid
			pop ax

			pop bp
			ret

RandPixel	endp


GetRand		proc near

			mov ax,rand_seed
			add ax,56791
			imul ax,13579
			mov rand_seed,ax
			and ax,07fffh
			ret

GetRand		endp


GetGrid		proc near

			imul bx,GRIDSIZE
			add bx,ax
			add bx,idx
			sub bx,ARRAYSIZE
			jnc no_add1
			add bx,ARRAYSIZE
no_add1:
			mov al,[bx+grid]
			xor ah,ah

			ret

GetGrid		endp


PutGrid		proc near

			imul bx,GRIDSIZE
			add bx,ax
			add bx,idx
			sub bx,ARRAYSIZE
			jnc no_add2
			add bx,ARRAYSIZE
no_add2:
			mov [bx+grid],cl

			ret

putGrid		endp


DoPlasma	proc near

x1			equ word ptr param1
y1			equ word ptr param2
x2			equ word ptr param3
y2			equ word ptr param4

x			equ word ptr [bp-2]
y			equ word ptr [bp-4]
s			equ word ptr [bp-6]

			push bp
			mov bp,sp
			sub sp,6

			mov ax,x2
			sub ax,x1
			cmp ax,1
			jg not_return

			mov ax,y2
			sub ax,y1
			cmp ax,1
			jg not_return
			jmp exit_doplasma

not_return:

			mov ax,y1
			add ax,y2
			sar ax,1
			mov y,ax

			mov ax,x1
			add ax,x2
			sar ax,1
			mov x,ax

			mov bx,y1
			call GetGrid

			or ax,ax
			jnz dp_s1

			push y1
			push x2
			push y1
			push x1
			push y1
			push x
			call RandPixel
			add sp,12

dp_s1:
			mov s,ax

			mov bx,y
			mov ax,x2
			call GetGrid

			or ax,ax
			jnz dp_s2

			push y2
			push x2
			push y1
			push x2
			push y
			push x2
			call RandPixel
			add sp,12

dp_s2:
			add s,ax

			mov bx,y2
			mov ax,x
			call GetGrid

			or ax,ax
			jnz dp_s3

			push y2
			push x2
			push y2
			push x1
			push y2
			push x
			call RandPixel
			add sp,12

dp_s3:
			add s,ax

			mov bx,y
			mov ax,x1
			call GetGrid

			or ax,ax
			jnz dp_s4

			push y2
			push x1
			push y1
			push x1
			push y
			push x1
			call RandPixel
			add sp,12

dp_s4:
			add s,ax

			mov bx,y
			mov ax,x
			call GetGrid

			or ax,ax
			jnz no_plot

			mov cx,s
			shr cx,2
			mov bx,y
			mov ax,x
			call PutGrid
no_plot:
			push y
			push x
			push y1
			push x1
			call DoPlasma
			add sp,8

			push y
			push x2
			push y1
			push x
			call DoPlasma
			add sp,8

			push y2
			push x
			push y
			push x1
			call DoPlasma
			add sp,8

			push y2
			push x2
			push y
			push x
			call DoPlasma
			add sp,8

exit_doplasma:
			leave
			ret

DoPlasma	endp


SwapScreens proc near

			mov dx, 03dah
ss_1:
			in al,dx
			test al,8
			jz ss_1
ss_2:
			in al,dx
			test al,8
			jnz ss_2

			cli
			add word ptr view_screen,04000h
			add word ptr screen,04000h

			mov bx,word ptr view_screen

			mov dx,03d4h
			mov al,0dh
			mov ah,bl
			out dx,ax
			dec al
			mov ah,bh
			out dx,ax
			sti

			ret

SwapScreens endp


Plot		proc near

			cmp bx, 319
			jae Plot_quit

			cmp cx, 199
			jae Plot_quit

			push di
			push ax
			les di,screen
			mov dx,cx
			shl dx,6
			shl cx,4
			add dx,cx

			mov cx,bx
			shr bx,2
			add bx,dx
			add di,bx
			mov dx,03c4h
			mov ax,0102h
			and cl,3
			shl ah,cl
			out dx,ax
			pop ax
			mov es:[di],al

			pop di
Plot_quit:
			ret

Plot		endp


MatrixRotate proc near

			movsx esi,ax
			imul esi,roll_cosine
			movsx edx,bx
			imul edx,roll_sine
			sub esi,edx
			sar esi, shift

			movsx ecx,ax
			imul ecx,roll_sine
			movsx edx,bx
			imul edx,roll_cosine
			add ecx,edx
			sar ecx, shift

			mov ebx,ecx
			imul ebx,pitch_cosine
			movsx edx,di
			imul edx,pitch_sine
			sub ebx,edx
			sar ebx, shift
			mov ax,bx

			imul ecx,pitch_sine
			movsx edx,di
			imul edx,pitch_cosine
			add ecx,edx
			sar ecx, shift
			mov dx,cx

			ret

MatrixRotate endp


PlotProjection proc near

			push bp
			mov bp,sp

			push si
			push di

			movsx ebx,word ptr param3
			mov di,gridptr

			cmp bx,1 shl EYEDIST
			jg no_quit_proj
quit_projection:

			mov point_col[di],0
			jmp exit_projection

no_quit_proj:

			mov ax,param1
			cwd
			xor ax,dx
			sub ax,dx
			shr ax,2
			add ax,bx

			shr byte ptr param4,2

			cmp ax,DEPTH_CUTOFF
			jg do_depth

			push word ptr param4
			jmp skip_depth

do_depth:

			sub ax,DEPTH_CUTOFF
			shr ax,DEPTH_SHIFT

			cmp ax,4
			jae quit_projection

			shl al,6
			add al,param4
			push ax
skip_depth:

			movsx eax,word ptr param2
			shl eax,EYEDIST
			cdq
			idiv ebx
			add ax,100
			mov cx,ax

			movsx eax,word ptr param1
			shl eax,EYEDIST
			cdq
			idiv ebx
			add ax,160
			mov bx,ax
			pop ax

			mov si,bx
			push cx

			call Plot

			pop cx

			push ax

			cmp my,VIEWSIZE/2 shl EXPAND
			jz skip_below

			cmp point_col[di],0
			jz skip_below

			push cx

			mov bx,si
			add bx,point_x[di]
			sar bx,1
			add cx,point_y[di]
			sar cx,1
			mov ax,point_col[di]

			call Plot

			pop cx

			cmp mx,VIEWSIZE/2 shl EXPAND
			jz skip_below

			cmp point_col[di+point_size],0
			jz skip_below

			push cx

			mov bx,si
			add bx,point_x[di+point_size]
			sar bx,1
			add cx,point_y[di+point_size]
			sar cx,1
			mov ax,point_col[di+point_size]

			call Plot

			pop cx

skip_below:
			cmp mx,-VIEWSIZE/2 shl EXPAND
			jz skip_left

			cmp point_col[di-point_size],0
			jz skip_left

			push cx

			mov bx,si
			add bx,point_x[di-point_size]
			sar bx,1
			add cx,point_y[di-point_size]
			sar cx,1
			mov ax,point_col[di-point_size]

			call Plot

			pop cx
skip_left:

			pop ax

			mov point_x[di],si
			mov point_y[di],cx
			mov point_col[di],ax

exit_projection:
			pop di
			pop si
			pop bp
			ret

PlotProjection endp


SetMyMode	proc near

			push si
			push di

			mov ax,013h
			int 10h

			mov dx,03c4h
			mov ax,0604h
			out dx,ax

			mov ax,0f02h
			out dx,ax

			xor di,di
			mov ax,0a000h
			mov es,ax
			mov cx,07fffh
			xor ax,ax

			rep stosw

			cli

			mov dx,03d4h
			mov al,011h
			out dx,al

			jmp $+2
			inc dx
			in al,dx
			and al,07fh
			out dx,al

			mov dx,03d4h
			mov si,offset vid_data
			cld
			lodsw
			mov cx,ax
out_next:
			lodsw
			out dx,ax
			loop out_next

			sti

			pop di
			pop si

			ret

SetMyMode	endp


ClearMyScreen proc near

			push di

			mov dx,03c4h
			mov ax,0f02h
			out dx,ax

			les di,screen
			mov cx,4000
			xor eax,eax

			rep stosd

;			xor cx,cx
;			xor bx,bx
;			xor al,al
;
;next_col:
;			push ax
;			push bx
;			push cx
;			call Plot
;			pop cx
;			pop bx
;			pop ax
;			inc bx
;			inc al
;			jnz next_col


			pop di
			ret

ClearMyScreen endp


Project		proc near

p			equ word ptr [bp-2]

			push bp
			mov bp,sp
			sub sp,2
			push si
			push di

			mov di,gp
			mov p,di

			mov my,VIEWSIZE/2 shl EXPAND
			jmp test_y
next_y:

			mov gridptr, offset point_grid
			mov mx,-VIEWSIZE/2 shl EXPAND
			jmp test_x
next_x:
			mov di,p
			movzx di,byte ptr [di]
			cmp di,63
			jae skip_levelsea
			mov di,63
skip_levelsea:

			mov ax,mx
			mov bx,my
			call MatrixRotate

			push di
			sub dx,cz
			push dx
			sub ax,cy
			push ax
			push si
			call PlotProjection
			add sp,8

			add mx,1 shl EXPAND
			inc p
			cmp p,offset grid_end
			jb skip_modp

			sub p,ARRAYSIZE
skip_modp:
			add gridptr,6
test_x:
			cmp mx,VIEWSIZE/2 shl EXPAND
			jle next_x

			sub my,1 shl EXPAND
			add p,GRIDSIZE-VIEWSIZE
			cmp p,offset grid_end
			jb test_y

			sub p,ARRAYSIZE
test_y:
			cmp my,-VIEWSIZE/2 shl EXPAND
			jge next_y


Project_quit:
			pop di
			pop si
			leave
			ret

Project		endp

			end
