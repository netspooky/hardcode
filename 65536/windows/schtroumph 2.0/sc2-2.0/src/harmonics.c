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

static RLEBitmap 	*rleSprite=&bmp_grand;
static Surface		*bmpSprite;
static GLuint  		texSprite;
static float		spriteZoom=0.0;

static Surface *bmpChecker;
static GLuint texChecker;
static GLuint texRender;

static Surface *bmpBack;
static GLuint texBack;

static Surface *bmpWipe;
static GLuint texWipe;


#define RENDER_SIZE 128

typedef struct vector {
        float x,y,z;
} vector;

static float introPixeled=0;
static float introHarmonics=0;
static float outro=0;

inline float fast_pow(float n, int p)
{
        switch(p) {
                case 0: return 1;
                case 1: return n;
                case 2: return n*n;
                case 3: return n*n*n;
                case 4: return n*n*n*n;
                case 5: return n*n*n*n*n;
                case 6: return n*n*n*n*n*n;
        };
	return 0.0f;
}

vector Eval(double theta,double phi, int *m)
{
        float r = 0;
        vector p;
        float a,b,c,d;

        a = sin(m[0]*phi+	timer*0.01);
        b = cos(m[2]*phi+	timer*0.02);
        c = sin(m[4]*theta+	timer*0.03);
        d = cos(m[6]*theta+	timer*0.04);

        r += fast_pow(a,m[1]);
        r += fast_pow(b,m[3]);
        r += fast_pow(c,m[5]);
        r += fast_pow(d,m[7]);

        p.x = r * sin(phi) * cos(theta);
        p.y = r * cos(phi);
        p.z = r * sin(phi) * sin(theta);

        return(p);
}

float nexttime=0;

int m[8]={0,4,0,3,2,2,4,1};

static void DrawHarmonics(int resolution)
{
        int i,j;
        float u,v,du,dv;
	
        du = TWOPI / (float)resolution;
        dv = PI / (float)resolution;

        glBegin(GL_QUADS);
        for (i=0;i<resolution;i++) {
                u = i * du;
                for (j=0;j<resolution;j++) {
                        vector q;
			
                        v = j * dv;
                        q = Eval(u,v,m);
			glTexCoord2f(0, 0);
                        glVertex3f(q.x,q.y,q.z);

                        q = Eval(u+du,v,m);
			glTexCoord2f(1, 0);
                        glVertex3f(q.x,q.y,q.z);

                        q = Eval(u+du,v+dv,m);
			glTexCoord2f(1, 1);
                        glVertex3f(q.x,q.y,q.z);

                        q = Eval(u,v+dv,m);
			glTexCoord2f(0, 1);
                        glVertex3f(q.x,q.y,q.z);
                }
        }
        glEnd();
}	

