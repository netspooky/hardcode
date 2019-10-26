/*

    Hi!


 [this]

    fontripper.c, locate fonts in raw data and encode them to .jtf files.
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
	
    This code  is intended to  extract non-proportional  bitmapped fonts
    from raw indexed-mode images and save them to one or more files.
	
    I use  Deluxe Paint IIe to pixel  my fonts, and  the font decoder is 
    heavily influenced by that,  and therefore expects it's font data in 
    a somewhat arbitrary and peculiar format which is described below.
	
    As stated above fonts should be non-proportional (every character in
    the  font should have the same height and  width as other characters 
    in the font), and obviously they're pixel based (no vectors).  Fonts 
    can have more than one colour (usually to provide some anti-aliasing
    for lower  resolutions), or be a  single colour  (which can  changed 
    more easily).

    UPDATE: some  support for proportional fonts is now  available, look 
    below for more details.	

    UPDATE: this is a re-implementation  of the original  c++ fontripper
    in c,  as a result  the single  colour support and  non-proportional 
    code is  completely untested  (in fact,  the current  implementation
    only saves variable width fonts).

    A single  image can contain  multiple fonts, as long as  fonts don't 
    share  lines (so, you can place one  font above the  other, but they 
    can't be next to eachother).  All fonts with the proper markers will
    be automatically discovered and extracted.

    -- Kuno Woudt <warp-tmt@dds.nl>


 [history]

    - 2001/03/17 Kuno Woudt <warp-tmt@dds.nl>.
      (first version, based on fontripper from 8bit/Jeeves64)

 
 [input]	
	
    The typeface decoder  expects fonts in  an 8bpp indexed mode buffer.
    In  order  for the  decoder to  automatically  grab any font  in the 
    buffer and determine the dimensions  and colours used by those fonts
    it has to know a few things about the font.

    First it  needs to know  which colours mark  the top-left and lower-
    right of a character: the colour index which marks the top-left of a
    character should  be placed  at the first pixel  in the buffer;  the
    colour  which marks  the lower-right  should be  placed at  the next 
    pixel, and so on - here's a list:

      buffer[0]       - this colour marks bottom-right of character
      buffer[1]       - this colour marks top-left of character
      buffer[2]       - this colour marks the background colour
                        (i.e. transparent parts)
      buffer[3]       - this is the colour used by single colour fonts
      buffer[4]       - this colour, and any colours following are the
                        colours used by multi-coloured fonts.
      buffer[n]       - a pixel with the same value as buffer[size-3] 
                        (the background colour marks the end of the 
                         list of colours used by multi-coloured fonts)

    Every other colour encountered in the buffer will be treated similar
    to the background c   olour - i.e. they will be treated as  transparent
    and not end up in the font.

 [output]

    FIXME: this section has not yet been written,  please have a look at
    the code for savefont() for more info on the 'jtf2' file format.


 [internal]

    Fonts are RLE encoded, they start  with an unsigned char for the run
    followed by an  unsigned char for the colour value of the run - zero
    is transparent.

    With current amounts  of memory in mind, i've decided  to waste some
    space so  as to be able to  easily locate font  data. When fonts are
    displayed, it is  probably best  to display  the first line of  each 
    character in the string, and then continue with the second line, and
    so on. Font data will be stored with these things in mind:
      
      // this is the start of RLE encoded scanline Y of character Count
      data[ (count*width*height + Y*width) << 1 ]; 

    As you may have  noticed, the RLE encoding is only used to  ease the
    displaying of faces, the compression is not used (quite the opposite
    in fact - the RLE worst case scenario kind of forces me to use twice
    as much as normally  would be required. Some more intelligent scheme 
    is possible  and will be implemented whenever I feel  like it (don't 
    hold your breath :).


  [proportional]

    ``this should be good enough'' support for proportional fonts is now
    included.  When a font  is decoded,  the width of  each character is 
    automatically  determined - so in order to  make proper use  of this 
    feature a `thin' character should be  positioned to  the left of its
    cell  in stead of centering it as you would  do for non-proportional 
    fonts. So - in most  cases a  font can  be used  only for one of the 
    output methods, and not both.
    
    NOTE: because the width  of characters is automatically  determined, 
    ` ' (space) will  usually end up in  the font with  width = 0.  This 
    character will be patched by the encoder to have a width of 0.5em.

*/


