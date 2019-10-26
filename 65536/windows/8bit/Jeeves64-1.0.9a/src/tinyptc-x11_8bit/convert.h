/*
   TinyPTC by Gaffer
   www.gaffer.org/tinyptc
*/

#ifndef __TINYPTC_CONVERT_H
#define __TINYPTC_CONVERT_H

#define __PTC_CONVERTER_8_TO_32_RGB888
#define __PTC_CONVERTER_8_TO_24_RGB888
#define __PTC_CONVERTER_8_TO_16_RGB565
#define __PTC_CONVERTER_8_TO_16_RGB555

/* include files */
#include "tinyptc.h"

/* converter function type */
typedef void (*PTC_CONVERTER) (void *src,void *dst,int pixels, unsigned char * palette);

/* converter request */
PTC_CONVERTER ptc_request_converter(int bits,int32 r,int32 g,int32 b);


#endif
