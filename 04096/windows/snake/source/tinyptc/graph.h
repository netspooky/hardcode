// this header is designed to be used by tinyptc

#define createscreen ptc_open
#define screen ptc_update
#define closescreen ptc_close
#include "tinyptc\tinyptc.h"
#include "tinyptc\convert.c"
#include "tinyptc\convert.h"
#ifndef WINDOWED
#include "tinyptc\ddraw.c"
#else
#include "tinyptc\gdi.c"
#endif

// MOUSE

#define M_LEFTDOWN		513 /*left  button clicked*/
#define M_LEFTUP		514 /*left  button released*/
#define M_LEFTDOUBLE		515 /*left  button double clicked (unused int tinyptc)*/
#define M_RIGHTDOWN		516 /*right button clicked*/
#define M_RIGHTUP		517 /*right button released*/
#define M_RIGHTDOUBLE		518 /*right button double clicked (unused int tinyptc)*/
#define M_MIDDOWN		519 /*mid   button clicked*/
#define M_MIDUP			520 /*mid   button released*/
#define M_MIDDOUBLE		521 /*mid   button double clicked (unused int tinyptc)*/
#define M_WHEELUP		522 /*wheel rolled upwards*/
#define M_WHEELDOWN		523 /*wheel rolled downwords*/

// KEYBOARD

#define K_BACKSPACE		  8 /*backspace key, one above the enter*/
#define K_TAB			  9 /*tab key*/
#define K_ENTER			 13 /*enter key*/
#define K_SHIFT			 16 /*right and left shifts*/
#define K_CTRL			 17 /*right ctrl and left ctrl*/
#define K_ALT			 18 /*alt key (alt is a system key) */
#define K_PAUSE			 19 /*pause and break key*/
#define K_CAPSLOCK		 20 /*capitals lock*/
#define K_ESCAPE		 27 /*escape key*/
#define K_SPACE			 32 /*the big key*/
#define K_PAGEUP		 33 /*page up key*/
#define K_PAGEDOWN		 34 /*page down key*/
#define K_END			 35 /*end key*/
#define K_HOME			 36 /*home key*/
#define K_LEFT			 37 /*left arrow*/
#define K_UP			 38 /*up arrow*/
#define K_RIGHT			 39 /*right arrow*/
#define K_DOWN			 40 /*down arrow*/
#define K_INSERT		 45 /*insert key*/
#define K_DELETE		 46 /*delete key*/
#define K_0			 48 /*character pad 0, equal sign and bracket close*/
#define K_1			 49 /*character pad 1 and exclamation mark*/
#define K_2			 50 /*character pad 2 and quotation mark*/
#define K_3			 51 /*character pad 3, power sign and sharp sign*/
#define K_4			 52 /*character pad 4, plus sign and dollar sign*/
#define K_5			 53 /*character pad 5 and modula sign*/
#define K_6			 54 /*character pad 6 and 'and' sign*/
#define K_7			 55 /*character pad 7, slash and open brackets*/
#define K_8			 56 /*character pad 8 and open normal and hard paranthesis*/
#define K_9			 57 /*character pad 9 and close normal and hard paranthesis*/
#define K_A			 65 /*character a*/
#define K_B			 66 /*character b*/
#define K_C			 67 /*character c*/
#define K_D			 68 /*character d*/
#define K_E			 69 /*character e and euro sign*/
#define K_F			 70 /*character f*/
#define K_G			 71 /*character g*/
#define K_H			 72 /*character h*/
#define K_I			 73 /*character i*/
#define K_J			 74 /*character j*/
#define K_K			 75 /*character k*/
#define K_L			 76 /*character l*/
#define K_M			 77 /*character m*/
#define K_N			 78 /*character n*/
#define K_O			 79 /*character o*/
#define K_P			 80 /*character p*/
#define K_Q			 81 /*character q and @ sign*/
#define K_R			 82 /*character r*/
#define K_S			 83 /*character s*/
#define K_T			 84 /*character t*/
#define K_U			 85 /*character u*/
#define K_V			 86 /*character v*/
#define K_W			 87 /*character w*/
#define K_X			 88 /*character x*/
#define K_Y			 89 /*character y*/
#define K_Z			 90 /*character z*/
#define K_WINDOWS		 92 /*left and right windows keys*/
#define K_LIST			 93 /*open list key*/
#define K_NUMPAD0		 96 /*numerical pad 0 and numerical pad insert key*/
#define K_NUMPAD1		 97 /*numerical pad 1 and numerical pad end key*/
#define K_NUMPAD2		 98 /*numerical pad 2 and numerical pad down key*/
#define K_NUMPAD3		 99 /*numerical pad 3 and numerical pad page down key*/
#define K_NUMPAD4		100 /*numerical pad 4 and numerical pad left key*/
#define K_NUMPAD5		101 /*numerical pad 5*/
#define K_NUMPAD6		102 /*numerical pad 6 and numerical pad right key*/
#define K_NUMPAD7		103 /*numerical pad 7 and numerical pad home key*/
#define K_NUMPAD8		104 /*numerical pad 8 and numerical pad up key*/
#define K_NUMPAD9		105 /*numerical pad 9 and numerical pad pageup key*/
#define K_NUMPADASTERISK	106 /*numerical pad asterix*/
#define K_NUMPADPLUS		107 /*numerical pad plus sign*/
#define K_NUMPADMINUS		109 /*numerical pad minus sign*/
#define K_NUMPADDOT		110 /*numerical pad dot and numerical pad delete key*/
#define K_NUMPADSLASH		111 /*numerical pad slash key*/
#define K_F1			112 /*f1 the holy help key*/
#define K_F2			113 /*f2 the rename key*/
#define K_F3			114 /*f3 the search key*/
#define K_F4			115 /*f4 the address key*/
#define K_F5			116 /*f5 the refresh key*/
#define K_F6			117 /*f6 key*/
#define K_F7			118 /*f7 key*/
#define K_F8			119 /*f8 key*/
#define K_F9			120 /*f9 key*/
#define K_F10			121 /*f10 key (f10 is a system key) */
#define K_F11			122 /*f11 key*/
#define K_F12			123 /*f12 key*/
#define K_NUMLOCK		144 /*numerical pad lock*/
#define K_SCROLLOCK		145 /*text scroll lock*/
#define K_TS			186 /*turkish alphabet character þ key*/
#define K_ASTERISK		187 /*asterisk, question mark and backslash key*/
#define K_TO			188 /*turkish alphabet character ö key*/
#define K_MINUS			189 /*minus sign and underscore key*/
#define K_TC			190 /*turkish alphabet character ç key*/
#define K_DOT			191 /*dot and colon key*/
#define K_DOUBLEQUOTATION	192 /*double quotation mark and é key*/
#define K_TG			219 /*turkish alphabet character ð key*/
#define K_COMMA			220 /*comma, semicolon and tear key*/
#define K_TU			221 /*turkish alphabet character ü key and tilde*/
#define K_TI			222 /*turkish alphabet character ý key*/
#define K_ARROW			226 /*greater than, less than and vertical line key*/

/* note: altgr generates two messages of key input (ctrl+alt) */
