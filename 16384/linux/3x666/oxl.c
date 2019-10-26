/*** OCSALiB 0.0.1alpha -- see oxl.h ***/

#include "config.h"

#if VIDEO==vga
	#include "vga.h"
#endif
#if VIDEO==X11
	#include "X11/Xlib.h"
	#include "X11/Xutil.h"
#endif

#if AUDIO
	#include "sys/soundcard.h"
	#include "sys/ioctl.h"
#endif

#include "stdio.h"
#include "stdlib.h"
#include "fcntl.h"
#include "unistd.h"
#include "malloc.h"
#include "time.h"
#include "sys/time.h"

#ifdef __linux__
#include "linux/string.h"
#else
#include "string.h"
#endif

#define DEMOHZ 100

int TIKLGT;

typedef struct { int r,g,b; } rgb;

/*** gLOBAL vARS ***/

int AUFREQ=OUTFREQ;

#if AUDIO==1
	int devdsp;
	char *audiobuf;
#else
	int baseclock;
#endif

#if VIDEO==vga
	int SCRH,SCRW;
#endif

#if VIDEO==X11
	Display *oxl_disp;
	Visual *oxl_vis;
	GC oxl_gc;
	int oxl_win,oxl_scr;
	Colormap oxl_pal;
	XImage *oxl_im;
	XColor oxl_col[256];
#endif

void oxl_init_video()
{
	printf("oxl: buffer size = %ix%ix8bit\n",BUFW,BUFH);

#if VIDEO==vga
{	int i,fit=0,fitw=9999,fith=9999;
	vga_modeinfo*inf;
	
	if(vga_init()){printf("oxl: can't init svgalib!\n");exit(0);}

	/* Finds the best-fitting 256-color videomode */
	for(i=0;i<GLASTMODE;i++){
		if(vga_hasmode(i)){
			inf=vga_getmodeinfo(i);
		   if((inf->colors==256)&&
			   (inf->width >=BUFW)&&(inf->height>=BUFH)&&
			   (inf->width <=fitw)&&(inf->height<=fith)){
			 	fith=SCRH=inf->height;
				fitw=SCRW=inf->width;
				fit=i;
	}	}	}

	if(!fit){
		printf("oxl: no suitable modes found.\n");exit(0);}
	else{
		printf("oxl: using %s\n",vga_getmodename(fit));
		vga_setmode(fit);
	}
}
#endif	

#if VIDEO==X11
{	XSetWindowAttributes att;
	Window rtwin;

	/* get some pointers'n'stuff */
	if(!(oxl_disp=XOpenDisplay(NULL))){
		perror("oxl: can't open X display!\n");exit(0);}
	oxl_scr=DefaultScreen(oxl_disp);
	oxl_gc=DefaultGC(oxl_disp,oxl_scr);
	oxl_vis=DefaultVisual(oxl_disp,oxl_scr);
	
	rtwin=DefaultRootWindow(oxl_disp);

	/* don't store the contents */
	att.backing_store=NotUseful;

	/* allocate a private colormap */
	oxl_pal=XCreateColormap(oxl_disp,rtwin,oxl_vis,AllocAll);
	att.colormap=oxl_pal;

	/* a black emptiness replaces the cursor */
	{XColor blk;Pixmap e;
	blk.red=blk.green=blk.blue=0;
	blk.flags=DoRed+DoGreen+DoBlue;
	e=XCreatePixmap(oxl_disp,rtwin,2,2,1);	
	att.cursor=XCreatePixmapCursor(oxl_disp,e,e,&blk,&blk,0,0);}

	oxl_win=XCreateWindow(
		oxl_disp,rtwin,
		0,0,BUFW,BUFH,4,
		8,	/* colordepth */
		InputOutput,
		oxl_vis,
		CWBackingStore+CWColormap+CWCursor,&att);

	/* tell the wm you can't resize it */
	{XSizeHints shints;
	shints.min_width= shints.max_width= BUFW;
	shints.min_height=shints.max_height=BUFH;
	shints.flags=PMinSize+PMaxSize;
	
	/* set the names etc */
	XSetStandardProperties(
		oxl_disp,oxl_win,
		WINNAME,WINNAME,
		None,NULL,0,
		&shints);
	}

	/* and draw the window */
	XMapWindow(oxl_disp,oxl_win);
	XSync(oxl_disp,False);

	/* create the ximage to be hooked on the frame buffer */
	oxl_im=XCreateImage(oxl_disp,oxl_vis,
		8,ZPixmap,  /* depth, format */
		0,NULL,     /* offset, data */
		BUFW,BUFH,  /* width, height */
		32,BUFW);   /* align bits, bytes per scanline */
	oxl_im->bitmap_unit=32;		
	
	/* some values for the palette */
	{int i;
	for(i=0;i<256;i++){
		oxl_col[i].flags=DoRed|DoGreen|DoBlue;
		oxl_col[i].pixel=i;
		oxl_col[i].pad=0;
	}}
}
#endif
}

