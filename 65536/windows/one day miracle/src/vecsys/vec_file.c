/*
 *
 *      VecSys File
 *
 *      - objektien ja tekstuurien lataus
 *
 */

#include "vec_file.h"
#include "vec_mem.h"
#include "vec_math.h"
#include "vec_matr.h"
#include "vec_mtrl.h"
#include "vec_3ds.h"

// #include "iff.h"
// #include "jpegread.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

#ifndef VEC_NO_FLOAT
static vec_fp   vec_3ds_vm=256,         //      kerroin, 3ds:n vertex
                vec_3ds_tm=256*256;     //      kerroin, 3ds:n textcrd
#endif

typedef struct                          //      EFILE muistista lataukselle
{
    uint8   *data;
    long    index;
} MFILE;

typedef void    EFILE;                  //      joko FILE tai MFILE

typedef struct
{
    size_t  (*read)(void *,size_t,size_t,void *);
    int     (*getb)(void *);
    EFILE   *(*open)(const char *,const char *);
    void    (*close)(void *);
    long    (*tell)(void *);
    void    (*seek)(void *,long,int);
#if defined(JPEGREAD_H)
    int     (*jpeg_load_info)(const char *,jpeg_info *);
    int     (*jpeg_load_image)(const char *,char *);
#endif
    int     (*load_iff)(unsigned char *,uint8 *,uint8 *);
} efile_f;

static int      vec_fgetb(FILE *fp);
static size_t   vec_fread(void *buf,size_t size,size_t count,FILE *fp);

static size_t   vec_mread(void *buf,size_t size,size_t count,MFILE *fp);
static int      vec_mgetb(MFILE *fp);
static MFILE    *vec_mopen(const char *data,const char *subfire);
static void     vec_mclose(MFILE *fp);
static long     vec_mtell(MFILE *fp);
static void     vec_mseek(MFILE *fp,long dest,int stype);

static efile_f
    vec_file =
    {
        (void *)vec_fread, (void *)vec_fgetb, (void *)fopen,
        (void *)fclose, (void *)ftell, (void *)fseek
#if defined(JPEGREAD_H)
        ,jpeg_load_info, jpeg_load_image
#endif
#if defined(IFF_H)
        ,load_iff
#endif
    },
    vec_mem =
    {
        (void *)vec_mread, (void *)vec_mgetb, (void *)vec_mopen,
        (void *)vec_mclose, (void *)vec_mtell, (void *)vec_mseek
#if defined(JPEGREAD_H)
        ,jpeg_get_info, jpeg_get_image
#endif
#if defined(IFF_H)
        ,get_iff
#endif
    },
    *vec_f=&vec_file;

//static void     vec_promote(uint8 *dat,uint8 *pal,void *de,long len,int bpp);
//static vec_obj  *vec_get_pete_object(const char *so,vec_obj *obz,int tex);

#ifndef VEC_NO_CAM
//static int      vec_load_yzi_objects(const char *name,vec_world *objs);
static int      vec_load_3ds_objects(const char *name,vec_world *objs);
static long     vec_check_3ds_id(EFILE *fine,uint16 id);
static long     vec_search_id(EFILE *fine,uint16 id,long slen);
//static long     vec_adjust_len(EFILE *fine,long cpos,long slen);
static void     vec_load_name(EFILE *fine,char *name,int len);
//static void     *vec_load_keys(EFILE *fine,const char *name,
//                    int32 *flags,int32 *keys,int item,long slen);
uint8    *vec_texturebyname(const char *tname,int bpp);
#endif

int vec_fgetb(FILE *fp)
{
    uint8   b;

    if(!fread(&b,1,1,fp))
        return EOF;

    return b;
}

size_t vec_fread(void *buf,size_t size,size_t count,FILE *fp)
{
#if defined(__WATCOMC__) || defined (VEC_X86)
    return fread(buf,size,count,fp);
#else
    size_t  n,m;
    uint32  l,h;
    uint8   *uf=buf;

    for(n=0; n<count; n++,uf+=size)
    {
        for(m=h=l=0; m<size; m++,h+=8)
            l+=(uint32)vec_fgetb(fp) << h;
        switch(size)
        {
            case 1: *((uint8 *)uf)=l;
                    break;
            case 2: *((uint16 *)uf)=l;
                    break;
            case 4: *((uint32 *)uf)=l;
                    break;
        }
    }

    return count;
#endif
}

size_t vec_mread(void *buf,size_t size,size_t count,MFILE *fp)
{
#if defined(__WATCOMC__) || defined (VEC_X86)
    memcpy(buf,fp->data+fp->index,size*count);
    fp->index += size*count;
#else
    size_t  n,m;
    uint32  l,h;
    uint8   *uf=buf;

    for(n=0; n<count; n++,uf+=size)
    {
        for(m=h=l=0; m<size; m++,h+=8)
            l+=(uint32)vec_mgetb(fp) << h;
        switch(size)
        {
            case 1: *((uint8 *)uf)=l;
                    break;
            case 2: *((uint16 *)uf)=l;
                    break;
            case 4: *((uint32 *)uf)=l;
                    break;
        }
    }
#endif
    return count;
}

