#include "z3d.h"

ulong *MixTable;//[65536];
ulong *TextureTable;//[65536];
ulong *FogTable;//[65536];
ulong *FogTable2;
float *xldivTable;//[65536];
long *roottable;//[769];
int *COSX;//[65536];
int putpointed=0;
//#define USE_PHONG
#define USE_FLAT

TEXTURE_Z *plasm1;

#define calc_d(x1,x0,dy) (long)((x1-x0)*(dy>65535?0:xldivTable[dy]))

#define xlsign(x) (x&0x80000000L)

#define xlabs(x) x>0?x:-x

void inline swap(long *a,long *b){
  __asm{
    mov     eax,[a]
    mov     ebx,[b]
    mov     ecx,[eax]
    xchg    ecx,[ebx]
    mov     [eax],ecx
  }
}

Z3D::~Z3D(){
  delete MixTable;
  delete FogTable;
  delete TextureTable;
  delete roottable;
  delete COSX;
  delete xldivTable;
}

void Z3D::Init(){
  plasm1=new TEXTURE_Z;
  plasm1->Create(256,256);

  txProcP txp;
  txp.param1 = 10;
  txp.param3 = 1;
  txp.param2 = 1;
  txgSubplasma(plasm1,&txp);
  txp.param2 = 2;
  txgSubplasma(plasm1,&txp);

  MixTable=new ulong[65536];
  FogTable=new ulong[65536];
  FogTable2=new ulong[65536];
  TextureTable=new ulong[65536];
  roottable=new long[769];
  COSX=new int[65536];
  xldivTable=new float[65536];

  for (int i=0;i<=768;i++){
    roottable[i] = (long)((1L<<8)/((sqrt((double)3/768*i))+1));
  }

  for (i=0;i<65536;i++){
    COSX[i] = (int)((cos((double)PI*2/65536.0*(double)i))*65536.0);
    xldivTable[i]=1/(float)i;
  }

  int j;

  for (i=0;i<256;i++)
    for (j=0;j<256;j++){
      int c=i+j-(i*j>>8);
            
      if (c<0) c=0;
      if (c>255) c=255;
      
      MixTable[((i<<8)|j)]=c<<16;

      TextureTable[(i<<8)|j]=((long)(i*j)>>8)<<16;

      uchar n=i;
      if (n>fogx) n=fogx;
      FogTable[(i<<8)|j]=((fogx-n)+((int)i*j>>8))<<16;

      n=i;
      if (n>fogx2) n=fogx2;
      FogTable2[(i<<8)|j]=((fogx2-n)+((int)i*j>>8))<<16;
    }
}

void OBJECT::calc_light(SCENE *scene,long nx,long ny,long nz,uchar *c_r,uchar *c_g,uchar *c_b){
        long cxr,cxg,cxb;
        if (this->shade==SHADE_SOLID) return;
         long ccl_t;
         long cclnx1,cclny1,cclnz1,rootted;
         long cr,cg,cb;
        cxr=this->r;
        cxg=this->g;
        cxb=this->b;
        for (int li=0;li<SCENE_MAX_LIGHTS;li++){
          if (scene->light[li]){   
            LIGHT *light;
            light=scene->light[li];
            if (light->type==LIGHT_AMBIENT){
              cxr+=light->r;
              cxg+=light->g;
              cxb+=light->b;
            }
            if (light->type==LIGHT_SPECULAR&&light->color){
              ccl_t = ((nx*light->x>>4)+
                       (ny*light->y>>4)+
                       (nz*light->z>>4));
              cclnx1=nx>>8;
              cclny1=ny>>8;
              cclnz1=nz>>8;

              uint underroot=(cclnx1*cclnx1>>8)+
                             (cclny1*cclny1>>8)+
                             (cclnz1*cclnz1>>8);

              if (underroot>768){
                underroot=768;
              }
              rootted = roottable[underroot]+1;

            
              cr=(((ccl_t*light->r)>>8)*rootted)>>15;
              cg=(((ccl_t*light->g)>>8)*rootted)>>15;
              cb=(((ccl_t*light->b)>>8)*rootted)>>15;

/*              if (this->shine){
                cr=(long)pow(cr,this->shininess);
                cg=(long)pow(cg,this->shininess);
                cb=(long)pow(cb,this->shininess);
              }
*/            
              cxr+=cr;
              cxg+=cg;
              cxb+=cb;
              if (cxr>255) cxr=255;
              if (cxg>255) cxg=255;
              if (cxb>255) cxb=255;
              if (cxr<0) cxr=0;
              if (cxg<0) cxg=0;
              if (cxb<0) cxb=0;
            }
          }
        }
        *c_r=(uchar)cxr;
        *c_g=(uchar)cxg;
        *c_b=(uchar)cxb;
}

void VECTOR::to_camera(CSYSTEM *source,CAMERA *camera,int translate,int to_wcs){
  VECTOR wcs;
  MATRIX m;
  long dist=camera->dist;

  wcs.x=x;
  wcs.y=y;
  wcs.z=z;

  ushort ax=source->ax, ay=source->ay, az=source->az;

  int cosax=COSX[ax];
  int sinax=COSX[(ushort)(ax+16536)];
  
  int cosay=COSX[ay];
  int sinay=COSX[(ushort)(ay+16536)];
  
  int cosaz=COSX[az];
  int sinaz=COSX[(ushort)(az+16536)];

//  if (ax){
    m.MakeEquality();
    m.a[1][1]=cosax;
    m.a[1][2]=sinax;
    m.a[2][1]=-sinax;
    m.a[2][2]=cosax;
    wcs*=m;
//  }

//  if (ay){
    m.MakeEquality();
    m.a[0][0]=cosay;
    m.a[2][0]=sinay;
    m.a[0][2]=-sinay;
    m.a[2][2]=cosay;
    wcs*=m;
//  }

//  if (az){
    m.MakeEquality();
    m.a[0][0]=cosaz;
    m.a[1][0]=-sinaz;
    m.a[0][1]=sinaz;
    m.a[1][1]=cosaz;
    wcs*=m;
//  }
  
  wcs.xworld=wcs.x;
  wcs.yworld=wcs.y;
  wcs.zworld=wcs.z;

  if (to_wcs){
    *this=wcs;
    return;
  }

  if (translate){
/*    m.MakeEquality();
    m.a[0][3]=source->x-camera->x;
    m.a[1][3]=source->y-camera->y;
    m.a[2][3]=source->z-camera->z;

    wcs*=m;*/
	wcs.x+=source->x-camera->x;
	wcs.y+=source->y-camera->y;
	wcs.z+=source->z-camera->z;
	
  }

  cosax=COSX[(ushort)-camera->ax];
  sinax=COSX[(ushort)(-camera->ax+16536)];
  
  cosay=COSX[(ushort)-camera->ay];
  sinay=COSX[(ushort)(-camera->ay+16536)];
  
  cosaz=COSX[(ushort)-camera->az];
  sinaz=COSX[(ushort)(-camera->az+16536)];

//  if (camera->ax){
    m.MakeEquality();
    m.a[1][1]=cosax;
    m.a[1][2]=sinax;
    m.a[2][1]=-sinax;
    m.a[2][2]=cosax;
    wcs*=m;
//  }

//  if (camera->ay){
    m.MakeEquality();
    m.a[0][0]=cosay;
    m.a[2][0]=sinay;
    m.a[0][2]=-sinay;
    m.a[2][2]=cosay;
    wcs*=m;
//  }

//  if (camera->az){
    m.MakeEquality();
    m.a[0][0]=cosaz;
    m.a[1][0]=-sinaz;
    m.a[0][1]=sinaz;
    m.a[1][1]=cosaz;
    wcs*=m;
//  }

  if (translate)
    wcs.z-=dist;

  if (wcs.z+dist<0){
    wcs.w=0;
  }
  else{
    if (((wcs.z+dist)>>14))
      wcs.w=(1L<<30)/((wcs.z+dist)>>14);
    else
      wcs.w=0x7fffffff;
  }

  *this=wcs;
}
//------------------------------
void VECTOR::normalize(){

  get_large_normalized(x,y,z);
  double len;
/*  len=sqrt(((double)x*x+(double)y*y+(double)z*z)/65535/65535);

  x=long(x/len);  
  y=long(y/len);
  z=long(z/len);
*/
  len=sqrt(((double)xworld*xworld+(double)yworld*yworld+(double)zworld*zworld)/65535/65535);

  xworld=long(xworld/len);
  yworld=long(yworld/len);
  zworld=long(zworld/len);
}

void VECTOR::get_large_normalized(double x,double y,double z){
  double len;
  len=sqrt(((double)x*x+(double)y*y+(double)z*z)/65535/65535);

  this->x=long(x/len);
  this->y=long(y/len);
  this->z=long(z/len);
}

void VERTEX::project(CSYSTEM *source,CAMERA *camera){

  VECTOR wcs;
  wcs.x=x;
  wcs.y=y;
  wcs.z=z;

  long dist=camera->dist;

  wcs.to_camera(source,camera,1,0);

  xw=wcs.x;
  yw=wcs.y;
  zw=wcs.z;
  w=wcs.w;

  long kp=((dist+wcs.z)>>8);
  if (kp>0){
    x2d=(camera->rect.right-camera->rect.left)/2+(wcs.x>>16)*(dist>>8)/kp;
    y2d=(camera->rect.bottom-camera->rect.top)/2-(wcs.y>>16)*(dist>>8)/kp;
  }
  else{
    x2d=(camera->rect.right-camera->rect.left)/2+(wcs.x>>16);
    y2d=(camera->rect.bottom-camera->rect.top)/2-(wcs.y>>16);
  }
}

