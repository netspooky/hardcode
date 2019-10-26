#include <stdio.h>
#include "stuff.hpp"
#include "timer.hpp"

extern int originalaika;

void Timer::start()
{
	HRT = true;
	startTime = 0;

//	startTime = (float)timeGetTime();
	startTime = (float)SDL_GetTicks()/1000.0;

	addTime = 0.0f;
	frames = 0;
	lastTime = 0;
	currentTime = 0;
	fps = 0;
	time = 0;	
	update();
}

void Timer::update()
{
//	time = (float)timeGetTime();
	time = (float)SDL_GetTicks()/1000.0;
	(startTime == 0.0f) ? startTime = time : 0;
	time = time + addTime - startTime;

	if(time < 0.0f)
	{
		addTime = 0.0f;
		frames = 0;
		startTime = 0.0f;
		lastTime = 0;
		currentTime = 0;		
		fps = 0;		
		time = 0.0f;
	}
	else
	{
		deltaTime = time - lastTime;
		lastTime = time;

		frames++;
		fps = frames / (time*0.001f);
	}
}

void Timer::add(float ptime)
{
	addTime += ptime;

}
