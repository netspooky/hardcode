
#include <math.h>
#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif
#include "palikka.h"
#include "volume.h"

#define CUBES 3

static GLuint lists;

static void valosotku(void);
void hakkyra_init(void);
void hakkyra(float tid);

void hakkyra_init(void)
{
    int n,i,x,y,z,flagga,size,ysize;
    static unsigned char blk[CUBES][20*20*20];

    lists=glGenLists(3);
    for(n=0;n<CUBES;n++)
    {
        size=n*3+1;
        ysize=n*5+1;
        for(i=z=0;z<size;z++)
            for(y=0;y<ysize;y++)
                for(x=0;x<size;x++,i++)
                {
                    flagga=0;
                    if(x==0) flagga++;
                    if(x==size-1) flagga++;
                    if(y==0) flagga++;
                    if(y==ysize-1) flagga++;
                    if(z==0) flagga++;
                    if(z==size-1) flagga++;

                    if(flagga>1)
                        blk[n][i]=2+((x+y+z)&1);
                    else
                        blk[n][i]=0;
                }

        glNewList(lists+n,GL_COMPILE);
        draw_volume(1,8,blk[n],size,ysize,size);
        glEndList();
    }
}

void hakkyra(float tid)
{
    int n;

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
    valosotku();

    glTranslatef(0,0,-14);
    glRotatef(tid*30,1,0,0);

    for(n=0;n<CUBES;n++)
    {
        glPushMatrix();
        glRotatef(40*sin(tid*3-n),0,0,1);
        glRotatef(15*sin(tid*1.1-n),0,1,0);
        glCallList(lists+n);
        glPopMatrix();
    }

    glPopMatrix();
}

void valosotku(void)
{
    GLfloat vari[4] = {1,1,1,1};
    GLfloat musta[4] = {0,0,0,1};
    GLfloat pos[4] = {0,0,2,1};

    glLightfv(GL_LIGHT0,GL_DIFFUSE,vari);
    glLightfv(GL_LIGHT0,GL_AMBIENT,musta);
    glLightfv(GL_LIGHT0,GL_SPECULAR,vari);
    glLightfv(GL_LIGHT0,GL_POSITION,pos);
    glLightf(GL_LIGHT0,GL_QUADRATIC_ATTENUATION,0.001);
    glLightf(GL_LIGHT0,GL_LINEAR_ATTENUATION,0);
}