int vec_mgetb(MFILE *fp)
{
    return fp->data[fp->index++];
}

MFILE *vec_mopen(const char *data,const char *subfire)
{
    MFILE *vile;

    vile=malloc(sizeof(MFILE));

    if(vile)
    {
        vile->data=(uint8 *)data;
        vile->index=0;
    }

    return vile;
}

void vec_mclose(MFILE *fp)
{
    free(fp);
}

long vec_mtell(MFILE *fp)
{
    return fp->index;
}

void vec_mseek(MFILE *fp,long dest,int stype)
{
    if(stype == SEEK_SET)
        fp->index=dest;
    else
        fp->index+=dest;
}

void vec_set_source(int type)
{
    switch(type)
    {
        case VEC_SRC_FILE:
            vec_f=&vec_file;
            break;
        case VEC_SRC_MEM:
            vec_f=&vec_mem;
            break;
    }
}

int vec_tell_filetype(const char *name)
{
    EFILE   *file;
    uint16  id;

    if(!(file=vec_f->open(name,"rb")))
        return VEC_UNKNOWN;

    vec_f->read(&id,2,1,file);
    vec_f->close(file);

    switch(id)
    {
        case 0x4f46:    return VEC_IFF;
        case 0xd8ff:    return VEC_JPEG;
        case 0x3a4d:    return VEC_MATLIST;
        case M3DMAGIC:  return VEC_3DS;
        case MLIBMAGIC: return VEC_MATLIB;
        case MATMAGIC:  return VEC_MATERIAL;
        case PRJMAGIC:  return VEC_PROJECT;
        default:        return VEC_UNKNOWN;
    }
}

#ifdef KUU
void vec_promote(uint8 *dat,uint8 *pal,void *de,long len,int bpp)
{
        static uint32   palko[256];
        uint32          col;
        long            n;

        for(n=0; n<256; n++)
        {
            col=pal[n*3];
            col <<= 8;
            col+=pal[n*3+1];
            col <<= 8;
            col+=pal[n*3+2];

            switch(bpp)
            {
                case 32:
                    palko[n]=col;
                    break;
                case 16:
                    palko[n]=(col>>3 & 0x1f)+
                        (col>>5 & 0x07e0)+
                        (col>>8 & 0xf800);
                    break;
            }
        }

        switch(bpp)
        {
            case 32:
                for(n=len-1; n>=0; n--)
                    ((uint32 *)de)[n]=palko[dat[n]];
                break;
            case 16:
                for(n=len-1; n>=0; n--)
                    ((uint16 *)de)[n]=palko[dat[n]];
                break;
        }
}

uint8 *vec_load_texture(const char *name,int bpp)
{
    uint8       *de,*temp,*demp;
    uint32      col;
    long        n,m, ix,iy, dx,dy, ti;
    int         type, width,height,components=0;

    if(bpp!=8 && bpp!=16 && bpp!=32)
        return NULL;

    if(!(de=vec_alloc_texture(bpp)))
        return NULL;

    type=vec_tell_filetype(name);

#if defined(IFF_H)
    if(type == VEC_IFF)
    {
        if( vec_f->load_iff((unsigned char *)name,NULL,NULL)==IFF_ERR ||
            !(temp=malloc(iff_x*iff_y)) )
        {
            vec_free_texture(de);
            return NULL;
        }

        width=iff_x;
        height=iff_y;
        components=1;

        vec_f->load_iff((unsigned char *)name,temp,de+0x10000);

        if(iff_type == ILBM)
        {
            if(!(demp=malloc(iff_x*iff_y)))
            {
                vec_free_texture(de);
                free(temp);
                return NULL;
            }

            planar2chunky(temp,demp);
            free(temp);
            temp=demp;
        }
    }
#endif
#if defined(JPEGREAD_H)
    if(type == VEC_JPEG)
    {
        jpeg_info   i;

        if( !vec_f->jpeg_load_info(name,&i) ||
            !(temp=malloc(4*i.width*i.height)) )
        {
            vec_free_texture(de);
            return NULL;
        }

        width=i.width;
        height=i.height;
        components=i.components;

        vec_f->jpeg_load_image(name,temp);

        if(i.components == 3)
            for(n=i.height*i.width-1; n>=0; n--)
                ((uint32 *)temp)[n]=(temp[3*n+2] << 16)+
                    (temp[3*n+1] << 8)+temp[3*n];
        if(i.components==1 || bpp==8)
            for(n=0; n<0x300; n++)
                de[n+0x10000]=n/3;
    }
#endif

    if(!components)
    {
        vec_free_texture(de);
        return NULL;
    }

    for(m=0,iy=0,dy=min(256,height); m<256; m++,iy+=dy)
        for(n=0,ix=0,dx=min(256,width); n<256; n++,ix+=dx)
        {
            ti=(iy >> 8)*width + (ix >> 8);
            if(components == 1)
                de[m*256+n]=temp[ti];
            else switch(bpp)
            {
                case 32:
                    ((uint32 *)de)[m*256+n]=((uint32 *)temp)[ti];
                    break;
                case 16:
                    col=((uint32 *)temp)[ti];
                    ((uint16 *)de)[m*256+n]=(col>>3 & 0x1f)+
                        (col>>5 & 0x07e0)+(col>>8 & 0xf800);
                    break;
                case 8:
                    col=((uint32 *)temp)[ti];
                    de[m*256+n]=((col>>16 & 0xff)+
                        (col>>8 & 0xff)+(col & 0xff))/3;
                    break;
            }
        }

    free(temp);

    if(components==1 && bpp>8)
        vec_promote(de,de+0x10000,de,0x10000,bpp);

    if(vec_f == &vec_file)
        memcpy(VEC_TH(de)->name,name,12);

    return de;
}

