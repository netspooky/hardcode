#include "everything.h"

////////////////////////////////////////////////////////////////////////
// motion like a thunder
////////////////////////////////////////
// PUBLIC
cThunder::cThunder()
{
}

cThunder::~cThunder()
{
}

void
cThunder::init(int num, cVec3f pos, cSize2f size)
{
	vers.resize(num);
	s=size;
	p=pos;
	
	vect0.resize(num);
	vect1.resize(num);
	
	// set color
	clr=cColor4f(1.0, 1.0, 1.0, 1.0);
	decAlpha=1.0/float(num*0.6);
	
	// push each object vectors
	int i, cnt=1;
	float angle=280/(float)num;
	for(i=0; i<num; i++){
		cVec3f d0 = cVec3f(0.0, 1.0, 0.0);
		cVec3f d1 = cVec3f(1.0, 0.0, 0.0);
		pushVector(i, d0, d1);
		
		if(i>=int(vers.size()*0.5)){
			vers[i].clr = cColor4f(	1.0,
									0.5-(decAlpha*0.5)*cnt,
									0.0,
									1.0-(decAlpha*0.6)*cnt
									);
			cnt++;
		}
		else{
			vers[i].clr = cColor4f(1.0, 0.5, 0.0, 1.0);
		}
	}
	
	baseAngle=30.0+10.0*(float)rand()/(float)RAND_MAX;
}

// menorize vector
void
cThunder::pushVector(int num, cVec3f d0, cVec3f d1)
{
	vect0[num]=d0;
	vect1[num]=d1;
}


// make wave
void
cThunder::shake(cVec3f pos)
{
	cVec3f start=pos;
	cVec3f hPos;
	
	// calculate randam start position
	// this position is apllyed 'pos'
	start.x+=(s.h*(float)rand()/(float)RAND_MAX)-s.h*0.5;
	start.y+=(s.h*(float)rand()/(float)RAND_MAX)-s.h*0.5;
	start.z+=(s.h*(float)rand()/(float)RAND_MAX)-s.h*0.5;
	
	// force face to camera
	cVec3f aspect[2];
	cVec3f tmp0, tmp1, tmp2;
//	tmp0=camEye;
	tmp0=sceneall.camera.mPosition;
//	tmp1=camCent;
	tmp1=sceneall.camera.mViewDir;
	tmp2=start;
//	tmp2.x=camEye.z;	tmp2.y=camEye.y;	tmp2.z=camEye.x;
	tmp2=cVec3f(sceneall.camera.mPosition.z,
				sceneall.camera.mPosition.y,
				sceneall.camera.mPosition.x
				);
	cal2n(aspect, tmp0, tmp1, tmp2);
	cVec3f n0, n1;
	n0=aspect[0];
	n1=aspect[1];
	
	baseAngle=30.0 + 10*(float)rand()/(float)RAND_MAX;
	int i;
	for(i=0; i<vers.size(); i++){
		// generate randam value of angle
		
		cVec3f angle=cVec3f(
						((baseAngle*(float)rand()/(float)RAND_MAX)-baseAngle*0.5),
						((baseAngle*(float)rand()/(float)RAND_MAX)-baseAngle*0.5),
						((baseAngle*(float)rand()/(float)RAND_MAX)-baseAngle*0.5)
						);
		
		// create basic rect
		cVec3f vertex[4];
		cSize2f rect0=cSize2f(0.0, s.h);
		cSize2f rect1=cSize2f(0.0, 0.0);
		cSize2f rect2=cSize2f(s.w, 0.0);
		cSize2f rect3=cSize2f(s.w, s.h);
		
		// create new rect
		vertex[0] = cVec3f( vect1[i].x*rect0.h + vect0[i].x*rect0.w + start.x,
							vect1[i].y*rect0.h + vect0[i].y*rect0.w + start.y,
							vect1[i].z*rect0.h + vect0[i].z*rect0.w + start.z );
		
		vertex[1] = cVec3f( vect1[i].x*rect1.h + vect0[i].x*rect1.w + start.x,
							vect1[i].y*rect1.h + vect0[i].y*rect1.w + start.y,
							vect1[i].z*rect1.h + vect0[i].z*rect1.w + start.z );
		
		vertex[2] = cVec3f( vect1[i].x*rect2.h + vect0[i].x*rect2.w + start.x,
							vect1[i].y*rect2.h + vect0[i].y*rect2.w + start.y,
							vect1[i].z*rect2.h + vect0[i].z*rect2.w + start.z );
		
		vertex[3] = cVec3f( vect1[i].x*rect3.h + vect0[i].x*rect3.w + start.x,
							vect1[i].y*rect3.h + vect0[i].y*rect3.w + start.y,
							vect1[i].z*rect3.h + vect0[i].z*rect3.w + start.z );
		
		// turn around x axis
		vertex[2]=turnOptAxis(angle.x, vertex[2]-vertex[1], 1.0, 0.0, 0.0)+vertex[1];
		vertex[3]=turnOptAxis(angle.x, vertex[3]-vertex[0], 1.0, 0.0, 0.0)+vertex[0];
		
		// turn around y axis
		vertex[2]=turnOptAxis(angle.y, vertex[2]-vertex[1], 0.0, 1.0, 0.0)+vertex[1];
		vertex[3]=turnOptAxis(angle.y, vertex[3]-vertex[0], 0.0, 1.0, 0.0)+vertex[0];
		
		// turn around z axis
		vertex[2]=turnOptAxis(angle.z, vertex[2]-vertex[1], 0.0, 0.0, 1.0)+vertex[1];
		vertex[3]=turnOptAxis(angle.z, vertex[3]-vertex[0], 0.0, 0.0, 1.0)+vertex[0];
		
		// start point is translated
		if(i==0){
			hPos=vertex[1];
		}
		start=vertex[2];
		
		// set vertices
		vers[i].init(vertex);
	}
	p=hPos;
}

