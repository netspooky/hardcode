//
// TinyPTC by Gaffer
// www.gaffer.org/tinyptc
//

#ifndef __TINYPTC_WINDOWS_H
#define __TINYPTC_WINDOWS_H


// integer types
typedef unsigned int int32;
typedef unsigned short int short16;
typedef unsigned char char8;

// tinyptc api
extern int ptc_open(char *title,int width,int height);
extern int ptc_update(void *buffer);
extern void ptc_close();

// display target
//#define __PTC_VFW__

#ifdef WINDOWED
#define __PTC_GDI__
#define __PTC_WINDOWED__
#define __PTC_ICON__ "IDI_MAIN"
#else
#define __PTC_DDRAW__
#endif

// configuration
//#define __PTC_CENTER_WINDOW__
//#define __PTC_RESIZE_WINDOW__
//#define __PTC_SYSTEM_MENU__
#define __PTC_ALLOW_CLOSE__

#ifndef IGNORE_ESCKEY
#define __PTC_CLOSE_ON_ESCAPE__ //required for key tracking
#endif

#ifdef KEYBOARD_CLOSE
#define __PTC_CLOSE_ON_ANY_KEY__
#endif

#ifdef MOUSE_CLOSE
#define __PTC_CLOSE_ON_MOUSE__
#endif

#ifdef KEYBOARD
#define __RETURN_KEYPRESSED__
#define __RETURN_KEYLEFT__
#endif

#ifdef KEYBOARD_SIMPLE
#define __RETURN_KEYPRESSED__
#endif

#ifdef KEYBOARD_SYSKEY
#define __RETURN_SYSKEY__ //requires key tracking
#endif

#ifdef MESSAGEBOX
#define __USE_MESSAGE_BOX__
#endif

#ifdef SETTITLE
#define __SET_TITLE__
#endif

#ifdef REMAINIDLE
#define __REMAIN_IDLE__
#endif

#ifdef MOUSE
#define __RETURN_MOUSE__
#endif

#ifdef MOUSE_CAPTURE
#define __MOUSE_CAPTURE__
#endif

//#define __PTC_DISABLE_SCREENSAVER__

// converter configuration
#define __PTC_CONVERTER_32_TO_32_RGB888
#define __PTC_CONVERTER_32_TO_32_BGR888
#define __PTC_CONVERTER_32_TO_24_RGB888
#define __PTC_CONVERTER_32_TO_24_BGR888
#define __PTC_CONVERTER_32_TO_16_RGB565
#define __PTC_CONVERTER_32_TO_16_BGR565
#define __PTC_CONVERTER_32_TO_16_RGB555
#define __PTC_CONVERTER_32_TO_16_BGR555

// endian configuration
#define __PTC_LITTLE_ENDIAN__

// optimization
//#define __PTC_MMX__
//#define __PTC_MEMCPY__

// linker configuration
//#define __PTC_WINMAIN_CRT__
#define __PTC_MAIN_CRT__


#endif