vec_obj *vec_get_pete_object(const char *so,vec_obj *obz,int tex)
{
    long    m,vc,fc;

    vc=((int16 *)so)[0];
    fc=((int16 *)so)[1];

    if(obz == NULL)
        if(!(obz=vec_alloc_object(vc,fc,tex)))
            return NULL;

    for(m=0,so+=4; m<vc*3; m++,so+=2)
        obz->vertex[m]=(vec_fp)(*(int16 *)so)*256;
    for(m=0; m<fc*VEC_MAX_VPF; m++,so+=2)
    {
        obz->face[m]=(long)((*(int16 *)so));

        if((m&3)==2 && VEC_MAX_VPF>3)
            obz->face[++m]=-1;
    }
    if(tex)
        for(m=0; m<fc*2; m++)
            obz->tcoord[m]=(vec_fp)(*so++)*256;

    vec_init_object(obz);

    return obz;
}

vec_obj *vec_load_object(const char *name)
{
    FILE    *file;
    vec_obj *obz;
    long    len,lex;
    int     tex;
    int16   vc,fc;
    char    *data;

    if(vec_f == &vec_mem)
        return vec_get_pete_object(name,NULL,1);

    if(!(file=vec_f->open(name,"rb")))
        return NULL;

    vec_f->read(&vc,2,1,file);
    vec_f->read(&fc,2,1,file);

    vec_f->seek(file,0,SEEK_END);
    len=vec_f->tell(file);
    vec_f->seek(file,0,SEEK_SET);

    lex=(vc+fc)*6+4;
    if( (len!=lex && len!=lex+vc*2) ||
        !(obz=vec_alloc_object(vc,fc,tex=len>lex)) )
    {
        vec_f->close(file);
        return NULL;
    }

    if(!(data=malloc(len)))
    {
        vec_f->close(file);
        vec_free_object(obz);
        return NULL;
    }

    vec_f->read(data,2,lex>>1,file);
    tex ? vec_f->read(data+lex,1,vc*2,file):0;

    vec_f->close(file);

    if(!(obz=vec_get_pete_object(data,obz,tex)))
        vec_free_object(obz);

    free(data);

    return obz;
}
#endif

#ifndef VEC_NO_CAM

#if VEC_MAX_VPF != 4
#error VEC_MAX_VPF != 4
#endif

int vec_load_objects(const char *name,vec_world *objs)
{
    // vec_obj *obj;

#ifndef VEC_NO_FLOAT
    if(vec_load_3ds_objects(name,objs) == VEC_OK)
        return VEC_OK;
#endif
    /*if(vec_load_yzi_objects(name,objs) == VEC_OK)
        return VEC_OK;*/

#ifdef  VEC_LOAD_PETE_OBJECTS
    obj=vec_load_object(name);
    if(vec_add_object(objs,obj,-1) == VEC_OK)
        return VEC_OK;

    vec_free_object(obj);
#endif
    return VEC_ERR;
}

