#include "math.h"
#include "stdio.h"
#include "stdlib.h"
#include "fcntl.h"
#include "unistd.h"
#include "malloc.h"
#include "time.h"
#include "sys/time.h"

#include "config.h"
#include "oxl.h"
#include "3xfont.h"

#ifdef __linux__
#include "linux/string.h"
#else
#include "string.h"
#endif

extern int TIKLGT;

/** typedefs **/

typedef struct { signed int x,y,z; } vec3d;

/**/

char *ruutu;
int *mxbuf;

int *ballz;

/**************** tEXT dRAWiNG rOUTiNES **********

bitmaps are for lamers :) let's use a little 12-segment calculator font...
ascii chars 32..90, 16 bits per char unpacked -> 114 bytes for the whole
font ;) let's credit karl/nooon for the original idea. */

void drawseg(int y,int x,int w,int h)
{
	/* clip clip clip */
	if(x+w>BUFW)w=BUFW-x;
	if(x<0){w+=x;x=0;}
	if(y+h>BUFH)h=BUFH-y;
	if(y<0){h+=y;y=0;}
	if(w>0)if(h>0){
		char *b=ruutu+y*BUFW+x;
		for(;h;h--){memset(b,122,w);b+=BUFW;}
}	}

void drawchar(int x,int y,int c,int xunit,int yunit)
{	x-=xunit*2;
	y-=yunit*3;
	for(;;){
	if(!c)break;
	
	if(c&1)drawseg(y,x+1,        xunit*2-2,yunit);
	if(c&2)drawseg(y,x+1+xunit*2,xunit*2-2,yunit);
	y++;

	c>>=2;
	if(!c)break;

	if(c&1)drawseg(y,x,		   xunit,yunit*3-2);
	if(c&2)drawseg(y,x+((xunit*3)>>1),xunit,yunit*3-2);
	if(c&4)drawseg(y,x+xunit*3,xunit,yunit*3-2);

	y+=yunit*2;
	c>>=3;	
}}

void drawtxtscr(char*z)
{
	int x=BUFW>>4,y=BUFH>>3;
	while(*z){
		if(*z>=32){
		  drawchar(x,y,phont[*z-32],BUFW/50,BUFW/80);
		  x+=BUFW/10;
		}else{x=BUFW>>4;y+=BUFW/10;}
		z++;
}	}


void flashtxt(char*txt)
{
	int x=(BUFW>>1)-(strlen(txt)+1)*3*BUFW/80;
	while(*txt){
		drawchar(x,BUFH>>1,phont[*txt++-32],BUFW/50,BUFW/80);
		x+=BUFW/10;}
}

/*************************** DA PHONGBALL HEAVEN **************

A short course on phongball theory!

A sphere: x^2+y^2+z^2=R^2

Diffuse shading: intensity = dotproduct(surfacenormal,lightvector)

(doing this for every drawn point of the surface is sometimes called
phong shading even if the normals aren't actually interpolated)

For a sphere, a normal vector at a point of the surface == constant *
the coordinates of the point (if center == origo).

Thus, the function for the intensity of a 2d-projected phongball can be
stated as

intensity(x,y) = l.x*x + l.y*y + l.z*z, z = sqrt(R^2-x^2-y^2)

The first two muls can be eliminated easily. (and will be eliminated by
a good compiler even if you are lazy)

The third mul can be eliminated by approximating l.z*z with a function
of the form f(x)=a*x^2+c. This approximation makes the ball look a bit
"twisty" but who cares, it just looks damn cool ;) 

***/

#if BUFH<BUFW
	#define maxR (BUFH>>1)
#else
	#define maxR (BUFW>>1)
#endif

struct{int *tab;signed int R;}balltab[50];

void preball()
{
	unsigned int rR; signed int R;

	for(rR=0;rR<48;rR++){
		int R2,*d;signed int y;
		R=(maxR*(rR+4))/52;
		if(R<2)R=2;
		R2=R*R;
		balltab[rR].R=R;
		d=balltab[rR].tab=malloc(R*2*sizeof(int)); 
		for(y=-R+1;y<R-1;y++)*d++=sqrt(R2-y*y);
	}	

	balltab[49].R=balltab[48].R=balltab[47].R;
	balltab[49].tab=balltab[48].tab=balltab[47].tab;
}

/**
	The i386 innerloop compiled by gcc sucked a bit so here's another
	one. Hope it runs faster :) I tried to optimize it for the 386,
	maybe 486 (not pentium kos it suxx)

**/

