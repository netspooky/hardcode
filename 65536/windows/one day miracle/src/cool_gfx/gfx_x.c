/*
    Implementation of CoolAPI X11-version.

    Created: 20.5.1999
    Updated: 12.4.2000

    -Marq
*/

#include "cool_gfx.h"
#include "gfx_x.h"
#include "blit32.h"
#include <stdio.h>

#include <X11/Xlib.h>
#include <X11/keysym.h>

#ifdef X_SHM
#include <sys/ipc.h>
#include <sys/shm.h>
#include <X11/extensions/XShm.h>
#endif

#ifdef X_DGA
#include <X11/extensions/xf86vmode.h>
#include <X11/extensions/xf86dga.h>
#endif

static int  scr_rowlen, /*  Screen row length (in bytes)        */
            scr_lines,  /*  Screen buffer height                */
            scr_inc=1,  /*  Lines to jump at a time             */
            buf_rowlen, /*  User buffer row length (in pixels)  */
            buf_lines,  /*  User buffer height                  */
            raster=0,   /*  1 for raster modes                  */
            paging=0,   /*  1 if pageflipping supported         */
            page=0;     /*  Current page #                      */
#ifdef X_SHM
static int  shm=0;      /*  1 if Shm used   */
#endif

#ifdef X_DGA
static int  dga=0,      /*  1 if DGA used       */
            rowlen,     /*  Total row length    */
            banksize,
            mem,        /*  Total memory        */
            prevx,      /*  Initial resolution  */
            prevy;

static char *base;      /*  LFB address         */
#endif

                        /*  Temporary buffer for blits          */
static unsigned char    blitbuf[X_BLITMAX];

                        /* X variables (urgh)       */
static Display  *display;
static int      nscreen,widow;
static Drawable window;
static GC       gc;
static XImage   *image;
static XColor   colors[256];
static Visual   *visual;
static Colormap colormap=0;
static int      depth,pixel_size;
static XSetWindowAttributes     winatt;

#ifdef X_SHM
static XShmSegmentInfo  segment;    // Shm segment info
#endif

int gfx_init(int mode,int special)
{
    switch(mode)
    {
        case GFX_320x200x32:    return(x_init(320,200,special));
        case GFX_320x240x32:    return(x_init(320,240,special));
        default:                return(GFX_ERR_MODE);
    }
}

