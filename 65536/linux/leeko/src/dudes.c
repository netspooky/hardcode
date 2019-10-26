
#include <math.h>
#include "wavefront.h"
#include "dump.h"
#include "gl_render.h"
#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif

extern unsigned char serfdata[],walkerdata[];

static SCENE lego,serf;

static void valosotku(void);

void dudes_init()
{
    get_dump(&lego,walkerdata);
    get_dump(&serf,serfdata);
}

void walkers(float tid,int num)
{
    int n;

    glPushMatrix();
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHTING);

    glTranslatef(0,sin(tid*10)/10.0-0.5,0);

    find_object(&lego,"rarm")->rot=sin(-tid*5)*60+10;
    find_object(&lego,"larm")->rot=sin(-tid*5)*60-10;
    find_object(&lego,"head")->rot=sin(tid*5)*15;
    find_object(&lego,"lfoot")->rot=sin(tid*5)*40;
    find_object(&lego,"rfoot")->rot=sin(tid*5)*40;

    glTranslatef(-num/2.0*7.0+3.5,0,0);
    for(n=0;n<num;n++)
    {
        glPushMatrix();
        glTranslatef(7*n,0,0);
        glRotatef(sin(-tid*5-M_PI/2)*2.0,0,0,1);
        render_scene(&lego);
        glPopMatrix();
    }

    glPopMatrix();
}

void microserf(void)
{
    valosotku();
    glEnable(GL_LIGHT0);
    glPushMatrix();
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHTING);
    glTranslatef(0,-2,0);
    render_scene(&serf);
    glPopMatrix();
}

void valosotku(void)
{
    GLfloat vari[4] = {1,1,1,1};
    GLfloat musta[4] = {0.3,0.3,0.3,1};
    GLfloat pos[4] = {2,6,10,1};

    glLightfv(GL_LIGHT0,GL_DIFFUSE,vari);
    glLightfv(GL_LIGHT0,GL_AMBIENT,musta);
    glLightfv(GL_LIGHT0,GL_SPECULAR,vari);
    glLightfv(GL_LIGHT0,GL_POSITION,pos);

    /* glLightf(GL_LIGHT0,GL_QUADRATIC_ATTENUATION,0.002);
    glLightf(GL_LIGHT0,GL_LINEAR_ATTENUATION,0); */
}
