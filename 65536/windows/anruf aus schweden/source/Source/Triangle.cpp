
#include "Triangle.h"

Triangle::Triangle() {
}

Triangle::Triangle( int _a, int _b, int _c ) : a( _a ), b( _b ), c( _c ), normal( Vector( 0.0f, 0.0f, 0.0f )) {
}

void Triangle::calcNormal( Vector const& v1, Vector const& v2, Vector const& v3 ) {
	normal = ( v2 - v1 ).cross( v3 - v1 );
	normal.normalize();
}