void OBJECT::calc_plane_normals(){
  VECTOR N,a,b;
  for (uint i=0;i<planecount;i++){

    a.x=vertex[plane[i].vindex[2]].x-vertex[plane[i].vindex[0]].x;
    a.y=vertex[plane[i].vindex[2]].y-vertex[plane[i].vindex[0]].y;
    a.z=vertex[plane[i].vindex[2]].z-vertex[plane[i].vindex[0]].z;

    b.x=vertex[plane[i].vindex[1]].x-vertex[plane[i].vindex[0]].x;
    b.y=vertex[plane[i].vindex[1]].y-vertex[plane[i].vindex[0]].y;
    b.z=vertex[plane[i].vindex[1]].z-vertex[plane[i].vindex[0]].z;

/*    N.x=-((a.y>>8)*(b.z>>8)-(b.y>>8)*(a.z>>8));
    N.y=((a.x>>8)*(b.z>>8)-(b.x>>8)*(a.z>>8));
    N.z=-((a.x>>8)*(b.y>>8)-(b.x>>8)*(a.y>>8));*/

    double xx,yy,zz;
    xx=-((double)a.y*b.z-(double)b.y*a.z)/65536;
    yy=((double)a.x*b.z-(double)b.x*a.z)/65536;
    zz=-((double)a.x*b.y-(double)b.x*a.y)/65536;
  
    N.get_large_normalized(xx,yy,zz);

//    N.normalize();
    plane[i].N=N;
  }
}

//------------------------------
void OBJECT::plane_normals_to_camera(CAMERA *camera){
  for (uint i=0;i<planecount;i++){
    plane[i].N.normalize();
    plane[i].Nw=plane[i].N;
    plane[i].Nw.to_camera(this,camera,0,0);
    plane[i].Nw.normalize();
  }
}

//------------------------------
void OBJECT::calc_vertex_normals(){
  uint i;

  for (i=0;i<vertexcount;i++){
    vertex[i].Nw.xworld=0;
    vertex[i].Nw.yworld=0;
    vertex[i].Nw.zworld=0;
  }

  for (i=0;i<planecount;i++){
    for (int j=0;j<3;j++){
      vertex[plane[i].vindex[j]].Nw.xworld+=plane[i].Nw.xworld;
      vertex[plane[i].vindex[j]].Nw.yworld+=plane[i].Nw.yworld;
      vertex[plane[i].vindex[j]].Nw.zworld+=plane[i].Nw.zworld;
    }
  }

  for (i=0;i<vertexcount;i++){
      vertex[i].Nw.normalize();
  }
}
//------------------------------

OBJECT::OBJECT(){
  vertex=NULL;
  plane=NULL;
  vertexcount=0;
  planecount=0;
  color=0;
  shine=0;
  shininess=1.030;
  texture=NULL;
  translucent=0;
  translucent_stainglass=0;
  translucent_doublesided=1;
  shade=SHADE_GOURAUD;
  standard_render=1;
  visible=1;
}

void Z3D::TexturizeObject(uint type,uint scene_id,uint object_id,uint texture_id){
  OBJECT *obj=scene[scene_id].object[object_id];
  obj->texture=texture[texture_id];
  
  for (unsigned int i=0;i<obj->vertexcount;i++){
    switch (type){
      case TEXTURIZE_PLANAR:{
        obj->vertex[i].v=obj->vertex[i].y;
        obj->vertex[i].u=obj->vertex[i].x;
        obj->recycle_u=0;
        obj->recycle_v=0;
      };break;
      case TEXTURIZE_CYLINDER:{
        obj->vertex[i].v=obj->vertex[i].y;
        if (obj->vertex[i].z==0)
          obj->vertex[i].u=0;
        else
          obj->vertex[i].u=(long)(256*atan((double)obj->vertex[i].z/obj->vertex[i].x)/PI)<<16;
        obj->recycle_u=1;
        obj->recycle_v=0;
      };break;
      case TEXTURIZE_SPHERE:{
//        obj->vertex[i].v=obj->vertex[i].y;
        obj->vertex[i].v=(long)(256*atan((double)obj->vertex[i].y/65536.0/sqrt(pow(obj->vertex[i].z/65536.0,2)+pow(obj->vertex[i].x/65536.0,2)))/PI)<<16;
        obj->vertex[i].u=(long)(256*atan((double)obj->vertex[i].z/obj->vertex[i].x)/PI)<<16;

        //obj->vertex[i].v=(long)(256*atan((double)obj->vertex[i].z/obj->vertex[i].x)/PI)<<16;
        //obj->vertex[i].u=(long)(256*atan((double)obj->vertex[i].z/65536.0/sqrt(pow(obj->vertex[i].y/65536.0,2)+pow(obj->vertex[i].x/65536.0,2)))/PI)<<16;
        
        obj->recycle_u=1;
        obj->recycle_v=1;
      };break;
    }
  }
}

void OBJECT::reset(uint vcount,uint pcount){
  this->~OBJECT();

  this->vertex = new VERTEX [vcount];
  this->plane = new PLANE  [pcount];
  vertexcount=0;
  planecount=0;
}
//------------------------------
OBJECT::~OBJECT(){
  if(this->vertex!=NULL)
    delete [] vertex;
  if(this->plane!=NULL)
    delete [] plane;
}
//------------------------------
void OBJECT::plane_sort_by_y_2d(uint pind){
  PLANE *pl;
  pl=&plane[pind];

  pl->vindex2d[0]=pl->vindex[0];
  pl->vindex2d[1]=pl->vindex[1];
  pl->vindex2d[2]=pl->vindex[2];

  uint *a=&pl->vindex2d[0];
  uint *b=&pl->vindex2d[1];
  uint *c=&pl->vindex2d[2];

  uint tmp;

  if (vertex[*a].y2d>vertex[*b].y2d) {tmp=*a;*a=*b;*b=tmp;};
  if (vertex[*a].y2d>vertex[*c].y2d) {tmp=*a;*a=*c;*c=tmp;};
  if (vertex[*b].y2d>vertex[*c].y2d) {tmp=*c;*c=*b;*b=tmp;};

};
//------------------------------

