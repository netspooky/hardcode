#ifndef _Y16I_ALGORITHM_
#define _Y16I_ALGORITHM_

////////////////////////////////////////////////////////////////////////////////
// Bezier Curves class
class cBezier{
public:
	cVec3f anchors[4];																// anchors
	int divs;																		// divide lenght
	int current;																	// current number
	int flg;
	vector < cVec3f > orbit;
	int fillOrbit;
	float decAlpha;

public:
	cBezier();
	~cBezier();
	void init(int divides);
	void calculate(cVec3f *a);
	void incCurrent(void);
	void decCurrent(void);
	void update(void);
	void slide(void);
	void pushAnchor(cVec3f newPos);
	int statusCurrent(void);
	void draw(void);
	
private:
	cVec3f pointTimes(float c, cVec3f p);
	cVec3f bernstein(float u, cVec3f *p);
};

#endif _Y16I_ALGORITHM_