inline void drawball_inloop
  (char *d,int dotxyz,int ddot,int dddot,int x)
{
#if ASMLOOPS==386

__asm__("

	movl %%edx,%%ebp

	movl %%ecx,%%eax
	andb $3,%%al
	je 1f
	cmpb $1,%%al
	je 2f
	cmpb $2,%%al
	je 3f

4:	addl %%ebx,%%ebp
	addl %%ebp,%%esi
	shldl $16,%%esi,%%eax	
	stosb

3:	addl %%ebx,%%ebp
	addl %%ebp,%%esi
	shldl $16,%%esi,%%eax
	stosb

2:	addl %%ebx,%%ebp
	addl %%ebp,%%esi
	shldl $16,%%esi,%%eax
	stosb

1:	shrl $2,%%ecx
	je 9f
	jne 8f

	.align 4

8:	addl %%ebx,%%ebp
	addl %%ebp,%%esi
	
	addl %%ebx,%%ebp
	shldl $24,%%esi,%%edx
	addl %%ebp,%%esi
	shldl $24,%%esi,%%eax

	addl %%ebx,%%ebp
	movb %%dh,%%al
	addl %%ebp,%%esi
	stosw
	shldl $24,%%esi,%%edx

	addl %%ebx,%%ebp
	addl %%ebp,%%esi
	shldl $24,%%esi,%%eax	
	movb %%dh,%%al		
	
	decl %%ecx
	stosw	
	jne 8b

9:	
"
::	"c"(x),	
	"D"(d),

	"S"(dotxyz),
	"d"(ddot),
	"b"(dddot)

:	"ax","bx","cx","dx","si","di","bp");

#else

	for(;x;x--){
	dotxyz+=ddot;
	ddot+=dddot;
	*d++=dotxyz>>16;}

#endif
}

void drawball(char *d,vec3d *l,int relR)
{
	int R=balltab[relR].R,*s=balltab[relR].tab;
	
	signed int doty=(-(R-1)*l->y);	
	signed int y=R*2-2;

	d+=(BUFW>>1)-R+((BUFH>>1)-R)*BUFW;

	if(y)for(;y;y--){
	int halfw=*s++;
	if(halfw)
		drawball_inloop(
		d+R-halfw,
	   	(doty-(l->x*halfw))<<8,	
		(l->x+l->z)<<8,	
		0-((l->z<<8)/halfw),
		halfw<<1);
	d+=BUFW;
	doty+=l->y;
}	}

/* some extra for freaks: a plasma made with the phongball innerloop :)
   looks ugly.

void drawplasma(char *d,float t)
{
	int y=BUFH; float u=0,du=500/BUFH;

	for(;y;y--){
		drawball_inloop(d,
			sin(t*0.02+0+u*0.033)*65536*256,
			cos(t*0.04+1+u*0.022)*65536*4096/BUFW,
			-2*cos(t*0.04+1+u*0.022)*65536*4096/(BUFW*BUFW), BUFW);
		d+=BUFW;
		u+=du;
	}
}
*/

/************************ oTHA FX ***************/

void rotochess(char *d,int du,int dv,int iu,int iv)
{
	int hu=iu-(dv*(BUFH>>1))-(du*(BUFW>>1)),
	    hv=iv+(du*(BUFH>>1))-(dv*(BUFW>>1));
	    
#if (ASMLOOPS==386) && (!(BUFW&3))

__asm__("

	movl %%eax,%%ebp

1:	pushl %%ecx
	pushl %%ebx
	pushl %%edx

	movl %0,%%ecx
	jmp 0f

	.align 4

0:	addl %%ebp,%%ebx
	movb %%bh,%%al
	addl %%esi,%%edx
	xorb %%dh,%%al
	
	addl %%ebp,%%ebx
	movb %%bh,%%ah
	addl %%esi,%%edx
	xorb %%dh,%%ah	

	addl %%ebp,%%ebx
	andl $0xb1b1,%%eax
	stosw
	movb %%bh,%%al
	addl %%esi,%%edx
	xorb %%dh,%%al

	addl %%ebp,%%ebx
	movb %%bh,%%ah
	addl %%esi,%%edx
	xorb %%dh,%%ah
	andl $0xb1b1,%%eax

	decl %%ecx
	stosw
	jne 0b
	
	popl %%edx
	popl %%ebx
	popl %%ecx
	
	subl %%ebp,%%edx
	addl %%esi,%%ebx
	
	decl %%ecx
	jne 1b
"
::	"m"(BUFW/4),

	"c"(BUFH),	// ecx == x
	"D"(d),	// edi == *d
	
	"b"(hu),"a"(du),
	"d"(hv),"S"(dv)
	
:	"ax","bx","cx","dx","si","di","bp");
	d+=BUFW;
#else
	int y;
	for(y=BUFH;y;y--){
	  {register int u=hu,v=hv,x=BUFW;
	  for(;x;x--){
	  u+=du;v+=dv;*d++=((u^v)>>8)&0xb1;}}
	hu+=dv;hv-=du;}	  
#endif
}