#ifdef KUU
int vec_load_yzi_objects(const char *name,vec_world *objs)
{
    EFILE   *file;
    vec_obj *obj;
    int32   dwrt;
    uint16  vc,fc,oc,on,kw,*temp;
    int16   *norm,wort;
    int     n,m, tex;
    char    objname[10];

    if(!(file=vec_f->open(name,"rb")))
        return VEC_ERR;

    vec_f->read(&oc,2,1,file);
    for(n=0; n<oc; n++)
    {
        vec_f->read(&on,2,1,file);
        vec_f->read(objname,10,1,file);
        vec_f->read(&kw,2,1,file);
        vec_f->read(&vc,2,1,file);
        vec_f->read(&fc,2,1,file);

        if(on!=n || !(kw&9) || !(obj=vec_alloc_object(vc,fc,kw&2)))
        {
            vec_f->close(file);
            return VEC_ERR;
        }

        if(kw&4)
        {
            obj->normal=malloc(vc*12);
            obj->ncoord=malloc(vc*12);
        }
        if( ((kw&4) && (!obj->normal || !obj->ncoord)) ||
            vec_add_object(objs,obj,-1)==VEC_ERR )
        {
            vec_free_object(obj);
            vec_f->close(file);
            return VEC_ERR;
        }

        for(m=0; m<vc*3; m++)
        {
            vec_f->read(&dwrt,4,1,file);
            obj->vertex[m]=(vec_fp)dwrt*256;
        }
        if(kw & 2)
        {
            for(m=0,tex=0; tex<2;)
            {
                vec_f->read(&wort,2,1,file);
                obj->tcoord[m*2+tex]=wort*256;
                if(++m == vc)
                {
                    m=0;
                    tex++;
                }
            }
        }
        if(kw & 4)
        {
            norm=(int16 *)obj->normal;
            vec_f->read(&kw,2,1,file);
            vec_f->read(norm,2,vc*3,file);
            for(m=vc*3-1; kw && m>=0; m--)
                obj->normal[m]=norm[m]*126/kw;
        }

        /*      Hyp„t„„n yli smoothing group ja face normals    */
        vec_f->seek(file,((kw&8) ? vc:0)+((kw&16) ? 6*vc:0),SEEK_CUR);

        temp=(uint16 *)obj->face;
        vec_f->read(temp,2,fc*4,file);
        for(m=fc*4-1; m>=0; m--)
            if((m&3)==3 && temp[m]==temp[m-1])
                obj->face[m]=-1;
            else
                obj->face[m]=temp[m];

        vec_init_object(obj);
        memcpy(obj->name,objname,10);
    }

    vec_f->close(file);

    return VEC_OK;
}

#endif

#ifndef VEC_NO_FLOAT

