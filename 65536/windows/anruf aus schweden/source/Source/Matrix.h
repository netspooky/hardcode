
#ifndef __MATRIX_H__
#define __MATRIX_H__

#include <vector>
#include "Vector.h"

struct Matrix {
		typedef float	value_type;

		Matrix() {}

		Matrix( Matrix const& rhs ) { 
			for( int j=0; j<4; j++ )
				for( int i=0; i<4; i++ )
					m[j][i] = rhs.m[j][i];
		}

		Matrix(	value_type m00, value_type m01, value_type m02, value_type m03,
				value_type m10, value_type m11, value_type m12, value_type m13,
				value_type m20, value_type m21, value_type m22, value_type m23,
				value_type m30, value_type m31, value_type m32, value_type m33 ) {

			m[0][0] = m00; m[0][1] = m01; m[0][2] = m02; m[0][3] = m03;
			m[1][0] = m10; m[1][1] = m11; m[1][2] = m12; m[1][3] = m13;
			m[2][0] = m20; m[2][1] = m21; m[2][2] = m22; m[2][3] = m23;
			m[3][0] = m30; m[3][1] = m31; m[3][2] = m32; m[3][3] = m33;

		}

		Matrix identity() {
			for( int j=0; j<4; j++ ) {
				for( int i=0; i<4; i++ )
					m[j][i] = value_type( 0 );
				m[j][j] = value_type( 1 );
			}

			return *this;
		}

		void transpose() {
			Matrix	tmp( *this );
			for( int j=0; j<4; j++ )
				for( int i=0; i<4; i++ )
					m[j][i] = tmp( i, j );
		}

		Matrix transposed() const {
			Matrix tmp( *this );
			tmp.transpose();
			return tmp;
		}

		void setRow( int rowNum, Vector const& v ) {
			m[ rowNum ][ 0 ] = v[ 0 ];
			m[ rowNum ][ 1 ] = v[ 1 ];
			m[ rowNum ][ 2 ] = v[ 2 ];
		}

		void setCol( int colNum, Vector const& v ) {
			m[ 0 ][ colNum ] = v[ 0 ];
			m[ 1 ][ colNum ] = v[ 1 ];
			m[ 2 ][ colNum ] = v[ 2 ];
		}

		Vector getRow( int rowNum ) const { 
			return Vector(	m[ rowNum ][ 0 ], 
							m[ rowNum ][ 1 ],
							m[ rowNum ][ 2 ],
							m[ rowNum ][ 3 ] );
		}

		Vector getCol( int colNum ) const {
			return Vector(	m[ 0 ][ colNum ], 
							m[ 1 ][ colNum ],
							m[ 2 ][ colNum ],
							m[ 3 ][ colNum ] );
		}

		Matrix const& operator*=( value_type rhs ) {
			for( int j=0; j<4; j++ )
				for( int i=0; i<4; i++ )
					m[j][i] *= rhs;
			return *this;
		}

		Matrix const& operator*=( Matrix const& rhs ) {
			Matrix tmp;
			for( int k=0; k<4; k++ ) {
				for( int j=0; j<4; j++ ) {			
					value_type	sum = value_type( 0 );	
					for( int i=0; i<4; i++ )
						sum += m[j][i] * rhs( i, k );
					tmp.m[j][k] = sum;
				}
			}
			*this = tmp;
			return *this;
		}

		Matrix const& operator+=( Matrix const& rhs ) {
			for( int j=0; j<4; j++ )
				for( int i=0; i<4; i++ )
					m[j][i] += rhs( j, i );
			return *this;
		}

		Matrix const& operator-=( Matrix const& rhs ) {
			for( int j=0; j<4; j++ )
				for( int i=0; i<4; i++ )
					m[j][i] -= rhs( j, i );
			return *this;
		}

		Matrix& operator=( Matrix const& rhs ) {
			if( this == &rhs )
				return *this;

			for( int j=0; j<4; j++ )
				for( int i=0; i<4; i++ )
					m[j][i] = rhs.m[j][i];

			return *this;
		}

		value_type& operator()( int row, int col ) {
			return m[row][col];
		}

		const value_type& operator()( int row, int col ) const {
			return m[row][col];
		}

		value_type	m[4][4];
};

Matrix operator*( Matrix const& lhs, Matrix::value_type rhs );
Matrix operator*( Matrix::value_type lhs, Matrix const& rhs );
Matrix operator*( Matrix const& lhs, Matrix const& rhs );
Vector operator*( Matrix const& lhs, Vector const& rhs );
Matrix operator+( Matrix const& lhs, Matrix const& rhs );
Matrix operator-( Matrix const& lhs, Matrix const& rhs );

typedef std::vector<Matrix> matrixList;

#endif