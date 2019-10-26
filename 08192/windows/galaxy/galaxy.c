/* ---------------------------------------------------------------------------------

	Hi guys,

	my first Win32 piece of code .. and my second C-program ...
	It was developed under WinXP on a Celeron 766.


	Nothing special to say about it .. it's a particle galaxy, not very complicated
	if you know how to do :-)

	I wanted to use it as a part of an intro, but I had no idea how to combine it with
	other effects.  

	Greetz fly to Gaffer for creating TinyPTC! It saved me to think about DirectX...

	To compile: LCC galaxy.c, LCCLNK galaxy.obj tinyptc.lib ....

	You can use it, but don't forget to greet :-)))

	Outlaw/YZ
	www.yakuza.de.be

----------------------------------------------------------------------------------------*/

#include <tinyptc.h>
#include <math.h>
#include "galpal.txt"

#define WIDTH 640
#define HEIGHT 480
#define SIZE WIDTH*HEIGHT

const double pi=3.14159265359;
const double e=2.71828182845904523536;

unsigned char field[400];

struct star { signed short x,y,z; };
struct star galaxy[2500];
int rotata;

static unsigned int index;
static unsigned int pixel[SIZE];
unsigned int pal[256];

unsigned short MyRandom(unsigned short range)
{
	if (range==0) return 0; else
	return (rand()/(32768/range));  
}

void createPal()
{
	unsigned int t,r,g,b;

	for (t=0;t<256;t++)
	{
		r=galpal[t*3];g=galpal[t*3+1];b=galpal[t*3+2];
		pal[t]=(r<<16)+(g<<8)+b;
	}
}


void createParticle()
{
	signed int t,t1,tt,t1t1;
	for (t=0;t<20;t++)
	for (t1=0;t1<20;t1++)
	{
		tt=(10-t)*(10-t);
		t1t1=(10-t1)*(10-t1);
		field[t*20+t1]=(char)(90*(1/(sqrt( (double)(tt + t1t1))+1)))-5;
	}
}


void createSpirale()
{
  int t,t1,t2,zweitradius;
  double startradius,startwinkel,xstar,ystar,zstar;

  
  createParticle();
  for (t=0;t<5;t++)					// Anzahl der Spiralarme
  {
    	startwinkel=(pi/180)*((double)t*72);	
	startradius=0;
	for (t1=0;t1<100;t1++)				// Anzahl der "Hauptsterne
	{
		xstar=cos(startwinkel)*startradius;	// "Zentralgestirn"
		zstar=sin(startwinkel)*startradius;	// Gal liegt in X-Z Ebene
		zweitradius=(130-t1)/2;			// Radius der Sternenhaufe nimmt am Rand ab
		for (t2=0;t2<5;t2++)
		{
			galaxy[(t*500)+(t1*5)+t2].x=(signed short)(xstar-(zweitradius/2)+MyRandom(zweitradius));
			galaxy[(t*500)+(t1*5)+t2].y=MyRandom(zweitradius)-(zweitradius/2); 
			galaxy[(t*500)+(t1*5)+t2].z=(signed short)(zstar-(zweitradius/2)+MyRandom(zweitradius));
   		}
		startradius=startradius+1.5;
		startwinkel=startwinkel+0.04;
	}

  }
}


void showSpirale(int winkel)
{
    int t,t1,t2,t3,pos,col,xnew,znew,ynew,xmax,xmin,ymax,ymin; 
    double coswinkel,sinwinkel;
    coswinkel=cos((pi/180)*winkel);sinwinkel=sin((pi/180)*winkel);
    xmax=0;xmin=640;ymax=0;ymin=640;
    for (t=0;t<2500;t++)
    {
	xnew=(int)((double)galaxy[t].x*coswinkel - (double)galaxy[t].z*sinwinkel);
	znew=(int)((double)galaxy[t].z*coswinkel + (double)galaxy[t].x*sinwinkel);
	ynew=(int)((double)galaxy[t].y*coswinkel + (double)znew*sinwinkel);
	znew=(int)((double)znew*coswinkel - (double)galaxy[t].y*sinwinkel);

	xnew=xnew+320; ynew=ynew+240;

	if (xnew>xmax) { xmax=xnew; }
	if (ynew>ymax) { ymax=ynew; }
	if (xnew<xmin) { xmin=xnew; }
	if (ynew<ymin) { ymin=ynew; }
	
	pos=ynew*640+xnew;
	for (t1=0;t1<20;t1++)
	 for (t2=0;t2<20;t2++)
	{
		col=pixel[pos+(t1*640)+t2];
		col=col+field[t1*20+t2];
		if (col>255) { col=255; }
		pixel[pos+(t1*640)+t2]=col;
				
    	}
    }

      for (t1=ymin;t1<(ymax+20);t1++)
	for (t=xmin;t<(xmax+20);t++)
	{
		col=pixel[t1*640+t];
		pixel[t1*640+t]=pal[col];
	}
}


void clearBuffer()
{
	memset(pixel,0,sizeof(pixel));
}


int main(void)
{
	createPal(); 
	
   if (!ptc_open("test",WIDTH,HEIGHT)) { printf("Couldn't create DXSurface !\n");return 1; }
   createSpirale();
	rotata=359;
    while (1)
    {
	showSpirale(rotata);
	rotata=rotata-2;
	if (rotata<0) { rotata=rotata+359; }
	ptc_update(pixel);
	clearBuffer();
    }
}
