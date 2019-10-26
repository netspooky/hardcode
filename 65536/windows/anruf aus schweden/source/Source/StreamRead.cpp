
#include "StreamRead.h"

StreamRead::StreamRead( unsigned char* b ) : buffer( b ) {
}

Vector StreamRead::readVector() {
	float x = read<float>();
	float y = read<float>();
	float z = read<float>();
	return Vector( x, y, z );
}

Matrix StreamRead::readMatrix() {
	Matrix m;
	m.identity();

	for( int i=0; i<3; i++ )
		for( int j=0; j<4; j++ )
			m.m[i][j] = read<float>();

	return m;
}

Quaternion StreamRead::readQuaternion() {
	float x = read<float>();
	float y = read<float>();
	float z = read<float>();
	float w = read<float>();
	return Quaternion( x, y, z, w );
}