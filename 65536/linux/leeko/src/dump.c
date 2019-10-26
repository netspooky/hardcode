
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "wavefront.h"
#include "dump.h"

static void writefloat(FILE *fp,float f);
static void writeint(FILE *fp,unsigned c,int len);
static float getfloat(unsigned char **p);
static unsigned getint(unsigned char **p,int len);

int dump_scene(SCENE *s,char *name)
{
    MTL *m;
    OBJ *o;
    PART *p;
    FACE *f;
    FILE *fp;
    int n,ker;
    float   max;

    fp=fopen(name,"wb");
    if(fp==NULL || s==NULL)
        return(-1);

    /* Vertex data */
    /*writeint(fp,s->vs,4);
    for(n=0;n<s->vs*3;n++)
        writefloat(fp,s->v[n]);
    writeint(fp,s->vns,4);
    for(n=0;n<s->vns*3;n++)
        writefloat(fp,s->vn[n]);*/

    max=0;
    for(n=0;n<s->vs*3;n++)
        if(fabs(s->v[n])>max)
            max=fabs(s->v[n]);
    for(n=0;n<s->vns*3;n++)
        if(fabs(s->vn[n])>max)
            max=fabs(s->vn[n]);
    ker=(int)((float)32767/(max+1.0));

    writeint(fp,ker,2);
    writeint(fp,s->vs,4);
    for(n=0;n<s->vs*3;n++)
        writeint(fp,s->v[n]*ker,2);
    writeint(fp,s->vns,4);
    for(n=0;n<s->vns*3;n++)
        writeint(fp,s->vn[n]*ker,2);

    /* Materials */
    m=s->materials;
    while(m!=NULL)
    {
        fputc('m',fp);
        fwrite(m->name,1,strlen(m->name)+1,fp);
        for(n=0;n<3;n++)
            writefloat(fp,m->ambient[n]);
        for(n=0;n<3;n++)
            writefloat(fp,m->diffuse[n]);
        for(n=0;n<3;n++)
            writefloat(fp,m->specular[n]);
        writefloat(fp,m->opacity);
        writefloat(fp,m->shininess);

        m=m->next;
    }

    /* Objects and related data */
    o=s->objects;
    while(o!=NULL)
    {
        fputc('o',fp);
        fwrite(o->name,1,strlen(o->name)+1,fp);

        p=o->parts;
        while(p!=NULL)
        {
            fputc('g',fp);
            fwrite(p->name,1,strlen(p->name)+1,fp);
            fwrite(p->material->name,1,strlen(p->material->name)+1,fp);
            n=0;
            f=p->faces;
            while(f!=NULL)
            {
                n++;
                f=f->next;
            }
            writeint(fp,n,2);
            f=p->faces;
            while(f!=NULL)
            {
                fputc(f->num,fp);
                for(n=0;n<f->num;n++)
                    writeint(fp,f->index[n],2);
                for(n=0;n<f->num;n++)
                    writeint(fp,f->normal[n],2);
                f=f->next;
            }

            p=p->next;
        }

        o=o->next;
    }
    fputc('q',fp);

    return(0);
}

int load_dump(SCENE *s,char *name)
{
    FILE *fp;
    unsigned char *data;
    int len;

    fp=fopen(name,"rb");
    if(fp==NULL)
        return(-1);

    fseek(fp,0,SEEK_END);
    len=ftell(fp);
    fseek(fp,0,SEEK_SET);
    data=malloc(len);
    if(data==NULL)
        return(-1);
    fread(data,1,len,fp);
    fclose(fp);

    return(get_dump(s,data));
}

