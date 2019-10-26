/*
    A quick & dirty 64k for Ass'06
*/

#include <SDL.h>
#include <SDL_opengl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "cool_mzx.h"
#include "wavefront.h"
#include "dump.h"
#include "gl_render.h"

extern short *aanibuf;
extern int aanilen;

int main(int argc, char *argv[])
{
  SDL_Event e;
  int n,quit=0,xs=640,ys=480,x,y,modpos,monta,iso,last=-1,oldie=-1;
  GLint tname;
  static char motti[100000];
  FILE *f;
  SCENE s[4];
  float str=0.01,angle=0,ff;

  /* The script of the demo */
  int monet[]={-1,-1, 0,2,0,2, -1,-1,-1,-1,-1, 1,1,3, 0,1,3,3,   -1};
  int isot[] ={-1,0,  0,1,3,2, -1,-1,2,3,0, 2,-1,0, 0,-1,3,-1,      -1};
  int vaiht[]={0,0,   1,1,1,1, 0,0,0,0,0, 0,0,0, 1,1,0,0,   0};
  int skobe[]={1,1,   0,0,0,0, 1,3,3,2,0, 0,1,0, 1,3,2,1,   1};
  int kliin[]={1,1,   1,1,1,1, 1,0,1,1,0, 1,1,1, 1,1,1,1,   1};
  float shi[]={0.03,0.03, 0,0.02,0,0.05, 0.11,0.18,0.06,0.03,0.02, 0,0.03,0, 0,0.04,0,0,   0.01};
  int valk[]={0,0,    1,1,1,1, 1,1,1,1,1, 1,1,1, 1,1,1,1,   0};
  int kart[]={0,0,    0,0,0,0, 0,0,0,1,0, 0,1,0, 0,0,0,0, 0};

  SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER|SDL_INIT_AUDIO);

  f=fopen("misty_luv2.mod","rb");
  fread(motti,1,100000,f);
  fclose(f);
  ungetc('\n',stdin);
  ungetc('2',stdin);
  mzx_init();
  mzx_get(motti);

  if(argc>=2 || argv[0][strlen(argv[0])-1]=='w')
      SDL_SetVideoMode(xs,ys,32,SDL_OPENGL);
  else
      SDL_SetVideoMode(xs,ys,32,SDL_OPENGL+SDL_FULLSCREEN);
  SDL_ShowCursor(0);
  SDL_WM_SetCaption("Emo Defect by The Fiture Crew",0);

    load_dump(&s[0],"kuutio.dump");
    load_dump(&s[1],"pallo.dump");
    load_dump(&s[2],"piikit.dump");
    load_dump(&s[3],"ratas.dump");

    /* Set up the shine */
    glGenTextures(1,&tname);
    glBindTexture(GL_TEXTURE_2D,tname);

    glPixelStorei(GL_UNPACK_ALIGNMENT,1);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,1024,512,0,GL_RGBA,GL_UNSIGNED_BYTE,NULL);

    mzx_start(50);
    while(mzx_position()<0 || mzx_position()>100) // Skip bug...
        ;

  while(!quit)
  {
    while(SDL_PollEvent(&e)>0)
    {
       if(e.type==SDL_KEYDOWN)
        if(e.key.keysym.sym==SDLK_ESCAPE)
          quit++;
    }
    modpos=mzx_position();

    /* Blinking */
    if(valk[modpos/100])
    {
        if(modpos%64%4==0)
        {
            if(last==-1)
                last=SDL_GetTicks();
            ff=cos((SDL_GetTicks()-last)/100.0*M_PI-0.2)/2.0;
            glClearColor(ff,ff,ff,0);
        }
        else
        {
            last=-1;
            glClearColor(0,0,0,0);
        }
    }
    else
    {
        last=-1;
        glClearColor(0,0,0,0);
    }

    /* Clear bg or not */
    if(kliin[modpos/100])
        glClear(GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT);
    else
        glClear(GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    /* Waveform display */
    if(skobe[modpos/100] && aanibuf)
    {
        glLineWidth(4);
        glColor3f(1,1,1);

        if(skobe[modpos/100]==3)
        {
            glDisable(GL_CULL_FACE);
            glBegin(GL_QUAD_STRIP);
            for(n=0;n<aanilen/2;n+=16)
            {
                glVertex3f((n/(double)aanilen)*4-1,aanibuf[n]/50000.0,0);
                glVertex3f((n/(double)aanilen)*4-1,0,0);
            }
            glEnd();
            glEnable(GL_CULL_FACE);
        }
        else
        {
            glBegin(GL_LINE_STRIP);
            for(n=0;n<aanilen/2;n+=16)
                glVertex3f((n/(double)aanilen)*4-1,aanibuf[n]/60000.0,0);
            glEnd();
    
            if(skobe[modpos/100]==2)
            {
                glLineWidth(3);
                glColor3f(1,1,1);
                glBegin(GL_LINE_STRIP);
                for(n=0;n<aanilen/2;n+=64)
                    glVertex3f((n/(double)aanilen)*4-1,aanibuf[n]/60000.0-0.4,0);
                glEnd();
    
                glLineWidth(3);
                glColor3f(1,1,1);
                glBegin(GL_LINE_STRIP);
                for(n=0;n<aanilen/2;n+=64)
                    glVertex3f((n/(double)aanilen)*4-1,aanibuf[n]/60000.0+0.4,0);
                glEnd();
            }
        }
    }
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-0.2,0.2, -0.15,0.15, 0.3, 100000);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    /* Red ball part */
    if(modpos>=600 && modpos<800)
    {
        glTranslatef(0,0,-1.1);
        glRotatef(SDL_GetTicks()/6.0,0,0,1);
        glRotatef(SDL_GetTicks()/9.0,1,0.2,0);
        glEnable(GL_LIGHTING);
        glEnable(GL_LIGHT0);
        render_scene(&s[1],RENDER_NORMAL);
        glLoadIdentity();
        glDisable(GL_LIGHTING);
    }

    /* Background object */
    iso=isot[modpos/100];
    if(iso!=-1)
    {
        if(modpos/100&1 && modpos/100!=9)
            glTranslatef(0,0,-1.3+0.5*sin(SDL_GetTicks()/200.0));
        else
            glTranslatef(0,0,-1.3);
        if(modpos/100==9)
            glTranslatef(0,0,-0.3);

        glRotatef(SDL_GetTicks()/9.0,0,0,1);
        glRotatef(SDL_GetTicks()/31.0,0,1,0);
        glDisable(GL_LIGHTING);
        //glEnable(GL_LIGHT0);
        if(kart[modpos/100])
            render_scene(&s[iso],RENDER_CARTOON);
        else
            render_scene(&s[iso],RENDER_WIRE+RENDER_NOLIGHTS);
        glLoadIdentity();
        glClear(GL_DEPTH_BUFFER_BIT);
    }

    /* Foreground objects */
    monta=monet[modpos/100];
    if(monta!=-1)
    {
        glTranslatef(0,0,-6);
        if(vaiht[modpos/100])
        {
            if(modpos%64/4&1)
                glRotatef(SDL_GetTicks()/6.0,0,0,1);
            else
                glRotatef(10000.0-SDL_GetTicks()/6.0,0,0,1);
        }
        else
            glRotatef(SDL_GetTicks()/6.0,0,0,1);

        if(modpos/100==17)
        {
            if(oldie==-1)
                oldie=SDL_GetTicks();
            glTranslatef(0,0,(SDL_GetTicks()-oldie)/800.0);
        }

        if(modpos/100>=10)
            glRotatef(sin(SDL_GetTicks()/600.0)*22.0,1,0,0);

        for(y=0;y<5;y++)
            for(x=0;x<5;x++)
            {
                glPushMatrix();
                glTranslatef((x-2)*1.99,(y-2)*1.99,0);
                glRotatef(SDL_GetTicks()/(10.0-x)+y/2.0,0,0,1);
                glRotatef(SDL_GetTicks()/(15.0+y),0,1,0);
                //glRotatef(SDL_GetTicks()/(10.0-x)+y/2.0,0,1,0);
                //glRotatef(SDL_GetTicks()/(15.0+y),1,0,0);
                glEnable(GL_LIGHTING);
                glEnable(GL_LIGHT0);
                if(modpos>=1600)
                    render_scene(&s[monta],RENDER_CARTOON);
                else
                    render_scene(&s[monta],RENDER_NORMAL);
                glPopMatrix();
            }
        glLoadIdentity();
    }

    /* Shine */
    glDisable(GL_LIGHTING);
    glLoadIdentity();

    if(shi[modpos/100])
    {
        str=shi[modpos/100];
        glPushAttrib(GL_ALL_ATTRIB_BITS);

        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE,GL_ONE);
        glDisable(GL_LIGHTING);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_STENCIL_TEST);
    
        glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D,tname);
    
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
    
        glColor3f(str,str,str);
        glCopyTexSubImage2D(GL_TEXTURE_2D,0, 0,0, 0,0, 640,480);
        for(n=0;n<15;n++)
        {
            glBegin(GL_POLYGON);
                glTexCoord2f(0,0);
                glVertex2f(-1,-1);
                glTexCoord2f(640.0/1024.0,0);
                glVertex2f(1,-1);
                glTexCoord2f(640.0/1024.0,480.0/512.0);
                glVertex2f(1,1);
                glTexCoord2f(0,480.0/512.0);
                glVertex2f(-1,1);
            glEnd();
    
            glScalef(1.02,1.02,1.02);
            glRotatef(angle,0,0,1);
        }
    
        glPopAttrib();
    }

    SDL_GL_SwapBuffers();

    if(modpos>=1848)
        quit++;
  }

  mzx_close();
  SDL_Quit();
}
