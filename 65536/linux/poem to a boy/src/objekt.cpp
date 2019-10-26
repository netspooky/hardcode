#include "objekt.h"

#include <cstring>
#include <GL/gl.h>
#include <cstdlib>

using namespace std;

Objekt::Objekt ( const vertex* vertexdata, const int vertexcount )
				: vcount(vertexcount - vertexcount%3), fcount((int)vertexcount/3) {
	int facecount = (int)vertexcount/3;
	dprint("Making objekt, faces: " << facecount << " vertices: " << vertexcount<<endl);
	vertices = new vertex[vertexcount];
	facenormals = new vector[facecount];
	vertexnormals = new vector[vertexcount];

	faces = (vertex ***)malloc(sizeof(vertex **) * facecount);

	vector p, q;

	memcpy(vertices, vertexdata, vertexcount * sizeof(vertex)); // init vertices

	for(int i = 0; i < facecount; i++) { 	// init faces
		faces[i] = (vertex **)malloc(sizeof(vertex *) * 3);
		faces[i][0] = &vertices[i*3];
		faces[i][1] = &vertices[i*3+1];
		faces[i][2] = &vertices[i*3+2];
		v_sub(&p, *faces[i][1], *faces[i][0]);
		v_sub(&q, *faces[i][2], *faces[i][0]);
		v_cross(&facenormals[i], p, q);
	}

	for(int ov = 0; ov < vertexcount; ov++) {  // init vertex normals
		vector v;
		for(int f = 0; f < facecount; f++) {
			for(int iv = 0; iv < 3; iv++) {
				if(v_equals(*faces[f][iv], vertices[ov])) {
					v_sum(&v, v, facenormals[f]); 
				}
			}
		}
		memcpy(vertexnormals[ov], v, sizeof(vector));
		v_norm(&vertexnormals[ov]);
	}

	for(int i = 0; i < facecount; i++) {
		v_norm(&facenormals[i]);
	}

	memset(pos, 0, sizeof(vector));
	memset(rot, 0, sizeof(matrix));  // init rotation matrix
	for(int i = 0; i < 4; i++) {
		rot[i*4+i] = 1.0;
	}

}

Objekt::~Objekt() {
	for(int i = 0; i < fcount; i++) {
		free(faces[i]);
		delete[] vertexnormals[i];
	}
	free(faces);
	free(vertexnormals);
	delete[] vertices;
	delete[] vertexnormals;
}

void Objekt::draw (  ){
	glPushMatrix();
	glTranslatef(pos[X], pos[Y], pos[Z]);
	glMultMatrixf(rot);
	glBegin(GL_TRIANGLES); {
		for(int i = 0; i < vcount; i++) {
			glNormal3fv(facenormals[i/3]);
			glVertex3fv(vertices[i]);
		}
	} glEnd();
	glPopMatrix();
}

void Objekt::move (const vector &incpos ){
	v_add(&pos, incpos);
}

void Objekt::move ( float x, float y, float z) {
	pos[X] += x;
	pos[Y] += y;
	pos[Z] += z;
}

void Objekt::rotate( float phi, float x, float y, float z) {
//	float c = cos(phi);
//	float s = sin(phi);
//	float t = 1 - cos(phi);
	
//	matrix m = { t*x*x + c, t*x*y - s*z, t*z*x + s*y, 0,
//				t*x*y + s*z, t*y*y + c, t*y*z - s*x, 0,
//				t*x*z - s*y, t*y*z + s*x, t*z*z + c, 0,
//				0, 0, 0, 1};
	
	glPushMatrix();
	glLoadMatrixf(rot);
//	glMultMatrixf(m);
	glRotatef(phi, x, y, z);
	glGetFloatv(GL_MODELVIEW_MATRIX, rot);
	glPopMatrix();
//	m_mul(rot, m);
//	memcpy(rot, m, sizeof(matrix));
	
	// blah blah!
}

// ----------------- hamster generating ----------------------

// #define gen_x(vertex, vertices, slice) ((float)((float)vertex/(float)vertices) - 1.0f)*slicefactor[slice]
#define gen_x(vertex, vertices, slice) (float)(vertex-4.0f)*slicefactor[slice]

float slicefactor[] = {0.0, 0.1, 0.1, 0.1, 0.1, 0.1, 0.0};
float zval[] = {0.0, 0.3, 2.0, 3.0, 4.0, 5.0, 6.0};
float yval[] = {0.0, 0.7, 0.8, 0.7, 0.6, 0.4, 0.0};

vertex* gen_hamster() {
	// config:
	int vertices[] = {1, 8, 8, 8, 8, 8, 1};
	const int slices = 6;
	const int faces = 70;

	// init array:
	vertex* data = (vertex*)malloc(sizeof(vertex)*faces*3);
	
//	vertex data[18*3]; //= new vertex[faces*3];
	
	// make hamster
	int vertexno = 0;
	for(int slice = 0; slice < slices; slice++) {
		int unf = vertices[slice];
		int lunf = vertices[slice+1];
		if(vertices[slice] == 1) {
			for(int face = 0; face < lunf-1; face++) {
				data[vertexno][2] = zval[slice];
				data[vertexno][0] = 0;
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;
				
				data[vertexno][2] = zval[slice + 1];
				data[vertexno][0] = gen_x(face, lunf, slice+1);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;

				data[vertexno][2] = zval[slice + 1];
				data[vertexno][0] = gen_x(face+1, lunf, slice+1);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;
			}
		} else if(vertices[slice +1] == 1) {
			for(int face = 0; face < unf-1; face++) {
				data[vertexno][2] = zval[slice];
				data[vertexno][0] = gen_x(face, unf, slice);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;

				data[vertexno][2] = zval[slice];
				data[vertexno][0] = gen_x(face+1, unf, slice);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;
				
				data[vertexno][2] = zval[slice + 1];
				data[vertexno][0] = 0;
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;
			}
		} else {
			for(int face = 0; face < unf-1; face++) {
				data[vertexno][2] = zval[slice];
				data[vertexno][0] = gen_x(face, unf, slice);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;

				data[vertexno][2] = zval[slice + 1];
				data[vertexno][0] = gen_x(face, lunf, slice+1);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;

				data[vertexno][2] = zval[slice];
				data[vertexno][0] = gen_x(face+1, unf, slice);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;

				data[vertexno][2] = zval[slice];
				data[vertexno][0] = gen_x(face+1, unf, slice);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;

				data[vertexno][2] = zval[slice + 1];
				data[vertexno][0] = gen_x(face, lunf, slice+1);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;

				data[vertexno][2] = zval[slice + 1];
				data[vertexno][0] = gen_x(face+1, lunf, slice+1);
				data[vertexno][1] = -abs(data[vertexno][0]);
				vertexno++;
			}
		}
	}
	dprint("Generated " << vertexno << " vertices." << endl);
	return data;
}