void oxl_init_audio(int rowtix)
{
#if AUDIO==1
	int tmp;
	printf("oxl: initing oss..\n");

	devdsp=open("/dev/dsp",O_WRONLY|O_NDELAY,0);
	ioctl(devdsp,SNDCTL_DSP_SPEED,&AUFREQ);
	
	tmp=(NUMFRAGS<<16)|FRAGSIZE;
	ioctl(devdsp,SNDCTL_DSP_SETFRAGMENT,&tmp);
	ioctl(devdsp,SNDCTL_DSP_SYNC,0);
	
	tmp=0;ioctl(devdsp,SNDCTL_DSP_STEREO,&tmp);	/* mono */	
	tmp=8;ioctl(devdsp,SNDCTL_DSP_SAMPLESIZE,&tmp);	/* 8*/

	audiobuf=malloc((rowtix*AUFREQ/DEMOHZ)*sizeof(char));
#endif
}

#if AUDIO==0
int klok()	/* just an internal clumsie */
{
	struct timeval tym;
	gettimeofday(&tym,NULL);
	return (tym.tv_sec*DEMOHZ)+(tym.tv_usec*DEMOHZ/1000000);
}
#endif

void oxl_init_timer()
{
#if AUDIO==0
	baseclock=klok();
#endif
}

void oxl_end()
{
/* These things should be done automatically on exit but
   let's put them here anyway :) */

#if AUDIO==1
	close(devdsp);
#endif

#if VIDEO==vga
	vga_setmode(TEXT);
#endif

#if VIDEO==X11
	XCloseDisplay(oxl_disp);
#endif
}

int oxl_timer()
{
#if AUDIO==1
	count_info p;
	ioctl(devdsp,SNDCTL_DSP_GETOPTR,&p);
	return p.bytes/TIKLGT;
#else
	return (klok()-baseclock);
#endif
}

void oxl_doaudio(int*(*player)(void))
{
#if AUDIO==1
	audio_buf_info a;
	
	for(;;){
	ioctl(devdsp,SNDCTL_DSP_GETOSPACE,&a);
	if(a.fragments<a.fragstotal/2) break;

	{register int i,*s=(*player)(); /* output 8bit	*/
	int lgt=*s++;char*d=audiobuf;
	for(i=lgt;i;i--){
		int x=*s++>>8;
		if(x<0)x=0;else if(x>255)x=255;
		*d++=x;
		}
	write(devdsp,audiobuf,lgt);
	}	
	}
#endif
}

void oxl_setpalette(rgb*pal)
{
#if VIDEO==vga
	int *p=(int*)pal,*c;int pp[256*3],i;c=pp;
	for(i=256*3;i;i--)*c++=*p++>>2;
	vga_setpalvec(0,256,pp);
#endif 

#if VIDEO==X11
{	int i;
	rgb*p=pal;XColor *c=oxl_col;
	for(i=256;i;i--){
		c->red=(p->r<<8);
		c->green=(p->g<<8);
		c->blue=(p->b<<8);
		c++;p++;
	}
	XStoreColors(oxl_disp,oxl_pal,oxl_col,256);
}
#endif
}

void oxl_doframe(char *vscr)
{
#if VIDEO==vga
	int y0=(SCRH-BUFH)>>1;
	
	#if VGARETRACE==1
	vga_waitretrace();
	#endif

	if(SCRW==BUFW)
 	  vga_drawscansegment(vscr,0,y0,BUFW*BUFH);
	else
	{
	 int y;char *s=vscr;int x0=(SCRW-BUFW)>>1;
	 for(y=y0;y<y0+BUFH;y++){vga_drawscansegment(s,x0,y,BUFW);s+=BUFW;}
	}
#endif

#if VIDEO==X11 
	oxl_im->data=vscr;
	XPutImage(oxl_disp,oxl_win,oxl_gc,oxl_im,-1,-1,0,0,BUFW,BUFH);
	XSync(oxl_disp,False);
#endif
}