static void partHarmonics_Draw(double time, double delta, int position)
{
	int i;
	int peak=0;

	/* Synchro */
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
			peak=1;
	}
        nexttime+=delta;
        if (peak) {
		srand(position);
                for (i=0;i<8;i++) {
                        m[i] = rand()%6;
                }
                nexttime = 0;
        }

	if (position<0x0418) {
		introPixeled+=delta*0.005f;
		introPixeled=CLAMP(introPixeled,0.0f,1.0f);
	} else {
		if (position<0x0430) {
			introHarmonics+=delta*0.005f;
			introHarmonics=CLAMP(introHarmonics,0.0f,1.0f);

			introPixeled-=delta*0.005f;
			introPixeled=CLAMP(introPixeled,0.0f,1.0f);
		} else {
			introHarmonics=1.0f;
		}
	}
	
	/* Render to texture */	
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_COLOR, GL_ONE);

        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, texChecker);

        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();

        glViewport(0, 0, RENDER_SIZE, RENDER_SIZE);

        gluPerspective(90, 1024.0/768.0, 100, 0);

        glClearColor( 0, 0, 0, 1 );
        glClear( GL_COLOR_BUFFER_BIT );

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glTranslatef(0,0,-5);
	glRotatef(timer*0.9,0,0,1);
        glScalef(0.25,0.25,1);

	DrawHarmonics(24);
	
	glBindTexture(GL_TEXTURE_2D,texRender);
	glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, RENDER_SIZE, RENDER_SIZE, 0);
	


	/* Draw background */
        Mode2D();
        glDisable(GL_BLEND);

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
	
	glTranslatef(512,384,0);
	
        glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D,texBack);

        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

        glMatrixMode(GL_MODELVIEW);
	glScalef(1.1,1.1,1);
	glRotatef(Sine(-2,2,5000,0),0,0,1);
	
	glBegin(GL_TRIANGLE_STRIP);
	switch (position) {
		case 0x0400:
		case 0x0500:
			glColor4f(1,0.5,1,1); /* white flash */
			break;
		default:
			glColor4f(0.5,0.25,0.5,1);
	}
	
	glTexCoord2f(0,0); 	glVertex2i(-512,   	-384  );
	glTexCoord2f(1,0); 	glVertex2i(512, 	-384  );
	glTexCoord2f(0,0.75); 	glVertex2i(-512,   	384);
	glTexCoord2f(1,0.75);	glVertex2i(512, 	384);
	
	glEnd();
	
	/* Draw big harmonics mesh */
        glEnable(GL_BLEND);
        glBindTexture(GL_TEXTURE_2D, texChecker);
	
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        gluPerspective(90, 1024.0/768.0, 100, 0);
	
        glViewport(0, 0, ScreenWidth, ScreenHeight);

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

        glTranslatef(0,0,-5);

        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

	glColor4f(0.7,0.5,0.5,introHarmonics/2.0f);
	DrawHarmonics(48);
	

	/* Draw the rendered texture (glow) */
	Mode2D();
	
	glTranslatef(512,384,0);
	glRotatef(timer*0.9,0,0,1);
        glScalef(2,2,1);

	glBindTexture(GL_TEXTURE_2D,texRender);
        glEnable(GL_TEXTURE_2D);

        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	glBegin(GL_TRIANGLE_STRIP);
	glColor4f(0.5,0.5,1,introHarmonics/2.0f);
	
	glTexCoord2f(0.25,0.75); 	glVertex2i(-512,   	-384  );
	glTexCoord2f(0.75,0.75); 	glVertex2i(512, 	-384  );
	glTexCoord2f(0.25,0.25); 	glVertex2i(-512,   	384);
	glTexCoord2f(0.75,0.25);	glVertex2i(512, 	384);
	
	glEnd();


	/* Draw the rendered texture (mosaic) */

	glBindTexture(GL_TEXTURE_2D,texRender);
        glEnable(GL_TEXTURE_2D);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

	glBegin(GL_TRIANGLE_STRIP);
	glColor4f(1,0.1,0.2,introPixeled);
	
	glTexCoord2f(0.25,0.75); 	glVertex2i(-512,   	-384  );
	glTexCoord2f(0.75,0.75); 	glVertex2i(512, 	-384  );
	glTexCoord2f(0.25,0.25); 	glVertex2i(-512,   	384);
	glTexCoord2f(0.75,0.25);	glVertex2i(512, 	384);
	
	glEnd();
	
	if (position>0x0600) {
		/* Grand Schtroumph */
		glBindTexture(GL_TEXTURE_2D, texSprite);
		glEnable(GL_TEXTURE_2D);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
		glLoadIdentity();
		glTranslatef(512,384,0);
		glScalef(spriteZoom,spriteZoom,1);
	
		spriteZoom += delta*0.005;
		
		glBegin(GL_TRIANGLE_STRIP);
		glColor4f(1,1,1,CLAMP(spriteZoom/2,0,1));
		
		glTexCoord2f(0,0); 	glVertex2i(-512,   	-384  );
		glTexCoord2f(1,0); 	glVertex2i(512, 	-384  );
		glTexCoord2f(0,0.75); 	glVertex2i(-512,   	384);
		glTexCoord2f(1,0.75);	glVertex2i(512, 	384);
		
		glEnd();
	}
	
	if (position>0x0620) {
		outro += delta * 0.01;
		outro = CLAMP(outro,0,1);
	}

	if (outro>0.0f) {
		/* Wipe transition */
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 1.0f-outro );

		if (outro<1.0f) {
			/* ==1 -> flat  */
			glBindTexture(GL_TEXTURE_2D, texWipe);
		} else {
			glBindTexture(GL_TEXTURE_2D, 0);
		}
		glEnable(GL_TEXTURE_2D);
		glDisable(GL_BLEND);
	
		glLoadIdentity();
		glTranslatef(512,384,0);
	
		glBegin(GL_TRIANGLE_STRIP);
		
		glColor4f(0.8,0.8,0.8,1);
		glTexCoord2f(0,0); 	glVertex2i(-512,   	-384  );
		glTexCoord2f(1,0); 	glVertex2i(512, 	-384  );
		glColor4f(1,1,1,1);
		glTexCoord2f(0,0.75); 	glVertex2i(-512,   	384);
		glTexCoord2f(1,0.75);	glVertex2i(512, 	384);
		
		glEnd();
	
		glDisable(GL_ALPHA_TEST);
	}
}


