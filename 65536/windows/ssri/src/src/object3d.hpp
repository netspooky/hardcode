#ifndef _OBJECT3D_HPP_
#define _OBJECT3D_HPP_

#include "stuff.hpp"

class Face
{
public:
	int v1, v2, v3; //indeksit verteksitaulukkoon
	Vector normal;

};

class Vertex
{
public:

	Vector position;
	Vector normal;
	Vector color;
	float u, v;
};

class Edge
{
public:
	int v1;
	int v2;
};

class Object
{
public:
	Object();
	~Object();

	Vertex *getVertices() { return vertices; }
	Face *getFaces() { return faces; }
	Edge *getEdges() { return edges; }

	int getVertexCount() { return vertexcount; }
	int getFaceCount() { return facecount; }
	int getEdgeCount() { return edgecount; }

	void calculateNormals();

	void buildSphere(float radius, int xres, int yres, Vector color);
	void buildPlane(float size, int xres, int yres, Vector rotation);
	void emptyCopy(Object *object);

	void destroy();

private:

	int vertexcount;
	int facecount;
	int edgecount;

	Vertex *vertices;
	Face *faces;
	Edge *edges;

};

#endif
