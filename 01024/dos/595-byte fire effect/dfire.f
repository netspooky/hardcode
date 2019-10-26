(
	fire.f
	Fire effect for ForthEC, DOS version
	/Mic, 2005
)



\ Random number generator 
: random 
	notouch
	mov si,random16
	mov al,[seed1]
	add al,[seed2]
	and ax,3
	add ax,ax
	add si,ax
	mov ax,[si]
	rol ax,11
	xchg al,ah
	mov [seed2],al
	mov [si],ax
	and ax,191
	touch a@ ;
			
		
0x13 a! 0x10 interrupt 0xa000 es!

\ Set up palette
33 1 do
	i 1- 0x3c8 outp
	i 1 << 1- 0x3c9 outp 0 0x3c9 outp 0 0x3c9 outp
	i 1- 32 + 0x3c8 outp
	63 0x3c9 outp i 1 << 1- 0x3c9 outp 0 0x3c9 outp
	i 1- 64 + 0x3c8 outp
	63 0x3c9 outp 63 0x3c9 outp i 1 << 1- 0x3c9 outp
	loop
\ Set remaining colors to white 
256 96 do
	i 0x3c8 outp
	63 0x3c9 outp 63 0x3c9 outp 63 0x3c9 outp loop


begin

\ Draw the fire
12160 
12798 
160 0 do
	over over
	82 0 do
		dup dup dup dup
		c:es@ swap 2 + c:es@ + swap 4 + c:es@ + swap 644 + c:es@ + 2 >>
		dup 0 <> if 1- then
		dup 8 << or	
		dup 3 pick w:es! 2 pick 320 + w:es! swap 640 + swap 640 + loop
	over 640 - random swap c:es!
	drop drop swap 2 + swap 2 + loop drop drop

\ Repeat until [ESC] is pressed
0x60 inp a@ 255 and 1- 0= until 3 a! 0x10 interrupt bye


\ Data for the RNG
notouch
random16 dw 25662,56977,36314,46707
seed1 db 58
seed2 db 0
touch
