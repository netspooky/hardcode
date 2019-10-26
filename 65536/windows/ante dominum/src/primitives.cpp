#include "primitives.hpp"
#pragma warning (disable : 4305)
/*
void tetrahedron();
void octahedron();
void hexahedron();
void icosahedron();
void dodecahedron();
*/
/*
static float tetravertices[4][3] = 
{
	-1, -1, -1,
	 1,  1, -1,
	 1, -1,  1,
	-1,  1,  1,
};
static int tetrafaces[4][3] = 
{
	1, 2, 3,
	1, 0, 2,
	3, 2, 0,
	0, 1, 3,
};
*/

static Vector tetravertices[4] = 
{
	Vector(-1, -1, -1),
	Vector(1, 1, -1),
	Vector(1, -1, 1),
	Vector(-1, 1, 1)
};

static int tetrafaces[4][3] = 
{
	1,2,3,
	1,0,2,
	3,2,0,
	0,1,3
};

static Vector octavertices[6] = 
{
	Vector(1,  0,  0),
	Vector(0, -1,  0),
	Vector(-1,  0,  0),
	Vector(0,  1,  0),
	Vector(0,  0,  1),
	Vector(0,  0, -1)
};

static int octafaces[8][3] = 
{
	4, 0, 1,
	4, 1, 2,
	4, 2, 3,
	4, 3, 0,
	5, 1, 0,
	5, 2, 1,
	5, 3, 2,
	5, 0, 3,
};

static Vector cubevertices[8] = 
{
	Vector(-1, -1, -1),
	Vector( 1, -1, -1),
	Vector( 1,  1, -1),
	Vector(-1,  1, -1),
	Vector(-1, -1,  1),
	Vector( 1, -1,  1),
	Vector( 1,  1,  1),
	Vector(-1,  1,  1),
};
static int cubefaces[6][4] = 
{
	0, 1, 2, 3,
	5, 4, 7, 6,
	6, 2, 1, 5,
	3, 7, 4, 0,
	7, 3, 2, 6,
	5, 1, 0, 4,
};

static Vector icosavertices[12] = 
{
	Vector(0, -0.52573,  0.85065),
	Vector(0.85065,  0,  0.52573),
	Vector(0.85065,  0, -0.52573),
	Vector(-0.85065,  0, -0.52573),
	Vector(-0.85065,  0,  0.52573),
	Vector(-0.52573,  0.85065,  0),
	Vector(0.52573,  0.85065,  0),
	Vector(0.52573, -0.85065,  0),
	Vector(-0.52573, -0.85065,  0),
	Vector(0, -0.52573, -0.85065),
	Vector(0,  0.52573, -0.85065),
	Vector(0,  0.52573,  0.85065)
};

static int icosafaces[20][3] = 
{
	6, 2, 1, 
	2, 7, 1, 
	5, 4, 3, 
	8, 3, 4, 
	11, 5, 6, 
	10, 6, 5, 
	2, 10, 9, 
	3, 9, 10, 
	9, 8, 7, 
	0, 7, 8, 
	1, 0, 11, 
	4, 11, 0, 
	10, 2, 6, 
	11, 6, 1, 
	10, 5, 3, 
	11, 4, 5, 
	9, 7, 2, 
	0, 1, 7, 
	8, 9, 3, 
	0, 8, 4, 
};

