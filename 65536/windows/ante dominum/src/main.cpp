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
#include "config.hpp"
#include "timer.hpp"

#include "Effects/alku.hpp"
#include "Effects/platon.hpp"
#include "Effects/pot2d.hpp"
#include "Effects/newton.hpp"
#include "Effects/lorentz.hpp"
#include "Effects/rossler.hpp"
#include "Effects/fibotree.hpp" 
#include "Effects/converge.hpp" 
#include "Effects/field.hpp" 
#include "Effects/cell.hpp" 
#include "Effects/curves.hpp" 
#include "Effects/iterator.hpp" 
#include "Effects/dla.hpp" 

Window win;
int OPENGL_XRES = WINDOW_WIDTH;
int OPENGL_YRES = WINDOW_HEIGHT;
bool OPENGL_FULLSCREEN;

Vector clearcolor;

Texture *render512_0;
Texture *render512_1;
Texture *render512_2;

Timer kello;
Sound sound;

bool runflag=true;
bool musicflag=true;
bool debugflag = false;
bool HRT=true;

int main(int argc, char **argv)
{
	bool done = false;

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

		clearcolor = Vector(1,1,1);
		glClearColor(clearcolor.x, clearcolor.y, clearcolor.z, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//		glViewport(0, 0, OPENGL_XRES, OPENGL_YRES);
		glViewport(0, 0, 1024, 768);
glScalef(0.02,0.02,0.02);
		font_write(-0.9f, -0.9f, "please wait...");
//		font_write(0.0f, 0.0f, "please wait...");
		glColor4f(1,1,1,1);

SDL_GL_SwapBuffers();
	
		alku_init();
		fibotree_init();
		platon_init();
		pot2d_init();
		newton_init();
		lorentz_init();
		rossler_init();
		converge_init();
		field_init(); 
		cell_init();
		curves_init();
		iterator_init();
		dla_init();
		
#define COMPLETEINTRO 

//	#ifdef COMPLETEINTRO
		if (musicflag==true)
			sound.play();
//	#endif

		kello.start();
/*		while(!done && !GetAsyncKeyState(VK_ESCAPE))
		{
			if(PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
			{ 
				if(msg.message == WM_QUIT)
				{
					done = true;
				}
				else
				{
					TranslateMessage(&msg);
			 		DispatchMessage(&msg);
				}
			}
			else*/
		SDL_Event event;
		while(!done)
		{
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

			{
				glEnable(GL_POINT_SMOOTH);
				glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
				glEnable(GL_LINE_SMOOTH);
				glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);

				glClearColor(clearcolor.x, clearcolor.y, clearcolor.z, 1);
				glLineWidth(1.0f);
				glDepthMask(1);
				glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
				glViewport(0, 0, OPENGL_XRES, OPENGL_YRES);

				float kerroin = 1.0f;

/*				if (GetAsyncKeyState(VK_SHIFT))
					kerroin = 8.0f;

				if (GetAsyncKeyState(VK_RIGHT))
					kello.add(0.05f*kerroin);
				if (GetAsyncKeyState(VK_LEFT))
					kello.add(-0.05f*kerroin);
				if (GetAsyncKeyState(VK_SPACE))
					debugflag^=1;*/


				glMatrixMode(GL_PROJECTION);
				glLoadIdentity();
//				gluPerspective(45.0f, 1024.0f/768.0f, 0.01f, 1000.0f);
				gluPerspective(45.0f, OPENGL_XRES/(float)OPENGL_YRES, 0.01f, 1000.0f);
				glMatrixMode(GL_MODELVIEW);
				glLoadIdentity();
				const int introloppu = 245000;
				kello.update();
				int aika = (int)kello.getMilliseconds();
/*

15:59 <unclex> glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_COLOR);
15:59 <unclex> on inverse blendi, ts. valkoinen tummentaa yms yms
15:59 <Preacher> yritin muistaakseni juurikin tuota
16:00 <Preacher> mutta siinä tuli jotain ongelmia alphan kanssa ja motivaatio meni
16:00 <unclex> kyllä toi ainakin meidän enginessä toimii :)
16:00 <Preacher> tosin silloin kyseessä oli tekstuurit, viivat yms menis varmaan kätevästi tolla
16:00 <unclex> ja sit tietty multiploiva blendi (tummat asiat tummentaa, kirkkaat pysyy normaaleina) glBlendFunc(GL_ZERO, GL_SRC_COLOR);
16:03 <unclex> sit tietty jos kikkailet vielä ton multiploivan (siis tummentavan) hehkun päälle vaik vähän terävemmän tai vähemmän terävän
               additiivisen hehkun niin saat kunnon utua aikaiseksi
16:04 <Preacher> tai sit väsää suoraan shaderilla
16:04 <Preacher> vois kyllä kokeilla tuota
16:04 <Preacher> en ole koskaan oikein koodannut kunnollista postproc-filtteriä
16:04 <unclex> niitä kannattaa aina olla

*/
	#ifndef COMPLETEINTRO

				const int testiaika[] = {0, 13000};

				if (testaaPos(aika, testiaika))
					converge(laskePos(aika, testiaika));

	#else
/*
0 alku
12000 muutos
27000 efekti
40000 efekti (kuten nytkin)
53000 muutos
66000 fraktaalit alku
78000 efekti
92000 efekti
106000 efekti
119000 efekti
132000 efekti
145000 efekti
159000 efekti
172000 efekti biitillä
185000 efekti
199000 efekti
225000 loppuefekti
245000 loppu
*/
				const int t0[] = {0, 29000};
				const int t1[] = {27000, 40000};
				const int t2[] = {40000, 66000};
				const int t3[] = {66000, 94000};
				const int t4[] = {93000, 106000};
				const int t5[] = {105000, 120000};
				const int t6[] = {119000, 132000};
				const int t7[] = {132000, 145000};
				const int t8[] = {145000, 159000};
				const int t9[] = {159000, 172000};
				const int t10[] = {171000, 199000};
				const int t11[] = {198500, 225000};
				const int t12[] = {225000, 244000};

				if (testaaPos(aika, t0))
					alku(laskePos(aika, t0));
				if (testaaPos(aika, t1))
					platon(laskePos(aika, t1));
				if (testaaPos(aika, t2))
					pot2d(laskePos(aika, t2));
				if (testaaPos(aika, t3))
					newton(laskePos(aika, t3));
				if (testaaPos(aika, t4))
					lorentz(laskePos(aika, t4));
				if (testaaPos(aika, t5))
					rossler(laskePos(aika, t5));
				if (testaaPos(aika, t6))
					dla(laskePos(aika, t6));
				if (testaaPos(aika, t7))
					cell(laskePos(aika, t7));
				if (testaaPos(aika, t8))
					curves(laskePos(aika, t8));
				if (testaaPos(aika,t9))
					converge(laskePos(aika, t9));
				if (testaaPos(aika, t10))
					fibotree(laskePos(aika, t10));
				if (testaaPos(aika,t11))
					iterator(laskePos(aika, t11));
				if (testaaPos(aika,t12))
					field(laskePos(aika, t12));
	#endif

				if (debugflag)
				{
					glDisable(GL_TEXTURE_2D);
					glDisable(GL_BLEND);
					glColor3f(0,0,0);
					char str[256];
					sprintf(str, "aika = %d", aika);

					glLoadIdentity();
					glDisable(GL_DEPTH_TEST);
					glTranslatef(0, 0, -5.0f);
					font_write(-2.7f, 1.45f, str);

					if (musicflag)
					{
/*						sprintf(str, "order = %x", sound.getOrder());
						debugprint(str, 1);
						sprintf(str, "row = %x", sound.getRow());
						debugprint(str, 2);*/
					}
				}


				SDL_GL_SwapBuffers();

				if (aika >= introloppu)
					done = true;

			}
		}

		//efektien vapautus
		alku_free();
		platon_free();
		pot2d_free();
		newton_free();
		lorentz_free();
		rossler_free();
		fibotree_free();
		converge_free();
		field_free();
		cell_free();
		curves_free();
		iterator_free();
		dla_free();

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
 