void OBJECT::render_plane(SCENE *scene,uint camera_id,uint plane_id){

   uint i=0;

   CAMERA  *camera=scene->camera[camera_id];

   COLOR   c;  

   long    x0,x1,x2,
           y0,y1,y2;

   long    dx0,dx1,dx2;

   long    xl,xr,y,x,lx1,lx2;

   int     midpassed;

   long    nx0,ny0,nz0,
           nx1,ny1,nz1,
           nx2,ny2,nz2;

#ifdef USE_PHONG
   long    nxl,nyl,nzl,
           nxr,nyr,nzr;

   long    dnx0,dny0,dnz0,
           dnx1,dny1,dnz1,
           dnx2,dny2,dnz2;

   long    lnx1,lny1,lnz1,
           lnx2,lny2,lnz2,
           dlnx,dlny,dlnz;
#endif

  //w-buffer
   long    w0,w1,w2,
           wl,wr,
           dw0,dw1,dw2,dlw,lw1,lw2;

  //gouraud
   long     cr0,cg0,cb0,
            cr1,cg1,cb1,
            cr2,cg2,cb2;

   long     dcr0,dcr1,dcr2,
            dcg0,dcg1,dcg2,
            dcb0,dcb1,dcb2;

   long     crl,cgl,cbl,
            crr,cgr,cbr;
    long    lcr2,lcg2,lcb2;
    #pragma pack(1)
    struct{
      long lcr1,lcg1,lcb1;
      long dlcr,dlcg,dlcb;
    } gour;
  //texture
   long     u0,v0,u1,v1,u2,v2;
   long     du0,du1,du2,dv0,dv1,dv2;
   long     ul,ur,vl,vr;
  long      lu2,lv2;

  #pragma pack(1)
  struct {
    long  lu1,lv1,dlu,dlv;
  } tx;

#ifdef USE_FLAT
  //flat
  COLOR   fc;
#endif
   int      oshade=this->shade;

   int      ot=this->texture?1:0;

  COLOR   oc=*this;

   COLOR    *tpx;

   int      otranslucent=this->translucent;

    int     mxe=0,
            pxe=camera->width,
            mye=0,
            pye=camera->height;
    
    char    *vbuffer=(char *)camera->data;
    long    *zbuffer=camera->zbuffer;
    int     zbw=camera->width,
            zbh=camera->height;


 if (ot) tpx=this->texture->GetDataPtr();
  i=plane_id;

  //<<--------plane visibility check


//*********************************************************************
// Skip non visible faces...
    VECTOR v;
    long s;
    long dist=camera->dist;

    if (this->vertex[this->plane[i].vindex[0]].zw<=-dist||
        this->vertex[this->plane[i].vindex[1]].zw<=-dist||
        this->vertex[this->plane[i].vindex[2]].zw<=-dist)
        return;
    
    v.x=this->vertex[this->plane[i].vindex[0]].xw;
    v.y=this->vertex[this->plane[i].vindex[0]].yw;
    v.z=this->vertex[this->plane[i].vindex[0]].zw;

    if(!otranslucent||(otranslucent&&!this->translucent_doublesided)) {
      s=(this->plane[i].Nw.x>>8)*((v.x)>>8);
      s+=(this->plane[i].Nw.y>>8)*((v.y)>>8);
      s+=(this->plane[i].Nw.z>>8)*((v.z+dist)>>8);

      if (s>0)
        return;
    }
    this->plane_sort_by_y_2d(i);

    y0=this->vertex[this->plane[i].vindex2d[0]].y2d;
    y1=this->vertex[this->plane[i].vindex2d[1]].y2d;
    y2=this->vertex[this->plane[i].vindex2d[2]].y2d;

    x0=this->vertex[this->plane[i].vindex2d[0]].x2d<<8;
    x1=this->vertex[this->plane[i].vindex2d[1]].x2d<<8;
    x2=this->vertex[this->plane[i].vindex2d[2]].x2d<<8;

    if (y0<(long)mye&&y1<(long)mye&&y2<(long)mye) return;
    if (y0>(long)pye&&y1>(long)pye&&y2>(long)pye) return;
    long mxe8=(long)mxe<<8;
    if (x0<(long)mxe8&&x1<(long)mxe8&&x2<(long)mxe8) return;
    long pxe8=(long)pxe<<8;
    if (x0>(long)pxe8&&x1>(long)pxe8&&x2>(long)pxe8) return;
    
    w0=this->vertex[this->plane[i].vindex2d[0]].w;
    w1=this->vertex[this->plane[i].vindex2d[1]].w;
    w2=this->vertex[this->plane[i].vindex2d[2]].w;

    if (oshade==SHADE_GOURAUD||oshade==SHADE_PHONG){
      nx0=this->vertex[this->plane[i].vindex2d[0]].Nw.xworld;
      nx1=this->vertex[this->plane[i].vindex2d[1]].Nw.xworld;
      nx2=this->vertex[this->plane[i].vindex2d[2]].Nw.xworld;

      ny0=this->vertex[this->plane[i].vindex2d[0]].Nw.yworld;
      ny1=this->vertex[this->plane[i].vindex2d[1]].Nw.yworld;
      ny2=this->vertex[this->plane[i].vindex2d[2]].Nw.yworld;

      nz0=this->vertex[this->plane[i].vindex2d[0]].Nw.zworld;
      nz1=this->vertex[this->plane[i].vindex2d[1]].Nw.zworld;
      nz2=this->vertex[this->plane[i].vindex2d[2]].Nw.zworld;
    }

    if (ot){
      u0=this->vertex[this->plane[i].vindex2d[0]].u;
      u1=this->vertex[this->plane[i].vindex2d[1]].u;
      u2=this->vertex[this->plane[i].vindex2d[2]].u;

      if (recycle_u){
        if (u0<0&&u1<0&&u2>0) u2=u2-(256L<<16);
        else
        if (u0<0&&u1>0&&u2<0) u1=u1-(256L<<16);
        else
        if (u0>0&&u1<0&&u2<0) u0=u0-(256L<<16);
        else
        if (u0>=0&&u1>0&&u2<0) u2=u2+(256L<<16);
        else
        if (u0>0&&u1<0&&u2>0) u1=u1+(256L<<16);
        else
        if (u0<0&&u1>0&&u2>0) u0=u0+(256L<<16);
      }

      v0=this->vertex[this->plane[i].vindex2d[0]].v;
      v1=this->vertex[this->plane[i].vindex2d[1]].v;
      v2=this->vertex[this->plane[i].vindex2d[2]].v;

      if (recycle_v){
        if (v0<0&&v1<0&&v2>0) v2=v2-(256L<<16);
        else
        if (v0<0&&v1>0&&v2<0) v1=v1-(256L<<16);
        else
        if (v0>0&&v1<0&&v2<0) v0=v0-(256L<<16);
        else
        if (v0>=0&&v1>0&&v2<0) v2=v2+(256L<<16);
        else
        if (v0>0&&v1<0&&v2>0) v1=v1+(256L<<16);
        else
        if (v0<0&&v1>0&&v2>0) v0=v0+(256L<<16);
      }
    }

#ifdef USE_FLAT
    if (oshade==SHADE_FLAT){
      calc_light(scene,this->plane[i].Nw.xworld,this->plane[i].Nw.yworld,this->plane[i].Nw.zworld,
                 &fc.r,&fc.g,&fc.b);
    }
    else
#endif
    if (oshade==SHADE_GOURAUD){
      cr0=0;cr1=0;cr2=0;
      cg0=0;cg1=0;cg2=0;
      cb0=0;cb1=0;cb2=0;

      calc_light(scene,nx0,ny0,nz0,(uchar *)&cr0,(uchar *)&cg0,(uchar *)&cb0);
      calc_light(scene,nx1,ny1,nz1,(uchar *)&cr1,(uchar *)&cg1,(uchar *)&cb1);
      calc_light(scene,nx2,ny2,nz2,(uchar *)&cr2,(uchar *)&cg2,(uchar *)&cb2);

      cr0<<=16;
      cg0<<=16;
      cb0<<=16;

      cr1<<=16;
      cg1<<=16;
      cb1<<=16;

      cr2<<=16;
      cg2<<=16;
      cb2<<=16;
    }

    if (y0!=y1) {

      long abs_y1y0=xlabs(y1-y0);
      dx0=calc_d(x1,x0,abs_y1y0);
      dw0=calc_d(w1,w0,abs_y1y0);//(w1-w0)/abs(y1-y0);

#ifdef USE_PHONG
      if (oshade==SHADE_PHONG){
        dnx0=calc_d(nx1,nx0,abs_y1y0);//(nx1-nx0)/abs(y0-y1);
        dny0=calc_d(ny1,ny0,abs_y1y0);//(ny1-ny0)/abs(y0-y1);
        dnz0=calc_d(nz1,nz0,abs_y1y0);//(nz1-nz0)/abs(y0-y1);
      }
      else
#endif
      if (oshade==SHADE_GOURAUD){
        dcr0=calc_d(cr1,cr0,abs_y1y0);//(cr1-cr0)/abs(y0-y1);
        dcg0=calc_d(cg1,cg0,abs_y1y0);//(cg1-cg0)/abs(y0-y1);
        dcb0=calc_d(cb1,cb0,abs_y1y0);//(cb1-cb0)/abs(y0-y1);
      }
      if (ot){
        dv0=calc_d(v1,v0,abs_y1y0);
        du0=calc_d(u1,u0,abs_y1y0);
      }

    }

    if (y1!=y2) {

      long abs_y2y1=xlabs(y2-y1);
      dx1=calc_d(x2,x1,abs_y2y1);
      dw1=calc_d(w2,w1,abs_y2y1);//(w2-w1)/abs(y2-y1);

#ifdef USE_PHONG
      if (oshade==SHADE_PHONG){
        dnx1=calc_d(nx2,nx1,abs_y2y1);//(nx2-nx1)/abs(y2-y1);
        dny1=calc_d(ny2,ny1,abs_y2y1);//(ny2-ny1)/abs(y2-y1);
        dnz1=calc_d(nz2,nz1,abs_y2y1);//(nz2-nz1)/abs(y2-y1);
      }
      else
#endif
      if (oshade==SHADE_GOURAUD){
        dcr1=calc_d(cr2,cr1,abs_y2y1);//(cr2-cr1)/abs(y2-y1);
        dcg1=calc_d(cg2,cg1,abs_y2y1);//(cg2-cg1)/abs(y2-y1);
        dcb1=calc_d(cb2,cb1,abs_y2y1);//(cb2-cb1)/abs(y2-y1);
      }
      if (ot){
        du1=calc_d(u2,u1,abs_y2y1);
        dv1=calc_d(v2,v1,abs_y2y1);
      }
    }

    if (y0!=y2) {

      long abs_y2y0=xlabs(y2-y0);
      dx2=calc_d(x2,x0,abs_y2y0);
      dw2=calc_d(w2,w0,abs_y2y0);//(w2-w0)/abs(y2-y0);

#ifdef USE_PHONG
      if (oshade==SHADE_PHONG){
        dnx2=calc_d(nx2,nx0,abs_y2y0);//(nx2-nx0)/abs(y2-y0);
        dny2=calc_d(ny2,ny0,abs_y2y0);//(ny2-ny0)/abs(y2-y0);
        dnz2=calc_d(nz2,nz0,abs_y2y0);//(nz2-nz0)/abs(y2-y0);
      }
      else
#endif
      if (oshade==SHADE_GOURAUD){
        dcr2=calc_d(cr2,cr0,abs_y2y0);//(cr2-cr0)/abs(y0-y2);
        dcg2=calc_d(cg2,cg0,abs_y2y0);//(cg2-cg0)/abs(y0-y2);
        dcb2=calc_d(cb2,cb0,abs_y2y0);//(cb2-cb0)/abs(y0-y2);
      }
      if (ot){
        du2=calc_d(u2,u0,abs_y2y0);
        dv2=calc_d(v2,v0,abs_y2y0);
      }
    }

    if (y2>=pye)
      y2=pye-1;

    if (y1>=pye-1)
      y1=pye;

    y=y0;
    if (y<-1000) return;
    xr=xl=x0;
    wl=wr=w0;
    midpassed=0;

#ifdef USE_PHONG
    if (oshade==SHADE_PHONG){
      nxl=nxr=nx0;
      nyl=nyr=ny0;
      nzl=nzr=nz0;
    }
    else
#endif
    if (oshade==SHADE_GOURAUD){
      crl=crr=cr0;
      cgl=cgr=cg0;
      cbl=cbr=cb0;
    }
    if (ot){
      ul=ur=u0;
      vl=vr=v0;
    }

     char* vpp;
     long* wpp;
    vpp=&vbuffer[y*camera->pitch];  //y*pitch
    wpp=&zbuffer[y*zbw];

    if (otranslucent&&this->translucent_stainglass&&y2<pye)
      y2++;

    while (y<y2){

      if (y==y1) {
        xr=x1;
#ifdef USE_PHONG
        if (oshade==SHADE_PHONG){
          nxr=nx1;
          nyr=ny1;
          nzr=nz1;
        }
        else
#endif
        if (oshade==SHADE_GOURAUD){
          crr=cr1;
          cgr=cg1;
          cbr=cb1;
        }
        if (ot){
          ur=u1;
          vr=v1;
        }
        wr=w1;
        midpassed=1;
      }
     if (y>=mye){
//=================================
      lx1=xl>>8;
      lx2=xr>>8;

#ifdef USE_PHONG
      if (oshade==SHADE_PHONG){
        lnx1=nxl;
        lnx2=nxr;

        lny1=nyl;
        lny2=nyr;

        lnz1=nzl;
        lnz2=nzr;
      }
      else
#endif
      if (oshade==SHADE_GOURAUD){
        gour.lcr1=crl;
        gour.lcg1=cgl;
        gour.lcb1=cbl;

        lcr2=crr;
        lcg2=cgr;
        lcb2=cbr;
      }
      if (ot){
        tx.lu1=ul;
        tx.lv1=vl;

        lu2=ur;
        lv2=vr;
      }

      lw1=wl;
      lw2=wr;

      if (lx1>lx2) {
        swap(&lx1,&lx2);
#ifdef USE_PHONG
        if (oshade==SHADE_PHONG){
          swap(&lnx1,&lnx2);
          swap(&lny1,&lny2);
          swap(&lnz1,&lnz2);
        }
        else
#endif
        if (oshade==SHADE_GOURAUD){
          swap(&gour.lcr1,&lcr2);
          swap(&gour.lcg1,&lcg2);
          swap(&gour.lcb1,&lcb2);
        }
        if (ot){
          swap(&tx.lu1,&lu2);
          swap(&tx.lv1,&lv2);
        }
        swap(&lw1,&lw2);
      }

      if (lx1!=lx2){
        long abs_lx2lx1=lx2-lx1;
#ifdef USE_PHONG
        if (oshade==SHADE_PHONG){
          dlnx=calc_d(lnx2,lnx1,abs_lx2lx1);//(lnx2-lnx1)/(lx2-lx1);
          dlny=calc_d(lny2,lny1,abs_lx2lx1);//(lny2-lny1)/(lx2-lx1);
          dlnz=calc_d(lnz2,lnz1,abs_lx2lx1);//(lnz2-lnz1)/(lx2-lx1);
        }
        else
#endif
        if (oshade==SHADE_GOURAUD){
          gour.dlcr=calc_d(lcr2,gour.lcr1,abs_lx2lx1);//(lcr2-lcr1)/(lx2-lx1);
          gour.dlcg=calc_d(lcg2,gour.lcg1,abs_lx2lx1);//(lcg2-lcg1)/(lx2-lx1);
          gour.dlcb=calc_d(lcb2,gour.lcb1,abs_lx2lx1);//(lcb2-lcb1)/(lx2-lx1);
        }
        if (ot){
          tx.dlu=calc_d(lu2,tx.lu1,abs_lx2lx1);//tx.dlu=(lu2-tx.lu1)/abs_lx2lx1;//
          tx.dlv=calc_d(lv2,tx.lv1,abs_lx2lx1);//tx.dlv=(lv2-tx.lv1)/abs_lx2lx1;//
        }

        dlw=calc_d(lw2,lw1,abs_lx2lx1);//(lw2-lw1)/(lx2-lx1);
      }

      if (lx2>pxe)
        lx2=pxe;

      if (lx1<mxe){
        long mk=mxe-lx1;

#ifdef USE_PHONG
        if (oshade==SHADE_PHONG){
          lnx1+=mk*dlnx;
          lny1+=mk*dlny;
          lnz1+=mk*dlnz;
        }
        else
#endif
        if (oshade==SHADE_GOURAUD){
          gour.lcr1+=mk*gour.dlcr;
          gour.lcg1+=mk*gour.dlcg;
          gour.lcb1+=mk*gour.dlcb;
        }
        if (ot){
          tx.lu1+=mk*tx.dlu;
          tx.lv1+=mk*tx.dlv;
        }

        lw1+=mk*dlw;

        lx1=mxe;
      }

       char *vp;
      if (bpp==24)
        vp=vpp+lx1+lx1+lx1;
      else
        vp=vpp+(lx1<<2);

       long *wp;
      wp=wpp+lx1;

      if (this->translucent&&this->translucent_stainglass&&lx2<pxe)
        lx2++;

//===============================================innerloop
      for (x=lx1;x<lx2;x++){
        if (lw1>*wp){
         if (!otranslucent){
            *wp=lw1;
            putpointed++;
          }
#ifdef USE_PHONG
         if (oshade==SHADE_PHONG){
          calc_light(scene,lnx1,lny1,lnz1,&c.r,&c.g,&c.b);
         }
         else
#endif
         if (oshade==SHADE_GOURAUD){
          __asm{
            mov     eax,[gour.lcr1]
            mov     al,byte ptr [gour.lcb1+2]
            mov     ah,byte ptr [gour.lcg1+2]
            mov     c.color,eax
          }
         }
         else
         if (oshade==SHADE_SOLID){
          c.color=oc.color;
         }
#ifdef USE_FLAT
         else
         if (oshade==SHADE_FLAT){
            c.color=fc.color;
         }
#endif

         if (ot){ //texturisation
            __asm{

              mov     ebx,tx.lu1
              mov     eax,tx.lv1
              sar     ebx,14
              and     eax,0x1ff0000
              and     ebx,(0x1ff)<<2
              sar     eax,5
              or      eax,ebx
              
              mov     ecx,[tpx]

              cmp     otranslucent,0
              je      txtlab1
              mov     ebx,MixTable
              jmp     txtlab2
              txtlab1:
              mov     ebx,TextureTable
              txtlab2:
              
              mov     ecx,[ecx+eax]
              cmp     otranslucent,0
              jne     txtlab3
              test    ecx,ecx
              jz      txtlab4
              txtlab3:
              mov     dl,ch
              mov     al,cl
              and     edx,0xff
              and     eax,0xff

              shr     ecx,16

              //cl:r
              //al:b
              //dl:g

              mov     dh,byte ptr c.g
              mov     ch,byte ptr c.r
              mov     ah,byte ptr c.b
              
              mov     ecx,[ebx+ecx*4]
              mov     ch,[ebx+edx*4+2]
              mov     cl,[ebx+eax*4+2]
              //mov     edx,dword ptr [ebx+edx*4+65536*4] //green
              //or      edx,dword ptr [ebx+eax*4] //blue
              //or      edx,dword ptr [ebx+ecx*4+65536*4*2]//red

txtlab4:
              mov     c.color,ecx
           }
         }
       
         if (otranslucent){//cristall
           if (c.color){
            __asm{
              mov     ecx,[vp];
              mov     ebx,MixTable
              mov     ecx,[ecx]

              //mov     ecx,[ecx];
              //movzx   eax,cx
              //movzx   edx,ah;

              mov     dl,ch
              mov     al,cl
              and     edx,0xff
              and     eax,0xff

              shr     ecx,16

              mov     dh,byte ptr c.g
              mov     ch,byte ptr c.r
              mov     ah,byte ptr c.b
              
              mov     ecx,[ebx+ecx*4]
              mov     ch,byte ptr [ebx+edx*4+2]
              mov     cl,byte ptr [ebx+eax*4+2]

              //mov     edx,dword ptr [MixTable+edx*4+65536*4] //green
              //or      edx,dword ptr [MixTable+eax*4] //blue
              //or      edx,dword ptr [MixTable+ecx*4+65536*4*2]//red

              mov     c.color,ecx
            }
           }
           else c.color=*(uint *)vp;
          }
         //} //need frames end
          __asm{
            mov       ebx,vp
            //putpixel
            cmp       bpp,32
            je        putpix1
            //24bit
            mov       eax,c.color
            mov       [ebx],ax
            mov       al,c.r
            mov       [ebx+2],al
            jmp       putpix2
            putpix1:  //32 bit
            mov       eax,dword ptr c.color;
            mov       [ebx],eax
            putpix2:
          }

        }
        __asm{
          cmp       bpp,32
          je        putinc1
          dec       vp
          putinc1:
          add       vp,4
        
          add       wp,4
          mov       eax,dlw
          add       lw1,eax
        }

#ifdef USE_PHONG
        if (oshade==SHADE_PHONG){
          __asm{
            mov     eax,dlnx
            mov     ebx,dlny
            add     lnx1,eax
            mov     ecx,dlnz
            add     lny1,ebx
            add     lnz1,ecx
          }
        }
        else
#endif
        if (oshade==SHADE_GOURAUD){
          __asm{
            movq    mm0,qword ptr gour.lcr1
            paddd   mm0,qword ptr gour.dlcr
            movq    qword ptr gour.lcr1,mm0
            mov     eax,gour.dlcb
            add     gour.lcb1,eax
          }
        }
        if (ot){
          __asm{
            movq      mm0,qword ptr tx.lu1
            paddd     mm0,qword ptr tx.dlu
            movq      qword ptr tx.lu1,mm0
          }
        }
      }
//=================================end of inner loop
     }
      __asm{
        emms
      }
      if (midpassed){
        xr+=dx1;
        wr+=dw1;

#ifdef USE_PHONG
        if (oshade==SHADE_PHONG){
          nxr+=dnx1;
          nyr+=dny1;
          nzr+=dnz1;
        }
        else
#endif
        if (oshade==SHADE_GOURAUD){
          crr+=dcr1;
          cgr+=dcg1;
          cbr+=dcb1;
        }
        if (ot){
          ur+=du1;
          vr+=dv1;
        }
      }
      else{
        xr+=dx0;
        wr+=dw0;

#ifdef USE_PHONG
        if (oshade==SHADE_PHONG){
          nxr+=dnx0;
          nyr+=dny0;
          nzr+=dnz0;
        }
        else
#endif
        if (oshade==SHADE_GOURAUD){
          crr+=dcr0;
          cgr+=dcg0;
          cbr+=dcb0;
        }
        if (ot){
          ur+=du0;
          vr+=dv0;
        }
      }

      xl+=dx2;
      wl+=dw2;

#ifdef USE_PHONG
      if (oshade==SHADE_PHONG){
        nxl+=dnx2;
        nyl+=dny2;
        nzl+=dnz2;
      }
      else
#endif
      if (oshade==SHADE_GOURAUD){
        crl+=dcr2;
        cgl+=dcg2;
        cbl+=dcb2;
      }
      if (ot){
        ul+=du2;
        vl+=dv2;
      }

      y++;
      vpp+=camera->pitch;
      wpp+=zbw;
    }
//  }
// } //end of "object visible"
}

