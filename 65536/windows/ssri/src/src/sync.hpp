#ifndef _SYNC_HPP_
#define _SYNC_HPP_

class Sync
{
public:
	Sync(int pcount);
	~Sync();

	void add(int order, int row, int milliseconds);
	float getValue();
	bool getActivated(); //täytyy kutsua getValue() jälkeen, vaikka getValue():ta ei käytettäisi ollenkaan.

private:
	bool active;

	int count;
	int offset;

	int *ordertable;
	int *rowtable;
	int *timetable;
	int *starttime;
	int *endtime;

	bool *activated;
};



#endif
