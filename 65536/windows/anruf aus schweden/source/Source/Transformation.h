
#ifndef __TRANSFORMATION_H__
#define __TRANSFORMATION_H__

#include <vector>
#include "Matrix.h"

class Transformation {
	public:
		Transformation();
		virtual ~Transformation();

		virtual void	addFrame( Matrix const& transform );
		Matrix			getActualMatrix( float time ) const;
		Vector			getActualPosition( float time ) const;
		void			setDelta( float _delta );

	private:
		matrixList		transformationMatrices;		// w/o scale
		float			delta;
};

#endif