void OBJECT::flip_plane_normals(){
  for (uint i=0;i<planecount;i++){
    swap((long *)&plane[i].vindex[1],(long *)&plane[i].vindex[0]);
  }
  this->calc_plane_normals();
}

void LIGHT::Set(int type,long x,long y,long z,uint color){
  this->type=type;
  this->x=x;
  this->y=y;
  this->z=z;
  this->color=color;
}

void VECTOR::operator*=(MATRIX &matrix){

  long oldx=this->x;
  long oldy=this->y;
  long oldz=this->z;

  long newx,newy,newz;
  x=(long)(((double)matrix.a[0][0]*oldx+(double)matrix.a[0][1]*oldy+(double)matrix.a[0][2]*oldz)/65536)+matrix.a[0][3];
/*  __asm{

    //mov   ebp,[this]

    //calc x
  
    mov   eax,matrix.a[0][0]
    imul  oldx
    shrd  eax,edx,16
    mov esi,eax
    //mov   esi,eax
    //mov   edi,edx

    mov   eax,matrix.a[0][1]
    imul  oldy
    shrd  eax,edx,16
    add esi,eax
    //add   esi,eax
    //adc   edi,edx

    mov   eax,matrix.a[0][2]
    imul  oldz
    shrd  eax,edx,16
    add esi,eax
    //add   esi,eax
    //adc   edi,edx

    //shrd  esi,edi,16

    add   esi,matrix.a[0][3]

//    mov   [ebp]VECTOR.x,esi
    mov   newx,esi

  }*/
  //x=newx;
  
  y=(long)(((double)matrix.a[1][0]*oldx+(double)matrix.a[1][1]*oldy+(double)matrix.a[1][2]*oldz)/65536)+matrix.a[1][3];
  z=(long)(((double)matrix.a[2][0]*oldx+(double)matrix.a[2][1]*oldy+(double)matrix.a[2][2]*oldz)/65536)+matrix.a[2][3];

}

