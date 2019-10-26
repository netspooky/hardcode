/*

    Hi!


 [this]

    spriteripper.c, locate sprites in raw data and save them to .jrs files.
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

  
 [intro]
	
    This code is a quick hack of my fontripper.c to grab sprites and
    save them to a file. Sprites are grabbed from a file which can also
    contain fonts, and saved almost verbatim to disk. The only addition
    to the sprite data is a header which looks like this:

      <jeeves raw sprite version 1 -- fileformat>

      offset      size                  data
      0           4                     "jrs1"
      4           1                     width of sprites
      5           1                     height of sprites
      6           1                     amount of sprites in this file
      7           1                     flags (currently not used)
      8           (width*height*count)  sprite data

    For more info on creating input files for this look at fontripper.c,
    spriteripper.c locates and saves fixed-width fonts detected in such
    a file.

    -- Kuno Woudt <warp-tmt@dds.nl>


 [history]

    - 2001/03/22 Kuno Woudt <warp-tmt@dds.nl>.
      (first version, based on fontripper.c)

 

*/


char * PACKAGE = "spriteripper";
char * VERSION = "0.0.1";
char * COPYRIGHT = "Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>\n"            \
"This program comes with NO WARRANTY, to the extent permitted by law.\n"      \
"You may redistribute copies of this program\n"                               \
"under the terms of the GNU General Public License.\n"                        \
"For more information about these matters,\n"                                 \
"see the file named COPYING.\n";
char * HELP = "syntax: spriteripper [filename]\n";

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_CHARS 0x100
#define MAX_FONTS 10
char file_naming_scheme[MAX_FONTS] = "0123456789";

void
error(const char * p, const char * p2)
{
  fprintf(stderr, "%s: %s%s.\n", PACKAGE, p, p2);
    
  exit(1);
}

void
savefont(unsigned char * t_data, char * filename, 
         unsigned char count, int x, int y, unsigned char flags)
{
  int size;

  FILE * out;                        /* output                              */

  if(t_data != NULL)
    {
      fprintf(stderr, "%s: saving %d sprites.\n", PACKAGE, count);

      size = x*y*count;

      out = fopen(filename, "wb");
      if(out == NULL)
        error("cannot open file: ", filename);

      fputs("jrs1", out);   /* header tag thingy                             */
      fputc(x, out);        /* cell width                                    */
      fputc(y, out);        /* cell height                                   */
      fputc(count, out);    /* character count                               */
      fputc(flags, out);    /* bit 0 = mono, bit 1 = non-fixed-width file    */

      fwrite( t_data, 1,  size, out);  /* font data.                         */

      free(t_data);
    }
}

int
bg(char c, unsigned char * colours, unsigned char count)
{
  int r = 1;
  int i;

  for(i=0; i<count; r = (colours[i++]!=c) && r);

  return r;
}


void
decode_char(unsigned char * data,     /* [x*y] array for char                 */
            unsigned char * b,        /* pointer to top left corner of char   */
            unsigned int bwidth,      /* width of *b buffer                   */
            unsigned char width,      /* width of character                   */
            unsigned char height,     /* height of character                  */
            unsigned char font_bg,    /* colour of transparent runs           */
            unsigned char * m,        /* non transparent colours              */
            unsigned char mc)         /* amount of non transparent colours    */
{
  unsigned int y;
  unsigned int x;

  for(y=0; y<height; y++)
    {
      memcpy(data+(y*width), b+(y*bwidth), width);
      for(x=0; x<width; x++)
        if(bg(data[y*width+x], m, mc))
          data[y*width+x] = font_bg;
    }
}

