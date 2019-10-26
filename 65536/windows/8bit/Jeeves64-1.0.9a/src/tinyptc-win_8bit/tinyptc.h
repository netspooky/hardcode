//
// TinyPTC by Gaffer
// www.gaffer.org/tinyptc
//

#ifndef __TINYPTC_WINDOWS_H
#define __TINYPTC_WINDOWS_H


// integer types
typedef unsigned __int32 int32;
typedef unsigned __int16 short16;
typedef unsigned __int8 char8;

// tinyptc api
extern int ptc_open(char *title,int width,int height);
extern int ptc_update(void *buffer);
extern int ptc_setpal(unsigned char *palette);
extern void ptc_close();

// display target
#define __PTC_DDRAW__

// configuration
/*
#define __PTC_WINDOWED__
#define __PTC_CENTER_WINDOW__
#define __PTC_RESIZE_WINDOW__
#define __PTC_SYSTEM_MENU__
*/

#define __PTC_ICON__ "IDI_MAIN"

// converter configuration
#define __PTC_CONVERTER_8_TO_32_RGB888
#define __PTC_CONVERTER_8_TO_24_RGB888
#define __PTC_CONVERTER_8_TO_16_RGB565
#define __PTC_CONVERTER_8_TO_16_RGB555

// endian configuration
#define __PTC_LITTLE_ENDIAN__

// linker configuration
#define __PTC_WINMAIN_CRT__
//#define __PTC_MAIN_CRT__


#endif
