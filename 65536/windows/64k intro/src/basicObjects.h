#ifndef _Y16I_BASICOBJECT_
#define _Y16I_BASICOBJECT_

////////////////////////////////////////////////////////////////////////////////
// Sphere 緯度・経度・半径
class cSphere{
public:
	vector < vector < cVec3f > > v;												// Sphere Vertex
	vector < vector < cVec3f > > vb;											// basic sphere vertex
	vector < vector < cVec3f > > n0;											// NormalLine
	vector < vector < cVec2f > > t;
	
	cVec3f position;															// sphere center position
	float radius;
	
	int latitude;																// 緯度 -
	int longitude;																// 経度 |
	
	vector < cVec3f > len;

	
public:
	cSphere();
	~cSphere();
	void init(int vert, int hori, cVec3f pos, float radius);
	void draw(void);
	void drawPoints(float size);
	void drawLines(void);
	void drawNormals(float len);
};

////////////////////////////////////////////////////////////////////////////////
// knot Type A class
/*
class cKnotA{
public:
	vector < cVec3f > p;
//	float radius=0.5;
public:
	cKnotA();
	virtual ~cKnotA();
	void initialize(float rad, int segs);
};
*/

////////////////////////////////////////////////////////////////////////////////
// knot Type B class
class cKnotB{
public:
	vector < cVec3f > p;
	
public:
	cKnotB();
	virtual ~cKnotB();
	void initialize(float rad, int segs);
};


////////////////////////////////////////////////////////////////////////////////
// knot Type C class
/*
class cKnotC{
public:
	vector < cVec3f > p;
	
public:
	cKnotC();
	virtual ~cKnotC();
	void initialize(float rad, int segs);
};
*/

////////////////////////////////////////////////////////////////////////////////
// Vertices combination for OpenGL Vertex Array
class cVertices{
public:
	cVec3f v[4];
	cVec2f a, b, c, d;
	cColor4f clr;
	
public:
	cVertices();
	~cVertices();
	void init(cVec3f vertex[4]);
	void draw(void);
};


#endif _Y16I_BASICOBJECT_