int
main(int argc, char* argv[])
{
  FILE * in;                         /* input                               */
  char * outfile;                    /* output filename                     */
  char * dot = NULL;                 /* sequential char in outfile          */

  int filesize;                      /* in filesize                         */
  int total = 0;                     /* total bytes read from file          */

  unsigned char font_count = 0;      /* amount of fonts discovered.         */
  unsigned int char_count;           /* amount of chars discovered.         */
  unsigned int char_width = 0;       /* character width                     */
  unsigned int char_height = 0;      /* character height                    */
  unsigned int buf_char_start;       /* character start in buffer           */
  unsigned int buf_char_end;         /* character end in buffer             */
  unsigned int buf_width;            /* input buffer width                  */
  unsigned int buf_height;           /* input buffer height                 */

  unsigned char * bufptr = NULL;     /* pointer to move about in buffer     */
  unsigned char * buffer = NULL;     /* temporary input data storage.       */
  unsigned char * t_data = NULL;     /* temporary font storage.             */
  unsigned char font_fg;             /* colour for mono fonts               */
  unsigned char font_bg;             /* background colour (end of multi[])  */
  unsigned char char_start;          /* colour marking start of char        */
  unsigned char char_end;            /* colour marking end of char          */
  unsigned char font_multi[0x100];   /* colours for multicolour fonts       */
  unsigned char font_multicount = 0; /* amount of colours in non-mono fonts */ 

  unsigned int found;                /* found a font                        */
  unsigned char x, y;                /*                                     */

  if(argc!=2)
    {
      fprintf(stderr, "%s %s\n%s\n", PACKAGE, VERSION, COPYRIGHT);
      error("\nusage: spriteripper <inputfile>.", "");
    }

  outfile = (char *) calloc(1, strlen(argv[1])+5);
          
  strcpy(outfile, argv[1]);

  dot = strrchr(outfile, '.');
  if(dot != NULL) strcpy(dot, "_.jrs"); /* jeeves typeface */

  if(NULL == (in = fopen(argv[1], "rb")))
    error("cannot open: ", argv[1]);

  fseek(in, 0, SEEK_END);
  filesize = ftell(in);
  fseek(in, 0, SEEK_SET);

  /* determine buffer dimensions */
  if(filesize == 640*480)
    {
      buf_width = 640;
      buf_height = 480;
    }
  else if(filesize == 320*200)
    {
      buf_width = 320;
      buf_height = 200;
    }
  else
    {
      error("cannot determine dimensions, please use a 320x200 or" 
            " 640x480 input file", "");
    }

  fprintf(stderr, "%s: Input buffer is %dx%d.\n", 
          PACKAGE, buf_width, buf_height);

  /* allocate memory and load font data */
  buffer = (unsigned char *) malloc(filesize);
  bufptr = buffer;

  if(buffer == NULL)
    error("out of memory", "");

  total = fread(buffer, 1, filesize, in);
  fclose(in);

  if(total<filesize) 
    error("something strange may have happened, " 
          "please check the output before using", "");

  /*
    if(NULL == (out = fopen(outfile, "wb")))
    error("cannot open: ", outfile);

    fclose(out); 
  */

  char_start = *bufptr++;  
  char_end = *bufptr++;  
  font_bg = *bufptr++;    
  font_fg = *bufptr++;  

  while(font_bg != *bufptr)
    font_multi[font_multicount++] = *bufptr++;

  fprintf(stderr, "%s: %d colours in multicolour sprite(s).\n", 
          PACKAGE, font_multicount);

  bufptr++;

  /* use fixed-width char_start and char_end. */
  char_start = *bufptr++;  
  char_end = *bufptr++;  

  buf_char_end = bufptr-buffer;

  while(bufptr++ < buffer+filesize)
    {
      if(char_start == *bufptr)
        {
          buf_char_start = bufptr-buffer;
          
          /* found topleft corner, go looking for bottom right. */
          for(found = 0; (buf_char_end < filesize) && (!found); buf_char_end++)
            if(buffer[buf_char_end] == char_end) 
              {
                found = 1;

                /* found bottom right corner, determine 
                   width/height and start decoding */
                x = buf_char_end % buf_width - buf_char_start % buf_width - 1;
                y = buf_char_end / buf_width - buf_char_start / buf_width - 1;

                if((x == char_width) && (y == char_height))
                  {
                    /* character is same size, so this is just the next 
                       character of the current font, decode and continue. */
                    decode_char(t_data + x*y*char_count, 
                                buffer + buf_char_start + buf_width + 1,
                                buf_width, x, y, 0, 
                                font_multi, font_multicount);

                    char_count++;
                  }
                else
                  {
                    /* character dimensions are new, so this must be the first 
                       character in a new font, so store the previous font and 
                       setup decoding the next. */
                    savefont(t_data, outfile, char_count, char_width, char_height, 0);


                    if(font_count > MAX_FONTS)
                      error("too many sprites in file, please recompile " 
                            "spriteripper.c and try again.\n","");
                      
                    *dot = file_naming_scheme[font_count];

                    char_width = x;
                    char_height = y;
                    char_count = 0;
                    font_count++;

                    fprintf(stderr, "%s: decoding sprites %s with character size: "
                            "%dx%d,...\n", PACKAGE, outfile, x, y);

                    t_data = (unsigned char *) malloc(x*y*MAX_CHARS);

                    if(t_data == NULL)
                      error("out of memory", "");

                    decode_char(t_data + x*y*char_count, 
                                buffer + buf_char_start + buf_width + 1,
                                buf_width, x, y, 0, 
                                font_multi, font_multicount);

                    char_count++;
                  }
              }
        }
    }

  savefont(t_data, outfile, char_count, char_width, char_height, 0);

  free(buffer);

  return 0;
}
