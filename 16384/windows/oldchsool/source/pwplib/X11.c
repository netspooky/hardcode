/*** HEADERS **********************************************/

#include "config.h"

#ifdef DRIVE_X11

#include "pwplib.h"

#include <string.h>
#include <malloc.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>

#ifdef DRIVE_X11SHM
#  include <sys/ipc.h>
#  include <sys/shm.h>
#  include <X11/extensions/XShm.h>
#endif

#define PWP_XWINNAME "pwplib"

#define BUFFSIZE(w,h,d) ( (((d)+7)>>3) *(w)*(h))

/*** INTERNAL DRIVER DATA *********************************/

struct
{
        u8*buf;
        int bufw,bufh,bufd,bpvl;

	Display *disp;
	Visual *vis;
	GC gc;
	int win,scr,rootw,dummyw;
	XImage *im;

	char*winname;
	Colormap cmap;
	XColor cols[256];

#ifdef DRIVE_X11SHM
		XShmSegmentInfo ssi;
#endif
	struct{
		int w,h;
	}savedmode;

	struct{
		int useXShm;
	}opt;

	u32 lookup[256];
}pwp_X11;

/*** SMALL API FUNX ****************************************/

void pwp_X11_setpalette(int*pal,int colorcount)
{
	int*p=pal,i;XColor*c=pwp_X11.cols;
	for(i=colorcount;i;i--){
		c->red=(*p++<<8);
		c->green=(*p++<<8);
		c->blue=(*p++<<8);
		c++;
	}
	XStoreColors(pwp_X11.disp,pwp_X11.cmap,pwp_X11.cols,colorcount);
	XSync(pwp_X11.disp,False);
}

void pwp_X11_blit()
{
	if(!pwp_X11.opt.useXShm)
	{

/****

	if((pwp_X11.opt.interlaced)||(pwp_X11.opt.halvescans))
	{
		int y1=(frame&1)<<pwp_X11.opt.halvescans,y=0,
		dy1=(1<<(pwp_X11.opt.interlaced+pwp_X11.opt.halvescans));
		for(;y<oxl.buf.vh;y++){
		XPutImage(pwp_X11.disp,pwp_X11.win,pwp_X11.gc,pwp_X11.im,
		0,y,0,y1,pwp_X11.bufw,1);
		y1+=dy1;
		}
		frame+=pwp_X11.opt.interlaced;
	}else

****/

	XPutImage(pwp_X11.disp,pwp_X11.win,pwp_X11.gc,pwp_X11.im,
	0,0,0,0,pwp_X11.bufw,pwp_X11.bufh);

	}
	else

	XShmPutImage(
		pwp_X11.disp,pwp_X11.win,pwp_X11.gc,pwp_X11.im,
		0,0,0,0,pwp_X11.bufw,pwp_X11.bufh,False);
	XSync(pwp_X11.disp,False);
}

int pwp_X11_testquit()
{
	XEvent e;
	if((XCheckMaskEvent(pwp_X11.disp,KeyPressMask|KeyReleaseMask,&e)==True)
	 ||(XEventsQueued(pwp_X11.disp,QueuedAlready)==True))
	 	return 1;else return 0;
}

/*** WINDOW SETUP FUNX *************************************/

void pwp_X11_getcolormap()
{
	int i=0;
	pwp_X11.cmap=XCreateColormap(pwp_X11.disp,pwp_X11.rootw,pwp_X11.vis,AllocAll);
	for(;i<256;i++){
		pwp_X11.cols[i].flags=DoRed|DoGreen|DoBlue;
		pwp_X11.cols[i].pixel=i;pwp_X11.cols[i].pad=0;
	}
}

