#pragma inline
#include <stdlib.h>
#include <stdio.h>
#include <dos.h>
typedef unsigned char byte;
typedef unsigned short word;
typedef char paltype[256][3];
paltype pl;
word VGA=0xa000;
word screen_width=320;
byte far *getromfont()
{
	asm push bp
	asm	mov ax,0x1130
	asm	mov bh,3
	asm	int 10h
	asm	mov dx,es
	asm	mov ax,bp
	asm	pop bp
	return MK_FP(_DX,_AX);
}
void opengraph()
{
asm {
	push ax
	mov ax,13h
	int 10h
	pop ax
	}
}
void closegraph()
{
	asm {
		push ax
		mov ax,3
		int 10h
		pop ax
		}
}
void putpixel(word x,word y,byte color,word segment)
{
asm push    es
asm mov     es,[segment]
asm mov     di,[x]
asm mov     dx,[y]
asm mov     bx, dx
asm shl     dx, 8
asm shl     bx, 6
asm add     dx, bx
asm add     di, dx
asm mov     ax, [color]
asm stosb
asm pop		es
}
byte getpixel(word x,word y,word segment)
{
asm push 	ds
asm mov     ds,[segment]
asm mov     si,[x]
asm mov     dx,[y]
asm mov     bx, dx
asm shl     dx, 8
asm shl     bx, 6
asm add     dx, bx
asm add     si, dx
asm lodsb
asm pop		ds
	return _AL;
}
void waitvbl(void)
{
	asm mov dx,3dah
	l1:
	asm	in al,dx
	asm	test al,8
	asm	jnz l1
	l2:
	asm	in al,dx
	asm	test al,8
	asm	jz l2
}
void setrgb(byte color,byte r,byte g,byte b)
{
asm {
	mov dx,3c8h
	mov al,color
	out dx,al
	inc dx
	mov al,[r]
	out dx,al
	mov al,[g]
	out dx,al
	mov al,[b]
	out dx,al
	}
}
void setrgbrange(byte palette[],word start,word count)
{
	asm mov ax,0x1012
	asm	mov bx,start
	asm	mov cx,count
	asm	les dx,palette
	asm	int 10h
}
void clearscreen(int segment)
{
	asm push es
	asm mov cx,32000
	asm	mov es,segment
	asm	sub di,di
	asm	sub ax,ax
	asm	cld
	asm	rep stosw
	asm pop es
}
void line(int x1, int y1, int x2, int y2 , byte color , int segment)
{
int i, deltax, deltay, numpixels,
	d, dinc1, dinc2,
	x, xinc1, xinc2,
	y, yinc1, yinc2;

  deltax = abs(x2 - x1);
  deltay = abs(y2 - y1);
  if (deltax >= deltay)
	{
	  numpixels = deltax + 1;
	  d = (2 * deltay) - deltax;
	  dinc1 = deltay << 1;
	  dinc2 = (deltay - deltax) << 1;
	  xinc1 = 1;  xinc2 = 1;
	  yinc1 = 0;  yinc2 = 1;
	}
  else
	{
	  numpixels = deltay + 1;
	  d = (2 * deltax) - deltay;
	  dinc1 = deltax << 1;
	  dinc2 = (deltax - deltay) << 1;
	  xinc1 = 0; xinc2 = 1;
	  yinc1 = 1; yinc2 = 1;
	}
  if (x1 > x2)
	{
	  xinc1 = - xinc1;
	  xinc2 = - xinc2;
	}
  if (y1 > y2)
	{
	  yinc1 = - yinc1;
	  yinc2 = - yinc2;
	}
  x = x1;y = y1;
  for(i = 1;i<=numpixels;i++)
	{
	  putpixel(x, y, color,segment);
	  if (d < 0)
		{
		  d = d + dinc1;
		  x = x + xinc1;
		  y = y + yinc1;
		}
      else
		{
		  d = d + dinc2;
		  x = x + xinc2;
		  y = y + yinc2;
		}
	}
}
void flip(word source,word dest)
{
  asm   push es
  asm   push ds
  asm 	mov     es, [dest]
  asm 	mov     ds, [source]
  asm 	xor     si, si
  asm 	xor     di, di
  asm 	mov     cx, 32000
  asm 	rep     movsw
  asm   pop ds
  asm   pop es
}
void fadeout()
{
byte r,g,b;
	asm mov cx,255
l1: asm	{
	mov ax,cx
	mov dx,3c7h
	out dx,al
	inc dx
	inc dx
	in al,dx
	cmp al,0
	je j1
	dec al
	}
j1: asm	{
	mov [offset r],al
	in al,dx
	cmp al,0
	je j2
	dec al
	}
j2: asm	{
	mov [offset g],al
	in al,dx
	cmp al,0
	je j3
	dec al
	}
j3: asm	{
	mov [offset b],al
	mov dx,3c8h
	mov ax,cx
	out dx,al
	inc dx
	mov al,[offset r]
	out dx,al
	mov al,[offset g]
	out dx,al
	mov al,[offset b]
	out dx,al
	loop l1
	}
}
void fadein()
{
word fs2;
byte r,g,b;
for(fs2=0;fs2<=255;fs2++)
	{
	asm {
	mov ax,fs2   //pal offseti
	mov bl,3
	mul bl
	mov bx,ax

	mov ax,fs2
	mov dx,3c7h
	out dx,al				   //rengi sec}
	inc dx
	inc dx
	in al,dx   				//red degerini al}

	mov ah,ds:pl[bx]
	cmp al,ah
	je j11						// esitse gec
	jb j1						// altindaysa j1 yallah
	dec al
	jmp j11						// gec
	}
j1: asm inc al
j11:asm {
	mov r,al

	in al,dx    					//green}
	inc bx
	mov ah,ds:pl[bx]
	cmp al,ah
	je j22
	jb j2
	dec al
	jmp j22
	}
j2: asm {
	inc al
	}
j22:asm {
	mov g,al

	in al,dx        			//blue}
	inc bx
	mov ah,ds:pl[bx]
	cmp al,ah
	je j33
	jb j3
	dec al
	jmp j33
	}
j3: asm inc al
j33:asm {
	mov b,al

	mov dx,3c8h 				//rengi sec}
	mov ax,fs2
	out dx,al
	inc dx             			//paleti yaz dx=3c9h}
	mov al,r
	out dx,al
	mov al,g
	out dx,al
	mov al,b
	out dx,al
	}
	}
}
