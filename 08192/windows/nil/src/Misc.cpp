#include "stdinc.hpp"
#include "Misc.hpp"

float frand()
{
	return ((double)(rand()%512))/512.0;
}

float screenRatio= 1.0;