void OBJECT::operator+=(OBJECT &obj){
  VERTEX *newvert;
  PLANE  *newplane;
  uint newvertexcount=vertexcount+obj.vertexcount;
  uint newplanecount=planecount+obj.planecount;

  newvert=new VERTEX[newvertexcount];
  newplane=new PLANE[newplanecount];

  for (uint i=0;i<vertexcount;i++)
    newvert[i]=vertex[i];
  for (i=vertexcount;i<newvertexcount;i++)
    newvert[i]=obj.vertex[i-vertexcount];

  for (i=0;i<planecount;i++)
    newplane[i]=plane[i];
  for (i=planecount;i<newplanecount;i++){
    newplane[i]=obj.plane[i-planecount];
    newplane[i].vindex[0]+=vertexcount;
    newplane[i].vindex[1]+=vertexcount;
    newplane[i].vindex[2]+=vertexcount;
  }

  delete vertex;
  delete plane;
  vertex=newvert;
  vertexcount=newvertexcount;
  plane=newplane;
  planecount=newplanecount;
}

void OBJECT::Clone(OBJECT *obj){
  *this=*obj;
  vertex=new VERTEX[vertexcount];
  plane=new PLANE[planecount];
  for (uint i=0;i<vertexcount;i++)
    vertex[i]=obj->vertex[i];
  for (i=0;i<planecount;i++)
    plane[i]=obj->plane[i];
}

void OBJECT::Array(uint count,MATRIX *matrix){
  OBJECT obj;
  obj.Clone(this);
  for (uint c=0;c<count;c++){
    for (uint i=0;i<obj.vertexcount;i++){
      obj.vertex[i]*=*matrix;
    }
    *this+=obj;
  }
  this->calc_plane_normals();
}

void OBJECT::Transform(MATRIX *matrix){
  for (uint i=0;i<vertexcount;i++){
    vertex[i]*=*matrix;
  }
  this->calc_plane_normals();
}

void SHAPE::Transform(MATRIX *matrix,int step){
  VERTEX v;
  for (uint i=0;i<vertexcount;i+=step){
    v.x=(long)vertex[i].x<<16;
    v.y=(long)vertex[i].y<<16;
    v.z=0;
    v*=*matrix;
    vertex[i].x=(short)((long)v.x>>16);
    vertex[i].y=(short)((long)v.y>>16);
  }
}

void MATRIX::MakeEquality(){
  memset(this,0,sizeof(MATRIX));
  a[0][0]=1L<<16;
  a[1][1]=1L<<16;
  a[2][2]=1L<<16;
  a[3][3]=1L<<16;
} 

int MATRIX::Unpack(void *packed){
  this->MakeEquality();
  ushort bits=*(ushort *)(packed);
  long *src=(long *)(((char *)packed)+2);
  long *dst=(long *)a;
  int cnt=2;
  for (int i=0;i<16;i++){
    if (bits&0x8000){
      *dst=*src;
      src++;
      cnt+=4;
    }
    dst++;
    bits<<=1;
  }
  return cnt;
}

void OBJECT::Loft(uint count,MATRIX* matrix,SHAPE *shape,uint flags){
  if (flags&LOFT_COVER)
    this->reset(shape->vertexcount*count,shape->edgecount*count*2+shape->planecount);
  else
  if (flags&LOFT_ENCLOSE)
    this->reset(shape->vertexcount*count,shape->edgecount*(count+1)*2);
  else
    this->reset(shape->vertexcount*count,shape->edgecount*count*2);
  
  uint i,j,k;

  for (i=0;i<shape->vertexcount;i++){
    this->vertex[i].x=(long)shape->vertex[i].x<<16;
    this->vertex[i].y=(long)shape->vertex[i].y<<16;
    this->vertex[i].z=0;
    vertexcount++;
  }

  for (j=1;j<count;j++){
    for (i=0;i<shape->vertexcount;i++){
      vertex[j*shape->vertexcount+i]=vertex[(j-1)*shape->vertexcount+i];
      vertex[j*shape->vertexcount+i]*=*matrix;
      vertexcount++;
    }
    for (i=0;i<shape->edgecount;i++){
      plane[planecount].vindex[0]=j*shape->vertexcount+shape->edge[i].vindex[0];
      plane[planecount].vindex[1]=j*shape->vertexcount+shape->edge[i].vindex[1];
      plane[planecount].vindex[2]=(j-1)*shape->vertexcount+shape->edge[i].vindex[0];
      planecount++;
      plane[planecount].vindex[0]=(j-1)*shape->vertexcount+shape->edge[i].vindex[1];
      plane[planecount].vindex[1]=(j-1)*shape->vertexcount+shape->edge[i].vindex[0];
      plane[planecount].vindex[2]=j*shape->vertexcount+shape->edge[i].vindex[1];
      planecount++;
    }
  }

  if (flags&LOFT_ENCLOSE){
    for (i=0;i<shape->edgecount;i++){
      plane[planecount].vindex[0]=shape->edge[i].vindex[0];
      plane[planecount].vindex[1]=shape->edge[i].vindex[1];
      plane[planecount].vindex[2]=(count-1)*shape->vertexcount+shape->edge[i].vindex[0];
      planecount++;
      plane[planecount].vindex[0]=(count-1)*shape->vertexcount+shape->edge[i].vindex[1];
      plane[planecount].vindex[1]=(count-1)*shape->vertexcount+shape->edge[i].vindex[0];
      plane[planecount].vindex[2]=shape->edge[i].vindex[1];
      planecount++;
    }
  }

  if (flags&LOFT_COVER){
    for (i=0;i<shape->planecount;i++){
      plane[planecount].vindex[0]=shape->plane[i].vindex[0];
      plane[planecount].vindex[1]=shape->plane[i].vindex[1];
      plane[planecount].vindex[2]=shape->plane[i].vindex[2];
      planecount++;
      plane[planecount].vindex[1]=(count-1)*shape->vertexcount+shape->plane[i].vindex[0];
      plane[planecount].vindex[0]=(count-1)*shape->vertexcount+shape->plane[i].vindex[1];
      plane[planecount].vindex[2]=(count-1)*shape->vertexcount+shape->plane[i].vindex[2];
      planecount++;
    }
  }

  this->Cleanup();
  calc_plane_normals();
}

void OBJECT::Extrude(SHAPE *shape,uint flags){
//  if (flags&EXTRUDE_DOUBLESIDED){
//    this->reset(shape->vertexcount,shape->planecount*2);
//  }
//  else{
    this->reset(shape->vertexcount,shape->planecount);
//  }

  int i;

  for (i=0;i<shape->vertexcount;i++){
    vertex[i].x=((long)shape->vertex[i].x)<<16;
    vertex[i].y=((long)shape->vertex[i].y)<<16;
    vertex[i].z=0;
    vertexcount++;
  }
  for (i=0;i<shape->planecount;i++){
    plane[planecount].vindex[0]=shape->plane[i].vindex[0];
    plane[planecount].vindex[1]=shape->plane[i].vindex[1];
    plane[planecount].vindex[2]=shape->plane[i].vindex[2];
    planecount++;
/*
    if (flags&EXTRUDE_DOUBLESIDED){
      plane[planecount].vindex[1]=(count-1)*shape->vertexcount+shape->plane[i].vindex[0];
      plane[planecount].vindex[0]=(count-1)*shape->vertexcount+shape->plane[i].vindex[1];
      plane[planecount].vindex[2]=(count-1)*shape->vertexcount+shape->plane[i].vindex[2];
      planecount++;
    }
*/
  }

}

