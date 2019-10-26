
#include <stdlib.h>
#include <math.h>
#include "wavefront.h"
#include "gl_render.h"

#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif

static GLint lname[8]={GL_LIGHT0,GL_LIGHT1,GL_LIGHT2,GL_LIGHT3,
                       GL_LIGHT4,GL_LIGHT5,GL_LIGHT6,GL_LIGHT7};

void render_scene(SCENE *s)
{
    OBJ *o;
    int n;

    if(s->lighting)
        for(n=0;n<8;n++)
            glDisable(lname[n]);
    
    o=s->objects;
    while(o!=NULL)
    {
        if(o->type==TYPE_POINT)
            render_object(s,o);
        o=o->next;
    }

    o=s->objects;
    while(o!=NULL)
    {
        if(o->type!=TYPE_POINT)
            render_object(s,o);
        o=o->next;
    }
}

void render_object(SCENE *s,OBJ *o)
{
    PART *p;
    FACE *f;
    static int n,lighti=0;
    GLfloat tx=0,ty=0,tz=0,param[4];
    GLint   light;

    if(o->type==TYPE_PIVOT)
        return;

    p=o->parts;

    glPushMatrix();

    if(o->pivot!=NULL)
    {
        tx=o->pivot->tx;
        ty=o->pivot->ty;
        tz=o->pivot->tz;
        glTranslatef(tx,ty,tz);
        glRotatef(o->rot,o->pivot->x,o->pivot->y,o->pivot->z);
    }

    if(o->type==TYPE_POINT)
    {
        light=lname[lighti];
        lighti++;

        glEnable(light);
        glLightfv(light,GL_AMBIENT,p->material->ambient);
        glLightfv(light,GL_SPECULAR,p->material->specular);
        glLightfv(light,GL_DIFFUSE,p->material->diffuse);
        param[0]=s->v[o->parts->faces->index[0]*3];
        param[1]=s->v[o->parts->faces->index[0]*3+1];
        param[2]=s->v[o->parts->faces->index[0]*3+2];
        param[3]=0;
        glLightfv(light,GL_POSITION,param);
        glLightf(light,GL_CONSTANT_ATTENUATION,1);
        glLightf(light,GL_LINEAR_ATTENUATION,0);
        glLightf(light,GL_QUADRATIC_ATTENUATION,0);
        glLightf(light,GL_SPOT_CUTOFF,180.0);

        glPopMatrix();
        return;
    }

    lighti=0;
    while(p!=NULL)
    {
        glMaterialfv(GL_FRONT,GL_DIFFUSE,p->material->diffuse);
        glMaterialfv(GL_FRONT,GL_AMBIENT,p->material->ambient);
        glMaterialfv(GL_FRONT,GL_SPECULAR,p->material->specular);
        glMaterialf(GL_FRONT,GL_SHININESS,p->material->shininess);

        f=p->faces;
        while(f!=NULL)
        {
            glBegin(GL_POLYGON);
            for(n=0;n<f->num;n++)
            {
                glNormal3f(s->vn[f->normal[n]*3],s->vn[f->normal[n]*3+1],
                           s->vn[f->normal[n]*3+2]);
                glVertex3f(s->v[f->index[n]*3]-tx,s->v[f->index[n]*3+1]-ty,
                           s->v[f->index[n]*3+2]-tz);
            }
            glEnd();
            f=f->next;
        }

        p=p->next;
    }
    glPopMatrix();
}
