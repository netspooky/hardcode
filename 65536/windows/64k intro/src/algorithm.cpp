////////////////////////////////////////////////////////////////////////////////
// include header files
#include "everything.h"


///////////////////////////////////////////////////////////////////////////////
// Create Bezier
cBezier::cBezier()
{
}

cBezier::~cBezier()
{
}

void
cBezier::init(int divides)
{
	divs=divides;
	flg=0;
	orbit.resize(divs);
	fillOrbit=false;
}

// return to current number od position
int cBezier::statusCurrent(void)
{
	if(current==divs-1){
		flg=1;
		fillOrbit=true;
	}
	if(current==0){
		flg=0;
	}
	if(current>0 && current<divs)	return 1;
	return -1;
}

void
cBezier::update(void)
{
	if(!flg)	incCurrent();
	if(flg)		decCurrent();
}

// gohead one by currnent positoin
void
cBezier::incCurrent(void)
{
	if(!flg){
		current++;
	}
	else{
		current=0;
		flg=1;
	}
}

// back one by current position
void
cBezier::decCurrent(void)
{
	if(flg){
		current--;
	}
	else{
		flg=0;
		current=divs;
	}
}

void
cBezier::slide(void)
{
	if(current>divs*0.5){
		cVec3f tmp;
		tmp=anchors[0];
		anchors[0]=anchors[1];
		anchors[1]=anchors[2];
		anchors[2]=anchors[3];
		anchors[3]=tmp;
	}
}

void
cBezier::pushAnchor(cVec3f newPos)
{
	anchors[1]=anchors[0];
	anchors[2]=anchors[1];
	anchors[3]=anchors[2];
	anchors[0]=newPos;
}

void
cBezier::calculate(cVec3f *a)
{
	cVec3f temp[4];
	float px, py;

	temp[0]=anchors[0];
	temp[1]=anchors[1];
	temp[2]=anchors[2];
	temp[3]=anchors[3];
	
	px=(float)current/(float)divs;
	*a = bernstein(px, temp);
	
	py=px;
	temp[0] = bernstein(py, anchors);
	orbit[current] = *a = bernstein(px, temp);
}

void
cBezier::draw(void)
{
	int i;
	int max;
	int min;
	if(!fillOrbit){
		max=current-1;
	}
	else{
		max=orbit.size()-1;
	}
	
	if(max>divs*0.3)	min=max-(divs*0.3);
	else				min=0;
	float decClr=1.0/(max-min);
	float bl=0;
	for(i=min; i<max; i++){
		bl+=decClr;
		glColor4f(1.0, 1.0, 1.0-bl, 1.0);
		glBegin(GL_LINES);
			glVertex3f(orbit[i].x, orbit[i].y, orbit[i].z);
			glVertex3f(orbit[i+1].x, orbit[i+1].y, orbit[i+1].z);
		glEnd();
	}
}

////////////////////////////////////////
// PRIVATE
cVec3f cBezier::pointTimes(float c, cVec3f p)
{
	p.x *= c;	p.y *= c;	p.z *= c;
	return p;
}

cVec3f cBezier::bernstein(float u, cVec3f *p)
{
	cVec3f a, b, c, d;
	
	a=pointTimes(pow(u, 3), p[0]);
	b=pointTimes(3*pow(u, 2)*(1-u), p[1]);
	c=pointTimes(3*u*pow((1-u), 2), p[2]);
	d=pointTimes(pow((1-u), 3), p[3]);
	
	a+=b;
	c+=d;
	return a+c;
}

