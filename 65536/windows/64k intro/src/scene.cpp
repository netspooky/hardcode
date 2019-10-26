#include "everything.h"
#pragma warning(disable : 4305)


////////////////////////////////////////////////////////////////////////////////
// Object00
// used for all scenes
cSceneAll::cSceneAll()
{
}

cSceneAll::~cSceneAll()
{
}

void
cSceneAll::init(void)
{
	s01.init();
	baseCount=0;
	lastTickCount=GetTickCount();
}

void
cSceneAll::restart(int sceneNum)
{
	s01.restart();
}

void
cSceneAll::move(int sceneNum)
{
	tickCount=GetTickCount();
	baseCount=float(tickCount-lastTickCount)*0.01;
	lastTickCount=tickCount;
	
	s01.move();
}

void
cSceneAll::draw(int sceneNum)
{
	s01.draw();
}

////////////////////////////////////////////////////////////////////////////////
// Scene 01
cScene01::cScene01()
{
}

cScene01::~cScene01()
{
}

void
cScene01::init(void)
{
	// lightning is initilaized
	cVec3f p;
	cSize2f s;
	
	// set initialize value
	p.x=0.0;	p.y=0.0;	p.z=0.0;
	s.w=0.09;	s.h=0.03;
	
	int lightningNumber=3;
	
	int length=18;																// locus 
	int allLightningsNumber=15;
	lightnings.resize(allLightningsNumber);
	int speed=300;
	int i;
	for(i=0; i<allLightningsNumber; i++){
		int tmp=speed + int(speed*0.6)*rand()/RAND_MAX;
		lightnings[i].init(lightningNumber, length, p, s, tmp);
		lightnings[i].shuttle=true;
	}

	// light initialize
	light0.setSpecular(0.9, 0.9, 1.0, 0.5);
	light0.setDiffuse(0.8, 0.8, 0.9, 0.5);
	light0.setAmbient(0.2, 0.2, 0.7, 0.5);
	light0.setPosition(30.0, 10.0, 30.0, 1.0);
	light0.init(GL_LIGHT0);
	
	light1.setSpecular(1.0, 0.0, 1.0, 1.0);
	light1.setDiffuse(0.8, 0.0, 0.8, 1.0);
	light1.setAmbient(0.1, 0.0, 0.1, 1.0);
	light1.setPosition(8.0, 0.0, 8.0, 1.0);
	light1.init(GL_LIGHT1);
	
	// camera motion initialize
	{
	float rad=3.0;
	int divs=800;
	cVec3f p;
	p=0;
	knots.init(p, rad, divs);
	currentPosition=0.0;
	}
	
	// array sphere
	{
		cVec3f p;
		p=0;
		float r=5.0;
		cColor4f c;
		c=cColor4f(1.0, 1.0, 1.0, 1.0);
		sph0.init(36, 36, p, r);
		
		c=cColor4f(0.6, 0.6, 0.8, 1.0);
		bgSph0.init(8, 16, p, r*6);
	}
	
	pointSize=1;
}

void
cScene01::restart(void)
{
	int i;
	for(i=0; i<lightnings.size(); i++){
		lightnings[i].~cLightnings();
	}
	init();
}

void
cScene01::move(void)
{
	// set movements for lightning
	int i;
	for(i=0; i<lightnings.size(); i++){
		lightnings[i].move();
	}
	
	// move camera eye
	cVec3f eye=lightnings[0].thunPos;
	sceneall.camera.mViewDir=eye;
	
	if(currentPosition<knots.p.size())	currentPosition+=sceneall.baseCount;
	else								currentPosition=0;
	sceneall.camera.mPosition=knots.p[int(currentPosition)];
	
	// get bgm data
	bgm.statusUpdate();
}

void
cScene01::draw(void)
{
	int i;
	
	sceneall.blend.on(GL_SRC_ALPHA, GL_DST_ALPHA);
	light0.on();
	glPushMatrix();
		sceneall.texture.environmentOn("bgImg");
		glColor4f(1.0, 1.0, 1.0, 1.0);
		bgSph0.draw();
		sceneall.texture.environmentOff();
	glPopMatrix();
	light0.off();
	
	glPushMatrix();
		if(bgm.tick){
			pointSize=15.0;
		}
		else{
			pointSize-=sceneall.baseCount;
			if(pointSize<0)	pointSize=1.0;
		}
		glColor4f(1.0, 1.0, 1.0, 1.0);
		sph0.drawPoints(pointSize);
		
		light1.on();
		glColor4f(0.9, 0.0, 0.0, 1.0);
		sph0.drawLines();
		light1.off();
		
		glColor4f(0.0, 0.35, 0.0, 1.0);
		glLineWidth(5.0);
		sph0.drawNormals(0.4);
		glLineWidth(1.0);
	glPopMatrix();
	sceneall.blend.off();
	
	sceneall.blend.on(GL_SRC_ALPHA, GL_DST_ALPHA);
	// draw for lightning
	glPushMatrix();
		for(i=0; i<lightnings.size(); i++){
			lightnings[i].draw();
		}
	glPopMatrix();
	sceneall.blend.off();
}

