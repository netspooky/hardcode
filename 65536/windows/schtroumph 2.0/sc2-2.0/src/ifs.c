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
#include "ifstext.h"

static RLEBitmap 	*rleBack=&bmp_smurfette;
static Surface		*bmpBack;
static GLuint  		texBack;


GLuint texBuffer;
Surface *bmpBuffer;
Surface *bmpBuffer8;

static Surface		*bmpNoise;
static GLuint  		texNoise;

static Surface		*bmpWipe;
static GLuint  		texWipe;



static float local_time=0;


#define ITERATIONS 30000 

Uint8 randtable[ITERATIONS];

int listx[ITERATIONS];
int listy[ITERATIONS];

GLshort vertexarray[ITERATIONS*2];

Uint8 table_addpixel_clamp[512];
Uint32 table_palette[256];


#define GREETS_MAX 16

IFSObject ifs_list[GREETS_MAX];

char ifs_text[GREETS_MAX][32]={
	"-",
	"-",
	"CODEFR",
	"SYN[RJ]",
	"EQUINOX",
	"GODS",
	"J.F.F.",
	"ORION",
	"MANDARINE",
	"FOOL",
	"POPSY",
	"BOMB",
	"CALODOX",
	"PHELIOS",
	"_P_H_E_L_I_O_S_",
	"___P___H___E___L___I___O___S___"
};

static int peak;
static float localTimer;
static int ifs_index=0;
static float ifs_time=0;

void Init(IFSObject ifs)
{
        
}

void Morph(IFSObject *ifs, IFSObject *ifs1, IFSObject *ifs2, float alpha)
{
        int i,j;
                
                for(j=0; j<IFS_MAX; j++) {
                        for(i=0; i<7; i++) {
                                ifs->ifs[j][i] = alpha*ifs1->ifs[j][i] + (1.0-alpha)*ifs2->ifs[j][i];
                        }
                }
}

void Iterate(IFSObject *ifs)
{
}

void Draw(IFSObject *ifs)
{
}

static void FindBoundaries(IFSObject *object)
{
	int i;
        float x=0,y=0;
        float dx,dy;
        char table_probability[256];
	Point min={0,0}, max={0,0};
	IFS ifs;
	float r;
	
	memcpy(ifs, object->ifs, sizeof(ifs));

        for(i=0; i<IFS_MAX-1; i++) {
                ifs[i+1][6] += ifs[i][6];
        }

	
        for(i=0; i<256; i++) {
                int j;
                float r = (rand()%10000)/10000.0f;

                for(j=0;j<IFS_MAX;j++) {
                        if (r < ifs[j][6]) {
                                break;
                        }
                }
                table_probability[i] = j;	
        }

        for(i=0; i<10000; i++) {
                int n;

                n = table_probability[randtable[i]];

                dx = ifs[n][0]*x + ifs[n][1]*y + ifs[n][4];
                dy = ifs[n][2]*x + ifs[n][3]*y + ifs[n][5];

		x = dx;
		y = dy;
		
		if (dx < min.x) min.x = dx;
		if (dx > max.x) max.x = dx;
		if (dy < min.y) min.y = dy;
		if (dy > max.y) max.y = dy;
        }

	r = max.x - min.x;
	/*
	if (max.y - min.y > r) {
        	r = max.y - min.y;
	}
	*/

	r = 0.9f * 1.0f/r;
	
	min.x *= r;
	min.y *= r;
	max.x *= r;
	max.y *= r;
	
	object->scale.x = 1024.0f*r;	
	object->scale.y = 768.0f*r;
	
	object->translation.x = 1024.0f*(-0.5*(min.x + max.x - 1.0));
	object->translation.y =  768.0f*(-0.5*(min.y + max.y - 1.0));

}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////


static float peak_power=200;
static float intro=1;
static float outro=0;

static void DrawSmurfette()
{
	int x,y,i;
        Mode2D();
        glEnable(GL_TEXTURE_2D);

	glLoadIdentity();
	glTranslatef(512,384,0);
	
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER, 0.1);

        glBindTexture(GL_TEXTURE_2D, texBack);
	glBegin(GL_QUADS);
	glColor4f(1,1,1,0.6);

	if (peak) {
		peak_power = 20+intro*200.0;
	}

	peak_power -= delta;
	if (peak_power<0) peak_power=0;
	x = peak_power;
	
	srand(frames);
	
	i=0;
	for(y=0;y<768;y+=2) {
		
		if ( 100+(rand()%900) > outro*1000.0f ) {
		
			x = Sine(-peak_power,peak_power,1000,y*10.0);
			if (i++&1) x=-x;
			
			glTexCoord2f(0,y/1024.0);	glVertex2i(-512+x,   	-384+y  );
			glTexCoord2f(1,y/1024.0);	glVertex2i(512+x, 	-384+y  );
			glTexCoord2f(1,(y+3)/1024.0);	glVertex2i(512+x, 	-384+y+2);
			glTexCoord2f(0,(y+3)/1024.0); 	glVertex2i(-512+x,   	-384+y+2);
		}	
	}
	glVertex2i(-512,-384);
	glVertex2i(-512,-384);
	glVertex2i(-512,-384);
	glVertex2i(-512,-384);
	glEnd();
	glDisable(GL_ALPHA_TEST);
}

