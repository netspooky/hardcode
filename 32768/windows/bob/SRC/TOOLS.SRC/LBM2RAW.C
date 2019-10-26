/*
  lbm2raw.c - a quick hack to convert my Deluxe Paint IIe files to raw.
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

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE !FALSE
#endif


char * PACKAGE = "lbm2raw.c";
char * VERSION = "0.0.1";
char * COPYRIGHT = "Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>\n"            \
"This program comes with NO WARRANTY, to the extent permitted by law.\n"      \
"You may redistribute copies of this program\n"                               \
"under the terms of the GNU General Public License.\n"                        \
"For more information about these matters,\n"                                 \
"see the file named COPYING.\n";
char * HELP = "syntax: lbm2raw [options]\n"                                   \
"where options is one or more of the following:\n"                            \
"\n"                                                                          \
"\t--help      \t\tthis.\n"                                                   \
"\t--raw       \t\toutput raw image data.\n"                                  \
"\t--pal, --old\t\toutput raw palette data in oldschool format.\n"            \
"\t--act, --new\t\toutput raw palette data in newschool format.\n"            \
"\n"                                                                          \
"NOTE: colours in oldschool palette files (.pal) range from 0x00 to 0x3F,\n"  \
"      colours in newschool palette files (.act) range from 0x00 to 0xFF.\n"  \
"\n";


/* ===[ help ]==============================================================
  
   > help on stdout.
   
   ========================================================================= */
void
help(void)
{
  printf(HELP);

  exit(1);
}

/* ===[ error ]=============================================================
  
   > print an error message on stderr and exit.

   .        msg                 error message
   
   ========================================================================= */
void
error(char * msg)
{
  fprintf(stderr, "%s: %s\n", PACKAGE, msg);

  exit(2);
}

/* ===[ warning ]===========================================================
  
   > print a warning warning on stderr.

   .        msg                 warning message
   
   ========================================================================= */
void
warning(char * msg)
{
  fprintf(stderr, "%s: %s\n", PACKAGE, msg);
}



/* iff/ilbm chunk header */
union iff_chunk
{
  unsigned char buffer[8];
  struct 
  {
    char ID[4];             /* type of data in this chunk */
    unsigned char size[4];  /* size of data in this chunk */
  } chunk;
};


/* iff/ilbm bitmap header */
union iff_BMHD
{
  unsigned char buffer[20];
  struct
  {                                /* byte offset */
    unsigned char width[2];                 /*  0 */
    unsigned char height[2];                /*  2 */
    char x[2];                              /*  4 */
    char y[2];                              /*  6 */
    unsigned char nPlanes;                  /*  8 */
    unsigned char Masking;                  /*  9 */
    unsigned char RLE;                      /* 10 */
    unsigned char pad1;                     /* 11 */
    unsigned char trColor[2];               /* 12 */
    unsigned char xAspect;                  /* 14 */
    unsigned char yAspect;                  /* 15 */
    char pagewidth[2];                      /* 16 */
    char pageheight[2];                     /* 18 */
  } bmhd;                                   /* 20 */
};


/* ===[ iff_chunk_eq ]======================================================
  
   > compares the iff CHUNK id with a given string.
   
   .        chunk               4 chars.
   :        id                  4 chars.

   ========================================================================= */
int
iff_chunk_eq(char* chunk, char* id)
{
  return (chunk[0]==id[0]) 
    && (chunk[1]==id[1])
    && (chunk[2]==id[2])
    && (chunk[3]==id[3]);
}

/* ===[ get_xxbit_big_endian_int ]==========================================
  
   > convert a 16bit or 32bit big-endian value to an int.
   
   .        word                2 unsigned chars (16bit big-endian int)
   .        dword               4 unsigned chars (32bit big-endian int)

   ========================================================================= */
int 
get_16bit_big_endian_int(unsigned char * word)
{ 
  return (word[0] << 0x08)
    | (word[1] << 0x00);
}

