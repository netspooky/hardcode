#include <dos.h>
#define codex
#define CLI
//#define INTR


int _seg *a=(int _seg *)0xa000;
//int stopped=0;
#ifdef codex
unsigned char *endtext="4kb Intro 'Chaos' (c) 1994\n\n\rCoding: Codex/Extend\n\n\rGreetings to: Future Crew, Silents, Virtual Visions, Paranoids.\n\n\r$";
#endif
#ifndef codex
unsigned char *endtext="4kb Intro 'Chaos' (c) 1994\n\n\rAt Assembly'94, Helsinki\n\n\rGreetings to: Future Crew, Silents, Virtual Visions, Paranoids.\n\n\r$";
#endif


#define plot(x,y,color) *(char far *)( ((char _seg *)a)+320*(y)+(x))=(color)
#define plota(as) *(char far *)((char _seg *)a+(as))^=0x80
#define plotb(as,bit) *(char far *)((char _seg *)a+(as))=(bit)
#define plot4(as) plota(as); plota(as+1); plota(as+321); plota(as+320);
#define abs(x) ((x)<0?-(x):(x))

#define plots(x,y,color) *(char far *)( ((char _seg *)a)+320*(y)+(x))=(color)
//void plotbc(int x,int y,int bit) { if ((y)>=0) if ((y)<=200) if ((x)>=0) if ((x)<=320) plots(x,y,bit); }
//void plotc(int x,int y) { if ((y)>=0) if ((y)<=200) if ((x)>=0) if ((x)<=320) plota((x)+(y)*320); }

#define xmax 318
#define xmin 0

int ymin=0,ymax=199;
#define vari 0
int mode=0,mode2=0,textplace;
int stage=0,count=0,count1=0;
//int ymin=0,ymax=199,xmax=318,xmin=0;
int sin[1025];
unsigned int linepattern=0xffff;

//unsigned int patterns[]=
//{
//0xffff,0xfffe,0xfefe,0xeeee,0xb6d3,0xaaaa,0x4924,0x1111,0x1010,0x1000,0,
//0,0,0,0,0,0,0
//};


#define xp 1
#define yp 2
#define zp 4
#define xm 8
#define ym 16
#define zm 32
#define dr 64
#define end_vec -1
#define origo -2
#define subitem -3
#define displace -4

char vec1[]={			// cube
	displace,0,xm+dr,ym+dr,xp+dr,yp+dr,
	zm+dr,
	xm+dr,ym+dr,xp+dr,yp+dr,
	ym,zp+dr,
	xm,zm+dr,
	yp,zp+dr,end_vec

	};
/*
char vec2[]={			// trek

	0,
	ym+xm+dr,
	yp+dr,
	ym+xm,
	xm+dr,
	xm+dr,
	xp,
	yp+dr,
	yp+dr,
	xp,xp,
	ym+dr,
	xp+dr,
	xm,
	xp+yp+dr,
	xp+ym,
	yp+dr,
	xp+dr,
	ym,
	xm+dr,
	ym+dr,
	xp+dr,
	xp,
	yp+dr,
	yp+dr,
	xp,
	xm+ym+dr,
	xp+ym+dr,-1
};
*/
char vec2[]=
{
	0,
	xm+dr,yp+dr,yp+dr,xm,ym+dr,ym+dr,yp,xm+dr,
	yp,ym+dr,ym+dr,xm,xm+dr,yp+dr,yp+dr,xp+dr,
	xp,xp,xp+ym,xp+dr,yp+dr,ym,ym+dr,
	xp,yp+dr,yp+dr,xp+dr,ym+dr,ym+dr,xm+dr,xp,xp,
	xp,xm+dr,yp+dr,xp+dr,yp+dr,xm+dr,end_vec

};