void pwp_X11_openwindow()
{
	XSetWindowAttributes att;
	Pixmap empty;XColor black={0,0,0,0,0,0};

/* empty cursor */
	empty=XCreatePixmap(pwp_X11.disp,pwp_X11.rootw,1,1,1);
	att.cursor=
		XCreatePixmapCursor(pwp_X11.disp,empty,empty,&black,&black,0,0);

		att.override_redirect=False;

/* create window */
	att.backing_store=NotUseful;
	att.colormap=pwp_X11.cmap;
	pwp_X11.win=XCreateWindow(
		pwp_X11.disp,pwp_X11.rootw,
		0,0,pwp_X11.bufw,pwp_X11.bufh,0,
		pwp_X11.bufd,
		InputOutput,
		pwp_X11.vis,
		CWBackingStore|CWCursor|CWOverrideRedirect
		|((pwp_X11.bufd==8)?CWColormap:0)
		,&att);

/* some hints&props */
	{XSizeHints shints;
	shints.min_width= shints.max_width= pwp_X11.bufw;
	shints.min_height=shints.max_height=pwp_X11.bufh;
	shints.flags=PMinSize+PMaxSize;

	XSetStandardProperties(
		pwp_X11.disp,pwp_X11.win,
		PWP_XWINNAME,PWP_XWINNAME,
		None,NULL,0,
		&shints);
	}

/* and draw the window */
	XMapWindow(pwp_X11.disp,pwp_X11.win);

/* hook keypress */
	XSelectInput(pwp_X11.disp,pwp_X11.win,KeyPress|KeyRelease);

/* blank */

/*	if(pwp_X11.opt.halvescans) {
		XFillRectangle(pwp_X11.disp,pwp_X11.win,
		pwp_X11.gc,0,0,pwp_X11.bufw,pwp_X11.bufh);
	} .. not yet*/

/* ok ok */
/*	{XEvent e;
	XMaskEvent(pwp_X11.disp,KeyPressMask|KeyReleaseMask,&e);}
*/
	XSync(pwp_X11.disp,False);
}


/*** DISPLAY SETUP FUNX **************************************/

int pwp_X11_testdepth(int depth)
{
	Screen*s=ScreenOfDisplay(pwp_X11.disp,pwp_X11.scr);
	Depth*d=s->depths;int i=0;
	#ifdef DEBUG
		fprintf(stderr,"testing for depth %i\n",depth);
	#endif
	for(;i<s->ndepths;i++)
		if(d[i].depth==depth)return 1;
	return 0;
}

#ifdef DRIVE_X11SHM
int pwp_X11_ready_XShm()
{
	pwp_X11.im=XShmCreateImage(
		pwp_X11.disp,pwp_X11.vis,pwp_X11.bufd,
		ZPixmap, NULL,&pwp_X11.ssi,
		pwp_X11.bufw,pwp_X11.bufh
		);
	if(pwp_X11.im==NULL)return 0;

	pwp_X11.bufh=pwp_X11.im->height;
	pwp_X11.bufw=pwp_X11.im->width;
        pwp_X11.bpvl=pwp_X11.im->bytes_per_line;

	pwp_X11.ssi.shmid=shmget(IPC_PRIVATE,
		pwp_X11.im->bytes_per_line*pwp_X11.im->height,
		IPC_CREAT|0777);
	if(pwp_X11.ssi.shmid<0){
		XDestroyImage(pwp_X11.im);return 0;}

	pwp_X11.im->data=pwp_X11.buf=pwp_X11.ssi.shmaddr=
	shmat(pwp_X11.ssi.shmid,0,0);

	if(pwp_X11.ssi.shmaddr==(void*)-1){
		XDestroyImage(pwp_X11.im);return 0;}
	
	pwp_X11.ssi.readOnly=False;
	
	/* XSetErrorHandler. Ei tänne */

	XShmAttach(pwp_X11.disp,&pwp_X11.ssi);
	XSync(pwp_X11.disp,False);

	shmctl(pwp_X11.ssi.shmid,IPC_RMID,0);
	return 1;
}
#endif

void pwp_X11_close()
{

#ifdef DRIVE_X11SHM
	if(pwp_X11.opt.useXShm){
		XShmDetach(pwp_X11.disp,&pwp_X11.ssi);
		shmdt(pwp_X11.ssi.shmaddr);}
#endif
	XDestroyImage(pwp_X11.im);
	XDestroyWindow(pwp_X11.disp,pwp_X11.win);
}

