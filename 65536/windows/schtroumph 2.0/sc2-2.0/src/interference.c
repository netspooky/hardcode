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

//#define BLUR_STEPS 7
#define BLUR_STEPS 8

static RLEBitmap 	*rleGrognon=&bmp_grognon;
static Surface		*bmpGrognon;
static GLuint  		texGrognon;
static GLuint  		texBlur[BLUR_STEPS];

static Surface		*bmpNoise;
static GLuint  		texNoise;

extern GLuint  		texGargamel;

void DrawRays(float px, float py, float radius, int number, float angle, Color* color)
{
        int i;

        Mode2D();

        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        glEnable(GL_BLEND);

        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);

        glDisable(GL_TEXTURE_2D);

        for(i=0;i<number;i++) {
                Point p[2];

                p[0].x = radius * cos((2*i)*2.0f*3.1415927f/(number*2)),
                p[0].y = radius * sin((2*i)*2.0f*3.1415927f/(number*2)),

                p[1].x = radius * cos((2*i+1)*2.0f*3.1415927f/(number*2)),
                p[1].y = radius * sin((2*i+1)*2.0f*3.1415927f/(number*2)),

                glLoadIdentity();
                glTranslatef(px,py,0);
                glRotatef(angle,0,0,1);

                glBegin(GL_TRIANGLES);
                glColor4f(color->r/255.0f, color->g/255.0f, color->b/255.0f, color->a/255.0f);
                glVertex2i(0,0);
                glColor4f(color->r/255.0f, color->g/255.0f, color->b/255.0f, 0);
                glVertex2f(p[0].x,p[0].y);
                glVertex2f(p[1].x,p[1].y);
                glEnd();
        }
}

static void DrawKaleido(int zoom, int angle, int number, Color* color)
{
	int i;

        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        glEnable(GL_BLEND);

        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);

        glDisable(GL_TEXTURE_2D);

	for(i=0; i<number; i++) {
                glLoadIdentity();
                glTranslatef(512+192,384,0);
                glRotatef(angle+i*360.0/number,0,0,1);

                glBegin(GL_TRIANGLES);
                glColor4f(color->r/255.0f, color->g/255.0f, color->b/255.0f, color->a/255.0f);
                glVertex2f(zoom*Sine(-1,1,5000,2124)*Sine(-1,1,4000,241), 
			   zoom*Sine(-1,1,3000,2258)*Sine(-1,1,5000,224));
                glVertex2f(zoom*Sine(-1,1,4000,6584)*Sine(-1,1,6000,985), 
			   zoom*Sine(-1,1,7000,2568)*Sine(-1,1,3000,654));
                glVertex2f(zoom*Sine(-1,1,3000,3578)*Sine(-1,1,4000,198), 
			   zoom*Sine(-1,1,6000,1568)*Sine(-1,1,5000,765));
//                glColor4f(color->r/255.0f, color->g/255.0f, color->b/255.0f, 0);
                glEnd();
	}
	
}

static float rubberAlpha=0;
static float kaleidoAlpha=0;
static float interferenceAlpha=0;
static float fadeout=0;

static float ltimer=0;

