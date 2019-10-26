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

#include "font.h"

#define INLINE
  /* to pwplib.h -- #define INLINE inline */

INLINE void zoomsprite_loop
  (mask, pict, xzoom, d, xo0, xdim, ydim, spwidth, yzoom, yo0, col)
register u8* mask, *pict;
register int xzoom, col;
u8* d;
int xo0, xdim, ydim, spwidth, yzoom, yo0;
{
   register u8 *dd, *m, *p;
   register int xo, x;

   for(;ydim;ydim--)
   {
      int linebase = (yo0>>8) * spwidth;
      
      m  = mask + linebase;
      p  = pict + linebase;
      dd = d;
      xo = xo0;

      for(x=xdim;x;x--)
      {
         register int z=xo>>8;

         *dd++ = (*dd & m[z]) | (p[z]&col);

         xo += xzoom;
      }

      yo0 += yzoom;
      d   += pwplib_bufw;
   }
}

void zoomsprite(int x0,int y0,sprite*sp,int xzoom,int yzoom, int col)
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

   if(x0+xdim>=pwplib_bufw)
   {
      xdim=pwplib_bufw-x0;
   }

   if(y0+ydim>=pwplib_bufh)
   {
      ydim=pwplib_bufh-y0;
   }
   
   if(xdim<=0 || ydim<=0) return;

   zoomsprite_loop
   (
      sp->mask, sp->pict, xzoom,
      pwplib_buf+x0+y0*pwplib_bufw,
      xo0, xdim, ydim, sp->width, yzoom, yo0, col
   );
}
/*
  (mask, pict, xzoom, d, xo0, xdim, ydim, spwidth, yzoom, yo0)
*/

void zoomsprite_gen(int x0,int y0,sprite*sp,int zoom,int col)
{
   zoomsprite(((x0+128)*pwplib_bufw)>>8,
              ((y0+128)*pwplib_bufh)>>8,
              sp,
              abs((zoom<<8)/pwplib_bufw),
              abs((zoom<<7)/pwplib_bufh), col
             );
}

/*
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
*/


/******************/

char scale[3][8]={
   0x00,0x08,0x80,0x88,0x87,0x77,0xf7,0xff,
   0x00,0x08,0x07,0x80,0x88,0x87,0x77,0x7f,
   0x00,0x06,0x60,0x66,0x6e,0xe6,0xee,0xef
};

char bwpal[8][256];
void bwpals()
{
   int i,j;
   for(i=0;i<8;i++)
   {
      int gamma=rand()&3;
      int brite=256+(rand()&15)-(rand()&15);
      int scl=rand()%3;

      for(j=0;j<256;j++)
      {
         int it=((j&1)?1:0)+((j&2)?6:0)+((j&4)?3:0)+((j&8)?5:0)+
                 ((j&16)?3:0)+((j&32)?12:0)+((j&64)?8:0)+((j&128)?8:0);

         it+=gamma;
         it=(it*brite)>>8;
         if(it>63)it=63;

         it/=8;

	 bwpal[i][j]=scale[scl][it];
      }
   }
}

void naarmuta()
{
   int i=pwplib_bufh*pwplib_bufw;
   static int ph=0,rr=0,nrmx=0;
   
   char*d=pwplib_buf;
   char*lookup=&bwpal[rr&7][0];
   ph++;if(!(ph&3))rr=rand();

   for(i=100;i;i--)
   {
      int z=rand()%(pwplib_bufw*pwplib_bufh);
      pwplib_buf[z]^=0x87;
   }
   
   for(i=0;i<pwplib_bufh;i++){ 
     pwplib_buf[pwplib_bufw*i+nrmx]&=~0x78; if(!(rand()&7))nrmx+=(rand()&3)-1;
     if(nrmx<0 || nrmx>=pwplib_bufw) nrmx=rand()%pwplib_bufw;
   }

   i=pwplib_bufh*pwplib_bufw;
   for(;i;i--){*d=lookup[*d];d++;}
}

#define NUMZOOMS 4

struct zoomer_t
{
   sprite*sprite;

   int starttime;

   int startzoom;
   int zoomspeed;

   int fadespeed;

   int dynamic;
}
zoomer[NUMZOOMS];

void drawtext(sprite*textbuf,char*txt,int col);