int pwp_X11_ready()
{
/* color depth */
	if(!pwp_X11_testdepth(pwp_X11.bufd))
	{
	if(pwp_X11_testdepth(8)) pwp_X11.bufd=8;else
	if(pwp_X11_testdepth(16))pwp_X11.bufd=16;else
	if(pwp_X11_testdepth(15))pwp_X11.bufd=15;else
	{ pwpwrite("No suitable depth available (8/15/16 bpp)\n");
	  return 0;
        }
	}

	if(pwp_X11.bufd==8)pwp_X11_getcolormap();

 	pwp_X11_openwindow();

	pwp_regdestr(pwp_X11_close);

/* shared memory buffer */
	#ifdef DRIVE_X11SHM
	if(pwp_X11.opt.useXShm){
		pwp_X11.opt.useXShm=XShmQueryExtension(pwp_X11.disp);
		/* tarkista myös versiosta pixmaps==true */
	if(pwp_X11.opt.useXShm)
		if(pwp_X11_ready_XShm())return;
		else{
			pwp_X11.opt.useXShm=0;
			fprintf(stderr,"no xshm\n");}
	}
	#endif

/* noxshm */
	fprintf(stderr,
		"X11_buf: %d x %d x %d, videobuf = %d x %d, malloc: %d\n",
		pwp_X11.bufw,pwp_X11.bufh,pwp_X11.bufd,
		pwplib.videobuf.width,pwplib.videobuf.height,
		BUFFSIZE(pwp_X11.bufw,pwp_X11.bufh,pwp_X11.bufd));

	pwp_X11.buf=malloc(BUFFSIZE(pwp_X11.bufw,pwp_X11.bufh,pwp_X11.bufd));

	pwp_X11.im=XCreateImage(
		pwp_X11.disp,pwp_X11.vis,
		pwp_X11.bufd,ZPixmap,           
		0,pwp_X11.buf,
		pwp_X11.bufw,pwp_X11.bufh,
		32,BUFFSIZE(1,pwp_X11.bufw,pwp_X11.bufd));

		pwp_X11.bpvl=pwp_X11.im->bytes_per_line; /* ? */

	return 1;
}

/*
	pwp_X11.opt.useXShm=!findarg(argc,argv,"-noxshm");

	pwp_X11.opt.fullscreen=findarg(argc,argv,"-full");
*/

/**************************************************************************/

void pwp_X11_dump_rast_4x4()
{
   u32*d = (u32*)pwp_X11.buf;
   int x,y,j=0;
   u8*ss=(u8*)pwplib.videobuf.d;

   for(y=pwplib.videobuf.height*2;y;y--)
   {
      u8*s=ss;

      for(x=pwplib.videobuf.width;x;x--)
      {
         *d++=pwp_X11.lookup[*s++];
      }
      j=(j+1)&1;
      if(!j) { ss+=pwplib.videobuf.width; }
   }

   pwp_X11_blit();
}

/**********/

void rast2rgb(int n,int muller,int*r,int*g,int*b)
{
   int fg=n&15,bg=(n>>4)&15;
   const char rgb[16*3] =
   { 0,0,0,
     0,0,9,
     0,9,0,
     0,9,9,
     9,0,0,
     9,0,9,
     9,9,0,
     9,9,9,
     6,6,6,
     0,0,15,
     0,15,0,
     0,15,15,
     15,0,0,
     15,0,15,
     15,15,0,
     15,15,15 };

   *r = (muller * (rgb[bg*3+0]*2 + rgb[fg*3+0]))/45;
   *g = (muller * (rgb[bg*3+1]*2 + rgb[fg*3+1]))/45;
   *b = (muller * (rgb[bg*3+2]*2 + rgb[fg*3+2]))/45;
}

void pwp_X11_init_8bpp()
{
   int pal[256*3];
   int i=0;
   for(;i<256;i++)
   {
      rast2rgb(i,255,pal+i*3,pal+i*3+1,pal+i*3+2);
      pwp_X11.lookup[i]=(i|(i<<8)|(i<<16)|(i<<24));
   }

   pwp_X11_setpalette(pal,256);

   pwplib.dump_rast = pwp_X11_dump_rast_4x4;
}

int pwp_X11_init()
{
	if(!(pwp_X11.disp=XOpenDisplay(NULL)))
	{
	   pwpwrite("* no X11 available - trying tty\n");

	   return 0;
	}
	
	pwp_X11.scr=DefaultScreen(pwp_X11.disp);
	pwp_X11.rootw=DefaultRootWindow(pwp_X11.disp);
	pwp_X11.gc=DefaultGC(pwp_X11.disp,pwp_X11.scr);
	pwp_X11.vis=DefaultVisual(pwp_X11.disp,pwp_X11.scr);


/*
pwp_X11.opt.halvescans = 0;
pwp_X11.opt.interlace = 0;
*/

        /****/

        pwp_X11.bufw = 640;
        pwp_X11.bufh = 480;

        pwplib.videobuf.width  = 640/4;
        pwplib.videobuf.height = 480/4;

        pwp_X11.opt.useXShm = 0;

        /****/

	if(!pwp_X11_ready()) return 0;

	if(pwp_X11.bufd==8)
        pwp_X11_init_8bpp();
        else { pwpwrite("* no 8bpp available\n"); return 0; }

        pwpwrite("* X11\n");

	return 1;
}


#endif