int 
get_32bit_big_endian_int(unsigned char * dword)
{ 
  return (dword[0] << 0x18)
    | (dword[1] << 0x10)
    | (dword[2] << 0x08)
    | (dword[3] << 0x00); 
}

/* ===[ decode_lbm ]========================================================
  
   > decode lbm and output raw image data or palette data.
   
   .        in          input FILE.
   :        out         output FILE.
   :.       pal         0 = raw image data, 
                        1 = raw palette data in oldschool format,
                        2 = raw palette data in newschool format.

   ========================================================================= */
int
decode_lbm(FILE * out, FILE * in, int pal)
{
  int rle;
  int x, y, bpp;
  int size;
  int pad;
  int count;
  int read;
  int i;

  int bodycount;
  char bodyrun;
  unsigned char bodyblok;

  unsigned char * temp;

  union iff_chunk chunk;
  union iff_BMHD bmhd;

  int BMHD = FALSE;     /* has the header       been found and decoded? */
  int CMAP = (pal==0);  /* has the palette      been found and decoded? */
  int BODY = (pal!=0);  /* has the picture data been found and decoded? */

  count = 0;

  while(!(CMAP && BODY))
    {
      if((read = fread(chunk.buffer, 1, sizeof(chunk.buffer), in))
         < sizeof(chunk.buffer))
        error("cannot read iff chunk header.");

      count += read;

      size = get_32bit_big_endian_int(chunk.chunk.size);
      pad = size % 2; 

      /* ===================================================================
         FORM CHUNK
         =================================================================== */
      if(iff_chunk_eq(chunk.chunk.ID, "FORM"))
        {
          if((read = fread(chunk.buffer, 1, 4, in)) < 4)
            error("cannot read iff chunk header.");

          count += read;

          /* if this form d
             FORM chunk (I suppose this skips to EOF for most files). */
          if((!iff_chunk_eq(chunk.chunk.ID, "PBM "))
             && (!iff_chunk_eq(chunk.chunk.ID, "ILBM")))
            for(i = 0; i < size+pad-4; i++)
              fgetc(in);
        }

      /* ===================================================================
         BMHD CHUNK
         =================================================================== */
      else if(iff_chunk_eq(chunk.chunk.ID, "BMHD"))
        {
          /* BMHD chunk found, init image info */
          if((read = fread(bmhd.buffer, 1, sizeof(bmhd.buffer), in))
             < sizeof(bmhd.buffer))
            error("cannot read iff/bmhd chunk header.");

          count += read;

          bpp = 8; /* I don't support anything else :) */
          x = get_16bit_big_endian_int(bmhd.bmhd.width);
          y = get_16bit_big_endian_int(bmhd.bmhd.height);

          rle = (bmhd.bmhd.RLE==1);

          fprintf(stderr, "%s: found BMHD (%dx%d:%d, nPlanes: %d, Masking: %d, rle: %d).\n", 
                  PACKAGE, x, y, bpp, bmhd.bmhd.nPlanes, bmhd.bmhd.Masking, rle);

          if(bmhd.bmhd.nPlanes!=8)
            error("fileformat not supported (wrong number of bitplanes).\n");

          if(bmhd.bmhd.Masking==1)
            error("fileformat not supported (please deactivate stencil before saving).\n");

          BMHD = TRUE;
        }

      /* ===================================================================
         CMAP CHUNK
         =================================================================== */
      else if(iff_chunk_eq(chunk.chunk.ID, "CMAP"))
        {
          /* CMAP chunk found, init Palette */
          if(BMHD && (pal!=0)) 
            {
              fprintf(stderr, "%s: decoding CMAP.\n", PACKAGE);

              if((temp = (unsigned char *) malloc(size)) == NULL)
                error("cannot allocate memory.");
              
              if((read = fread(temp, 1, size, in)) < size)
                error("cannot read palette data.");
              
              if(pal==1)
                for(i = 0; i < size; temp[i++] >>= 2);

              if((read = fwrite(temp, 1, size, out)) < size)
                error("cannot write palette data.");

              free(temp);

              count += read;
              
              CMAP = TRUE;

              if(pad)
                {
                  for(i = 0; i < pad; i++)
                    fgetc(in);

                  count+=pad;
                }
            }
          else
            {
              /* ignore CMAP if it is not wanted (no --pal in argv)
                 and ignore any CMAPs without preceding BMHD chunks */

              for(i = 0; i < size+pad; i++)
                fgetc(in);

              count += i;
            }
        }

      /* ===================================================================
         BODY CHUNK
         =================================================================== */
      else if(iff_chunk_eq(chunk.chunk.ID, "BODY"))
        {
          /* BODY chunk found, load data */
          if(BMHD && (pal==0))
            {
              fprintf(stderr, "%s: decoding BODY.\n", PACKAGE);

              if((temp = (unsigned char *) malloc(x*y)) == NULL)
                error("cannot allocate memory.");

              if(rle)
                {
                  bodycount = 0;

                  while(bodycount < (x*y))
                    {
                      bodyrun = fgetc(in);
                      count++;
                      
                      if(bodyrun!=-128)
                        {
                          if(bodyrun>=0)
                            {
                              if((read = fread(temp + bodycount, 1, bodyrun+1, in)) < bodyrun+1)
                                error("cannot read image data.");

                              count+=(bodyrun+1);
                              bodycount+=(bodyrun+1);
                            }
                          else /* (bodyrun<0) && (bodyrun != -128) */
                            {
                              bodyblok = fgetc(in);
                              count++;
                          
                              memset(temp + bodycount, bodyblok, (1-bodyrun));
                              bodycount += (1-bodyrun);
                            }
                        }
											/*
                      else
                        {
                          warning("shouldn't come here, file might be corrupt."); 
                        }
											*/
                    }
                }
              else /* !rle */
                {
                  warning("raw BODY chunk is completely untested! :).\n");

                  if((read = fread(temp, 1, (x*y), in)) < (x*y))
                    error("cannot read image data.");
              
                  count+=(x*y);
                }

              if((read = fwrite(temp, 1, (x*y), out)) < (x*y))
                error("cannot write image data.");

              BODY = TRUE;

              free(temp);
          
              if(pad)
                {
                  for(i = 0; i < pad; i++)
                    fgetc(in);

                  count+=pad;
                }
            }
          else
            {
              for(i = 0; i < size+pad; i++)
                fgetc(in);

              count += i;
            }
        }

      /* ===================================================================
         unknown CHUNK
         =================================================================== */
      else /* chunk.ID not recognized. */
        {
          /*
          fprintf(stderr, "%s: found unknow chunk: %c%c%c%c.\n", PACKAGE, 
                  chunk.chunk.ID[0], chunk.chunk.ID[1], 
                  chunk.chunk.ID[2], chunk.chunk.ID[3]);
          */

          for(i = 0; i < size+pad; i++)
            fgetc(in);

          count += i;
        }

    }

  return 0;
}



/* ===[ main ]==============================================================
  
   > reads from stdin, writes to stdout, nothing else supported.
   
   ========================================================================= */
int
main(int argc, char ** argv)
{
  int i;
  char * arg;
  int quiet = 0;
  int hlp = 0;
  int pal = 0;

  if(argc > 1)
    for(i = 1; i < argc; i++)
      {
        arg = argv[i];

        if(strcmp(arg, "--quiet") == 0) quiet = 1;
        if(strcmp(arg, "--raw")   == 0) pal = 0;
        if(strcmp(arg, "--old")   == 0) pal = 1;
        if(strcmp(arg, "--pal")   == 0) pal = 1;
        if(strcmp(arg, "--act")   == 0) pal = 2;
        if(strcmp(arg, "--new")   == 0) pal = 2;
        if(strcmp(arg, "--help")  == 0) hlp = 1;
      }
  
  if(!quiet)
    fprintf(stderr, "%s - %s\n%s\n", PACKAGE, VERSION, COPYRIGHT);

  if(hlp)
    help();
    
  decode_lbm(stdout, stdin, pal); 

  return 0;
}