int x_init(int x,int y,int special)
{
    int     n,mode;

#ifdef X_DGA
    int     major,minor;
    XF86VidModeModeInfo     **modes;
    int     nmodes,lippu=-1;
#endif

    raster=paging=page=0;   /*  Default values  */
    scr_inc=1;
    buf_rowlen=x;
    buf_lines=y;

#ifdef X_SHM
    shm=0;
#endif

#ifdef X_DGA
    dga=0;
#endif

    if(special&GFX_NOASK)
    {
        mode=1;
#ifdef X_DGA
        if(special&GFX_FULL)
            mode=5;
#endif
    }
    else    /*  Prompt the user to select mode  */
    {
        printf("Internal window size: %dx%d\n",x,y);
        puts("1 - Standard X11 (Grayscale in 8-bit)");
        puts("2 - Standard X11 double pixels");

#ifdef X_SHM
        puts("3 - X11 Shm (Grayscale in 8-bit)");
        puts("4 - X11 Shm double pixels");
#endif

#ifdef X_DGA
        puts("5 - XF86 fullscreen DGA (Grayscale in 8-bit)");
        puts("6 - XF86 fullscreen DGA double pixels");
#endif
        scanf("%d",&mode);
    }

    switch(mode)
    {
        case 1:     scr_rowlen=x; scr_lines=y; break;
        case 2:     raster=1; scr_rowlen=x*2; scr_lines=y*2; scr_inc=2;
                    break;
#ifdef X_SHM
        case 3:     shm=1; scr_rowlen=x; scr_lines=y; break;
        case 4:     shm=1; raster=1; scr_rowlen=x*2; scr_lines=y*2; scr_inc=2;
                    break;
#endif

#ifdef X_DGA
        case 5:     dga=1; scr_rowlen=x; scr_lines=y; paging=1; break;
        case 6:     dga=1; raster=1; scr_rowlen=x*2; scr_lines=y*2; scr_inc=2;
                    break;
#endif
        default:    return(GFX_ERR_MODE);
    }

    display=XOpenDisplay(0);
    if(!display)
        return(GFX_ERR_MODE);

#ifdef X_SHM
    if(shm)
    {
        if(!XShmQueryExtension(display))
            return(GFX_ERR_EXT);
    }
#endif

    nscreen=DefaultScreen(display);
    visual=DefaultVisual(display,nscreen);
    gc=DefaultGC(display,nscreen);
    depth=DefaultDepth(display,nscreen);
    pixel_size=depth/8;
    if(depth==24)
	pixel_size=4;

    switch(depth)
    {
        case 8:     if(raster)
                        blit32_init(BLIT_8_RASTER_DOUBLE);
                    else
                        blit32_init(BLIT_8_GRAY);
                    break;
        case 15:    if(raster)
                        blit32_init(BLIT_15_DOUBLE);
                    else
                        blit32_init(BLIT_15);
                    break;
        case 16:    if(raster)
                        blit32_init(BLIT_16_DOUBLE);
                    else
                        blit32_init(BLIT_16);
                    break;
        case 24:    if(raster)
                        blit32_init(BLIT_32_DOUBLE);
                    else
                        blit32_init(BLIT_32);
                    break;
        case 32:    if(visual->blue_mask==0xff) /* Normal color order */
                    {
                        if(raster)
                            blit32_init(BLIT_32_DOUBLE);
                        else
                            blit32_init(BLIT_32);
                    }
                    else /* Creator3D's pervert color order */
                    {
                        if(raster)
                            blit32_init(BLIT_32_DOUBLE_PERVERT);
                        else
                            blit32_init(BLIT_32_PERVERT);
                    }
                    break;
    }

    if(depth==8)    /* Set the palette for 8-bit modes  */
    {
        if(raster)  /*  Color 8-bit */
        {
            colormap = XCreateColormap(display,DefaultRootWindow(display),visual,AllocAll);
            for(n=0;n<64;n++)
            {
                colors[n].flags=DoRed|DoGreen|DoBlue;
                colors[n].pixel=n;
                colors[n].pad=0;
                colors[n].red=65535*n/64;
                colors[n].green=0;
                colors[n].blue=0;
            }
            for(n=0;n<128;n++)
            {
                colors[128+n].flags=DoRed|DoGreen|DoBlue;
                colors[128+n].pixel=n+128;
                colors[128+n].pad=0;
                colors[128+n].red=0;
                colors[128+n].green=(n&15)*65535/15;
                colors[128+n].blue=(n>>4)*65535/7;
            }
        }
        else    /*  B/W 8-bit   */
        {
            colormap = XCreateColormap(display,DefaultRootWindow(display),visual,AllocAll);
            for(n=0;n<256;n++)
            {
                colors[n].flags=DoRed|DoGreen|DoBlue;
                colors[n].pixel=n;
                colors[n].pad=0;

                if(n<96)
                {
                    colors[n].red=65535*n/96;
                    colors[n].green=65535*n/96;
                    colors[n].blue=65535*n/96;
                }
                else
                {
                    colors[n].red=0;
                    colors[n].green=0;
                    colors[n].blue=0;
                }
            }
        }
        XStoreColors(display,colormap,colors,256);
    }

#ifdef X_DGA
    if(dga)
    {
        if(!XF86DGAQueryVersion(display,&major,&minor))
            return(GFX_ERR_EXT);

        XF86DGAGetVideo(display,nscreen,&base,&rowlen,&banksize,&mem);

        if(banksize<mem)
            return(GFX_ERR_EXT);

        if(!XF86VidModeQueryVersion(display,&major,&minor))
            return(GFX_ERR_MODE);

        XF86VidModeGetAllModeLines(display,nscreen,&nmodes,&modes);
        for(n=0,lippu=-1;n<nmodes;n++)
            if((*modes)[n].hdisplay==scr_rowlen && (*modes)[n].vdisplay==scr_lines)
                lippu=n;

        if(lippu==-1)
            return(GFX_ERR_MODE);

        prevx=(*modes)[0].hdisplay;
        prevy=(*modes)[0].vdisplay;

        XF86VidModeSwitchToMode(display,nscreen,modes[lippu]);
        XF86VidModeSetViewPort(display,nscreen,0,0);
        XFlush(display);

        XF86DGADirectVideo(display,nscreen,XF86DGADirectGraphics|XF86DGADirectMouse|XF86DGADirectKeyb);
        XGrabKeyboard(display,DefaultRootWindow(display),True,
                      GrabModeAsync,GrabModeAsync,CurrentTime);

        for(n=0;n<mem*1024;n++) /*  Clear video RAM */
            base[n]=0;

        if(depth==8)
            XF86DGAInstallColormap(display,nscreen,colormap);

        return(GFX_OK);
    }
#endif

    winatt.backing_store=NotUseful;
    winatt.colormap=colormap;

    widow=XCreateWindow(display,DefaultRootWindow(display),
                        0,0,scr_rowlen,scr_lines,4,depth,InputOutput,visual,
                        CWBackingStore+CWColormap,&winatt);

    XStoreName(display,widow,"CoolAPI in X11");
    XMapWindow(display,widow);
    XSync(display,0);

    XSelectInput(display,widow,KeyPressMask);

#ifdef X_SHM
    if(shm)
    {
        image=XShmCreateImage(display,visual,depth,ZPixmap,0,&segment,
                              scr_rowlen,scr_lines);
        image->bitmap_unit=32;

        segment.shmid=shmget(IPC_PRIVATE,image->bytes_per_line*image->height,
                             IPC_CREAT|0777);

        segment.shmaddr=image->data=shmat(segment.shmid,0,0);
        segment.readOnly=False;

        if(!XShmAttach(display,&segment))
            return(GFX_ERR_EXT);
    }
    else
    {
#endif
    image=XCreateImage(display,visual,depth,ZPixmap,0,NULL,
                       scr_rowlen,scr_lines,32,(pixel_size<3)?scr_rowlen*pixel_size:scr_rowlen*4);
    image->bitmap_unit=32;
#ifdef X_SHM
    }
#endif

    XFlush(display);
    return(GFX_OK);
}

