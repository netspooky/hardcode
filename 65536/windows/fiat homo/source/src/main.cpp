/*
	Fiat Homo by Traction
	main source file
*/

#include <stdlib.h>
#include <string.h>
#include <SDL/SDL.h>

#ifndef OS_X
#include <GL/gl.h>
#include <GL/glu.h>
#else
#include <gl.h>
#include <glu.h>
#endif

#include "misc.hpp"
#include "win32.hpp"
#include "sound.hpp"
#include "texture.hpp"
#include "font.hpp"
#include "data.h"
#include "Effects/alku.hpp"
#include "Effects/bigbang.hpp"
#include "Effects/atomi.hpp"
#include "Effects/molekyyli.hpp"
#include "Effects/dna.hpp"
#include "Effects/amino.hpp"
#include "Effects/solut.hpp"
#include "Effects/life.hpp"
#include "Effects/meri.hpp"
#include "Effects/meduusa.hpp"
#include "Effects/evoluutio.hpp"
#include "Effects/ranta.hpp"
#include "Effects/kukka.hpp"
#include "Effects/ihminen.hpp"
#include "Effects/galaksi.hpp"
Texture *pallura;
Texture *pallura2;
Texture *render512_0;
Texture *render512_1;
Texture *render512_2;
Texture *kasvot;
Texture *kasvot2;
Texture *planeetantekstuuri;
Window win;
int OPENGL_XRES;
int OPENGL_YRES;
bool OPENGL_FULLSCREEN;
Vector clearcolor;
int originalaika; //globaali, että näkyisi muuallekin.. 
bool smoothflag=true;
bool runflag=false;
bool musicflag=true;
bool spookyflag=false;
int main(int argc, char **argv)
{
    for(int i=1; i<argc; i++)
    {
		if(!strcmp(argv[i],"--no-smooth"))
		{
			smoothflag = false;
		}
	}

	Sound sound;
	bool done = false;
	OPENGL_XRES = WINDOW_WIDTH; OPENGL_YRES = WINDOW_HEIGHT;
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
		atexit(SDL_Quit);
		Vector clearcolorv(1,1,1);
		clearcolor = clearcolorv;
		bool inputdone = false;

		if (smoothflag)
		{
			glEnable(GL_POINT_SMOOTH);
			glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
			glEnable(GL_LINE_SMOOTH);
			glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
		}

		glDepthMask(1);
		glViewport(0, 0, OPENGL_XRES, OPENGL_YRES);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(45.0f, OPENGL_XRES/(float)OPENGL_YRES, 0.5f, 14000.0f);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		SDL_Event event;
		const int alkuajat[] = {0, 17000};
		const int efekti1ajat[] = {17000, 40200}; //bigbang
		const int efekti2ajat[] = {40000, 63000}; //atomi
		const int efekti3ajat[] = {63000, 83000}; //molekyyli
		const int efekti4ajat[] = {75000, 100000}; //dna
		const int efekti5ajat[] = {82000, 106000}; //amino
		const int efekti6ajat[] = {105000, 123000}; //solu
		const int efekti7ajat[] = {122000, 140000}; //life
		const int efekti8ajat[] = {139000, 162000}; //meri
		const int efekti9ajat[] = {161000, 190000}; //meduusa
		const int efekti10ajat[] = {190000, 218000}; //evoluutio/monoliitti
		const int efekti11ajat[] = {218000, 240000}; //kukka
		const int efekti12ajat[] = {239400, 262000}; //ranta
		const int efekti13ajat[] = {261300, 280000}; //ihminen
		const int efekti14ajat[] = {278500, 299500}; //galaksi
		const int introloppu = 300000;
		//**************ENGINEN INITIT TÄHÄN********************
		textures_init();
		font_init();
		//***************EFEKTIEN INITIT TÄHÄN******************
		alku_init();
		bigbang_init();
		atomi_init();
		molekyyli_init();
		dna_init();
		amino_init();
		solut_init();
		life_init();
		meri_init();
		meduusa_init();
		evoluutio_init();
		kukka_init();
		ranta_init();
		ihminen_init();
		galaksi_init();
		if (musicflag==true)
			sound.play();
		int alkuaika = SDL_GetTicks();
		while(!done)
		{
#ifdef OS_X
			SDL_WarpMouse(1024,768); //OS X fix
#endif
			glClearColor(clearcolor.x, clearcolor.y, clearcolor.z, 1);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			glLoadIdentity();
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
			originalaika = SDL_GetTicks()-alkuaika;
			//dna loppuu 100 sekunnin kohdalla
			if ((spookyflag==true) && (originalaika > 100000) && (originalaika < 105000))
			{
				const float spookiness = 1-calcPosInt(originalaika, 100000, 105000);
				Vector clearcolorv(spookiness,spookiness,spookiness);
				clearcolor = clearcolorv;
			}
			if (testaaPos(originalaika, alkuajat))
				alku(laskePos(originalaika, alkuajat));
			if (testaaPos(originalaika, efekti1ajat))
				bigbang(laskePos(originalaika, efekti1ajat));
			if (testaaPos(originalaika, efekti2ajat))
				atomi(laskePos(originalaika, efekti2ajat));
			if (testaaPos(originalaika, efekti3ajat))
				molekyyli(laskePos(originalaika, efekti3ajat));
			if (testaaPos(originalaika, efekti4ajat))
				dna(laskePos(originalaika, efekti4ajat));
			if (testaaPos(originalaika, efekti5ajat))
				amino(laskePos(originalaika, efekti5ajat));
			if (testaaPos(originalaika, efekti6ajat))
				solut(laskePos(originalaika, efekti6ajat));
			if (testaaPos(originalaika, efekti7ajat))
				life(laskePos(originalaika, efekti7ajat));
			if (testaaPos(originalaika, efekti8ajat))
				meri(laskePos(originalaika, efekti8ajat));
			if (testaaPos(originalaika, efekti9ajat))
				meduusa(laskePos(originalaika, efekti9ajat));
			if (testaaPos(originalaika, efekti10ajat))
				evoluutio(laskePos(originalaika, efekti10ajat));
			if (testaaPos(originalaika, efekti11ajat))
				kukka(laskePos(originalaika, efekti11ajat));
			if (testaaPos(originalaika, efekti12ajat))
				ranta(laskePos(originalaika, efekti12ajat));
			if (testaaPos(originalaika, efekti13ajat))
				ihminen(laskePos(originalaika, efekti13ajat));
			if (testaaPos(originalaika, efekti14ajat))
				galaksi(laskePos(originalaika, efekti14ajat));
			SDL_GL_SwapBuffers();
			if (originalaika >= introloppu)
				done = true;
		}
		SDL_WarpMouse(600,400);
		//call each effect's release function
		alku_free();
		bigbang_free();
		atomi_free();
		molekyyli_free();
		dna_free();
		amino_free();
		solut_free();
		life_free();
		meri_free();
		meduusa_free();
	//	planeetta_free();
		evoluutio_free();
		kukka_free();
		ranta_free();
		ihminen_free();
		galaksi_free();
		//free engine related things
		textures_free();
		font_free();
		if (musicflag==true)
			sound.release();
		//... and that was it, then.
		return 0;	
	}
	else //we don't want to run the intro.. bummer
	{
		return 0;
	}
}
