
#ifndef __PROJECTION_H__
#define __PROJECTION_H__

#include <vector>
#include "Matrix.h"

class Projection {
	public:
		Projection( Matrix const& _projection );
		Projection( float fov, float aspect, float near, float far );

		void			setPerspectiveProjection( float fov, float aspect, float near, float far );
		Matrix const&	getProjection() const;

	private:
		Matrix			projection;
};

typedef std::vector<Projection>	projectionList;

#endif