int vec_load_3ds_objects(const char *name,vec_world *objs)
{
    EFILE   *fail;
    int     i,j, tex, end,found;
    long    meshlen,objlen,keyflen, meshpos,objpos,keyfpos,
            clen,flen, cpos,fpos,vpos,tpos=0, n;
    int16   fc,vc, wort,hier;
    float   rfloat[12],pivot[3];
    char    objname[10],kname[10];
    vec_obj *obj;

    /*      Avataan ja testataan tiedosto       */
    /*      ja haetaan objektidatan paikka      */

    if(!(fail=vec_f->open(name,"rb")))
        return VEC_ERR;
    if( !(meshlen=keyflen=vec_check_3ds_id(fail,M3DMAGIC)) ||
        !(meshlen=vec_search_id(fail,MDATA,meshlen)) )
    {
        vec_f->close(fail);
        return VEC_ERR;
    }
    meshpos=vec_f->tell(fail);

    /*      Haetaan keyframedatan paikka        */

    vec_f->seek(fail,6,SEEK_SET);
    if( !(keyflen=vec_search_id(fail,KFDATA,keyflen)) ||
        !(clen=vec_search_id(fail,KFHDR,keyflen)) )
    {
        vec_f->close(fail);
        return VEC_ERR;
    }
    keyfpos=vec_f->tell(fail)+clen-6;

    for(end=0; !end;)
    {
        obj=NULL;

        /*      Haetaan hierarkian paikka       */

        vec_f->seek(fail,keyfpos,SEEK_SET);
        if(!vec_search_id(fail,OBJECT_NODE_TAG,keyflen))
            end=1;
        else
        {
            keyfpos=vec_f->tell(fail);
            if(!vec_search_id(fail,NODE_HDR,keyflen))
                break;
            vec_load_name(fail,kname,10);

            /*      Ladataan hierarkia ja pivot     */

            vec_f->seek(fail,4,SEEK_CUR);
            vec_f->read(&hier,2,1,fail);
            vec_f->seek(fail,keyfpos,SEEK_SET);
            if(vec_search_id(fail,PIVOT,keyflen))
                vec_f->read(pivot,4,3,fail);
            else
                memset(pivot,0,3*4);

            if(!strncmp(kname,"$$$DUMMY",8))
            {
                vec_f->seek(fail,keyfpos,SEEK_SET);
                if(!vec_search_id(fail,INSTANCE_NAME,keyflen))
                    break;
                vec_load_name(fail,objname,10);

                obj=vec_alloc_object(0,0,0);
            }
            else for(found=0,objpos=meshpos; !found; objpos+=objlen-6)
            {
                /*      Haetaan objektin paikka     */

                vec_f->seek(fail,objpos,SEEK_SET);
                if(!(objlen=vec_search_id(fail,NAMED_OBJECT,meshlen)))
                    break;
                objpos=vec_f->tell(fail);
                vec_load_name(fail,objname,10);

                if( (clen=vec_search_id(fail,N_TRI_OBJECT,objlen)) &&
                    !strncmp(kname,objname,10) )
                {
                    found=1;

                    /*      Haetaan datojen paikat      */

                    cpos=vec_f->tell(fail);
                    vec_search_id(fail,POINT_ARRAY,clen);
                    vec_f->read(&vc,2,1,fail);
                    vpos=vec_f->tell(fail);
                    vec_f->seek(fail,cpos,SEEK_SET);
                    flen=vec_search_id(fail,FACE_ARRAY,clen);
                    vec_f->read(&fc,2,1,fail);
                    fpos=vec_f->tell(fail);
                    vec_f->seek(fail,cpos,SEEK_SET);
                    if((tex=vec_search_id(fail,TEX_VERTS,clen)))
                        tpos=vec_f->tell(fail)+2;

                    /*      Varataan objekti            */

                    if(!(obj=vec_alloc_object(vc,fc,tex)))
                        break;

                    /*      Ladataan objektin datat     */

                    vec_f->seek(fail,vpos,SEEK_SET);
                    for(n=0; n<vc*3; n++)
                    {
                        vec_f->read(rfloat,4,1,fail);
                        obj->vertex[n]=rfloat[0]*vec_3ds_vm;
                    }
                    vec_f->seek(fail,fpos,SEEK_SET);
                    for(n=0; n<fc*4; n++)
                    {
                        vec_f->read(&wort,2,1,fail);
                        obj->face[n]=(n&3)<3 ? wort : -1;
                    }
                    if(vec_search_id(fail,MSH_MAT_GROUP,flen-8*fc))
                    {
                        vec_load_name(fail,obj->material,16);
                    }
                    if(tex)
                    {
                        vec_f->seek(fail,tpos,SEEK_SET);
                        for(n=0; n<vc*2; n++)
                        {
                            vec_f->read(rfloat,4,1,fail);
                            obj->tcoord[n]=rfloat[0]*vec_3ds_tm;
                        }
                    }

                    vec_f->seek(fail,cpos,SEEK_SET);
                    vec_init_qmatr(obj->mmatr);
                    if(vec_search_id(fail,MESH_MATRIX,clen))
                    {
                        vec_f->read(rfloat,4,12,fail);
                        for(i=0; i<3; i++)
                        {
                            for(j=0; j<3; j++)
                                obj->mmatr[i][j]=rfloat[j+i*3];
                            obj->mmatr[i][3]=-rfloat[9+i]*vec_3ds_vm;
                        }
                    }
                }
            }

            if(obj == NULL)
                break;

            /*      Lis„t„„n objekti listaan        */

            if(vec_add_object(objs,obj,hier) == VEC_ERR)
                break;

            /*      Alustetaan objektin tiedot      */

            vec_init_object(obj);
            memcpy(obj->name,objname,10*sizeof(char));
            for(n=Xi; n<=Zi; n++)
                obj->pivot[n]=pivot[n]*vec_3ds_vm;
        }
    }

    vec_f->close(fail);

    if(!end)
    {
        vec_free_object(obj);
        return VEC_ERR;
    }

    return VEC_OK;
}

int vec_load_camera(const char *name,int num,vec_cam *camel)
{
    EFILE   *fail;
    float   nummi[7];
    long    n, slen, chunklen,chunkpos;

    if(num<1 || !camel || !(fail=vec_f->open(name,"rb")))
        return VEC_ERR;

    if( !(slen=vec_check_3ds_id(fail,M3DMAGIC)) ||
        !(slen=vec_search_id(fail,MDATA,slen)) )
    {
        vec_f->close(fail);
        return VEC_ERR;
    }

    while(num > 0)
    {
        if(!(chunklen=vec_search_id(fail,NAMED_OBJECT,slen)))
        {
            vec_close(camel);
            vec_f->close(fail);
            return VEC_ERR;
        }

        chunkpos=vec_f->tell(fail);

        vec_load_name(fail,camel->name,10);

        if(vec_search_id(fail,N_CAMERA,chunklen))
            num--;
        if(num)
        {
            slen-=chunklen;
            vec_f->seek(fail,chunkpos+chunklen-6,SEEK_SET);
        }
    }

    vec_f->read(nummi,4,7,fail);
    for(n=Xi; n<=Zi; n++)
    {
        camel->w[n]=nummi[n]*vec_3ds_vm;
        camel->l[n]=nummi[n+3]*vec_3ds_vm;
    }
    camel->az=nummi[6]*1024/360;

    vec_f->close(fail);

    return VEC_OK;
}