int get_dump(SCENE *s,unsigned char *data)
{
    int n,i,num,pts,quit=0;
    unsigned char c;
    char key[1000];
    float   ker;
    MTL *m;
    OBJ *o=NULL,*o2;
    PART *p;
    FACE *f;

    s->objects=NULL;
    s->materials=NULL;
    s->lighting=0;

    /* Vertices */
    num=getint(&data,2);
    ker=num;

    num=getint(&data,4);
    s->vs=num;
    s->v=malloc(num*3*sizeof(float));
    if(s->v==NULL)
        return(-1);
    /*for(n=0;n<num*3;n++)
        s->v[n]=getfloat(&data);*/
    for(n=0;n<num*3;n++)
        s->v[n]=(float)(signed short)getint(&data,2)/ker;

    /* Normals */
    num=getint(&data,4);
    s->vns=num;
    s->vn=malloc(num*3*sizeof(float));
    if(s->vn==NULL)
        return(-1);
    /*for(n=0;n<num*3;n++)
        s->vn[n]=getfloat(&data);*/
    for(n=0;n<num*3;n++)
        s->vn[n]=(float)(signed short)getint(&data,2)/ker;

    while(!quit)
    {
        c=*data++;
        if(c=='q')
            quit=1;

        /* Material */
        if(c=='m')
        {
            m=malloc(sizeof(MTL));
            m->next=s->materials;
            s->materials=m;
            strcpy(m->name,data);
            while(*data++);

            m->ambient[3]=m->diffuse[3]=m->specular[3];

            for(n=0;n<3;n++)
                m->ambient[n]=getfloat(&data);
            for(n=0;n<3;n++)
                m->diffuse[n]=getfloat(&data);
            for(n=0;n<3;n++)
                m->specular[n]=getfloat(&data);

            m->opacity=getfloat(&data);
            m->shininess=getfloat(&data);
        }

        /* Object */
        if(c=='o')
        {
            o=malloc(sizeof(OBJ));
            o->next=s->objects;
            s->objects=o;
            o->parts=NULL;
            o->x=o->y=o->z=0;
            o->tx=o->ty=o->tz=0;
            o->rot=0;
            o->pivot=NULL;

            strcpy(o->name,data);
            while(*data++);

            o->type=TYPE_OBJECT;
            if(!strncmp("pivot_",o->name,6))
                o->type=TYPE_PIVOT;
            if(!strncmp("point",o->name,5))
            {
                s->lighting=1;
                o->type=TYPE_POINT;
            }
        }

        /* Part and faces */
        if(c=='g')
        {
            p=malloc(sizeof(PART));
            p->faces=NULL;
            p->next=o->parts;
            o->parts=p;
            strcpy(p->name,data);
            while(*data++);

            m=s->materials; /* Find material */
            while(m!=NULL)
            {
                if(!strcmp(m->name,data))
                    p->material=m;
                m=m->next;
            }
            while(*data++);

            num=getint(&data,2); /* Faces */
            for(i=0;i<num;i++)
            {
                f=malloc(sizeof(FACE));
                f->next=p->faces;
                p->faces=f;

                pts=*data++;
                f->num=pts;

                f->index=malloc(pts*sizeof(float));
                f->normal=malloc(pts*sizeof(float));

                for(n=0;n<pts;n++)
                    f->index[n]=getint(&data,2);
                for(n=0;n<pts;n++)
                    f->normal[n]=getint(&data,2);
            }
        }
    }

    /* Calculate pivot points */
    o=s->objects;
    while(o!=NULL)
    {
        if(o->type==TYPE_PIVOT)
        {
            pivot_vectors(s,o);
            o2=s->objects;
            while(o2!=NULL)
            {
                if(o2->type!=TYPE_PIVOT && o2->pivot==NULL)
                {
                    key[0]='_';
                    strcpy(&key[1],o2->name);
                    if(strstr(o->name,key)!=NULL)
                        o2->pivot=o;
                }
                o2=o2->next;
            }
        }

        o=o->next;
    }

    return(0);
}

void writefloat(FILE *fp,float f)
{
    int *p=&f;
    writeint(fp,*p,4);
}
void writeint(FILE *fp,unsigned c,int len)
{
    int n;

    for(n=0;n<len;n++)
        fputc((c>>n*8)&0xff,fp);
}

float getfloat(unsigned char **p)
{
    int i=getint(p,4);
    float *f=&i;
    return(*f);
}
unsigned getint(unsigned char **p,int len)
{
    int n;
    unsigned i=0;

    for(n=0;n<len;n++)
    {
        i+=(unsigned)(**p)<<(n*8);
        (*p)++;
    }

    return(i);
}
