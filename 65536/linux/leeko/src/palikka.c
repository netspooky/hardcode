/*
    New blocks on the kid
*/

#include <math.h>
#include "palikka.h"

void lego_init(void)
{
    glLightModeli(GL_LIGHT_MODEL_TWO_SIDE,GL_TRUE);
}

/* Hi, I'm a dork and like to write a lot of coordinates by hand */
void lego(int xs,int zs,int center,int nsteps,int psteps,
          GLfloat r,GLfloat g,GLfloat b)
{
    int x,z,n;
    GLfloat fx,fz,color[4]={0,0,0,1.0};
    GLboolean kulli=glIsEnabled(GL_CULL_FACE);
    double d,d2;

    color[0]=r;
    color[1]=g;
    color[2]=b;
    glMaterialfv(GL_FRONT_AND_BACK,GL_DIFFUSE,color);
    color[0]=1;
    color[1]=1;
    color[2]=1;
    glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,color);
    color[0]=0.1;
    color[1]=0.1;
    color[2]=0.1;
    glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT,color);
    glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,100);

    glPushMatrix();
    if(center)
        glTranslatef(-xs/2.0,-LHEIGHT/2.0,zs/2.0);

    glEnable(GL_CULL_FACE);
    /* Nipples on the block */
    if(nsteps)
    {
        for(z=0;z<zs;z++)
        {
            glPushMatrix();
            glTranslatef(0.5,0,-0.5-z);
            fz=z;
            for(x=0;x<xs;x++)
            {
                fx=x;
                glBegin(GL_QUAD_STRIP);
                for(n=0;n<nsteps;n++)
                {
                    d=n*2.0*M_PI/nsteps+M_PI/4.0;
                    d2=d+2.0*M_PI/nsteps;
                    if(!n)
                    {
                        glNormal3f(sin(d),0,cos(d));
                        glVertex3f(sin(d)*NRAD,LHEIGHT+NHEIGHT,cos(d)*NRAD);
                        glVertex3f(sin(d)*NRAD,LHEIGHT,cos(d)*NRAD);
                    }
                    glNormal3f(sin(d2),0,cos(d2));
                    glVertex3f(sin(d2)*NRAD,LHEIGHT+NHEIGHT,cos(d2)*NRAD);
                    glVertex3f(sin(d2)*NRAD,LHEIGHT,cos(d2)*NRAD);
                }
                glEnd();
    
                glNormal3f(0,1,0);
                glBegin(GL_TRIANGLE_FAN);
                glVertex3f(0,LHEIGHT+NHEIGHT,0);
                for(n=0;n<nsteps;n++)
                {
                    d=n*2.0*M_PI/nsteps+M_PI/4.0;
                    d2=d+2.0*M_PI/nsteps;
                    glVertex3f(sin(d)*NRAD,LHEIGHT+NHEIGHT,cos(d)*NRAD);
                    glVertex3f(sin(d2)*NRAD,LHEIGHT+NHEIGHT,cos(d2)*NRAD);
                }
                glEnd();

                glTranslatef(1,0,0);
            }
            glPopMatrix();
        }
    }

    /* Outer sides of the block */
    glBegin(GL_QUADS);
        glNormal3f(0,0,1);
        glVertex3f(0,0,0);
        glVertex3f(xs,0,0);
        glVertex3f(xs,LHEIGHT,0);
        glVertex3f(0,LHEIGHT,0);

        glNormal3f(-1,0,0);
        glVertex3f(0,0,0);
        glVertex3f(0,LHEIGHT,0);
        glVertex3f(0,LHEIGHT,-zs);
        glVertex3f(0,0,-zs);

        glNormal3f(1,0,0);
        glVertex3f(xs,0,0);
        glVertex3f(xs,0,-zs);
        glVertex3f(xs,LHEIGHT,-zs);
        glVertex3f(xs,LHEIGHT,0);

        glNormal3f(0,0,-1);
        glVertex3f(0,0,-zs);
        glVertex3f(0,LHEIGHT,-zs);
        glVertex3f(xs,LHEIGHT,-zs);
        glVertex3f(xs,0,-zs);

    if(nsteps)
    {
        glNormal3f(0,1,0);
        glVertex3f(0,LHEIGHT,0);
        glVertex3f(xs,LHEIGHT,0);
        glVertex3f(xs,LHEIGHT,-zs);
        glVertex3f(0,LHEIGHT,-zs);
    }
    glEnd();

    /* Inside of the block */
    if(psteps)
    {
        glBegin(GL_QUAD_STRIP);
            /* Bottom */
            glNormal3f(0,-1,0);
            glVertex3f(0,0,0);
            glVertex3f(LTHICK,0,-LTHICK);
            glVertex3f(xs,0,0);
            glVertex3f(xs-LTHICK,0,-LTHICK);
    
            glVertex3f(xs,0,-zs);
            glVertex3f(xs-LTHICK,0,-zs+LTHICK);
    
            glVertex3f(0,0,-zs);
            glVertex3f(LTHICK,0,-zs+LTHICK);
    
            glVertex3f(0,0,0);
            glVertex3f(LTHICK,0,-LTHICK);
        glEnd();

        glBegin(GL_QUADS);
            /* Top */
            glVertex3f(LTHICK,LHEIGHT-LTHICK,-zs+LTHICK);
            glVertex3f(xs-LTHICK,LHEIGHT-LTHICK,-zs+LTHICK);
            glVertex3f(xs-LTHICK,LHEIGHT-LTHICK,-LTHICK);
            glVertex3f(LTHICK,LHEIGHT-LTHICK,-LTHICK);

            /* Sides */
            glNormal3f(0,0,1);
            glVertex3f(LTHICK,0,-zs+LTHICK);
            glVertex3f(xs-LTHICK,0,-zs+LTHICK);
            glVertex3f(xs-LTHICK,LHEIGHT-LTHICK,-zs+LTHICK);
            glVertex3f(LTHICK,LHEIGHT-LTHICK,-zs+LTHICK);
    
            glNormal3f(0,0,-1);
            glVertex3f(xs-LTHICK,0,-LTHICK);
            glVertex3f(LTHICK,0,-LTHICK);
            glVertex3f(LTHICK,LHEIGHT-LTHICK,-LTHICK);
            glVertex3f(xs-LTHICK,LHEIGHT-LTHICK,-LTHICK);
    
            glNormal3f(1,0,0);
            glVertex3f(LTHICK,0,-LTHICK);
            glVertex3f(LTHICK,0,-zs+LTHICK);
            glVertex3f(LTHICK,LHEIGHT-LTHICK,-zs+LTHICK);
            glVertex3f(LTHICK,LHEIGHT-LTHICK,-LTHICK);
    
            glNormal3f(-1,0,0);
            glVertex3f(xs-LTHICK,0,-zs+LTHICK);
            glVertex3f(xs-LTHICK,0,-LTHICK);
            glVertex3f(xs-LTHICK,LHEIGHT-LTHICK,-LTHICK);
            glVertex3f(xs-LTHICK,LHEIGHT-LTHICK,-zs+LTHICK);
        glEnd();
    }

    /* The pipes inside the block */
    if(psteps)
    {
        glDisable(GL_CULL_FACE);
        for(z=1;z<zs;z++)
        {
            fz=z;
            for(x=1;x<xs;x++)
            {
                glPushMatrix();
                glTranslatef(x,0,-z);
                fx=x;
                glBegin(GL_QUAD_STRIP);
                for(n=0;n<psteps;n++)
                {
                    d=n*2.0*M_PI/psteps+M_PI/4.0;
                    d2=d+2.0*M_PI/psteps;
                    if(!n)
                    {
                        glNormal3f(sin(d),0,cos(d));
                        glVertex3f(sin(d)*PRAD,LHEIGHT-LTHICK,cos(d)*PRAD);
                        glVertex3f(sin(d)*PRAD,LTHICK,cos(d)*PRAD);
                    }

                    glNormal3f(sin(d2),0,cos(d2));
                    glVertex3f(sin(d2)*PRAD,LHEIGHT-LTHICK,cos(d2)*PRAD);
                    glVertex3f(sin(d2)*PRAD,LTHICK,cos(d2)*PRAD);
                }
                glEnd();
    
                glPopMatrix();
            }
        }
    }

    if(kulli)
        glEnable(GL_CULL_FACE);

    glPopMatrix();
}
