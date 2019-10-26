
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

void ball_init(void)
{
    int n;
    double  r,r2;

    lists=glGenLists(2);
    glNewList(lists,GL_COMPILE);
    for(n=1;n<100;n++)
    {
        glPushMatrix();

        if(n<50)
            r2=sqrt(n)*4.0;
        else
            r2=(M_PI/2.0-sqrt(100-n))*4.0;

        r=sqrt(fabs(50*50-(n-50)*(n-50)))/6;
        glTranslatef(sin(r2)*r,-n/6.0,cos(r2)*r);
        glRotatef(r2*57.3,0,1,0);
        glRotatef(n*1.8+180,1,0,0);
        if(n%2)
            lego(3,2,1, 6,0, RED);
        else
            lego(1,2,1, 6,0, YELLOW);

        glPopMatrix();
    }
    glEndList();

    glNewList(lists+1,GL_COMPILE);
    for(n=1;n<100;n+=2)
    {
        glPushMatrix();

        if(n<50)
            r2=sqrt(n)*4.0;
        else
            r2=(M_PI/2.0-sqrt(100-n))*4.0;

        r=sqrt(fabs(50*50-(n-50)*(n-50)))/6;
        glTranslatef(sin(r2)*r,(50-n)/6.0,cos(r2)*r);
        glRotatef(r2*57.3,0,1,0);
        glRotatef(n*1.8,1,0,0);

        lego(3,2,1, 5,3, lclr[2+n%3][0],lclr[2+n%3][1],lclr[2+n%3][2]);

        glPopMatrix();
    }
    glEndList();
}

void ball1(float tid)
{
    glPushMatrix();

    glEnable(GL_LIGHTING);
    glShadeModel(GL_SMOOTH);
    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHT0);
    glDisable(GL_LIGHT1);
    glDisable(GL_LIGHT2);
    glEnable(GL_DEPTH_TEST);

    valosotku();

    glTranslatef(0,0,-7.8);
    glRotatef(tid*10,0,1,0);
    glRotatef(tid*80,1,0,0);

    glTranslatef(0,8,0);
    glCallList(lists);

    glPopMatrix();
}

void ball2(float tid,int rot)
{
    glPushMatrix();

    glEnable(GL_LIGHTING);
    glShadeModel(GL_SMOOTH);
    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);
    glEnable(GL_LIGHT0);
    glDisable(GL_LIGHT1);
    glDisable(GL_LIGHT2);
    glEnable(GL_DEPTH_TEST);

    glPushMatrix();
    glTranslatef(1,10,40);
    valosotku();
    glPopMatrix();
    if(rot)
    {
        glRotatef(tid*120,0,1,0);
        glRotatef(tid*30,0,0,1);
    }
    glCallList(lists+1);

    glPopMatrix();
}

void valosotku(void)
{
    GLfloat vari[4] = {1,1,1,1};
    GLfloat musta[4] = {0.2,0.2,0.2,1};
    GLfloat pos[4] = {0,0,0,1};

    glLightfv(GL_LIGHT0,GL_DIFFUSE,vari);
    glLightfv(GL_LIGHT0,GL_AMBIENT,musta);
    glLightfv(GL_LIGHT0,GL_SPECULAR,vari);
    glLightfv(GL_LIGHT0,GL_POSITION,pos);
    glLightf(GL_LIGHT0,GL_QUADRATIC_ATTENUATION,0);
    glLightf(GL_LIGHT0,GL_LINEAR_ATTENUATION,0);
}
