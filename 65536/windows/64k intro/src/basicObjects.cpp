#include "everything.h"
////////////////////////////////////////////////////////////////////////
// SPHERE CLASS 緯度・経度・半径
cSphere::cSphere()
{
}

cSphere::~cSphere()
{
	v.clear();
	n0.clear();
}
	
// Initialize sphere
void
//cSphere::init(float r, int slices, int stacks, cVec3f center)
cSphere::init(int vert, int hori, cVec3f pos, float r)
{
	position=pos;
	latitude=vert;
	longitude=hori;
	radius=r;
	int i, j;
	float pi=PI/180;
	float stp[2];
	
	v.resize(latitude);														// Resize vertexes for latitude
	vb.resize(latitude);
	n0.resize(latitude);
	t.resize(latitude);
	
	for(i=0; i<latitude; i++){
		v[i] .resize(longitude);												// Resize vertexes for longitude
		vb[i].resize(longitude);
		n0[i].resize(longitude);
		t[i].resize(longitude);
	}
	
	// create sphere vertexes
	float tw, th;
	tw=1.0/(float)(latitude);
	th=1.0/(float)(longitude);
	stp[0]=360/(float)(latitude-1);
	stp[1]=180/(float)(longitude-1);
	for(i=0; i<latitude; i++){
		for(j=0; j<longitude; j++){
			// compute sphere vertices
			vb[i][j].x = ySin(stp[1]*j*pi)*r*ySin(stp[0]*i*pi);
			vb[i][j].y = yCos(stp[1]*j*pi)*r;
			vb[i][j].z = ySin(stp[1]*j*pi)*r*yCos(stp[0]*i*pi);
			
			// copy basic veterx
			v[i][j]=vb[i][j]+position;
			
			// compute normalize each vertex
			cVec3f tmp=vb[i][j];
//			normalize(&tmp);
			tmp.normalize();
			n0[i][j]=tmp;
			
			// for texture
			t[i][j].x=tw*(float)i;
			t[i][j].y=th*(float)j;
		}
	}
	
//	// caluculate lenght between each vertices
//	calLength();
}


void
cSphere::draw(void)
{
	int i, j;
	glBegin(GL_TRIANGLES);
	for(i=0; i<latitude-1; i++){
		for(j=0; j<longitude-1; j++){
			glTexCoord2f(t[i][j].x, t[i][j].y);			glVertex3f(v[i][j].x, v[i][j].y, v[i][j].z); 
			glTexCoord2f(t[i][j+1].x, t[i][j+1].y);		glVertex3f(v[i][j+1].x, v[i][j+1].y, v[i][j+1].z);
			glTexCoord2f(t[i+1][j+1].x, t[i+1][j+1].y);	glVertex3f(v[i+1][j+1].x, v[i+1][j+1].y, v[i+1][j+1].z);
			
			glTexCoord2f(t[i][j].x, t[i][j].y);			glVertex3f(v[i][j].x, v[i][j].y, v[i][j].z);
			glTexCoord2f(t[i+1][j+1].x, t[i+1][j+1].y);	glVertex3f(v[i+1][j+1].x, v[i+1][j+1].y, v[i+1][j+1].z);
			glTexCoord2f(t[i+1][j].x, t[i+1][j].y);		glVertex3f(v[i+1][j].x, v[i+1][j].y, v[i+1][j].z);
		}
	}
	glEnd();
}

void
cSphere::drawPoints(float size)
{
	int i, j;
	glPointSize(size);
	glBegin(GL_POINTS);
	for(i=0; i<latitude-1; i++){
		for(j=0; j<longitude-1; j++){
			glVertex3f(v[i][j].x, v[i][j].y, v[i][j].z); 
		}
	}
	glEnd();
	glPointSize(1.0);
}


void
cSphere::drawLines(void)
{
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	draw();
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
}


void
cSphere::drawNormals(float len)
{
	int i, j;
	glBegin(GL_LINES);
	for(i=0; i<latitude-1; i++){
		for(j=0; j<longitude-1; j++){
			glVertex3f(v[i][j].x, v[i][j].y, v[i][j].z); 
			glVertex3f(v[i][j].x+n0[i][j].x*len, v[i][j].y+n0[i][j].y*len, v[i][j].z+n0[i][j].z*len); 
		}
	}
	glEnd();
}

