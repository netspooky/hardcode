#include "perlin.h"


#define YWRAP 16
#define YWRAPB 4
#define TWRAP 256
#define TWRAPB 8

#define OCTAVEN 2

float __forceinline fsc(float i)
{
  return 0.5f*(1.0f-cos(i*3.1415926535f));
}

Perlin::Perlin(void)
{
	int i;
	for(i=0; i<4096; i++)
		buffer[i] = rand()/32767.0f;
	for (i=0; i<IBUFSIZE; i++) 
		ucbuf[i] = rand();
  for (i=0; i<256; i++)
    wtb[i]=255*fsc(i/256.0f);
}

Perlin::~Perlin(void)
{
}

float Perlin::Get(float x)
{
	if(x<0) x=-x;
	float r=0;
	float ampl=0.5f;
  int xi=(int) x;
  float xf = x-xi;
    
	for(int i=0; i<OCTAVEN; i++)
	{
		float n1;
		n1  = buffer[xi&4095];
    n1 += fsc(xf)*(buffer[(xi+1)&4095]-n1);
		r  += n1*ampl;
		ampl *= 0.5f;
    xi<<=1; xf*=2;
    if (xf>=1.0f) xi++, xf-=1.0f;
	}
	return r;
}


float Perlin::Get2D (float x, float y) {
  if (x<0) x=-x;
	if (y<0) y=-y;
  int xi=x, yi=y;

	float r=0;
	float ampl=0.5f;
  float xf=x-xi, yf=y-yi, rxf;

  xf=yf=.0f;
  
  for(int i=0; i<OCTAVEN; i++)
	{
	  int of=xi+(yi<<YWRAPB);
		float n1,n2;

    rxf=fsc(xf);

		n1  = buffer[of&4095];
    n1 += rxf*(buffer[(of+1)&4095]-n1);
		n2  = buffer[(of+YWRAP)&4095];
    n2 += rxf*(buffer[(of+YWRAP+1)&4095]-n2);
		n1 += fsc(yf)*(n2-n1);
		
		r  += n1*ampl;

		ampl *= 0.5f;
		xf *= 2; xi<<=1;
		yf *= 2; yi<<=1;
    if (xf>=1.0f) xi++, xf-=1.0f;
    if (yf>=1.0f) yi++, yf-=1.0f;
	}
  return r;
}

float Perlin::Get3D (float x, float y, float t) {
	if (x<0) x=-x;
	if (y<0) y=-y;
	if (t<0) t=-t;

  int xi=x, yi=y, ti=t;
	float xf = x-xi;
  float yf = y-yi;
  float tf = t-ti;
  float rxf, ryf;

	float r=0;
	float ampl=0.5f;

	for(int i=0; i<OCTAVEN; i++)
	{
	  int of=xi+(yi<<YWRAPB)+(ti<<TWRAPB);
		float n1,n2,n3;

    rxf=fsc(xf);
    ryf=fsc(yf);

		n1  = buffer[of&4095];
    n1 += rxf*(buffer[(of+1)&4095]-n1);
    n2  = buffer[(of+YWRAP)&4095];
    n2 += rxf*(buffer[(of+YWRAP+1)&4095]-n2);
    n1 += ryf*(n2-n1);
    
    of += TWRAP;
    n2  = buffer[of&4095];
    n2 += rxf*(buffer[(of+1)&4095]-n2);
    n3  = buffer[(of+YWRAP)&4095];
    n3 += rxf*(buffer[(of+YWRAP+1)&4095]-n3);
    n2 += ryf*(n3-n2);

    n1 += fsc(tf)*(n2-n1);

		r += n1*ampl;
		ampl *= 0.5f;
		xi<<=1; xf*=2;
		yi<<=1; yf*=2;
    ti<<=1; tf*=2;

    if (xf>=1.0f) xi++, xf-=1.0f;
    if (yf>=1.0f) yi++, yf-=1.0f;
    if (tf>=1.0f) ti++, tf-=1.0f;
	}
	
  return r;
}

unsigned char Perlin::GetI3DI (unsigned int xfp, unsigned int yfp, unsigned int tfp) 
{
	int r = 0;
	
	// in is 16.16 fixed point
	
	int amplshift = 17;
	while (amplshift<25) { // do 7 ovtaves.. way enough for char result
		unsigned int xindex = (xfp>>16)&0xffff;
		unsigned int yindex = ((yfp>>16)&0xffff)<<5; // ROL BLAH!!! .. hate c
		unsigned int tindex = ((tfp>>16)&0xffff)<<10; // ROL BLAH!!!
		int xf = wtb[(xfp>>8)&0xff];
		int yf = wtb[(yfp>>8)&0xff];
		int tf = wtb[(tfp>>8)&0xff];
    unsigned int off=xindex+yindex+tindex;

		int n1 = ucbuf [off&0xffff];
		int n2 = ucbuf [(off+1)&0xffff];
		int nh1 = (n1<<8) + (n2-n1)*xf; // 8.8
		n1 = ucbuf [(off+32)&0xffff];
		n2 = ucbuf [(off+33)&0xffff];
		int nh2 = (n1<<8) + (n2-n1) * xf; // 8.8
		int nv1 = ((nh1<<8) +  (nh2-nh1) * yf) >> 8; // 8.8

		n1 = ucbuf [(off+1024)&0xffff];
		n2 = ucbuf [(off+1025)&0xffff];
		nh1 = (n1<<8) + (n2-n1) * xf; // .8
		n1 = ucbuf [(off+1056)&0xffff];
		n2 = ucbuf [(off+1057)&0xffff];
		nh2 = (n1<<8) + (n2-n1) * xf; // .8
		int nv2 = ((nh1<<8) +  (nh2-nh1) * yf) >> 8; // .8		

		int n = ((nv1<<8) + (nv2-nv1)*tf)>>(amplshift);

		r+=n;
		xfp<<=1; yfp<<=1; tfp<<=1;		
		amplshift++;
	}	

  return r;
}

unsigned char Perlin::GetI3D (float x, float y, float t) {
	// convert float to fixed point
	unsigned int xfp = (unsigned int)(x*(float)((1<<16)-1));
	unsigned int yfp = (unsigned int)(y*(float)((1<<16)-1));
	unsigned int tfp = (unsigned int)(t*(float)((1<<16)-1));

	return GetI3DI (xfp, yfp, tfp);
}