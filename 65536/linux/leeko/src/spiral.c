
#include <math.h>
#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif
#include "palikka.h"
#include "volume.h"

static GLuint lists;

static void valosotku(void);

void spiral_init(void)
{
    int n;
    double  r;

    glEnable(GL_LIGHTING);
    glShadeModel(GL_SMOOTH);
    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);

    lists=glGenLists(2);
    glNewList(lists,GL_COMPILE);
    for(n=0;n<55;n++)
    {
        r=sqrt(n+0.5)*4.0;
        glPushMatrix();
        glTranslatef(sin(r/1.3)*r/1.5,0,cos(r/1.3)*r/1.5);
        glRotatef(r*57.3/1.3-5.0,0,1,0);
        if(n&1)
            lego(2,2,1, 8,0, WHITE);
        else
            lego(3,2,1, 8,0, WHITE);
        glPopMatrix();
    }
    glEndList();

    glNewList(lists+1,GL_COMPILE);
    for(n=0;n<75;n++)
    {
        r=sqrt(n+0.5)*4.0;
        glPushMatrix();
        glTranslatef(sin(r/1.3)*r/1.5,0,cos(r/1.3)*r/1.5);
        glRotatef(r*57.3/1.3-5.0,0,1,0);
        if(n&1)
            lego(2,2,1, 8,0, RED);
        else
            lego(3,2,1, 8,0, RED);
        glPopMatrix();
    }
    glEndList();
}

void spiral(float tid)
{
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

    glTranslatef(0,0,-13);
    glRotatef(90,1,0,0);
    glRotatef(-tid*90,0,1,0);

    glRotatef(sin(tid*2.0)*10,0,0,1);
    glCallList(lists);

    glRotatef(tid*20.0,0,1,0.1);
    glRotatef(-10,0,0,1);
    glTranslatef(0,-4,0);
    glCallList(lists+1);

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
    //glLightf(GL_LIGHT0,GL_QUADRATIC_ATTENUATION,0.002);
}