#ifdef KUU
int vec_load_cam_kf(const char *name,const char *camname,vec_ckf *ckf)
{
    EFILE   *fail;
    int32   slen,hlen;

    if(!(fail=vec_f->open(name,"rb")))
            return VEC_ERR;
    if( !(slen=vec_check_3ds_id(fail,M3DMAGIC)) ||
        !(slen=vec_search_id(fail,KFDATA,slen)) ||
        !(hlen=vec_search_id(fail,KFHDR,slen)) )
    {
        vec_f->close(fail);
        return VEC_ERR;
    }

    vec_f->seek(fail,hlen-6,SEEK_CUR);
    slen-=hlen;

    if( !(ckf->cpos=vec_load_keys(fail,camname,
            &ckf->cpflags,&ckf->cpkeys,0,slen)) ||
        !(ckf->roll=vec_load_keys(fail,camname,
            &ckf->crflags,&ckf->crkeys,1,slen)) ||
        !(ckf->tpos=vec_load_keys(fail,camname,
            &ckf->tpflags,&ckf->tpkeys,2,slen)) ||
        !vec_search_id(fail,KFSEG,slen) )
    {
        free(ckf->cpos);
        free(ckf->roll);
        free(ckf->tpos);

        vec_f->close(fail);
        return VEC_ERR;
    }

    vec_f->read(&slen,4,1,fail);
    ckf->start=slen;
    vec_f->read(&slen,4,1,fail);
    ckf->end=slen;

    vec_f->close(fail);
    return VEC_OK;
}

int vec_load_obj_kf(const char *name,const char *objname,vec_okf *okf)
{
    EFILE   *fail;
    int32   slen,hlen;
    int     fl;

    if(!(fail=vec_f->open(name,"rb")))
        return VEC_ERR;
    if( !(slen=vec_check_3ds_id(fail,M3DMAGIC)) ||
        !(slen=vec_search_id(fail,KFDATA,slen)) ||
        !(hlen=vec_search_id(fail,KFHDR,slen)) )
    {
        vec_f->close(fail);
        return VEC_ERR;
    }

    vec_f->seek(fail,hlen-6,SEEK_CUR);
    slen-=hlen;

    if( !(okf->pos=vec_load_keys(fail,objname,
            &okf->pflags,&okf->pkeys,3,slen)) ||
        !(okf->rot=vec_load_keys(fail,objname,
            &okf->rflags,&okf->rkeys,4,slen)) )
    {
        free(okf->pos);

        vec_f->close(fail);
        return VEC_ERR;
    }

    vec_f->close(fail);
    return VEC_OK;
}

int vec_load_kf(const char *name,vec_cam *cam)
{
    vec_nod *node;
    vec_obj *obz;

    if(!cam)
        return VEC_ERR;

    if(vec_load_cam_kf(name,cam->name,&cam->kf) == VEC_ERR)
        return VEC_ERR;

    for(node=cam->objlist->first; node; node=node->nextnode)
    {
        obz=node->obj;

        vec_load_obj_kf(name,obz->name,&node->kf);
    }

    return VEC_OK;
}

