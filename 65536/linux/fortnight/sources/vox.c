


static void hajo_x(unsigned char *b, int p, int xs, int ys) {
  int x, y;
  unsigned char *b2=malloc(xs*ys>>1);
  for (y=0; y<ys; y++) for (x=0; x+x+1<xs; x++) {
    unsigned char *d=b+y*p+x*2;
    b2[y*(xs>>1)+x]=d[0]+d[1]>>1;
  }
  if (xs>3) hajo_x(b2, xs>>1, xs>>1, ys);  
  for (y=0; y<ys; y++) for (x=0; x+x+1<xs; x++) {
    unsigned char *d=b+y*p+x*2;
    unsigned char s=b2[y*(xs>>1)+x];
    int a=d[0], b=d[1];
    d[0]=a;
    d[1]=s;
  }  
  free(b2);
}

typedef struct {
  float xk, yk, zk, d;
  float a2, b2, c2, d2;
  int a3, b3, c3, d3;
//  float xi, yi, zi, di;
  float map[256];
} Tso;

int gounter;



static inline float tsox_gv(Tso *t, int lkm, float x, float y, float z) { 
  float v=0, vv, a; int i;
  unsigned ia;
  for (i=0; i<lkm; i++, t++) { 
    a=(x*t->xk+y*t->yk+t->zk)*z+t->d; 
    ia=lrint(a*256)*65536; 
    vv=t->map[ia>>24];
    v+=vv+(t->map[ia+16777216>>24]-vv)*(1/16777216.)*(ia&16777215);
  }  
  return v;
}

static inline float tsox_gv2(Tso *t, int lkm, int x, int y, int z) { 
  float v=0, vv, a; int i;
  unsigned ia;
  for (i=0; i<lkm; i++, t++) { 
    ia=(x*t->a3+y*t->b3+t->c3)*z+t->d3; 
    vv=t->map[ia>>24];
    v+=vv+(t->map[ia+16777216>>24]-vv)*(1/16777216.)*(ia&16777215);
  }  
  if (v<-1) v=-1;
  if (v>1) v=1;
  return v;
}

static inline float tsox_grad(Tso *t, int lkm, float x, float y, float z, float xd, float yd, float zd) {
  float a; int i;
  unsigned ia;
  float xg=0, yg=0, zg=0;
  for (i=0; i<lkm; i++, t++) { 
    a=(x*t->xk+y*t->yk+t->zk)*z+t->d; 
    ia=lrint(a*256)*65536; 
    xg+=(t->map[ia+16777216>>24]-t->map[ia>>24])*t->xk;
    yg+=(t->map[ia+16777216>>24]-t->map[ia>>24])*t->yk;
    zg+=(t->map[ia+16777216>>24]-t->map[ia>>24])*t->zk;
  }  
  return (xg*xd+yg*yd+zg*zd)/sqrt(xg*xg+yg*yg+zg*zg);
}



/*
a  b  c  d  e  f  g  h
ab bc cd de ef fg gh ha
a-e   c-g   e-a   g-c  
*/

#define xper 1.6
#define yper 1.2


