
#include <string.h>
#include <stdlib.h>
#include <SDL/SDL.h>
#include <math.h>
#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif

#include "syna.h"
#include "palikka.h"
#include "volume.h"
#include "dudes.h"
#include "hakkyra.h"
#include "tunneli.h"
#include "spiral.h"
#include "ball.h"
#include "writer.h"
#include "feidit.h"
#include "naamat.h"

#define XS 640
#define YS 480

extern char piisi[];

void run_fx(void);
float musasynk(int ins,float tid);

void pakki(void *udata, Uint8 *stream, int len)
{
    syna_play((short *)stream,len/4);
}

int main(int argc, char *argv[])
{
    int i,quit=0,xs=XS,ys=YS,flagga=0,aa=1,param=0;
    SDL_Event e;
    SDL_AudioSpec w;

    SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER|SDL_INIT_AUDIO);

    /* Open audio and load the tune */
    w.freq=44100;
    w.format=AUDIO_S16SYS;
    w.channels=2;
#ifdef BLKSIZE
    w.samples=BLKSIZE;
#else
    w.samples=4096;
#endif
    w.callback=pakki;
    w.userdata=NULL;
    SDL_OpenAudio(&w,NULL);
    syna_init(44100);
    if(syna_get(piisi)<0)
        return(EXIT_FAILURE);

    for(i=1;i<argc;i++)
    {
        if(!strcmp(argv[i],"-w"))
        {
            flagga-=SDL_FULLSCREEN;
            param++;
        }
        if(!strcmp(argv[i],"-a"))
        {
            aa=0;
            param++;
        }
    }

    if(argv[0][strlen(argv[0]-1)]=='w')
        flagga-=SDL_FULLSCREEN;

    if(argc>=param+3)
    {
        xs=atoi(argv[argc-2]);
        ys=atoi(argv[argc-1]);
    }

    /* Works with NVidia Unix drivers only so never mind */
    if(aa && !getenv("__GL_FSAA_MODE"))
        putenv("__GL_FSAA_MODE=4");

    flagga+=SDL_OPENGL|SDL_FULLSCREEN;
    if(argv[0][strlen(argv[0])-1]=='w')
        flagga-=SDL_FULLSCREEN;

#ifdef MAC
    SDL_SetVideoMode(xs,ys,32,flagga);
#else
    //SDL_SetVideoMode(xs,ys,32,SDL_DOUBLEBUF|SDL_OPENGL|SDL_FULLSCREEN);
    SDL_SetVideoMode(xs,ys,32,SDL_DOUBLEBUF|flagga);
#endif
    SDL_WM_SetCaption("Leeko",0);
    SDL_ShowCursor(0);

    lego_init();
    dudes_init();
    hakkyra_init();
    tunneli_init();
    spiral_init();
    ball_init();
    writer_init();
    naamat_init();
    SDL_PauseAudio(0);

    while(!quit)
    {
        glClearColor(0,0,0,0);
        glClear(GL_DEPTH_BUFFER_BIT|GL_COLOR_BUFFER_BIT);
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glFrustum(-1,1, -0.75,0.75, 1,10000);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

        run_fx();
        if(beat>=73)
            quit=1;

        SDL_GL_SwapBuffers();
        while(SDL_PollEvent(&e)>0)
        {
            if(e.type==SDL_MOUSEBUTTONDOWN)
                quit=1;
            if(e.type==SDL_QUIT)
                quit=1;
            if(e.type==SDL_KEYDOWN)
                if(e.key.keysym.sym==SDLK_ESCAPE)
                    quit=1;
        }
    }

    SDL_Quit();
    return(EXIT_SUCCESS);
}

#define GREETZ 6

