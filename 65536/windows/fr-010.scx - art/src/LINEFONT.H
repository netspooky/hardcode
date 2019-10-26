#ifndef _LINEFONT_H_
#define _LINEFONT_H_
#include <windows.h>
#include "3dmath.h"


class LineChar
{
public:
	int curvecount;
	Vector* Curves;
	int ppcurve[512];
	unsigned int w;
};

class LineFont
{
	
public:
	LineChar LC[256];
	LineFont(char* FN,HDC hdc);
	~LineFont(void);
};
#endif //_LINEFONT_H_