////////////////////////////////////////////////////////////////////////////////
// knot Type A class
/*
cKnotA::cKnotA()
{
}

cKnotA::~cKnotA()
{
}

void
cKnotA::initialize(float rad, int segs)
{
	p.resize(segs+1);
	double twopi=PI*2.0;
	double mu;
	int i;
	for(i=0; i<=segs; i++){
		mu = i*twopi/double(segs);
//		double x = rad*10*(cos(mu) + rad*10*cos(3*mu)) + rad*cos(2*mu) + rad*cos(4*mu);
//		double y = rad*6*sin(mu) + rad*10*sin(3*mu);
//		double z = rad*4*sin(3*mu) * sin(5*mu/2) + rad*4*sin(4*mu) - rad*2*sin(6*mu);
		double x = 10*(cos(mu) + rad*10*cos(3*mu)) + cos(2*mu) + cos(4*mu);
		double y = 6*sin(mu) + 10*sin(3*mu);
		double z = 4*sin(3*mu) * sin(5*mu/2) + 4*sin(4*mu) - 2*sin(6*mu);
		
		// copy as float
		p[i].x=float(x*rad);
		p[i].y=float(y*rad);
		p[i].z=float(z*rad);
	}
}
*/

////////////////////////////////////////////////////////////////////////////////
// knot Type B class
cKnotB::cKnotB()
{
}

cKnotB::~cKnotB()
{
}

void
cKnotB::initialize(float rad, int segs)
{
	p.resize(segs+1);
	double twopi=PI*2.0;
	double mu;
	int i;
	for(i=0; i<=segs; i++){
		mu=i*twopi/double(segs);
		double x=4*(cos(mu+PI))/3 + 2*cos(3*mu);
		double y=4*sin(mu)/3 + 2*sin(3*mu);
		double z=sin(4*mu) + sin(2*mu)/2;
		
		p[i].x = x*rad;
		p[i].y = y*rad;
		p[i].z = z*rad;
	}
	
}

////////////////////////////////////////////////////////////////////////////////
// knot Type C class
/*
cKnotC::cKnotC()
{
}

cKnotC::~cKnotC()
{
}

void
cKnotC::initialize(float rad, int segs)
{
	p.resize(segs+1);
	double twopi = PI*2.0;
	double mu;
	// 3, 4 : 4, 7 : 6, 11
	int longitudes=6;
	int meridians=11;
	int i;
	for(i=0; i<=segs; i++){
		mu = i*twopi * meridians/double(segs);
		double x = cos(mu) * ( 1 + yCos(longitudes*mu/double(meridians))/2.0 );
		double y = sin(mu) * ( 1 + yCos(longitudes*mu/double(meridians))/2.0 );
		double z = sin(longitudes*mu/double(meridians))/2.0;
		
		p[i].x=x;
		p[i].y=y;
		p[i].z=z;
	}
}
*/

////////////////////////////////////////////////////////////////////////
// vertex set
// PUBLIC
cVertices::cVertices()
{
	// set to default texture value
	a=cVec2f(0.0, 0.0);
	b=cVec2f(0.0, 1.0);
	c=cVec2f(1.0, 1.0);
	d=cVec2f(1.0, 0.0);
}

cVertices::~cVertices()
{
}

void

cVertices::init(cVec3f vertex[4]){
	v[0]=vertex[0];
	v[1]=vertex[1];
	v[2]=vertex[2];
	v[3]=vertex[3];
}

void

cVertices::draw(void)
{
//		glBegin(GL_TRIANGLES);
	glColor4f(clr.r, clr.g, clr.b, clr.a);
	glTexCoord2f(a.x, a.y);	glVertex3f(v[0].x,	v[0].y,	v[0].z);
	glTexCoord2f(b.x, b.y);	glVertex3f(v[1].x,	v[1].y,	v[1].z);
	glTexCoord2f(c.x, c.y);	glVertex3f(v[2].x,	v[2].y,	v[2].z);
	glTexCoord2f(c.x, c.y);	glVertex3f(v[2].x,	v[2].y,	v[2].z);
	glTexCoord2f(d.x, d.y);	glVertex3f(v[3].x,	v[3].y,	v[3].z);
	glTexCoord2f(a.x, a.y);	glVertex3f(v[0].x,	v[0].y,	v[0].z);
//		glEnd();
}