void run_fx(void)
{
    static float tid=0,tid2=0,t,t2,f,turn,turn2;
    static int kuk=-1,first=0,nakki=-1,sika=-1;
    int n;
    char    *txt[]={"i","was","born","in","billund"},
            *greetz[]={"     bw     ","   zenon   ","    rno    "," halcyon ","  unique  ","  exvrc  "};

    if(tid<=0)
        tid=SDL_GetTicks();

    t=(SDL_GetTicks()-tid)/1000.0;
    t2=(SDL_GetTicks()-tid2)/1000.0;

    if(beat>=64)
    {
        if(nakki==-1)
        {
            nakki=glGenLists(GREETZ);
            for(n=0;n<GREETZ;n++)
            {
                glNewList(nakki+n,GL_COMPILE);
                write_string(greetz[n],0, REDI,WR_SINGLE);
                glTranslatef(0,0,-6);
                write_string(greetz[n],1, WHITEI,WR_CHECKER|WR_TWO);
                glEndList();
            }
        }

        if(beat<72)
        {
            glPushMatrix();
            spiral(t);
            glPopMatrix();

            glClear(GL_DEPTH_BUFFER_BIT);
            glPushMatrix();
            glTranslatef(0,-2,-32);
            glRotatef(20-10*(musasynk(4,t*0.7)),1,0,0);
            if(beat>=65 && beat-65<GREETZ)
                glCallList(nakki+beat-65);
            glPopMatrix();
        }
        if(beat>=71)
            pathetic(t2*1.2,WHITEI);
        else
            tid2=SDL_GetTicks();
    }

    if(beat>=48 && beat<56)
    {
        tid2=SDL_GetTicks();

        if(sika==-1)
        {
            sika=glGenLists(3);
            glNewList(sika,GL_COMPILE);
            write_string("toyz",0, BLUEI,WR_SINGLE);
            glEndList();
            glNewList(sika+1,GL_COMPILE);
            write_string("for",0, BLUEI,WR_SINGLE);
            glEndList();
            glNewList(sika+2,GL_COMPILE);
            write_string("boyz",0, BLUEI,WR_SINGLE);
            glEndList();
        }

        glPushMatrix();
        glTranslatef(0,fmod(t*20+20,60)-30,-18);
        glCallList(sika);
        glPopMatrix();
        glPushMatrix();
        glTranslatef(0,fmod(t*20,60)-30,-18);
        glCallList(sika+1);
        glPopMatrix();
        glPushMatrix();
        glTranslatef(0,fmod(t*20-20,60)-30,-18);
        glCallList(sika+2);
        glPopMatrix();

        glPushMatrix();
        glClear(GL_DEPTH_BUFFER_BIT);
        glTranslatef(0,0,2*musasynk(3,t));
        if(beat&1)
            hakkyra(-t);
        else
            hakkyra(t);
        glPopMatrix();
    }

    if(beat>=32 && beat<48)
    {
        tid=SDL_GetTicks();
        glPushMatrix();
        if(beat<36)
        {
            naamat(t2*1.8,0,20-sin(t2/6)*20);
            glTranslatef(7*musasynk(3,t2)-7,15,-44);
            glClear(GL_DEPTH_BUFFER_BIT);
            write_string("codegfx",0, BLUEI,WR_SINGLE);
            turn=t2;
            goto skippi;
        }
        if(beat>=36 && beat<40)
        {
            naamat(12+(turn-t2)*1.8,0,20-sin(t2/6)*20);
            glTranslatef(20-7*musasynk(3,t2),-15,-44);
            glClear(GL_DEPTH_BUFFER_BIT);
            write_string("marq",0, BLUEI,WR_SINGLE);
            turn2=t2;
            goto skippi;
        }
        if(beat>=40 && beat<44)
        {
            naamat((t2-turn2)*1.8,2,20-sin(t2/6)*20);
            glTranslatef(7*musasynk(4,t2)-17,15,-44);
            glClear(GL_DEPTH_BUFFER_BIT);
            write_string("music",0, BLUEI,WR_SINGLE);
            turn=t2;
            goto skippi;
        }
        if(beat>=44)
        {
            naamat(12+(turn-t2)*1.8,2,20-sin(t2/6)*20);
            glTranslatef(27-7*musasynk(4,t2),-15,-44);
            glClear(GL_DEPTH_BUFFER_BIT);
            write_string("roz",0, BLUEI,WR_SINGLE);
        }
        skippi:
        glPopMatrix();
    }

    if(beat<20)
    {
        glPushMatrix();
        if(beat<8 && musasynk(4,t))
            ball1(t);
        if(beat>=8)
            ball1(t2-0.4*musasynk(3,t2));

        f=fmod(t*15,20)-10;
        glPopMatrix();
    }

    if(beat>=8 && beat<20)
    {
        tid=SDL_GetTicks();

        glPushMatrix();
        glClear(GL_DEPTH_BUFFER_BIT);
        for(n=0;n<5;n++)
        {
            glPushMatrix();
            glTranslatef(n*7+13-t2*2.4,0,-9);
            glRotatef(sin(t2*3+n)*60,0,1,0);
            microserf();
            glPopMatrix();
        }
        glClear(GL_DEPTH_BUFFER_BIT);
        glTranslatef(0,0,-26+8*musasynk(3,t2));
        switch((beat-8)/3)
        {
            case 0: write_string("from",0,BLUEI,WR_SINGLE); break;
            case 1: write_string("serfs",0,REDI,WR_SINGLE); break;
            case 2: write_string("to",0,BLUEI,WR_SINGLE); break;
            case 3: write_string("serfs",0,REDI,WR_SINGLE); break;
        }
        glPopMatrix();
    }

    if(beat>=20 && beat<32)
    {
        tid2=SDL_GetTicks();

        glPushMatrix();
        if(beat&1)
            tunneli(t,1);
        else
            tunneli(-t,-1);
        glPopMatrix();

        glPushMatrix();
        glClear(GL_DEPTH_BUFFER_BIT);
        glTranslatef(sin(t*2)*30,-14,-24);
        glRotatef(10*musasynk(3,t),0,1,0);
        glRotatef(sin(t)*5,0,1,0);
        if(beat<30)
            write_string(txt[(beat-20)/2%5],0,YELLOWI,WR_SINGLE);
        glPopMatrix();
    }

    if(beat<8)
    {
        tid2=SDL_GetTicks();

        glClear(GL_DEPTH_BUFFER_BIT);
        glPushMatrix();

        if(kuk==-1)
        {
            kuk=glGenLists(3);

            glNewList(kuk,GL_COMPILE);
            write_string("leeko",0,REDI,WR_SINGLE);
            glTranslatef(0,0,-6);
            write_string("oleekol",1,WHITEI,WR_CHECKER|WR_TWO);
            glEndList();

            glNewList(kuk+1,GL_COMPILE);
            write_string("by",0,REDI,WR_SINGLE);
            glTranslatef(0,0,-6);
            write_string("bybybybyby",1,WHITEI,WR_CHECKER|WR_TWO);
            glEndList();

            glNewList(kuk+2,GL_COMPILE);
            write_string("fit",0,REDI,WR_SINGLE);
            glTranslatef(0,0,-6);
            write_string("fitfitfit",1,WHITEI,WR_CHECKER|WR_TWO);
            glEndList();
        }
        else
        {
            glTranslatef(0,-2,-24+6*musasynk(4,t));
            glRotatef(24,1,0,0);
            switch(beat/2)
            {
                case 1: if(!first) {
                            if(musasynk(4,t)) {
                                first=1;
                                glCallList(kuk);
                            }
                        }
                        else
                            glCallList(kuk);
                        break;
                case 2: if(first==1) {
                            if(musasynk(4,t)) {
                                first=2;
                                glCallList(kuk+1);
                            }
                            else
                                glCallList(kuk);
                        }
                        else
                            glCallList(kuk+1);
                        break;
                case 3: if(first==2) {
                            if(musasynk(4,t)) {
                                first=3;
                                glCallList(kuk+2);
                            }
                            else
                                glCallList(kuk+1);
                        }
                        else
                            glCallList(kuk+2);
                        break;
            }
        }
        glPopMatrix();
    }

    if(beat>=56 && beat<64)
    {
        tid=SDL_GetTicks();

        glPushMatrix();
        if(beat&1)
            hakkyra(-t2);
        else
            hakkyra(t2);
        glClear(GL_DEPTH_BUFFER_BIT);

        if(beat<57)
        {
            f=t2*30-40;
            if(f<0)
                glTranslatef(0,f,0);
        }

        glRotatef(t2*3-20,0,1,0);
        glPushMatrix();
        glTranslatef(0,-6,-13-fmod(t2*3.2,2));
        glScalef(2,1,2);
        lego(14,10,1, 6,0, RED);
        glPopMatrix();

        glTranslatef(0,0,-9);
        walkers(t2,3);
        glTranslatef(0,0,-4);
        walkers(t2+1,2);

        glPopMatrix();
        glClear(GL_DEPTH_BUFFER_BIT);
        glTranslatef(0,0,-33+8*musasynk(3,t2));
        switch((beat-56)/2)
        {
            case 0: write_string("keep",0,BLUEI,WR_SINGLE); break;
            case 1: write_string("walking",0,GREENI,WR_SINGLE); break;
            case 2: write_string("keep",0,BLUEI,WR_SINGLE); break;
            case 3: write_string("smiling",0,GREENI,WR_SINGLE); break;
        }
    }
}

float musasynk(int ins,float tid)
{
    static int last[30]={0},on[30]={0};
    static float   tids[30],d;

    if(last[ins]>lastrig[ins] && !on[ins])
    {
        tids[ins]=tid;
        on[ins]=1;
    }
    last[ins]=lastrig[ins];

    if(tid-tids[ins]<0)
    {
        on[ins]=0;
        return(0);
    }

    d=sqrt(60*(tid-tids[ins]));

    if(d<M_PI && on[ins])
        return(sin(d));
    else
    {
        on[ins]=0;
        return(0);
    }
}
