; "VGA64" by HellMood / DESiRE
; released May 2015
; the 64 byte version of "vga55" (128b) by "Warner"
; see : http://www.pouet.net/prod.php?which=65673
;
; had to sacrifice "the return to textmode" and perfect alignment
; feel free to improve further =) (i feel both could fit in, but i'm lazy)
;
; see youtube video (~30000 cycles in DosBox)
; https://www.youtube.com/watch?v=CTsGNywe6SE
;
; Greets and Respect go to : 
; homecoded, rrrola, frag, Baudsurfer, Optimus, p01
; Sensenstahl, Whizart, g0blinish, Rudi, orbitaldecay,
; igor, Drift and all Desire members =)
;
push 0xa000			; word [si] = word [0x100] = 0x0068 = 100
pop es
mov al,0x13			; switch to 320*200 in 256 colors
int 0x10
L:
cwd					; DX = 0 ( AH=0 or AH=1 before)
mov ax,di			; make x,y from counter DI
mov bx,320
div bx				; AX = y, DX = x
sub dx,[si]			; x = x - 100	; 160 in the original
sub ax,[si]			; y = y - 100
js  F
not ax				; basically avoids 0 in AX and mirrors at 0
F:
sal dx,4			; x = x << 4 (arithmetic)
xchg bx,ax			; y -> BX, 320 -> AX
xchg dx,ax			; (x << 4) -> AX, 320 -> DX
cwd					; DX = 0 (AX < 0x7fff before)
idiv bx				; AX = (x << 4) / y
shr ax,3			; AX = ((x << 4) / y) >> 3
xchg cx,ax			; "push AX" to CX
cwd					; DX = 0 (AX < 0x7fff before)
mov ax,256			; AX = 256
idiv bx				; AX = 256 / y
add ax,cx			; AX = ((x << 4) / y) >> 3 + ( 256 / y)
sub ax,bp			; AX = ((x << 4) / y) >> 3 + ( 256 / y) - frame
aam 24				; "& 15" originally, but "aam 24" maps smoother
add al,32			; map to coder colors
stosb				; write pixel, increment pixel counter
inc di				; the dither trick (+double "inc DI") writes 3 * (1/3) frames 
inc di				; until DI is 0 again (use "test DI,DI" for no dither)
jnz L				; next pixel
inc bp				; next frame
mov ah,1			; check for any key
int 0x16			
jz L				; loop if no key
ret					; exit