/***************************************************************/

rgb pal[256],pal2[256];
void setpal()	
{
	int i,a=3,b=0;
	for(i=255;i;i--){
		rgb*d=&pal[(i+128)&255];
		d->r=(abs(i-140)>>a)&255;
		d->g=((abs(i-128)>>b)&255)^1;
		d->b=(abs(i-96)>>b)&255;
		if(i==128){a=0;b=1;}
	}
	oxl_setpalette(pal);
}

void unitvec(vec3d *v,float a,float b,float c,float m)
{
	float cam=cos(a)*m,sam=sin(a)*m,sbcam=sin(b)*cam;
	
	v->x=cos(b)*cam;
	v->y=cos(c)*sam-sin(c)*sbcam;
	v->z=cos(c)*sbcam+sin(c)*sam;
}

/************************* MUSiC cODE **************************/

#if AUDIO

/* This table was ripped (and reduced and rudely integerized) from the
   Maube tracker by K .. keep on the good work man! ;) */

const int noterate[3*12] = {     
     1000, 1059, 1122, 1189, 1259, 1334,
     1414, 1498, 1587, 1681, 1781, 1887,
     
     2000, 2118, 2244, 2378, 2519, 2669,
     2828, 2996, 3174, 3363, 3563, 3775,
     
     4000, 4237, 4489, 4756, 5039, 5339,
     5656, 5993, 6349, 6727, 7127, 7550
};

/*	64 bytes of pure musical power ;)  
	Originally composed with Scream Tracker.  */

const char basstrak[32]={
	12,0, 24,12,
	12,24,12,24,
	12,0, 24,12,
	12,24,12,24,
	15,0, 27,15,
	15,27,15,27,
	14,0, 26,14,
	15,27,17,29};

const char melody[32]={
	24,12,19,15,
	24,0, 19,0,
	24,12,19,15,
	24,0, 15,19,
	15,19,15,19,
	22,0, 15,19,
	14,17,21,14,
	22,17,17,22};

signed int*drum0,*drum1;

void audio_precalcs()
/* sampling sucks! */
{
	int drumlgt=TIKLGT*ROWTIX*4;
	int *d=drum0=malloc(drumlgt*sizeof(int)),
	    *e=drum1=malloc(drumlgt*sizeof(int)),i,
		 vol=24680,dvol=35000/(float)drumlgt;
	int o=0,oo=0;float a=0,da=386/(float)drumlgt,dda=da/(float)drumlgt;

	printf("aCtIvATiNg 303 eMuLAtOR\n");
	
	for(i=drumlgt;i;i--){
		int u;
		
		o=(o>>1)+(rand()%vol)-(rand()%vol);		
		oo=(oo*2+((rand()%vol)-(rand()%vol)))/3;

		o*=sin(a);oo*=sin(a);

		u=o*2;if(u<-65535)u=-65535;if(u>65535)u=65535;
		*d++=(vol*sin((a/2)+((float)u)/80000));
		*e++=(vol*sin(a+((float)oo)/60000));

		a+=da;da-=dda;vol-=dvol;
}	}

