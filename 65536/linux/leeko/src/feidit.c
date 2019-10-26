
#include <math.h>
#include <stdlib.h>
#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif
#include "volume.h"
#include "palikka.h"

#define XS 9
#define YS 11

static void valosotku(void);

void pathetic(float phase,int base)
{
    int n,plus;
    static char blks[XS*YS];

    glPushMatrix();
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    valosotku();
    srand(1); /* We want the same numbers all over again */

    for(n=0;n<XS*YS;n++)
    {
        blks[n]=0;

        plus=phase*70.0+n-25;
        if(rand()%40+plus>=120)
            blks[n]=base+n%2;
        if(rand()%40+plus>=260)
            blks[n]=0;
    }

    glTranslatef(0,0,-8.5);
    glRotatef(cos(phase*0.7)*5.0,0,0,1);
    draw_volume(1,6,blks, XS,YS,1);
    glPopMatrix();
}

void valosotku(void)
{
    GLfloat vari[4] = {1,1,1,1};
    GLfloat musta[4] = {0.4,0.4,0.4,1};
    GLfloat pos[4] = {2,6,10,1};

    glLightfv(GL_LIGHT0,GL_DIFFUSE,vari);
    glLightfv(GL_LIGHT0,GL_AMBIENT,musta);
    glLightfv(GL_LIGHT0,GL_SPECULAR,vari);
    glLightfv(GL_LIGHT0,GL_POSITION,pos);

    glLightf(GL_LIGHT0,GL_QUADRATIC_ATTENUATION,0);
    glLightf(GL_LIGHT0,GL_LINEAR_ATTENUATION,0);
}
