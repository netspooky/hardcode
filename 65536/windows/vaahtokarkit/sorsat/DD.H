/* DirectDraw */

#ifndef _DD_h_
#define _DD_h_

void ddInit(int w,int h);
void ddDeinit();
void ddLockScreen(int &width,int &height,int &bpl,int &bpp,void **scrptr);
void ddUnlockScreen();
void ddSync();

#endif