/*
char vec3[]={
  displace,yp,
  ym+dr,ym+dr,xm+dr,yp+dr,yp+dr,
  xp+dr,xp+dr,xp+dr,

  //ym+dr,ym+dr,ym+dr,yp,yp,yp,

  zm+dr,zm+dr,

  //ym+dr,ym+dr,ym+dr,yp,yp,yp,

  xm+dr,xm+dr,xm+dr,xm+dr,xm+dr,

  //ym+dr,ym+dr,ym+dr,yp,yp,yp,

  zp+dr,zp+dr,

  //ym+dr,ym+dr,ym+dr,yp,yp,yp,

  xp+dr,xp+dr,

  ym,ym,ym,
  xp+dr,xp+dr,xp+dr,
  ym+zm+dr,yp+zm+dr,
  xm+dr,xm+dr,xm+dr,xm+dr,xm+dr,
  zp+ym+dr,zp+yp+dr,
  xp+dr,xp+dr,
  xm+zm+ym,xm,
  xp+dr,xp+dr,xp+dr,xp+dr,xp+dr,

  yp,yp+zm+xm,xm+dr,yp+dr,xp+dr,ym+dr,
  xm,xm,
  xm+dr,yp+dr,xp+dr,ym+dr,
  end_vec
};
*/
char *vec[]={vec1,vec2};

#undef xp 1
#undef yp 2
#undef zp 4
#undef xm 8
#undef ym 16
#undef zm 32
#undef dr 64
// number= new picture +waittime
// -1, wait, repeat = moving blocks
// -2, num= change ashift
// -3, wait = STARS!!! needs blank screen
// -4, ystart,yend=linecut
// -5, ystart,yend = horiz-eor-line
// -6, colornum(0/1/2), colorset(0=0x0000,1=0xffff,2=random)
// -7, wait  = simple wait
// -8, palette = vaihda paletti
// -9, WAIT = LINETUNNEL
// -10,wait,object num,xspeed+yspeed*256 = vectorlines
// -11,ystart,yend = move vector y-coord...
// -12,xstart,xend = move vector x-coord...
// -15,xspeed+yspeed*256 = vector rotation control
#define f_vector -10
#define f_vecspeed -15
#define f_hline -5
#define f_ltunnel -9
#define f_block -1
#define f_end 0
#define f_x -12
#define f_y -11
#define f_z -13
#define f_maxy -3
#define f_linecut -4
#define f_wait -7
#define f_cont -14
#define f_ashift -2
#define f_endblock -6
#define f_sinscroll -8

#define ZMIN 2
#define shift  (7)
#define zshift (9)
#define cosadd (256) //196

int frames[]={

f_hline,0,199,
f_wait,200,

f_sinscroll,
f_wait,687,
f_sinscroll,


f_ashift,2,
f_x,-30,160,
f_y,0,0,
f_z,1500,200,
f_cont,1000,
f_vector,1200,1,(5+0*256),   // chaos-text
f_y,0,350,

f_ashift,1,

f_x,-100,520,
f_y,100,100,
f_z,60,60, // 50,50,

f_vector,620,0,(5+3*256),   // cube

f_sinscroll,
f_wait,520,
f_sinscroll,

//f_ashift,2,

//f_x,160,160,
//f_y,-70,100,
//f_z,150,150, // 50,50,
//f_cont,500,
//f_vector,800,2,(4+0*256),   // house
//f_x,160,480,

//f_wait,100,


f_x,160,160,
f_y,100,100,
f_linecut,100,0,
f_wait,1,
f_cont,250,
f_ltunnel,350,
f_linecut,0,100,

f_block,2,60,

f_wait,1550,
f_endblock,
f_hline,199,0,

f_wait,250,
f_end
};



#define cut(dd,do,dist) ((do)*(dist)/(dd))


