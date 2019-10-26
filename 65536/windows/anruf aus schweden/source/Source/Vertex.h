
#ifndef __VERTEX_H__
#define __VERTEX_H__

#include <vector>
#include "Vector.h"

struct Vertex {

	Vertex( Vector const& _pos );

	Vector		pos;
	Vector		nrm;
};

typedef std::vector<Vertex>		vertexList;

#endif