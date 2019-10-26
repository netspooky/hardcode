
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "wavefront.h"
#include "gl_render.h"

#include <SDL_opengl.h>

static GLint lname[8]={GL_LIGHT0,GL_LIGHT1,GL_LIGHT2,GL_LIGHT3,
                       GL_LIGHT4,GL_LIGHT5,GL_LIGHT6,GL_LIGHT7};

void render_scene(SCENE *s,int type)
{
    OBJ *o;
    int n;

    glPushAttrib(GL_ALL_ATTRIB_BITS);

    if(s->lighting)
        for(n=0;n<8;n++)
            glDisable(lname[n]);
    
    o=s->objects;
    while(o!=NULL && (type&RENDER_NORMAL))
    {
        if(o->type==TYPE_POINT)
            render_object(s,o,0);
        o=o->next;
    }

    o=s->objects;
    while(o!=NULL)
    {
        if(o->type!=TYPE_POINT)
            render_object(s,o,type);
        o=o->next;
    }

    glPopAttrib();
}

void render_object(SCENE *s,OBJ *o,int type)
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

    /* Add rotation if there's a pivot point */
/*    if(o->pivot!=NULL)
    {
        tx=o->pivot->tx;
        ty=o->pivot->ty;
        tz=o->pivot->tz;
        glTranslatef(tx,ty,tz);
        glRotatef(o->rot,o->pivot->x,o->pivot->y,o->pivot->z);
    }*/

    /* Point lights */
/*    if(o->type==TYPE_POINT)
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
    }*/

    /* "Cartoon rendered" object */
    if(type&RENDER_CARTOON)
    {
        glLineWidth(5.0);
        glColor3f(0,0,0);
        glDisable(GL_LIGHTING);
        glEnable(GL_CULL_FACE);

        glPushMatrix();
        glCullFace(GL_FRONT);
        glPolygonMode(GL_BACK,GL_LINE);

        glEnable(GL_POLYGON_OFFSET_LINE);
        glPolygonOffset(1,1);
        while(p!=NULL)
        {
            if(p->dlist==-1)
            {
                p->dlist=glGenLists(1);
                glNewList(p->dlist,GL_COMPILE);
                f=p->faces;
                while(f!=NULL)
                {
                    glBegin(GL_POLYGON);
                    for(n=0;n<f->num;n++)
                        glVertex3f(s->v[f->index[n]*3]-tx,s->v[f->index[n]*3+1]-ty,
                                   s->v[f->index[n]*3+2]-tz);
                    glEnd();
                    f=f->next;
                }
                glEndList();
            }
            else
                glCallList(p->dlist);

            p=p->next;
        }
        glPopMatrix();
        glDisable(GL_POLYGON_OFFSET_LINE);

        p=o->parts;
        glCullFace(GL_BACK);

        glEnable(GL_POLYGON_OFFSET_FILL);
        glPolygonOffset(0,0);
        while(p!=NULL)
        {
            glColor3f(p->material->diffuse[0],p->material->diffuse[1],
                      p->material->diffuse[2]);

            glCallList(p->dlist);
    
            p=p->next;
        }
        glDisable(GL_POLYGON_OFFSET_FILL);
    }
    else /* Gouraud and wireframe */
    {
        if(type&RENDER_NORMAL)
            glEnable(GL_CULL_FACE);
        else
            glDisable(GL_CULL_FACE);

        glLineWidth(2.0);
        lighti=0;
        while(p!=NULL)
        {
            if(type&RENDER_NOLIGHTS)
            {
                glColor3fv(p->material->diffuse);
            }
            else
            {
                glMaterialfv(GL_FRONT,GL_DIFFUSE,p->material->diffuse);
                glMaterialfv(GL_FRONT,GL_AMBIENT,p->material->ambient);
                glMaterialfv(GL_FRONT,GL_SPECULAR,p->material->specular);
                glMaterialf(GL_FRONT,GL_SHININESS,p->material->shininess);
            }

            f=p->faces;
            while(f!=NULL)
            {
                if(type&RENDER_NORMAL)
                    glBegin(GL_POLYGON);
                if(type&RENDER_WIRE)
                    glBegin(GL_LINE_LOOP);
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
    }

    glPopMatrix();
}
