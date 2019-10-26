#include <stdio.h>

#ifndef OS_X
#include <GL/gl.h>
#include <GL/glu.h>
#include <SDL/SDL.h>
#else
#include <gl.h>
#include <glu.h>
#include <SDL.h>
#endif

#include "misc.hpp"
#include "win32.hpp"
#include "sound.hpp"
#include "font.hpp"
#include "texture.hpp"
#include "timer.hpp"

#include "Effects/kasvu.hpp"
#include "Effects/rakenne.hpp"
#include "Effects/pyorre.hpp"
#include "Effects/viivatus.hpp"
#include "Effects/ruutu.hpp"
#include "Effects/aukko.hpp"
#include "Effects/alku.hpp"
#include "Effects/perhonen.hpp"
#include "Effects/kaupunki.hpp"
#include "Effects/molekyyli.hpp"
#include "Effects/virta.hpp"
#include "Effects/kellu.hpp"

#include "tausta.hpp"

Window win;
int OPENGL_XRES;
int OPENGL_YRES;
bool OPENGL_FULLSCREEN;

Vector clearcolor;

Vector harmaa = Vector(190/255.0f, 196/255.0f, 204/255.0f);
Vector oranssi = Vector(242/255.0f, 103/255.0f, 33/255.0f);
Vector sininen = Vector(31/255.0f, 65/255.0f, 126/255.0f);
Vector punainen = Vector(0.9f, 0.3f, 0.3f);
Vector violetti = Vector(0.6f, 0.3f, 0.6f);
Vector keltainen = Vector(0.7f,0.6f,0.25f);

Texture *render512_0;
Texture *render512_1;

Timer kello;
Sound sound;

bool runflag=false;
bool musicflag=true;
bool debugflag = false;
bool HRT=true;

int main(int argc, char **argv)
{
//	MSG msg = {0};
	bool done = false;

/*	//bring up the dialog	
	if(DialogBox(hInstance, MAKEINTRESOURCE(IDD_SETUPDIALOG), NULL, (DLGPROC)ConfigProc) == 1)
	{		
		return false;
	}*/

	OPENGL_XRES = WINDOW_WIDTH, OPENGL_YRES = WINDOW_HEIGHT;
	runflag = true;
	//if we want to run the intro
	if (runflag==true)
	{
		//create window and sound if necessary
		if(!win.create(false)) return 0;
		if (musicflag==true)
		{
			if(!sound.init()) 
				return 0;
		}

		//**************ENGINEN INITIT TÄHÄN********************

		textures_init();
		font_init();

		//***************EFEKTIEN INITIT TÄHÄN******************

		kasvu_init();
		rakenne_init();
		pyorre_init();
		viivatus_init();
		ruutu_init();
		aukko_init();
		alku_init();
		perhonen_init();
		kaupunki_init();
		molekyyli_init();
		virta_init();
		kellu_init();

//		clearcolor = Vector(0,0,0);
//		clearcolor = Vector(1,1,1);

		clearcolor = harmaa;

		if (musicflag==true)
			sound.play();

		kello.start();

		SDL_Event event;
		while(!done)
		{
#if defined(OS_X) && defined(FULLSCREEN)
			SDL_WarpMouse(WINDOW_WIDTH, WINDOW_HEIGHT);
#endif
			SDL_PollEvent(&event);
			switch(event.type)
			{
				case SDL_QUIT:
					done = true;
					break;
				case SDL_KEYDOWN:
					switch (event.key.keysym.sym)
					{
						case SDLK_ESCAPE:
							done = true;
							break;
					}
			}

			glEnable(GL_POINT_SMOOTH);
			glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
			glEnable(GL_LINE_SMOOTH);
			glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);

			glClearColor(clearcolor.x, clearcolor.y, clearcolor.z, 1);
			glLineWidth(1.0f);
			glDepthMask(1);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			glViewport(0, 0, OPENGL_XRES, OPENGL_YRES);

			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluPerspective(45.0f, OPENGL_XRES/(float)OPENGL_YRES, 0.01f, 1000.0f);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			const int introloppu = 200000;
			kello.update();
			int aika = (int)kello.getMilliseconds();

			const int efekti0[] = {0, 23500}; //alkutekstit
			const int efekti1[] = {20000, 40000}; //rakenne
			const int efekti2[] = {39500, 59800}; //viivatus
			const int efekti3[] = {59000, 79000}; //pyörre
			const int efekti4[] = {79000, 102000}; //ruutu
			const int efekti5[] = {101000, 124000}; //kasvu
			const int efekti6[] = {124000, 141000}; //aukko
			const int efekti7[] = {140000, 162000}; //perhonen
			const int efekti8[] = {159000, 180000}; //virta
			const int efekti9[] = {178800, 200000}; //kaupunki


			const int kellut[] = {24000, 58000};

			//intro tähän 

			//alkuosan jutut
			taustasky(0.4f, calcSaturate((float)aika, 35000.0f, 124000.0f, 12));
			taustaground(0.4f, calcSaturate((float)aika, 35000.0f, 182000.0f, 12));
			taustasky(0.5f, calcPosFloat((float)aika, 140000.0f, 160000.0f));
			taustasky(0.5f, calcPosFloat((float)aika, 180000.0f, 188000.0f));

			if (testaaPos(aika, efekti0))
				alku(laskePos(aika, efekti0));
			if (testaaPos(aika, efekti1))
				rakenne(laskePos(aika, efekti1));
			if (testaaPos(aika, efekti2))
				viivatus(laskePos(aika, efekti2));
			if (testaaPos(aika, efekti3))
				pyorre(laskePos(aika, efekti3));
			if (testaaPos(aika, efekti4))
				ruutu(laskePos(aika, efekti4));
			if (testaaPos(aika, efekti5))
				kasvu(laskePos(aika, efekti5));
			if (testaaPos(aika, efekti6))
				aukko(laskePos(aika, efekti6));
			if (testaaPos(aika, efekti7))
				perhonen(laskePos(aika, efekti7));
			if (testaaPos(aika, efekti8))
				virta(laskePos(aika, efekti8));
			if (testaaPos(aika, efekti9))
				kaupunki(laskePos(aika, efekti9));

			//tilpet yms


			SDL_GL_SwapBuffers();

			if (aika >= introloppu)
				done = true;

		}

		//efektien vapautus
		kasvu_free();
		rakenne_free();
		pyorre_free();
		viivatus_free();
		ruutu_free();
		aukko_free();
		alku_free();
		perhonen_free();
		kaupunki_free();
		molekyyli_free();
		virta_free();
		kellu_free();

		//free engine related things
		textures_free();
		font_free();

		if (musicflag==true)
			sound.release();

		SDL_Quit();
		return 0;	
	}
	else
	{
		return 0;
	}

}
