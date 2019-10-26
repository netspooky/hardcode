#ifndef __TIMERUSE_H
#define __TIMERUSE_H

extern "C"
{
  void tuInstall();
  void tuClose();
  void tuDisable();
  void tuEnable();
  void tuUpdate();
  long tuGetTimer();
  void tuResetTimer();
}

#endif
