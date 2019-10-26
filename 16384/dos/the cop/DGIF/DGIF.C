/* ------------------------------- DGIF.C -------------------------------- */


/******************************************************************************
 VGLGIF.C

 VGLGif( char* file, char far* buffer, char far* palette,
         int* width, int* height );

 Routine to load a 256 color .GIF file into a memory buffer.  *Only* 256
 color images are supported here!  Sorry, no routines to SAVE .GIFs...
 Memory required is allocated on the fly and no checks are in place.  If you
 don't have enough memory it will likely crash.  It's easy to add the checks
 yourself, just put one after each call to malloc().  If you supply a pointer
 to a palette, it will be filled in.  If you supply a pointer to a width
 and/or height variable, it will be filled in as well.

 This code is hereby placed in the public domain.  Have fun!

 Mark Morley
 morley@camosun.bc.ca
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <alloc.h>
#include <string.h>
#include <dos.h>

#define MAX_CODES     4096

static FILE*          fp;
static int            curr_size;
static int            clear;
static int            ending;
static int            newcodes;
static int            top_slot;
static int            slot;
static int            navail_bytes = 0;
static int            nbits_left = 0;
static unsigned char  b1;
static unsigned char  byte_buff[257];
static unsigned char* pbytes;
static unsigned char* stack;
static unsigned char* suffix;
static unsigned int*  prefix;

static unsigned long code_mask[13] =
{
   0L,
   0x0001L, 0x0003L,
   0x0007L, 0x000FL,
   0x001FL, 0x003FL,
   0x007FL, 0x00FFL,
   0x01FFL, 0x03FFL,
   0x07FFL, 0x0FFFL
};

static int pascal
get_next_code(void)
{
   register int  i;
   static unsigned long ret;

   if( ! nbits_left )
   {
      if( navail_bytes <= 0 )
      {
	 pbytes = byte_buff;
         navail_bytes = getc( fp );
	 if( navail_bytes )
	    for( i = 0; i < navail_bytes; ++i )
               *(byte_buff + i) = getc( fp );
      }
      b1 = *pbytes++;
      nbits_left = 8;
      --navail_bytes;
   }
   ret = b1 >> (8 - nbits_left);
   while( curr_size > nbits_left )
   {
      if( navail_bytes <= 0 )
      {
	 pbytes = byte_buff;
         navail_bytes = getc( fp );
	 if( navail_bytes )
	    for( i = 0; i < navail_bytes; ++i )
               *(byte_buff + i) = getc( fp );
      }
      b1 = *pbytes++;
      ret |= b1 << nbits_left;
      nbits_left += 8;
      --navail_bytes;
   }
   nbits_left -= curr_size;

   return( (int) (ret & *(code_mask + curr_size)) );
}

int VGLGif( char* file, char far* buffer, char far* pal, int* width, int* height )
{
   unsigned char* sp;
   int            code, fc, oc;
   int            i;
   unsigned char  size;
   int            c;
   unsigned char  buf[1028];
   unsigned char  red;
   unsigned char  grn;
   unsigned char  blu;

   fp = fopen( file, "rb" );
   if( !fp )
      return( 0 );
   fread( buf, 1, 6, fp );
   if( strncmp( (char *)buf, "GIF", 3 ) )
   {
      fclose( fp );
      return( 0 );
   }
   fread( buf, 1, 7, fp );
   for( i = 0; i < 768; )
   {
      red = getc( fp );
      grn = getc( fp );
      blu = getc( fp );

      if( pal )
      {
         pal[i++] = red >> 2;
         pal[i++] = grn >> 2;
         pal[i++] = blu >> 2;
      }
      else
         i += 3;
   }
   fread( buf, 1, 5, fp );
   i = getw( fp );
   if( width )
      *width = i;
   i = getw( fp );
   if( height )
      *height = i;
   if( !buffer ) {
      fclose(fp);
      return( 1 );
   }
   fread( buf, 1, 1, fp );
   size = getc( fp );
   if( size < 2 || 9 < size )
   {
      fclose( fp );
      return( 0 );
   }

   stack = (unsigned char*) malloc( MAX_CODES + 1 );
   suffix = (unsigned char*) malloc( MAX_CODES + 1 );
   prefix = (unsigned int*) malloc( sizeof(int) * (MAX_CODES + 1) );

   curr_size = size + 1;
   top_slot = 1 << curr_size;
   clear = 1 << size;
   ending = clear + 1;
   slot = newcodes = ending + 1;
   navail_bytes = nbits_left = 0;
   oc = fc = 0;
   sp = stack;
   while( (c = get_next_code()) != ending )
   {
      if( c == clear )
      {
	 curr_size = size + 1;
	 slot = newcodes;
	 top_slot = 1 << curr_size;
	 while( (c = get_next_code()) == clear );
	 if( c == ending )
	    break;
	 if( c >= slot )
	    c = 0;
	 oc = fc = c;
         *buffer++ = c;
      }
      else
      {
	 code = c;
	 if( code >= slot )
	 {
	    code = oc;
	    *sp++ = fc;
	 }
	 while( code >= newcodes )
	 {
	    *sp++ = *(suffix + code);
	    code = *(prefix + code);
	 }
	 *sp++ = code;
	 if( slot < top_slot )
	 {
	    *(suffix + slot) = fc = code;
	    *(prefix + slot++) = oc;
	    oc = c;
	 }
	 if( slot >= top_slot && curr_size < 12 )
	 {
	    top_slot <<= 1;
	    ++curr_size;
	 }
	 while( sp > stack )
	 {
	    --sp;
            *buffer++ = *sp;
	 }
      }
   }
   free( stack );
   free( suffix );
   free( prefix );
   fclose( fp );
   return( 1 );
}


// =======================================================

void Error(const char *txt) {
   printf("ERROR: %s\n", txt);
   exit(1);
}

void Usage(void) {
   puts("DGIF, GIF dumper bye Jare using Mark Morley's fab VGL.\n"
        "   Usage: DGIF file[.GIF]");
   exit(1);
}


void DumpFile(const char* fn, char huge* buf, unsigned long l) {
   FILE *f;

   printf("Escribiendo %ld bytes desde %lX al fichero %s\n", l, (long)buf, fn);
   if ((f = fopen(fn, "wb")) == NULL)
      Error("Creando fichero.");
   while (l > 16384L) {
      if (fwrite(buf, 16384, 1, f) < 1)
          Error("Escribiendo en fichero");
      buf = buf + 16384;
      l -= 16384;
      printf("Quedan %ld bytes en %lX.\n", l, (long)buf);
   }
   if (fwrite(buf, (unsigned)l, 1, f) < 1)
      Error("Completando fichero");
   fclose(f);
}




char fname[200];
char pal[768];


void main(int argc, char *argv[]) {
   char *p, *g;
   int   w = -1, h = -1;
   int   ok;

   char far* im;


   if (argc < 2)
      Usage();
   p = strrchr(argv[1], '.');
   g = strrchr(argv[1], '\\');
   if (p && (!g || g < p))
      *p = '\0';
   sprintf(fname, "%s.GIF", argv[1]);

   printf("Leyendo %s...\n", fname);
   ok = VGLGif(fname, NULL, NULL, &w, &h);
   if (!ok)
      Error("Fichero no encontrado");
   printf("X = %d, Y = %d\n", w, h);

   printf("Memory left: %ld\n", farcoreleft());
   if ( (im = farmalloc((unsigned)w*h)) == NULL)
      Error("Out of memory for image.");
   printf("Memory left: %ld\n", farcoreleft());
   ok = VGLGif(fname, im, pal, NULL, NULL);
   if (!ok)
      Error("Reloading gif.");

   asm {
      PUSH SI
      MOV AX,0x13
      INT 0x10
      MOV SI,OFFSET pal
      MOV CX,768
      MOV DX,0x3c8
      XOR AL,AL
      OUT DX,AL
      INC DX
      REP OUTSB
   }

   movedata(FP_SEG(im), FP_OFF(im), 0xA000, 0, 64000);

   asm {
      MOV AH,0
      INT 0x16
      MOV AX,3
      INT 0x10
   }


   printf("Memory left: %ld\n", farcoreleft());
   sprintf(fname, "%s.pal", argv[1]);
   DumpFile(fname, pal, 768);
   sprintf(fname, "%s.pix", argv[1]);
   DumpFile(fname, im, (unsigned)w*h);
   exit(0);
}

/* ---------------------------- End of DGIF.C ---------------------------- */
