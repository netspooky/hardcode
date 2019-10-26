
#include <SDL.h>
#include <SDL_opengl.h>
#include <math.h>
#include "dynlib.h"

#ifndef M_PI
#define M_PI 3.141592
#endif

#define MUL 128.0

extern unsigned char jamppa[];

void frustraatio(void);
void show(unsigned char *s,char fg,char bg);

extern int counter;
extern char quit;

// texture
#define TW 1024
#define TH 512

// screen
#define W 640.0
#define H 480.0
#define IW 640
#define IH 480

signed short *smp=NULL;

#define AUDIO_LEN 1024

void init(void)
{
    int i;

    for (i=1; i<=1; i++) {
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
}

#define X 1.0
#define Y 0.75
#define Z2 (-0.99)

#define LIN 1
#define JAM 2
#define ROT 4
#define RIN 8

#define ROWLEN 6 /* Row len in bytes in script */

/* Beat, fx, rotation speed/dir, shine1, shine2, Brown's head (r,g) */
signed char script[] ={
0,    LIN,          -1, 0,  0,  0,
16/2, LIN,          1,  0,  0,  0,
32/2, JAM+ROT,      -2, 15, 1,  060,
40/2, JAM+ROT,      4,  10, 4,  000,
44/2, JAM+ROT,      -6, 30, 4,  060,
47/2, JAM+ROT,      22, 30, 4,  060,

48/2, JAM+LIN,      3,  25, 3,  060,
64/2, RIN,          0,  80, 1,  0,
68/2, RIN+LIN,      -3, 127, 1, 0,
78/2, RIN,          0,  80, 1,  0,

80/2, JAM+RIN+ROT,  2,  20, 5,  060,
84/2, JAM+RIN+ROT,  -3, 10, 5,  040,
88/2, JAM+LIN,      3,  20, 5,  063,
92/2, JAM+RIN+ROT,  -3, 30, 5,  065,

96/2,  RIN+ROT,     1,  0,  0,  0,
108/2, RIN+ROT,     -2, 10, 5,  0,
112/2, RIN+ROT,     2,  10, 5,  0,
116/2, RIN+ROT,     -2, 10, 5,  0,
120/2, RIN+ROT,     2,  10, 5,  0,
124/2, RIN+ROT,     -1, 0,  0,  0,

254/2, 0,0,0,0,0
};

char osa(int klok)
{
    static int oldframe=0,n,i,j,k;
    float  f,p,p_r;
    static float    p_s1=0,p_s2=0;
    signed char fx,*sk=script,colr;

    int beat=(counter-4096)/5292;
    if (beat<0)
	beat=0;
    beat/=8;

    /* Hey hey, not too fast (100Hz) */
    if(klok<oldframe+9)
	return(0); // Frame not drawn
    oldframe=klok;

    /* Search the script */
    while(1)
    {
        if(beat/2<*sk++)
            break;
        fx=*sk++;
        p_r=*sk++;
        p_s1=*sk++/100.0;
        p_s2=*sk++/100.0;
        colr=*sk++;
    }

    /* GL setup */
    mlClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    mlMatrixMode(GL_PROJECTION);
    mlLoadIdentity();
    frustraatio();

    mlMatrixMode(GL_MODELVIEW);
    mlLoadIdentity();

    mlLineWidth(5);
    mlDisable(GL_TEXTURE_2D);
    mlDisable(GL_BLEND);

    /* Sample lines */
    if(fx&LIN)
    {
        mlRotatef(klok/100.0*p_r,0,0,1);
        mlTranslatef(0,-0.9,-0.8);
        if(smp!=NULL)
        {
            for(j=0;j<10;j++)
            {
                mlColor3f(1,0.6,j/20.0);
                mlBegin(GL_LINE_STRIP);
    
                k=(klok<15000)?AUDIO_LEN*klok/15000:AUDIO_LEN;
                for(n=0;n<k;n+=8)
                    mlVertex3f(n/400.0-k/800.0,smp[n+AUDIO_LEN/2-k/2]/200000.0,0);
                mlEnd();

                mlTranslatef(0,0.2,0);
            }
        }
    }

    /* Rotating plaque */
    if(fx&ROT)
    {
        mlLoadIdentity();
        mlTranslatef(0,0,-1.0);
        mlRotatef(klok/10.0*p_r,0,0.3,1);

        mlBegin(GL_POLYGON);
        mlColor3f(1,0.9,0.1);
        mlVertex3f(0,-50,0);
        mlVertex3f(50,-50,0);
        mlVertex3f(50,50,0);
        mlVertex3f(0,50,0);
        mlEnd();
    }

    /* Sample rings */
    if(fx&RIN)
    {
        mlLoadIdentity();
        mlTranslatef(0,0,-1.0);
        mlRotatef(klok/10.0*p_r,0,0.3,1);
        if(smp!=NULL)
        {
            for(i=0;i<12;i++)
            {
                mlBegin(GL_LINE_LOOP);
                for(n=0;n<AUDIO_LEN;n+=8)
                {
                    if(n<AUDIO_LEN/2 && fx&ROT)
                        mlColor3f(0,0,0);
                    else
                        mlColor3f(1,0.9,0.1);
                    f=0.2+i/3.0+smp[n]/100000.0;
                    mlVertex3f(sin((n+i)*(M_PI*2.0/AUDIO_LEN))*f,
                               cos((n+i)*(M_PI*2.0/AUDIO_LEN))*f,0);
                }
                mlEnd();
            }
        }
    }

    /* James Brown face */
    if(fx&JAM)
    {
        unsigned char c,*s;

        for(i=0;i<5;i++)
        {
            mlLoadIdentity();
            f=-1.2+0.7*sin(klok/(3*50.0));
            if(beat>=48 && beat<64)
                f=-3.3+(beat-48)/4*0.85;
            else
                if(i!=2)
                    continue;
            mlTranslatef(i*1.6-3.2,0,f);

            s=jamppa;
            while(1)
            {
                c=*s++;
                if(c==255)
                    break;
                n=c&0x7f;
    
                if(c&0x80)
                    mlColor3f((colr>>3)/7.0,(colr&7)/7.0,0);
                else
                    mlColor3f(1,1,0.5);
    
                mlBegin(GL_POLYGON);
                while(n--)
                {
                    mlVertex3f((signed char)s[0]/MUL,(signed char)s[1]/MUL,0);
                    s+=2;
                }
                mlEnd();
            }
        }
    }

    if(beat<32)
    {
        p_s1=klok/18000.0;
        p_s2=0.012;
    }

    /* Shine effect */
    mlEnable(GL_TEXTURE_2D);
    mlEnable(GL_BLEND);

    mlBindTexture(GL_TEXTURE_2D,1);
    mlCopyTexSubImage2D(GL_TEXTURE_2D,0,
			0,0, // destination
			0,0, // source
			W,H
		       );
    mlLoadIdentity();
    mlBlendFunc(GL_ONE,GL_ONE);

    mlColor3f(0.2*p_s1,0.2*p_s1,0.2*p_s1);
    for (i=0; i<20; i++)
    {
        mlBegin(GL_QUADS);
        mlTexCoord2f(0.0,0.0);
        mlVertex3f(-X,-Y,Z2);
        mlTexCoord2f(W/TW,0.0);
        mlVertex3f(X,-Y,Z2);
        mlTexCoord2f(W/TW,H/TH);
        mlVertex3f(X,Y,Z2);
        mlTexCoord2f(0,H/TH);
        mlVertex3f(-X,Y,Z2);
        mlEnd();

        mlTranslatef(0.0,0.0,p_s2);
    }

    if(beat>147)
	quit++;

    return(1); // Frame drawn
}
