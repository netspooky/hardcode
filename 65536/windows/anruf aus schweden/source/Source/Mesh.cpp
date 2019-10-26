
#include "Mesh.h"

Mesh::Mesh(): Transformation() {
	vertices.reserve( 1000 );
	triangles.reserve( 2000 );
}

Mesh::~Mesh() {
	vertices.clear();
	triangles.clear();
}

void Mesh::calcNormals() {

	for( triangleList::iterator it = triangles.begin(); it != triangles.end(); ++it )
		it->calcNormal( vertices[ it->a ].pos, vertices[ it->b ].pos, vertices[ it->c ].pos );

	for( triangleList::iterator it = triangles.begin(); it != triangles.end(); ++it )
		for( int j=0; j<3; j++ )
			vertices[ it->index[ j ] ].nrm += it->normal;
	
	for( vertexList::iterator it = vertices.begin(); it != vertices.end(); ++it )
		it->nrm.normalize();
}

void Mesh::addVertex( Vertex const& vertex ) {
	vertices.push_back( vertex );
}

void Mesh::addTriangle( Triangle const& triangle ) {
	triangles.push_back( triangle );
}

void Mesh::setMaterial( Material const& _material ) {
	material = _material;
}

vertexList const& Mesh::getVertices() const {
	return vertices;
}

triangleList const& Mesh::getTriangles() const {
	return triangles;
}

Material const& Mesh::getMaterial() const {
	return material;
}

void Mesh::offsetIndices( int offset ) {			// add offset to mesh indices (we have one whole vertexbuffer for all meshes)

	for( triangleList::iterator it = triangles.begin(); it != triangles.end(); ++it ) {
		it->a += offset;
		it->b += offset;
		it->c += offset;
	}
}

void Mesh::setIndexOffset( int pos ) {				// offset in den indexbuffer in byte
	indexOffset = pos * 4;
}

int Mesh::getIndexOffset() const {
	return indexOffset;
}

void Mesh::setFirstIndex( int _first ) {			// kleinster index in der range des index buffers
	first = _first;
}

int Mesh::getFirstIndex() const {
	return first;
}

void Mesh::setLastIndex( int _last ) {				// grösster index in der range des index buffers
	last = _last;
}

int Mesh::getLastIndex() const {
	return last;
}

int Mesh::getTriangleCount() const {
	return static_cast<int>( triangles.size() );
}