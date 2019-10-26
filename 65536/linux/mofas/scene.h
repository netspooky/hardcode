#ifndef _TSCENE_H__
#define _TSCENE_H__

#include <stdio.h>
#include <GL/gl.h>
#include <GL/glu.h>


class TScene {
public:
  long startTime, endTime;

  virtual int setup(int reason) = 0;
  virtual int run(long time) = 0;
 // virtual void _free() = 0;
};


#endif
