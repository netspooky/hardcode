
#include "Vector.h"
#include "numbers.h"

Vector Vector::cross( Vector const& rhs ) const {
	Vector tmp;

	tmp.v[0] = v[1] * rhs[2] - v[2] * rhs[1];
	tmp.v[1] = -( v[0] * rhs[2] - v[2] * rhs[0] ); 
	tmp.v[2] = v[0] * rhs[1] - v[1] * rhs[0];
	tmp.v[3] = 1.0;

	return tmp;
}

void Vector::normalize() {
	value_type	tmp = magnitude();

	if( tmp == static_cast<value_type>( 0 ) )				// aaah :/
		tmp = static_cast<value_type>( 0.00001 );
	else
		tmp = static_cast<value_type>( 1 ) / tmp;

	v[0] *= tmp;
	v[1] *= tmp;
	v[2] *= tmp;
}

void Vector::homogenize() {
	assert( v[3] != static_cast<value_type>( 0 ) );
	value_type tmp = static_cast<value_type>( 1 ) / v[3];
	v[0] *= tmp;
	v[1] *= tmp;
	v[2] *= tmp;
	v[3] = static_cast<value_type>( 1 );
}

////////////////

Vector operator*( Vector const& lhs, Vector::value_type rhs ) {
	return Vector( lhs ) *= rhs;
}

Vector operator*( Vector::value_type lhs, Vector const& rhs ) {
	return rhs * lhs;
}

Vector operator+( Vector const& lhs, Vector const& rhs ) {
	return Vector( lhs ) += rhs;
}

Vector operator-( Vector const& lhs, Vector const& rhs ) {
	return Vector( lhs ) -= rhs;
}

bool operator==( Vector const& lhs, Vector const& rhs ) {
	for( int i=0; i<4; i++ )
		if( static_cast<Vector::value_type>( fabs( lhs[i] - rhs[i] ) ) > static_cast<Vector::value_type>( EPSILON ) )
			return false;
	return true;
}

bool operator!=( Vector const& lhs, Vector const& rhs ) {
	return !( lhs == rhs );
}