void initzoomers()
{
   int i=0;
   for(;i<NUMZOOMS;i++) zoomer[i].sprite=NULL;
}

void alloczoomer(sprite*s,int starttime,int startzoom,
                 int zoomspeed,int fadespeed,int dynamic)
{
   if(zoomer[0].sprite!=NULL)
   {
      int i=NUMZOOMS-2;
      for(;i>=0;i--)
      memcpy(
        &zoomer[i+1],
        &zoomer[i],
          sizeof(struct zoomer_t));
   }
   
        zoomer[0].sprite=s;
        zoomer[0].starttime=starttime;
        zoomer[0].startzoom=startzoom;
        zoomer[0].zoomspeed=zoomspeed;
        zoomer[0].fadespeed=fadespeed;
        zoomer[0].dynamic=dynamic;
}

/*
   0x00 -> 0x01 -> 0x11 -> 0x13 -> 0x33 -> 0x37 -> 0x77 -> 0x7f -> 0xff
*/

void zoomer_free(int i)
{
   if(zoomer[i].dynamic)
   {
      free(zoomer[i].sprite->mask);
      free(zoomer[i].sprite->pict);
      free(zoomer[i].sprite);
   }
   zoomer[i].sprite=NULL;
}

void zoomer_do(int t)
{
   int i=NUMZOOMS-1,col=0x00;
   for(;i>=0;i--) if(zoomer[i].sprite!=NULL)
   {
      int killit=0;
      int passed = t-zoomer[i].starttime,
          zoomlevel = zoomer[i].startzoom+((zoomer[i].zoomspeed*passed)>>8),
          fadelevel = ((zoomer[i].fadespeed*passed)>>8);

      {
         static char orrers[] = {
           0x76,0xff,0xfe,0xea,
           0xae,0xac,0xaa,0xa9,
           0x9a,0x92,0x29,0x22,
           0x21,0x12,0x11,0x01 };

         if(fadelevel>=20) { killit++; } else col=orrers[fadelevel];
      }

      if(zoomlevel<64)zoomlevel=64;

      if(killit || zoomlevel>512)
      {
         zoomer_free(i);
      }
       else
   
      zoomsprite_gen(0,0,zoomer[i].sprite,zoomlevel,col);
   }
}

/*
void addtext(int m)
{
   if(textbuf.width)
   {
      zoomsprite_gen(0,0,&textbuf,m);
   }
}
*/

void pelubounce0(int t)
{
   sprite*c;
   
   {int u=(t>>3)&3;
    if(u==0)c=&pelush0;else
    if(u==1)c=&pelush1;else
    if(u==2)c=&pelush2;else
            c=&pelush1;}

   {int j=0;
   for(;j<256;j+=32)
   zoomsprite_gen(SIN(t+j)>>9,COS(t+j)>>9,c,112,0xff);
   }
}

void pelubounce1(int t)
{
   sprite*c;
   
   {int u=(t>>3)&3;
    if(u==0)c=&pelush0;else
    if(u==1)c=&pelush1;else
    if(u==2)c=&pelush2;else
            c=&pelush1;}

   {int axis0 = SIN(t/3),axis1=0; /* (48*COS(t/3))>>15; */
    int j=0;
   for(;j<256;j+=32)
   zoomsprite_gen(SIN(t+j)>>9,(axis0*(COS(t+j)>>9))>>15,c,
                  112+((axis1*SIN(t/3+j))>>15),0xff);
   }
}

//zoomsprite(int x0,int y0,sprite*sp,int xzoom,int yzoom, int col)

/*************************** boulderdash-related ***********************/

