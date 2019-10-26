/* a simple utility to dump binary into a header file
   
   Copyright (C) 1998 Jan Vondrak
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

#include <stdio.h>

#define MAX_LEN 128000

static unsigned char buffer[MAX_LEN];

int main (int argc, char **argv) {
	int i, len;
	FILE *f = fopen (argv[1], "r");
    
	if (!f)
		return 1;
    
	fseek (f, 0, SEEK_END);
	len = ftell (f);
	if (len > MAX_LEN)
		return 1;
    	
	fseek (f, 0, SEEK_SET);
	fread (buffer, 1, len, f);
	fclose (f);

	/* header file */
	if (*argv[3] == 'h') {
		printf ("#define %s_LEN  %d\n\n", argv[2], len);
		printf ("extern const unsigned char %s_DATA[%s_LEN];\n",argv[2],argv[2]);
		return 0;
	}

	printf ("const unsigned char %s_DATA[%d] = {\n", argv[2], len);
    
	for (i = 0; i < len; i++)
		printf ("0x%02X,\n", buffer[i]);
            
	printf ("};\n");

	return 0;
}
