
#include <math.h>
#include <stdlib.h>
#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif
#include "palikka.h"
#include "volume.h"

#define SIZ 2.5

extern unsigned char naamadata[];

static GLuint lists;

static void valosotku(void);

void naamat_init(void)
{
    lists=glGenLists(5);

    glNewList(lists,GL_COMPILE);
    lego(2,2,1, 5,3, WHITE);
    glEndList();

    glNewList(lists+1,GL_COMPILE);
    lego(2,2,1, 5,0, WHITE);
    glEndList();

    glNewList(lists+2,GL_COMPILE);
    lego(2,2,1, 5,3, BLACK);
    glEndList();

    glNewList(lists+3,GL_COMPILE);
    lego(2,2,1, 5,0, BLACK);
    glEndList();

    glNewList(lists+4,GL_COMPILE);
    lego(42,42,1, 4,0, RED);
    glEndList();
}

void naamat(float tid,int naama,float ang)
{
    int x,y;
    float   h,t;

    glPushMatrix();

    srand(naama);
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

    glTranslatef(0,0,-28);
    glRotatef(90,1,0,0);
    glRotatef(ang,0,1,0);

    glCallList(lists+4);

    glTranslatef(0,1,0);

    glTranslatef(0,0,-7.5*SIZ);
    for(y=0;y<16;y++)
    {
        glPushMatrix();
        glTranslatef(-7.5*SIZ,0,0);
        for(x=0;x<16;x++)
        {
            glPushMatrix();
            t=rand()%640/80.0-tid;
            if(t>0)
                t=0;
            h=30-t*t*10;
            if(h<0)
                h=0;
            glTranslatef(0,h,0);
            glTranslatef(rand()%3/60.0,0,rand()%20/60.0);
            glRotatef(rand()%20-10,0,1,0);
            glRotatef(h*10,1,0.5,0);

            if(h==0)
            {
                if(naamadata[y*48+x+naama*16])
                    glCallList(lists+1);
                else
                    glCallList(lists+3);
            }
            else
            {
                if(naamadata[y*48+x+naama*16])
                    glCallList(lists);
                else
                    glCallList(lists+2);
            }

            glPopMatrix();
            glTranslatef(SIZ,0,0);
        }
        glPopMatrix();
        glTranslatef(0,0,SIZ);
    }

    glPopMatrix();
}

void valosotku(void)
{
    GLfloat vari[4] = {1,1,1,1};
    GLfloat musta[4] = {0,0,0,1};
    GLfloat pos[4] = {10,10,2,1};

    glLightfv(GL_LIGHT0,GL_DIFFUSE,vari);
    glLightfv(GL_LIGHT0,GL_AMBIENT,musta);
    glLightfv(GL_LIGHT0,GL_SPECULAR,vari);
    glLightfv(GL_LIGHT0,GL_POSITION,pos);
    //glLightf(GL_LIGHT0,GL_QUADRATIC_ATTENUATION,0.002);
}
