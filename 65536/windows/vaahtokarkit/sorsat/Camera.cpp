#include "Camera.h"
#include "Error.h"
#include "Sphere.h"

Camera::Camera()
{
  argsused = 1;
  target = new Sphere();
}

void Camera::createCameraMatrix()
{
  Vector cx,cy,cz;

  cz.x = target->position.x - position.x;
	cz.y = target->position.y - position.y;
	cz.z = target->position.z - position.z;
  vectorNormalizeAndGetLength(&cz);

  cy.x = 0;
  cy.y = 1;
  cy.z = 0;
  vectorCrossProduct(&cx,&cy,&cz);
  vectorNormalize(&cx);

  vectorCrossProduct(&cy,&cz,&cx);

  cameramatrix.m[0][0]=cx.x;	cameramatrix.m[0][1]=cx.y;	cameramatrix.m[0][2]=cx.z;
  cameramatrix.m[1][0]=cy.x;	cameramatrix.m[1][1]=cy.y;	cameramatrix.m[1][2]=cy.z;
  cameramatrix.m[2][0]=cz.x;	cameramatrix.m[2][1]=cz.y;	cameramatrix.m[2][2]=cz.z;

  Matrix t;
  t.identity();

  float s=sinf(3.141592f*2.0f*(arg1*cz.x)/360.0f),c=cosf(3.141592f*2.0f*(arg1*cz.x)/360.0f);
  t.m[1][1]=c;  t.m[1][2]=s;
  t.m[2][1]=-s; t.m[2][2]=c;
  cameramatrix.multipleMatrix(t);

  t.identity();
  s=sinf(3.141592f*2.0f*(arg1*cz.y)/360.0f);
  c=cosf(3.141592f*2.0f*(arg1*cz.y)/360.0f);
  t.m[0][0]=c; t.m[0][2]=-s;
  t.m[2][0]=s; t.m[2][2]=c;
  cameramatrix.multipleMatrix(t);

  t.identity();
  s=sinf(3.141592f*2.0f*(arg1*cz.z)/360.0f);
  c=cosf(3.141592f*2.0f*(arg1*cz.z)/360.0f);
  t.m[0][0]=c;  t.m[0][1]=s;
  t.m[1][0]=-s; t.m[1][1]=c;
  cameramatrix.multipleMatrix(t);
/*
  cameramatrix.rotateX(arg1*cz.x);
  cameramatrix.rotateY(arg1*cz.y);
  cameramatrix.rotateZ(arg1*cz.z);
*/
}
