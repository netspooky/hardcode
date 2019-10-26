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

static RLEBitmap 	*rleBack=&bmp_coquet;
static Surface		*bmpBack;
static Surface		*bmpBuffer;
static GLuint  		texBack;

static Surface		*bmpNoise;
static GLuint  		texNoise;

static RLEBitmap 	*rleTitle=&bmp_title;
static Surface		*bmpTitle;
static GLuint  		texTitle;

#define NOISE_SIZE 1024

static Surface *noise1;
static Surface *noise2;

static float deformPower=0;

static double localTimer=0;

void Deform(int dx1, int dy1, int dx2, int dy2, int power)
{
	int x,y,i;
	Surface *surface;
	int mulTable[256];
	
	for(i=0; i<256; i++) {
		mulTable[i] = (i-128)*power/256;
	}

	surface = bmpBuffer;
	for(y=0; y<384; y++) {
		
		Uint32 *dst = (Uint32*)(surface->pixels+y*surface->width*4);
		Uint32 *src = (Uint32*)(bmpBack->pixels);
		Uint8 *src1 = (Uint8*)(noise1->pixels+((y+dy1) )*noise1->width);
		Uint8 *src2 = (Uint8*)(noise2->pixels+((y+dy2) )*noise2->width);

		src1+=dx1;
		src2+=dx2;
		
		for(x=0; x<512; x++) {
			int ddx,ddy;
		
			ddx = mulTable[*src1++];
			ddy = mulTable[*src2++];
			
			*dst &= 0xfefefefe;
			*dst >>= 1;
			*dst += ((src[ ((y+ddy)*512+ddx)&0x3ffff ])&0xfefefefe)>>1;
			
			dst++;
			src++;
		}
	}
}


static void partNoise_Open()
{
	Surface * tmp;
	Surface * tmp2;
	tmp  = LoadRLEBitmap(rleBack);
	tmp2 = Scale4x(tmp);
	bmpBack = AntiAlias(tmp2);
	FreeSurface(tmp);
	FreeSurface(tmp2);
	
	texBack = CreateTexture(512,512);

        glBindTexture(GL_TEXTURE_2D, texBack);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	UploadTextureSub(texBack, bmpBack, 0,0);
        bmpBuffer = CreateSurface(512,384,4);

	tmp  = LoadRLEBitmap(rleTitle);
	tmp2 = Scale8x(tmp);
	bmpTitle = AntiAlias(tmp2);
	FreeSurface(tmp);
	FreeSurface(tmp2);

	AddShadow(bmpTitle,4,4);

	texTitle = CreateTexture(1024,256);

        glBindTexture(GL_TEXTURE_2D, texTitle);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	UploadTextureSub(texTitle, bmpTitle, 0,0);

	bmpNoise = LoadBMP("pandora/noise.bmp");
	if (!bmpNoise) {
		bmpNoise = CreateSurface(512,512,1);
		FillNoise(bmpNoise, 4, 0.8, 10.0/256, 10,20,8);
		Threshold(bmpNoise, 128, 10, 192, 255);
		SaveBMP(bmpNoise,"pandora/noise.bmp");
	}
	
	texNoise = CreateTexture(512,512);
	UploadTextureLuminance(texNoise, bmpNoise);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	noise1 = LoadBMP("pandora/noise1.bmp");
	if (!noise1) {
		noise1 = CreateSurface(NOISE_SIZE,NOISE_SIZE,1);
		FillNoise(noise1, 1, 1, 2.0/256, 40,30,18);
		SaveBMP(noise1,"pandora/noise1.bmp");
	}
	
	noise2 = noise1;
}

static void partNoise_Close()
{
	FreeTexture(texBack);
	FreeTexture(texNoise);
	FreeTexture(texTitle);
	FreeSurface(bmpBack);
	FreeSurface(bmpBuffer);
	FreeSurface(bmpNoise);
	FreeSurface(bmpTitle);
	FreeSurface(noise1);
}

