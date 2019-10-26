
#include "Projection.h"
#include "numbers.h"

Projection::Projection( Matrix const& _projection ) : projection( _projection ) {
}

Projection::Projection( float fov, float aspect, float near, float far ) {

	setPerspectiveProjection( fov, aspect, near, far );
}

void Projection::setPerspectiveProjection( float fov, float aspect, float near, float far ) {

	float	y		= near * tan( fov * PI  / 360.0f );
	float	x		= y * aspect;

	float	top		= y;
	float	bottom	= -y;
	float	left	= -x;
	float	right	= x;

	/*
		perspective projection stöcker stylee.. \o/

		2*near/(right-left)				0				(right+left)/(right-left)				0
		0						2*near/(top-bottom)		(top+bottom)/(top-bottom)				0
		0								0				-(far+near)/(far-near)		-2*far*near/(far-near)
		0								0						-1								0

	*/

	projection = Matrix(	2.0f * near / ( right - left ), 0.0f, ( right + left ) / ( right - left ), 0.0f,
							0.0f, 2.0f * near / ( top - bottom ), ( top + bottom ) / ( top - bottom ), 0.0f,
							0.0f, 0.0f, -( far + near ) / ( far - near ), -2.0f * far * near / ( far - near ),
							0.0f, 0.0f, -1.0f, 0.0f
						);

}

Matrix const& Projection::getProjection() const {
	return projection;
}