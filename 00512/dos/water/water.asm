; 512-byte water demo using only plaintext characters (for #asm contest 10)
; Written by rwagner

; Compiled using nasm

	bits	16
	org		0x100

; This code extracts a 319 byte block of traditional code, containing a graphical water demo,
; at run time.  The main code is encoded using 6 bits per character (base 64).  The full
; listing of the encoded program can be found at the bottom of the file, after its encoded form.

start:
	; Set si = 0x156 (start of data)
	push	0x2374
	pop	ax
	xor	ax, 0x2222
	push	ax
	pop	si

	; Set di = 0x100 (start of prog)
	sub	al, 0x56
	push	ax
	pop	di

	; Self modify some instructions that can't be represented as printable chars (shr, shl, lodsw)
	xor	ax, 0x417e		; ax = 0x407e
	sub	[di+0x29], al
	sub	[di+0x3c], al
	sub	[di+0x55], al
	sub	[di+0x35], ax
	sub	[di+0x43], ax
	sub	[di+0x4c], ax

	; Set bp = 0
	sub	ax, 0x407e
	push	ax
	pop	bp

	; Force instruction cache flush (pre-Pentium chips need this after self-modify)
	jz	decodeloopend

	; Loop to decode base 64 encoded program.  Each byte represents 6 bits in the real code
	; stream.  Four encoded characters decodes into three bytes.  This decoding routine is
	; exactly 86 bytes long, so we have (512 - 86) * (3 / 4) = 426 * (3 / 4) = 319 bytes
	; to play with, where those 319 bytes can be any desired value (no limits on which
	; instructions can be used).
decodeloop:
	; Load first two bytes of next four byte chunk
	db	0x2b			; lodsw after self modify
	and	ax, 0x3f3f

	; Write first 6 bits
	and	[di+0x56], bp
	xor	[di+0x56], al

	; Xor in the second 6 bits
	and	al, 0x40		; al = 0
	db	0x3f, 0x29, 0x42 	; shr ax, 2 after self modify
	xor	[di+0x56], ax
	inc	di

	; Load last two bytes of the four byte chunk
	db	0x2b			; lodsw after self modify
	and	ax, 0x3f3f

	; Xor in the last 6 bits
	and	[di+0x57], bp
	db	0x3f, 0x21, 0x42	; shl ax, 2 after self modify
	xor	[di+0x57], ah

	; Xor in the third 6 bits
	xor	ah, [di+0x57]		; ah = 0
	db	0x3f, 0x21, 0x42	; shl ax, 2 after self modify
	xor	[di+0x56], ax
	inc	di
	inc	di

	; Loop long enough to decode entire program (jns will go to 0x8000, more than far enough)
decodeloopend:
	jns	decodeloop+0x7e		; offset of 0x7e will be subtracted out during self modify


	; Encoded instruction stream, execution will begin here immediately after decode
	; is completed.
data:
	db	0x38, 0x4e, 0x41, 0x40, 0x4d, 0x43, 0x41, 0x23, 0x48, 0x57, 0x40, 0x40, 0x50, 0x38, 0x48, 0x3a
	db	0x3a, 0x22, 0x3c, 0x40, 0x31, 0x40, 0x2c, 0x3b, 0x42, 0x25, 0x4b, 0x40, 0x41, 0x2c, 0x4b, 0x20
	db	0x40, 0x24, 0x36, 0x30, 0x4b, 0x40, 0x20, 0x21, 0x20, 0x3b, 0x5e, 0x5a, 0x43, 0x47, 0x42, 0x40
	db	0x46, 0x42, 0x2e, 0x3b, 0x29, 0x4d, 0x2c, 0x4a, 0x40, 0x58, 0x48, 0x38, 0x2e, 0x4f, 0x24, 0x38
	db	0x28, 0x3f, 0x40, 0x2a, 0x47, 0x44, 0x33, 0x3f, 0x31, 0x58, 0x5f, 0x4c, 0x40, 0x27, 0x4b, 0x40
	db	0x40, 0x4e, 0x3f, 0x2a, 0x4c, 0x22, 0x5e, 0x41, 0x40, 0x40, 0x21, 0x23, 0x40, 0x47, 0x43, 0x30
	db	0x39, 0x42, 0x40, 0x20, 0x33, 0x2f, 0x3a, 0x2e, 0x40, 0x40, 0x40, 0x23, 0x28, 0x47, 0x40, 0x36
	db	0x4e, 0x22, 0x4d, 0x23, 0x28, 0x47, 0x38, 0x3c, 0x40, 0x40, 0x51, 0x40, 0x58, 0x3b, 0x48, 0x30
	db	0x53, 0x25, 0x4b, 0x41, 0x40, 0x20, 0x2e, 0x28, 0x40, 0x4c, 0x49, 0x3a, 0x5e, 0x42, 0x40, 0x40
	db	0x47, 0x40, 0x30, 0x51, 0x3f, 0x43, 0x30, 0x51, 0x41, 0x40, 0x30, 0x21, 0x40, 0x3b, 0x4f, 0x40
	db	0x47, 0x42, 0x54, 0x40, 0x50, 0x23, 0x4f, 0x40, 0x47, 0x46, 0x2c, 0x3f, 0x40, 0x5c, 0x38, 0x2f
	db	0x3e, 0x43, 0x30, 0x21, 0x3f, 0x44, 0x40, 0x40, 0x47, 0x3e, 0x2b, 0x3f, 0x22, 0x57, 0x3d, 0x56
	db	0x28, 0x43, 0x49, 0x40, 0x4f, 0x38, 0x5b, 0x51, 0x3f, 0x3f, 0x20, 0x2f, 0x55, 0x45, 0x50, 0x40
	db	0x50, 0x3f, 0x20, 0x2f, 0x55, 0x42, 0x2c, 0x3f, 0x41, 0x40, 0x3d, 0x43, 0x3e, 0x56, 0x49, 0x50
	db	0x41, 0x44, 0x40, 0x34, 0x51, 0x23, 0x2f, 0x49, 0x4f, 0x38, 0x5b, 0x45, 0x29, 0x40, 0x5d, 0x22
	db	0x42, 0x47, 0x2c, 0x3e, 0x45, 0x24, 0x42, 0x34, 0x3d, 0x40, 0x47, 0x40, 0x3f, 0x29, 0x50, 0x4f
	db	0x50, 0x3e, 0x5f, 0x5f, 0x47, 0x40, 0x4b, 0x24, 0x29, 0x4b, 0x40, 0x40, 0x30, 0x42, 0x27, 0x2a
	db	0x22, 0x57, 0x4c, 0x3a, 0x52, 0x41, 0x40, 0x5a, 0x40, 0x40, 0x3a, 0x41, 0x4f, 0x20, 0x3a, 0x54
	db	0x4c, 0x22, 0x5e, 0x41, 0x40, 0x40, 0x22, 0x23, 0x28, 0x3f, 0x20, 0x2f, 0x45, 0x46, 0x54, 0x40
	db	0x4f, 0x38, 0x5b, 0x55, 0x3f, 0x27, 0x42, 0x34, 0x51, 0x23, 0x4f, 0x41, 0x40, 0x2a, 0x2a, 0x38
	db	0x2e, 0x2f, 0x35, 0x43, 0x29, 0x42, 0x46, 0x2d, 0x51, 0x34, 0x2c, 0x45, 0x21, 0x3d, 0x40, 0x21
	db	0x52, 0x3d, 0x4f, 0x2e, 0x43, 0x40, 0x50, 0x33, 0x50, 0x50, 0x4b, 0x44, 0x4d, 0x5b, 0x51, 0x33
	db	0x20, 0x58, 0x56, 0x28, 0x56, 0x45, 0x20, 0x59, 0x29, 0x41, 0x5c, 0x3f, 0x43, 0x4d, 0x40, 0x40
	db	0x26, 0x55, 0x30, 0x30, 0x5e, 0x5a, 0x42, 0x40, 0x26, 0x4d, 0x2a, 0x55, 0x41, 0x58, 0x56, 0x30
	db	0x28, 0x43, 0x31, 0x30, 0x3a, 0x2a, 0x3d, 0x40, 0x2c, 0x23, 0x4a, 0x42, 0x35, 0x2d, 0x4f, 0x3b
	db	0x28, 0x22, 0x40, 0x5d, 0x3b, 0x4f, 0x4c, 0x40

; Below is the source code to the encoded program

;      1                                  	bits	16
;      2                                  	org		0x156
;      3                                  
;      4                                  init:
;      5                                  	; Switch to 320x200x8 mode
;      6 00000000 B81300                  	mov		ax, 0x13
;      7 00000003 CD10                    	int		0x10
;      8                                  
;      9 00000005 8CC8                    	mov		ax, cs
;     10 00000007 050010                  	add		ax, 0x1000
;     11 0000000A 8EE8                    	mov		gs, ax
;     12                                  	
;     13 0000000C BAC803                  	mov		dx, 0x3c8
;     14 0000000F 31C0                    	xor		ax, ax
;     15 00000011 EE                      	out		dx, al			; palette write index = 0
;     16                                  
;     17 00000012 42                      	inc		dx
;     18                                  	
;     19 00000013 B90001                  	mov		cx, 0x100
;     20 00000016 BB8000                  	mov		bx, 0x80
;     21                                  palinitloop:
;     22 00000019 69C30B00                	imul	ax, bx, 45 / 4
;     23 0000001D 86E0                    	xchg	ah, al
;     24 0000001F EE                      	out		dx, al
;     25 00000020 69C32100                	imul	ax, bx, 134 / 4
;     26 00000024 86E0                    	xchg	ah, al
;     27 00000026 EE                      	out		dx, al
;     28 00000027 69C32A00                	imul	ax, bx, 171 / 4
;     29 0000002B 86E0                    	xchg	ah, al
;     30 0000002D EE                      	out		dx, al
;     31 0000002E 43                      	inc		bx
;     32 0000002F E2E8                    	loop	palinitloop
;     33                                  
;     34 00000031 0FA8                    	push	gs
;     35 00000033 07                      	pop		es	
;     36 00000034 31FF                    	xor		di, di
;     37 00000036 31F6                    	xor		si, si
;     38 00000038 31C0                    	xor		ax, ax
;     39 0000003A B90080                  	mov		cx, 0x8000
;     40 0000003D F3AB                    	rep		stosw
;     41                                  
;     42 0000003F 8CE8                    	mov		ax, gs
;     43 00000041 050010                  	add		ax, 0x1000
;     44 00000044 8EC0                    	mov		es, ax
;     45 00000046 31C0                    	xor		ax, ax
;     46 00000048 B90080                  	mov		cx, 0x8000
;     47 0000004B F3AB                    	rep		stosw
;     48                                  	
;     49 0000004D BB0000                  	mov		bx, 0
;     50                                  
;     51                                  renderloop:
;     52 00000050 8CE8                    	mov		ax, gs
;     53 00000052 01D8                    	add		ax, bx
;     54 00000054 8ED8                    	mov		ds, ax
;     55                                  	
;     56 00000056 8CE8                    	mov		ax, gs
;     57 00000058 81F30010                	xor		bx, 0x1000
;     58 0000005C 01D8                    	add		ax, bx
;     59 0000005E 8EC0                    	mov		es, ax
;     60                                  
;     61 00000060 53                      	push	bx
;     62                                  	
;     63 00000061 B90400                  	mov		cx, 4
;     64                                  droploop:
;     65 00000064 E8A200                  	call	rand
;     66 00000067 93                      	xchg	ax, bx
;     67 00000068 E89E00                  	call	rand
;     68 0000006B 0007                    	add		[bx], al
;     69 0000006D 0047FF                  	add		[bx-1], al
;     70 00000070 004701                  	add		[bx+1], al
;     71 00000073 0087C0FE                	add		[bx-320], al
;     72 00000077 00874001                	add		[bx+320], al
;     73 0000007B D0F8                    	sar		al, 1
;     74 0000007D 0087C1FE                	add		[bx-319], al
;     75 00000081 0087BFFE                	add		[bx-321], al
;     76 00000085 00873F01                	add		[bx+319], al
;     77 00000089 0087BFFE                	add		[bx-321], al
;     78 0000008D E2D5                    	loop	droploop
;     79                                  
;     80 0000008F 5B                      	pop		bx
;     81                                  
;     82 00000090 E89000                  	call	vsync
;     83                                  
;     84                                  updateloop:
;     85 00000093 0FBE45FF                	movsx	ax, byte [di-1]
;     86 00000097 0FBE5501                	movsx	dx, byte [di+1]
;     87 0000009B 01D0                    	add		ax, dx
;     88 0000009D 0FBE95C0FE              	movsx	dx, byte [di-320]
;     89 000000A2 01D0                    	add		ax, dx
;     90 000000A4 0FBE954001              	movsx	dx, byte [di+320]
;     91 000000A9 01D0                    	add		ax, dx
;     92 000000AB D1F8                    	sar		ax, 1
;     93 000000AD 260FBE15                	movsx	dx, byte [es:di]
;     94 000000B1 29D0                    	sub		ax, dx
;     95 000000B3 89C2                    	mov		dx, ax
;     96 000000B5 C1FA05                  	sar		dx, 5
;     97 000000B8 29D0                    	sub		ax, dx
;     98 000000BA 3D7000                  	cmp		ax, 0x70
;     99 000000BD 7F0A                    	jg		abovemax
;    100 000000BF 3D90FF                  	cmp		ax, 0xff90
;    101 000000C2 7D07                    	jge		ok
;    102 000000C4 B090                    	mov		al, 0x90
;    103 000000C6 E90200                  	jmp		ok
;    104                                  abovemax:
;    105 000000C9 B070                    	mov		al, 0x70
;    106                                  ok:
;    107 000000CB AA                      	stosb
;    108 000000CC E2C5                    	loop	updateloop
;    109                                  
;    110 000000CE E85200                  	call	vsync
;    111                                  
;    112 000000D1 6800A0                  	push	0xa000
;    113 000000D4 07                      	pop		es
;    114 000000D5 0FA8                    	push	gs
;    115 000000D7 53                      	push	bx
;    116 000000D8 8CE8                    	mov		ax, gs
;    117 000000DA 050020                  	add		ax, 0x2000
;    118 000000DD 8EE8                    	mov		gs, ax
;    119                                  finalloop:
;    120 000000DF 0FBE854101              	movsx	ax, [di+321]
;    121 000000E4 0FBE55FF                	movsx	dx, [di-1]
;    122 000000E8 29D0                    	sub		ax, dx
;    123 000000EA D1F8                    	sar		ax, 1
;    124 000000EC 0480                    	add		al, 0x80
;    125 000000EE AA                      	stosb
;    126 000000EF E2EE                    	loop	finalloop
;    127 000000F1 5B                      	pop		bx
;    128 000000F2 0FA9                    	pop		gs
;    129                                  
;    130 000000F4 60                      	pusha
;    131 000000F5 B411                    	mov		ah, 0x11
;    132 000000F7 CD16                    	int		0x16
;    133 000000F9 61                      	popa
;    134 000000FA 0F8452FF                	jz		renderloop
;    135                                  
;    136                                  exit:
;    137 000000FE B80300                  	mov		ax, 3
;    138 00000101 CD10                    	int		0x10
;    139 00000103 B410                    	mov		ah, 0x10
;    140 00000105 CD16                    	int		0x16
;    141 00000107 CD20                    	int		0x20
;    142                                  
;    143                                  
;    144                                  ; Output
;    145                                  ;   ax = Random number
;    146                                  rand:
;    147                                  	; Get next random number, use init code as rand seed since we don't need it anymore
;    148 00000109 66A1[0000]              	mov		eax, [init]
;    149 0000010D 6669C0FD430300          	imul	eax, eax, 214013
;    150 00000114 6605C39E2600            	add		eax, 2531011
;    151 0000011A 66A3[0000]              	mov		[init], eax
;    152 0000011E 66C1E810                	shr		eax, 16
;    153 00000122 C3                      	ret
;    154                                  
;    155                                  vsync:
;    156                                  	; Wait for VSYNC, locks framerate to 60 FPS and prevents artifacts
;    157 00000123 BADA03                  	mov		dx, 0x3da
;    158                                  vsyncwait1:
;    159 00000126 EC                      	in		al, dx
;    160 00000127 A808                    	test	al, 8
;    161 00000129 75FB                    	jnz		vsyncwait1
;    162                                  	
;    163                                  vsyncwait2:
;    164 0000012B EC                      	in		al, dx
;    165 0000012C A808                    	test	al, 8
;    166 0000012E 74FB                    	jz		vsyncwait2
;    167 00000130 C3                      	ret