static void partInterference_Draw(double time, double delta, int position)
{
	int i;
	int peak=0;
	Color color={255,255,255,128};
	float z;

	ltimer += delta;	
	switch (position&255) {
		case 0x04:
		case 0x0c:
		case 0x0e:
		case 0x14:
		case 0x1c:
		case 0x1f:
		case 0x24:
		case 0x2c:
		case 0x34:
		case 0x38:
		case 0x3c:
		case 0x3e:
		case 0x3f:
			ltimer+=3.0*delta;
			peak=1;
	}
	
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);

        glEnable(GL_TEXTURE_2D);

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

	glLoadIdentity();
	glTranslatef(512,384,0);

        glBindTexture(GL_TEXTURE_2D, texNoise);
	glBegin(GL_TRIANGLE_STRIP);
	glColor4f(0.8,0.6,0.5,interferenceAlpha);
	
	glTexCoord2f(0,0); 	glVertex2i(-512,   	-512  );
	glTexCoord2f(1,0); 	glVertex2i(512, 	-512  );
	glTexCoord2f(0,1); 	glVertex2i(-512,   	512);
	glTexCoord2f(1,1);	glVertex2i(512, 	512);
	
	glEnd();


	if (position>0x1034) {
		
		if (position<0x1038) {
			return;
		}
		
		fadeout+=delta*0.005;
		fadeout=CLAMP(fadeout,0,1);
		
		/* Gargamel Sprite */
		glBindTexture(GL_TEXTURE_2D, texGargamel);
	
		glLoadIdentity();
		glTranslatef(512+256,384,0);
		
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.1);
	
		glBegin(GL_TRIANGLE_STRIP);
		glColor4f(1,1,1,1);
		
		glTexCoord2f(0,0); 	glVertex2i(-512,   	-384  );
		glTexCoord2f(1,0); 	glVertex2i(512, 	-384  );
		glTexCoord2f(0,0.75); 	glVertex2i(-512,   	384);
		glTexCoord2f(1,0.75);	glVertex2i(512, 	384);
		
		glEnd();
		glDisable(GL_ALPHA_TEST);
		
		glDisable(GL_TEXTURE_2D);		
		
		glLoadIdentity();
		glTranslatef(512,384,0);
		
		glBegin(GL_TRIANGLE_STRIP);
		glColor4f(0,0,0,fadeout);
		
		glVertex2i(-512,   	-384  );
		glVertex2i(512, 	-384  );
		glVertex2i(-512,   	384);
		glVertex2i(512, 	384);
		
		glEnd();
		
		glEnable(GL_TEXTURE_2D);		
		
		return;
	}



	interferenceAlpha+=delta*0.01;
	interferenceAlpha=CLAMP(interferenceAlpha,0,0.5);
	color.a = interferenceAlpha*256.0;
	if (position<0x0c00) {
		z = Sine(200,500,4000,0);
		for(i=0; i<2; i++) {
			DrawRays(	512+z*Sine(-1,1,10000,i*500     )*Sine(-1,1,5000,i*150), 
					384+z*Sine(-1,1,10000,i*500+2500)*Sine(-1,1,5000,i*150+2500), 
					Sine(700,900,1000,0), 32, (time*(1.5-i))/124.0, &color);
		}
	} else
	if (position<0x0d00) {
		z = Sine(300,500,1000,0);
		for(i=0; i<3; i++) {
			DrawRays(	512+z*Sine(-1,1,10000,i*2500     )*Sine(-1,1,5000,i*250), 
					384+z*Sine(-1,1,10000,i*3500+2500)*Sine(-1,1,5000,i*250+250), 
					Sine(500,800,1000,0), peak?32:16, time/924.0, &color);
		}
	} else
	if (position<0x0e00) {
		for(i=0; i<4; i++) {
			z = Sine(100,500,4000,i*200);
			DrawRays(	512+z*Sine(-1,1,16000,i*4000     )*Sine(-1,1,10000,i*150), 
					384+z*Sine(-1,1,16000,i*4000+2000)*Sine(-1,1,10000,i*150+2500), 
					Sine(300,800,1000,0), 16, time*0.1f+30.0f*i, &color);
		}
	} else
	if (position<0x0f00) {
		for(i=0; i<8; i++) {
			z = Sine(-200,300,2800,i*100);
			DrawRays(	512+z*Sine(-1,1,16000,i*2194     ), 
					384+z*Sine(-1,1,16000,i*2123+4000), 
					Sine(200,300,5000,0), 24, time*i*5.0f, &color);
		}
	} else {
		z = Sine(200,500,4000,0);
		for(i=0; i<8; i++) {
			DrawRays(	512+z*Sine(-1,1,10000,i*500     )*Sine(-1,1,5000,i*250), 
					384+z*Sine(-1,1,10000,i*500+2500)*Sine(-1,1,5000,i*250+2500), 
					Sine(400,500,1000,0), 32, (time*(1.5-i))/124.0, &color);
		}
	}
	if (position>0x0f00) {
		Color color={0,0,0,64};
		//interferenceAlpha-=delta*0.02;
		kaleidoAlpha+=delta*0.02;
		kaleidoAlpha=CLAMP(kaleidoAlpha,0,0.1);
		color.a = kaleidoAlpha*256.0;
		DrawKaleido(peak?320:300,Sine(-90,90,15000,0),peak?32:16, &color);
	}
	
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER,0.05);
	
        glEnable(GL_TEXTURE_2D);
	glLoadIdentity();
	glTranslatef(512+192,384,0);

	if (peak) {
		glTranslatef(10-(rand()%20),10-(rand()%20),0);
	}
	
	glScalef(0.5,0.5,1);
	
        glBindTexture(GL_TEXTURE_2D, texGrognon);
	
	glBegin(GL_TRIANGLE_STRIP);
	glColor4f(1,1,1,0.7);
	glTexCoord2f(0,0); 	glVertex2i(-512,   	-512  );
	glTexCoord2f(1,0); 	glVertex2i(512, 	-512  );
	glTexCoord2f(0,1); 	glVertex2i(-512,   	512);
	glTexCoord2f(1,1);	glVertex2i(512, 	512);
	glEnd();


	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();		
	gluPerspective(45.0f,(GLfloat)ScreenWidth/(GLfloat)ScreenHeight,0.1f,100.0f);
	//Mode2D();

	glMatrixMode(GL_MODELVIEW);

        glEnable(GL_TEXTURE_2D);
	glLoadIdentity();

	if (position>=0x0c00) {
		rubberAlpha+=delta*0.01;
		rubberAlpha=CLAMP(rubberAlpha,0,0.9);
	}

	for(i=-15; i<15; i++) {
		int blur;
		blur = CLAMP(SineEx(ltimer,-BLUR_STEPS,BLUR_STEPS-1,2000,i*100),0,BLUR_STEPS-1);
	        glBindTexture(GL_TEXTURE_2D, texBlur[blur]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		
		glLoadIdentity();
		glTranslatef(-5+SineEx(ltimer,-0.5,0.5,3000,i*100),i*0.5+1.0*SineEx(ltimer,-1,1,8000,0),-15);
		glRotatef(45, 1, 0, 0);
		glScalef(1,0.4,1);
		glScalef(SineEx(ltimer,0.7,1.6,2000,i*250), 1, SineEx(ltimer,1,1.5,4000,timer+i*150));
		glRotatef(SineEx(ltimer,0,360*1.5,9000,i*120), 0, 1, 0);
		glBegin(GL_TRIANGLE_STRIP);
		glColor4f(1,1,1,rubberAlpha);
		glTexCoord2f(0,1);  glVertex3f(-1,0, 1);
		glTexCoord2f(0,0);  glVertex3f(-1,0,-1);
		glTexCoord2f(1,1);  glVertex3f( 1,0, 1);
		glTexCoord2f(1,0);  glVertex3f( 1,0,-1);
		glEnd();
	}
	
	glDisable(GL_ALPHA_TEST);

	Mode2D();
}
        
