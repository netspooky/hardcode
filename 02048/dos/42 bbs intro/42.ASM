jumps
.286
SEG_A           SEGMENT
		ASSUME CS:SEG_A, DS:SEG_A
		ORG     100H

COMDUMMY        PROC FAR

	INIT:   JMP     START

;insert your data here like this one:

i dw 0
j dw 0
li dw 0
lj dw 0
llj db 0
lk db 0
d dw 0
ctr dw 0
color db 0
c db 0
firstchar db 0
k db 0
l db 0
m db 0

x dw 0
y dw 0

jdir db 0
randseed dw 0
pxi db 0
pyi db 0

fofs dw 0
fseg dw 0

Fib  dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

txtofs dw 0
txt1 db "This file was stolen from"
txt2 db "The coding bbs           "
txt3 db "+644 568-6697            $"
txt4 db "42 - $"
scrollstr db "LBA WHQ"  ;
	  db "Sysop: Maniac/LBA... " ;28
	  db "No doors... No Lamers... " ;25
          db "Thousands of messages... "     ;25
	  db "1,000,000,000 byte file area... "  ;32
	  db "Fidonet 3:771/42... "   ;
	  db "                                                         "
               ; blank space to make the com file exactly 2k
_42points db 20, 30 , 20, 0, 0, 20, 30, 20

	  db 30, 5, 45, 0, 50, 10, 30, 28, 50, 28

;insert your macros and procedures here like this one:

proc putpixelasm near
  shl bx,6
  mov di,bx
  shl bx,2
  add di,bx
  add di,cx
  mov al, dl
  stosb
  ret
  endp putpixelasm



proc writetxt near
	  mov i, 0
	  @@textiloop:

	  mov llj, 0
	  @@textlljloop:

	  mov lk, 0
	  @@textlkloop:

	  mov si, txtofs
	  mov ax,i
	  add si, ax
	  mov ah, 0
	  mov al, [si];

	  shl ax, 3

	  mov bl, llj
	  add ax, bx


	  mov es, fseg
	  mov di, ax
	  add di, fofs

	  mov al, [es:di]
	  mov ah, 0
	  mov cl, lk
	  shl ax, cl
	  and ax, 128

	  jz @@textcnot9

	  mov al , color
	  sub al, llj
	  sub al, lk
	  mov c, al
	  jmp @@textc9
@@textcnot9:
mov c, 0

	     @@textc9:
  mov ax, 0a000h
  mov es, ax
  mov ah, 0
  mov al, llj
  add ax, y

  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  mov ax, i
  shl ax, 3
  mov bh, 0
  mov bl, lk
  add ax, bx
  add ax, x

  add di,ax
  mov al,[c]
  stosb
  @@endputpix:

inc lk
cmp lk, 8
jnz @@textlkloop

inc llj
cmp llj, 8
jnz @@textlljloop

inc i
cmp i, 25
jnz @@textiloop

ret
endp writetxt



proc rand near
mov si, offset [fib]
add si, li
add si, li
mov ax, [si]

mov si, offset [fib]
add si, lj
add si, lj
add ax, [si]


mov si, offset [fib]
add si, li
add si, li
mov [si], ax

dec li
jnz @@randlinz
mov li, 17
@@randlinz:

dec lj
jnz @@randljnz
mov lj, 17
@@randljnz:

mov dx,0;

div bx
mov ax, dx
ret
endp rand

	START:
; insert your main program code here:


;(* init mode 13h *)
mov ax, 013h
int 10h;
;(* get font *)
  mov ax,1130h
  mov bh,3
  int 10h
  mov fseg,es
  mov fofs,bp




;(* Seed random number *)
mov ax, 040h
mov es, ax
mov di, 06ch
mov ax, [es:di]


mov si, offset [fib]
add si, 2
mov [si], ax
inc si
inc si
mov [si], ax

mov li, 17

mov dx, 0
mov bx, 17
div bx
mov lj, dx

mov x, 3
@@randseedxloop:


mov si, offset [fib]
mov ax, x
dec ax
dec ax
add si, ax
add si, ax
lodsw
mov bx, ax
lodsw

add ax, bx

mov si, offset [fib]
add si, x
add si, x
mov [si], ax


inc x
cmp x, 18
jnz @@randseedxloop





mov ax, 0a000h
mov es, ax




mov m, 24
mov jdir, 0