void bdash_do(u8*field,int xbase,int ybase,int zoom,int aniphase)
{
   static sprite*pix[][4] =
   {
      {&bdash0,&bdash1,&bdash2,&bdash1},
      {&pelush0,&pelush1,&pelush2,&pelush1},
      {&brick0,&brick0,&brick0,&brick0},
      {&brick1,&brick1,&brick1,&brick1},
      {&pelush0,&pelush1,&pelush2,&pelush1},
      {&pelush0,&pelush1,&pelush2,&pelush1},
      {&pelush0,&pelush1,&pelush2,&pelush1},
      {&pelush0,&pelush1,&pelush2,&pelush1},
      {&pelush0,&pelush1,&pelush2,&pelush1},
      {&pelush0,&pelush1,&pelush2,&pelush1},
      {&pelush0,&pelush1,&pelush2,&pelush1},
      {&boulder,&boulder,&boulder,&boulder},
      {&boulder,&boulder,&boulder,&boulder},  
      {&splat0,&splat0,&splat0,&splat0},
      {&splat1,&splat1,&splat1,&splat1},
      {&splat2,&splat2,&splat3,&splat3},
      {&splat4,&splat4,&splat4,&splat4},
      {&boulder,&boulder,&boulder,&boulder},
      {&bdash4,&bdash4,&bdash4,&bdash4},
      {&tietzka,&tietzka,&tietzka,&tietzka}
    };

   int x,y;
   /* 256 == normal size (16 objs per width) */
   zoom = (zoom*pwplib.videobuf.width)>>8;
   /* zoom == width of the whole stuph in pixels */

   aniphase&=3;

   for(y=0;y<16;y++)
   for(x=0;x<16;x++)
   {
      u8 f=*field++;

      if(f<128) {

      sprite*c=pix[f&31][aniphase];

      zoomsprite(pwplib.videobuf.width/2  + ((x*zoom-((xbase*zoom)>>8))>>4),
                 pwplib.videobuf.height/2 + ((y*zoom-((ybase*zoom)>>8))>>4),
                 c,65536/zoom,65536/zoom,0xff);

      /* 256*256 / zoom -- */
/*
      size=16: zoom=256, väli=16

      zoomsprite_gen(((x-xbase)*zoom)>>4,((y-ybase)*zoom)>>4,c,
                     (256*16*16)/zoom,0xff);
*/
      }
   }
}

enum { Rockford=0, PeluLeft=1,Brick0=2, Brick1=3, 
       PeluRight=4, PeluUp=5, PeluDown=6,
       PeluLeftMoved=7, PeluRightMoved=8, PeluUpMoved=9, PeluDownMoved=10,
       Boulder=11, BoulderFalls=12,
       Splat0=13,Splat1=14,Splat2=15,Splat3=16,       
       BoulderMoved=17,RockfordStanding=18,Tietzka=19,

       Void=128 };

#define MoveShit(mover,aftermove,afterchk, thispt,movpt,chkpt) \
  if(s==(mover)) { \
     if((field[(chkpt)&255]<128) && (field[(movpt)&255]>=128)) { \
         field[(thispt)&255]=128; field[(movpt)&255]=(aftermove); } else \
         field[(thispt)&255]=(afterchk); }

void simulate_bdash(u8*field)
{
   int x,y;
 
  /* field[rand()&255]=3;
  */
   for(y=0;y<16;y++)
   for(x=0;x<16;x++)
   {
      u8 s=field[y*16+x];
      MoveShit(PeluUp,PeluUpMoved,PeluRightMoved,y*16+x,y*16+x-16,y*16+x+1)
      else
      MoveShit(PeluDown,PeluDownMoved,PeluLeftMoved,y*16+x,y*16+x+16,y*16+x-1)
      else
      MoveShit(PeluRight,PeluRightMoved,PeluDownMoved,y*16+x,y*16+x+1,y*16+x+16)
      else
      MoveShit(PeluLeft,PeluLeftMoved,PeluUpMoved,y*16+x,y*16+x-1,y*16+x-16)
      else
      if(s==Boulder)
      {
         if(field[(y*16+x+16)&255]==128) field[y*16+x]=BoulderFalls;
      }
       else
      if(s==BoulderFalls)
      {
         u8 below = field[(y*16+x+16)&255];

         if(below==128) { field[y*16+x]=128;field[(y*16+x+16)&255]=BoulderMoved; }
         else
         if(below==PeluRight || below==PeluLeft || below==PeluUp || below==PeluDown ||
            below==PeluRightMoved || below==PeluLeftMoved || below==PeluUpMoved || below==PeluDownMoved)
         {
            int x1,y1;
            for(y1=-1;y1<=1;y1++)for(x1=-1;x1<=1;x1++)
                field[((y+y1)*16+x+x1)&255]=Splat0;
         }
         else
         if((field[(y*16+x+16+1)&255]==128) && (field[(y*16+x+1)&255]==128))
         { field[y*16+x]=128;field[(y*16+x+1)&255]=Boulder; }
         else
         if((field[(y*16+x+16-1)&255]==128) && (field[(y*16+x-1)&255]==128))
         { field[y*16+x]=128;field[(y*16+x-1)&255]=Boulder; }
         else field[y*16+x]=Boulder;
      }
   }

  for(y=0;y<16;y++)
  for(x=0;x<16;x++)
  {
      u8*s=&field[y*16+x];
      if(*s==PeluUpMoved)*s=PeluUp;else
      if(*s==PeluDownMoved)*s=PeluDown;else
      if(*s==PeluRightMoved)*s=PeluRight;else
      if(*s==PeluLeftMoved)*s=PeluLeft;else
      if(*s==Splat0)*s=Splat1;else
      if(*s==Splat1)*s=Splat2;else
      if(*s==Splat2)*s=Splat3;else
      if(*s==Splat3)*s=Void;else
      if(*s==BoulderMoved)*s=BoulderFalls;
  }
}

