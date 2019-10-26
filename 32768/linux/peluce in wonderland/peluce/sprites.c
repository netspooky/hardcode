#include <stdio.h>
#include <stdlib.h>

#include "pwpdemo.h"

typedef struct
{
   int width,height;
   u8*pict;
   u8*mask;
}sprite;

#include "sprites.h"

/*
void rotozoom(int x0,int y0,
              char*map,int dim,int angle,int zoom)
{
  int du,dv,u,v,x,y,xdim,ydim;
  char*d=pwplib.videobuf.d;

  {int xp0,yp0;
  dim=(dim*zoom)>>8;

  if(x0+dim>pwplib.videobuf.width)
    xdim=pwplib.videobuf.width-x0;else xdim=dim;

  if(y0+dim>pwplib.videobuf.height)
    ydim=pwplib.videobuf.height-y0;else ydim=dim;

  if(x0<0){xdim+=x0;xp0=-dim-x0; x0=0;}else xp0=-dim;
  if(y0<0){ydim+=y0;yp0=-dim-y0; y0=0;}else yp0=-dim;

  if(xdim<=0 || ydim<=0)return;

  du=sin(angle/256.0)*zoom;
  dv=cos(angle/256.0)*zoom;

  u=-du*xp0-dv*yp0;
  v=-dv*xp0+du*yp0;
  }

  {int duo=-dv-du*xdim,
       dvo= du-dv*xdim,
       mod=pwplib.videobuf.width-xdim;

   d+=ydim*pwplib.videobuf.width+xdim;

  for(y=ydim;y;y--)
  {
     for(x=xdim;x;x--)
     {
        int ptr=(u&~0xff)+(v>>8);

        *d=(*d&map[ptr])|map[ptr+128];
        d++;
        u+=du;
        v+=dv;
     }
     
     u+=duo;
     v+=dvo;
     d+=mod;
  }
  }
}
*/

void zoomsprite(int x0,int y0,sprite*sp,int xzoom,int yzoom)
{
   int xdim,ydim,
       xo0=0,yo0=0,x,y,ptr;

   if(xzoom<=32 && yzoom<=32)return;
   
   xdim=(sp->width<<8)/xzoom;
   ydim=(sp->height<<8)/yzoom;

   x0-=(xdim>>1);
   y0-=(ydim>>1);

   if(x0<0)
   {
      xdim+=x0;
      xo0=(0-x0)<<8;
      x0=0;
   }

   if(y0<0)
   {
      ydim+=y0;
      yo0=(0-y0)<<8;
      y0=0;
   }

   if(x0+xdim>=pwplib.videobuf.width)
   {
      xdim=pwplib.videobuf.width-x0;
   }

   if(y0+ydim>=pwplib.videobuf.height)
   {
      ydim=pwplib.videobuf.height-y0;
   }
   
   if(xdim<=0 || ydim<=0) return;
   
   {u8*d=pwplib.videobuf.d+x0+y0*pwplib.videobuf.width;

   for(y=0;y<ydim;y++)
   {
      int linebase=(yo0>>8)*sp->width;
      int xo=xo0;

      {u8*dd=d;
      for(x=xdim;x;x--)
      {
         int a=*dd,z=linebase+(xo>>8);
         *dd=(a&sp->mask[z])|sp->pict[z];
         xo+=xzoom;
         dd++;
      }}
      yo0+=yzoom;
      d+=pwplib.videobuf.width;
   }}
}

void zoomsprite_gen(int x0,int y0,sprite*sp,int zoom)
{
   zoomsprite(((x0+128)*pwplib.videobuf.width)>>8,
              ((y0+128)*pwplib.videobuf.height)>>8,
              sp,
              abs((zoom<<8)/pwplib.videobuf.width),
              abs((zoom<<7)/pwplib.videobuf.height)
             );
}

void metsae(int t,int mode)
{
   int i,x;

  const sprite*mo[]={&kuusi};
  const int mosiz[]={128};
  const int mostep[]={64};

  for(i=0;i<512;i+=mostep[mode])
  {
   zoomsprite_gen(
     ((i-t/3)&511)-256 ,0,mo[mode],mosiz[mode]);
  }
}

void drawkiller(int tminus)
{
   int ttt=tminus;

   if(tminus<-64)tminus=-64;else
   if(tminus>0)tminus=0;

   zoomsprite_gen(tminus,48,(ttt&16)?&pelustna0:&pelustna1,80);
}

void encounter(int tminus,int kode,int zoom,int speed)
{
   int ttt=tminus;
   sprite*pum[][2]=
   {
      &krist0,&krist1,
      &pelusieni,&pelusieni,
      &pelusieni1,&pelusieni1,
      &pelusieni2,&pelusieni2,
      &pelux,&pelux,
      &pelustna0,&pelustna1,
      &ruumis,&ruumis,
      &uusmed0,&uusmed1,
      &tesno0,&tesno1,
      &army0,&army0,
      &windows0,&windows1,
      &quake0,&quake0      
   };

   if(ttt<0)ttt=0;

   zoomsprite_gen(0+ttt,48,(tminus&16)?pum[kode][0]:pum[kode][1],zoom);
}

void pelubounce(int t,int bouncemode)
{
   const unsigned char bfunc[32]={
       32,32,32,36,38,40,42,44,50,60,61,62,62,63,63,63,
       63,63,63,62,61,60,50,40,32,33,34,35,34,33,32,32
   };
   const sprite*poo[3]={&peluface0,&peluface1,&peluface2};
   
   zoomsprite_gen(0,0,bouncemode?&sieni:poo[(t>>6)%3],40+((t-2560)&63));
}

void blaah(int t)
{
   int x0=0,
       y0=0,
       z0=300+(sin(t/70.8)*300);

   zoomsprite_gen(x0,y0,(t&16)?&krist0:&krist1,z0);
}


/*****************************/

/*
        for(y=0;y<hg;y++)
        {
	     register int dofz=(hg*64)/(y+3),ofz=t*32-dofz*20-((dofz>>4)*32*256);
             {int x=pwplib.videobuf.width;for(;x;x--)*d++=texture1[((ofz+=dofz)>>8)&1023];}
	     k-=(k>>3);
	}
}

*/
