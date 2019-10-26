#ifndef _FONT_H_
#define _FONT_H_

#include "main.h"

typedef struct
{
	u8	 	w,h;
	f32		u0,v0;
	f32		u1,v1;
	u32		glTex;
	u32		*data;
} sCharImageBLAH;
typedef sCharImageBLAH sCharImage;

extern sCharImage *pCharImage;
extern f32		fontSizeXY;

int initFont(void);
void deinitFont(void);
void printFont(i8 *str,f32 spacing);
void bindChar(i8 ch);
		

#endif