#include "RayTracer.h"
#include "Primitive.h"
#include "Bitmap.h"
#include "Camera.h"

// Varoitus, alhaalla on kamalaa koodia, koska se on optimoitu nopeudelle...
// Enkä osaa edes hyvin optimoida... :(

extern Ray globalray;

#define prepareColorInterpolation(s) \
int rsa=(r3->mulr - r1->mulr) * (256/s), gsa=(r3->mulg - r1->mulg) * (256/s), \
    bsa=(r3->mulb - r1->mulb) * (256/s), rea=(r4->mulr - r2->mulr) * (256/s), \
    gea=(r4->mulg - r2->mulg) * (256/s), bea=(r4->mulb - r2->mulb) * (256/s); \
int rs=r1->mulr*256, gs=r1->mulg*256, bs=r1->mulb*256, \
    re=r2->mulr*256, ge=r2->mulg*256, be=r2->mulb*256;

#define prepareColorInterpolation2(s) \
int rsa2=(r3->addr - r1->addr) * (256/s), gsa2=(r3->addg - r1->addg) * (256/s), \
    bsa2=(r3->addb - r1->addb) * (256/s), rea2=(r4->addr - r2->addr) * (256/s), \
    gea2=(r4->addg - r2->addg) * (256/s), bea2=(r4->addb - r2->addb) * (256/s); \
int rs2=r1->addr*256, gs2=r1->addg*256, bs2=r1->addb*256, \
    re2=r2->addr*256, ge2=r2->addg*256, be2=r2->addb*256;

#define prepareTextureInterpolation(s) \
int u1a=(r3->u-r1->u)*(65536/s), v1a=(r3->v-r1->v)*(65536/s), \
    u2a=(r4->u-r2->u)*(65536/s), v2a=(r4->v-r2->v)*(65536/s); \
int u1=r1->u*65536, v1=r1->v*65536, u2=r2->u*65536, v2=r2->v*65536; \
int *texture=r1->texture->data[0];

