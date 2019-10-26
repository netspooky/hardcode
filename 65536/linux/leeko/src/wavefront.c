
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "wavefront.h"

static int get_mtl(SCENE *s,char *mtl);

int load_scene(SCENE *s,char *name)
{
    long size;
    char *scn;
    FILE    *fp;

    fp=fopen(name,"rb");
    if(fp==NULL)
        return(-1);
    fseek(fp,0,SEEK_END);
    size=ftell(fp);
    fseek(fp,0,SEEK_SET);

    scn=malloc(size+1);
    if(scn==NULL)
        return(-1);
    fread(scn,1,size,fp);
    scn[size]=0;
    fclose(fp);

    if(get_scene(s,scn,NULL)==-1)
        return(-1);

    free(scn);
    return(0);
}

int get_scene(SCENE *s,char *scn,char *mtl)
{
    long    size;
    int     quit=0,v=0,vn=0,vi=0,vni=0,
            fn,done,n;
    char    *row,key[1000],mfile[1000],*tmp;
    FILE    *fp;

    OBJ     *o=NULL,*o2;
    PART    *p=NULL;
    FACE    *f;
    MTL     *m;

    tmp=strdup(scn);
    row=strtok(tmp,"\r\n");
    while(!quit)
    {
        sscanf(row,"%s",key);
        if(!strcmp(key,"v"))
            v++;
        if(!strcmp(key,"vn"))
            vn++;

        row=strtok(NULL,"\r\n");
        if(row==NULL)
            quit=1;
    }
    free(tmp);
    s->v=malloc(3*sizeof(float)*v);
    s->vn=malloc(3*sizeof(float)*vn);

    s->vs=v;
    s->vns=vn;
    s->objects=NULL;
    s->materials=NULL;
    s->lighting=0;

    row=strtok(scn,"\r\n");
    quit=0;
    while(!quit)
    {
        sscanf(row,"%s",key);
        if(key[0]!='#')
        {
            /* Material file */
            if(!strcmp(key,"mtllib"))
            {
                if(mtl==NULL)
                {
                    sscanf(row,"%s%s",key,mfile);
                    fp=fopen(mfile,"rb");
                    if(fp==NULL)
                        return(-1);

                    fseek(fp,0,SEEK_END);
                    size=ftell(fp);
                    fseek(fp,0,SEEK_SET);
                
                    mtl=malloc(size+1);
                    if(mtl==NULL)
                        return(-1);
                    fread(mtl,1,size,fp);
                    mtl[size]=0;
                    fclose(fp);

                    if(get_mtl(s,mtl)==-1)
                        return(-1);
                    free(mtl);
                }
                else
                    get_mtl(s,mtl);
            }

            /* Object */
            if(!strcmp(key,"o"))
            {
                o=malloc(sizeof(OBJ));
                o->next=s->objects;
                s->objects=o;
                o->parts=NULL;
                o->x=o->y=o->z=0;
                o->tx=o->ty=o->tz=0;
                o->rot=0;
                o->pivot=NULL;
                sscanf(row,"%s%s",key,o->name);

                o->type=TYPE_OBJECT;
                if(!strncmp("pivot_",o->name,6))
                    o->type=TYPE_PIVOT;
                if(!strncmp("point",o->name,5))
                {
                    s->lighting=1;
                    o->type=TYPE_POINT;
                }
            }

            /* Part */
            if(!strcmp(key,"g"))
            {
                p=malloc(sizeof(PART));
                p->next=o->parts;
                o->parts=p;
                p->faces=NULL;
                sscanf(row,"%s%s",key,p->name);
            }

            /* Material of a part */
            if(!strcmp(key,"usemtl"))
            {
                sscanf(row,"%s%s",key,mfile);
                m=s->materials;
                while(m!=NULL)
                {
                    if(!strcmp(m->name,mfile))
                        p->material=m;
                    m=m->next;
                }
            }

            /* Index */
            if(!strcmp(key,"f"))
            {
                f=malloc(sizeof(FACE));
                f->next=p->faces;
                p->faces=f;

                tmp=strdup(row);
                strsep(&tmp," ");
                for(done=fn=0;!done;)
                {
                    if(strsep(&tmp," "))
                        fn++;
                    else
                        done=1;
                }
                f->num=fn;
                f->index=malloc(fn*sizeof(int));
                f->normal=malloc(fn*sizeof(int));

                strsep(&row," ");
                for(done=fn=0;!done;)
                {
                    if((tmp=strsep(&row," ")))
                    {
                        f->index[fn]=atoi(tmp)-1;
                        for(n=strlen(tmp)-1;tmp[n]!='/';n--)
                            ;
                        f->normal[fn]=atoi(&tmp[n+1])-1;
                        fn++;
                    }
                    else
                        done=1;
                }
            }

            /* Vertex */
            if(!strcmp(key,"v"))
            {
                sscanf(row,"%s%f%f%f",key,&s->v[vi],&s->v[vi+1],&s->v[vi+2]);
                vi+=3;
            }
            /* Vertex normal */
            if(!strcmp(key,"vn"))
            {
                sscanf(row,"%s%f%f%f",key,&s->vn[vni],&s->vn[vni+1],
                                          &s->vn[vni+2]);
                vni+=3;
            }
        }

        row=strtok(NULL,"\r\n");
        if(row==NULL)
            quit=1;
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

void delete_scene(SCENE *s)
{
    MTL *m,*m2;
    PART *p,*p2;
    FACE *f,*f2;
    OBJ *o,*o2;

    if(s==NULL)
        return;

    m=s->materials;
    while(m!=NULL)
    {
        m2=m;
        m=m->next;
        free(m2);
    }

    o=s->objects;
    while(o!=NULL)
    {
        p=o->parts;
        while(p!=NULL)
        {
            f=p->faces;
            while(f!=NULL)
            {
                free(f->index);
                free(f->normal);
                f2=f;
                f=f->next;
                free(f2);
            }

            p2=p;
            p=p->next;
            free(p2);
        }
        o2=o;
        o=o->next;
        free(o2);
    }

    free(s->v);
    free(s->vn);
}

int get_mtl(SCENE *s,char *mtl)
{
    char *row,key[1000];
    int quit=0;
    MTL *m=NULL;

    row=strsep(&mtl,"\r\n");
    while(!quit)
    {
        key[0]=0;
        sscanf(row,"%s",key);

        if(key[0]!='#')
        {
            /* New material */
            if(!strcmp(key,"newmtl"))
            {
                m=malloc(sizeof(MTL));
                m->next=s->materials;
                s->materials=m;
                sscanf(row,"%s%s",key,m->name);
                m->diffuse[3]=m->specular[3]=m->ambient[3]=1;
            }

            /* Diffuusi */
            if(!strcmp(key,"Kd"))
                sscanf(row,"%s%f%f%f",key,&m->diffuse[0],&m->diffuse[1],
                                          &m->diffuse[2]);
            /* Spekulaari */
            if(!strcmp(key,"Ks"))
                sscanf(row,"%s%f%f%f",key,&m->specular[0],&m->specular[1],
                                          &m->specular[2]);
            /* Ambientti */
            if(!strcmp(key,"Ka"))
                sscanf(row,"%s%f%f%f",key,&m->ambient[0],&m->ambient[1],
                                          &m->ambient[2]);

            /* Shininess */
            if(!strcmp(key,"Ns"))
                sscanf(row,"%s%f",key,&m->shininess);
            /* Opacity */
            if(!strcmp(key,"d"))
                sscanf(row,"%s%f",key,&m->opacity);
        }

        row=strsep(&mtl,"\r\n");
        if(row==NULL)
            quit=1;
    }

    return(0);
}

void pivot_vectors(SCENE *s,OBJ *o)
{
    PART *p=o->parts;
    FACE *f;
    float   mx=0,my=0,mz=0,
            dx=0,dy=0,dz=0,
            dis[3];
    int  n,i,found=0;

    f=p->faces;
    while(f!=NULL)
    {
        /* Midpoint */
        if(f->num>3)
        {
            for(n=0;n<f->num;n++)
            {
                mx+=s->v[f->index[n]*3];
                my+=s->v[f->index[n]*3+1];
                mz+=s->v[f->index[n]*3+2];
            }
            mx/=(float)f->num;
            my/=(float)f->num;
            mz/=(float)f->num;
        }

        if(f->num==3 && !found) /* Tip */
        {
            for(n=0;n<3;n++)
            {
                i=(n+1)%3;
                dx=s->v[f->index[n]*3]   - s->v[f->index[i]*3];
                dy=s->v[f->index[n]*3+1] - s->v[f->index[i]*3+1];
                dz=s->v[f->index[n]*3+2] - s->v[f->index[i]*3+2];

                dis[n]=dx*dx+dy*dy+dz*dz;
            }

            if(dis[0]>dis[1] && dis[2]>dis[1])
                i=0;
            if(dis[0]>dis[2] && dis[1]>dis[2])
                i=1;
            if(dis[1]>dis[0] && dis[2]>dis[0])
                i=2;

            dx=s->v[f->index[i]*3];
            dy=s->v[f->index[i]*3+1];
            dz=s->v[f->index[i]*3+2];
            found=1;
        }

        f=f->next;
    }

    mx-=dx;
    my-=dy;
    mz-=dz;

    o->tx=dx; /* Pivot point and vector done! */
    o->ty=dy;
    o->tz=dz;
    o->x=mx;
    o->y=my;
    o->z=mz;
}

OBJ *find_object(SCENE *s,char *name)
{
    OBJ *o=s->objects;

    while(o!=NULL)
    {
        if(!strcmp(o->name,name))
            return(o);
        o=o->next;
    }

    return(NULL);
}
