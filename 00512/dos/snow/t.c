#include <stdio.h>

int main(int argc, char **argv)
{
	FILE *fin = fopen(argv[1], "rb");
	FILE *fout = fopen(argv[2], "w");
	int b;

	b = fgetc(fin);
	while (b != -1) {
		fprintf(fout, "DW 0x%02X%02X\n", (b&0xF)+0x20, (b>>4)+0x20);
		b = fgetc(fin);
	}
}
