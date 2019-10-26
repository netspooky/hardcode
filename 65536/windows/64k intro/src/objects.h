#include "basicObjects.h"
////////////////////////////////////////////////////////////////////////////////
// knots class | call type A, B, C
class cKnots: public cKnotB{//, public cKnotB, public cKnotC{
public:
	cColor4f c;

public:
	cKnots();
	virtual ~cKnots();
	void init(cVec3f p, float rad, int div);
	void draw(void);
};

////////////////////////////////////////////////////////////////////////////////
// motion like a thunder
class cThunder{
public:
	vector < cVertices > vers;
	cSize2f s;
	cVec3f p;
	
	
	// keeping vector each rects
	vector < cVec3f > vect0;
	vector < cVec3f > vect1;
	
	float baseAngle;
	cColor4f clr;
	float decAlpha;
	
public:
	cThunder();
	~cThunder();
	void init(int num, cVec3f pos, cSize2f size);
	void pushVector(int num, cVec3f d0, cVec3f d1);								// apply vector
	void shake(cVec3f pos);
	void draw(void);
};

////////////////////////////////////////////////////////////////////////////////
//
class cLightnings{
public:
	// about main objects
	vector < cThunder > thun;													// thunder main object
	cVec3f thunPos;																// position
	cSize2f thunSiz;															// size
	
	vector < vector < cVec3f > > hist;											// locus
	vector < int > histCnt;														// count up a number of histry
	int histMax;																//
	
	// load
	cBezier bezi;
	int beziDivs;
	
	// flag for shuttle
	int shuttle;
	
	int type;
	enum{
		typeA=0, typeB, typeC, typeD
	};
	
public:
	cLightnings();
	~cLightnings();
	void init(int numbers, int length, cVec3f position, cSize2f size, int spd);
	void move(void);
	int getPosition(cVec3f* pos);
	void draw(void);
	
private:
	void selectAnchor(void);
};

