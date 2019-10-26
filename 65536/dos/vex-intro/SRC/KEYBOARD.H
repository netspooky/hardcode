#ifndef __KEYBOARD_H
#define __KEYBOARD_H

extern "C"
{
  void InitKey();
  void CloseKey();
  int GetKey();
  int KeyPressed();
}

#endif
