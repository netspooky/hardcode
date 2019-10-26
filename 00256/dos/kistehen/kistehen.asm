;
;	Yes, this one is opensource :))
;
;	Distributed under the MIT license
;
;	(c) 2002 robymus + blala / byteam
;
;	greets to lorenzo / darkside [barackpalinka]
;
;	nasm rulz :)
;
org 100h

start:
mov al,3
int 10h

push word 0b800h
pop es
mov si, l1

mov cl,4
mov ah,11
mov di, 160*8 + 40
.w0:
push di
.w1:
lodsb
stosw
or al, al
jnz .w1
pop di
add di, 3 * 160
loop .w0

mov ds, cx
mov bx, 46ch

mov ah,1
mov cx, 2020h
int 10h

.loop:
mov di, 160*9 + 40
mov si, timing

.doit:
mov ax, 0c00h + 30
push di
stosw
db 2eh	; segcs
lodsb
aam 16
add ah, [bx]
.wait:
cmp ah, [bx]
jne .wait

; barackpalinka
push ax
push si
mov si, barackpalinka
mov di, 160*24 + 65 * 2
.w2:
db 2eh	; segcs
lodsb
stosw
or al, al
jnz .w2
pop si
pop ax

pop di
xor ah,ah
stosw
cmp al,0eh
je .endnow
jb .notf
db 2eh	; segcs
lodsw
.notf:
add di, ax
add di, ax
jmp .doit


.endnow:
mov ah,1
int 16h
jz .loop
ret


l1 db 'n vagyok a kis teh‚n',0
l2 db 'šl”k a fa tetej‚n',0
l3 db 'L bamat l¢gatom s j¢l ‚rzem magamat',0
l4 db 'n a kis teh‚n',0

barackpalinka db '[barackp linka]'


;d1:
;	dw 160*8 + 40
;	dw 160*11 + 40
;	dw 160*14 + 40
;	dw 160*17 + 40
;	dw 160*24 + 65*2

%macro deftiming 2
%if %2 > 15
db (%1 << 4) | 15
dw %2
%else
db (%1 << 4) | %2
%endif
%endmacro

timing:
	deftiming 10	,3	; En 
	deftiming 4	,2	; va
	deftiming 4	,2	; gyok
	deftiming 4	,2	; a
	deftiming 7	,3	; kis
	deftiming 4	,1	; te
	deftiming 12	,240-20	; hen

	deftiming 4	,1	; U
	deftiming 4	,2	; lok
	deftiming 4	,2	; a
	deftiming 4	,2	; fa
	deftiming 4	,1	; te
	deftiming 4	,1	; te
	deftiming 12	,240-15	; jen

	deftiming 4	,1	; La
	deftiming 4	,1	; ba
	deftiming 4	,3	; mat
	deftiming 4	,1	; lo
	deftiming 4	,1	; ga
	deftiming 4	,5	; tom
	deftiming 4	,2	; s jol
	deftiming 4	,2	; er
	deftiming 4	,3	; zem
	deftiming 4	,1	; ma
	deftiming 4	,1	; ga
	deftiming 6	,240-34	; mat

	deftiming 8	,2	; En
	deftiming 4	,2	; a
	deftiming 7	,3	; kis
	deftiming 4	,1	; te
	deftiming 12	,160*10	; hen 
	
	deftiming 15	,0	; - the end -
	deftiming 15	,0	; - the end -
	deftiming 15	,14	; - the end -

