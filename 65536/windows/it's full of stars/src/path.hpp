#ifndef _PATH_HPP_
#define _PATH_HPP_

#include "stuff.hpp"

class Path
{
public:
	Path();
	~Path();
	
	void destroy();
	void addpoint(Vector &point);

	void draw();
	Vector getValue(float t);

private:
	
	int count;
	Lista *points;

};



#endif 
