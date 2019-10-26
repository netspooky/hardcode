#ifndef _Camera_h_
#define _Camera_h_

#include "Object.h"

class Camera : public Object
{
public:
  Camera();
  void createCameraMatrix();
  void save(class Block *block);

  class Sphere *target;
  Matrix cameramatrix;
};

#endif