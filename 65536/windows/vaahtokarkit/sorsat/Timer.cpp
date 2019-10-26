#include "Timer.h"

#ifdef WIN32

#include <windows.h>
#define TIMERCOUNTER (timeGetTime())
#define TIMERCOUNTERSPEED (1000)

#else

#include <time.h>
#define TIMERCOUNTERi (clock())
#define TIMERCOUNTERSPEEDi (CLOCKS_PER_SEC)

#endif

Timer::Timer(int t)
{
  start(t);
}

void Timer::start(int t)
{
  tps=t;
  multijuttu=(float)(t)/(float)(TIMERCOUNTERSPEED);
  start_time=TIMERCOUNTER;
}

int Timer::getCounter()
{
  return (int)((float)(TIMERCOUNTER-start_time)*multijuttu);
}

float Timer::getCounterf()
{
  return (float)(TIMERCOUNTER-start_time)*multijuttu;
}
/*
int Timer::getSpeed()
{
  return tps;
}
*/
void Timer::setCounter(int c)
{
  start_time=TIMERCOUNTER-c*multijuttu;
}