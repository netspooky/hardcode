#ifndef _KeyFramer_h_
#define _KeyFramer_h_

#include "Ptrlist.h"

typedef struct
{
  float t,v;
} Key;

class KeyFramer
{
public:
  void init();
  Key *addKey(float t,float v);
  void addKeys(KeyFramer *kf);
  float getValue(float t);
  void sortKeys();

  float spline;
  Ptrlist keys;
};

#endif