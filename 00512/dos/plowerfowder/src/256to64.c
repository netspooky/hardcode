/*
	-- 256to64 --
	converts a binary input file to a base64 (6-bit) ASCII file
	that can be included in assembly projects.

	by thefox <fuchs@runkkaajat.org> 2004
	
	public domain.
*/

#include <stdio.h>

int main(int argc, char **argv)
{
	FILE *fp;
	unsigned long t;
	unsigned char a, b, c;
	unsigned char q, w, e, r;
	unsigned int mc;

	if(--argc != 1) {
		printf("usage: 256to64 <infile>\n");
		return 1;
	}
	
	fp = fopen(argv[1], "rb");
	if(fp == NULL)
		return 2;

	printf("byte \"");	

	for(mc = 1; ; ++mc) {
		a = fgetc(fp);
		if(feof(fp))
			break;
		
		b = fgetc(fp);
		if(feof(fp)) {
			b = c = 0;
		}
		else {
			c = fgetc(fp);
			if(feof(fp)) {
				c = 0;
			}
		}

		t = a | (b << 8) | (c << 16);
		
		q = ((t >> 18) & 0x3f) + 0x20;
		w = ((t >> 12) & 0x3f) + 0x20;
		e = ((t >> 6) & 0x3f) + 0x20;
		r = (t & 0x3f) + 0x20;
		
		putchar(q);
		if(q == '"')
			putchar('"');
		putchar(w);
		if(w == '"')
			putchar('"');
		putchar(e);
		if(e == '"') 
			putchar('"');
		putchar(r);
		if(r == '"')
			putchar('"');
		
		if((mc % 16) == 0)
		{
			printf("\"\nbyte \"");
			mc = 0;
		}
	};

	fclose(fp);
	printf("\"\n");

	return 0;
}