void
cThunder::draw(void)
{
	int i;
	sceneall.texture.normalOn("laser");
	glBegin(GL_TRIANGLES);
	for(i=1; i<vers.size(); i++){
		vers[i].draw();
	}
	glEnd();
	sceneall.texture.normalOff();
}


////////////////////////////////////////////////////////////////////////
// gathered thunders
cLightnings::cLightnings()
{
}

cLightnings::~cLightnings()
{
}

void
cLightnings::init(int numbers, int length, cVec3f position, cSize2f size, int spd)
{
	int i;
	thun.resize(numbers);
	
	beziDivs=spd;
	histMax=length;
	
	histCnt.resize(numbers);
	
	hist.resize(numbers);
	for(i=0; i<numbers; i++){
		hist[i].resize(histMax);
	}
	
	// generate anchor of bezier
	selectAnchor();
	
	fill(histCnt.begin(), histCnt.end(), 0);
	for(i=0; i<thun.size(); i++){
		thun[i].init(length, position, size);
		fill(hist[i].begin(), hist[i].end(), 0);
	}
	
	shuttle=true;
	type=typeA;
}


void
cLightnings::move(void)
{
	// compute next position
	int ans=bezi.statusCurrent();
	if(ans)	bezi.calculate(&thunPos);											// get current position
	bezi.update();
	
	// shuttle
	if(shuttle){
		// re-genelate bezier's anchor when go to the end of bezier line.
		if(bezi.current>=beziDivs-1){
			// generate anchor
			selectAnchor();
		}
	}
	
	int thunderId;
	for(thunderId=0; thunderId<thun.size(); thunderId++){
		// calculate vector from bezier positions
		if(histCnt[thunderId]<histMax){
			// save current posituin
			hist[thunderId][histCnt[thunderId]]=thunPos;
			
			if(histCnt[thunderId]>0){
				cVec3f l0, l1;
				l0=(hist[thunderId][histCnt[thunderId]-1]);
				l1=(hist[thunderId][histCnt[thunderId]]);
				
				// distance between two points on the bezier.
				cVec3f dist;
				dist=(l0-l1);
				
				// compute Normal with dist and camEye.
				cVec3f aspect[2];
				cVec3f tmp0=sceneall.camera.mPosition;
				cVec3f tmp1=sceneall.camera.mViewDir;
				cal2n(aspect, tmp0, tmp1, dist);
				cVec3f n0=aspect[0];
				
				dist.normalize();
				thun[thunderId].pushVector(histCnt[thunderId], dist, n0);
			}
			histCnt[thunderId]++;
		}
		else{
			histCnt[thunderId]=0;
		}
		thun[thunderId].shake(thunPos);
	}
}