void *vec_load_keys(EFILE *fine,const char *name,int32 *flags,int32 *keys,
        int item,long slen)
{
    union   //  tarpeetonta kikkailua
    {
            void            *all;
            vec_poskey      *pos;
            vec_rollkey     *roll;
            vec_rotkey      *rot;
    } d;

    int     i,j,n, startpos, klen,kpos, found,

            object_id[]={CAMERA_NODE_TAG, TARGET_NODE_TAG, OBJECT_NODE_TAG},
            trtype_id[]={POS_TRACK_TAG, ROLL_TRACK_TAG, ROT_TRACK_TAG},
            sizeofkey[]={sizeof(*d.pos), sizeof(*d.roll), sizeof(*d.rot)},
            item_object[]={0,0,1,2,2}, item_trtype[]={0,1,0,0,2};

    int16   wort;
    int32   fnum;
    float   rfloat[4],tcbe[5];
    char    kname[10];

    d.all=NULL;
    startpos=vec_f->tell(fine);

    for(found=0; !found; slen-=klen)
    {
        if(!(klen=vec_search_id(fine,object_id[item_object[item]],slen)))
            break;
        kpos=vec_f->tell(fine);
        if(!vec_search_id(fine,NODE_HDR,klen))
            break;

        vec_load_name(fine,kname,10);
        if(!strncmp(kname,"$$$DUMMY",8))
        {
            vec_f->seek(fine,kpos,SEEK_SET);
            if(!vec_search_id(fine,INSTANCE_NAME,klen))
                break;
            vec_load_name(fine,kname,10);
        }
        vec_f->seek(fine,kpos,SEEK_SET);
        if(!strncmp(kname,name,10))
        {
            found=1;

            if(!vec_search_id(fine,trtype_id[item_trtype[item]],klen))
                break;

            vec_f->read(&wort,2,1,fine);
            *flags=wort;
            vec_f->seek(fine,8,SEEK_CUR);
            vec_f->read(&wort,2,1,fine);
            *keys=wort;
            if(!(d.all=malloc(*keys*sizeofkey[item_trtype[item]])))
                break;

            vec_f->seek(fine,2,SEEK_CUR);
            for(n=0; n<*keys; n++)
            {
                vec_f->read(&fnum,4,1,fine);
                vec_f->read(&wort,2,1,fine);
                //  1,2,4=TCB; 8,10=Ease to,Ease from;
                for(i=1,j=0; i<=16; i<<=1,j++)
                    if(wort & i)
                        vec_f->read(&tcbe[j],4,1,fine);
                    else
                        tcbe[j]=0;

                switch(item_trtype[item])
                {
                    case 0:
                        d.pos[n].fnum=fnum;
                        vec_f->read(rfloat,4,3,fine);
                        for(i=Xi; i<=Zi; i++)
                            d.pos[n].pos[i]=rfloat[i]*vec_3ds_vm;
                        d.pos[n].tension=tcbe[0];
                        d.pos[n].continuity=tcbe[1];
                        d.pos[n].bias=tcbe[2];
                        break;
                    case 1:
                        d.roll[n].fnum=fnum;
                        vec_f->read(rfloat,4,1,fine);
                        d.roll[n].angle=*rfloat*1024/360;
                        d.roll[n].tension=tcbe[0];
                        d.roll[n].continuity=tcbe[1];
                        d.roll[n].bias=tcbe[2];
                        break;
                    case 2:
                        d.rot[n].fnum=fnum;
                        vec_f->read(rfloat,4,4,fine);
                        d.rot[n].ax=-rfloat[0]*rfloat[1]*512/M_PI;
                        d.rot[n].ay=-rfloat[0]*rfloat[2]*512/M_PI;
                        d.rot[n].az=-rfloat[0]*rfloat[3]*512/M_PI;
                        vec_init_qmatr(d.rot[n].matr);
                        if(n)
                        {
                            vec_calc_qrot(d.rot[n].matr,
                                d.rot[n].ax,d.rot[n].ay,d.rot[n].az);
                            vec_matrixmul_4x4(d.rot[n].matr,
                                d.rot[n-1].matr,d.rot[n].matr);
                        }
                        d.rot[n].tension=tcbe[0];
                        d.rot[n].continuity=tcbe[1];
                        d.rot[n].bias=tcbe[2];
                        break;
                }
            }
        }
    }

    vec_f->seek(fine,startpos,SEEK_SET);
    return d.all;
}

#endif

long vec_adjust_len(EFILE *fine,long cpos,long slen)
{
    return slen-(vec_f->tell(fine)-cpos);
}

long vec_search_id(EFILE *fine,uint16 id,long slen)
{
    int     fountain=0;
    uint16  ch_id;
    uint32  ch_len;

    while(!fountain && slen>0)
    {
        vec_f->read(&ch_id,2,1,fine);
        vec_f->read(&ch_len,4,1,fine);
	if(ch_len==0)
		break;
        slen-=ch_len;

        if(ch_id != id)
            vec_f->seek(fine,ch_len-6,SEEK_CUR);
        else
            fountain=1;
    }

    return fountain ? ch_len : 0;
}

long vec_check_3ds_id(EFILE *fine,uint16 id)
{
    uint16  ch_id;
    uint32  ch_len;

    vec_f->read(&ch_id,2,1,fine);
    if(ch_id != id)
        return 0;
    vec_f->read(&ch_len,4,1,fine);

    return ch_len;
}

#endif

void vec_load_name(EFILE *fine,char *name,int len)
{
    int     i,c;

    /*      Luetaan [len] kirjainta ja jatketaan    */
    /*      etenemist„ nimen loppuun asti           */

    for(i=0,c=1; c!=0;)
    {
        c=vec_f->getb(fine);
        if(c=='\n' || c=='\r' || c=='\t' || c==EOF)
        {
            vec_f->seek(fine,-1,SEEK_CUR);
            c=0;
        }
        if(i < len)
            name[i++]=c;
    }
}