static void DrawNoise()
{
        Mode2D();

        glEnable(GL_BLEND);
        glEnable(GL_TEXTURE_2D);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

	glTranslatef(512,384,0);

	glScalef(Sine(1,1.02,1000,0),Sine(1,1.02,1000,200),1);

        glBindTexture(GL_TEXTURE_2D, texNoise);
	glBegin(GL_TRIANGLE_STRIP);
	glColor4f(0.5,0.3,0.4,1);
	
	glTexCoord2f(0,0); 	glVertex2i(-512,   	-512  );
	glTexCoord2f(1,0); 	glVertex2i(512, 	-512  );
	glTexCoord2f(0,1); 	glVertex2i(-512,   	512);
	glTexCoord2f(1,1);	glVertex2i(512, 	512);
	
	glEnd();
}

static void DrawCube()
{
	float a,z,f;
	int i;
	
        glDisable(GL_TEXTURE_2D);

	Mode2D();

	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        glBlendFunc(GL_ZERO,GL_SRC_COLOR);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();		
	gluPerspective(45.0f,(GLfloat)ScreenWidth/(GLfloat)ScreenHeight,0.1f,100.0f);

	glMatrixMode(GL_MODELVIEW);

	a = 0.1;
	a = 1.0-Sine(0.05,0.10,2000,0);
	z = -5;

	glLoadIdentity();
	glTranslatef(Sine(-1,1,10000,0),Sine(-0.2,0.2,10000,0),z);
	glRotatef (localTimer, 1, 1, 1);

	glColor4f(a,a,a,a);

	for(f=-1;f<=1;f+=0.5) {
		i++;
		glBegin (GL_QUADS);
		glVertex3f(f,-1,-1);
		glVertex3f(f,-1,1);
		glVertex3f(f,1,1);
		glVertex3f(f,1,-1);
		glEnd ();
	}
	for(f=-1;f<=1;f+=0.5) {
		i++;
		glBegin (GL_QUADS);
		glVertex3f(-1,f,-1);
		glVertex3f(-1,f,1);
		glVertex3f(1,f,1);
		glVertex3f(1,f,-1);
		glEnd ();
	}
	for(f=-1;f<=1;f+=0.5) {
		i++;
		glBegin (GL_QUADS);
		glVertex3f(-1,-1,f);
		glVertex3f(-1,1,f);
		glVertex3f(1,1,f);
		glVertex3f(1,-1,f);
		glEnd ();
	}
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

static void partIFS_Draw(double time, double delta, int position)
{
        float x=0,y=0;
        float dx,dy;

        int i,j;
        float a;
        Uint8 table_probability[256];

	IFS ifs;
	Point scale, translation;

	localTimer += delta;

	peak = 0;	
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
			localTimer+=delta*3.0;
			peak=1;
	}

	if (position>0x0a20) {
		outro += delta * 0.01;
		outro = CLAMP(outro,0,1);
	}
	
	local_time += delta;
	ifs_time = local_time * 20.0f / 1400.0f ;
	a = fade(ifs_time - floor(ifs_time));
	ifs_index = (int) ifs_time;
	
        // morphing	
        for(j=0; j<IFS_MAX; j++) {
                for(i=0; i<7; i++) {
                        ifs[j][i] = a*ifs_list[(ifs_index+1)%GREETS_MAX].ifs[j][i] + (1.0f-a)*ifs_list[ifs_index%GREETS_MAX].ifs[j][i];
                }
        }

	scale.x = a*ifs_list[(ifs_index+1)%GREETS_MAX].scale.x + (1.0f-a)*ifs_list[ifs_index%GREETS_MAX].scale.x;
	scale.y = a*ifs_list[(ifs_index+1)%GREETS_MAX].scale.y + (1.0f-a)*ifs_list[ifs_index%GREETS_MAX].scale.y;
	translation.x = a*ifs_list[(ifs_index+1)%GREETS_MAX].translation.x + (1.0f-a)*ifs_list[ifs_index%GREETS_MAX].translation.x;
	translation.y = a*ifs_list[(ifs_index+1)%GREETS_MAX].translation.y + (1.0f-a)*ifs_list[ifs_index%GREETS_MAX].translation.y;
	
        for(i=0; i<IFS_MAX-1; i++) {
                ifs[i+1][6] += ifs[i][6];
        }
        srand(0);

        for(i=0; i<256; i++) {
                int j;
                float r = (rand()%10000)/10000.0f;

                for(j=0;j<IFS_MAX;j++) {
                        if (r < ifs[j][6]) {
                                break;
                        }
                }
                table_probability[i] = j;	
        }
	
	DrawNoise();
	DrawSmurfette();
	DrawCube();	

	
        Mode2D();
        glDisable(GL_TEXTURE_2D);
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);


        // warm attractor
        for(i=0; i<20; i++) {
                int n;

                n = table_probability[randtable[i]];

                dx = ifs[n][0]*x + ifs[n][1]*y + ifs[n][4];
                dy = ifs[n][2]*x + ifs[n][3]*y + ifs[n][5];

                x = dx;
                y = dy;
        }

        // then start the real fun
        for(i=0; i<ITERATIONS; i++) {
                int n;

                n = table_probability[randtable[i]];

                dx = ifs[n][0]*x + ifs[n][1]*y + ifs[n][4];
                dy = ifs[n][2]*x + ifs[n][3]*y + ifs[n][5];

                x = dx;
                y = dy;
                vertexarray[2*i]   = x*scale.x + translation.x;
                vertexarray[2*i+1] = 768.0f - (y*scale.y + translation.y);
		
        }

        glEnable(GL_BLEND);

        glPointSize(1);

        glTranslatef(10,10,0);
	glRotatef(Sine(-2,2,5000,0),0,0,1);
        glColor4f(0,0,0,0.5-outro/2.0f);
        glVertexPointer(2, GL_SHORT, 0, vertexarray);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_POINTS, 0, ITERATIONS);
	
        glPointSize(2);

        glLoadIdentity();
	
	glRotatef(Sine(-2,2,5000,0),0,0,1);
	
        glColor4f(0.9,1.0,0.9,1.0f-outro);
	
        glVertexPointer(2, GL_SHORT, 0, vertexarray);
        glEnableClientState(GL_VERTEX_ARRAY);
        glDrawArrays(GL_POINTS, 0, ITERATIONS);


	intro -= delta * 0.01;
	intro = CLAMP(intro,0,1);

	if (intro>0.0f) {
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 1.0f-intro );

		if (intro<1.0f) {
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
        
static void partIFS_Open()
{
        int i;
	
	Surface * tmp;
	Surface * tmp2;
	tmp  = LoadRLEBitmap(rleBack);
	tmp2 = Scale8x(tmp);
	bmpBack = AntiAlias(tmp2);
	FreeSurface(tmp);
	FreeSurface(tmp2);
	
	texBack = CreateTexture(1024,1024);

        glBindTexture(GL_TEXTURE_2D, texBack);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	
	UploadTextureSub(texBack, bmpBack, 0,0);
	
	
        for(i=0; i<ITERATIONS; i++) {
                randtable[i] = rand() % 256;
        }

        for(i=0; i<512; i++) {
                table_addpixel_clamp[i] = (i<256) ? i : 255;
        }

        for(i=0; i<256; i++) {
                table_palette[i] = (i<<24)+0xffffff;
        }
        table_palette[0] = (128<<24)+0x0;

        texBuffer = CreateTexture(512,512);
        bmpBuffer = CreateSurface(512,384,4);
        bmpBuffer8= CreateSurface(512,384,1);

        InitLetters();

        for(i=0; i<GREETS_MAX; i++) {
		StringToIFS(ifs_list[i].ifs,ifs_text[i]);
		FindBoundaries(&ifs_list[i]);	
	}
	
	bmpNoise = LoadBMP("pandora/ifs.bmp");
	if (!bmpNoise) {
		bmpNoise = CreateSurface(512,512,1);
		FillNoise(bmpNoise, 2, 0.8, 5.0/256, 20,10,5);
		Threshold(bmpNoise, 128, 10, 192, 255);
		SaveBMP(bmpNoise,"pandora/ifs.bmp");
	}
	
	texNoise = CreateTexture(512,512);
	UploadTextureLuminance(texNoise, bmpNoise);

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	bmpWipe = LoadBMP("pandora/ifs-intro.bmp");
	if (!bmpWipe) {
		bmpWipe = CreateSurface(512,512,1);
		FillNoise(bmpWipe, 4, 1, 8.0/256, 5,5,5);
		SaveBMP(bmpWipe,"pandora/ifs-intro.bmp");
	}
	
	texWipe = CreateTexture(512,512);
	
        glBindTexture(GL_TEXTURE_2D, texWipe);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	UploadTextureAlpha(texWipe, bmpWipe);
}

static void partIFS_Close()
{
        FreeTexture(texBuffer);
        FreeTexture(texBack);
        FreeTexture(texNoise);
        FreeTexture(texWipe);

        FreeSurface(bmpBuffer);
        FreeSurface(bmpBuffer8);
        FreeSurface(bmpBack);
        FreeSurface(bmpNoise);
        FreeSurface(bmpWipe);
}


DemoPart partIFS = {0x0700, 0x0b20, partIFS_Draw, partIFS_Open, partIFS_Close};
