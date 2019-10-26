#ifndef _Light_h_
#define _Light_h_

#include "Object.h"

class Light : public Object
{
public:
  Light();
  void save(class Block *block);
};

#endif