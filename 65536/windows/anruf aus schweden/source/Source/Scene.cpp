
#include "Scene.h"
#include <utility>
#include <map>

Scene::Scene(): vertexBuffer(), indexBuffer() {
	meshes.reserve( 80 );
	cameras.reserve( 20 );
	lights.reserve( 4 );
	views.reserve( 1 );

	activeCamera		= 0;
	activeView			= 0;
}

Scene::~Scene() {

	meshes.clear();
	cameras.clear();
	lights.clear();
	views.clear();
}

void Scene::deleteBuffer() {
	vertexBuffer.deleteBuffer();
	indexBuffer.deleteBuffer();
}

void Scene::addMesh( Mesh const& mesh ) {
	meshes.push_back( mesh );
}

void Scene::addCamera( Camera const& camera ) {
	cameras.push_back( camera );
}

void Scene::addLight( Light const& light ) {
	lights.push_back( light );
}

void Scene::addView( View const& view ) {
	views.push_back( view );
}

void Scene::setActiveCamera( int _activeCamera ) {
	activeCamera = _activeCamera;
}

void Scene::setActiveView( int _activeView ) {
	activeView = _activeView;
}

meshList const& Scene::getMeshes() const {
	return meshes;
}

lightList const& Scene::getLights() const {
	return lights;
}

Camera const& Scene::getActiveCamera() const {
	return cameras[ activeCamera ];
}

View const& Scene::getActiveView() const {
	return views[ activeView ];
}

Light* Scene::getLightByPtr( int num ) {
	return &lights[ num ];
}

Camera* Scene::getCameraByPtr( int num ) {
	return &cameras[ num ];
}

void Scene::createBuffers() {

	vertexBuffer.genBuffer( VERTEX_ARRAY );
	indexBuffer.genBuffer( INDEX_ARRAY );

	vertexList					allVerts;
	std::vector<unsigned int>	allIndices;
	int							offset			= 0;

	for( meshList::iterator mit = meshes.begin(); mit != meshes.end(); ++mit ) {

		vertexList const& verts = mit->getVertices();
		for( vertexList::const_iterator vit = verts.begin(); vit != verts.end(); ++vit )
			allVerts.push_back( *vit );

		mit->offsetIndices( offset );
		mit->setIndexOffset( static_cast<int>( allIndices.size() ) );
		mit->setFirstIndex( offset );
		mit->setLastIndex( offset + static_cast<int>( verts.size() ) - 1 );

		triangleList const& tris = mit->getTriangles();
		for( triangleList::const_iterator tit = tris.begin(); tit != tris.end(); ++tit ) {
			allIndices.push_back( tit->a );
			allIndices.push_back( tit->b );
			allIndices.push_back( tit->c );
		}

		offset += static_cast<int>( verts.size() );
	}

	vertexBuffer.fillBuffer( allVerts );
	indexBuffer.fillBuffer( allIndices );

	allVerts.clear();
	allIndices.clear();
}

void Scene::bindVertexBuffer() {
	vertexBuffer.bindBuffer();
}

void Scene::bindIndexBuffer() {
	indexBuffer.bindBuffer();
}

std::vector<int> Scene::getIndicesDistanceDependent( Vector const& center ) {

	std::multimap<float, int>	distToCenter;

	for( meshList::iterator it = meshes.begin(); it != meshes.end(); ++it ) {

		float dist = fabs( ( it->getActualPosition( 0 ) - center ).magnitudeSquared() );
		distToCenter.insert( std::pair<float, int>( dist, static_cast<int>( distance( meshes.begin(), it ) ) ) );
	}

	std::vector<int>	ordered;

	for( std::multimap<float, int>::iterator it = distToCenter.begin(); it != distToCenter.end(); ++it )
		ordered.push_back( it->second );

	distToCenter.clear();

	return ordered;
}