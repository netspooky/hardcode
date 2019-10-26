#ifndef __VGA13X2_H
#define __VGA13X2_H

extern "C"
{
  void vgaInit();
  void vgaClose();
  void vgaViewPage(short);
  void vgaWaitRetrace();
  void vgaFillScreen(short, unsigned char);
}

#endif
