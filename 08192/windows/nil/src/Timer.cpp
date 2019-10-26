#include "Timer.h"

#include <windows.h>
#include <winnt.h>

#include <winbase.h>

#include "misc.h"


Timer::Timer()
	: fail( false ), freq( 0 ), lastTime( 0 ) 
	{
		{
		LARGE_INTEGER temp;

		if( QueryPerformanceFrequency( &temp ) == 0 )
			fail= true;
		else
			{
			freq= temp.QuadPart;

			QueryPerformanceCounter( &temp );

			lastTime= temp.QuadPart;
			}
		}
	}



Timer::~Timer()
	{
	}



bool Timer::Fail()
	{
	return fail;
	}



float Timer::Tick()
	{
	LARGE_INTEGER temp;
	LONGLONG currTime;
	float returnValue;

	QueryPerformanceCounter( &temp );
	currTime= temp.QuadPart;

	returnValue= float((double)(currTime-lastTime)/(double)freq);
	
	lastTime= currTime;

	return returnValue;
	}
