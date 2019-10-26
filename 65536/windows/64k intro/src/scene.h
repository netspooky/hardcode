#ifndef _Y16I_SCENE_
#define _Y16I_SCENE_

////////////////////////////////////////////////////////////////////////////////
// Scene
class cScene01{
public:
	
	vector < cLightnings > lightnings;
	cLighting light0, light1;
	
	// camera motion
	cKnots knots;
	float currentPosition;
	
	// background
	cSphere sph0, bgSph0;
	float pointSize;
	
public:
	cScene01();
	~cScene01();
	void init(void);
	void restart(void);
	void move(void);
	void draw(void);
};


////////////////////////////////////////////////////////////////////////////////
// SceneAll
class cSceneAll{
public:
	cScene01 s01;
	
	int before, current, after;
	
	DWORD tickCount, lastTickCount;
	float baseCount;
	
	cTexture texture;
	cCamera camera;
	cBlend blend;
	
public:
	cSceneAll();
	~cSceneAll();
	void init(void);
	void restart(int sceneNum);
	void move(int sceneNum);
	void draw(int sceneNum);
};

#endif _Y16I_SCENE_