static void partInterference_Open()
{
	int i,s;
	Surface * tmp;
	Surface * tmp2;
	tmp  = LoadRLEBitmap(rleGrognon);
	tmp2 = Scale8x(tmp);
	bmpGrognon = AntiAlias(tmp2);
	FreeSurface(tmp);
	FreeSurface(tmp2);

	texGrognon = CreateTexture(512,512);

	glBindTexture(GL_TEXTURE_2D, texGrognon);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	UploadTexture(texGrognon, bmpGrognon);

	tmp = AntiAlias(bmpGrognon);
	FreeSurface(bmpGrognon);
	bmpGrognon = AntiAlias(tmp);
	FreeSurface(tmp);

	
	s = 128;
	for(i=0; i<BLUR_STEPS; i++) {
		texBlur[i] = CreateTexture(s,s);

		glBindTexture(GL_TEXTURE_2D, texBlur[i]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

		
		UploadTexture(texBlur[i], bmpGrognon);
		Blur(bmpGrognon);
		Blur(bmpGrognon);
	}

	bmpNoise = LoadBMP("pandora/interference.bmp");
	if (!bmpNoise) {
		bmpNoise = CreateSurface(512,512,1);
		FillNoise(bmpNoise, 4, 0.8, 10.0/256, 10,20,8);
		Threshold(bmpNoise, 128, 10, 192, 255);
		SaveBMP(bmpNoise,"pandora/interference.bmp");
	}
	
	texNoise = CreateTexture(512,512);
	UploadTextureLuminance(texNoise, bmpNoise);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

}

static void partInterference_Close()
{
	int i;
	
	for(i=0; i<BLUR_STEPS; i++) {
		FreeTexture(texBlur[i]);
	}
	FreeTexture(texGrognon);
	FreeTexture(texNoise);
	
	FreeSurface(bmpGrognon);
	FreeSurface(bmpNoise);
}


DemoPart partInterference = {0x0b00, 0x1200, partInterference_Draw, partInterference_Open, partInterference_Close};
