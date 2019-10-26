
#include <SDL.h>
#include <SDL_opengl.h>
#include <math.h>
#include "dynlib.h"

#include "letters2.h"

void frustraatio(void);

extern int counter;
extern char quit;

// dimensions

// texture
#define TW 1024
#define TH 512

// screen
#define W 640.0
#define H 480.0
#define IW 640
#define IH 480

#define AUDIO_LEN 1024
#define FACTOR 0.15
float max_sample;

/* Audio "analysis" */
void analyysi(signed short *dest) {
    int i;
    float w,max=-10.0;
    for (i=0; i<AUDIO_LEN; i++) {
	w=(float)dest[i]/32768.0;
	if (fabs(w)>max)
	    max=fabs(w);
    }
    max_sample=max*FACTOR+(1.0-FACTOR)*max_sample;
}

void init(void)
{
    int i;
    static unsigned char tmp[(int)TW*(int)TH*3];
    int x,y;
    unsigned char *p=tmp;

    for (i=1; i<4; i++) {
	mlBindTexture(GL_TEXTURE_2D,i);
        /* It is a bit dangerous to leave them out...
	mlPixelStorei(GL_UNPACK_ALIGNMENT, 1);

	mlTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	mlTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	mlTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);*/
	mlTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	mlTexImage2D(GL_TEXTURE_2D, 0,
		     GL_RGBA,
		     TW,TH,
		     0,
		     GL_RGB,
		     GL_UNSIGNED_BYTE,
		     NULL
		    );
    }

    /* Generate filled circles */
    for (y=-IH/2; y<IH/2; y++) {
	for (x=-IW/2; x<IW/2; x++) {
	    i=x*x+y*y;
	    
	    if (i>220*220)
		i=0;
            else
		i=255;

	    *p++=i;
            *p++=i;
	    *p++=i;
	}
        p+=(TW-IW)*3;
    }

    mlTexImage2D(GL_TEXTURE_2D, 0,
		 GL_RGBA,
		 TW,TH,
		 0,
		 GL_RGB,
		 GL_UNSIGNED_BYTE,
                 tmp
		);
}

/* A general texture-mapped quad */
void plane(float x1,float y1,float y3,float x4,float z) {
    mlBegin(GL_POLYGON);
    mlTexCoord2f(0.0,0.0);
    mlVertex3f(x1,y1,z);
    mlTexCoord2f(W/TW,0.0);
    mlVertex3f(-x1,y1,z);
    mlTexCoord2f(W/TW,H/TH);
    mlVertex3f(-x1,y3,z);
    mlTexCoord2f(0,H/TH);
    mlVertex3f(x4,y3,z);
    mlEnd();
}

#define X 1.0
#define Y 0.75
#define Z (-1.02)

void motion_blur(float factor)
{
    mlBindTexture(GL_TEXTURE_2D,1);
    mlLoadIdentity();
    mlEnable(GL_BLEND);
    mlEnable(GL_TEXTURE_2D);

    mlBlendFunc(GL_ONE_MINUS_DST_COLOR,GL_DST_COLOR);
    mlColor3f(0.992*factor,0.98*factor,0.94*factor);
    plane(-X,-Y,+Y,-X,Z);
    mlCopyTexSubImage2D(GL_TEXTURE_2D,0,
			0,0, // destination
			0,0, // source
			W,H
		       );
}

#define X 1.0
#define Y 0.75
#define Z2 (-0.99)

void shine(float factor, float dist)
{
    int i;

    mlBindTexture(GL_TEXTURE_2D,2);
    mlCopyTexSubImage2D(GL_TEXTURE_2D,0,
			0,0, // destination
			0,0, // source
			W,H
		       );
    //mlLoadIdentity(); Already set by motion blur
    mlBlendFunc(GL_ONE,GL_ONE);

    mlColor3f(0.25*factor,0.2*factor,0.2*factor);
    for (i=0; i<20; i++) {
	plane(-X,-Y,+Y,-X,Z2);
        mlTranslatef(0.0,0.0,dist);
    }
}

#define F 0.01

#define TEKSTIT 1
#define MEDUUSA 2
#define NAUHAT 4
#define KOLMIOT 8

#define N 6

/* The demo script: blur speed, shine strength&dist, param, effects, beat */
signed char osat[]={
    95, 11,  -2,  00,     MEDUUSA,         00,
    99, 11,  -2,  5*16,   MEDUUSA,         14/2,
    65, 21,  -15, 00,     TEKSTIT|NAUHAT,  32/2,
    95, 21,  -15, 00,     TEKSTIT|NAUHAT,  40/2,
    95, 11,  1,   00,     TEKSTIT|KOLMIOT, 48/2,
    95, 11,  1,   00,     KOLMIOT,         72/2,
    95, 11,  1,   00,     KOLMIOT|NAUHAT,  76/2,
    90, 11,  1,   0,      KOLMIOT,         112/2,
    99, 10,  -4,  1,      KOLMIOT,         128/2,
    92, 11,  -2,  1+2*16, MEDUUSA|TEKSTIT, 160/2,
    45, 11,  -2,  1+2*16, MEDUUSA|TEKSTIT, 192/2,
    80, 11,  1,   0,      MEDUUSA|NAUHAT,  196/2,
    90, 11,  -4,  1+4*16, MEDUUSA|TEKSTIT, 200/2,
    90, 11,  1,   0,      MEDUUSA|NAUHAT,  204/2,
    95, 11,  -4,  1+4*16, MEDUUSA|TEKSTIT, 208/2,
    95, 11,  1,   0,      MEDUUSA|NAUHAT,  212/2,
    95, 11,  -4,  1+4*16, MEDUUSA|TEKSTIT, 216/2,
    95, 11,  1,   0,      MEDUUSA|NAUHAT,  220/2,
    95, 11,  1,   0,      MEDUUSA,         224/2,
    95, 110, -5, -2*16,   MEDUUSA,         240/2,
    95, 110, -5, -2*16,   0,               264/2

};

