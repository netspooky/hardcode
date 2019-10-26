////////////////////////////////////////////////////////////////////////////////
#include "everything.h"

////////////////////////////////////////////////////////////////////////////////
// Camera class
cCamera::cCamera()
{
	// Initalize all our member varibles.
	mPosition.x=0.0, mPosition.y=0.0, mPosition.z=5.0;
	mViewDir.x=0.0, mViewDir.y=0.0, mViewDir.z=0.0;
	mUp.x=0.0, mUp.y=1.0, mUp.z=0.0;
}

cCamera::~cCamera()
{

}

void
cCamera::update(void)
{
//	cVec3f viewPos = mPosition + mViewDir;
//	gluLookAt(mPosition.x, mPosition.y, mPosition.z, viewPos.x, viewPos.y, viewPos.z, mUp.x, mUp.y, mUp.z);
	gluLookAt(mPosition.x, mPosition.y, mPosition.z, mViewDir.x, mViewDir.y, mViewDir.z, mUp.x, mUp.y, mUp.z);
	static int angle=0;
	if(angle<360)	angle+=sceneall.baseCount;
	else			angle=0;
	glRotatef(angle, 0.0, 1.0, 0.0);
}


/*
////////////////////////////////////////////////////////////////////////////////
// glLookAt wrapper
void setCamera(cVec3f eye, cVec3f center, cVec3f up)
{
	gluLookAt(eye.x, eye.y, eye.z, center.x, center.y, center.z, up.x, up.y, up.z);
}

////////////////////////////////////////////////////////////////////////////////
// Rotate camera eye
void controlCam(cVec3f* eye, cVec3f* center, cVec3f* up)
{

	cVec3f tmp=*eye;
	cVec3f res;
	// SHIFT==16
	if(!keys[VK_SHIFT]){
		// turn left
		if(keys[VK_LEFT]){																// left arrow
			*eye = turnOptAxis(-10.0, tmp, 0.0, 1.0, 0.0);
			keys[VK_LEFT]=false;
		}
		
		// turn up
		if(keys[VK_UP]){																// up arrow
			cVec3f nAxis;
			cVec3f val;
			val.x=eye->x;	val.y=0.0;	val.z=eye->z;
			normalize(&val);
			nAxis=turnOptAxis(90, val, 0.0, 1.0, 0.0);
//			cVec3f tmp1;
//			tmp1 = turnOptAxis(10.0, tmp, nAxis.x, 0.0, 0.0);
			res = turnOptAxis(10.0, tmp, nAxis.x, 0.0, nAxis.z);
			*eye=res;
			keys[VK_UP]=false;
		}

		// turn right
		if(keys[VK_RIGHT]){																// right arrow
			*eye = turnOptAxis(10.0, tmp, 0.0, 1.0, 0.0);
			keys[39]=false;
		}

		// turn down
		if(keys[VK_DOWN]){																// down arrow
			cVec3f nAxis;
			cVec3f val;
			val.x=eye->x;	val.y=0.0;	val.z=eye->z;
			normalize(&val);
			nAxis=turnOptAxis(90, val, 0.0, 1.0, 0.0);
//			cVec3f tmp1;
//			tmp1 = turnOptAxis(-10.0, tmp, nAxis.x, 0.0, 0.0);
			res = turnOptAxis(-10.0, tmp, nAxis.x, 0.0, nAxis.z);
			*eye=res;
			keys[VK_DOWN]=false;
		}
		
		// zoom in
		if(keys[VK_PRIOR]){																// PageUp
			eye->x*=0.9f;	eye->y*=0.9f;	eye->z*=0.9f;
			keys[VK_PRIOR]=false;
		}
		
		// zoom out
		if(keys[VK_NEXT]){																// PageDown
			eye->x*=1.1f;	eye->y*=1.1f;	eye->z*=1.1f;
			keys[VK_NEXT]=false;
		}
	}
	else{																			// If push SHIFT KEY
		// SHITF + Arrow LEFT
		if(keys[VK_LEFT]){
			cVec3f distance;
			distance.x=eye->x-center->x;
			distance.y=eye->y-center->y;
			distance.z=eye->z-center->z;
			normalize(&distance);
			distance=turnOptAxis(90, distance, 0.0, 1.0, 0.0);
			eye->x-=distance.x;		eye->y-=distance.y;		eye->z-=distance.z;
			center->x-=distance.x;	center->y-=distance.y;	center->z-=distance.z;
			keys[VK_LEFT]=false;
		}
		
		// SHIFT + Arrow RIGHT
		if(keys[VK_RIGHT]){
			cVec3f distance;
			distance.x=eye->x-center->x;
			distance.y=eye->y-center->y;
			distance.z=eye->z-center->z;
			normalize(&distance);
			distance=turnOptAxis(90, distance, 0.0, 1.0, 0.0);
			eye->x+=distance.x;		eye->y+=distance.y;		eye->z+=distance.z;
			center->x+=distance.x;	center->y+=distance.y;	center->z+=distance.z;
			keys[VK_RIGHT]=false;
		}
		
		// SHIFT + Arrow UP
		if(keys[VK_UP]){
			eye->y++;
			center->y++;
			keys[VK_UP]=false;
		}
		
		// SHIFT + Arrow DOWN
		if(keys[VK_DOWN]){
			eye->y--;
			center->y--;
			keys[VK_DOWN]=false;
		}
	}
}


////////////////////////////////////////////////////////////////////////////////
// ドラックでカメラを動かす
void camDrag(cVec3f* cam)
{
	cam->x=10*ySin(dragMouse.x*0.01)+10*yCos(dragMouse.x*0.01);
	cam->y=10*yCos(dragMouse.y*0.01);
	cam->z=10*ySin(dragMouse.y*0.01);
}
*/