int*audio_mix(void)
/* mixes the next row of music into b */
{
	static int rowno=0;
	static signed int delta=-5;
	static char ismelody=0,silend=0;
	
	int rowlgt=TIKLGT*ROWTIX,i;
	int *d=mxbuf,note;
	
		/* BASS (sawtooth ofcoz) */

	*d++=rowlgt;
	
	note=basstrak[(rowno>>1)&31];	
	
	if(!note)note=basstrak[((rowno>>1)&31)-1];
		else if(rowno&1)note=0;
	if((rowno&3)==3)note=0;
	if(note){
		int ps=16384,dps;
		note+=delta;
		dps=((noterate[note]<<10)/AUFREQ);
		for(i=rowlgt;i;i--){
			*d++=ps;ps=(ps+dps)&32767; }
	}else
		for(i=rowlgt;i;i--)*d++=16384;

		/* MELODY (sawtooth as well :) */

	if(!(silend&&((rowno&63)>47))){

	if(ismelody){
	d=mxbuf+1;
	if(rowno&1)note=0;else note=melody[(rowno>>1)&31];
	if(note){
		int ps=16384,dps;	/* this loop is different */
		note+=delta;
		dps=((noterate[note]<<12)/AUFREQ);
		for(i=rowlgt;i;i--){
 			*d+++=ps;ps=(ps+dps)&32767;}
 	}}
		/* DRUMS (rave on!!!) */

	{
		int *s=drum1;d=mxbuf+1;
		if(rowno&4)s=drum0;
		s+=(rowno&3)*rowlgt;
		
		for(i=rowlgt;i;i--)*d+++=*s++;
	}
	}
		/* PATTERN SHIFT */

	rowno++;
	
	/* no switch+case? just check out how gcc handles them!  
	   it's 1024+ bytes for every phukken switch statement!	   
	   in this case we can prefer size to speed, can't we? */

	if(!(rowno&63)){
		int r=rowno>>6;
		if(r==2)delta=0;
		if(r==4)ismelody=1;
		if((r==6)||(r==10))delta=5;
		if((r==7)||(r==11))silend=1;
		if(r==8)delta=silend=0;
		if(r==12){rowno=ismelody=silend=0;delta=-5;}
	}
	return mxbuf;	
}

#endif

/**************** tEXT gENERATORS eTC ***************/

char skrtxt[]={
"         HI THERE !  THIS IS THE FIRST OCSA RELEASE FOR LINUX !  "
"IT'S A STUPID INTRO CALLED 3X666 !          " };

void plainscroll(int t)
#define CHTIME 16
#define CHPSCR 8
{	
	int chno=t/CHTIME;
	int x=0-((t%CHTIME)*(BUFW/CHPSCR))/CHTIME;
	int h=(abs((t%48)-24)*BUFH)/256,i;
	char*c=skrtxt+chno;

	for(i=0;i<CHPSCR+1;i++){
		drawchar(x,(BUFH*3)/4,phont[*c++-32],BUFW/(6*CHPSCR),h);
		x+=BUFW/CHPSCR;
}	}

char*lyrix(void)
{
	static int phinext=0,philast;
	int phiwsty;
	char*phiword;

	phiwsty=phinext;

if(!phiwsty){
	if(!(rand()&3))phiwsty=13;
	else phiwsty=1+(rand()&1);
}
if(phiwsty==1){
	char *w[]={"HERE","THERE","NOW","TOMORROW","TODAY","NEVER"};
	phiword=w[rand()%6];
	if(rand()&1)phinext=2;else phinext=12;
}else
if(phiwsty==2){
	char nx[]={5,10,7,3,11};
	philast=rand()&1;
	if(!philast)phiword="YOU";else phiword="I";
	phinext=nx[rand()%5];
}else
if(phiwsty==3){
	char *w[]={"DON'T","CAN'T","WON'T","COULDN'T"};
	phiword=w[rand()%4];phinext=7+(rand()&4);
}else
if(phiwsty==4){
	if(rand()&1)phiword="YOU";else phiword="ME";
	if(rand()&1)phinext=6;else if(rand()&1)phinext=0;else phinext=11;
}else
if(phiwsty==5){
	if(philast)phiword="AM";else phiword="ARE";
	if(rand()&1)phinext=6;else phinext=12+(rand()&1);
}else
if(phiwsty==6){
	char *w[]={"FALLING","THINKING","DREAMING","CRYING",
	"LYING","REACHING","BREATHING","BURNING","RUNNING"};
	phiword=w[rand()%9];
	if(rand()&1)phinext=9;else if(rand()&1)phinext=0;else phinext=13;
}else
if(phiwsty==7){
	char nx[]={8,4,12};
	if(rand()&1)phiword="NEED";else phiword="WANT";
	phinext=nx[rand()%3];
}else
if(phiwsty==8){phiword="TO";phinext=11;
}else
if(phiwsty==9){
	char *w[]={"DOWN","OFF","OUT","UP","ABOUT"};
	phiword=w[rand()%5];
	if(rand()&1)phinext=rand()&4;else phinext=12+(rand()&1);
}else
if(phiwsty==10){
	char *w[]={"CAN","COULD","WOULD","MAY","MIGHT"};
	phiword=w[rand()%5];
	if(rand()&1)phinext=11;else phinext=12;
}else
if(phiwsty==11){
	char *w[]={"SEE","HEAR","FEEL","THINK"};
	phiword=w[rand()%4];
	if(rand()&1)phinext=12;else phinext=rand()&4;
}else
if(phiwsty==12){
	char *w[]={"WHAT","SOMETHING","NOTHING","THINGS","WHATEVER"};
	phiword=w[rand()%5];phinext=2;
}else
if(phiwsty==13){
	phiword="THE";phinext=14;
}else{
	char*w[]={"WAY","EYES","WORLD","ROBOT","FREEDOM","HATE"};
	phiword=w[rand()%6];phinext=0;	
}
return phiword;
}

