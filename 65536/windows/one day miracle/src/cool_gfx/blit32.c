/*
    Implementation of the 32->N bit converters. Calls the assembly
    functions.

    Created: 31.3.1999
    Updated: 12.4.2000

    -Marq
*/

#include "blit32.h"

/*  Declarations of the external converters */
extern void blit32_8_gray(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_8_raster(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_8_raster_double(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_15(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_15_double(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_16(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_16_double(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_24(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_24_double(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_32(void *dest,unsigned *data,int len,int rowlen,int extra);
extern void blit32_32_double(void *dest,unsigned *data,int len,int rowlen,int extra);
//extern void blit32_32_pervert(void *dest,unsigned *data,int len,int rowlen,int extra);
//extern void blit32_32_double_pervert(void *dest,unsigned *data,int len,int rowlen,int extra);

/*  Function pointer to the actual blit function   */
static void (*blit32)(void *dest,unsigned *data,int len,int rowlen,int extra);

/*  Sets up the conversion array for 8-bit color    */
void blit32_prepare(void);

extern unsigned char blit32_array[];

int blit32_init(int type)
{
    switch(type)
    {
        case BLIT_8_GRAY  : blit32=blit32_8_gray;
                            break;
        case BLIT_8_RASTER: blit32=blit32_8_raster;
                            blit32_prepare();
                            break;  
        case BLIT_8_RASTER_DOUBLE: blit32=blit32_8_raster_double;
                            blit32_prepare();
                            break;
        case BLIT_15      : blit32=blit32_15;
                            break;
        case BLIT_15_DOUBLE: blit32=blit32_15_double;
                            break;
        case BLIT_16      : blit32=blit32_16;
                            break;
        case BLIT_16_DOUBLE: blit32=blit32_16_double;
                            break;
        case BLIT_24      : blit32=blit32_24;
                            break;
        case BLIT_24_DOUBLE: blit32=blit32_24_double;
                            break;
        case BLIT_32      : blit32=blit32_32;
                            break;
        case BLIT_32_DOUBLE: blit32=blit32_32_double;
                            break;
/*        case BLIT_32_PERVERT       : blit32=blit32_32_pervert;
                                     break;
        case BLIT_32_DOUBLE_PERVERT: blit32=blit32_32_double_pervert;
                                     break;*/
        default: return(BLIT_ERR);
    }
    return(BLIT_OK);
}

void blit32_prepare(void)
{
    int     n;

    for(n=0;n<65536;n++)
        blit32_array[n]=128+((n>>1)&0x70)+(n>>12);
}

void blit32_blit(void *dest,void *data,int len,int rowlen,int extra)
{
    blit32(dest,data,len,rowlen,extra);
}

/*  EOS */
