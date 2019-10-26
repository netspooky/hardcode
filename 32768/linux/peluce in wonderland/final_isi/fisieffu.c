#include "wrapper.h"

#include "fisi.h"

/* #include "dos.h" */

#define uchar unsigned char
#define uint unsigned int
#define sint signed int

#include "sini.h"

extern void waitretrace();
extern signed int mul32(signed int a,signed int b);

/*************** setup *******************/

      char setup_rtc=1;
      char setup_force25=0;
      char setup_nohibit=0;

/*************** multimedia interface **********/

      char buffclass;   /* preparebuff == setmode etc */

      int bgcol=0;
      int txtcol=0;
      int ansifrom=0;

      /*************/

      char fx_main=0;
      char fx_main_spex=0;
      char fx_3d=0;
      char fx_flare=0;

      /*************/

uchar txl[6][20];

/*************** cOnstANTZ eTC *************/

#ifdef MSDOS
  char FAR *ruutu = (char *) 0xb8000000;
  #define   monoruutu (char*)0xb0000000;
#else
  uchar ruutu__[80*25*2];
  uchar*ruutu=ruutu__;
#endif

uchar symtab[50][80];
uchar videobuf[80*50];  /* 80x50! */
uchar textbuf[80*50];
uchar ansibuf[80*25*2];   /* 80x25! */
/*char xorru[120*75];*/
uchar*abb=ansibuf;
uchar*txb=textbuf;
uchar*vib=videobuf;

/*********/

/***************.: STATiK dEMO mAiNLOOP eT sETUppES :.******************/

extern int taimeri;

setmono() {
  #ifdef MSDOS
    ruutu=monoruutu;
  #endif
}

/******************.: tABLES, pRECALX :.*********************/

char fadetab[256];            /* fadetaulu on ihan hY™DYKE */
fadetab_make(char *ft)
{
      int s;char d;
      for(s=0;s<256;s++){
      switch(s&0x88){
	    case(0x88):d=s&~8;break;              /* 99 -> 91 */
	    case(0x80):d=(s&0x70)|(s>>4);break;   /* 91 -> 19 */
	    case(0x08):if(s&0xf0)d=((s&7)<<4)|(s&7);
		       else d=(s&7)<<4; break;	  /* 19 -> 11 */
						  /* 09 -> 10 */
	    case(0x00):
		  if((s&0xf0)&&(s&0x0f))d=s&0xf0; /* 11 -> 10 */
		  else d=s>>4;                    /* 10 -> 01 */
            break;
      }
      *ft++=d;}
}

uchar sqrt[256];
sqrt_make()
{
      uint l=0,l2=0,sq;       /* m„„rjoukko: 0..255 */
			      /* arvojoukko: 0..255 (=<<8) */
      for(;l<256;l++){
            sq=(l*l)>>8;
	    while(l2<=sq) sqrt[l2++]=l;
      }
      while(l2<=255) sqrt[l2++]=255;
}

/************************ xORRUTUS *************************/

/************************* TUNNELZ ************************/
/************************* TUNNELZ ************************/
/************************* TUNNELZ   etc ******************/

char lenssprite[256]={
0x00,0x00,0x00,0x00,0x00,0x88,0xff,0xff,0xff,0xff,0x88,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,
0x00,0x00,0xff,0xff,0xff,0xff,0x77,0x88,0x88,0x77,0xff,0xff,0xff,0xff,0x00,0x00,
0x00,0xff,0xff,0xff,0x77,0x00,0x00,0x00,0x00,0x00,0x00,0x77,0xff,0xff,0xff,0x00,
0x88,0xff,0xff,0xff,0x88,0x00,0x00,0x00,0x00,0x00,0x00,0x88,0xff,0xff,0xff,0x88,
0xff,0xff,0xff,0x77,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x77,0xff,0xff,0xff,
0xff,0xff,0xff,0x88,0x00,0x00,0x00,0x88,0x88,0x00,0x00,0x00,0x88,0xff,0xff,0xff,
0xff,0xff,0xff,0x88,0x00,0x00,0x00,0x88,0x88,0x00,0x00,0x00,0x88,0xff,0xff,0xff,
0xff,0xff,0xff,0x77,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x77,0xff,0xff,0xff,
0x88,0xff,0xff,0xff,0x88,0x00,0x00,0x00,0x00,0x00,0x00,0x88,0xff,0xff,0xff,0x88,
0x00,0xff,0xff,0xff,0x77,0x00,0x00,0x00,0x00,0x00,0x00,0x77,0xff,0xff,0xff,0x00,
0x00,0x00,0xff,0xff,0xff,0xff,0x77,0x88,0x88,0x77,0xff,0xff,0xff,0xff,0x00,0x00,
0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x77,0xff,0xff,0xff,0xff,0x77,0x00,0x00,0x00,0x00,0x00
};


