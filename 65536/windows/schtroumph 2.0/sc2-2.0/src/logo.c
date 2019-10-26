/* Schtroumpf - the intro - (c) 2004 Gautier Portet < kassoulet @ no-log . org >
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include "introsystem.h"

static RLEBitmap *rleLogo=&bmp_knights;
static Surface *bmpLogo, *bmpLogoR, *bmpLogoG, *bmpLogoB;
static GLuint texLogo,texLogoR,texLogoG,texLogoB;

static Surface	*bmpNoise;
static GLuint  	texNoise;

int boom=0;
int oldPos;

static void ExtractRGB()
{
	int i;
	Uint32 *p,*pR,*pG,*pB;
	
	bmpLogoR = CreateSurface(bmpLogo->width, bmpLogo->height, 4);
	bmpLogoG = CreateSurface(bmpLogo->width, bmpLogo->height, 4);
	bmpLogoB = CreateSurface(bmpLogo->width, bmpLogo->height, 4);
	
	p  = (Uint32*) bmpLogo->pixels;
	pR = (Uint32*) bmpLogoR->pixels;
	pG = (Uint32*) bmpLogoG->pixels;
	pB = (Uint32*) bmpLogoB->pixels;
	
	for(i=0; i< bmpLogo->width*bmpLogo->height; i++) {
		Uint32 pixel;
		pixel = *p++;
		*pR++ = pixel & 0xff0000ff;
		*pG++ = pixel & 0xff00ff00;
		*pB++ = pixel & 0xffff0000;
	}
}

static void partLogo_Open()
{
	bmpLogo = LoadRLEBitmap(rleLogo);
	ExtractRGB();
	texLogo = CreateTexture(256,128);
	texLogoR = CreateTexture(256,128);
	texLogoG = CreateTexture(256,128);
	texLogoB = CreateTexture(256,128);

        glBindTexture(GL_TEXTURE_2D, texLogo);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	UploadTexture(texLogo,bmpLogo);

        glBindTexture(GL_TEXTURE_2D, texLogoR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	UploadTexture(texLogoR,bmpLogoR);

        glBindTexture(GL_TEXTURE_2D, texLogoG);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	UploadTexture(texLogoG,bmpLogoG);

        glBindTexture(GL_TEXTURE_2D, texLogoB);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	UploadTexture(texLogoB,bmpLogoB);
	
	bmpNoise = LoadBMP("pandora/logo.bmp");
	if (!bmpNoise) {
		bmpNoise = CreateSurface(512,512,1);
		FillNoise(bmpNoise, 4, 0.8, 5.0/256, 10,20,18);
		Threshold(bmpNoise, 128, 10, 192, 255);
		SaveBMP(bmpNoise,"pandora/logo.bmp");
	}
	texNoise = CreateTexture(512,512);
	UploadTextureLuminance(texNoise, bmpNoise);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
}

static void partLogo_Close()
{
	FreeTexture(texLogo);
	FreeTexture(texLogoB);
	FreeTexture(texLogoG);
	FreeTexture(texLogoR);
	FreeTexture(texNoise);
	FreeSurface(bmpLogo);
	FreeSurface(bmpLogoB);
	FreeSurface(bmpLogoG);
	FreeSurface(bmpLogoR);
	FreeSurface(bmpNoise);
}

static void DrawBlur(float angle, float power, int radial, int precision)
{
	float px,py,vx,vy;
	float ax,ay;
	float w,h;
	int i;
	float alpha;
	
	w = bmpLogo->width*2;
	h = bmpLogo->height*2;
	
	if (radial) {
		vx = 0;
		vy = 0;
		
		px = -w/2;
		py = -h/2;
	} else {
		ax = cos(angle);
		ay = sin(angle);
		
		vx = ax * power/(float)precision;
		vy = ay * power/(float)precision;
		
		px = -w/2-precision/2*vx;
		py = -h/2-precision/2*vy;
	}
	
	alpha = CLAMP(1.0/(float)precision,0.,1.);
        glColor4f(1,1,1,alpha);
	
	for(i=0; i<precision; i++){
		
                glLoadIdentity();
                glTranslatef(1024/2,768/2,0);
		if (radial) {
			glRotatef(angle*(i-precision/2)/(float)precision,0,0,1);
		}
		
		glBegin(GL_TRIANGLE_STRIP);
		glTexCoord2f(0, 0); glVertex2f(px,   py  );
		glTexCoord2f(1, 0); glVertex2f(px+w, py  );
		glTexCoord2f(0, 1); glVertex2f(px,   py+h);
		glTexCoord2f(1, 1); glVertex2f(px+w, py+h);
		glEnd();
		
		px += vx;
		py += vy;
	}
}

static void partLogo_Draw(double time, double delta, int position)
{
	static float alpha=0;
	static float zoom=1;

	Mode2D();
	
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);

	glTranslatef(512,384,0);

        glBindTexture(GL_TEXTURE_2D, texNoise);
	glBegin(GL_TRIANGLE_STRIP);
	glColor4f(0.1,0.2,0.3,1);
	
	glTexCoord2f(0,0); 	glVertex2i(-512,   	-512  );
	glTexCoord2f(1,0); 	glVertex2i(512, 	-512  );
	glTexCoord2f(0,1); 	glVertex2i(-512,   	512);
	glTexCoord2f(1,1);	glVertex2i(512, 	512);
	
	glEnd();
	
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

        glBindTexture(GL_TEXTURE_2D, texLogo);
        glMatrixMode(GL_MODELVIEW);
	
	if (position != oldPos) {
		/* new module row */
		switch (position&0x0f) {
			case 0x00:
			case 0x01:
			case 0x04:
			case 0x05:
			case 0x08:
				alpha=1.0;
				break;
			case 0x09:
				alpha=2.0;
		}
		if ( ( (position&0xff)>=0x2d ) && ( (position&0xff)<=0x40 ) ) {
			alpha=1.0;
			zoom+=0.1f;
		}
	} else {
		alpha-=0.1*delta;
		if (alpha<0) {
			alpha=0;
		}
	}
	oldPos = position;
	{
		float a = alpha;
		CLAMP(a,0,1);
		if ( ( (position&0xff)>=0x2d ) && ( (position&0xff)<=0x34 ) || 
		((position&0xf0) == 0x00) ) {
			int x,y,w,h;
			
			x = -256;
			y = -128;
			w = 512;
			h = 256;
			glLoadIdentity();
			glTranslatef(1024/2,768/2,0);
			glScalef(zoom,zoom,0);
			glBindTexture(GL_TEXTURE_2D, texLogo);
			glBegin(GL_TRIANGLE_STRIP);
			glColor4f(1,1,1,a);
			glTexCoord2f(0, 0); glVertex2i(x,   y  );
			glTexCoord2f(1, 0); glVertex2i(x+w, y  );
			glTexCoord2f(0, 1); glVertex2i(x,   y+h);
			glTexCoord2f(1, 1); glVertex2i(x+w, y+h);
			glEnd();
		} else 
		if ( (position&0xf0) == 0x10) {
			glBindTexture(GL_TEXTURE_2D, texLogo);
			DrawBlur( ticks*0.001 , Sine(0, a*200, 400, 0), 0, 32);
		} else
		if ( (position&0xf0) == 0x20) {
		        glBlendFunc(GL_ONE, GL_ONE);
			glBindTexture(GL_TEXTURE_2D, texLogoR);
			DrawBlur( ticks*0.001 , Sine(0, a*200, 800, 0), 0, 24);
			glBindTexture(GL_TEXTURE_2D, texLogoG);
			DrawBlur( ticks*0.002 , Sine(0, a*200, 600, 300), 0, 24);
			glBindTexture(GL_TEXTURE_2D, texLogoB);
			DrawBlur( ticks*0.003 , Sine(0, a*100, 400, 600), 0, 16);
		}
	        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glMatrixMode(GL_TEXTURE);
        glLoadIdentity();
}

DemoPart partLogo = {0x0000, 0x0200, partLogo_Draw, partLogo_Open, partLogo_Close};
