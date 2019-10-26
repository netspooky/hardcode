
#include "Transformation.h"

Transformation::Transformation() {
	transformationMatrices.reserve( 40 );
	delta = 0.0f;
}

Transformation::~Transformation() {
	transformationMatrices.clear();
}

void Transformation::addFrame( Matrix const& transform ) {
	transformationMatrices.push_back( transform );
}

Matrix Transformation::getActualMatrix( float time ) const {

	if( transformationMatrices.size() == 1 )

		return transformationMatrices[ 0 ];

	else {

		// lerp
		float	d = delta;

		if( d == 0.0f )
			d = 1.0f;

		int		framePrev	= static_cast<int>( time / d );

		if( framePrev > static_cast<int>( transformationMatrices.size() - 2 ) )
			framePrev = static_cast<int>( transformationMatrices.size() - 2 );

		float	t			= ( time / d ) - static_cast<float>( framePrev );
		float	tinv		= 1.0f - t;

		return ( transformationMatrices[ framePrev ] * tinv ) + ( transformationMatrices[ framePrev + 1 ] * t );
	}
}

Vector Transformation::getActualPosition( float time ) const {
	return getActualMatrix( time ).getCol( 3 );
}

void Transformation::setDelta( float _delta ) {
	delta = _delta;
}