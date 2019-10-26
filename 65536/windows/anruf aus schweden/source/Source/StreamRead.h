
#ifndef __STREAM_READ_H__
#define __STREAM_READ_H__

//#include <istream>
#include "Quaternion.h"

class StreamRead {
	public:
		StreamRead( unsigned char* b );

		template<typename T>
		T				read() {
			T	t;
			memcpy( &t, buffer, sizeof( t ) );
			buffer += sizeof( t );
			return t;
		}

		Vector			readVector();
		Matrix			readMatrix();
		Quaternion		readQuaternion();

	private:
		unsigned char*	buffer;
};

#endif