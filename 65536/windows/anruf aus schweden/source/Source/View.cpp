
#include "View.h"

View::View( int _left, int _right, int _bottom, int _top ) : left( _left ), right( _right ), bottom( _bottom ), top( _top ) {
}

float View::getAspect() const {
	return ( static_cast<float>( right - left ) / static_cast<float>( top - bottom ) );
}