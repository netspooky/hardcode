/*

  Adapted from my 8bit version of TinyPTC.
  (only released in Bliss-8bit.zip at Bizarre 2000).

  original TinyPTC by Gaffer, www.gaffer.org/tinyptc

*/

#ifndef __TINYPTC_CONVERT_H
#define __TINYPTC_CONVERT_H

/* integer types */
typedef unsigned __int32 int32;
typedef unsigned __int16 short16;
typedef unsigned __int8 char8;


/* converter configuration */
#define __PTC_CONVERTER_8_TO_32_RGB888
#define __PTC_CONVERTER_8_TO_24_RGB888
#define __PTC_CONVERTER_8_TO_16_RGB565
#define __PTC_CONVERTER_8_TO_16_RGB555

/* converter function type */
typedef void (*PTC_CONVERTER) (void *src,void *dst,int pixels, unsigned char * palette);

/* converter request */
PTC_CONVERTER ptc_request_converter(int bits, int32 r, int32 g, int32 b);

#endif