#ifdef KUU
int vec_convert_matinfo(const char *in_name,const char *out_name)
{
    EFILE   *fail;
    FILE    *fool;
    long    len1,len2,len3,len4, pos1;
    int     num=0,i,
            tcids[]={MAT_TEXMAP,MAT_BUMPMAP,MAT_REFLMAP};
    uint8   color[3];
    char    mname[17],
            *ttags[3]={"\tT: ","\tB: ","\tE: "};

    if(!(fail=vec_f->open(in_name,"rb")))
        return 0;

    if(!(len1=vec_check_3ds_id(fail,MLIBMAGIC)))
    {
        vec_f->seek(fail,0,SEEK_SET);
        if( !(len1=vec_check_3ds_id(fail,M3DMAGIC)) ||
            !(len1=vec_search_id(fail,MDATA,len1)) )
        {
            vec_f->close(fail);
            return 0;
        }
    }

    if(out_name == NULL)
        fool=stdout;
    else if(!(fool=fopen(out_name,"wt")))
    {
        vec_f->close(fail);
        return 0;
    }

    while((len2=vec_search_id(fail,MAT_ENTRY,len1)))
    {
        pos1=vec_f->tell(fail)+len2-6;
        len1-=len2;

        vec_search_id(fail,MAT_NAME,len2);
        vec_load_name(fail,mname,17);
        fputs("M: ",fool);
        fputs(mname,fool);

        for(i=21-strlen(mname); i>0; i-=8)
            fputs("\t",fool);

        len3=vec_search_id(fail,MAT_AMBIENT,len2);
        vec_search_id(fail,LIN_COLOR_24,len3);
        vec_f->read(color,1,3,fail);
        fprintf(fool,"C: %i %i %i",color[0],color[1],color[2]);

        for(i=0; i<3; i++)
        {
            len3=vec_adjust_len(fail,pos1,len2);
            if((len4=vec_search_id(fail,tcids[i],len3)))
            {
                vec_search_id(fail,MAT_MAPNAME,len4);
                vec_load_name(fail,mname,13);
                fputs(ttags[i],fool);
                fputs(mname,fool);
            }
        }

        fputs("\n",fool);

        vec_f->seek(fail,pos1,SEEK_SET);
        num++;
    }

    fclose(fool);
    vec_f->close(fail);
    return num;
}

uint8 *vec_texturebyname(const char *tname,int bpp)
{
    uint8   *tex,*temp;
    efile_f *tmp_f;

    if(!(tex=vec_query_texture(tname,bpp)))
    {
        tmp_f=vec_f;
        vec_f=&vec_file;

        tex=vec_load_texture(tname,bpp);
            
        vec_f=tmp_f;
    }

    return tex;
}

int vec_load_materials(const char *name,vec_world *world)
{
    EFILE   *fail;
    vec_nod *node;
    vec_obj *obj;
    uint8   *tex;
    int     i,n,c, found,end, ret=VEC_OK;
    char    id[3], num[4], tname[17];

    if(!world || !(fail=vec_f->open(name,"rb")))
        return VEC_ERR;

    for(node=world->objlist->first; node; node=node->nextnode)
    {
        obj=node->obj;
        vec_f->seek(fail,0,SEEK_SET);

        if(obj->texture || obj->env || obj->bump)
            continue;

        for(end=found=0; !end && !found;)
        {
            for(i=0; i<3; i++)
                id[i]=vec_f->getb(fail);

            if(strncmp(id,"M: ",3))
                end=1;
            else
            {
                vec_load_name(fail,tname,16);
                if(strncmp(tname,obj->material,16))
                    while((c=vec_f->getb(fail))!='\n' && c!=EOF)
                        ;
                else
                {
                    found=1;

                    do
                    {
                        while((c=vec_f->getb(fail)) == '\t')
                            ;

                        if(c=='T' || c=='B' || c=='E')
                        {
                            vec_f->seek(fail,2,SEEK_CUR);
                            vec_load_name(fail,tname,13);

                            tex=vec_texturebyname(tname,c=='B' ? 8:32);

                            //  vain uuden tekstuurin
                            //  lis„ys voi ep„onnistua
                            if(vec_add_texture(tex) == -1)
                            {
                                vec_free_texture(tex);
                                ret=VEC_ERR;
                                continue;
                            }
                        }

                        switch(c)
                        {
                            case 'C':
                                vec_f->seek(fail,2,SEEK_CUR);
                                for(n=obj->colour=0; n<3; n++)
                                {
                                    i=0;
                                    while(isdigit(c=vec_f->getb(fail)))
                                        if(i < 3)
                                            num[i++]=c;
                                    num[i]=0;
                                    obj->colour <<= 8;
                                    obj->colour += atoi(num);
                                }
                                break;
                            case 'T':
                                obj->texture=tex;
                                obj->type &= VEC_ENV;
                                obj->type |= VEC_TEXTURE;
                                break;
                            case 'B':
                                obj->bump=tex;
                                obj->type=VEC_BUMP;
                                break;
                            case 'E':
                                obj->env=tex;
                                obj->type &= VEC_TEXTURE;
                                obj->type |= VEC_ENV;
                                break;
                        }
                    }
                    while(c!='\n' && c!=EOF);
                }
            }
        }
    }

    vec_f->close(fail);
    return ret;
}
#endif

#endif

