#include "drawing.h"
#include "nrline.h"
#include "pastelcolor.h"

#ifndef mySwap 
#define mySwap(_x, _y, _temp) _temp = _x; _x = _y; _y = _temp
#endif

int maxi (int a, int b) 
{
	if (a<0) a=-a; if (b<0) b=-b;
	if (a>b) return a;
	return b;
}

CDrawing::CDrawing(void)
{	
	perlin = new Perlin();
}

CDrawing::~CDrawing(void)
{
}

template< class T > void swap( T& a, T& b ) 
{
	T c;
	c = a; a = b; b = c;
}

static int textln=0;

void CDrawing::DrawLine(Vector a, Vector b)
{
	int i,j;
  Vector d=a;
  d-=b;
	float len = (float)sqrt(d.x*d.x + d.y*d.y);

	int subdivs = (int)(len/20)+1;

	float maxd=(len<32.0f)?(len*0.5):16.0f;
  float tf=1.0f;
  if (textln)
    maxd*=2.1f, tf*=5.5f;
  else
    maxd*=1.6f, tf*=2.2f;

	b.x += (perlin->Get3D (b.x*0.01f, b.y*0.01f,t*1.3f*tf)-0.5f) * 0.5f * maxd;
	b.y += (perlin->Get3D (b.y*0.01f, b.x*0.01f,t*1.4f*tf)-0.5f) * 0.5f * maxd;
	a.x += (perlin->Get3D (a.x*0.01f, a.y*0.01f,t*1.3f*tf)-0.5f) * 0.5f * maxd;
	a.y += (perlin->Get3D (a.y*0.01f, a.x*0.01f,t*1.4f*tf)-0.5f) * 0.5f * maxd;
	a.x += (perlin->Get2D (a.x*0.01f, a.y*0.01f)-0.5f) * maxd;
	a.y += (perlin->Get2D (a.y*0.01f, a.x*0.01f)-0.5f) * maxd;

	for(i=0; i<4; i++)
	{

		d = a;
    d -= b;
		a += d * (perlin->Get2D (b.x*0.0404f, b.y*0.00707f)-0.6f)*0.1f;
		b -= d * (perlin->Get2D (b.x*0.0303f, b.y*0.00909f)-0.6f)*0.1f;

		Vector k=a, ok;
		d = (b-a)/(float)subdivs;

		for(j=0; j<(subdivs+1)/2; j++)
		{			
			ok=k;
			k+=d;
			k.x += (perlin->Get(j*0.1f)-0.5f) * -d.y * .303f;
			k.y += (perlin->Get(j*0.1f)-0.5f) * d.x * .303f;
			DDBresenhamLine(ok.x, ok.y, k.x, k.y, 0x60606060);
		}		
		for(j=0; j<subdivs/2; j++)
		{			
			ok=k;
			k+=d;
			k.x += (perlin->Get(j*0.1f)-0.5f) * d.y * .303f;
			k.y += (perlin->Get(j*0.1f)-0.5f) * -d.x * .303f;
			DDBresenhamLine(ok.x, ok.y, k.x, k.y, 0x60606060);
		}		

		b.x += (perlin->Get3D (b.x*0.01f, b.y*0.01f,i*0.1f*tf)-0.5f) * d.x * .01707f;
		b.y += (perlin->Get3D (b.y*0.01f, b.x*0.01f,i*0.1f*tf)-0.5f) * d.y * .01707f;
	}
}

void CDrawing::DrawText(LineFont* lf, char* string, int x, int y, float size, int spacing, int lw)
{
  textln=1;

	while(*string)
	{
		LineChar* lc=&(lf->LC[(int)(*string)]);
		int v=0;
		for(int i=0; i<lc->curvecount; i++)
		{
			int pindex = v;
			for(int j=0; j<lc->ppcurve[i]-1; j++)
			{
				DrawLine(lc->Curves[v]*size+Vector((float)x,(float)y,0.0f),lc->Curves[v+1]*size+Vector((float)x,(float)y,0.0f));

				v++;
			}
			DrawLine(lc->Curves[pindex]*size+Vector((float)x,(float)y,0.0f),lc->Curves[v]*size+Vector((float)x,(float)y,0.0f));
			v++;
		}
		string++;
		x+=(int)((lc->w+spacing)*size);
	}

  textln=0;
}


long __forceinline ceil16r(long x)
{
  __asm {
    mov eax, [x]
    add eax, 0ffffh
    shr eax, 16
  }
}

long __forceinline imul16(long x, long y)
{
  __asm {
    mov eax, [x]
    imul [y]
    shrd eax, edx, 16
  }
}

long __forceinline imul14(long x, long y)
{
  __asm {
    mov eax, [x]
    imul [y]
    shrd eax, edx, 14
  }
}

