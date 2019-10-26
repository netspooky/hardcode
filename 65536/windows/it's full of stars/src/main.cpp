#include <stdio.h>

#include "stuff.hpp"
#include "misc.hpp"
#include "win32.hpp"
#include "sound.hpp"
#include "font.hpp"
#include "texture.hpp"
#include "timer.hpp"

#include "Effects/alku.hpp"
#include "Effects/kaupunki.hpp"
#include "Effects/dla.hpp"
#include "Effects/maailma.hpp"
#include "Effects/synty.hpp"
#include "Effects/lento.hpp"
#include "Effects/universumi.hpp"
#include "Effects/kasvi.hpp"
#include "Effects/valo.hpp"
#include "Effects/hila.hpp"
#include "Effects/tunneli.hpp"
#include "Effects/loppu.hpp"

Window win;
int OPENGL_XRES=WINDOW_WIDTH;
int OPENGL_YRES=WINDOW_HEIGHT;
bool OPENGL_FULLSCREEN;

Vector clearcolor;

Texture *flare;
Texture *flare2;

Texture *render0;
Texture *render1;
Texture *render2;
Texture *render512_0;

Timer kello;
Sound sound;

bool runflag=true;
bool musicflag=true;
bool debugflag = false;
bool glowflag = false;

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

		clearcolor = Vector(0, 0, 0);
		glClearColor(clearcolor.x, clearcolor.y, clearcolor.z, 1);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glViewport(0, 0, OPENGL_XRES, OPENGL_YRES);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(45.0f, OPENGL_XRES/(float)OPENGL_YRES, 0.01f, 1000.0f);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);

		glColor3f(1,0,0);
		font_write(-0.9f, -0.9f, "please wait...");
		SDL_GL_SwapBuffers();

		alku_init();
		kaupunki_init();
		dla_init();
		maailma_init();
		synty_init();
		lento_init();
		universumi_init();
		kasvi_init();
		valo_init();
		hila_init();
		tunneli_init();
		loppu_init();
		

		
#define COMPLETEINTRO 
//	#ifdef COMPLETEINTRO
		if (musicflag==true)
			sound.play();
//	#endif

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
						default:
							break;
					}
				default:
					break;
			}
//			else
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