void RayTracer::renderQuad4(int x,int y)
{
  RTResult *r1 = tracePoint(x,y);
  RTResult *r2 = tracePoint(x+4,y);
  RTResult *r3 = tracePoint(x,y+4);
  RTResult *r4 = tracePoint(x+4,y+4);

  if((!((r1->hid==r2->hid) && (r2->hid==r3->hid) && (r3->hid==r4->hid))) || r1->divide || r2->divide || r3->divide || r4->divide)
  {
    renderQuad2(x,y);
    renderQuad2(x+2,y);
    renderQuad2(x,y+2);
    renderQuad2(x+2,y+2);
  } else {
/*
    int c1 = r1->mulr + r1->mulg + r1->mulb;
    int c2 = r2->mulr + r2->mulg + r2->mulb;
    int c3 = r3->mulr + r3->mulg + r3->mulb;
    int c4 = r4->mulr + r4->mulg + r4->mulb;
    int ka = (c1+c2+c3+c4) >> 2;
    int ka1 = ka-32;
    int ka2 = ka+32;
    if(c1 < ka1 || c1 > ka2 || c2 < ka1 || c2 > ka2 || c3 < ka1 || c3 > ka2 || c4 < ka1 || c4 > ka2)
    {
      renderQuad2(x,y);
      renderQuad2(x+2,y);
      renderQuad2(x,y+2);
      renderQuad2(x+2,y+2);
      return;
    }
*/
    int *d=&dest->data[y][x-1];
    int wii=dest->width-4;
    int xx,yy,drawer = r1->quaddrawer|r2->quaddrawer|r3->quaddrawer|r4->quaddrawer;

    switch(drawer) {
      case QUADDRAWER_FLAT: {
        int c = (r1->mulr<<16) + (r1->mulg<<8) + r1->mulb;
        for(yy=0;yy<4;yy++) {
          for(xx=0;xx<4;xx++) {
            *(++d)=c;
          }
          d+=wii;
        }
      } break;

      case QUADDRAWER_GOURAUD: {
        prepareColorInterpolation(4);

        for(yy=0;yy<4;yy++) {
          int rx=rs,  gx=gs,  bx=bs;
          int rxa=(re-rs)*(256/4)>>8,  gxa=(ge-gs)*(256/4)>>8,  bxa=(be-bs)*(256/4)>>8;

          for(xx=0;xx<4;xx++) {
            *(++d)=((rx<<8)&0xFF0000) + (gx&0xFF00) + (bx>>8);
            rx+=rxa; gx+=gxa; bx+=bxa;
          }

          d+=wii;
          rs+=rsa; gs+=gsa; bs+=bsa; re+=rea; ge+=gea; be+=bea;
        }
      }
      break;

      case QUADDRAWER_TEXTURE|QUADDRAWER_GOURAUD: {
        prepareColorInterpolation(4);
        prepareTextureInterpolation(4);

        for(yy=0;yy<4;yy++) {
          int rx=rs,  gx=gs,  bx=bs;
          int rxa=(re-rs)*(256/4)>>8,  gxa=(ge-gs)*(256/4)>>8,  bxa=(be-bs)*(256/4)>>8;

          unsigned int ux=u1*256, vx=v1*256;
          int uax=(u2-u1)*(256/4), vax=(v2-v1)*(256/4);
          for(xx=0;xx<4;xx++) {
            register int tex=texture[((vx>>16)&0xff00) + (ux>>24)];
            ux+=uax;
            vx+=vax;
            *(++d)=((tex>>16)*rx&0xFF0000) + (((tex>>8)&0xFF)*gx>>8&0xFF00) + ((tex&0xFF)*bx>>16);
            rx+=rxa; gx+=gxa; bx+=bxa;
          }

          d+=wii;
          u1+=u1a; v1+=v1a; u2+=u2a; v2+=v2a;
          rs+=rsa; gs+=gsa; bs+=bsa; re+=rea; ge+=gea; be+=bea;
        }
      }
      break;
/*
      case QUADDRAWER_TEXTURE|QUADDRAWER_PHONG:
      case QUADDRAWER_TEXTURE|QUADDRAWER_PHONG|QUADDRAWER_GOURAUD: {
        prepareColorInterpolation(4);
        prepareColorInterpolation2(4);
        prepareTextureInterpolation(4);

        for(yy=0;yy<4;yy++) {
          int rx=rs,  gx=gs,  bx=bs;
          int rxa=(re-rs)*(256/4)>>8,  gxa=(ge-gs)*(256/4)>>8,  bxa=(be-bs)*(256/4)>>8;

          int rx2=rs2,  gx2=gs,  bx2=bs2;
          int rxa2=(re2-rs2)*(256/4)>>8,  gxa2=(ge2-gs2)*(256/4)>>8,  bxa2=(be2-bs2)*(256/4)>>8;

          unsigned int ux=u1*256, vx=v1*256;
          int uax=(u2-u1)*(256/4), vax=(v2-v1)*(256/4);
          for(xx=0;xx<4;xx++) {
            register int tex=texture[((vx>>16)&0xff00) + (ux>>24)];
            ux+=uax;
            vx+=vax;

            register int r = ((tex>>16)*rx&0xFF0000) + (rx2<<8);
            register int g = (((tex>>8)&0xFF)*gx>>8&0xFF00) + (gx2);
            register int b = ((tex&0xFF)*bx>>16) + (bx2 >> 8);
            if(r>0xFF0000) r=0xFF0000;
            if(g>0xFF00) g=0xFF00;
            if(b>0xFF) b=0xFF;
            *(++d)=(r&0xFF0000) + (g&0xFF00) + b;
            //*(++d)=0xFFFFFF;

            rx+=rxa; gx+=gxa; bx+=bxa;
            rx2+=rxa2; gx2+=gxa2; bx2+=bxa2;
          }

          d+=wii;
          u1+=u1a; v1+=v1a; u2+=u2a; v2+=v2a;
          rs+=rsa; gs+=gsa; bs+=bsa; re+=rea; ge+=gea; be+=bea;
          rs2+=rsa2; gs2+=gsa2; bs2+=bsa2; re2+=rea2; ge2+=gea2; be2+=bea2;
        }
      }
      break;
*/
      case QUADDRAWER_TEXTURE: {
        int r=r1->mulr,g=r1->mulg,b=r1->mulb;
        prepareTextureInterpolation(4);

        for(yy=0;yy<4;yy++) {
          unsigned int ux=u1*256, vx=v1*256;
          int uax=(u2-u1)*(256/4), vax=(v2-v1)*(256/4);
          for(xx=0;xx<4;xx++) {
            register int tex=texture[((vx>>16)&0xff00) + (ux>>24)];
            ux+=uax;
            vx+=vax;
            *(++d)=(((tex>>16)*r<<8)&0xFF0000) + (((tex>>8)&0xFF)*g&0xFF00) + ((tex&0xFF)*b>>8);
          }

          d+=wii;
          u1+=u1a; v1+=v1a; u2+=u2a; v2+=v2a;
        }
      }
      break;
    }
  }
}

