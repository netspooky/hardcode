
#include <string.h>
#include <stdlib.h>
#include <math.h>
#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif
#include "palikka.h"
#include "volume.h"

#define DIM 40
#define TUNNEL 6

static GLuint list;

static void valosotku(float z);

void tunneli_init(void)
{
    int i;
    static char tau[DIM*DIM*1];
    double  ang,r;

    list=glGenLists(1);

    memset(tau,0,DIM*DIM);
    glNewList(list,GL_COMPILE);
    r=0.50;
    for(ang=0;ang<=M_PI*2.0;ang+=0.02)
    {
        i=((int)(10.0*r*sin(ang)))*DIM+(int)(cos(ang)*r*6.0-0.5);
        i+=DIM/2+DIM*DIM/2;
        if(i>=0 && i<DIM*DIM)
            tau[i]=2+i%3;
            //tau[i]=1+rand()%2;
    }
    for(i=0;i<10;i++)
        tau[rand()%(DIM*DIM)]=1+rand()%2;

    draw_volume(1,6,tau,DIM,DIM,1);
    glEndList();
}

void tunneli(float tid,int dir)
{
    int n;
    float   dist;

    glPushMatrix();
    glEnable(GL_LIGHTING);
    glShadeModel(GL_SMOOTH);
    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHT0);
    glDisable(GL_LIGHT1);
    glDisable(GL_LIGHT2);
    glDisable(GL_LIGHT3);
    glEnable(GL_DEPTH_TEST);

    dist=fmod(tid*25,10);
    valosotku(-3);

    glRotatef(sin(tid/2.0)*20,0,1,0);
    if(dir==1)
        glTranslatef(0,0,-60);
    else
        glTranslatef(0,0,-50);

    glRotatef(sin(tid/20.0)*80.0,0,0,1);
    for(n=0;n<TUNNEL;n++)
    {
        glPushMatrix();
        glTranslatef(0,0,dist+n*10);

        glRotatef(sin(tid/10*2*M_PI +dist/20+n/2.0)*40.0,0,0,1);
        glRotatef(sin(tid*2)*20.0,0,1,0);
        glTranslatef(sin(tid/20.0 +dist/10+n),0,0);
        glCallList(list);
        glPopMatrix();
    }

    glPopMatrix();
    glLightf(GL_LIGHT0,GL_QUADRATIC_ATTENUATION,0);
}

void valosotku(float z)
{
    GLfloat vari[4] = {1,1,1,1};
    GLfloat musta[4] = {0,0,0,1};
    GLfloat pos[4] = {0,0,z,1};

    glLightfv(GL_LIGHT0,GL_DIFFUSE,vari);
    glLightfv(GL_LIGHT0,GL_AMBIENT,musta);
    glLightfv(GL_LIGHT0,GL_SPECULAR,vari);
    glLightfv(GL_LIGHT0,GL_POSITION,pos);

    glLightf(GL_LIGHT0,GL_QUADRATIC_ATTENUATION,0.002);
    glLightf(GL_LIGHT0,GL_LINEAR_ATTENUATION,0);
}
