org 100h

use16

mov al,13h
int 10h
;--setpal
xor cl,cl
sp_lp:
	mov dx,03C8h
	mov al,cl
	out dx,al
	inc dx
	and al,63
	out dx,al
	mov ah,al
	test cl,64
	jne put2
	xor al,al
put2:
	out dx,al
	mov al,ah
	out dx,al
	inc cl
	jne sp_lp

mov bh,0A0h
mov es,bx

mov bh,80h
mov ds,bx

inc byte [es:100*320+160]

da_lp:
mov di,318

mov bp,200

dlp_x1:
mov cx,319

inc di

dlp_x2:
inc di

movzx ax,byte [es:di-320]
movzx bx,byte [es:di+320]
add ax,bx
movzx bx,byte [es:di-1]
add ax,bx
movsx bx,byte [es:di+1]
add ax,bx

mov bx,119
cwd
idiv bx
mov [ds:di],dl
loop dlp_x2

dec bp
jne dlp_x1
;;inc byte [es:di]
;cmp di,320*200;64000
;jc dlp_x1

	       mov     dx, 3DAh
waitvr:
	       in      al, dx
	       test    al, 8
	       jnz     short waitvr
loc_448:
	       in      al, dx
	       and     al, 8
	       jz      short loc_448
;
xor si,si
xor di,di
mov ch,0FAh
rep movsb

in al,60h
dec al
jne da_lp
ret
