xor al,0x13			; video mode & palette offset into gray
int 0x10			; execute : set mode & set pixel
mov ax,cx			; get pixel number (~column number)
imul ax				; squared into DX -> row for setpixel
mov ax,[fs:0x46C]	; get timer1 value (18.2 times a second)
or al,0x4B			; melody pattern + 2 LSB for speaker link
out 0x42,al			; set new countdown for timer2 (two passes)
out 0x61,al			; link timer2 to PC speaker (2 LSBs are 1)
and al,0xF9			; sync colors to melody pattern
add al,ch			; use pixelnumber as gray base offset
aam 0x09			; reduce to 9 colors
mov ah,0x0C			; set sub opcode to "set pixel"
inc cx				; next pixel
jmp si				; rinse and repeat