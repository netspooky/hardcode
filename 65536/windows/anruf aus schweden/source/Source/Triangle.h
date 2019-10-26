
#ifndef __TRIANGLE_H__
#define __TRIANGLE_H__

#include <vector>
#include "Vector.h"

struct Triangle {
	typedef int value_type;

	Triangle();
	Triangle( int _a, int _b, int _c );

	void	calcNormal( Vector const& v1, Vector const& v2, Vector const& v3 );

	union {
		struct { value_type		a, b, c; };
		value_type				index[3];
	};

	Vector						normal;
};

typedef std::vector<Triangle>	triangleList;

#endif