static Vector dodecavertices[20] = 
{
	Vector(-0.57735, -0.57735, 0.57735),
	Vector(0.93417, 0.35682, 0),
	Vector(0.93417, -0.35682, 0),
	Vector(-0.93417, 0.35682, 0),
	Vector(-0.93417, -0.35682, 0),
	Vector(0, 0.93417, 0.35682),
	Vector(0, 0.93417, -0.35682),
	Vector(0.35682, 0, -0.93417),
	Vector(-0.35682, 0, -0.93417),
	Vector(0, -0.93417, -0.35682),
	Vector(0, -0.93417, 0.35682),
	Vector(0.35682, 0, 0.93417),
	Vector(-0.35682, 0, 0.93417),
	Vector(0.57735, 0.57735, -0.57735),
	Vector(0.57735,0.57735,0.57735),
	Vector(-0.57735, 0.57735, -0.57735),
	Vector(-0.57735, 0.57735, 0.57735),
	Vector(0.57735, -0.57735, -0.57735),
	Vector(0.57735, -0.57735, 0.57735),
	Vector(-0.57735, -0.57735, -0.57735)
};
static int dodecafaces[12][5] = 
{
	1, 2, 18, 11, 14, 
	1, 13, 7, 17, 2, 
	3, 4, 19, 8, 15, 
	3, 16, 12, 0, 4, 
	3, 15, 6, 5, 16, 
	1, 14, 5, 6, 13, 
	2, 17, 9, 10, 18, 
	4, 0, 10, 9, 19, 
	7, 8, 19, 9, 17, 
	6, 15, 8, 7, 13, 
	5, 14, 11, 12, 16, 
	10, 0, 12, 11, 18, 
};

void tetrahedron()
{
	int i;
	int facecount = 4;
	glBegin(GL_TRIANGLES);

	for (i=0;i<facecount;i++)
	{
		Vector v1 = tetravertices[tetrafaces[i][0]];
		Vector v2 = tetravertices[tetrafaces[i][1]];
		Vector v3 = tetravertices[tetrafaces[i][2]];

		Vector n = (v3-v1).crossProduct(v2-v1).normalize();
		glNormal3fv((float *)&n);
		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
		glVertex3fv((float *)&v3);
	}
	glEnd();
}

void octahedron()
{
	int i;
	int facecount = 8;
	glBegin(GL_TRIANGLES);

	for (i=0;i<facecount;i++)
	{
		Vector v1 = octavertices[octafaces[i][0]];
		Vector v2 = octavertices[octafaces[i][1]];
		Vector v3 = octavertices[octafaces[i][2]];

		Vector n = (v3-v1).crossProduct(v2-v1).normalize();
		glNormal3fv((float *)&n);
		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
		glVertex3fv((float *)&v3);
	}
	glEnd();
}

void hexahedron()
{
	int i;
	int facecount = 6;
	glBegin(GL_QUADS);

	for (i=0;i<facecount;i++)
	{
		Vector v1 = cubevertices[cubefaces[i][0]];
		Vector v2 = cubevertices[cubefaces[i][1]];
		Vector v3 = cubevertices[cubefaces[i][2]];
		Vector v4 = cubevertices[cubefaces[i][3]];

		Vector n = (v3-v1).crossProduct(v2-v1).normalize();
		glNormal3fv((float *)&n);
		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
		glVertex3fv((float *)&v3);
		glVertex3fv((float *)&v4);
	}
	glEnd();
}

void icosahedron()
{
	int i;
	int facecount = 20;
	glBegin(GL_TRIANGLES);

	for (i=0;i<facecount;i++)
	{
		Vector v1 = icosavertices[icosafaces[i][0]];
		Vector v2 = icosavertices[icosafaces[i][1]];
		Vector v3 = icosavertices[icosafaces[i][2]];

		Vector n = (v3-v1).crossProduct(v2-v1).normalize();
		glNormal3fv((float *)&n);
		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
		glVertex3fv((float *)&v3);
	}
	glEnd();
}

void dodecahedron()
{
	int i;
	int facecount = 12;

	for (i=0;i<facecount;i++)
	{
		Vector v1 = dodecavertices[dodecafaces[i][0]];
		Vector v2 = dodecavertices[dodecafaces[i][1]];
		Vector v3 = dodecavertices[dodecafaces[i][2]];
		Vector v4 = dodecavertices[dodecafaces[i][3]];
		Vector v5 = dodecavertices[dodecafaces[i][4]];

		Vector n = (v3-v1).crossProduct(v2-v1).normalize();
		glBegin(GL_POLYGON);
		glNormal3fv((float *)&n);
		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
		glVertex3fv((float *)&v3);
		glVertex3fv((float *)&v4);
		glVertex3fv((float *)&v5);
		glEnd();
	}
	glEnd();
}


