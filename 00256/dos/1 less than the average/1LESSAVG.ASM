; "1 <ess than the average"
; a 256b compo for myself bY
; -=* thE /P.A.P.+O./ (BraiN)KiLLeR *=-
; [Src in NBASM 00.24.00 free beta]
; History:
;  2004.06.09. 15:30+4H	start (Sorry for the messy, undoc,
;		&not so opti code, but I was too tired to
;		"clean" it. Maybe later)
;
.model tiny
.optof
.186
.code
 org 100h
 mov al,13h
 int 10h
 mov dx,3dah
 mov bp,555
 mov bx,01ffh
loop2
 add bl,2
loop1
vsync2
 in al,dx
 and al,8
jzloop1
 jz vsync2
 push cs
 pop es
 push 0a000h
 pop ds
 xor si,si
 mov di,1024
 mov cx,32000	; ]opt[ -
 rep
 movsw
 push es
 push ds
 pop es
 pop ds
 mov di,320
 mov cx,63360	; 320*198
 xor ah,ah	; ]opt[ -
loop0
 mov al,[di+1023]
 add al,[di+1025]
 adc ah,0
 add al,[di+704]
 adc ah,0
 add al,[di+1344]
 adc ah,0
 shr ax,2
 sub al,bl
 stosb
 loop loop0
 test bh,bh
 jz shit
 mov es:[32160],bl
nsll
 mov ah,11
 int 21h	; ]opt[ -
 test al,al
 jnz keloop
vsync1
 in al,dx
 and al,8
 jnz vsync1
 dec bp
 jnz loop1
 mov bp,360
 dec bl
 jz jzloop1
 dec bh
 jnz eloop
 jmp short loop2
keloop
 mov ah,7
 int 21h	; ]opt[ -
eloop
 mov ax,0003h
 int 10h	; ]opt[ -
 ret		; exit
shit	 ; I< I < < e F<
 mov al,255
 mov di,6420
 mov cl,158
ll0
 stosb
 add di,319
 loop ll0
 mov di,22465
 call drawless
 mov di,35260
 mov cl,20
 rep
 stosb
 mov cl,10
ll1
 stosb
 add di,318
 loop ll1
 mov cl,10
ll2
 stosb
 sub di,322
 loop ll2
 mov di,41670
 mov cl,60
ll3
 stosb
 add di,319
 loop ll3
 mov di,22545
 call drawless
 mov di,22590
 call drawless
 mov di,22635
 call drawless
 mov di,22705
 call drawless
 mov di,38585
 mov cl,50
 rep
 stosb
 mov di,57220
 mov cl,108
ll4
 stosb
 sub di,321
 loop ll4
 mov cl,45
 rep
 stosb
 jmp nsll
drawless
 mov cl,50
dll0
 stosb
 add di,318
 loop dll0
 mov cl,40
dll1
 stosb
 add di,320
 loop dll1
 ret
.end