/*
int
cLightnings::getPosition(cVec3f* pos)
{
	int ans=bezi.statusCurrent();
	if(ans)	bezi.calculate(&pos);											// get current position
	if(!bezi.flg)	bezi.incCurrent();											// step to next position
	if(bezi.flg)	bezi.decCurrent();											// step to before position
	
	return true;
}
*/

void
cLightnings::draw(void)
{
	int i;
	for(i=0; i<thun.size(); i++){
		// draw thunder
		thun[i].draw();
	}
	// draw bezier locus
	bezi.draw();
//	knots.draw();
}


////////////////////////////////////////
// PRIVATE
//+----+----+
//|    |    |
//|c   |d   |
//+----y----z
//|    |    |
//|a   |b   |
//+----x----+
void
cLightnings::selectAnchor(void)
{
	if(type>typeD){
		type=typeA;
	}
	else{
		type++;
	}

	int target0, target1, target2, target3;
	switch(type){
		case typeA:{
			target0=0;
			target1=1;
			target2=2;
			target3=3;
//			sprintf(debugInfo, "typeA: %d", type);
			break;
		}
		case typeB:{
			target0=1;
			target1=0;
			target2=2;
			target3=3;
//			sprintf(debugInfo, "typeB");
			break;
		}
		case typeC:{
			target0=3;
			target1=2;
			target2=1;
			target3=0;
//			sprintf(debugInfo, "typeC");
			break;
		}
		case typeD:{
			target0=2;
			target1=3;
			target2=1;
			target3=0;
//			sprintf(debugInfo, "typeD");
			break;
		}
		default:{
			target0=0;
			target1=1;
			target2=2;
			target3=3;
//			sprintf(debugInfo, "def");
			break;
		}
	}
	// a: x, +-y, -z
	bezi.anchors[target0]=cVec3f( 10*(float)rand()/(float)RAND_MAX,
								 (10*(float)rand()/(float)RAND_MAX)-5,
								 -10*(float)rand()/(float)RAND_MAX );
	// b: x, +-y, z
	bezi.anchors[target1]=cVec3f( 10*(float)rand()/(float)RAND_MAX,
								 (10*(float)rand()/(float)RAND_MAX)-5,
								 10*(float)rand()/(float)RAND_MAX );
	// c: -x, +-y, -z
	bezi.anchors[target2]=cVec3f(-10*(float)rand()/(float)RAND_MAX,
								 (10*(float)rand()/(float)RAND_MAX)-5,
								 -10*(float)rand()/(float)RAND_MAX );
	
	// d: -x, +-y, z
	bezi.anchors[target3]=cVec3f(-10*(float)rand()/(float)RAND_MAX,
								 (10*(float)rand()/(float)RAND_MAX)-5,
								  10*(float)rand()/(float)RAND_MAX );
	
	// initialize
	bezi.init(beziDivs);
	
	// reset current
	bezi.current=0;
}





////////////////////////////////////////////////////////////////////////////////
// knots class | call type A, B, C
cKnots::cKnots()
{
}

cKnots::~cKnots()
{
}

void
cKnots::init(cVec3f p, float rad, int div)
{
	c=1.0;
	initialize(rad, div);
}

void
cKnots::draw(void)
{
	int i;
	
	glPointSize(5.0);
	glBegin(GL_LINES);
	for(i=0; i<p.size()-1; i++){
		glColor4f(c.r, c.g, c.b, c.a);	glVertex3f(p[i].x, p[i].y, p[i].z);
		glColor4f(c.r, c.g, c.b, c.a);	glVertex3f(p[i+1].x, p[i+1].y, p[i+1].z);
	}
	glEnd();
	glPointSize(1.0);
}
