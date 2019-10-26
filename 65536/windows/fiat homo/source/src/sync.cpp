#include "sync.hpp"
#include "stuff.hpp"

Sync::Sync(unsigned int pstarttime, unsigned int pendtime)
{
	set(pstarttime, pendtime);

}

void Sync::set(unsigned int pstarttime, unsigned int pendtime)
{
	starttime = pstarttime;
	endtime = pendtime;
}

float Sync::getVal(unsigned int time)
{
	return calcPosInt(time, starttime, endtime);
}
