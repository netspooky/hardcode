/*
    Header file for 32->n bit converters. Converts only one row per
    time.

    Created: 31.3.1999
    Updated: 12.4.2000

    -Marq
*/

#ifndef BLIT32_H
#define BLIT32_H

/*  The return values   */
#define BLIT_OK  0
#define BLIT_ERR 1

/*  Allowed conversion types    */
enum {BLIT_8_GRAY,BLIT_8_RASTER,BLIT_8_RASTER_DOUBLE,
      BLIT_15,BLIT_15_DOUBLE,
      BLIT_16,BLIT_16_DOUBLE,
      BLIT_24,BLIT_24_DOUBLE,
      BLIT_32,BLIT_32_DOUBLE,
      BLIT_32_PERVERT,BLIT_32_DOUBLE_PERVERT};

/*  Sets up the conversion engine */
int blit32_init(int type);

/*  Converts a line of the buffer   */
void blit32_blit(void *dest,void *data,int len,int rowlen,int extra);

/*  Converts a tweak buffer   */
void blit32_tweak(void *dest,void *data,int bytes,int dummy,int extra);

#endif
/*  EOS */
