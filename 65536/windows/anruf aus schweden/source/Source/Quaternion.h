
#ifndef __QUATERNION_H__
#define __QUATERNION_H__

#include "Matrix.h"

class Quaternion {
	public:
		typedef float value_type;

		Quaternion() {}

		Quaternion( Quaternion const& rhs ) {
			x = rhs.x; y = rhs.y; z = rhs.z; w = rhs.w;
		}

		Quaternion( value_type _x, value_type _y, value_type _z, value_type _w ) {
			x = _x; y = _y; z = _z; w = _w;
		}

		Quaternion( Vector const& axis, value_type const angle ) {

			// q = [cos(angle/2), sin(angle/2)*axis]

			w = cos( angle / static_cast<value_type>( 2.0 ) );
			
			value_type sin_half_angle = sin( angle / static_cast<value_type>( 2.0 ) );
			x = axis.x * sin_half_angle;
			y = axis.y * sin_half_angle;
			z = axis.z * sin_half_angle;
		}

		Quaternion( Matrix const& m ) {

			// take upper left 3x3 part
			value_type diagonal = m(0, 0) + m(1, 1) + m(2, 2);

			if( diagonal > static_cast<value_type>( 0.0 ) ) {

				value_type s = sqrt( diagonal + static_cast<value_type>( 1.0 ) );

				w = s / static_cast<value_type>( 2.0 );

				s = static_cast<value_type>( 0.5 ) / s;

				x = ( m(1, 2) - m(2, 1) ) * s;
				y = ( m(2, 0) - m(0, 2) ) * s;
				z = ( m(0, 1) - m(1, 0) ) * s;

			} else {

				// diagonal < 0

				int i = 0;
				if( m(1, 1) > m(0, 0) )
					i = 1;
				if( m(2, 2) > m(i, i) )
					i = 2;

				int	next[3] = { 1, 2, 0 };
				int j		= next[i];
				int k		= next[j];

				value_type s = sqrt( ( m(i, i) - ( m(j, j) + m(k, k) ) ) + 1.0f );

				value_type	q[4];
				q[i] = s * static_cast<value_type>( 0.5 );

				if( s != static_cast<value_type>( 0.0 ) )
					s = static_cast<value_type>( 0.5 ) / s;

				q[j] = ( m(j, k) - m(k, j) ) * s;
				q[k] = ( m(j, k) - m(k, j) ) * s;
				q[3] = ( m(j, k) - m(k, j) ) * s;

				x = q[0];
				y = q[1];
				z = q[2];
				w = q[3];
			}
		}

		void conjugate() {
			
			// q* = [w, -v]

			x = -x;
			y = -y;
			z = -z;
		}

		Quaternion conjugated() const {
			
			// q* = [w, -v]

			Quaternion q( *this );
			q.conjugate();
			return q;
		}

		value_type magnitude() const {

			return w * w + x * x + y * y + z * z;
		}

		void inverse() {

			// q^-1 = q* / Norm( q )

			assert( magnitude() != 0 );
			value_type inorm = 1 / magnitude();
			conjugate();
			x *= inorm;
			y *= inorm;
			z *= inorm;
		}

		Matrix toMatrix() {

			// coefficients
			value_type x2 = x + x;
			value_type y2 = y + y; 
			value_type z2 = z + z;

			value_type xx = x * x2;
			value_type xy = x * y2;
			value_type xz = x * z2;
			value_type yy = y * y2;
			value_type yz = y * z2;
			value_type zz = z * z2;
			value_type wx = w * x2;
			value_type wy = w * y2;
			value_type wz = w * z2;

			Matrix m;

			m(0, 0) = static_cast<value_type>( 1.0 ) - ( yy + zz );
			m(1, 0) = xy - wz;
			m(2, 0) = xz + wy;
			m(3, 0) = static_cast<value_type>( 0.0 );

			m(0, 1) = xy + wz;
			m(1, 1) = static_cast<value_type>( 1.0 ) - ( xx + zz );
			m(2, 1) = yz - wx;
			m(3, 1) = static_cast<value_type>( 0.0 );

			m(0, 2) = xz - wy;
			m(1, 2) = yz + wx;
			m(2, 2) = static_cast<value_type>( 1.0 ) - ( xx + yy );
			m(3, 2) = static_cast<value_type>( 0.0 );

			m(0, 3) = static_cast<value_type>( 0.0 );
			m(1, 3) = static_cast<value_type>( 0.0 );
			m(2, 3) = static_cast<value_type>( 0.0 );
			m(3, 3) = static_cast<value_type>( 1.0 );	

			return m;
		}

		Quaternion const& operator+=( Quaternion const& rhs ) {

			// q + q' = [ w + w', v + v']

			w += rhs.w; x += rhs.x; y += rhs.y; z += rhs.z;
			return *this;
		}

		Quaternion const& operator*=( Quaternion const& rhs ) {

			// q * q' = [ ww' - v.v', vxv' + w.v' + w'.v ]

			Quaternion q( *this );

			value_type a = ( w + x ) * ( rhs.w + rhs.x );
			value_type b = ( z - y ) * ( rhs.y - rhs.z );
			value_type c = ( w - x ) * ( rhs.y + rhs.z );
			value_type d = ( y + z ) * ( rhs.w - rhs.x );
			value_type e = ( x + z ) * ( rhs.x + rhs.y );
			value_type f = ( x - z ) * ( rhs.x - rhs.y );
			value_type g = ( w + y ) * ( rhs.w - rhs.z );
			value_type h = ( w - y ) * ( rhs.w + rhs.z );

			w = b + ( -e - f + g + h ) * static_cast<value_type>( 0.5 );
			x = a - (  e + f + g + h ) * static_cast<value_type>( 0.5 );
			y = c + (  e - f + g - h ) * static_cast<value_type>( 0.5 );
			z = d + (  e - f - g + h ) * static_cast<value_type>( 0.5 );

			/*
			w = ( q.w * rhs.w ) - ( q.x * rhs.x + q.y * rhs.y + q.z * rhs.z );
			x = ( q.y * rhs.z - q.z * rhs.y ) + ( q.w * rhs.x + rhs.w * q.x );
			y = -( q.x * rhs.z - q.z * rhs.x ) + ( q.w * rhs.y + rhs.w * q.y );
			z = ( q.x * rhs.y - q.y * rhs.x ) + ( q.w * rhs.z + rhs.w * q.z );
			*/

			return *this;
		}

		Quaternion& operator=( Quaternion const& rhs ) {
			if( this == &rhs )
				return *this;

			x = rhs.x;
			y = rhs.y;
			z = rhs.z;
			w = rhs.w;

			return *this;
		}

		value_type& operator[]( int pos ) {
			return v[ pos ];
		}

		value_type const& operator[]( int pos ) const {
			return v[ pos ];
		}

		union {
			struct {	value_type	x, y, z, w; };
						value_type	v[4];
		};
};

Quaternion operator*( Quaternion const& lhs, Quaternion const& rhs );
Quaternion operator+( Quaternion const& lhs, Quaternion const& rhs );
bool operator==( Quaternion const& lhs, Quaternion const& rhs );

#endif