void line(int x1,int y1,int x2,int y2)
{
int i,deltax,deltay,numpixels,d,dinc1,dinc2,c,xinc1,xinc2,y,yinc1,yinc2,scr;
int ainc1,ainc2,scr1,num1;

next:
if (y1<ymin && y2<ymin) return;
if (y1>ymax && y2>ymax) return;
if (x1>xmax && x2>xmax) return;
if (x1<xmin && x2<xmin) return;

if (x2<xmin)
{
y2=y1-cut(x1-x2,y1-y2,x1-xmin); x2=xmin; goto next;
}
if (y2<ymin)
{
x2=x1-cut(y1-y2,x1-x2,y1-ymin); y2=ymin; goto next;
}
if (x1<xmin)
{
y1=y2-cut(x2-x1,y2-y1,x2-xmin); x1=xmin; goto next;
}
if (y1<ymin)
{
x1=x2-cut(y2-y1,x2-x1,y2-ymin); y1=ymin; goto next;
}
if (x2>xmax)
{
y2=y1+cut(x1-x2,y1-y2,xmax-x1); x2=xmax; goto next;
}
if (x1>xmax)
{
y1=y2+cut(x2-x1,y2-y1,xmax-x2); x1=xmax; goto next;
}

if (y2>ymax)
{
x2=x1+cut(y1-y2,x1-x2,ymax-y1); y2=ymax; goto next;
}
if (y1>ymax)
{
x1=x2+cut(y2-y1,x2-x1,ymax-y2); y1=ymax; // goto next;
}


deltax=abs(x2-x1);
deltay=abs(y2-y1);

	if (deltax>=deltay)
	{
		numpixels=deltax+1;
		d=(deltay<<1) - deltax;
		dinc1=deltay<<1;
		dinc2=(deltay-deltax)<<1;
		xinc1=xinc2=yinc2=1; yinc1=0;
	} else {
		numpixels=deltay+1;
		d=(deltax<<1)-deltay;
		dinc1=deltax<<1;
		dinc2=(deltax-deltay) << 1;
		xinc1=0; xinc2=yinc1=yinc2=1;
	}
	if (x1>x2) { xinc1=-xinc1; xinc2=-xinc2; }
	if (y1>y2) { yinc1=-yinc1; yinc2=-yinc2; }
	ainc1=xinc1+yinc1*320; ainc2=xinc2+yinc2*320;
	_BX=x1+y1*320; _DI=x2+y2*320;
	//_DI=linepattern;
	_ES=(int)a;
	_CX=(numpixels-2)>>1;
	if ((int)_CX<=0) return;
	_DX=d+16384; if (_DX<16384) _DI-=ainc1; else _DI-=ainc2;
	_SI=linepattern;
	//for(i=1;i<=num1;i++)
	//{
	nextpixel:
		asm ror si,1
		asm jnc nopixel

		//if (_DI&0x1)
		//{
		asm xor byte ptr es:[bx],80h
		asm xor byte ptr es:[di],80h
		//}
		nopixel:
		if (_DX<16384) { _DX+=dinc1; _DI-=ainc1;
		_BX+=ainc1; } else
			 { _DX+=dinc2; _DI-=ainc2;
			 _BX+=ainc2; }

	asm loop nextpixel
	asm ror si,1
	asm jnc nopixel1
	if (_DI!=_BX) {
		asm xor byte ptr es:[bx],80h
		}
		asm xor byte ptr es:[di],80h
	nopixel1: ;
	//}
}




volatile unsigned int seed1=0x0,seed2=0xa001;
unsigned int aseed1=0x1234,aseed2=0x1234;

volatile unsigned int random()
{
unsigned int temp;
temp=seed1;seed1+=seed2; seed2=temp;
_AX=seed1;
asm ror ax,8
return seed1=_AX;
}

#ifdef INTR

void interrupt far _loadds stupidinterruptroutine()
{
int key=inportb(0x60);
if (key==1) stopped=1;
_CL=inportb(0x61);
_CL|=128;
outportb(0x61,_CL);
_CL&=0x7f;
outportb(0x61,_CL);
outportb(0x20,0x20);
}
#endif




void shade(int start,int end,int add)
{
int c;
for (;start!=end;start+=add)
{
_CX=768-3;
_DX=0x03c8;
_AX=1;  // 0
asm out dx,al
_DX++;
_AX=start;
uusi:
asm out dx,al
asm loop uusi


for (c=0;c<=2;c++)
{
	while (0==(inportb(0x3da)&8));
	while ((inportb(0x3da))&8);	//waittof
}
}

}

