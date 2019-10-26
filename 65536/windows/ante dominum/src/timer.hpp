#ifndef _TIMER_HPP_
#define _TIMER_HPP_

//#include <windows.h>

class Timer
{
public:
	Timer() {};
	~Timer() {};

	void start();
	void update();

	void add(float time);
	float getSeconds() { return time; };
	float getMilliseconds() { return time*1000; }

private:
	bool HRT;
	float addTime;
	Uint64 ticksPerSec;
	float startTime;
	unsigned int frames;
	float time, deltaTime;
	float lastTime, currentTime, fps;

};

#endif