int gfx_blit(unsigned *buffer)
{
        int     n,plus;

#ifdef X_DGA
        if(dga)
        {
            if(paging)
                plus=page*rowlen*pixel_size*scr_lines;
            else
                plus=0;

            for(n=0;n<scr_lines;n+=scr_inc)
                blit32_blit(&base[plus+n*rowlen*pixel_size],&buffer[n*buf_rowlen/scr_inc],
                        buf_rowlen,rowlen*pixel_size,0);

            if(paging)
            {
                while(!XF86DGAViewPortChanged(display,nscreen,2))
                    ;
                XF86DGASetViewPort(display,nscreen,0,page*scr_lines);
                
                page=1-page;
            }

            return(GFX_OK);
        }
#endif

#ifdef X_SHM
        if(shm)
        {
            for(n=0;n<scr_lines;n+=scr_inc)
                blit32_blit(&image->data[n*scr_rowlen*pixel_size],&buffer[n*buf_rowlen/scr_inc],
                        buf_rowlen,scr_rowlen*pixel_size,0);
            XSync(display,0);
            XShmPutImage(display,widow,gc,image,0,0,0,0,scr_rowlen,scr_lines,False);
            XFlush(display);
        }
        else
        {
#endif
        for(n=0;n<scr_lines;n+=scr_inc)
            blit32_blit(&blitbuf[n*scr_rowlen*pixel_size],&buffer[n*buf_rowlen/scr_inc],
                        buf_rowlen,scr_rowlen*pixel_size,0);

        XSync(display,0);
        image->data=(char *)blitbuf;
        XPutImage(display,widow,gc,image,0,0,0,0,scr_rowlen,scr_lines);
        XFlush(display);
#ifdef X_SHM
        }
#endif

}

int gfx_exitevent(void)
{
    XEvent  event;

    XKeyEvent *key;

    XSync(display,0);
    XFlush(display);
    while(XPending(display))
    {
        XNextEvent(display,&event);

	key=(XKeyEvent *)&event;
	if(XkbKeycodeToKeysym(display,key->keycode,0,0)==XK_Escape)
	    return(1);
    }
    return(0);
}

/*  Shuts down the graphics engine  */
void gfx_close(void)
{
#ifdef X_DGA
    int     major,minor;
    XF86VidModeModeInfo     **modes;
    int     nmodes,n,lippu=-1;

    if(dga)
    {
	XUngrabKeyboard(display,CurrentTime);
        XF86DGADirectVideo(display,nscreen,0);

        XF86VidModeGetAllModeLines(display,nscreen,&nmodes,&modes);
        for(n=0,lippu=-1;n<nmodes;n++)
            if((*modes)[n].hdisplay==prevx && (*modes)[n].vdisplay==prevy)
                lippu=n;

        if(lippu!=-1)
        {
            XF86VidModeSwitchToMode(display,nscreen,modes[lippu]);
            XFlush(display);
        }

        XCloseDisplay(display);
        return;
    }
#endif

#ifdef X_SHM
    if(shm)
    {
        XShmDetach(display,&segment);
        XDestroyImage(image);
        shmdt(segment.shmaddr);
        shmctl(segment.shmid,IPC_RMID,0);
    }
#endif

    XDestroyWindow(display,widow);
    /*if(image)
        XDestroyImage(image);
    XFreeGC(display,gc);    */
    XCloseDisplay(display);
}

/*  EOS */