char * PACKAGE = "fontripper";
char * VERSION = "0.1.0";
char * COPYRIGHT = "Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>\n"            \
"This program comes with NO WARRANTY, to the extent permitted by law.\n"      \
"You may redistribute copies of this program\n"                               \
"under the terms of the GNU General Public License.\n"                        \
"For more information about these matters,\n"                                 \
"see the file named COPYING.\n";
char * HELP = "syntax: fontripper [filename]\n";

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ASCII     ' '   /* first character in font */
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
savefont(unsigned char * t_data, char * filename, unsigned char ascii, 
         unsigned char count, int x, int y, unsigned char flags, unsigned char bg,
         unsigned char colour, unsigned char * multicolour, unsigned char multicount)
{
  int size;
  int chars;
  int lines;
  int column;
  int run;

  unsigned int ptr = 0;
  unsigned char * width = NULL;      /* width of each character.            */
  FILE * out;                        /* output                              */

  if(t_data != NULL)
    {
      fprintf(stderr, "%s: saving %d characters.\n", 
              PACKAGE, count);

      size = x*y*count*2;

      width = (unsigned char *) malloc(count);
      if(width == NULL)
        error("out of memory", "");

      /* determine the width of each character. */
      for(chars=0; chars<count-1; chars++)
        {
          width[chars]=0;
          for(lines=0; lines<y; lines++)         
            {
              ptr = (chars*x*y + x*lines) << 1;  
                    
              for(column=0; column<x;)
                {
                  for(run=0; run<t_data[ptr]; run++) 
                    {
                      if(t_data[ptr+1]!=bg)
                        width[chars] = column>width[chars] ? column : width[chars];
                      column++;
                    }
                  ptr+=2;
                }
            }
        }

      /* FIXME: this should be an option (and many other things too :) */
      if(((' ' - ascii)>=0) && (('M' - ascii) < count))
        width[' ' - ascii] = (width['M' - ascii] >> 1); 
      
      out = fopen(filename, "wb");
      if(out == NULL)
        error("cannot open file: ", filename);

      flags = flags | 2;    /* store width for each char (proportional font) */

      fputs("jtf2", out);   /* header tag thingy                             */
      fputc(x, out);        /* cell width                                    */
      fputc(y, out);        /* cell height                                   */
      fputc(count, out);    /* character count                               */
      fputc(flags, out);    /* bit 0 = mono, bit 1 = non-fixed-width file    */
      fputc(colour, out);   /* default colour for mono fonts                 */
      fputc(ascii, out);    /* 1st character in font corresponds to this   
                               ascii char (usually ' ' or 0)                 */

      if(flags & 2)
        fwrite(width, 1, count, out);  /* width for each char.               */
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


int  /* return 1 if current character is mono coloured.                       */
decode_char(unsigned char * data,     /* [x*y*2] array for RLE encoded char   */
            unsigned char * b,        /* pointer to top left corner of char   */
            unsigned int bwidth,      /* width of *b buffer                   */
            unsigned char width,      /* width of character                   */
            unsigned char height,     /* height of character                  */
            unsigned char font_fg,    /* colour of mono fonts                 */
            unsigned char font_bg,    /* colour of transparent runs           */
            unsigned char * m,        /* non transparent colours              */
            unsigned char mc)         /* amount of non transparent colours    */
{
  int mono = 1;
  unsigned int x;
  unsigned int y;
  unsigned char chr;
  unsigned char run;
  unsigned int ptr;

  for(y=0; y<height; y++)
    {
      chr = b[y*bwidth];
      run = 0;
      ptr = y*width*2;

      for(x=0; x<=width; x++)
        {
          /* continue run if byte is same as previous OR byte is bg and 
             previous byte is bg AND byte is not the last byte on the line. */
          if( ((b[y*bwidth+x]==chr) || (bg(chr, m, mc) && bg(b[y*bwidth+x], m, mc))) && (!(x==width)) )
            run++;
          else
            {
              data[ptr++] = run; 
              data[ptr++] = bg(chr, m, mc) ? font_bg : chr; 
              if((chr != font_fg) && (!bg(chr, m, mc))) mono = 0;
              run = 1;
              chr = b[y*bwidth+x]; 
            }
        }
    }
  
  return mono;
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
  unsigned char font_flags;          /* bit 0 => 1 = mono;                  */
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
      error("\nusage: fontripper <inputfile>.", "");
    }

  outfile = (char *) calloc(1, strlen(argv[1])+5);
          
  strcpy(outfile, argv[1]);

  dot = strrchr(outfile, '.');
  if(dot != NULL) strcpy(dot, "_.jtf"); /* jeeves typeface */

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

  fprintf(stderr, "%s: %d colours in multicolour font(s).\n", 
          PACKAGE, font_multicount);

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
                    font_flags = font_flags & 1 &
                      decode_char(t_data + x*y*2*char_count, 
                                  buffer + buf_char_start + buf_width + 1,
                                  buf_width, x, y, font_fg, 0, 
                                  font_multi, font_multicount);

                    char_count++;
                  }
                else
                  {
                    /* character dimensions are new, so this must be the first 
                       character in a new font, so store the previous font and 
                       setup decoding the next. */
                    savefont(t_data, outfile, ASCII, char_count, char_width, char_height, 
                             font_flags, 0, font_fg, font_multi, font_multicount);

                    if(font_count > MAX_FONTS)
                      error("too many fonts in file, please recompile " 
                            "fontripper.c and try again.\n","");
                      
                    *dot = file_naming_scheme[font_count];

                    char_width = x;
                    char_height = y;
                    font_flags = 1;
                    char_count = 0;
                    font_count++;

                    fprintf(stderr, "%s: decoding font %s with character size: "
                            "%dx%d,...\n", PACKAGE, outfile, x, y);

                    t_data = (unsigned char *) malloc(x*y*2*MAX_CHARS);

                    if(t_data == NULL)
                      error("out of memory", "");

                    font_flags = font_flags & 1 &
                      decode_char(t_data + x*y*2*char_count, 
                                  buffer + buf_char_start + buf_width + 1,
                                  buf_width, x, y, font_fg, 0, 
                                  font_multi, font_multicount);


                    char_count++;
                  }
              }
        }
    }

  savefont(t_data, outfile, ASCII, char_count, char_width, char_height, 
           font_flags, 0, font_fg, font_multi, font_multicount);

  free(buffer);

  return 0;
}
