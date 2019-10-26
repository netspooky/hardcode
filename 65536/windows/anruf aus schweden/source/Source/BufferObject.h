
#ifndef __BUFFEROBJECT_H__
#define __BUFFEROBJECT_H__

#include "Extensions.h"
#include "Vertex.h"

enum BUFFER_TYPE {
	VERTEX_ARRAY,
	INDEX_ARRAY
};

class BufferObject {
	public:
		BufferObject();
		~BufferObject();

		void		genBuffer( BUFFER_TYPE const& t );
		void		bindBuffer() const;
		void		fillBuffer( vertexList const& vertices );
		void		fillBuffer( std::vector<unsigned int> const& indices );
		void		deleteBuffer();

	private:
		GLuint		bufferID;
		GLenum		type;
};

#endif