long __forceinline idiv16(long x, long y)
{
  __asm {
    mov eax, [x]
    mov edx, eax
    sar edx, 16
    shl eax, 16
    idiv [y]
  }
}

void CDrawing::rightSide()
{
  int dy;
  
  int index=r_eck-1;
  if (index<0) index=2;

  rdy=ceil16r(poly.y[index])-ceil16r(poly.y[r_eck]);
  if (rdy<=0)
  {
    r_eck=index;
    return;
  }

  dy=poly.y[index]-poly.y[r_eck];

  if (rdy>1)
    rdx=idiv16(poly.x[index]-poly.x[r_eck], dy);
  else
  {
    long idy=(0x10000<<14)/dy;
    rdx=imul14(poly.x[index]-poly.x[r_eck], idy);
  }

  int prestep=(ceil16r(poly.y[r_eck])<<16)-poly.y[r_eck];
  rx=poly.x[r_eck]+imul16(prestep, rdx);
  r_eck=index;
}

void CDrawing::leftSide()
{
  int dy;

  int index=l_eck+1;
  if (index>2) index=0;

  ldy=ceil16r(poly.y[index])-ceil16r(poly.y[l_eck]);
  if (ldy<=0)
  {
    l_eck=index;
    return;
  }

  dy=poly.y[index]-poly.y[l_eck];

  if (ldy>1)
  {
    ldx=idiv16(poly.x[index]-poly.x[l_eck], dy);
    ldu=idiv16(poly.u[index]-poly.u[l_eck], dy);
    ldv=idiv16(poly.v[index]-poly.v[l_eck], dy);
  }
  else
  {
    long idy=(0x10000<<14)/dy;
    ldx=imul14(poly.x[index]-poly.x[l_eck], idy);
    ldu=imul14(poly.u[index]-poly.u[l_eck], idy);
    ldv=imul14(poly.v[index]-poly.v[l_eck], idy);
  }

  int prestep=(ceil16r(poly.y[l_eck])<<16)-poly.y[l_eck];
  lx=poly.x[l_eck]+imul16(prestep, ldx);
  lu=poly.u[l_eck]+imul16(prestep, ldu);
  lv=poly.v[l_eck]+imul16(prestep, ldv);
  l_eck=index;
}

void CDrawing::drawFace(DrawFaceObjPtr f)
{
  unsigned int *col=f->col->colormap;
  unsigned char *tex=::texture->GetTexture(f->texnum);
  int i, j, x1, w, u, v, end_of_line, miny, maxy, tdu, tdv;
  double d, id;

  poly.x[0]=f->x1*65536.0f;
  poly.y[0]=f->y1*65536.0f;
  poly.u[0]=f->u1*65536.0f;
  poly.v[0]=f->v1*65536.0f;

  poly.x[1]=f->x2*65536.0f;
  poly.y[1]=f->y2*65536.0f;
  poly.u[1]=f->u2*65536.0f;
  poly.v[1]=f->v2*65536.0f;

  poly.x[2]=f->x3*65536.0f;
  poly.y[2]=f->y3*65536.0f;
  poly.u[2]=f->u3*65536.0f;
  poly.v[2]=f->v3*65536.0f;

  miny=maxy=poly.y[0];
  o_eck=u_eck=0;

  for (i=1; i<3; i++)
  {
    j=poly.y[i];
    if (j<miny)
    {
      miny=j;
      o_eck=i;
    }
    if (j>maxy)
    {
      maxy=j;
      u_eck=i;
    }
  }
  
  l_eck=r_eck=o_eck;

  // doing the following in fixed point is a real bitch, so i won't :)
  
  d=((double) (poly.x[0]-poly.x[2])*(double) (poly.y[1]-poly.y[2])-
     (double) (poly.x[1]-poly.x[2])*(double) (poly.y[0]-poly.y[2]))/(65536.0f*65536.0f);
      
  if (d==0.0)
    return;

  id=1.0/d;

  double y02=(poly.y[0]-poly.y[2])/65536.0f;
  double y12=(poly.y[1]-poly.y[2])/65536.0f;

  tdu=((double) (poly.u[0]-poly.u[2])*y12-(double) (poly.u[1]-poly.u[2])*y02)*id;
  tdv=((double) (poly.v[0]-poly.v[2])*y12-(double) (poly.v[1]-poly.v[2])*y02)*id;
  
  do
  {
    if (r_eck==u_eck)
      return;

    rightSide();
  } while (rdy<=0);

  do
  {
    if (l_eck==u_eck)
      return;

    leftSide();
  } while (ldy<=0);

  unsigned int *vbuffer=vscreen+ceil16r(miny)*lPitch;

  for (;;)
  {
    x1=ceil16r(lx);
    w=ceil16r(rx)-x1;

    if (w>0)
    {
      int prestep=(x1<<16)-lx;
      u=lu+imul16(prestep, tdu);
      v=lv+imul16(prestep, tdv);

#if 1 // textured
      __asm {
        mov   eax, [w];
        mov   ecx, [x1];
        mov   esi, [u];
        mov   edi, [v];
        add   eax, ecx;
        mov   [end_of_line], eax;

pixel:
        mov   eax, esi;
        mov   ebx, edi;
        shr   eax, 16;
        shr   ebx, 8;
        and   eax, 000ffh
        and   ebx, 0ff00h;
        or    eax, ebx;
        add   eax, [tex];
        mov   edx, [col];
        movzx ebx, byte ptr [eax]; // ich hab hier eh nen agi, so what

        mov   ebx, dword ptr [edx+ebx*4]; // hier auch
        mov   edx, [vbuffer];
        mov   [edx+ecx*4], ebx;

        add   esi, [tdu];
        add   edi, [tdv];

        inc   ecx;
        cmp   ecx, [end_of_line];
        jb    pixel;
      }
#else // debug flatshade
      __asm
      {
        mov   ecx, [w];
        mov   eax, [x1];
        mov   ebx, [vbuffer];
        lea   edi, [ebx+eax*4];
        cld;
        mov   eax, 0ff7800h;
        rep   stosd;
      }
#endif
    }

    vbuffer+=lPitch;

    if (--rdy<=0)
    {
      while (rdy<=0)
      {
        if (r_eck==u_eck)
          return;

        rightSide();
      }
    }
    else
      rx+=rdx;

    if (--ldy<=0)
    {
      while (ldy<=0)
      {
        if (l_eck==u_eck)
          return;

        leftSide();
      }
    }
    else
    {
      lx+=ldx;
      lu+=ldu;
      lv+=ldv;
    }
  }
}