void SHAPE::gnCircle(int cx,int cy,uint R,uint maxsteps,uint steps,double start_angle){
  if (steps==maxsteps)
    this->reset(steps+1,steps,steps,steps);
  else
    this->reset(steps+1,steps+1,steps,steps-1);
  
  double a,da;
  da=2*PI/maxsteps;
  a=start_angle;
  uint i;
  for(i=0;i<steps;i++){
    vertex[i].x=(short)(cos(a)*R)+cx;
    vertex[i].y=(short)(sin(a)*R)+cy;

    if ((steps!=maxsteps&&i!=steps-1)||steps==maxsteps){
      edge[i].vindex[1]=i;
      edge[i].vindex[0]=(i+1)%maxsteps;

      plane[i].vindex[1]=i;
      plane[i].vindex[0]=(i+1)%maxsteps;
      plane[i].vindex[2]=steps;
    }

    a+=da;
  }

  if (steps!=maxsteps){
    edge[i-1].vindex[1]=i-1;
    edge[i-1].vindex[0]=steps;

    edge[i].vindex[1]=steps;
    edge[i].vindex[0]=0;
  }

  this->vertex[steps].x=cx;
  this->vertex[steps].y=cy;

}

void SHAPE::reset(uint vertexcount,uint edgecount,uint loftvertexcount,uint planecount){
  delete  vertex;
  delete  edge;
  delete  plane;
  vertex=new SHAPE_VERTEX[vertexcount];
  edge=new SHAPE_EDGE[edgecount];
  plane=new SHAPE_PLANE[planecount];
  this->edgecount=edgecount;
  this->vertexcount=vertexcount;
  this->loftvertexcount=loftvertexcount;
  this->planecount=planecount;
}

PLANE_SELECTOR render_plane[SCENE_MAX_PLANES];

void OBJECT::render(SCENE *scene,uint camera_id){
  return;
}


int __cdecl plane_mid_z_compare(const void *p1,const void *p2){
  PLANE_SELECTOR *pp1,*pp2;
  pp1=(PLANE_SELECTOR *)p1;
  pp2=(PLANE_SELECTOR *)p2;
  
  if (pp1->object->translucent&&!pp2->object->translucent) return 1;
  if (!pp1->object->translucent&&pp2->object->translucent) return -1;
  if (pp1->object->translucent&&pp2->object->translucent) return 0;

  return pp1->object->vertex[pp1->plane->vindex[0]].zw-pp2->object->vertex[pp2->plane->vindex[0]].zw;
}

void SCENE::render(int camera_id){
    uint i,j;
    uint pc=0;
    for (i=0;i<SCENE_MAX_OBJECTS;i++){
      if (this->object[i]){
        if (this->object[i]->visible&&this->object[i]->standard_render){
          for (j=0;j<object[i]->planecount;j++){
            render_plane[pc].scene=this;
            render_plane[pc].object=object[i];
            render_plane[pc].plane=&object[i]->plane[j];
            render_plane[pc].plane_id=j;  
            pc++;
          }
          object[i]->plane_normals_to_camera(camera[camera_id]);
          object[i]->calc_vertex_normals();
          for (j=0;j<object[i]->vertexcount;j++){
            object[i]->vertex[j].project(object[i],this->camera[camera_id]);
          }
        }
      }
    }
    qsort(render_plane,pc,sizeof(PLANE_SELECTOR),&plane_mid_z_compare);
    
    camera[camera_id]->InitAndLock();
    if (!camera[camera_id]->data) return;
    for (i=0;i<pc;i++){
      render_plane[i].object->render_plane(this,camera_id,render_plane[i].plane_id);
    }
    for (i=0;i<SCENE_MAX_OBJECTS;i++){
      if (object[i])
        if (!object[i]->standard_render&&object[i]->visible)
          object[i]->render(this,camera_id);
    }
    CAMERA *cam=camera[camera_id];
    if (cam->fog==FOG_FOG){
      COLOR fog;
      COLOR cxx;
      long n,nx;
      uchar *dat=(uchar *)cam->data;
      long  *zb=cam->zbuffer;
      uint  camw=cam->width,camh=cam->height;
      
      /*static long fog_tex_frame=0;

      fog_tex_frame+=3;*/

      for (int yy=0;yy<camh;yy++){
        __asm {
          mov   edi,dat
          mov   esi,zb
        }
        //COLOR *txp=plasm1->GetDataPtr();

        for (int xx=0;xx<camw;xx++){
          __asm{
            mov     eax,[esi]
            test    eax,eax
            //cmp     eax,300000
            jz      xwfogl4

            /*mov     edx,yy
            add     edx,fog_tex_frame
            shl     edx,9
            add     edx,xx
            shl     edx,2
            and     edx,0xfffff
            add     edx,txp
            movzx   edx,byte ptr [edx]
            shl     edx,14
            add     eax,edx
            */

            cmp     eax,256<<18
            jb      xwfogl1
            mov     eax,256<<18
          xwfogl1:
            shr     eax,5
          
            mov     edx,[edi]
            
            mov     ebx,eax
            mov     bl,dl

            mov     ecx,eax
            mov     cl,dh

            mov     al,dl

            mov     edx,FogTable2
            mov     eax,[edx+eax*4] //r
            mov     ah,byte ptr [edx+ecx*4+2] //g
            mov     al,byte ptr [edx+ebx*4+2] //b

            mov     ebx,bpp
            cmp     ebx,32
            je      xwfogl2
            mov     word ptr [edi],ax
            shr     eax,16
            mov     byte ptr [edi+2],al
            add     edi,3
            jmp     xwfogl5
          xwfogl2:
            mov     [edi],eax
            add     edi,4
            jmp     xwfogl5
          xwfogl4:
            mov     ebx,bpp
            cmp     ebx,32
            jne     xwfogl6
            inc     edi
          xwfogl6:
            add     edi,3
          xwfogl5:
            add     esi,4
          }
        }
        dat+=cam->pitch;
        zb+=cam->width;
      }
    }
    else
    if (cam->fog==FOG_WATER){
      COLOR fog;
      COLOR cxx;
      long n,nx;
      uchar *dat=(uchar *)cam->data;
      long  *zb=cam->zbuffer;
      uint  camw=cam->width,camh=cam->height;
      
      static long fog_tex_frame=0;

      fog_tex_frame+=3;

      for (int yy=0;yy<camh;yy++){
        __asm {
          mov   edi,dat
          mov   esi,zb
        }
        COLOR *txp=plasm1->GetDataPtr();

        for (int xx=0;xx<camw;xx++){
          __asm{
            mov     eax,[esi]
            test    eax,eax
            jz      wfogl4

            mov     edx,yy
            add     edx,fog_tex_frame
            shl     edx,9
            add     edx,xx
            shl     edx,2
            and     edx,0xfffff
            add     edx,txp
            movzx   edx,byte ptr [edx]
            shl     edx,15
            add     eax,edx

            cmp     eax,256<<23
            jb      wfogl1
            mov     eax,256<<23
          wfogl1:
            shr     eax,10
          
            mov     edx,[edi]
            
            mov     ebx,eax
            mov     bl,dl

            mov     ecx,eax
            mov     cl,dh

            mov     eax,edx

            //----------dirty camera
            
/*
            mov     edx,yy
            shl     edx,9
            add     edx,xx
            shl     edx,2
            and     edx,0xfffff
            add     edx,txp
            mov     dl,[edx]
            shr     dl,2
            add     ch,dl
*/
            //----------------------


            mov     edx,FogTable
            mov     ah,byte ptr [edx+ecx*4+2] //g
            mov     al,byte ptr [edx+ebx*4+2] //b

            mov     ebx,bpp
            cmp     ebx,32
            je      wfogl2
            mov     word ptr [edi],ax
            shr     eax,16
            mov     byte ptr [edi+2],al
            add     edi,3
            jmp     wfogl5
          wfogl2:
            mov     [edi],eax
            add     edi,4
            jmp     wfogl5
          wfogl4:
            mov     ebx,bpp
            cmp     ebx,32
            jne     wfogl6
            inc     edi
          wfogl6:
            add     edi,3
          wfogl5:
            add     esi,4
          }
        }
        dat+=cam->pitch;
        zb+=cam->width;
      }

    }
    
    camera[camera_id]->Unlock();
}

void DECAL_SPAWNER::render(SCENE *scene,uint camera_id){
  *((CSYSTEM *)this)=*bind_csystem;
  CAMERA *camera=scene->camera[camera_id];
  
  char    *vbuffer=(char *)scene->camera[camera_id]->data;
  long    *zbuffer=camera->zbuffer;  
  
  uint mxe=0;
  uint pxe=camera->width;
  uint mye=0;
  uint pye=camera->height;

  uint pitch=camera->pitch;

  COLOR c;

  for (uint i=0;i<spawncount;i++){
    if (killonend&&decal->isEnd(current_frame[i])) present[i]=0;
    if (present[i]){
      this->spawnpoint[i].project(this,camera);
    
      if (spawnpoint[i].zw<-camera->dist+(100L<<16)) continue;

      double kp=((double)spawnpoint[i].zw+camera->dist)/(double)camera->dist;
    
      uint y2d=spawnpoint[i].y2d-(uint)(decal->cy/kp);

      long yy=0;
      long dx;
      long dy;
      dx=dy=(long)(65536*kp);

      char *vpp=&vbuffer[y2d*pitch];
      long *wpp=&zbuffer[y2d*camera->width];
    
      uchar *dppx=(uchar *)decal->GetFrame(current_frame[i]);
      uchar *dpp;

      uint dch=(uint)((decal->h-1)/kp);
      uint dcw=(uint)((decal->w-1)/kp);
//      if (dcw==0) {dcw=1;kp=decal->h;};
//      if (dch==0) {dch=1;kp=decal->w;};
      
      for (uint y=0;y<dch;y++,y2d++){
        dpp=dppx+(((yy>>16)+((yy&0x8000)>>15))*decal->w<<2);
        uint x2d=spawnpoint[i].x2d-(uint)(decal->cx/kp);
        long xx=0;

        char *vp=vpp+(bpp==24?(x2d<<1)+x2d:x2d<<2);
        long *wp;
        uchar *dp;
        wp=wpp+x2d;
      
        for (uint x=0;x<dcw;x++,x2d++){
          dp=dpp+(((xx>>16)+((xx&0x8000)>>15))<<2);
          if (y2d>mye && y2d<pye && x2d>mxe && x2d<pxe && *wp<spawnpoint[i].w){
            c=*(COLOR *)dp;
            if (c.color){
              __asm{
                mov     ecx,[vp]
                mov     ecx,[ecx]
                mov     ebx,MixTable

                mov     dl,ch
                mov     al,cl
                and     edx,0xff
                and     eax,0xff

                shr     ecx,16

                mov     dh,byte ptr c.g
                mov     ch,byte ptr c.r
                mov     ah,byte ptr c.b
              
                mov     ecx,[ebx+ecx*4]
                mov     ch,byte ptr [ebx+edx*4+2]
                mov     cl,byte ptr [ebx+eax*4+2]

  //              mov     edx,dword ptr [MixTable+edx*4+65536*4] //green
  //              or      edx,dword ptr [MixTable+eax*4] //blue
  //              or      edx,dword ptr [MixTable+ecx*4+65536*4*2]//red
  //              mov     ebx,dword ptr [MixTable+ecx*4] //r
  //              mov     bh,byte ptr [MixTable+edx*4+2] //g
  //              mov     bl,byte ptr [MixTable+eax*4+2]//b
              
                mov     c.color,ecx
              }
              if(bpp==32){
                *(COLOR *)vp=c.color;
              }
              else{
                *vp=c.b;
                *(vp+1)=c.g;
                *(vp+2)=c.r;
              }
            }
          }
          vp+=(bpp==24?3:4);
          wp++;
          xx+=dx;
        }
        yy+=dy;
        vpp+=pitch;
        wpp+=camera->width;
      }
    }
  }
}

