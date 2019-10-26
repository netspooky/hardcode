#pragma inline

void main(void)
{
	int x, y;

/*----------------------------------------------------------------------------
 *								set vga mode
 *----------------------------------------------------------------------------*/

   	/*set vga mode*/
   	asm mov ax, 13h;
   	asm int 10h;

/*----------------------------------------------------------------------------
 *								main loop
 *----------------------------------------------------------------------------*/
	/*set output base address*/
	asm mov ax, 0a000h;
	asm mov es, ax;
	
	asm mainloop:

	/*reset output offset*/
	asm xor di, di;

	/*write pixels*/
	for (y=-100; y<100; y++) {
		int s = (y < 1)?(1 - y):y;
		for (x=-160; x<160; x++) {
			_AX = ((((((x << 4) / s) >> 3) + (256 / s) + _BX)) & 15) + 32;
			asm stosb;
		}
	}

	/*increase scrolling offset*/
	asm inc bx;

	/*loop until keypress*/
	asm mov ah, 01h;
	asm int 16h;
	asm jz short cs:mainloop;
	
	/*return to CO80*/
	asm mov ax, 03h;
	asm int 10h;
		
}
