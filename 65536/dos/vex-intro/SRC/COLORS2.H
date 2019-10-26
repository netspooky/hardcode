#ifndef __COLORS2_H
#define __COLORS2_H

extern "C" void GetColors(unsigned char(*)[3], unsigned char o, short n);
extern "C" void SetColors(const unsigned char(*)[3], unsigned char o, short n);
extern "C" void SetColorsBlack();
extern "C" void SetColor(unsigned char c, unsigned char r, unsigned char g, unsigned char b);
extern "C" void MakeFadeStep(unsigned char(*)[3], const unsigned char(*)[3], const unsigned char(*)[3], short n, unsigned char s);
extern "C" void InterpolCols(unsigned char(*)[3], short n, unsigned char crs,  unsigned char cgs, unsigned char cbs, unsigned char crd, unsigned char cgd, unsigned char cbd);

#endif