int FONT::getpx(int x,int y,char *dat){
  char sh,sw,ox,oy;
  sh=dat[0];
  sw=dat[1];
  ox=dat[2];
  oy=dat[3];
  if (x<ox||x>=(sw+ox)) return 0;
  if (y<oy||y>=(sh+oy)) return 0;
  char *px=dat+4;
  px+=(y-oy);
  if (*px&(0x80>>(x-ox))) return 1;
  else return 0;
}

void FONT::Unpack(char *abc,uchar *data,uint size,COLOR color,int frames,int flags){
  ushort index[256];
  uchar *p=data;
  for (int ii=0;ii<strlen(abc);ii++){
    index[ii]=p-data;
    uchar ssh=*p;
    p+=4+ssh;
  }

  for (int i=0;i<strlen(abc);i++){
    
    int c=abc[i];
    
    symbol[c]=new DECAL;
    char *dat=(char *)&data[index[i]];
    char sh,sw,ox,oy;
    sh=dat[0];
    sw=dat[1];
    ox=dat[2];
    oy=dat[3];
    double k=(double)size/10;
    symbol[c]->Create(k*(sw+ox+2),k*(sh+oy+2),frames);
    
    for (int x=0;x<symbol[c]->w;x++){
      for (int y=0;y<symbol[c]->h;y++){

        if (flags&FONT_INTERLACED){  
          int kk = ceil(k);
          if((!(x%kk))||(!(y%kk))) {
            //fr[y*symbol[c]->w+x] = 0;
            continue;
          } 
        }

        double nx,ny;
        nx=(double)x/k-1;
        ny=(double)y/k-1;

        COLOR setcolor=0;
        if (getpx(nx,ny,dat)) 
          setcolor=color;
        else{
          COLOR cx=0;
          COLOR cy=color;
          COLOR cz;
          cy.r>>=1;
          cy.g>>=1;
          cy.b>>=1;
        
          cz=cy;
          cz.r>>=1;
          cz.g>>=1;
          cz.b>>=1;

          if (getpx(nx-1,ny,dat)) cx%=cy;
          if (getpx(nx,ny-1,dat)) cx%=cy;
          if (getpx(nx,ny+1,dat)) cx%=cy;
          if (getpx(nx+1,ny,dat)) cx%=cy;

          if (getpx(nx-1,ny-1,dat)) cx%=cz;
          if (getpx(nx+1,ny+1,dat)) cx%=cz;
          if (getpx(nx+1,ny-1,dat)) cx%=cz;
          if (getpx(nx-1,ny+1,dat)) cx%=cz;

          setcolor=cx;
        }
        for (int f=0;f<frames;f++){
          COLOR *fr=symbol[c]->frame[f];
          if (flags&FONT_FADEINOUT){
            fr[y*symbol[c]->w+x].r=(uchar)((double)setcolor.r*sin(f*PI/frames));
            fr[y*symbol[c]->w+x].g=(uchar)((double)setcolor.g*sin(f*PI/frames));
            fr[y*symbol[c]->w+x].b=(uchar)((double)setcolor.b*sin(f*PI/frames));
          }
          else
            fr[y*symbol[c]->w+x]=setcolor;
        }
      }
    }
  }
}
void FONT::GetTextParam(char *string,int *w,int *h){
  *w=0;
  *h=0;
  for (int i=0;i<strlen(string);i++){
    *w+=symbol[string[i]]->w+1;
    if (symbol[string[i]]->h>*h) *h=symbol[string[i]]->h;
  }
  *h++;
}

void FONT::Puts(DECAL *buf,char *string,int frame){
  int extent,maxh;

  GetTextParam(string,&extent,&maxh);

  buf->Create(extent,maxh,1);

  int curx=0;
  int i;
  for (i=0;i<strlen(string);i++){
    int c=string[i];
    for (int x=0;x<symbol[c]->w;x++){
      for (int y=0;y<symbol[c]->h;y++){
        buf->frame[0][y*buf->w+curx+x]=symbol[c]->GetFrame(frame)[y*symbol[c]->w+x];
      }
    }
    curx+=symbol[c]->w+1;
  }
}

void DECAL::BltToSurface(LPDIRECTDRAWSURFACE7 surface,RECT *rct){

  double kp=(double)DEMO_FIXED_WIDTH/(double)DEMO_BB_WIDTH;

  int x2d,y2d;
  y2d=(uint)((this->y2d-this->cy)/kp);
  x2d=(uint)((this->x2d-this->cx)/kp);

  if (rct){
    y2d+=rct->top;
    x2d+=rct->left;
  }
  
  RECT rect;
  rect.left=x2d;
  rect.top=y2d;
  rect.bottom=rect.top+this->h/kp;
  rect.right=rect.left+this->w/kp;
//  if (rect.left<0) rect.left=0;
//  if (rect.top<0) rect.top=0;
//  if (rect.right>=DEMO_WIDTH) rect.right=DEMO_WIDTH-1;
//  if (rect.bottom>=DEMO_HEIGHT) rect.bottom=DEMO_HEIGHT-1;
  
	DDSURFACEDESC2 ddsd;
  ZeroMemory(&ddsd,sizeof(ddsd));
  ddsd.dwSize=sizeof(ddsd);
  void *data=NULL;
  int pitch;

  if (SUCCEEDED(surface->Lock(&rect,&ddsd,DDLOCK_NOSYSLOCK|DDLOCK_WAIT,NULL))){
	  pitch = ddsd.lPitch;
    data = ddsd.lpSurface;
  }
  if (!data) return;

  long yy=0;
  long dx;
  long dy;
  dx=dy=(long)(65536*kp);

  char *vpp=(char *)data;

  uchar *dppx=(uchar *)this->GetFrame(current_frame);
//  if (this->x2d<0) dppx-=this->x2d<<2;
  
  uchar *dpp;
  uint dcw;
  
  if (this->x2d<0)
    dcw=(uint)((this->w+this->x2d)/kp);
  else
    dcw=(uint)(this->w/kp);

  uint dch=(uint)(this->h/kp);
  if (dcw==0) dcw=1;
  if (dch==0) dch=1;
  
  for (uint y=0;y<dch;y++){
    dpp=dppx+((yy>>16)*this->w<<2);
    long xx;
    xx=0;  

    char *vp=vpp;
    uchar *dp;
  
    for (uint x=0;x<dcw;x++){
      dp=dpp+((xx>>16)<<2);
      COLOR c=*(COLOR *)dp;
      __asm{
        mov     ebx,MixTable
        mov     ecx,[vp];

        mov     ecx,[ecx]
        mov     dl,ch
        mov     al,cl
        and     edx,0xff
        and     eax,0xff

        shr     ecx,16

        mov     dh,byte ptr c.g
        mov     ch,byte ptr c.r
        mov     ah,byte ptr c.b
    
        mov     ecx,dword ptr [ebx+ecx*4]
        mov     ch,byte ptr [ebx+edx*4+2]
        mov     cl,byte ptr [ebx+eax*4+2]

//        mov     edx,dword ptr [MixTable+edx*4+65536*4] //green
//        or      edx,dword ptr [MixTable+eax*4] //blue
//        or      edx,dword ptr [MixTable+ecx*4+65536*4*2]//red
    
        mov     c.color,ecx
      }
      *vp=c.b;
      *(vp+1)=c.g;
      *(vp+2)=c.r;

      vp+=(bpp==24?3:4);
      xx+=dx;
    }
    yy+=dy;
    vpp+=pitch;
  }
  if (!data) return;
  surface->Unlock(&rect);
}

void FONT::PutsToSurface(int x,int y,char *string,LPDIRECTDRAWSURFACE7 surface,RECT *rect,int frame){
  DECAL decal;
  this->Puts(&decal,string,frame);
  decal.x2d=x;
  decal.y2d=y;
  decal.BltToSurface(surface,rect);
}

void SCENE::Remove(){
      int i;
      for (i=0;i<SCENE_MAX_OBJECTS;i++)
        if (object[i]) delete object[i];
      for (i=0;i<SCENE_MAX_CAMERAS;i++)
        if (camera[i]) delete camera[i];
      for (i=0;i<SCENE_MAX_LIGHTS;i++)
        if (light[i]) delete light[i];
      zero_pointers();
}