/*************************************************************************/

void fadeoldsk(int t)
{
   alloczoomer(&oldsk,t,128,-128,24,0);
}

void oldskzooms(int t)
{
   zoomsprite_gen(0,32+abs(127-((t<<1)&255))-64,&oldsk,48+abs(64-((t<<2)&127)),0xff);
}

void newtext(int t,char*txt,int col)
{
   sprite*z = (sprite*)malloc(sizeof(sprite));
   drawtext(z,txt,col);
   alloczoomer(z,t,48,128,24,1);
}

void drawtext(sprite*textbuf,char*txt,int col)
{
   int wdt=0,x=0,y=0,idx,hgt=7;
   unsigned char*f,*fnt=font;


/*   killtext();*/
   {char*t=txt;
   for(;;)
   {int thiswdt=0;
    while(*t && *t!='\n'){thiswdt+=font_lengths[(*t>='A'&&*t<=']')?(*t-'@'):4];t++;}
    if(thiswdt>wdt)wdt=thiswdt;
    if(!*t)break; else {t++;hgt+=11;}
   }}

   textbuf->width=wdt+1;
   textbuf->height=hgt+1;
   { int sz=textbuf->height*textbuf->width*sizeof(u8);
      textbuf->pict=malloc(sz);
      textbuf->mask=malloc(sz);
      memset(textbuf->pict,0,sz);
      memset(textbuf->mask,0xff,sz);}


   while(*txt)
   {
      int z=*txt,a;

      txt++;

      if(z=='\n'){x=0;y+=textbuf->width*11;continue;}

      z-='@';
      if(z<0 || z>29){x+=4;continue;}

      f=fnt;
      while(z)
      {
         if(*f==0)z--;
         f++;
      }

      while((a=*f))
      {
         idx=x+y;

         for(;a;a>>=1)
         {
            if(a&1){textbuf->pict[idx]=col;
                    textbuf->mask[idx]=0;
                    if(textbuf->mask[idx+1+textbuf->width])
                    {
                       textbuf->pict[idx+textbuf->width+1]=
                       textbuf->mask[idx+textbuf->width+1]=0;
                    }
                    }

            idx+=textbuf->width;
         }
         x++;
         f++;
      }
      x++; /* x+=2; */
   }
}


void rotozoompaski(u8*s,int u0,int v0,int du,int dv)
{
   u8*d=pwplib_buf;
   int i,j,u,v;
   int idu=du/pwplib_bufw,idv=dv/pwplib_bufw,
       odu=dv/pwplib_bufh,odv=-du/pwplib_bufh;

   for(i=pwplib_bufh;i;i--)
   {
      int iu=u,iv=v;
      for(j=pwplib_bufw;j;j--) 
      {
         *d++=s[((iu>>4)&(1023&~31))|((iv>>9)&31)];
         iu+=idu;iv+=idv;
      }
      u+=idv;v+=-idu;
   }
}

/*
void rotozoom_do(int t,int m)
{
   u8*poo[]={piimae.pict,pelu.pict,taehti.pict};
   int u=SIN(t),v=COS(t);
   rotozoompaski(poo[m],(-u+v)*32,(-v-u)*32,u,v);
}
*/
