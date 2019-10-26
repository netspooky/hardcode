#ifndef _Y16I_CAMERA_
#define _Y16I_CAMERA_

//#include "glQuaternion.h"

////////////////////////////////////////////////////////////////////////////////
// CAMERA
//void setCamera(cVec3f eye, cVec3f center, cVec3f up);
//void controlCam(cVec3f* eye, cVec3f* center, cVec3f* up);
//void camDrag(cVec3f* cam);

////////////////////////////////////////////////////////////////////////////////
// Cameara class 
class cCamera
{
public:
	cVec3f mPosition;
	cVec3f mViewDir;
	cVec3f mUp;
	cVec3f mRight;
	void update(void);
//	void compute(float agl, float vel, float x0, float y0, float z0, cVec3f *p);
	
	cCamera();
	virtual ~cCamera();
};

#endif _Y16I_CAMERA_