unsigned int teksti[]=
{
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0x1108,0x3108,0x3108,0x514e,0xf989,0x1149,0x112e, // 4kb
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0xe000,
0x4000,
0x4000,  // I
0x4000,
0xe000,
0,
0x1200,
0x1a00,
0x1600, // N
0x1200,
0x1200,
0,
0x03e0,
0x0080,
0x0080, // T
0x0080,
0x0080,
0,
0x0070,
0x0048,
//0x0048,
0x0070,  // R
0x0048,
0x0048,
0,
0x0006,
0x0009,
0x0009,  // O
0x0009,
0x0006,


0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,



0xaaaa,0x5555,0xaaaa,0x5555,0xaaaa,0x5555,0xaaaa,0x5555,
0xaaaa,0x5555,0xaaaa,0x5555,0xaaaa,0x5555,0xaaaa,0x5555,
0xaaaa,0xcccc,0x3333,0x3333,0xcccc,0xcccc,0x3333,0x3333,
0xcccc,0xcccc,0x3333,0x3333,0xcccc,0xcccc,0x3333,0x3333,
0xcccc,0xcccc,0x3333,0x3333,0xcccc,0xcccc,0x3333,0x3333,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,


};

void main()
{
char pal[256][3];
int placex[150],placey[150],blockcount[150];
int sx[150],sy[150],pl,pl1;
int b,c,c1,c2,c3,c4,d,f,e,e1,o,re,re1,xpl,xpl1,ypl,ypl1,plc,m,n;
int g;
char *oldobj;
unsigned int mode1,xdim,ydim,yscroll;
int hstart,hend,vstart,vend,bstart,etemp,ymin1,ymin2,ymax1,ymax2;
int vx2,vy2,alfa,beta,Vvar,alfa1,beta1,r,fx,fy,fz,fx1,fy1,fz1;
int vx,vy,vz,vx1,vy1,vz1;
int ca,cb,sa,sb,c0,ca1,cb1,sa1,sb1,zadd,xadd,yadd,zstart,zend,ystart,yend,xadd1,yadd1,zadd1,flg1,addalfa,addbeta;
int ashift;
int oldx[40],oldy[40];
char apu;
char *obj;
unsigned int pointer1,pointer2,ga,sincount,apointer1,apointer2;
int *frame=(int *)&frames;
int matrix[9],oldmatrix[9];
int bcount=-2;
int offset;
int *textptr,text,etext,acounter;
int wd,wdadd,intoff,intseg;
d=mode1=offset=bstart=yscroll=0;
textptr=(int *)teksti;
addalfa=4; addbeta=7; ashift=3;
zadd=150; xadd=160; yadd=100;

#ifdef INTR
_AL=9; _AH=0x35; geninterrupt(0x21);
intoff=_BX; intseg=_ES;
_DS=FP_SEG(stupidinterruptroutine);
_DX=FP_OFF(stupidinterruptroutine);
_AL=9; _AH=0x25; geninterrupt(0x21);
#endif
#ifdef CLI
	asm cli
#endif

for (b=0;b<=255;b++)
{
	pal[b][0]=pal[b][2]=random()&0x1f;
	pal[b][1]=0;
}

_AX=0x13; geninterrupt(0x10);


c=128; // accleration 64
d=0;
for (b=0;b<1024;b++)
{
sin[b]=d+=c;
	if (!(b&1))
	{
		if (d>0) c-=1; else c+=1;
	}
}

//_SI=(int)(pal+d);
//_DX=0x3c8; _AL=0;
//asm out dx,al
//_CX=128*3;
//_DX++;
//asm rep outsb

_CX=768;
_DX=0x03c8;
_AX=0;  // 0
asm out dx,al
_DX++;
uusi:
asm out dx,al
asm loop uusi

for (b=0;b<=31999;b++)
{
	plota(b);
	plota((unsigned int)b+32000);
}

shade(0,0x3f,1);

for (b=0;b<=31999;b++)
{
	plotb(b,random()%127+1); plota(b);
	plotb((unsigned int)b+32000,random()%127+1); plota((unsigned int)b+32000);
}



loop:
	//if (stopped==1) goto endprog;
	if (bcount==-1)
	{
	bcount=-2; e=etemp; goto loop1;
	} else mode=0;
loopagain:
	e=*frame++;
	switch(-e)
	{
	case 0: endprog:
	shade(0x3f,0,-1);
	_AX=0x3; geninterrupt(0x10);
	_DX=(int)endtext; _AH=9; geninterrupt(0x21);
#ifdef INTR
_DS=intseg;
_DX=intoff;
_AL=9; _AH=0x25; geninterrupt(0x21);
#endif
#ifdef CLI
	asm sti
#endif
	return;
	case 1: 		placex[offset]=-30;
				placey[offset]=0; blockcount[offset]=0;
				sx[offset]=1;sy[offset]=1;
				 mode=1; e=*frame;
				if (frame[1]) { offset++; frame[1]--; frame--; } else { frame+=2; }
	break;

	case 2: ashift=*frame++; goto loop;
	case 6: offset=0; goto loop;
	case 5: mode1|=1; goto label9;
	case 4: mode1|=128; label9: vstart=*frame++; vend=*frame++; goto loop;
	case 7: mode=-1; e=*frame++; break;
	case 8: mode1^=32; goto loop;
	case 9: mode=9; e=*frame++; break;
	case 10: mode=10; e=*frame++; alfa=beta=0; Vvar=*frame++; // ei break-komentoa!!
	case 15:
		addalfa=*frame++; addbeta=addalfa&0xff; addalfa>>=8; break;
	case 11: mode1|=4; yadd=ystart=*frame++; yend=*frame++; goto loop;
	case 12: mode1|=8; xadd=hstart=*frame++; hend=*frame++; goto loop;
	case 13: mode1|=16; zadd=zstart=*frame++; zend=*frame++; goto loop;
	case 14: bcount=*frame++; goto loop;
  default: textplace=*frame++;
}

loop1:
	for (b=bstart;b<=e;b++) {
	if (b==bcount) {
	bcount=-1; bstart=b; etemp=e; goto loopagain;
	}
	bstart=0;


	if (mode==9)
	{
		//if (b<80) { tunnelstart=(80-b)>>3; }
		//if (b>e-80) { tunnelstart=(b-e+80)>>3; }
		for (f=0;f<=30;f+=2) {	//26


			re=((((-b*512)&0x7ff)+f*0x400)>>5)+4;
			re1=(((((-b)*512-512)&0x7ff)+f*0x400)>>5)+4;
			xpl=(sin[(b*8-cosadd)&0x3ff])/((re>>3)+256)+xadd1;	// re=32-f
			ypl=(sin[(b*8)&0x3ff])/((re>>3)+(256))+yadd1;
			xpl1=(sin[((b+1)*8-cosadd)&0x3ff])/((re1>>3)+256)+xadd;
			ypl1=(sin[((b+1)*8)&0x3ff])/((re1>>3)+(256))+yadd;

			f<<=1;
				for(g=0;g<=7;g++)
				{
				 oldx[g]=(( sin[( (g<<7)    -((b)<<3)       +f)&0x3ff])/re)+xpl;
				 oldy[g]=(((sin[( (g<<7)    -((b)<<3)+cosadd+f)&0x3ff])/re))+ypl;

					ymin=ymin2; ymax=ymax2;
			//linepattern=patterns[(f>>3)];
			line( oldx[g],
			      oldy[g],
			       (( sin[(((g+1)<<7) -((b)<<3)       +f)&0x3ff])/re)+xpl,
			      (((sin[(((g+1)<<7) -((b)<<3)+cosadd+f)&0x3ff])/re))+ypl);

			oldx[g+16]=(( sin[( (g<<7)    -((b+1)<<3)       +f)&0x3ff])/re1)+xpl1;
			oldy[g+16]=(((sin[( (g<<7)    -((b+1)<<3)+cosadd+f)&0x3ff])/re1))+ypl1;

			//linepattern=patterns[(f>>3)];
			ymin=ymin1; ymax=ymax1;
			line(  oldx[g+16],
			       oldy[g+16],
			       (( sin[(((g+1)<<7) -((b+1)<<3)       +f)&0x3ff])/re1)+xpl1,
			       (((sin[(((g+1)<<7) -((b+1)<<3)+cosadd+f)&0x3ff])/re1))+ypl1);


			if (f>=4)
			{
			//linepattern=patterns[(f>>3)];
			ymin=ymin2; ymax=ymax2;
			   line(oldx[g],oldy[g],oldx[g+8],oldy[g+8]);
			ymin=ymin1; ymax=ymax1;
			//linepattern=patterns[(f>>3)];
			   line(oldx[g+16],oldy[g+16],oldx[g+24],oldy[g+24]);
			}
			oldx[g+8]=oldx[g];
			oldy[g+8]=oldy[g];
			oldx[g+24]=oldx[g+16];
			oldy[g+24]=oldy[g+16];
			}
			f>>=1;
		}
	//tunnelend=tunnelstart;

	}


	if (mode==10)
	{

		c0=sin[cosadd]>>shift;

		alfa+=addalfa; beta+=addbeta;

		sa=sin[(alfa)&0x3ff]>>shift;
		sb=sin[(beta)&0x3ff]>>shift;
		ca=sin[((alfa)+cosadd)&0x3ff]>>shift;
		cb=sin[((beta)+cosadd)&0x3ff]>>shift;

		matrix[0]=(ca*cb)>>ashift;
		matrix[1]=(sa*cb)>>ashift;
		matrix[2]=(sb*c0)>>zshift;

		matrix[3]=((-sa)*c0)>>ashift;
		matrix[4]=((ca)*c0)>>ashift;
		matrix[5]=0;

		matrix[6]=((-ca)*sb)>>ashift;
		matrix[7]=((-sa)*sb)>>ashift;
		matrix[8]=(cb*c0)>>zshift;
		oldobj=0;
		vz=zadd;
		vz1=zadd1;
label2:
		obj=vec[Vvar];

label1:
		vx=vx1=vy=vy1=0;

		vz+=(matrix[2]+matrix[5]+matrix[8]>>1);
		vz1+=(oldmatrix[2]+oldmatrix[5]+oldmatrix[8]>>1);
		vy+=matrix[1]+matrix[4]+matrix[7]>>1;
		vy1+=oldmatrix[1]+oldmatrix[4]+oldmatrix[7]>>1;
		vx+=matrix[0]+matrix[3]+matrix[6]>>1;
		vx1+=oldmatrix[0]+oldmatrix[3]+oldmatrix[6]>>1;

label3:
	for(;;)
	{
foragain:
	   switch (-(apu=*obj++))
	   {
		case 1: goto endfor;
		case 2: goto label1;
		case 3:
		apu=*obj++; oldobj=obj; obj=vec[apu]; goto foragain;
		case 4:


		goto foragain;

	   }
		if (apu&1) { vx+=matrix[0]; vy+=matrix[1]; vz+=matrix[2];
		     vx1+=oldmatrix[0]; vy1+=oldmatrix[1]; vz1+=oldmatrix[2]; }
		if (apu&2) { vx+=matrix[3]; vy+=matrix[4]; vz+=matrix[5];
		     vx1+=oldmatrix[3]; vy1+=oldmatrix[4]; vz1+=oldmatrix[5]; }
		if (apu&4) { vx+=matrix[6]; vy+=matrix[7]; vz+=matrix[8];
		     vx1+=oldmatrix[6]; vy1+=oldmatrix[7]; vz1+=oldmatrix[8]; }
		if (apu&8) { vx-=matrix[0]; vy-=matrix[1]; vz-=matrix[2];
		     vx1-=oldmatrix[0]; vy1-=oldmatrix[1]; vz1-=oldmatrix[2]; }
		if (apu&16) { vx-=matrix[3]; vy-=matrix[4]; vz-=matrix[5];
		     vx1-=oldmatrix[3]; vy1-=oldmatrix[4]; vz1-=oldmatrix[5]; }
		if (apu&32) { vx-=matrix[6]; vy-=matrix[7]; vz-=matrix[8];
		     vx1-=oldmatrix[6]; vy1-=oldmatrix[7]; vz1-=oldmatrix[8]; }

		if (apu&64)
		{
		linepattern=0xffff;
		if (Vvar!=1) { if (vz>73 || fz>73) linepattern=0x8888; }
		line(vx/vz+xadd,vy/vz+yadd,fx/fz+xadd,fy/fz+yadd);
		linepattern=0xffff;
		if (Vvar!=1) { if (vz1>73 || fz1>73) linepattern=0x8888; }
		if (b!=0) line(vx1/vz1+xadd1,vy1/vz1+yadd1,fx1/fz1+xadd1,fy1/fz1+yadd1);
		}
		fx=vx; fx1=vx1; fy=vy; fy1=vy1; fz=vz; fz1=vz1;
	}
endfor:
	if (oldobj!=0) { obj=oldobj; oldobj=0; goto label1; }

	for (f=0;f<=8;f++) oldmatrix[f]=matrix[f];

	linepattern=0xffff;

	}

		zadd1=zadd; yadd1=yadd; xadd1=xadd;


	if (mode1&4)
	{
	if (ystart==yend) mode1&=~4;
	yadd=(ystart+=((ystart>yend) ? -1 : 1));
	}
	if (mode1&8)
	{
	if (hstart==hend) mode1&=~8;
	xadd=(hstart+=((hstart>hend) ? -1 : 1));
	}
	if (mode1&16)
	{
	if (zstart==zend) mode1&=~16;
	zadd=zstart+=((zstart>zend) ? -2 : 2);
	}

	if (mode1&1)
	{
	g=320*vstart;
	for (f=0;f<=319;f++) { plota(g+f); }
	if (vstart==vend) mode1&=0xfe;
	vstart+=(vstart>vend) ? -1 : 1;
	}

	ymin2=ymin1;
	ymax2=ymax1;
	if (mode1&128)
	{
	if (vstart==vend) mode1&=0x7f;
	vstart+=(vstart>vend) ? -1 : 1;
	ymin1=vstart;
	ymax1=199-vstart;
	}


	if (mode1&32)
	{
	if (yscroll) yscroll--; else { yscroll=7; textptr++; }
	pointer1=yscroll*320+160;
	_ES=(int)a;
	for (f=0;f<=24;f++)
	{
	etext=textptr[f-1];
	text=textptr[f];
	wdadd=200+(sin[(((f<<3)+yscroll)<<3)&0x3ff]>>8);
	wd=-(wdadd)<<3;           //width[(f<<3)+yscroll])<<4;
	ga=0x8000;
	for (g=0;g<16;g++)
	{
		if ((etext&ga)!=(text&ga))
		{
		_BX=(wd>>4); pointer2=_CX=(((wd+wdadd)>>4)-_BX);
		_CX>>=1;
		_BX+=pointer1;
		_SI=0x8080;

		again1:
		asm xor es:[bx],si
		asm add bx,2
		asm loop again1

		if (pointer2&1) plota(_BX);

		}
		ga>>=1;
		wd+=wdadd;
	}

	pointer1+=320*8;


	}

	}


	if (offset!=0)
	{
	acounter++;
	for (f=0;f<offset;f++) {
	pl1=placex[f]+(sin[(acounter+(f<<4)<<3)&0x3ff]>>11)+(placey[f]+(sin[cosadd+((acounter-(f<<2))<<3)&0x3ff]>>11))*320-1284;
	o=e1=0x8080;
	if (placex[f]<=10||blockcount[f]>=1520) e1=0;
	blockcount[f]++; if (blockcount[f]>=1520) o=0;
	placex[f]+=sx[f]; if (placex[f]<=10) { sx[f]=1; o=0;}
			  if (placex[f]>=307) sx[f]=-1;
	placey[f]+=sy[f]; if (placey[f]<=10) sy[f]=1;
			  if (placey[f]>=190) sy[f]=-1;
	pl=placex[f]+(sin[(acounter+1+(f<<4)<<3)&0x3ff]>>11)+((sin[cosadd+((acounter+1-(f<<2))<<3)&0x3ff]>>11)+placey[f])*320-1284;	_ES=(int)a; _BX=pl; _DI=pl1;
	for(_AX=0;_AX<=5;_AX++)
	{
		_CX=3;
		again:
		asm add bx,2
		asm mov si,o
		asm xor es:[bx],si

		asm add di,2
		asm mov si,e1
		asm xor es:[di],si
		asm loop again

		_BX+=(314); _DI+=(314);
	}




		}

	}




	while (0==(inportb(0x3da)&8));
	while ((inportb(0x3da))&8);	//waittof


d=random()&0x7f;
c1=pal[d+vari][0];c2=pal[d+vari][1];c3=pal[d+vari][2];
pal[d+vari][0]=pal[d+vari][1]=pal[d+vari][2]=0;

_SI=(int)(pal+d);
_DX=0x3c8; _AL=0;
asm out dx,al
_CX=128*3;
_DX++;
asm rep outsb

pal[d+vari][0]=c1;pal[d+vari][1]=c2;pal[d+vari][2]=c3;


}



goto loop;
}