float intro=0;

static void partNoise_Draw(double time, double delta, int position)
{
	int peak=0;
	
	localTimer += delta;
	
	switch (position&255) {
		case 0x04:
		case 0x0c:
		case 0x14:
		case 0x1c:
		case 0x1f:
		case 0x24:
		case 0x2b:
		case 0x2c:
		case 0x34:
		case 0x3c:
		case 0x3f:
			if (position>=0x0200) {
				localTimer+=delta*5.0;
				peak=1;
			}
	}

	if (position<0x0200) {
		intro+=delta*0.02f;
		intro=CLAMP(intro,0.0f,1.0f);
	} else {
		intro=1.0f;
	}

	
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);

        Mode2D();

        glEnable(GL_TEXTURE_2D);

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

	glTranslatef(512,384,0);
	
	if (peak) {
		glScalef(1.01,1.01,1);
	}
	
        glBindTexture(GL_TEXTURE_2D, texNoise);
	glBegin(GL_TRIANGLE_STRIP);
	if (peak) {
		glColor4f(0.9,0.8,0.6,1);
	} else {
		if (position<0x0200) {
			glColor4f(0.8,0.6,0.5,intro);
		} else {
			glColor4f(0.8,0.6,0.5,1);
		}
	}
	
	glTexCoord2f(0,0); 	glVertex2i(-512,   	-512  );
	glTexCoord2f(1,0); 	glVertex2i(512, 	-512  );
	glTexCoord2f(0,1); 	glVertex2i(-512,   	512);
	glTexCoord2f(1,1);	glVertex2i(512, 	512);
	
	glEnd();

	/**********************************************/

	deformPower += delta;
	deformPower = CLAMP(deformPower,0,512);
	
	Deform(
		SineEx(localTimer,0,(NOISE_SIZE-512),20000,1254),
		SineEx(localTimer,0,(NOISE_SIZE-512),30000,8547),
		SineEx(localTimer,0,(NOISE_SIZE-512),19000,6554),
		SineEx(localTimer,0,(NOISE_SIZE-512),25000,3584),
		deformPower
		);	
		
	UploadTextureSub(texBack, bmpBuffer, 0,0);

	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER,0.2);

        glBindTexture(GL_TEXTURE_2D, texBack);

	glLoadIdentity();
	glTranslatef(512,384,0);
	glScalef(Sine(1,1.2,10000,0),Sine(1,1.2,10000,5000),1);
	
	glBegin(GL_TRIANGLE_STRIP);
	glColor4f(1,1,1,intro);
	
	glTexCoord2f(0,0); 	glVertex2i(-512,   	-384  );
	glTexCoord2f(1,0); 	glVertex2i(512, 	-384  );
	glTexCoord2f(0,0.75); 	glVertex2i(-512,   	384);
	glTexCoord2f(1,0.75);	glVertex2i(512, 	384);
	
	glEnd();


	if (position>=0x0200) {

		glBindTexture(GL_TEXTURE_2D, texTitle);
		
		glLoadIdentity();
		glTranslatef(512,384,0);
	
		glScalef(Sine(0.9,1,1000,0),Sine(0.9,1,1000,500),1);
		glRotatef(Sine(-1,1,5000,0),0,0,1);


		glBegin(GL_TRIANGLE_STRIP);
		glColor4f(1,1,1,intro);
		
		glTexCoord2f(0,0); 	glVertex2i(-512,   	-128  );
		glTexCoord2f(1,0); 	glVertex2i(512, 	-128  );
		glTexCoord2f(0,1); 	glVertex2i(-512,   	128);
		glTexCoord2f(1,1);	glVertex2i(512, 	128);
		
		glEnd();
	}	
	glDisable(GL_ALPHA_TEST);
}

DemoPart partNoise = {0x0134, 0x0400, partNoise_Draw, partNoise_Open, partNoise_Close};