static void rend(char *buf, int pit, int xs, int ys, Tso *t, int cnt) {
  Tso *tt;
  int x, y, zz, xx, yy, c, i, zf;
  float xf, yf, v, z0, z1, z;
  float xk=xper/(float)xs;
  float yk=yper/(float)ys;
  static struct {
    float xg, yg, zg;
    int z;
  } puf[4096], *pp;
  static struct {
    int min, max;
    float minv, maxv;
    float v;
  } vbuf[4000], *vp;
  for (tt=t; tt<t+cnt; tt++) {
    tt->a2=tt->xk*xk, tt->b2=tt->yk*yk, tt->c2=tt->zk-.5*(xs*tt->a2+ys*tt->b2), tt->d2=tt->d;
    tt->a3=tt->a2*16777216; tt->b3=tt->b2*16777216; tt->c3=tt->c2*16777216; tt->d3=tt->d2*16777216;
  }
  for (vp=vbuf, yy=0; yy<=ys>>5; yy++) for (xx=0; xx<=xs>>5; xx++, vp++) {
    vp->min=1; vp->max=8192;
    for (vp->max=32; vp->max<8192; vp->max+=32+(vp->max>>2)) {
      vp->maxv=tsox_gv2(t, cnt, xx*32, yy*32, vp->max);
      if (vp->maxv>0) break; else vp->min=vp->max, vp->minv=vp->maxv;
    }
    if (vp->max>=8192) vp->maxv=0;
    if (vp->minv>vp->maxv) return;
    if (vp->minv>0) return;//vp->minv=0;
  }
  for (vp=vbuf, yy=0; yy<=ys>>5; yy++, vp++) for (xx=0; xx<xs>>5; xx++, vp++) {
//    vp->v=vp->maxv-vp->minv;
    if (vp[1].min<vp[0].min) vp[0].min=vp[1].min;
    if (vp[1].max>vp[0].max) vp[0].max=vp[1].max;
    if (vp[1].minv<vp[0].minv) vp[0].minv=vp[1].minv;
    if (vp[1].maxv>vp[0].maxv) vp[0].maxv=vp[1].maxv;
  }
  for (vp=vbuf, yy=0; yy<ys>>5; yy++, vp++) for (xx=0; xx<xs>>5; xx++, vp++) {
    if (vp[xs+32>>5].min<vp[0].min) vp[0].min=vp[xs+32>>5].min;
    if (vp[xs+32>>5].max>vp[0].max) vp[0].max=vp[xs+32>>5].max;
    if (vp[xs+32>>5].minv<vp[0].minv) vp[0].minv=vp[xs+32>>5].minv;
    if (vp[xs+32>>5].maxv>vp[0].maxv) vp[0].maxv=vp[xs+32>>5].maxv;
  }
  for (yy=0; yy<ys>>5; yy++) for (xx=0; xx<xs>>5; xx++) {
    vp=vbuf+yy*(xs+32>>5)+xx;
    v=(vp->max-vp->min)/(vp->maxv-vp->minv);
    for (i=0; i<8*8; i++) puf[i].z=(vp->min+vp->max)*.5;
    pp=puf;
    for (i=0; i<1; i++) for (y=0; y<8; y++) {
      for (x=0; x<8; x++) {
        pp->z-=tsox_gv2(t, cnt, xx*32+x*4, yy*32+y*4, pp->z)*v; pp++;
      }
    }
    for (i=0; i<8*8; i++) puf[i].xg=puf[i].yg=puf[i].zg=0;
    for (tt=t; tt<t+cnt; tt++) { 
      float d;
      int v, vxi, vyi; 
      unsigned ia;
      pp=puf;
      v=xx*32*tt->a3+yy*32*tt->b3+tt->c3;
      vxi=tt->a3*4; vyi=tt->b3*4-32*tt->a3;
      for (y=0; y<8; y++) {
        for (x=0; x<8; x++) {
          ia=v*pp->z+tt->d2; d=tt->map[ia+16777216>>24]-tt->map[ia>>24]; pp->xg+=d*tt->xk; pp->yg+=d*tt->yk; pp->zg+=d*tt->zk; v+=vxi; pp++;
        }
        v+=vyi;
      }
    }
    pp=puf;
    for (y=0; y<8; y++) for (x=0; x<8; x++) {
      c=lrint(fabs(pp->zg/sqrt(pp->xg*pp->xg+pp->yg*pp->yg+pp->zg*pp->zg))*127*32*64/pp->z); pp->z=c<0?0:c>127?127:c; pp++;
    }
    for (y=31; y>=0; y--) for (x=31; x>=0; x--) puf[y*32+x]=puf[(y>>2)*8+(x>>2)];
    pp=puf;
    i=yy*32*pit+xx*32;
    for (y=0; y<32; y++) {
      for (x=0; x<32; x++) buf[i++]=pp++->z;
      i+=pit-32;
    }
  }
}












/*
 (x*A+y*B+C)*z+D
 D_RADIX=24
 Z_RADIX=12
 A_RADIX=12
 B_RADIX=12
 C_RADIX=12
*/
