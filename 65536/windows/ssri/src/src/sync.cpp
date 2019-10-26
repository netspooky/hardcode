/* sit ku laitat ‰‰net kuntoon niin muista muuttaa getrow synkki kuntoon */
#include "stuff.hpp"
#include "sync.hpp"

/*
	Sync(int pcount);
	~Sync();

	void add(int order, int row, int milliseconds);
	float getValue();

private:
	int count;

	int *ordertable;
	int *rowtable;
	int *timetable;
*/

Sync::Sync(int pcount)
{
	int i;
	count = pcount;
	offset = 0;
	active = false;
	
	ordertable = new int[count];
	rowtable   = new int[count];
	timetable  = new int[count];
	starttime  = new int[count];
	endtime    = new int[count];
	activated  = new bool[count];

	for (i=0;i<count;i++)
	{
		activated[i] = false;
		starttime[i] = 0;
		endtime[i] = 0;
		ordertable[i] = 0;
		rowtable[i] = 0;
		timetable[i] = 0;
	}
}
Sync::~Sync()
{
	if (count > 0)
	{
		delete [] ordertable;
		delete [] rowtable;
		delete [] timetable;
		delete [] starttime;
		delete [] endtime;
		delete [] activated;
	}
}
void Sync::add(int order, int row, int milliseconds)
{
	if (offset < count)
	{
		ordertable[offset] = order;
		rowtable[offset] = row;
		timetable[offset] = milliseconds;
	}
	offset++;
}

float Sync::getValue()
{
	int i;
	int currentrow = sound.getRow();
	int currentorder = sound.getOrder();
	int currenttime = (int)kello.getMilliseconds();

	//nollataan "t‰ll‰ framella aktiiviseksi"-muuttuja. 
	active = false;

	//k‰yd‰‰n l‰pi mahdolliset osumat

	for (i=0;i<count;i++)
	{
		//osuma
		if ((ordertable[i]==currentorder) && (rowtable[i]==currentrow))
		{
			//uusi osuma
			if (activated[i]==false)
			{
				active = true;
				activated[i] = true;
				starttime[i] = currenttime;
				endtime[i] = currenttime + timetable[i];
			}
		}
	}
	float value = 0.0f;
	for (i=0;i<count;i++)
	{
		//vanha/juuri lˆydetty osuma. Lasketaan interpolaatio
		if (activated[i]==true)
		{
			value += 1.0f-calcPosInt(currenttime, starttime[i], endtime[i]);
		}
	}
	if (value > 1.0f)
		value = 1.0f;
	return value;
}

bool Sync::getActivated()
{
	return active;
}
