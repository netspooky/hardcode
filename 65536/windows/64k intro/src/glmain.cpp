#include "everything.h"

cSceneAll sceneall;												// manage all scene

// Initialize gl function
BOOL glInit(void)
{
	glClearColor (0.0, 0.0, 0.0, 1.0);							// Black Background
	glClearDepth (100);											// Depth Buffer Setup
	glDepthFunc (GL_LEQUAL);									// The Type Of Depth Testing (Less Or Equal)
	glEnable (GL_DEPTH_TEST);									// Enable Depth Testing
	glShadeModel (GL_SMOOTH);									// Select Smooth Shading
	glHint (GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);			// Set Perspective Calculations To Most Accurate

	sceneall.texture.generate(1);
	
	// SIN COS table
	createTrigonometricTbl();
	
	// scene initialize
	sceneall.init();
	
	return TRUE;
}

int sceneStatus=-1;

// GL draw
DWORD tickCount, lastTickCount;
BOOL glDraw(void)
{
	// get tick ount
	tickCount=GetTickCount();
	
	glClearStencil(0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);						// Clear Screen And Depth Buffer
	glLoadIdentity ();															// Reset The Modelview Matrix
	
	sceneall.camera.update();
	
	glEnable(GL_DEPTH_TEST);
	
	//  draw constantly time
	if(sceneStatus)	sceneall.move(sceneStatus);
	sceneStatus=1;
	sceneall.draw(sceneStatus);
	glDisable(GL_LIGHTING);
	return TRUE;
}