/*
symtab_tunnel()
{
	int x,y;
	uchar*d=symtab[0];
	for(y=0;y<50;y++)
	for(x=0;x<80;x++){
		sint r=(x-40)*(x-40)+(y-25)*(y-25);
		*d++=sqrt[r/10];
	}
}

uchar tunxlat[4*16]={
      0x00,0x00,0x00,0x00,
      0x01,0x01,0x10,0x10,
      0x11,0x11,0x11,0x19,
      0x19,0x91,0x99,0xff,

      0x00,0x08,0x80,0x88,
      0x87,0x78,0x77,0x7f,
      0xff,0xff,0xff,0xff,
      0xfe,0xef,0xee,0xe6,

      0x00,0x00,0x00,0x00,
      0x02,0x02,0x20,0x20,
      0x20,0x22,0x22,0x22,
      0x2a,0x2a,0xa2,0xa2,

      0x00,0x08,0x80,0x88,
      0x87,0x78,0x77,0x7f,
      0xff,0xff,0xff,0xff,
      0xfe,0xef,0xee,0xe6,
      };


xorrutab()
{
	int x,y;
	uchar*d=xorru;
	for(y=0;y<75;y++)
	for(x=0;x<120;x++){
		char joo;
		sint r=(x-60)*(x-60)+(y-37)*(y-37);
		r=sqrt[r/20];
		joo=tunxlat[(r>>3)&15];
		if(r&16)joo^=0xcc;
		*d++=joo;
	}
}

do_xorru(int t)
{
	sint x,y,zoom,q=t/6;
	uchar*s0,*s1;
	uchar*d=videobuf;

	x=sini[t&255];y=sini[(t+64)&255];
	x=20+(x/4);y=12+(y/10);
	s0=xorru+x+120*y;

	x=sini[(-t+q+128+47)&255];y=sini[(-t+q+128+64+22)&255]*zoom;
	x=20+(x/4);y=12+(y/10);
	s1=xorru+x+120*y;

	xorrase(s0,s1,videobuf,bgcol);
}

char paletti[255];

dotunneltxt(int t)
{
	int i,j=0;uchar*d=paletti;
	for(i=64;i;i--){
		j+=i+192;
		*d++=fadetab[tunxlat[((t+(j>>6))>>4)&63]|bgcol];
	}
	for(i=192;i;i--){
		j+=i;
		*d++=tunxlat[((t+(j>>6))>>4)&63]|bgcol;
	}
}
*/

/*
tunxshl()
{
	int l;
	for(l=0;l<16;l++) tunxlat[l]<<=1;
}
*/

/*        ^^3   ^^2  */


/******************.: eFFECTZ hANDLER :.*********************/

char wirez[16]={
        ' ', '¼', 'È', 'Í', '»', 'º', 'Î', 'É',
        'É', 'Î', 'º', '»', 'Í', 'È', '¼', ' ' };

char zbpalli[]={
      0x00,0x01,0x10,0x11,0x13,0x31,0x33,0x3c,0xc3,0xcc,0xcf,0xfc,0xff};

int fps=0,framez,lasttik=0;

preparebuff(int c)
{
      if(c!=buffclass)
      switch(c){
	case(NONE):case(HYBRID):txtmode(0);
		memfill(ruutu,0x0000,80*25*2);
		memfill(ansibuf,253,80*25*2);
		break;

	case(SINGLE):
                txtmode(1-setup_force25);
                if(!setup_force25)memfill(ruutu,176+256*176,80*50*2);
			     else memfill(ruutu,223+256*223,80*25*2);
		break;
      }
	buffclass=c;
}

/*
txtmode(int c)
{
  #ifdef MSDOS
      _AX=0x0003;_BX=0;geninterrupt(0x10);
      _AX=0x1003;_BX=0;geninterrupt(0x10);
      if (c){_AX=0x1112;_BX=0;geninterrupt(0x10);}
  #else
  #endif
}
*/

/**********************************/

framekey o0[7]={
      40*32,40*32,1024,  /* OX */
      25*32,25*32,1024,  /* OY */
      25000,25000,1024,  /* OZOOM */
      0,0,1024,          /* OROT */

      25*256,25*256,4096,/* OHGT */
      0*256,0*256,4096,/* OFLX */
      0*256,0*256,4096 /* OFLY */
};

char ltcols[]={
      0x00,
      0x00,
      0x00,
      0x80,
      0x00,
      0x08,
      0x88,
      0x88,
      0x87,
      0x78,
      0x77,
      0x87,
      0x7e,
      0xe7,
      0xe6,
      0xee,
      0xef,
      0xfe,
      0xf7,
      0xff,
      0xff,
      0xff,
      0xff
};