void OBJECT::Cleanup(){
  char *pres=new char[vertexcount];
  memset (pres,0,vertexcount);

  int i,j,k;

  for (j=0;j<planecount;j++){
    pres[plane[j].vindex[0]]=1;
    pres[plane[j].vindex[1]]=1;
    pres[plane[j].vindex[2]]=1;
  }

  for (i=0;i<vertexcount;i++){
    if (pres[i]){
      for (j=i+1;j<vertexcount;j++){
        if (abs(vertex[i].x-vertex[j].x)<1L<<16&&
            abs(vertex[i].y-vertex[j].y)<1L<<16&&
            abs(vertex[i].z-vertex[j].z)<1L<<16){
          for (k=0;k<planecount;k++){
            if (plane[k].vindex[0]==j) plane[k].vindex[0]=i;
            if (plane[k].vindex[1]==j) plane[k].vindex[1]=i;
            if (plane[k].vindex[2]==j) plane[k].vindex[2]=i;
          }
          pres[j]=0;
        }
      }
    }
  }
/*  delete pres;
  pres=new char[planecount];
  memset (pres,1,planecount);

  for (i=0;i<planecount-1;i++){
    if (pres[i])
    for (j=i+1;j<planecount;j++){
      if (
          ( plane[i].vindex[0]==plane[j].vindex[0]&&
            plane[i].vindex[1]==plane[j].vindex[1]&&
            plane[i].vindex[2]==plane[j].vindex[2])||

          ( plane[i].vindex[0]==plane[j].vindex[0]&&
            plane[i].vindex[1]==plane[j].vindex[1]&&
            plane[i].vindex[2]==plane[j].vindex[2])||

          ( plane[i].vindex[0]==plane[j].vindex[2]&&
            plane[i].vindex[1]==plane[j].vindex[0]&&
            plane[i].vindex[2]==plane[j].vindex[1])){

        pres[j]=0;
      }
    }
  }

  i=0;
  while (1){
    if (i>=planecount-1) break;
    if (!pres[i]){
      for (j=i;j<planecount-1;j++){
        plane[j]=plane[j+1];
        pres[j]=pres[j+1];
      }
      planecount--;
      if (i>=planecount-1) break;
    }
    else i++;
  }

  delete pres;*/
}

void TEXTURE_Z::Create(long w,long h){
  if (w>512||h>512) return;
  if (!(data=new COLOR[512*512])) return;
  this->w=w;
  this->h=h;
  memset(data,0,512*512*sizeof(COLOR));
}

long TEXTURE_Z::SetPixel(long x,long y,COLOR c){
  long ix,iy=y;
  long put=0;
  while (iy<512){
    ix=x;
    COLOR *dat=&data[((iy<<9)+ix)];
    while (ix<512){
      *dat=c;
      put++;
      ix+=w;
      dat+=w;
    }
    iy+=h;
  }
  return put;
}

COLOR TEXTURE_Z::GetPixel(long x,long y){
  return *(COLOR *)(&data[((y<<9)+x)]);
}
 
VECTOR  VECTOR::operator*(long m){
  return VECTOR(x*m,y*m,z*m);
};
VECTOR  VECTOR::operator+(VECTOR &vx){
  return VECTOR(x+vx.x,y+vx.y,z+vx.z);
};
VECTOR& VECTOR::operator+=(VECTOR &vx){
  *this=*this+vx;
  return *this;
}

void    CAMERA::Create(LPDIRECTDRAWSURFACE7 surface,RECT *cliprect){
  rect=*cliprect;
  this->surface=surface;
  width=rect.right-rect.left;
  height=rect.bottom-rect.top;
  zbuffer=new long[width*height];
}

void    CAMERA::InitAndLock(){
  memset(zbuffer,0,width*height*sizeof(long));

	DDSURFACEDESC2 ddsd;
  ZeroMemory(&ddsd,sizeof(ddsd));
  ddsd.dwSize=sizeof(ddsd);
  this->data=NULL;
  if (SUCCEEDED(this->surface->Lock(&rect,&ddsd,DDLOCK_NOSYSLOCK|DDLOCK_WAIT,NULL))){
	  this->pitch = ddsd.lPitch;
    this->data = ddsd.lpSurface;
  }
  else
    return;

  if (this->fog==FOG_WATER||this->fog==FOG_FOG){
    uint strt=this->ax;
    uchar *dat=(uchar *)data;
    uint dstrt=(3L<<4)*DEMO_FIXED_HEIGHT/DEMO_BB_HEIGHT;
    if (dusk>60000) dusk=60000;
    for (int y=rect.top;y<rect.bottom;y++){
      uint val;

      if (this->fog==FOG_FOG) {
        if (strt!=0)
          val=fogx_fog_hi*(48L<<8)/strt;
        else
          val=fogx_fog_hi;
        if (val>fogx_fog_hi) val=fogx_fog_hi;
        val+=fogx_fog_lo;
        val*=dusk;
        val>>=16;
      }else{
        if (strt!=0)
          val=fogx_water_hi*(48L<<8)/strt;
        else
          val=fogx_water_hi;
        if (val>fogx_water_hi) val=fogx_water_hi;
        val+=fogx_water_lo;
      }
      
      uchar *datx=dat;
      if (this->fog==FOG_WATER){
        for (int x=rect.left;x<rect.right;x++){
          *datx=val;
          *(datx+1)=val;
          *(datx+2)=0;
          datx+=bpp==24?3:4;
        }
      }
      else{
        for (int x=rect.left;x<rect.right;x++){
          *datx=val;
          *(datx+1)=val;
          *(datx+2)=val;
          datx+=bpp==24?3:4;
        }
      }
      strt+=dstrt;
      dat+=this->pitch;
    }
  }
}

void    CAMERA::Unlock(){
  if (!data) return;
  surface->Unlock(&rect);
}

void CAMERA::Clear(COLOR color){

  DDSurfaceClear(color.color,surface,&rect);
}

void DECAL::Create(uint w,uint h,uint framecount){
  if (frame){
    for (uint i=0;i<this->framecount;i++){
      delete frame[i];
    }
    delete frame;
  }
  this->framecount=framecount;
  this->w=w;
  this->h=h;
  frame=new COLOR*[framecount];
  for (uint i=0;i<framecount;i++){
    frame[i]=new COLOR[w*h];
  }
  Clear();
}

COLOR *DECAL::GetFrame(uint frame_index){
  frame_index/=framedelay;
  return frame[frame_index%framecount];
}
int DECAL::isEnd(uint frame_index){
  frame_index/=framedelay;
  return frame_index>=framecount;
}
void DECAL::Clear(){
  for (int i=0;i<framecount;i++){
    memset(this->frame[i],0,this->w*this->h*sizeof(COLOR));
  } 
}

int DECAL_SPAWNER::Spawn(int x,int y,int z){
  for (uint i=0;i<spawncount;i++){
    if (!present[i]){
      spawnpoint[i].x=x;
      spawnpoint[i].y=y;
      spawnpoint[i].z=z;
      present[i]=1;
      current_frame[i]=0;
      return i;
    }
  }
  return 0;
}
int DECAL_SPAWNER::Spawn(CSYSTEM *source,VECTOR point){
  CAMERA dummy;
  point.to_camera(source,&dummy,1,1);
  return Spawn(point.xworld,point.yworld,point.zworld);
}

void DECAL_SPAWNER::Play(){
  for (uint i=0;i<spawncount;i++)
    current_frame[i]++;
}

void DECAL_SPAWNER::Modulo(){
  for (uint i=0;i<spawncount;i++)
    current_frame[i]%=decal->framecount;
}
        
DECAL_SPAWNER::DECAL_SPAWNER(){
  spawnpoint=NULL;
  current_frame=NULL;
  present=NULL;
  spawncount=0;
  killonend=1;
  current_frame=0;
  standard_render=0;
}

void DECAL_SPAWNER::Create(uint spawncount){
  this->spawncount=spawncount;
  spawnpoint=new VERTEX[spawncount];
  present=new int[spawncount];
  current_frame=new uint[spawncount];
  ZeroMemory(present,spawncount*sizeof(int));
}
DECAL_SPAWNER::~DECAL_SPAWNER(){
  delete spawnpoint;
  delete current_frame;
  delete present;
}

void BUBBLE_SPAWNER::Create(uint spawncount){
  DECAL_SPAWNER::Create(spawncount);
  vel=new VECTOR[spawncount];
  acc=new VECTOR[spawncount];
}

int BUBBLE_SPAWNER::Spawn(){
  if (!visible) return 0;
  long xx,yy,zz;
  xx=(rand()-RAND_MAX/2)<<4;
  yy=0;
  zz=(rand()-RAND_MAX/2)<<4;
  int index=DECAL_SPAWNER::Spawn(xx,yy,zz);
  vel[index].x=0;
  vel[index].y=1L<<15;
  vel[index].z=0;

  acc[index].x=0;
  acc[index].y=1L<<14;
  acc[index].z=0;

  return index;
}

void BUBBLE_SPAWNER::Play(){
  if (!visible) return;
  for (uint i=0;i<spawncount;i++){
    if (present[i]){
      spawnpoint[i]+=vel[i];
      spawnpoint[i].x+=(rand()-RAND_MAX/2)<<5;
      spawnpoint[i].z+=(rand()-RAND_MAX/2)<<5;
      vel[i]+=acc[i];
      if (spawnpoint[i].y>end_y) present[i]=0;
    }
  }
}

FONT::FONT(){for (int i=0;i<256;i++) symbol[i]=NULL;}
FONT::~FONT(){for (int i=0;i<256;i++) delete symbol[i];}

COLOR *TEXTURE_Z::GetDataPtr(){
  return data;
}