char*dotxtscr(void)
{
	static int cnt=0;
	cnt++;
	if(cnt==1)
	return
		"WHERES THE\n"
		"DESIGN?\n\n"
		"WHERES THE\n"
		"ATTITUDE?!";
	
	if(cnt==2)
	return
		"NOTHING\n"
		"HAPPENED\n"
		"IN 1997";

	if(cnt==3)
	return
		"PERHAPS\n"
		"IT IS TIME\n"
		"FOR A NEW\n"
		"PROPHECY?";

	if(cnt==4)
	return
		"IN 1998,\n"
		"SCENE WILL\n"
		"DIE !!!!!";

	if(cnt==5)
	return		
		"PHONGBALLS\n"
		"WILL\n"
		"INVADE\n"
		"THE WORLD";

	if((cnt==6)||(cnt==7))
	return
		"HALUU OLLA\n"
		"APPELSIINI";
		
	return NULL;
}

const char*endscroll=
"THAT'S ALL
FOLKS !

ALL CODING +
COMPOSING
BY VIZNUT !

WHAT A
MARVELOUS
PALETTE !
WHAT A
SUPERB TUNE !

BUT IT'S ALL
BELOW 10 KB
AND RUNS
SMOOTHLY ON
A 386

GREETINGS TO
ALL THE
LINUX SCENE !

LET'S MAKE
THIS WORLD A
BETTER PLACE
TO LIVE IN !

THIS IS JUST
A PIECE OF
SHITTY CODE
BUT IT'S ALL
YOURS !

RIP OFF
EVERYTHING !
USE IT FOR
SOMETHING
CREATIVE !
"

"\n\n\nOCSA 1998";

void doendscroll(int t)
{
	const char *s=endscroll;
	int y=BUFH-(BUFH*t/512),x=BUFW/24;

	while(*s){
		if(*s<32){x=BUFW/24;y+=BUFH/8;}else{
		if(y>=0-(BUFH/8))if(y<BUFH){
			drawchar(x,y,phont[*s-32],BUFW/60,BUFH/60);
			x+=BUFW/13;}
		}
	s++;}
}

/********************** tHA kORE bEGiNS *********************/

#define BLACKBG   1
#define FLASHBG   2
#define OCSALOGO  4
#define SCROLL0   8
#define BALLIE    16
#define BALLJUMPS 32
#define COUNTAH   64
#define CHESSBG   128
#define PLASMABG  256
#define FLASHTXT  512
#define TXTSCR    1024
#define ENDSCR    2048
#define DEMOEND   4096

const short dezign[]={
	0,	 BLACKBG|OCSALOGO|SCROLL0,
	256,FLASHBG|BALLIE|BALLJUMPS|COUNTAH,
	384,BLACKBG|BALLIE|BALLJUMPS|COUNTAH|OCSALOGO,
	400,BLACKBG|BALLIE|COUNTAH|OCSALOGO,
	416,BLACKBG|BALLIE,
	448,BLACKBG|BALLIE|TXTSCR,
	512,CHESSBG|BALLIE|BALLJUMPS|TXTSCR,
	576,CHESSBG|BALLIE|BALLJUMPS|TXTSCR,
	640,CHESSBG|BALLIE|BALLJUMPS|TXTSCR,
	704,CHESSBG|BALLIE|BALLJUMPS|TXTSCR,
	768,FLASHBG|FLASHTXT,	
	896,FLASHBG|FLASHTXT|TXTSCR,
	962,FLASHBG|FLASHTXT|TXTSCR|BALLIE|BALLJUMPS,
	1024,BLACKBG|BALLIE|ENDSCR,
	1152,CHESSBG|BALLIE|BALLJUMPS|ENDSCR,
	1344,FLASHBG|BALLIE|BALLJUMPS|ENDSCR,
 	1536,DEMOEND
};


