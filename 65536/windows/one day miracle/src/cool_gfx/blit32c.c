/*
    Implementation of the 32->N bit converters. Pure C.

    Created: 6.9.1999
    Updated: 12.4.2000

    -Marq
*/

#include "blit32.h"
#include <string.h>

unsigned char blit32_array[65536];

/*  Declarations of the external converters */
void blit32_8_gray(void *dest,unsigned *data,int len,int rowlen,int extra)
{
    unsigned n,temp;

    unsigned char *de=dest,*so=(unsigned char *)data;

    for(n=0;n<len;n++)
    {
	temp=so[n*4]+so[n*4+1]+so[n*4+2];
	de[n]=temp>>3;
    }
}
void blit32_8_raster(void *dest,unsigned *data,int len,int rowlen,int extra)
{
/*  Nothing here, unusable anyway */
}
void blit32_8_raster_double(void *dest,unsigned *data,int len,int rowlen,int extra)
{
    unsigned char *de=dest,te;

    unsigned n;

    for(n=0;n<len;n++)
    {
	te=data[n]>>18&0x3f;
	de[n*2]=de[n*2+rowlen+1]=te;
	te=blit32_array[data[n]&0xffff];
	de[n*2+1]=de[n*2+rowlen]=te;
    }
}
void blit32_15(void *dest,unsigned *data,int len,int rowlen,int extra)
{
    short *de=dest;

    unsigned n,*so=data;

    for(n=0;n<len;n++)
        de[n]=(so[n]>>9&0x7c00)+(so[n]>>6&0x3e0)+(so[n]>>3&0x1f);
}
void blit32_15_double(void *dest,unsigned *data,int len,int rowlen,int extra)
{
    unsigned n,pixels,*so=data,*de=dest;

    for(n=0;n<len;n++)
    {
        pixels=(so[n]>>9&0x7c00)+(so[n]>>6&0x3e0)+(so[n]>>3&0x1f);
    	pixels+=pixels<<16;
	de[n]=pixels;
    }
}
void blit32_16(void *dest,unsigned *data,int len,int rowlen,int extra)
{
    unsigned short *de=dest;

    unsigned n,*so=data;

    for(n=0;n<len;n++)
        de[n]=(so[n]>>8&0xf800)+(so[n]>>5&0x7e0)+(so[n]>>3&0x1f);
}
void blit32_16_double(void *dest,unsigned *data,int len,int rowlen,int extra)
{
    unsigned n,pixels,*so=data,*de=dest;

    for(n=0;n<len;n++)
    {
        pixels=(so[n]>>8&0xf800)+(so[n]>>5&0x7e0)+(so[n]>>3&0x1f);
	pixels+=pixels<<16;
	de[n]=pixels;
    }
}
void blit32_24(void *dest,unsigned *data,int len,int rowlen,int extra)
{
}
void blit32_24_double(void *dest,unsigned *data,int len,int rowlen,int extra)
{
}
void blit32_32(void *dest,unsigned *data,int len,int rowlen,int extra)
{
    memcpy(dest,data,len*sizeof(unsigned));
}
void blit32_32_double(void *dest,unsigned *data,int len,int rowlen,int extra)
{
    int n;

    unsigned *de=dest;

    for(n=0;n<len;n++)
	de[n*2]=de[n*2+1]=data[n];
}

void blit32_32_pervert(void *dest,unsigned *data,int len,int rowlen,int extra)
{
    unsigned *de=dest,r,b,tmp;

    int n;

    for(n=0;n<len;n++)
    {
        tmp=data[n];
        r=tmp>>16u;
        b=(tmp&0xff)<<16u;
        tmp&=0xff00;
        de[n]=b+tmp+r;
    }
}

void blit32_32_double_pervert(void *dest,unsigned *data,int len,int rowlen,
                              int extra)
{
    unsigned *de=dest,r,b,tmp;

    int n;

    for(n=0;n<len;n++)
    {
        tmp=data[n];
        r=tmp>>16u;
        b=(tmp&0xff)<<16u;
        tmp&=0xff00;
        de[n*2]=de[n*2+1]=b+tmp+r;
    }
}

/*  EOS */