/*				float kerroin = 1.0f;
				if (GetAsyncKeyState(VK_SHIFT))
					kerroin = 18.0f;

				if (GetAsyncKeyState(VK_RIGHT))
					kello.add(0.05f*kerroin);
				if (GetAsyncKeyState(VK_LEFT))
					kello.add(-0.05f*kerroin);
				if (GetAsyncKeyState(VK_SPACE))
					debugflag^=1;*/

				glMatrixMode(GL_PROJECTION);
				glLoadIdentity();
				gluPerspective(45.0f, OPENGL_XRES/(float)OPENGL_YRES, 0.01f, 1000.0f);
				glMatrixMode(GL_MODELVIEW);
				glLoadIdentity();
				const int introloppu = 298000;
				kello.update();
				int aika = (int)kello.getMilliseconds();

	#ifndef COMPLETEINTRO
				const int testiaika[] = {0, 30000};

				if (testaaPos(aika, testiaika))
					tunneli(laskePos(aika, testiaika));
	#else
				const int t0[] = {0, 29000};
				const int t1[] = {27000, 56000};
				const int t2[] = {54000, 84000};
				const int t3[] = {82000, 112000};
				const int t4[] = {111000, 148000};
				const int t5[] = {146000, 176000};
				const int t6[] = {174000, 204000};
				const int t7[] = {202000, 232000};
				const int t8[] = {223200, 242000};
				const int t9[] = {233000, 260000};
				const int t10[] = {257000, 285000};
				const int t11[] = {283000, 298000};

				if (glowflag)
				{
					glViewport(0, 0, 512, 512);
				}
				if (testaaPos(aika, t0))
					alku(laskePos(aika, t0));
				if (testaaPos(aika, t1))
					synty(laskePos(aika, t1));
				if (testaaPos(aika, t2))
					dla(laskePos(aika, t2));
				if (testaaPos(aika, t3))
					kaupunki(laskePos(aika, t3));
				if (testaaPos(aika, t4))
					maailma(laskePos(aika, t4));
				if (testaaPos(aika, t5))
					lento(laskePos(aika, t5));
				if (testaaPos(aika, t6))
					universumi(laskePos(aika, t6));
				if (testaaPos(aika, t7))
					kasvi(laskePos(aika, t7));
				if (testaaPos(aika, t8))
					valo(laskePos(aika, t8));
				if (testaaPos(aika, t9))
					hila(laskePos(aika, t9));
				if (testaaPos(aika, t10))
					tunneli(laskePos(aika, t10));
				if (testaaPos(aika, t11))
					loppu(laskePos(aika, t11));

				if (glowflag)
				{

					glEnable(GL_TEXTURE_2D);
					glBindTexture(GL_TEXTURE_2D, render0->ID);
					glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, 512, 512, 0);
					glBindTexture(GL_TEXTURE_2D, render2->ID); //alkup. talteen
					glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, 512, 512, 0);

					glDisable(GL_DEPTH_TEST);
				//	myDisable(MY_DEPTH_MASK); //<--- miksi tästä tulee kummallinen bugitus?
					perspective2D(1,1);

					glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
					Texture *render1;
					Texture *render2;
					
					glEnable(GL_BLEND);
					glBlendFunc(GL_SRC_ALPHA, GL_ONE);
					
					float blendalpha = 0.20f;
					const float zoom = 0.001f;//+sync*sync*0.10f;//5f;
					const float radiusmod = 0.0025f;
					const int count = 10;

					for (int i=0;i<count;i++)
					{
						const float kohta = i / (float)count;
						const float radius = i * radiusmod;
						//piirrettävän tekstuurin paikan muutokset
						const float xdisplace = radius*(float)sin(kohta*4*3.141592f);
						const float ydisplace = radius*(float)cos(kohta*4*3.141592f);
        
						//zoomataan hieman, muuten näyttää rumalta
        
						if (!(i%2))
						{
								render1 = render0;
								render2 = render1;
						}
						else
						{
								render1 = render1;
								render2 = render0;
						}

						glBindTexture(GL_TEXTURE_2D, render1->ID);
						glBegin(GL_QUADS);
						glColor4f(1, 1, 1, blendalpha);
						glTexCoord2f(zoom, zoom);
						glVertex2f(xdisplace, ydisplace);
						glTexCoord2f(1-zoom, zoom);
						glVertex2f(1+xdisplace, ydisplace);
						glTexCoord2f(1-zoom, 1-zoom);
						glVertex2f(1+xdisplace, 1+ydisplace); //, 1);
						glTexCoord2f(zoom, 1-zoom);
						glVertex2f(xdisplace, 1+ydisplace);
						glEnd();

						glBindTexture(GL_TEXTURE_2D, render2->ID);
						glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, 512, 512, 0);
					}
					glDisable(GL_BLEND);

					glViewport(0, 0, OPENGL_XRES, OPENGL_YRES);//(), dmsGetWindowHeight());
					glColor3f(1,1,1);
					glBindTexture(GL_TEXTURE_2D, render2->ID);
					glBegin(GL_QUADS);
					glColor4f(1,1,1,1);
					glTexCoord2f(0, 0);
					glVertex2f(0, 0);
					glTexCoord2f(1, 0);
					glVertex2f(1, 0);
					glTexCoord2f(1, 1);
					glVertex2f(1, 1);
					glTexCoord2f(0, 1);
					glVertex2f(0, 1);
					glEnd();
					glEnable(GL_BLEND);

					glColor4f(1,1,1,1);
					glBindTexture(GL_TEXTURE_2D, render2->ID);
					glBegin(GL_QUADS);
					glColor4f(1,1,1,1);
					glTexCoord2f(0, 0);
					glVertex2f(0, 0);
					glTexCoord2f(1, 0);
					glVertex2f(1, 0);
					glTexCoord2f(1, 1);
					glVertex2f(1, 1);
					glTexCoord2f(0, 1);
					glVertex2f(0, 1);
					glEnd();
					perspective3D();
				}

	#endif
				if (debugflag)
				{
					glDisable(GL_TEXTURE_2D);
					glDisable(GL_BLEND);
					glColor4f(1,1,1,1);
					char str[256];
					sprintf(str, "aika = %d", aika);

					glLoadIdentity();
					glDisable(GL_DEPTH_TEST);
					glTranslatef(0, 0, -5.0f);
					font_write(-2.7f, 1.45f, str);

					if (musicflag)
					{
						glColor4f(1,1,1,1);
						sprintf(str, "order = %x", sound.getOrder());
						debugprint(str, 1);
						sprintf(str, "row = %x", sound.getRow());
						debugprint(str, 2);
					}
				}

				SDL_GL_SwapBuffers();

				if (aika >= introloppu)
					done = true;

			}
		}

		//efektien vapautus
		alku_free();
		kaupunki_free();
		dla_free();
		maailma_free();
		synty_free();
		lento_free();
		universumi_free();
		kasvi_free();
		valo_free();
		hila_free();
		tunneli_free();
		loppu_free();

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
 
