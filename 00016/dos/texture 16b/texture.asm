; ---------------------------------------------------
;                T e x t u r e    16 b
; ---------------------------------------------------
; 16 byte MSDOS procedural text mode graphic effect
; by HellMood / DESiRE
; Release : January 2015
; Greetings to every sizecoder out there!
; Let's make 16byters a thing again ♥

org 0x100
bits 16
; assembler information. i use NASM
; "nasm texture.asm -fbin -o texture.com"

push ax
; equals "0x50" which is the number of columns
; in the standard text mode (80x25), this way
; [si] = [0x100] = 0x50, which allows an optimized
; row/column generation later. Also, this is a one
; byte instruction, which does no harm to the rest
; of the code flow, and needs no further jumping
; into the middle of instructions ;)
push 0xB670
pop es
; Let ES point to the start of the text memory.
; There are several ways to save a byte here, with
; the usage of "LES ??,[(bx+)si(+n)]" like "m8trix",
; reusing code as segment data, but i am already
; at 16bytes, and the segment alignment is crucial
; to the visual effect : First, you will want a
; segment in the form "0xB800 - n * 10", to have 
; horizontal alignment (incrementing segments shift
; 16 bytes, 160 = 80 * 2 = 80 colored chars /w 2byte)
; Second, you will want to make that 0xB800 - n * 80
; to have good vertical alignment, like, having the
; pattern start at the top left corner. That is
; of course strongly bound to the pattern itself.
; Third, you can now shift through several segments
; by changing the segment value yourself. This offers
; a little design space for tuning the effect. Personally
; i don't like the original 0xB800, but maybe it's
; just me :D. Fourth, a neat little thing you might
; have noticed with this value: The first three bytes
; of the code now spell "Php" ^^ Values you might try 
; here : 0xB800, 0xB7B0, 0xB760, 0xB710, 0xB6C0 etc.
L: stosw
; Finally, write a colored char to the screen and
; increment the memory pointer DI. It is important
; to increment DI before doing using DIV, so that
; division overflow does not occur right at the start.
; DI is "0xFFFE" at start on almost every DOS environment
; and plain "0x0000" after the first "stosw".
mov ax,di
idiv byte [si]
; Compose row and column number from the memory pointer
; so they end up in AL and AH. This saves one byte
; over moving "0x50" to any register and then DIV.
; ATTENTION : this can, and will(!) overflow, and it is
; totally intended. When DI reaches 0x5000, division by
; "0x50" would result in 0x100, which doesn't fit into
; on byte, therefore, division overflow is triggered, and
; exits the program. But at this point, 255 rows have been
; written already, which is enough even for a backshifted
; segment start. By changing the segment (described above)
; you can chose which 25 of the 255 lines you want to see.
; If you use IDIV instead of DIV, it is reduced to 128
; possible lines. With the special segment i chose, it
; also suppresses the unwanted 25th row, resulting in a
; well  aligned texture (10*8 x 3*8 chars)
; NOTE : DOSBOX seems to trigger the overflow, but does
; not exit the program.
; NOTE : On my old WinXP Laptop, the overflow occurs right
; at the start. However, if you start "debug", then quit
; it the run "texture", it shows the desired effect.
xor ah,al
mov al,0xB1
; Now, that column and row are available in AL and AH, just
; XOR them to get a color combination of foreground 
; background from it. Using "0xB1" as the char beeing
; written, which is a XOR pattern itself, creates the
; effect of up to 256 colors combinations via dithering.
; On systems using the high bit of the color byte to
; indicate blinking, it is 128 colors combinations. Many
; combinations map to same/similar colors, so the true
; and perceived number of colors is lower of course ;)
; The segment i chose above, is located in an area which
; should be free of blinking on any system. The 25th row
; which would blink on some systems, is supressed by using
; IDIV instead of DIV. If you have fun with blinking effects,
; switch back to DIV and lower the segment value even more ;)
jmp short L
; rinse and repeat =)
