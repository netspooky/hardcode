#include "main.h"
#include "ogl.h"
#include "mygl.h"
#include "water.h"
#include "font.h"

static char strMJ[] = "moOjUiCE\0presents\0SPLASH\0end\0";

	f32 tz;
	u32 timer;
	char bindc;
	int watermode;
	int fontmode;
	char *text;
	int x,y,i;
	float f;
	f32 sx,sy,sz;
	f32 colrgb;
	float rotate;
	i16 freq;
	f32 tzz;
	f32 fcol;

enum
{
	WDRAW		=	0x01,
	WUPDATE		=	0x02,
	WHIT		=	0x04,
	WLIGHT		=	0x08,
	WBLEND      =	0x10,
	WENV		=	0x20,
	WENVLINEAR	=	0x40,
};
enum
{
	FDRAW		=	0x01,
};

void draw2(void)
{
	u32 mmode;
	
		glDisable(GL_TEXTURE_2D);
		glDisable(GL_DEPTH_TEST);
		glMatrixMode(GL_MODELVIEW); 
		glLoadIdentity();
		glTranslatef(0,0,tz);
		glRotatef(rotate*0.1,1,1,1);
		glRotatef(90,1,rotate,0);
		glScalef(sx,sy,sz);
		
		bindChar(bindc);
		glDisable(GL_LIGHTING);
		glDisable(GL_BLEND);
		glDisable(GL_TEXTURE_GEN_S);
		glDisable(GL_TEXTURE_GEN_T);

		if (watermode&WLIGHT)
			glEnable(GL_LIGHTING);
		if (watermode&WBLEND)
			glEnable(GL_BLEND);
		if (watermode&WENV)
		{
			glEnable(GL_TEXTURE_GEN_S);
			glEnable(GL_TEXTURE_GEN_T);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_REPEAT);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_REPEAT);
			glEnable(GL_TEXTURE_2D);
		}
		mmode=GL_SPHERE_MAP;
		if (watermode&WENVLINEAR)
		{
			mmode=GL_EYE_LINEAR;
		}
		glTexGeni(GL_S, GL_TEXTURE_GEN_MODE,mmode);
		glTexGeni(GL_T, GL_TEXTURE_GEN_MODE,mmode);


		if (watermode&WDRAW)
			drawWater();

		if (watermode&WHIT)
		{
			if (rand()>freq)
				hitWater();
		}
		if (watermode&WUPDATE)
		{
			updateWater();
		}

		if (fontmode&FDRAW)
		{
		glDisable(GL_LIGHTING);
		glDisable(GL_TEXTURE_GEN_S);
		glDisable(GL_TEXTURE_GEN_T);
		glColor4f(fcol,fcol,fcol,1);
		glMatrixMode(GL_MODELVIEW); 
		glLoadIdentity();
		glTranslatef(0,0,-tzz);
		printFont(text,0.0f);
		}

}

void tile1(void)
{
	watermode=WDRAW|/*WUPDATE|WHIT|*/WLIGHT|WBLEND|WENV|WENVLINEAR;
	tz=-5.1;
	draw2();
}

MSG msg;									// Windows Message Structure

int WINAPI WinMainCRTStartup(void)
{
	if (!initGL())
		return 0;

	initFont();
	initWater();

	tz=-3;
	timer=0;
	bindc='.';
	watermode=0;
	fontmode=0;
	text=strMJ;
	f=0;
	rotate=0.0f;
	sx=15.0f;
	sy=0.1;
	sz=15.0f;
	watermode=1|2|4|8|16|32|64|256;
	fontmode=0;
	freq=30000;
	tzz=2.4;
	fcol=0.0f;

	while (!demoFinished)
	{
		glClearColor(colrgb,colrgb,colrgb,1.0);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

		if (timer<100*4)
		{
			bindc='o';
			colrgb=1.0f;
			sx=190.0f;
			sy=10.0f;
			sz=190.0f;
			glBlendFunc(GL_SRC_COLOR,GL_ONE_MINUS_SRC_COLOR);
			tile1();
		}
		else
		if (timer<100*8)
		{
		fontmode=FDRAW;
		text=strMJ;
		tile1();
		//rotate+=15;
		glBlendFunc(GL_SRC_COLOR,GL_ONE_MINUS_SRC_COLOR);
		//draw2();
		}
		else
		if (timer<100*12)
		{
		fontmode=FDRAW;
		//fontmode=FDRAW;
		//watermode=WDRAW|WUPDATE|WHIT|WBLEND|WENV|WENVLINEAR;
		bindc='+';
		text=strMJ+9;
		//rotate+=15;
		tzz=3;
		glBlendFunc(GL_SRC_COLOR,GL_ONE_MINUS_SRC_COLOR);
		//draw2();
		tile1();
		}
		else
		if (timer<100*20)
		{
		fontmode=FDRAW;
		colrgb=0.0f;
		watermode=WDRAW|WUPDATE|WHIT|WLIGHT|WBLEND;
		//glTranslatef(0,0,tz);
		//glRotatef(rotate*0.1,0,1,1);
		//glRotatef(40,1,0,0);
		tz=-5.1;
		sx=14.0f;
		sy=6.0f;
		sz=14.0f;
		//rotate+=15;
		freq=20000;
		text=strMJ+18;
		fcol=1.0f;
		tzz=2;
		//glBlendFunc(GL_SRC_COLOR,GL_ONE_MINUS_SRC_COLOR);
		glBlendFunc(GL_ONE,GL_ONE);
		draw2();
		}
		else
		if (timer<100*24)
		{
			fontmode=0;
			colrgb=0.0f;
			glBlendFunc(GL_ONE,GL_ONE);
			sy=190;
			tile1();
		}
		else
		if (timer<100*28)
		{
			fontmode=0;
			colrgb=01.0f;
			glBlendFunc(GL_SRC_COLOR,GL_ONE_MINUS_SRC_COLOR);
			tile1();
		}
		else
		{
		colrgb=1.0f;
		watermode=WDRAW|WUPDATE|WHIT|WLIGHT|WBLEND;
		//glTranslatef(0,0,tz);
		tz=-5.1;
		sx=10.0f;
		sy=4.0f;
		sz=1.0f;
		//rotate+=15;
		freq=20000;
		fcol=0.0f;
		glBlendFunc(GL_SRC_COLOR,GL_ONE_MINUS_SRC_COLOR);
		draw2();
		}

		if (timer>100*32)
		{
			fontmode=FDRAW;
			text=strMJ+25;
		}
		
		wglMakeCurrent(hDC,hRC);
		SwapBuffers(hDC);
		if (PeekMessage(&msg,NULL,0,0,PM_REMOVE))
		{
			if ( (msg.message==WM_KEYDOWN) )
			{
				demoFinished=1;
			}
			else
			{
				TranslateMessage(&msg);
				DispatchMessage(&msg);
			}
		}

		rotate+=15;
		f+=0.02f;
		timer++;
	}

	deinitFont();
	deinitWater();
	deinitGL();
	return 0;
}
