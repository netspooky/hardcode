/*

  Adapted from my 8bit version of TinyPTC.
  (only released in Bliss-8bit.zip at Bizarre 2000).

  original TinyPTC by Gaffer, www.gaffer.org/tinyptc
 
*/

#include "convert.h"

void ptc_convert_8_to_32_rgb888(void *src, void *dst, int pixels, unsigned char * palette)
{
    unsigned char * p = (unsigned char *) src;
    int32 *q = (int32*) dst;
    while (pixels--)
    {
        *(q++) = ( palette[(*p) * 3 + 0] << 0x10 |
                   palette[(*p) * 3 + 1] << 0x08 |
                   palette[(*p) * 3 + 2]);
        p++;
    }
}

void ptc_convert_8_to_24_rgb888(void *src,void *dst,int pixels, unsigned char * palette)
{
    unsigned char * p = (unsigned char *) src;
    char8 *q = (char8*) dst;
    while (pixels--)
    {
        #ifdef __PTC_LITTLE_ENDIAN__
        *(q+0) = palette[(*p) * 3 + 0];
        *(q+1) = palette[(*p) * 3 + 1];
        *(q+2) = palette[(*p) * 3 + 2];
        #else
        *(q+2) = palette[(*p) * 3 + 0];
        *(q+1) = palette[(*p) * 3 + 1];
        *(q+0) = palette[(*p) * 3 + 2];
        #endif
        p++;
        q+=3;
    }
}


void ptc_convert_8_to_16_rgb565(void *src,void *dst,int pixels, unsigned char * palette)
{
    unsigned char * p = (unsigned char *) src;
    short16 *q = (short16*) dst;
    while (pixels--)
    {
        short16 r = (short16) ( (palette[(*p) * 3 + 0] & 0xF8) << 0x08 );
        short16 g = (short16) ( (palette[(*p) * 3 + 1] & 0xFC) << 0x03 );
        short16 b = (short16) ( (palette[(*p) * 3 + 2] & 0xF8) >> 0x03 );
        *q = r | g | b;
        p++;
        q++;
    }
}


void ptc_convert_8_to_16_rgb555(void *src,void *dst,int pixels, unsigned char * palette)
{
    unsigned char * p = (unsigned char *) src;
    short16 *q = (short16*) dst;
    while (pixels--)
    {
        short16 r = (short16) ( (palette[(*p) * 3 + 0] & 0xF8) << 0x07 );
        short16 g = (short16) ( (palette[(*p) * 3 + 1] & 0xF8) << 0x02 );
        short16 b = (short16) ( (palette[(*p) * 3 + 2] & 0xF8) >> 0x03 );
        *q = r | g | b;
        p++;
        q++;
    }
}


PTC_CONVERTER ptc_request_converter(int bits,int32 r,int32 g,int32 b)
{
    /* 8bit PAL -> 32bit RGB888 */
    #ifdef __PTC_CONVERTER_8_TO_32_RGB888
    if (bits==32 && r==0x00FF0000 && g==0x0000FF00 && b==0x000000FF) return &ptc_convert_8_to_32_rgb888;
    #endif

    /* 8bit PAL -> 24bit RGB888 */
    #ifdef __PTC_CONVERTER_8_TO_24_RGB888
    if (bits==24 && r==0x00FF0000 && g==0x0000FF00 && b==0x000000FF) return &ptc_convert_8_to_24_rgb888;
    #endif

    /* 8bit PAL -> 16bit RGB565 */
    #ifdef __PTC_CONVERTER_8_TO_16_RGB565
    if (bits==16 && r==0xF800 && g==0x07E0 && b==0x001F) return &ptc_convert_8_to_16_rgb565;
    #endif

    /* 8bit PAL -> 16bit RGB555 */
    #ifdef __PTC_CONVERTER_8_TO_16_RGB555
    if (bits==16 && r==0x7C00 && g==0x03E0 && b==0x001F) return &ptc_convert_8_to_16_rgb555;
    #endif

    /* failure */
    return 0;
}
