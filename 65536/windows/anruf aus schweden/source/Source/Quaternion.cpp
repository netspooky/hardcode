
#include "Quaternion.h"
#include "numbers.h"

Quaternion operator*( Quaternion const& lhs, Quaternion const& rhs ) {
	return Quaternion( lhs ) *= rhs;
}

Quaternion operator+( Quaternion const& lhs, Quaternion const& rhs ) {
	return Quaternion( lhs ) += rhs;
}

bool operator==( Quaternion const& lhs, Quaternion const& rhs ) {

	for( int i=0; i<4; i++ )
		if( fabs( lhs[i] - rhs[i] ) > static_cast<Quaternion::value_type>( EPSILON ) )
			return false;

	return true;
}