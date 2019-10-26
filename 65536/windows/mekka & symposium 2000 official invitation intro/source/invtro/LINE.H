#ifndef __line_h
#define __line_h

void lineclip8 (int x1, int y1, int x2, int y2, long * dest, long *pal);
#pragma aux lineclip8 "*" parm[eax][ebx][ecx][edx][edi][esi] modify [];

void RectRopOr (int x1, int y1, int x2, int y2, int value);
#pragma aux RectRopOr "*" parm[eax][ebx][ecx][edx][esi] modify exact [];

void RectRopFill (int x1, int y1, int x2, int y2, int value);
#pragma aux RectRopFill "*" parm[eax][ebx][ecx][edx][esi] modify exact [];


#endif
