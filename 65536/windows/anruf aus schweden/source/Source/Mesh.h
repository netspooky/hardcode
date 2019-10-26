
#ifndef __MESH_H__
#define __MESH_H__

#include <vector>
#include "Vertex.h"
#include "Triangle.h"
#include "Transformation.h"
#include "Material.h"
#include "BufferObject.h"

class Mesh : public Transformation {
	public:
		Mesh();
		~Mesh();

		void						calcNormals();

		void						addVertex( Vertex const& vertex );
		void						addTriangle( Triangle const& triangle );
		void						setMaterial( Material const& _material );

		vertexList const&			getVertices() const;
		triangleList const&			getTriangles() const;
		Material const&				getMaterial() const;

		// vbo creation helpers
		void						offsetIndices( int offset );
		void						setIndexOffset( int pos );
		int							getIndexOffset() const;
		void						setFirstIndex( int _first );
		int							getFirstIndex() const;
		void						setLastIndex( int _last );
		int							getLastIndex() const;
		int							getTriangleCount() const;


	private:
		vertexList					vertices;
		triangleList				triangles;
		Material					material;

		int							indexOffset;
		int							first;
		int							last;
};

typedef std::vector<Mesh> meshList;

#endif