mov si, offset [_42points]
mov ah, 0
lodsb
mov x, ax
lodsb
mov y, ax



mov i, 8
@@4piloop:

lodsb
mov pxi, al
lodsb
mov pyi, al


@@4ppixloop:


mov ax, x
cmp al, pxi
ja @@4pdecx
cmp al, pxi
je @@4pincx
inc x
jmp @@4pincx
@@4pdecx:
dec x
@@4pincx:

mov ax, y
cmp al, pyi
ja @@4pdecy
cmp al, pyi
je @@4pincy
inc y
jmp @@4pincy
@@4pdecy:
dec y
@@4pincy:



mov al, jdir
add m, al
dec m

cmp m, 28
jb @@4pmless28
mov jdir, 0
@@4pmless28:

cmp m, 24
ja @@4pmabove24
mov jdir, 2
@@4pmabove24:

cmp i, 5
jz @@4pnopixloop


mov dl, m

mov ax, x
cmp al, pxi
jz @@4pnoxshad

mov cx, x
add cx, 135
mov bx, y
add bx, 14
mov dl, m
sub dl, 4
call putpixelasm

mov bx, y
add bx, 16
call putpixelasm

@@4pnoxshad:

mov ax, y
cmp al, pyi
jz @@4pnoyshad

mov cx, x
add cx, 134
mov bx, y
add bx, 15
mov dl, m
sub dl, 4
call putpixelasm

mov cx, x
add cx, 136
mov bx, y
add bx, 15
call putpixelasm

@@4pnoyshad:

mov cx, x
add cx, 135
mov bx, y
add bx, 15
mov dl, m
call putpixelasm

@@4pnopixloop:

mov ax, x
cmp al, pxi
jnz @@4ppixloop
mov ax, y
cmp al, pyi
jnz @@4ppixloop


dec i
cmp i, 0
jnz @@4piloop




mov x,60
mov y, 0
mov txtofs, offset [txt1]
mov color,31
call writetxt;

mov x,100
mov y, 50
mov txtofs, offset [txt2]
mov color,60
call writetxt;

mov x,105
mov y, 60
mov txtofs, offset [txt3]
mov color,60
call writetxt;

mov x, 0
@@citypixxloop:
mov y, 121
@@citypixyloop:

mov dl, 20

mov ax, x
mov bl, 2
div bl
cmp ah, 0
jnz @@citipixgrey
mov ax, y
mov bl, 2
div bl
cmp ah, 0
jnz @@citipixgrey

mov dh, dl
mov bx,5
call rand
mov dl,dh


cmp ax, 0
jz @@citipixgrey

mov dl, 14
@@citipixgrey:

mov cx, x
mov bx, y

call putpixelasm

mov bx, y
shr bx, 3
call rand
cmp ax, 0
jz @@citypixexityloop


dec y
cmp y, 80
jnz @@citypixyloop
@@citypixexityloop:

inc x
cmp x, 320
jnz @@citypixxloop




mov di, 39040
mov ah, 20
mov al, 20
mov cx, 2720
rep stosw
mov di, 64000
mov cx, 768
rep stosw


mov di, 39040
mov y, 9
@@scrollbackgroundyloop:
mov cx, 160

@@scrollbackgroundxloop:

mov bx, 5
call rand
cmp ax, 0
jz @@scrollbackgroundnotyellow
mov al, 14
inc di
stosb
mov dx, di

  mov ax, 9
  sub ax, y
  shl ax,5
  mov di,ax
  add di, 64000
  shl ax,2
  add di,ax
  add di,cx
  mov al,14
  stosb


mov di, dx
jmp @@scrollbackgroundyellow
@@scrollbackgroundnotyellow:
inc di
inc di
@@scrollbackgroundyellow:

loop @@scrollbackgroundxloop

add di, 320
dec y
jnz @@scrollbackgroundyloop




mov ctr, 0
mov firstchar, 1
@@mainloop:

inc ctr
cmp firstchar, 166
jna @@mainloopnoresetctr
mov firstchar, 1
mov ctr, 1
@@mainloopnoresetctr:

	  mov ah,0
	  mov al, firstchar
	  shl ax, 3
	  add ax, 170
	  cmp ctr, ax
	  jl @@dottextnoinc
	  inc firstchar
	  @@dottextnoinc:
	  mov i, 0
	  @@dottextiloop:

	  mov ah, 0
	  mov al, firstchar
	  add ax, i
	  shl ax, 4
	  mov bx, ctr
	  shl bx, 1
	  add ax, 319
	  sub ax, bx
	  mov x, ax

	  mov llj, 0
	  @@dottextlljloop:

	  mov lk, 0
	  @@dottextlkloop:

	  mov si, offset[scrollstr]
	  mov ax,i
	  mov bh, 0
	  mov bl, firstchar
	  add ax, bx
	  dec ax
	  add si, ax
	  mov ah, 0
	  mov al, [si];

	  shl ax, 3

	  mov bl, llj
	  add ax, bx


	  mov es, fseg
	  mov di, ax
	  add di, fofs

	  mov al, [es:di]
	  mov ah, 0
	  mov cl, lk
	  shl ax, cl
	  and ax, 128

	  jz @@dottextcnot9

	  mov c, 9
	  jmp @@dottextc9
@@dottextcnot9:


	     mov ax, 0a000h
	     mov es, ax
	     mov di, 64000


	     mov ah,0
	     mov al, llj
	     mov bx, ax
	     shl bx, 7
	     add di, bx
	     shl ax, 5
	     add di, ax

	     mov ah,0
	     mov al, lk
	     add di, ax

	     mov ax, x
	     sar ax, 1
	     add di, ax

	     mov al, [es:di]
	     mov c, al
	     @@dottextc9:
  mov ax, 0a000h
  mov es, ax
  mov ah, 0
  mov al, llj
  shl ax, 1
  add ax, 122

  cmp ax, 200
  jae @@dtendputpix
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  mov ah, 0
  mov al, lk
  shl ax, 1
  add ax, x

  add di,ax
  cmp ax, 320
  jae @@dtendputpix
  mov al,[c]
  stosb
  @@dtendputpix:

inc lk
cmp lk, 8
jnz @@dottextlkloop

inc llj
cmp llj, 8
jnz @@dottextlljloop

inc i
cmp i, 21
jnz @@dottextiloop


inc k


mov al, k
mov bl, 16
div bl
add ah, 16
mov k, ah

mov j, 0

mov di,0
mov ax,0
mov cx,25600

@@l1:
mov dl,[es:di]
cmp dl, 16
ja @@nostos
stosb
jmp @@stosed
@@nostos:
inc di;
@@stosed:
loop @@l1



mov j, 0
mov i, 0
@@leftlightiloop:

  mov bx, 3
  call rand
  add j, ax
  dec j

  mov ax,30
  add ax, j
  dec ax
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,141
  sub di, i

  sub di, 321
  mov al, 9
  mov dl, [es:di]
  cmp dl, 0
  jnz @@llend2
  cmp di, 32000
  ja @@llend2
  stosb
@@llend2:
  add di, 639
  mov dl, [es:di]
  cmp dl, 0
  jnz @@llend3
  cmp di, 32000
  ja @@llend3
  stosb
@@llend3:
  sub di, 321
  mov al, 11
  mov dl, [es:di]
  cmp dl, 0
  jnz @@llend1
  cmp di, 32000
  ja @@llend1
  stosb
@@llend1:
inc i
cmp i, 140
jnz @@leftlightiloop

mov j, 0
mov i, 0
@@rightlightiloop:

  mov bx, 3
  call rand
  add j, ax
  dec j
  mov ax,30
  add ax, j
  dec ax
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,184
  add di, i

  sub di, 321
  mov al, 9
  mov dl, [es:di]
  cmp dl, 0
  jnz @@rlend2
  cmp di, 32000
  ja @@rlend2
  stosb
@@rlend2:
  add di, 639
  mov dl, [es:di]
  cmp dl, 0
  jnz @@rlend3
  cmp di, 32000
  ja @@rlend3
  stosb
@@rlend3:
  sub di, 321
  mov al, 11
  mov dl, [es:di]
  cmp dl, 0
  jnz @@rlend1
  cmp di, 32000
  ja @@rlend1
  stosb
@@rlend1:
inc i
cmp i, 137
jnz @@rightlightiloop

in al, 060h
;cmp al, 1
dec al
jnz @@mainloop

mov ax, 03h
int 10h;


mov dx, offset txt4
mov ah, 9
int 21h
mov dx, offset txt2
mov ah, 9
int 21h



mov ax, 04c00h
int 21h



		RETN
COMDUMMY        ENDP

SEG_A           ENDS
		END     INIT