void wireCube(float size)
{
	if (size <= 0) return;
	Vector upleftback = Vector( -size, -size, -size);
	Vector upleftfront = Vector(-size, -size, +size);
	Vector uprightback = Vector( size, -size, -size);
	Vector uprightfront = Vector(size, -size, +size);

	Vector downleftback = Vector( -size, size, -size);
	Vector downleftfront = Vector(-size, size, +size);
	Vector downrightback = Vector( size, size, -size);
	Vector downrightfront = Vector(size, size, +size);
	
	glBegin(GL_LINES);

	//yläsivu vasen
	glVertex3fv((float *)&upleftfront);
	glVertex3fv((float *)&upleftback);
	//yläsivu oikea
	glVertex3fv((float *)&uprightfront);
	glVertex3fv((float *)&uprightback);
	//yläsivu etu
	glVertex3fv((float *)&uprightfront);
	glVertex3fv((float *)&upleftfront);
	//yläsivu taka
	glVertex3fv((float *)&uprightback);
	glVertex3fv((float *)&upleftback);

	//alasivu vasen
	glVertex3fv((float *)&downleftfront);
	glVertex3fv((float *)&downleftback);
	//alasivu oikea
	glVertex3fv((float *)&downrightfront);
	glVertex3fv((float *)&downrightback);
	//alasivu etu
	glVertex3fv((float *)&downrightfront);
	glVertex3fv((float *)&downleftfront);
	//alasivu taka
	glVertex3fv((float *)&downrightback);
	glVertex3fv((float *)&downleftback);

	//oikea sivu ylä
	glVertex3fv((float *)&uprightfront);
	glVertex3fv((float *)&uprightback);
	//oikea sivu ala
	glVertex3fv((float *)&downrightfront);
	glVertex3fv((float *)&downrightback);
	//oikea sivu etu
	glVertex3fv((float *)&uprightfront);
	glVertex3fv((float *)&downrightfront);
	//oikea sivu taka
	glVertex3fv((float *)&uprightback);
	glVertex3fv((float *)&downrightback);

	//vasen sivu ylä
	glVertex3fv((float *)&upleftfront);
	glVertex3fv((float *)&upleftback);
	//vasen sivu ala
	glVertex3fv((float *)&downleftfront);
	glVertex3fv((float *)&downleftback);
	//vasen sivu etu
	glVertex3fv((float *)&upleftfront);
	glVertex3fv((float *)&downleftfront);
	//vasen sivu taka
	glVertex3fv((float *)&upleftback);
	glVertex3fv((float *)&downleftback);

	//etusivu ylä
	glVertex3fv((float *)&uprightfront);
	glVertex3fv((float *)&upleftfront);
	//etusivu ala
	glVertex3fv((float *)&downrightfront);
	glVertex3fv((float *)&downleftfront);
	//etusivu oikea
	glVertex3fv((float *)&uprightfront);
	glVertex3fv((float *)&downrightfront);
	//etusivu vasen
	glVertex3fv((float *)&upleftfront);
	glVertex3fv((float *)&downleftfront);

	//takasivu ylä
	glVertex3fv((float *)&uprightback);
	glVertex3fv((float *)&upleftback);
	//takasivu ala
	glVertex3fv((float *)&downrightback);
	glVertex3fv((float *)&downleftback);
	//takasivu oikea
	glVertex3fv((float *)&uprightback);
	glVertex3fv((float *)&downrightback);
	//takasivu vasen
	glVertex3fv((float *)&upleftback);
	glVertex3fv((float *)&downleftback);

	glEnd();
}
 
