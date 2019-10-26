#ifndef _Y16I_LIGHT_
#define _Y16I_LIGHT_
////////////////////// LightŠÖŒW ///////////////////////////
//
///////////////////////////////////////////////////////////////////////////////////////////
// lighting.cpp
class cLighting{
public:
	unsigned int lightNum;
	
	cColor4f specular;
	cColor4f diffuse;
	cColor4f ambient;
	float pos[4];
	
	cVec3f position;
	cVec3f basePos;
	float direction;
	
public:
	cLighting();
	~cLighting();
	void init(unsigned int targetNum);
	void setSpecular(float r, float g, float b, float a);
	void setDiffuse(float r, float g, float b, float a);
	void setAmbient(float r, float g, float b, float a);
	void setPosition(float x, float y, float z, float d);
	void move(cVec3f pos);
	void convert(void);
	void on(void);
	void off(void);
};


#endif _Y16I_LIGHT_
