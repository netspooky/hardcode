#include "changer.hpp"

/*class Changer
{
public:
	Changer(int states);
	~Changer();

	void setState(int statenumber, float start, float end);
	float getValue(float t);

private:
	int statecount;
	float *starts;
	float *ends;
};*/

Changer::Changer(int states)
{
	int i;
	statecount = states;
	starts = new float[statecount];
	ends = new float[statecount];

	for (i=0;i<statecount;i++)
	{
		starts[i] = 0;
		ends[i] = 0;
	}
}

Changer::~Changer()
{
	delete [] starts;
	delete [] ends;
}

void Changer::setState(int statenumber, float start, float end)
{
	if ((statenumber < 0) || (statenumber > statecount))
	{
//		MessageBox(NULL, "Changer::setState() cannot add state", "Error!", MB_ICONWARNING);
		return;
	}
	starts[statenumber] = start;
	ends[statenumber] = end;
}

float Changer::getValue(float t)
{
	int i=0;

	//etsitään kohta, missä ollaan menossa
	while(i<statecount)
	{
		if (i==(statecount-1)) //viimeinen kohta
		{
			return calcPosFloat(t, starts[statecount-1], ends[statecount-1]);
		}
		if ((t>=starts[i]) && (t<starts[i+1])) //löytyi
		{
			return calcPosFloat(t, starts[i], ends[i]);
		}
		else
			i++;
	}

	return t;
}

int Changer::getStateNumber(float t)
{
	int i=0;
	if (t < 0)
		return 0;
	if (t > 1.0f)
		return statecount-1;

	//etsitään kohta, missä ollaan menossa
	while(i<statecount-1)
	{
		if ((t>=starts[i]) && (t<starts[i+1])) //löytyi
		{
			return i;
		}
		else
			i++;
	}
	return statecount-1;
} 