/* don't look at the rest of the code, it just sucks :) */

void main(void)
{
	vec3d joo;

	int flagz=0;const short*dez=dezign;
	char *phiword=NULL,*dizainword=NULL;int flixtim=0;

	ruutu=malloc(BUFH*BUFW*sizeof(char));	
	preball();

	srand((int)time(NULL));

#define MAXROWLGT TIKLGT*ROWTIX
 
#if AUDIO!=0
	oxl_init_audio(ROWTIX);
	TIKLGT=AUFREQ/DEMOHZ;
	mxbuf=malloc(MAXROWLGT*sizeof(int));
	audio_precalcs();
#endif

	oxl_init_video();
	oxl_init_timer();

	setpal();
	
	for(;;){
	int t=oxl_timer();

	while((t/ROWTIX>=*dez)&&(!(flagz&DEMOEND)))
		{dez++;flagz=*dez++;
		 if(flagz&FLASHTXT)flixtim=*(dez-2); 
		 if(flagz&TXTSCR)dizainword=dotxtscr();
		 }
	if(flagz&FLASHTXT)
	  while((t/ROWTIX)>=flixtim){phiword=lyrix();flixtim+=4;}

	if(flagz&DEMOEND)break;

	if(flagz&BLACKBG)memset(ruutu,0,BUFH*BUFW);else
	if(flagz&FLASHBG)
		{ unsigned char col=130+(t%48)*2;
		#if ASMLOOPS==386
	/* the original asm/string.h by linus does this with stosb, so */		
	__asm__("rep;stosl"::"D"(ruutu),"c"((BUFH*BUFW)>>2),
	"a"(col|(col<<8)|(col<<16)|(col<<24)):"ax","cx","di");
		#else
		memset(ruutu,col,BUFH*BUFW);
		#endif
	}

	if(flagz&CHESSBG){int zoom=((10+abs(((t>>1)%96)-48))*4096/BUFW);
		rotochess(ruutu,
		sin(t*0.03)*zoom,cos(t*0.03)*zoom,0,0);}

/*	if(flagz&PLASMABG) drawplasma(ruutu,t); */

	if(flagz&OCSALOGO){
		#define U (BUFW/40)
			drawchar(U*6,U*4,phont['O'-32],U+U*sin(t*0.10+3),U);
			drawchar(U*14,U*4,phont['C'-32],U,U+U*sin(t*0.11+3));
			drawchar(U*22,U*4,phont['S'-32],U,U+U*sin(t*0.12+3));		
			drawchar(U*30,U*4,phont['A'-32],U+U*sin(t*0.13+3),U);
		#undef U
	}
	
	if(flagz&SCROLL0)plainscroll(t);
	
	if(flagz&BALLIE){
		int zoom;
		if(flagz&BALLJUMPS)zoom=abs((t%96)-48);else zoom=47;
		if(zoom<0)zoom=0;else if(zoom>47)zoom=47;
		
		unitvec(&joo,0.038*t,0.023*t,0.011*t,32000/balltab[zoom].R);
		joo.z<<=1;
		
		drawball(ruutu,&joo,zoom);
	}

	if(flagz&FLASHTXT)flashtxt(phiword);
	if(flagz&TXTSCR)if((t/ROWTIX)&2)drawtxtscr(dizainword);

	if(flagz&ENDSCR)doendscroll(t-1024*ROWTIX);

	#define U (BUFW/40)
	if(flagz&COUNTAH)
	  {int n=((t*50/48)-256*6);
	  int dis=(rand()%U)>>1;
	  if(n>666)n=666;
	  if(n>600){
	  	drawchar(U*12+dis,(BUFH>>1)+dis+U*6,phont['X'-32],U,U);
	  	drawchar(U*22+dis,(BUFH>>1)+dis+U*6,phont['3'-32],U,U);}		
		drawchar(U*28+dis,BUFH>>1,phont[16+(n%10)],U,U);n/=10;
		drawchar(U*18+dis,BUFH>>1,phont[16+(n%10)],U,U);n/=10;
		drawchar(U*8+dis,BUFH>>1,phont[16+(n%10)],U,U);n/=10;
	}	
	#undef U
	
	/* blitzz */
	
		oxl_doframe(ruutu);
	#if AUDIO!=0
		oxl_doaudio(audio_mix);
	#endif
		while(t==oxl_timer()){
		#if SLEEPY
			usleep(250000/DEMOHZ);
		#endif
		}
	}
	oxl_end();
}
