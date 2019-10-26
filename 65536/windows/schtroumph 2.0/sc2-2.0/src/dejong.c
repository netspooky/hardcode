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

/*
 * Dejong Iterated Fractal
 * EndScroll
 */

#include "introsystem.h"

GLuint texBuffer;
Surface *bmpBuffer;
Surface *bmpBuffer8;

static Surface		*bmpNoise;
static GLuint  		texNoise;

static RLEBitmap 	*rleGargamel=&bmp_gargamel;
static Surface		*bmpGargamel;
GLuint  		texGargamel;

#define ITERATIONS 15000 

Uint8 randtable[ITERATIONS];

int vertexarray[ITERATIONS*2];

Uint8 table_addpixel_clamp[512];
Uint32 table_palette[256];

#define BUFFER_WIDTH  384
#define BUFFER_HEIGHT 384

#define TABLE_RANDOM_SIZE 4096
#define TABLE_RANDOM_MAX  32
float table_random[TABLE_RANDOM_MAX][TABLE_RANDOM_SIZE];
int table_random_index=0;

static float intro=768*2;

#define LINE_LENGHT 32

char text[][LINE_LENGHT]=
{
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{""},	
{"SCHTROUMPH 2.0"},	
{"COPYRIGHT 2004 KNIGHTS"},
{""},	
{"---"},	
{""},	
{"-- CODE --"},
{"KASSOULET"},	
{""},	
{"-- MUSIC --"},	
{"BENJI/JFF"},	
{""},	
{"-- GFX --"},	
{"EXOCET/JFF"},	
{"KASSOULET"},	
{""},	
{"SOUNDSYSTEM"},
#ifdef USE_MIKMOD
{"MIKMOD"},	
#else
{"MINIFMOD"},	
#endif
{""},	
{"---"},	
{""},	
{"TOOLS USED:"},	
{"SCITE"},	
{"VIM"},	
{"MINGW+MSYS"},	
{"[GCC 3.4]"},	
{"CVS"},	
{"UPX"},	
{"GIMP"},	
{"DELUXE PAINT"},	
{"FASTTRACKER2"},	
{"SOUNDTRACKER"},	
{""},	
{"---"},	
{""},	
{"SPECIAL THANKS TO:"},	
{""},	
{"KEN PERLIN"},	
{"ANDREA MAZZOLENI"},	
{"WESLEY LOEWER"},	
{"PAUL BOURKE"},	
{"PETER DEJONG"},	
{"HUGO ELIAS"},	
{"NEHE"},	
{""},	
{"---"},	
{""},	
{"GREETS TO:"},	
{""},	
{"OUR FAMILIES AND FRIENDS"},	
{""},	
{"#CODEFR"},
{"#DEMOFR"},
{""},	
{"SYN[RJ]"},
{"EQUINOX"},
{"GODS"},
{"J.F.F."},
{"ORION"},
{"MANDARINE"},
{"FOOL"},
{"POPSY"},
{"BOMB"},
{"CALODOX"},
{"PHELIOS"},
{""},	
{"PLANET-D"},	
{"NECTARINE"},	
{"POUET"},	
{"SCENE.ORG"},	
{"ORANGE JUICE"},	
{"FLIPCODE"},	
{"DEMOO"},	
{"MONOSTEP"},	
{""}
};

/* Clear Dejong Buffer, with fake motion blur */
static void ClearBuffer(Surface * surface)
{
        Uint8 table[256];
        Uint8 *p;
        int i;

        for(i=0; i<256; i++) {
                int n;
                n = i*0.95;
		if (n==0) n=1;
                table[i]= n;
        }

        p=surface->pixels;
        for(i=0; i<BUFFER_WIDTH*BUFFER_HEIGHT; i++) {
                *p = table[*p];
                p++;
        }
}


static float scroller_position=0;
/* Draw the endscroll */
void DrawScroller()
{
	int height = sizeof(text)/LINE_LENGHT;
	int y;
		
	scroller_position += delta/48.0;
	
	for(y=0; y<16; y++) {
		int line = y + (int)scroller_position;
		DrawString(512,y*56- 56.0*(scroller_position-floor(scroller_position)),
			text[line%height],TEXT_CENTER,texFont);	
	}
}