static void partHarmonics_Open()
{
	int i,j;
	int s=4;

	Surface * tmp;
	Surface * tmp2;
	tmp  = LoadRLEBitmap(rleSprite);
	tmp2 = Scale8x(tmp);
	bmpSprite = AntiAlias(tmp2);
	FreeSurface(tmp);
	FreeSurface(tmp2);
	
	texSprite = CreateTexture(1024,1024);

        glBindTexture(GL_TEXTURE_2D, texSprite);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	UploadTextureSub(texSprite, bmpSprite, 0,0);

        bmpChecker = CreateSurface(s,s,4);

	for(j=0;j<s;j++) {
		Uint32* p = (Uint32*)bmpChecker->pixels;
		p+=j*s;
		for(i=0;i<s;i++) {
			if ( ((j^i)&1) == 0 ) {
				*p=0xff000000;
			} else {
				*p=0xff888888;
			}
			p++;
		}
	}
	
	texChecker = CreateTexture(s,s);
	texRender =  CreateTexture(RENDER_SIZE,RENDER_SIZE);

        glBindTexture(GL_TEXTURE_2D, texChecker);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	UploadTexture(texChecker,bmpChecker);
	
        glBindTexture(GL_TEXTURE_2D, texRender);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	s = 512;
	bmpBack = LoadBMP("pandora/harmonics.bmp");
	if (!bmpBack) {
		bmpBack = CreateSurface(s,s,1);
		FillNoise(bmpBack, 4, 1, 5.0/256, 0,0,0.5);
		Threshold(bmpBack, 128, 10, 192, 255);
		SaveBMP(bmpBack,"pandora/harmonics.bmp");
	}
	
	texBack = CreateTexture(s,s);
	
        glBindTexture(GL_TEXTURE_2D, texBack);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	UploadTextureLuminance(texBack, bmpBack);

	bmpWipe = LoadBMP("pandora/harmonics-end.bmp");
	if (!bmpWipe) {
		bmpWipe = CreateSurface(s,s,1);
		FillNoise(bmpWipe, 2, 1, 6.0/256, 10,10,10);
		SaveBMP(bmpWipe,"pandora/harmonics-end.bmp");
	}
	
	texWipe = CreateTexture(s,s);
	
        glBindTexture(GL_TEXTURE_2D, texWipe);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	UploadTextureAlpha(texWipe, bmpWipe);
}

static void partHarmonics_Close()
{
	FreeTexture(texBack);
	FreeTexture(texChecker);
	FreeTexture(texRender);
	FreeTexture(texSprite);
	FreeTexture(texWipe);

	FreeSurface(bmpBack);	
	FreeSurface(bmpChecker);	
	FreeSurface(bmpSprite);	
	FreeSurface(bmpWipe);	
}


DemoPart partHarmonics = {0x0400, 0x0700, partHarmonics_Draw, partHarmonics_Open, partHarmonics_Close};
