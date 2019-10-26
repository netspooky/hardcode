;Routline by Harekiet

cpu 386
org	0100h

;set video segment
push 0xa000-70
pop es

;Setup video mode
mm:
or al,0x13	
int 0x10

;Setup font pointer 
push 0xf000 + 0xfa6
pop fs

restart:
;Turbo debugger doesn't properly init this
;mov si,0x100

;sp is -2 here
add word [si+rotate-2-0x100],sp
;dec word [si+rotate-2-0x100]


pixel:


;magic trick
mov ax, 0xcccd
mul di
;[si] points to initial push instruction
sub dh,[si]

pusha

;Shamelessly based on hellmood's hypnoeye routine

;fninit
fild word [byte bx-8]		;<- dh+dl		; x
fst st1										; x x
fmul st0									; x*x x
fild word [byte bx-9]		;<- dl+bh		; y x*x x
fst st3										; y x*x x y									
fmul st0									; y*y x*x x y 
faddp st1									; y*y+x*x x y
fsqrt										; r x y
fistp word [byte bx-5]		;-> al+ch		; x y
fpatan										; arc
fmul dword [byte si+const-0x100]			; arc/pi*64
fistp word [byte bx-14]		;-> arc -> bp	;

popa

;al should have distance from center
;bp should have some sort of radial counter

add bp, 6000
rotate:

;Filter out the lineS I want
sub al, 50
js skip
cmp al, 32
jae skip

;Store line for colouring
cbw
push ax

;Move through the string based on the arc distance

push bp
shr bp, 3
and bp, 7

;read string
movzx bp, byte [bp + outline]
shl bp, 3
;32/8 is 4
shr ax, 2
;The correct row
add bp, ax
;pixel index
pop cx
and cl, 7

;Final color
pop ax
add al, 32

;mov ch, byte [fs:bp+0xe]
;shl ch, cl
;shift directly into rom
shl byte [fs:bp+0xe],cl
js skipzero
skip:
;salc
xor ax,ax
skipzero:
stosb

;trigger the loop and do dithered view
;inc di
;inc di
or di,di
jnz pixel

;Wait till retrace starts
;mov	dx, 03dah
;wait_on:
;in	al,dx
;test al,8
;jnz	wait_on
;jmp restart


in al,0x60
dec ax
jnz restart
ret

const:
dd 20.371832

outline:
db "OUTLINE!"
