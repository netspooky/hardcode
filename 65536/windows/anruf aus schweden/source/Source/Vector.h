
#ifndef __VECTOR_H__
#define __VECTOR_H__

#include <cmath>
#include <cassert>

struct Vector {

		typedef float value_type;

		Vector() { w = static_cast<value_type>( 1 ); };
		
		Vector( value_type _x, value_type _y, value_type _z ): x( _x ), y( _y ), z( _z ), w( static_cast<value_type>( 1 ) ) {};
		
		Vector( value_type _x, value_type _y, value_type _z, value_type _w ): x( _x ), y( _y ), z( _z ), w( _w ) {};	

		Vector( Vector const& rhs ) {
			v[0] = rhs.v[0];
			v[1] = rhs.v[1];
			v[2] = rhs.v[2];
			v[3] = rhs.v[3];
		}

		value_type dot( Vector const& rhs ) const {
			return v[0] * rhs[0] + v[1] * rhs[1] + v[2] * rhs[2];
		}

		value_type magnitudeSquared() const {
			return dot( *this );
		}

		value_type magnitude() const {
			return static_cast<value_type>( sqrt( magnitudeSquared() ) );
		}

		Vector cross( Vector const& rhs ) const;
		void normalize();
		void homogenize();

		Vector const& operator*=( value_type rhs ) {
			v[0] *= rhs;
			v[1] *= rhs;
			v[2] *= rhs;
			return *this;
		}

		Vector const& operator+=( Vector const& rhs ) {
			v[0] += rhs[0];
			v[1] += rhs[1];
			v[2] += rhs[2];
			return *this;
		}

		Vector const& operator-=( Vector const& rhs ) {
			v[0] -= rhs[0];
			v[1] -= rhs[1];
			v[2] -= rhs[2];
			return *this;
		}

		Vector&	operator=( Vector const& rhs ) {
			if( this == &rhs )
				return *this;

			v[0] = rhs.v[0];
			v[1] = rhs.v[1];
			v[2] = rhs.v[2];
			v[3] = rhs.v[3];

			return *this;
		}

		value_type&	operator[]( int pos ) {
			return v[ pos ];
		}

		value_type const& operator[]( int pos ) const {
			return v[ pos ];
		}

		union {
			struct { value_type		x, y, z, w; };
			value_type		v[4];
		};
};

Vector operator*( Vector const& lhs, Vector::value_type rhs );
Vector operator*( Vector::value_type lhs, Vector const& rhs );
Vector operator+( Vector const& lhs, Vector const& rhs );
Vector operator-( Vector const& lhs, Vector const& rhs );
bool operator==( Vector const& lhs, Vector const& rhs );
bool operator!=( Vector const& lhs, Vector const& rhs );

#endif