char osa(int klok)
{
    int     z,i,j,pat;
    float   f,r1,r2;
    static int oldframe;

    static float old_motion_blur_spd;
    float   motion_blur_spd;
    float   shine_strength;
    float   shine_dist;
    int     param1;
    int     effects;

    int beat=(counter-4096)/5292;
    if (beat<0)
	beat=0;

    /* Find the beat from demo script and load values */
    beat/=8;
    for (i=0; i<sizeof(osat)/N; i++)
	if (beat>=((unsigned char)osat[i*N+5]))
	    pat=i;

    motion_blur_spd =
	(1.0-F)*old_motion_blur_spd+
	F*(float)osat[N*pat+0]/100.0;

    old_motion_blur_spd=motion_blur_spd;

    shine_strength = (float)osat[N*pat+1]/10.0;
    shine_dist = (float)osat[N*pat+2]/100.0;
    param1 = osat[N*pat+3];
    effects = osat[N*pat+4];

    /* Hey hey, not too fast (100Hz) */
    if(klok<oldframe+9)
	return(0); // Frame not drawn
    oldframe=klok;

    /* GL setup */
    mlClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    mlMatrixMode (GL_PROJECTION);
    mlLoadIdentity ();
    frustraatio();

    mlMatrixMode(GL_MODELVIEW);
    mlLoadIdentity(); // W00t... This isn't necessary but helps compression
    
    mlBindTexture(GL_TEXTURE_2D,3);
    mlEnable(GL_TEXTURE_2D);
    mlEnable(GL_BLEND);

    /* Text cylinder */
    if (effects & TEKSTIT) {

	mlLoadIdentity();
	mlTranslatef(0,+2*0.14,-2);
	mlRotatef(-30,0,1+(param1 & 15),param1 & 15);

	mlRotatef(-klok/20.0,0,1,0);

	for (z=0; z<STRLEN; z++) {
	    for (j=0; j<5; j++) {
		for (i=0; i<4; i++) {
		    if (letters_font[5*strige[z]+j][i]!=' ')
		        plane(-0.1,-0.075,+0.075,-0.1,+1.2);
		    mlTranslatef(+0.14,0,0);
		}
		mlTranslatef(-0.14*4,-0.14,0);
	    }
	    mlRotatef(+360.0/12.0,0,1,0);
	    mlTranslatef(0,+0.14*5,0);
	}
    }

    mlDisable(GL_BLEND);
    mlDisable(GL_TEXTURE_2D);

    /* Red sphere */
    if (effects & MEDUUSA) {
	mlLoadIdentity();
	mlTranslatef(0,0,-4+param1/16.0);

	mlRotatef(klok/30.0,0,0,1);
	mlRotatef(klok/81.0,1,0.2,0);
	mlLineWidth(8);
        r1=klok/3000.0; /* Fade in */
	if(r1>1)
	    r1=1;
	mlColor3f(0.26*r1,0.10*r1,0.11*r1);
	for(r2=-2.9;r2<3.1;r2+=0.97/2.0)
	{
	    mlBegin(GL_LINE_STRIP);
	    for(r1=0;r1<M_PI*2+0.2;r1+=0.1)
	    {
		f=sqrt(9-r2*r2)+sin(r2+klok/500.0)*0.3;
		mlVertex3f(sin(r1)*f,r2,cos(r1)*f);
	    }
	    mlEnd();
	}
    }

    /* Stripes */
    if (effects & NAUHAT) {
	mlLoadIdentity();
	mlTranslatef(0.0,0.0,-1.5);
	mlRotatef(-klok/10.0,0,0,1);
	mlLineWidth(2.0);

	for (j=0; j<(4*max_sample); j++) {

	    mlColor3f(0.5+j*0.05,0.4+j*0.05,0.4+j*0.05);

	    mlBegin(GL_LINE_STRIP);
	    for (i=0; i<100; i++) {
		r1=0.4*(i*(0.4*sin(i*0.1+klok*0.001)));
		r2=0.1*(i*(0.2*sin(i*0.1+klok*0.003)));
		mlVertex3f(sin(i*0.0005*(1.0+10.0*max_sample))*r1,
			   cos(i*0.0005*(1.0+10.0*max_sample))*r2,
			   +sin(max_sample*1.0+i*0.01+klok*0.005)*1.2);
	    }
	    mlEnd();
	    mlRotatef(33.0,1,1,1);
	}
    }

    /* Music synced triangles */
    if (effects & KOLMIOT) {

	mlColor3f(0.08+max_sample*0.24,0.06+max_sample*0.26,
                  0.05+max_sample*0.25);
	for (j=0; j<2; j++) {
	    mlLoadIdentity();
            mlRotatef(klok/10.0+j*360.0/2.0,0,0,1);
            mlRotatef(param1*45.0,1,0,0);
	    for (i=0; i<30; i++) {

                if (i!=0)
		    plane(0.0,-0.1,0.0,-0.1,-0.59+max_sample*0.50);
		mlRotatef(max_sample*550.0+j*40,0,0,1);
		mlTranslatef(-0.15,0,-0.01);
	    }
	}
    }

    motion_blur(motion_blur_spd);
    if (shine_dist>=0.099)
	shine_dist+=0.05*max_sample;

    shine(shine_strength, shine_dist);

    if(beat>270/2)
	quit++;

    return(1); // Frame drawn
}
