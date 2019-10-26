/*
  bin2h.c, converts binary data to a c/c++ array in a header file.
  Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING; if not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA


  history:
    - 2001/04/01 Kuno Woudt <warp-tmt@dds.nl>.
      v0.7 . replaced the misleading copyright msg in output files.
    
    - 2001/03/17 Kuno Woudt <warp-tmt@dds.nl>.
      v0.6 . back to .c, c++ compilers are not quite mature yet.
    
    - 2000/09/26 Kuno Woudt <warp-tmt@dds.nl>.
      unsigned char variant.

    - 2000/08/27 Kuno Woudt <warp-tmt@dds.nl>.
      v0.5 . filesize is correct now, trailing zero has been eliminated.

    - 2000/08/27 Kuno Woudt <warp-tmt@dds.nl>.
      v0.4 . small changes to make it compile with gcc-2.95.2 and g++-2.

    - 2000/08/02 Kuno Woudt <warp-tmt@dds.nl>.
      (first version, for ms visual c++)
*/

char * PACKAGE = "bin2h";
char * VERSION = "0.7";
char * COPYRIGHT = "Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>\n"            \
"This program comes with NO WARRANTY, to the extent permitted by law.\n"      \
"You may redistribute copies of this program\n"                               \
"under the terms of the GNU General Public License.\n"                        \
"For more information about these matters,\n"                                 \
"see the file named COPYING.\n";
char * HELP = "syntax: bin2h [filename]\n";


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void
error(const char * p, const char * p2)
{
  fprintf(stderr, "%s: %s%s.\n", PACKAGE, p, p2);
    
  exit(1);
}

const char *
strchrII(const char * s, const char c)
{
  char * t;

  return ((t = strrchr(s, c)) == NULL ? s : t+1);
}


int
main(int argc, char* argv[])
{
  char * outfile;
  char * infile;
  char * header;
  FILE * in;
  FILE * out;
  unsigned int i;
  int filesize;
  int count = 0;
  int total = 0;
  int ch;

  /* this should be an option. */
  int maxcount = 10;

  if(argc!=2)
    {
      fprintf(stderr, "%s %s\n%s\n", PACKAGE, VERSION, COPYRIGHT);
      error("\nusage: bin2h <inputfile>.", "");
    }

  outfile = (char *) calloc(1, strlen(argv[1]));
  infile = (char *) calloc(1, strlen(argv[1])+2);
  header = (char *) calloc(1, strlen(argv[1]));
  
  strcpy(infile, strchrII(argv[1], '/'));
  strcpy(outfile, argv[1]);
  strcat(outfile, ".h");

  for(i=0; i<strlen(infile); i++)
    infile[i] = (infile[i]=='.') ? '_' : infile[i];

  strcpy(header, infile);

  for(i=0; i<strlen(header); i++)
    if((header[i]>='a') && (header[i]<='z')) header[i]=header[i]-('a'-'A');

  if(NULL == (in = fopen(argv[1], "rb")))
    error("cannot open: ", argv[1]);

  if(NULL == (out = fopen(outfile, "wb")))
    error("cannot open: ", outfile);

  fseek(in, 0, SEEK_END);
  filesize = ftell(in);
  fseek(in, 0, SEEK_SET);

  fprintf(out, "/*\n  %s, generated from %s by %s %s.\n" \
          "  %s by Kuno Woudt <warp-tmt@dds.nl>.\n*/\n" \
          "\n" \
          "#ifndef _%s_H_\n" \
          "#define _%s_H_\n" \
          "\n" \
          "#define %s_SIZE %d\n" \
          "unsigned char %s_data[%s_SIZE] = \n{\n\t",
          strchrII(outfile, '/'), strchrII(argv[1], '/'), PACKAGE, 
          VERSION, PACKAGE, header, header, header, filesize, infile, header);

  while((ch = fgetc(in)) != EOF)
    {
      fprintf(out, "0x%02x", ch);
      count++;
      total++;
      if(total!=filesize) fprintf(out, ", ");
      if(count==maxcount) { fprintf(out, "\n\t"); count=0; }
    }

  if(total<filesize) 
    error("something strange may have happened, "
          "please check the output before using.", "");

  fprintf(out, "\n};\n\n#endif /* _%s_H_ */\n", header);

  fclose(out);
  fclose(in);

  return 0;
}