uchar*ltloc;
doltsrc(char*b,int x,int y,int lev)
{
      int i;char*tmp;
      x+=40;y+=25;
      b+=x+y*80;ltloc=b;

      *b=0xff;

      tmp=b;
      i=lev;if(i>x-1)i=x-1;
            if(i>0)
            while(i--){tmp--;*tmp|=ltcols[i+(rand()&3)];}
      tmp=b;
      i=lev;if(i>79-x)i=79-x;
            if(i>0)
            while(i--){tmp++;*tmp|=ltcols[i+(rand()&3)];}

      tmp=b;
      i=lev;if(i>y-1)i=y-1;
            if(i>0)
            while(i--){tmp-=80;*tmp|=ltcols[i+(rand()&3)];}

      tmp=b;
      i=lev;if(i>49-y)i=49-y;
            if(i>0)
            while(i--){tmp+=80;*tmp|=ltcols[i+(rand()&3)];}
}

/********************************************/

psetpic(char *buf, char *pic, sint x, sint y, int xsize, int ysize,int method)
{
      sint xstart=0,ystart=0,xclip=xsize,yclip=ysize;
      x-=(xsize>>1);y-=(ysize>>1);

      if (x>=0-xsize) if (x<=80+xsize)
      if (y>=0-ysize) if (y<=50+ysize){

      if (x<0){xstart=0-x;xclip-=xstart;x=0;}
      if (y<0){ystart=0-y;yclip-=ystart;y=0;}

      if (x+xclip>79) xclip-=abs((x+xclip)-79);
      if (y+yclip>49) yclip-=abs((y+yclip)-49);

      if (xclip>0) if (yclip>0)
      picmov(pic+xsize*ystart+xstart,
             buf+y*80+x,
             xsize,xclip,yclip,method);
}}

char lensb[256],lensg[256],lensr[256];

lflare_do(signed int x,signed int y)
{
	if(abs(x)<40*4)if(abs(y)<25*4)
	if(*ltloc==0xff){
	    doltsrc(videobuf,(x+(rand()&1)) >>2,(y+(rand()&1)) >>2,20);
	    psetpic(videobuf,lensr,40-(x>>3),25-(y>>3),16,16,1);
	    psetpic(videobuf,lensb,40-(x>>2),25-(y>>2),16,16,1);
	    psetpic(videobuf,lensg,40-(x>>1),25-(y>>1),16,16,1);
        }
}

flarez_init()
{
	char*s=lenssprite;
	char*d0=lensb,*d1=lensg,*d2=lensr;
	int i;
	for(i=256;i;i--){*d0++=*s&0x9c;
	*d1++=*s&0x9a;*d2++=*s++&0xec;}
}


do3ddezign(int tskip)
{
      int i;
      for(i=0;i<7;i++){
            o0[i].curr+=
            tskip*mul32(o0[i].targ-o0[i].curr,o0[i].frac);
      }

      if(o0[OZOOM].curr>100)eggine_do(videobuf,o0[OROT].curr&255,
      o0[OZOOM].curr,o0[OX].curr,o0[OY].curr);
}

precalx()
{
/*      cprintf("cREATiNG!!! ");*/
	fillbuf(textbuf,0,80*50);
      eggine_init();
      flarez_init();
}

effu(int t)
{
      static int lastt=0;
      char*ggg;
      if (setup_rtc) retracecheck();

      switch(buffclass){
	    case(SINGLE):
	       #ifdef MSDOS
		  if(!setup_force25)
	       #endif
			if(txtcol)
                                attr2dump(textbuf,videobuf,ruutu+1,
					80*50,txtcol);
			else
				attrdump(videobuf,ruutu+1,80*50);
		#ifdef MSDOS
		  else{
			int z=0xf0f0;if(setup_nohibit)z=0x7070;
			if(!txtcol)
			dump16(videobuf,ruutu,z);else
			dump216(textbuf,videobuf,ruutu,txtcol,z);
		  }
		#endif
		  break;

	    case(HYBRID):
                if(ansifrom)ggg=ansibuf;else ggg=textbuf;
                if(ansifrom==2)if(t&16)ggg=textbuf;
                dumphybrid(ggg,videobuf,ruutu);
		break;
      }

/*      framez++;gotoxy(1,1);textcolor(15);cprintf("%i  %i  %i  ..%i           ",taimeri,buffclass,fps,fx_3d);
      if (taimeri>lasttik+70) { lasttik=taimeri;fps=framez;framez=0;}*/

      /*** EFFUEZ ***/

/*      o0[OFLX].curr=sini[(t/3)&255]*30;
      o0[OFLY].curr=sini[(t+64)&255]*30;*/

      if (buffclass){
	int c=bgcol;
	if(buffclass==1)c*=0x101;

	/*if(fx_main==NONE)fillbuf(videobuf,c,80*50);*/

	if(fx_main==SCROLLER)scroller_do(videobuf,t,o0[OHGT].curr>>8);

        if(fx_flare)
	    doltsrc(videobuf,o0[OFLX].curr>>8,o0[OFLY].curr>>8,10);
	if(fx_3d)do3ddezign(t-lastt);
	if(fx_flare)lflare_do(o0[OFLX].curr>>6,o0[OFLY].curr>>6);
	    }
     /**************/


        lastt=t;
}

/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/
/*****************************************/

