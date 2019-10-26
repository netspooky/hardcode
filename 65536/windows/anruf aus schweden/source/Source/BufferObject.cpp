
#include "BufferObject.h"

BufferObject::BufferObject(): bufferID( 0 ) {
}

BufferObject::~BufferObject() {
}

void BufferObject::genBuffer( BUFFER_TYPE const& t ) {

	if( t == VERTEX_ARRAY )
		type = GL_ARRAY_BUFFER_ARB;
	else
		type = GL_ELEMENT_ARRAY_BUFFER_ARB;

	glGenBuffersARB( 1, &bufferID );
}

void BufferObject::bindBuffer() const {

	glBindBufferARB( type, bufferID );
}

void BufferObject::fillBuffer( vertexList const& vertices ) {

	assert( type == GL_ARRAY_BUFFER_ARB );

	bindBuffer();
	glBufferDataARB( type, static_cast<int>( vertices.size() ) * 2 * 4 * 4, vertices[ 0 ].pos.v, GL_STATIC_DRAW_ARB );
}

void BufferObject::fillBuffer( std::vector<unsigned int> const& indices ) {

	assert( type == GL_ELEMENT_ARRAY_BUFFER_ARB );

  	bindBuffer();
	glBufferDataARB( type, static_cast<int>( indices.size() ) * 4, &indices[ 0 ], GL_STATIC_DRAW_ARB );
}

void BufferObject::deleteBuffer() {
	glDeleteBuffersARB( 1, &bufferID );
}