void CDrawing::DDBresenhamLine(float x0, float y0, float x1, float y1, unsigned int value)
{
	float dx, dy, t;
	int error, incre, incrne, x, y, i, length;

	if (x0<1) x0=1;
	if (x0>638) x0=638;
	if (x1<1) x1=1;
	if (x1>638) x1=638;
	if (y0<1) y0=1;
	if (y0>478) y0=478;
	if (y1<1) y1=1;
	if (y1>478) y1=478;

	if(x0==x1 && y0==y1)return;

  if (fabs(x1-x0)>fabs(y1-y0))
  {
    if (y0<y1)
    {
      mySwap(x0, x1, t);
      mySwap(y0, y1, t);
    }
  }
  else
  {
    if (x0<x1)
    {
      mySwap(x0, x1, t);
      mySwap(y0, y1, t);
    }
  }

  x=x0;
	y=y0;
	dx=x1-x0;
	dy=y1-y0;

	if (dx<0)
	{
		incre=-1;
		dx=-dx;
	}
	else
    incre=1;

	if (dy<0)
	{
		incrne=-lPitch;
		dy=-dy;
	}
	else
    incrne=lPitch;

	i=0;
	int dxi=(int)(dx*256.0f);
	int dyi=(int)(dy*256.0f);

	if (dx<dy)
	{
    int offset=x+y*lPitch;
		length=dy+1;
		error=(y0-y)*dxi-(x0-x)*dyi;
    __asm emms;
		while(i<length)
		{
      offset+=incrne;
			error+=dxi;
			if (error>dyi)
			{
				offset+=incre;
				error-=dyi;
			}
			i++;
      unsigned int *pixel=vscreen+offset; 
			// okay, kids. this is evil. NEVER NEVER EVER use
      // vram reads. they are slow, like SLOW. SLOOOW. don't do it. no-no-no.
      // (seems like we're really lazy, yeah)
			// (and we're trained professionals, of course)
			__asm {
				mov esi, [pixel]
				movd mm6, [esi]
				movd mm7, [value]
				psubusb mm6,mm7
				movd [esi], mm6
      } 
 		}
	}
	else
	{
    int offset=x+y*lPitch;
		length=dx+1;
		error=(x0-x)*dyi-(y0-y)*dxi;
    __asm emms;
		while(i<length)
		{
			offset+=incre;
			error+=dyi;
			if(error>dxi)
			{
				offset+=incrne;
				error-=dxi;
			}
			i++;
			unsigned int *pixel=vscreen+offset;
			__asm {
				mov esi, [pixel]
				movd mm6, [esi]
				movd mm7, [value]
				psubusb mm6,mm7
				movd [esi], mm6
			}
		}
	}
	__asm emms;
}