;	      ===============================================
;	      ||	     D E A D   E N D !		   ||
;	      ||					   ||
;	      ||	  Version 1,  30 Mar 1997	   ||
;	      ||					   ||
;	      ||An entry to the 256-byte Worm game contest ||
;	      ||	   by Boris van Schooten	   ||
;	      ||	  E-mail:  vicman@dds.nl	   ||
;	      ||		 Homepage:		   ||
;	      || www.geocities.com/TimesSquare/Alley/3583/ ||
;	      ===============================================

code	segment public
	assume	cs:code
	org	100h
start:


;Some assemblers don't support putting segment override prefixes in front of
;implicit instructions

cs_opc	EQU	2eh
ds_opc	EQU	3eh
es_opc	EQU	26h
ss_opc	EQU	36h


;Some assemblers don't support sign extension with AND,OR,XOR.

and_imm_btow_di_1	equ	10000011b
and_imm_btow_di_2	equ	11100111b


;attrs and their bit meanings

wall_attr	equ	70h

drone_bits	equ	80h
obstruction_bits equ	0f0h


;negative offsets from BP

cycles_ofs	equ	-7-8-24
keytbl_ofs	equ	-7-8
keytodir_ofs	equ	-7


;positive offsets from BP

timer_ofs	equ	0

tailbuf1_ofs	equ	2
tailbuf2_ofs	equ	2050
tailbuf3_ofs	equ	4098
tailbuf4_ofs	equ	6146


;interleaved array of cycle data

cycle_bufpos	equ	0;W pos. in tail buffer

cycle_head	equ	8;W pos of head on screen

cycle_dir	equ	16;B value to be added to head pos
cycle_attr	equ	17;B colour



;assumed on entry: ss=cs=es, d bit clear, sp set to end of segment, 0 pushed
;on stack


	push	es

	sub	ax,ax
	int	10h

	mov	bp,offset endofprogram

	mov	ah,0b8h
	mov	es,ax
	mov	ds,ax		;ds=video mem GLOBAL


	sub	di,di
	mov	ax,20h+256*wall_attr

	mov	cx,40		;ch=0 GLOBAL
rep	stosw

	mov	di,24*80
	mov	cl,40
rep	stosw

	pop	es		;es=cs GLOBAL


gameloop:
	inc	word ptr[ss:bp+timer_ofs]


	mov	cl,3
waitsyncs:

	mov	dx,03dah
waitsync_end:
	in	al,dx
	test	al,8
	jz	waitsync_end		;wait for sync to end
waitsync_start:
	in	al,dx
	test	al,8
	jnz	waitsync_start		;wait for sync to start

	loop	waitsyncs


	mov	ah,6
	mov	dl,-1
	int	21h
	jz	nokey

	or	al,60h			;make lowercase
	mov	di,offset key1_tbl
	mov	cl,8
repne	scasb

	jnz	nokey

	mov	al,cl
	and	al,3
	mov	di,cx

	db	and_imm_btow_di_1, and_imm_btow_di_2,	4
;	= and	  di,4

	mov	bx,offset keytodir_tbl
	db	cs_opc
	xlatb
	mov	[ss:bp+di+cycles_ofs+cycle_dir],al
nokey:


	push	ds

	mov	bx,40h
	mov	ds,bx			;ds=BDA.

	mov	al,[bx] 		;Motor shutoff counter
	and	al,3
	sub	al,7
	cbw				;ax=RND value -7..-4

	mov	dl,[bx-40h + 17h]	;dl = b0=LSH b1=RSH b2=CTRL b3=ALT

	pop	ds


	push	ax

	mov	cl,4			;cl=loop counter
	mov	si,cycles_ofs
cyclesloop:

	mov	bx,[ss:bp+si+cycle_head] ;0=dead, >0=dying, <0=normal
	neg	bx
	je	skipcycle
	jg	movecycle

deletecycle:

;Incbufpos
	add	word ptr[ss:bp+si+cycle_bufpos],2
	mov	di,[ss:bp+si+cycle_bufpos]
;End incbufpos

	mov	di,[ss:bp+di]		;get end of tail
	mov	[di],ch 		;erase end of tail
	add	bx,di			;Has head been reached?
	jnz	skipcycle
	jmp	short updcyclehead


hop_to_gameloop:
	jmp	short gameloop



;Inline procedure movecycle
;I:[si]=structure  bx=-> to head  TopOfStack=RND value -7..-4
;u:ax bx di dh
movecycle:

	test	dl,1
	jnz	movecycle_fast
	test	byte ptr[ss:bp+timer_ofs],3
	jnz	skipcycle
movecycle_fast:


	mov	ax,[ss:bp+si+cycle_dir] ;get al=dir  ah=attr
	mov	[bx],ah 		;Give tail the proper colour

	sub	di,di
	shl	ah,1			;shift drone bit into carry
	jnc	movecycle_tryentry

	pop	di
	push	di
	jmp	short movecycle_tryentry

movecycle_tryagain:
	mov	al,[ss:bp+di]
	mov	[ss:bp+si+cycle_dir],al ;update dir
movecycle_tryentry:
	cbw
	add	bx,ax			;retry other direction
	test	byte ptr[bx],obstruction_bits
	jz	movecycle_norm
	sub	bx,ax			;retract head
	inc	di
	jl	movecycle_tryagain


movecycle_die:
	and	word ptr[ss:bp+si+cycle_bufpos],0ffffh-2047
					;reset buf.pos. to begin.
	jmp	short negcyclehead


movecycle_norm:

;Incbufpos
	add	word ptr[ss:bp+si+cycle_bufpos],2
	mov	di,[ss:bp+si+cycle_bufpos]
;End incbufpos

	mov	[ss:bp+di],bx		;store new pos in tail buffer

	mov	byte ptr[bx],70h	;Draw lt.grey head



updcyclehead:
	neg	bx			;negate it back
negcyclehead:
	mov	[ss:bp+si+cycle_head],bx



skipcycle:
	ror	dl,1

	inc	si
	inc	si
	loop	cyclesloop

	pop	ax



	mov	ax,[ss:bp+si]
	and	ax,[ss:bp+si+4]
	jl	hop_to_gameloop

quit:
	ret






cycles_arr:
	dw	tailbuf1_ofs-2
	dw	tailbuf2_ofs-2
	dw	tailbuf3_ofs-2
	dw	tailbuf4_ofs-2

	dw	-19*80-61
	dw	-19*80-21
	dw	-5*80-21
	dw	-5*80-61

	db	-2,20h
	db	2,50h + drone_bits
	db	2,30h
	db	-2,60h + drone_bits



key1_tbl	db	'a','s','d','w'
key2_tbl	db	'j','k','l','i'



keytodir_tbl	db     -80,2,80,-2, -80,2,80

endofprogram:


code	ends
	end	start