static void partDejong_Draw(double time, double delta, int position)
{
        float x=0,y=0;
        float ox,oy;
	float z=1.0f;
        int i;
        Uint32 *dest;
        float a,b,c,d;
	int *pvertex;
	int blur;

	intro -= delta*5.0;
	//intro = CLAMP(intro,0,1);

        Mode2D();

        glDisable(GL_TEXTURE_2D);
        glEnable(GL_TEXTURE_2D);
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

	/* Background */
        glBindTexture(GL_TEXTURE_2D, texNoise);
	
        glDisable(GL_BLEND);
        glBegin(GL_QUADS);

        glColor4f(
		(1.0 +1.0* sin(timer*0.01) )/15.0,
		(5.5 +2.5* sin(timer*0.02) )/15.0,
		(12.0+4.0* sin(timer*0.03) )/15.0,a);
        glTexCoord2f(0,0); 	glVertex2i(0,   	0  );
        glColor4f(
		(1.0 +1.0* sin(timer*0.04) )/15.0,
		(5.5 +2.5* sin(timer*0.05) )/15.0,
		(12.0+4.0* sin(timer*0.06) )/15.0,a);
        glTexCoord2f(1,0); 	glVertex2i(1024, 	0  );
        glColor4f(
		(1.0 +1.0* sin(timer*0.05) )/15.0,
		(5.5 +2.5* sin(timer*0.04) )/15.0,
		(12.0+4.0* sin(timer*0.03) )/15.0,a);
        glTexCoord2f(1,0.75); 	glVertex2i(1024, 	768);
        glColor4f(
		(1.0 +1.0* sin(timer*0.02) )/15.0,
		(5.5 +2.5* sin(timer*0.01) )/15.0,
		(12.0+4.0* sin(timer*0.02) )/15.0,a);
        glTexCoord2f(0,0.75); 	glVertex2i(0,   	768);
        glEnd();


        Mode2D();
        glEnable(GL_BLEND);
	
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);

	/* Gargamel Sprite */
        glBindTexture(GL_TEXTURE_2D, texGargamel);

	glLoadIdentity();
	glTranslatef(512,384,0);
	//glScalef(Sine(1,1.2,10000,0),Sine(1,1.2,10000,5000),1);
	
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER, 0.1);

	glBegin(GL_TRIANGLE_STRIP);
	glColor4f(1,1,1,Sine(0.4,0.5,3000,0));
	
	glTexCoord2f(0,0); 	glVertex2i(-512,   	-384  );
	glTexCoord2f(1,0); 	glVertex2i(512, 	-384  );
	glTexCoord2f(0,0.75); 	glVertex2i(-512,   	384);
	glTexCoord2f(1,0.75);	glVertex2i(512, 	384);
	
	glEnd();
	glDisable(GL_ALPHA_TEST);
	
	glLoadIdentity();
	
        glDisable(GL_TEXTURE_2D);

	a =  1.5+1.01*sin(timer*0.001);
	b = -2.2+1.01*sin(timer*0.002);
	c =  2.5+1.01*sin(timer*0.003);
	d = -2.2+1.01*sin(timer*0.004);

	blur = TABLE_RANDOM_MAX*sin(timer*0.01);
	if (blur<0) blur = 0;
	
	srand(0);

	ox = rand();
	oy = rand();

	/* Fill vertexarray */	
	pvertex = vertexarray;
	for(i=0; i<ITERATIONS; i+=1) {
		x = sin(a*oy) - cos(b*ox);
		y = sin(c*ox) - cos(d*oy);
		ox = x;
		oy = y;

		x = x*3.0f/4.0f * (0.99*512.0f-TABLE_RANDOM_MAX)/4.0f + 384.0f/2.0f;
		y = y*0.99*(384.0f-TABLE_RANDOM_MAX)/4.0f + 384.0f/2.0f;
		
		x += table_random[blur][table_random_index&(TABLE_RANDOM_SIZE-1)];
		table_random_index++;
		y += table_random[blur][table_random_index&(TABLE_RANDOM_SIZE-1)];
		table_random_index++;
		
		*(pvertex+0) = x;
		*(pvertex+1) = y;
		pvertex+=2;
	}
	
	
        {
                Uint8* p;	
                Uint8* src;
                Uint8* dest8;

		ClearBuffer(bmpBuffer8);

                dest8 = (Uint8*)bmpBuffer8->pixels;
                for(i=0; i<ITERATIONS; i++) {
			int x,y;
			x = vertexarray[2*i];
			y = vertexarray[2*i+1];
			
			p = dest8+y*BUFFER_WIDTH+x; /* warning: no clipping! */	
			*p= table_addpixel_clamp[*p+32];
                }

                src  = (Uint8*)bmpBuffer8->pixels;
                dest = (Uint32*)bmpBuffer->pixels;
                for(i=0; i<BUFFER_WIDTH*BUFFER_HEIGHT; i++) {
                        *dest++ = table_palette[ *src++];
                }

                UploadTextureSub( texBuffer, bmpBuffer, 0, 0);
                glEnable(GL_TEXTURE_2D);
                glEnable(GL_BLEND);
                glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                glBlendFunc(GL_ZERO, GL_SRC_COLOR);
                glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
                glBindTexture(GL_TEXTURE_2D, texBuffer);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		
		glTranslatef(512+128,384,0);
		z = 1.0 + 0.1*sin(timer*0.003);
		glScalef(z,z,0);
		glRotatef(190.0f*sin(timer*0.0001),0,0,1);
                glBegin(GL_TRIANGLE_STRIP);
                glColor4f(1,1,1,1);
		
                glTexCoord2f(0,0); 	glVertex2i(-384,   	-384  );
                glTexCoord2f(0.75,0); 	glVertex2i(384, 	-384  );
                glTexCoord2f(0,0.75); 	glVertex2i(-384,   	384);
                glTexCoord2f(0.75,0.75);glVertex2i(384, 	384);
		
                glEnd();

        }

	DrawScroller();

	if (intro) {
	
		Mode2D();
		
		glTranslatef(512,384,0);
		glTranslatef(0,intro-768*2,0);
		glDisable(GL_TEXTURE_2D);		
		
		glBegin(GL_TRIANGLE_STRIP);
		glColor4f(0,0,0,1);
		glVertex2i(-512,   	-384  );
		glVertex2i(512, 	-384  );
		glVertex2i(-512,   	384);
		glVertex2i(512, 	384);
		glEnd();
		
		glTranslatef(0,768,0);
		glBegin(GL_TRIANGLE_STRIP);
		glColor4f(0,0,0,1);
		glVertex2i(-512,   	-384  );
		glVertex2i(512, 	-384  );
		glColor4f(0,0,0,0);
		glVertex2i(-512,   	384);
		glVertex2i(512, 	384);
		
		glEnd();
		
		glEnable(GL_TEXTURE_2D);
	}
}
        
