#ifndef TIMER_H
#define TIMER_H


#include <windows.h>
#include <winnt.h>

class Timer 
	{
public:
	Timer();
	~Timer();

	bool Fail();

	float Tick();

private:
	bool fail;
	LONGLONG freq;
	LONGLONG lastTime;
	};

#endif