void RayTracer::renderQuad2(int x,int y)
{
  RTResult *r1 = tracePoint(x,y);
  RTResult *r2 = tracePoint(x+2,y);
  RTResult *r3 = tracePoint(x,y+2);
  RTResult *r4 = tracePoint(x+2,y+2);

  if(!((r1->hid==r2->hid) && (r2->hid==r3->hid) && (r3->hid==r4->hid)))
  {
    renderQuad1(x,y);
    renderQuad1(x+1,y);
    renderQuad1(x,y+1);
    renderQuad1(x+1,y+1);
  } else {

    switch(r1->quaddrawer|r2->quaddrawer|r3->quaddrawer|r4->quaddrawer) {
      case QUADDRAWER_FLAT: {   
        int c = (r1->mulr<<16) + (r1->mulg<<8) + r1->mulb;
        dest->data[y][x] = c;
        dest->data[y][x+1] = c;
        dest->data[y+1][x] = c;
        dest->data[y+1][x+1] = c;
      }
      break;

      case QUADDRAWER_GOURAUD: {
        int c1 = (r1->mulr<<16) + (r1->mulg<<8) + r1->mulb;
        int c2 = (r2->mulr<<16) + (r2->mulg<<8) + r2->mulb;
        int c3 = (r3->mulr<<16) + (r3->mulg<<8) + r3->mulb;
        int c4 = (r4->mulr<<16) + (r4->mulg<<8) + r4->mulb;

        dest->data[y][x] = c1;
        dest->data[y][x+1] = mix(c1,c2);
        dest->data[y+1][x] = mix(c1,c3);
        dest->data[y+1][x+1] = mix(mix(c1,c2),mix(c3,c4));
      }
      break;

/*
      case QUADDRAWER_TEXTURE|QUADDRAWER_GOURAUD|QUADDRAWER_PHONG:
      case QUADDRAWER_TEXTURE|QUADDRAWER_PHONG: {
        int t;
        t = r1->texture->data[r1->v&255][r1->u&255];
        int c1 = (((t>>16)*r1->mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r1->mulg&0xFF00) + ((t&0xFF)*r1->mulb>>8);
        t = r1->texture->data[r2->v&255][r2->u&255];
        int c2 = (((t>>16)*r2->mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r2->mulg&0xFF00) + ((t&0xFF)*r2->mulb>>8);
        t = r1->texture->data[r4->v&255][r3->u&255];
        int c3 = (((t>>16)*r3->mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r3->mulg&0xFF00) + ((t&0xFF)*r3->mulb>>8);
        t = r1->texture->data[r4->v&255][r4->u&255];
        int c4 = (((t>>16)*r4->mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r4->mulg&0xFF00) + ((t&0xFF)*r4->mulb>>8);

        dest->data[y][x] = c1;
        dest->data[y][x+1] = mix(c1,c2);
        dest->data[y+1][x] = mix(c1,c3);
        dest->data[y+1][x+1] = mix(mix(c1,c2),mix(c3,c4));
      }
*/

      case QUADDRAWER_TEXTURE: // Feikkiii!
      case QUADDRAWER_TEXTURE|QUADDRAWER_GOURAUD: {
        int t;
        t = r1->texture->data[r1->v&255][r1->u&255];
        int c1 = (((t>>16)*r1->mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r1->mulg&0xFF00) + ((t&0xFF)*r1->mulb>>8);
        t = r1->texture->data[r2->v&255][r2->u&255];
        int c2 = (((t>>16)*r2->mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r2->mulg&0xFF00) + ((t&0xFF)*r2->mulb>>8);
        t = r1->texture->data[r4->v&255][r3->u&255];
        int c3 = (((t>>16)*r3->mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r3->mulg&0xFF00) + ((t&0xFF)*r3->mulb>>8);
        t = r1->texture->data[r4->v&255][r4->u&255];
        int c4 = (((t>>16)*r4->mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r4->mulg&0xFF00) + ((t&0xFF)*r4->mulb>>8);

        dest->data[y][x] = c1;
        dest->data[y][x+1] = mix(c1,c2);
        dest->data[y+1][x] = mix(c1,c3);
        dest->data[y+1][x+1] = mix(mix(c1,c2),mix(c3,c4));
      }
      break;
    }
  }
}

RTResult r2;

void RayTracer::renderQuad1(int x,int y)
{
  RTResult *r = tracePoint(x,y);

  int c1;
  switch(r->quaddrawer) {
    default: case QUADDRAWER_GOURAUD: case QUADDRAWER_FLAT:
      c1 = (r->mulr<<16) + (r->mulg<<8) + r->mulb;
      break;
    case QUADDRAWER_TEXTURE: case QUADDRAWER_TEXTURE|QUADDRAWER_GOURAUD: {
      int t = r->texture->data[r->v&255][r->u&255];
      c1 = (((t>>16)*r->mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r->mulg&0xFF00) + ((t&0xFF)*r->mulb>>8);
    }
    break;
  }

#ifdef ANTIALIAS

  int c2;

  vectorMultipleMatrix(globalray.dir,camera->cameramatrix,rays2[y][x]);
  traceFirstHit(&r2,&objectareas[y>>4][x>>4]);

  switch(r2.quaddrawer) {
    default: case QUADDRAWER_GOURAUD: case QUADDRAWER_FLAT:
      c2 = (r2.mulr<<16) + (r2.mulg<<8) + r2.mulb;
      break;
    case QUADDRAWER_TEXTURE: case QUADDRAWER_TEXTURE|QUADDRAWER_GOURAUD: {
      int t = r2.texture->data[r2.v&255][r2.u&255];
      c2 = (((t>>16)*r2.mulr<<8)&0xFF0000) + (((t>>8)&0xFF)*r2.mulg&0xFF00) + ((t&0xFF)*r2.mulb>>8);
    }
    break;
  }

  dest->data[y][x] = mix(c1,c2);

#else

  dest->data[y][x] = c1;

#endif
}