static void partDejong_Open()
{
        int i,j;

	Surface * tmp;
	Surface * tmp2;
	tmp  = LoadRLEBitmap(rleGargamel);
	tmp2 = Scale8x(tmp);
	bmpGargamel = AntiAlias(tmp2);
	FreeSurface(tmp);
	FreeSurface(tmp2);
	
	texGargamel = CreateTexture(1024,1024);

        glBindTexture(GL_TEXTURE_2D, texGargamel);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	UploadTexture(texGargamel, bmpGargamel);
	
	bmpNoise = LoadBMP("pandora/dejong.bmp");
	if (!bmpNoise) {
		bmpNoise = CreateSurface(512,512,1);
		FillNoise(bmpNoise, 4, 0.8, 16.0/256, 20,10,8);
		Threshold(bmpNoise, 128, 10, 224, 255);
		SaveBMP(bmpNoise,"pandora/dejong.bmp");
	}
	
	texNoise = CreateTexture(512,512);
	UploadTextureLuminance(texNoise, bmpNoise);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	
        for(i=0; i<512; i++) {
                table_addpixel_clamp[i] = (i<256) ? i : 255;
        }

        for(i=0; i<256; i++) {
                table_palette[255-i] = (i<<16)+(i<<8)+i;
        }
        table_palette[0] = (128<<24)+0x0;

	for(j=0; j< TABLE_RANDOM_MAX; j++) {
		for(i=0; i<TABLE_RANDOM_SIZE; i++) {
			if (j>0) {
				table_random[j][i] = (j)/2-(rand()%((j)));
			} else {
				table_random[j][i] = 0;
			}
		}
	}

        texBuffer = CreateTexture(512,512);
        bmpBuffer = CreateSurface(BUFFER_WIDTH,BUFFER_HEIGHT,4);
        bmpBuffer8= CreateSurface(BUFFER_WIDTH,BUFFER_HEIGHT,1);
}

static void partDejong_Close()
{
        FreeTexture(texBuffer);
        FreeTexture(texNoise);
        FreeTexture(texGargamel);
	
        //FreeSurface(bmpGargamel);
        //FreeSurface(bmpNoise);
        //FreeSurface(bmpBuffer);
        //FreeSurface(bmpBuffer8);
}


DemoPart partDejong = {0x1200, 0x2000, partDejong_Draw, partDejong_Open, partDejong_Close};
