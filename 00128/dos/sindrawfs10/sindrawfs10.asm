;now its 101 bytes
; Z - MATRIX
org 256
mov   al,13h ; ah=0 so -1 bytes
int   10h
les di,[bx] ; size - xp and 200 users use alternative
;finit
mainloop:
mov bp,si

;and word [x],cx
xor bx,bx
mov cx,320		   ; 320-szor megyünk
@go:
mov	[szoroz],bp	       ; szoroz=0..319, a
fld	dword [osztott]        ; szögszámláló benyomjuk
fimul	word [szoroz]
fsin
fimul	word [hiddenbigszam-1]	       ; hogy lássuk is
fistp	word [y]	       ; y=sin(A)

;;--- speed optimized block
;mov     ax,[y]
;add     ax,100
;lea edi,[4*eax+eax]
;shl di,6
;add     di,[x]                  ; di=320*(y+100)+x
;;---
;;--- size optimized block
mov ax,[y] ; did you know? 3 byte

;mov di,[y]
;add di,100

;mov bx,[y] ;               4 byte :)

;push ax ; see below
mov di,ax
add di,100
imul di,320
add di,bx
;---
;pop ax

and byte [bit],1;bt word [bit],0
jz second;jc second
;mov al,byte [y] ;mov  al,15 ;-1 byte if you like white
add al,70 ; color offset - i like it this way (+2 bytes)
jmp first
second:
xor al,al
first:
stosb
inc	bx
inc	bp
loop	@go

xor byte [bit],1;btc word [bit],0
jnz noretrace;jc noretrace
    mov dx,3dah ; 13 bytes (14 w ret)
;.v1:in al,dx   ; 8 bytes to wait for half retrace
;    and al,8
;    jnz .v1
.v2:in al,dx
    and al,8
    jz .v2
jmp mainloop
noretrace:
inc si
;cmp si,360 ; cmp word [offset],360 ; to prevent wrapping
;jb .skip
;xor si,si ; and word [offset],0
;.skip:
mov ah,11h
int 16h
jz mainloop
mov	ax,3
int	10h
ret ; exit

osztott dd 0.0174532925199432957692369076848861  ; = PI/180
;bigszam db 58 ;3A                 ; Ezzel szorozzuk fel ..
hiddenbigszam: ;3C 1 more bytes at the cost of good lookin'
rb 1
szoroz	rw 1		       ; Ez a szögszámláló
y	rw 1
;x       rw 1
bit rw 1
