#ifndef _GDI_h_
#define _GDI_h_

void gdiInit(int w,int h);
void gdiDeinit();
void gdiLockScreen(int &width,int &height,int &bpl,int &bpp,void **scrptr);
void gdiUnlockScreen();
void gdiSync();

#endif