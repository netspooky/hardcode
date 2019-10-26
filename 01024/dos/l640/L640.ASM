	.MODEL	small
	.STACK	100h
	.CODE
	push	ds
	sub	ax,ax
	push	ax
	mov	ah,00          ;set video mode
	mov	al,5dh
	int	10h
	mov	ah,0bh        ;set pallette
	mov	bh,01
	mov	bl,03
	int	10h
	mov	cx,160       ;set hor col
	mov	dx,000       ;set vert col
	mov	ax,@data
	mov	ds,ax
	mov	bx,OFFSET table   ;point to table of colors
do:	mov	al,[bx]         ;load al with the color
	inc	bx
	inc	bp
dis:

	mov	si,200
try:	mov	ah,0ch        ;dos write dot routine
	int	10h

	dec	si
	inc	cx
	cmp	si,0
	jne	try
	cmp	al,0ffh
	je	done
	mov	cx,160
calc:
	inc	dx
	inc	dx
	jmp	do
done:	mov	ah,0   ;set up for any key to be hit
	int	16h    ;make the call for the keyboard routine
	cmp	al,0
	je	done   ;if key is not normal retry
	mov	ah,00     ;return to text mode
	mov	al,03
	int	10h
	mov	ah,4ch
	int	21h
	.DATA
table	db	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
	db	21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38
	db	39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57
	db	58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75
	db	76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93
	db	94,95,96,97,98,99,100,101,102,103,104,105,106,107,108
	db	109,110,111,112,113,114,115,116,117,118,119,120,121,122
	db	123,124,125,126,127,128,129,130,131,132,133,134,135,136
	db	137,138,139,140,141,142,143,144,145,146,147,148,149,150
	db	151,152,153,154,155,156,157,158,159,160,161,162,163,164
	db	165,166,167,168,169,170,171,172,173,174,175,176,177,178
	db	179,180,181,182,183,184,185,186,187,188,189,190,191,192
	db	193,194,195,196,197,198,199,200,201,202,203,204,205,206
	db	207,208,209,210,211,212,213,214,215,216,217,218,219,220
	db	221,222,223,224,225,226,227,228,229,230,231,232,233,234
	db	235,236,237,238,239,240,241,242,243,244,245,246,247,248
	db	249,250,251,252,253,254,255
	end
