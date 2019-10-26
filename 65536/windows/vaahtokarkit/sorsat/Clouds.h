#ifndef _Clouds_h_
#define _Clouds_h_

#include "Bitmap.h"
#include "Camera.h"

class Clouds
{
public:
  void draw(Bitmap &dest);

  Camera camera;
};

#endif