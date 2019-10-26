#include <stdio.h>
#include "object3d.hpp"

Object::Object()
{
	vertexcount = 0;
	facecount = 0;
	edgecount = 0;

	vertices = NULL;
	faces = NULL;
	edges = NULL;
}

Object::~Object()
{
	destroy();
}

void Object::destroy()
{
	if (vertices)
		delete [] vertices;
	if (faces)
		delete [] faces;
	if (edges)
		delete [] edges;

	vertexcount = 0;
	edgecount = 0;
	facecount = 0;
}

void Object::calculateNormals()
{
	int i;
	FILE *fp;

	fp = fopen("C:\\debug.txt", "wt");
	char string[256];

	//facenormaalit


	for (i=0;i<vertexcount;i++)
	{
		sprintf(string, "i = %d, v = %f %f %f\n", i, vertices[i].position.x, vertices[i].position.y, vertices[i].position.z);
		fputs(string, fp);
	}



	for (i=0;i<facecount;i++)
	{
		Vector v1 = vertices[faces[i].v1].position;
		Vector v2 = vertices[faces[i].v2].position;
		Vector v3 = vertices[faces[i].v3].position;

//		Vector normal = (v1-v2).crossProduct(v1-v3);
		Vector normal = (v2-v1).crossProduct(v3-v1);

		faces[i].normal = normal.normalize()*-1;
		sprintf(string, "i=%d\nindeksit = %d %d %d\nv1 = %f,%f,%f\n, v2 = %f,%f,%f\n, v3 = %f,%f,%f\n, normal = %f,%f,%f\n,normalisoitu=%f,%f,%f\n\n", 
				i, faces[i].v1, faces[i].v2, faces[i].v3, v1.x, v1.y, v1.z, v2.x, v2.y, v2.z, v3.x, v3.y, v3.z, normal.x, normal.y, normal.z, faces[i].normal.x, faces[i].normal.y,
				faces[i].normal.z);
		fputs(string, fp);
	}
	//verteksinormaalit (samaan looppiin?)

	for (i=0;i<vertexcount;i++)
	{
		vertices[i].normal = Vector(0, 0, 0);
	}
	for (i=0;i<facecount;i++)
	{
		Vector normal = faces[i].normal;
		vertices[faces[i].v1].normal += normal;
		vertices[faces[i].v2].normal += normal;
		vertices[faces[i].v3].normal += normal;
	}
	for (i=0;i<vertexcount;i++)
	{
		vertices[i].normal.normalize();
	}
	fclose(fp);
}

void Object::buildSphere(float radius, int xres, int yres, Vector &color)
{
	int x, y;
	vertexcount = xres*yres;
	facecount = xres*yres*2;
	vertices = new Vertex[vertexcount];
	faces = new Face[facecount];

	for (y=0;y<yres;y++)
	{
		for (x=0;x<xres;x++)
		{
			const float xkohta = x / (float)xres;
			const float ykohta = y / (float)yres;

			Vector pos = sphereCoord(radius, ykohta*3.141592f, xkohta*2*3.141592f);
			vertices[x+y*xres].position = pos;
			vertices[x+y*xres].u = xkohta;
			vertices[x+y*xres].v = ykohta;
			vertices[x+y*xres].color = color;
		}
	}
	int index=0;
	for (y=0;y<yres;y++)
	{
		for (x=0;x<xres;x++)
		{
			faces[index].v1 = (x%xres)+(y%yres)*xres;
			faces[index].v2 = ((x+1)%xres)+(y%yres)*xres;
			faces[index].v3 = ((x+1)%xres)+((y+1)%yres)*xres;
			index++;
			faces[index].v1 = (x%xres)+(y%yres)*xres;
			faces[index].v2 = ((x+1)%xres)+((y+1)%yres)*xres;
			faces[index].v3 = ((x)%xres)+((y+1)%yres)*xres;
			index++;
		}
	}
}

void Object::buildPlane(float size, int xres, int yres, Vector &rotation)
{
	int x, y;
	Matrix rotate;

	vertexcount = xres*yres;
	facecount = xres*yres*2;
	vertices = new Vertex[vertexcount];
	faces = new Face[facecount];
	rotate.makeRotation(rotation.x, rotation.y, rotation.z);

	for (y=0;y<yres;y++)
	{
		for (x=0;x<xres;x++)
		{
			const float xkohta = x / (float)xres;
			const float ykohta = y / (float)yres;

			vertices[x+y*xres].position = (Vector(xkohta-0.5f, 0, ykohta-0.5f)*size)*rotate;
		}
	}
	int index=0;
	for (y=0;y<yres;y++)
	{
		for (x=0;x<xres;x++)
		{
			faces[index].v1 = (x%xres)+(y%yres)*xres;
			faces[index].v2 = ((x+1)%xres)+(y%yres)*xres;
			faces[index].v3 = ((x+1)%xres)+((y+1)%yres)*xres;
			index++;
			faces[index].v1 = (x%xres)+(y%yres)*xres;
			faces[index].v2 = ((x+1)%xres)+((y+1)%yres)*xres;
			faces[index].v3 = ((x)%xres)+((y+1)%yres)*xres;
			index++;
		}
	}

}

void Object::emptyCopy(Object *object)
{
	vertexcount = object->getVertexCount();
	edgecount = object->getEdgeCount();
	facecount = object->getFaceCount();

	vertices = new Vertex[vertexcount];
	edges = new Edge[edgecount];
	faces = new Face[facecount];
}





 
