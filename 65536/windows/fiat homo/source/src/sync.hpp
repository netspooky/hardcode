#ifndef _SYNC_HPP_
#define _SYNC_HPP_

class Sync
{
public:
	Sync(unsigned int pstarttime, unsigned int pendtime);
	void set(unsigned int pstarttime, unsigned int pendtime);
	
	float getVal(unsigned int time);

private:
	unsigned int starttime;
	unsigned int endtime;
};



#endif
