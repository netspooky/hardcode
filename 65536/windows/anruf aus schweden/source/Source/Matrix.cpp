
#include "Matrix.h"

Matrix operator*( Matrix const& lhs, Matrix::value_type rhs ) {
	return Matrix( lhs ) *= rhs;	
}

Matrix operator*( Matrix::value_type lhs, Matrix const& rhs ) {
	return rhs * lhs;
}

Matrix operator*( Matrix const& lhs, Matrix const& rhs ) {
	return Matrix( lhs ) *= rhs;
}

Vector operator*( Matrix const& lhs, Vector const& rhs ) {
	Vector tmp;
	for( int j=0; j<4; j++ ) {
		Matrix::value_type sum = Matrix::value_type( 0 );
		for( int i=0; i<4; i++ )
			sum += lhs( j, i ) * rhs[i];
		tmp.v[j] = sum;
	}
	return tmp;
}

Matrix operator+( Matrix const& lhs, Matrix const& rhs ) {
	return Matrix( lhs ) += rhs;
}

Matrix operator-( Matrix const& lhs, Matrix const& rhs ) {
	return Matrix( lhs ) -= rhs;
}