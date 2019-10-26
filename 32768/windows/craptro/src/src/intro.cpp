//--------------------------------------------------------------------------//
// iq . 2003/2008 . code for 64 kb intros by RGBA                           //
//--------------------------------------------------------------------------//


#include "sys/msys.h"
#include "sys/ufmod.h"
#include "intro.h"
#include "sys/msys.h"
#include "DemoText.h"

//Assets
#include "atari.h"
#include "song.h"
#include "floor.h"

Font *fnt;

#define in_time(a, x) (sceneTime >= (a) && sceneTime < (a)+(x))
// A cool curve which is excellent for fading text
#define io_curve(x) ((x)*(1-(x))*4)
// Fades in & out during the given time frame
#define fade_io(a, x) (io_curve((sceneTime-(a))/(x)))

int intro_init( int xr, int yr, int nomusic, IntroProgressDelegate *pd )
{
	Resize(XRES,YRES);
	fnt = new Font("[ATARI-FONT]Ver0.99", 20, false, false,atari,atari_len);
	floor_init();
    // remember to call pd->func() regularly to update the loading bar
	HWAVEOUT *res = uFMOD_PlaySong((void*)xm,(void*)sizeof(xm), XM_MEMORY);
	if (res == NULL) return 0;
    return 1;
}

void intro_end( void )
{    
    // deallicate your stuff here
}




//---------------------------------------------------------------------


int intro_do( void )
{
	static long lastTime = GetTime();
	long currTime = GetTime();
	long deltaTime = currTime - lastTime;
	lastTime = currTime;
	static float sceneTime = 0;
	sceneTime += (float)deltaTime/1000.f;

	floor_do();
	
	if (sceneTime > 53) sceneTime = 0.0;
	{
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		// Switch to 2D mode
		glDisable(GL_DEPTH_TEST);
		BeginOrtho2D(XRES, YRES);
		// Loop through all of the text
		for(int i = 0; i < numtext; i++)
		{
			// Draw the text if it's visible
			glPushMatrix();
			if(in_time(demotext[i].start, demotext[i].duration))
			{
				float c = fade_io(demotext[i].start, demotext[i].duration);

				glColor4f(1, 1, 1, c);

				glTranslatef(demotext[i].x + (sceneTime-demotext[i].start)*demotext[i].xspd,
				//flip Y coords when using FBOs
			//	(YRES-demotext[i].y) + (sceneTime-demotext[i].start)*-demotext[i].yspd, 0);
			    (demotext[i].y) + (sceneTime-demotext[i].start)*demotext[i].yspd, 0);

				glScalef(1+demotext[i].xscl, 1-demotext[i].yscl, 1);
				//flip X when using FBO
			//	glScalef(1.0f, -1.0f, 1.0f);
				fnt->Print(0, 0, demotext[i].msg);
			}
			glPopMatrix();
		}

		// Return to 3D
		EndProjection();
		glDisable(GL_TEXTURE_2D);
		glDisable(GL_BLEND);
	}

	
	

	return( 0 );
}