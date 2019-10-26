/*
    Implementation of CoolAPI Mac-version.

    Very crude, made just to get Anataus 6 ported. Partially based on
    Anton Kirczenov's PPC-Mac tutorial: http://www.sfu.ca/~akirczen/PPCDC/

    Created: 19.1.2000
    Updated: 19.1.2000

    -Marq
*/

#include <string.h>

/*  Mac specific includes   */
#include <QuickTimeComponents.h>
#include <Quickdraw.h>
#include <QDOffscreen.h>

#include "cool_gfx.h"
#include "gfx_mac.h"
#include "blit32.h"

static int  scr_rowlen, /*  Screen row length (in bytes)        */
            scr_lines,  /*  Screen buffer height                */
            scr_inc=1,  /*  Lines to jump at a time             */
            buf_rowlen, /*  User buffer row length (in pixels)  */
            buf_lines,  /*  User buffer height                  */
            raster=0;   /*  1 for raster modes                  */

static void *scr_addr;  /*  Framebuffer address                 */

static Ptr  oldscreen;  /*  MacOS screen pointer                */

static short    olddepth;   /*  MacOS screen depth              */

QDGlobals   qd;         /*  Quickdraw globals must be defined   */

int gfx_init(int mode,int special)
{
    switch(mode)
    {
        case GFX_320x240x32:    return(mac_init(320,240,16,special));
        default:                return(GFX_ERR_MODE);
    }
}

int mac_init(int x,int y,int depth,int special)
{
    short   x_size=x,
            y_size=y;

    GDevice **maindevice;   /*  Mac specific    */
    OSErr   err;
    PixMap  mainpixmap;

    long    response;

    raster=0;   /*  Default values  */
    scr_inc=1;
    buf_rowlen=x;
    buf_lines=y;

    /*  Init ToolBox                */
    InitGraf(&qd.thePort);
    InitFonts();

    /*  Check QT version (>= 2.1)   */
    Gestalt('qtim', &response);
    if (response < 0x02100000)
        return(GFX_ERR_EXT);

    /*  Double res for lowres modes  */
    if(x<640 && y<480)
    {
        x_size*=2;
        y_size*=2;

        blit32_init(BLIT_15_DOUBLE);
        scr_inc=2;
        raster=1;
        scr_rowlen=x*2*2;   /*  Jerky...    */
        scr_lines=y*2;
    }
    else
    {
        blit32_init(BLIT_15);
        raster=0;
        scr_rowlen=x*2;     /*  Jerky...    */
        scr_lines=y;
    }

    /*  Switch resolution with QT   */
    err=BeginFullScreen(&oldscreen,0,&x_size,&y_size,0,0,0);
    if(err!=noErr)
        return(GFX_ERR_MODE);

    /*  Get & save old depth    */
    maindevice=GetMainDevice();
    mainpixmap=**((**maindevice).gdPMap);
    olddepth=mainpixmap.pixelSize;

    /*  Set depth to 16 bits (jerky)    */
    if(!HasDepth(maindevice,16,0,0))
    {
        EndFullScreen(oldscreen,0);
        return(GFX_ERR_MODE);
    }
    if(SetDepth(maindevice,16,0,0)!=noErr)
    {
        EndFullScreen(oldscreen,0);
        return(GFX_ERR_MODE);
    }

    /*  Get the framebuffer address */
    maindevice=GetMainDevice();
    mainpixmap=**((**maindevice).gdPMap);
    scr_addr=(void *)mainpixmap.baseAddr;

    /*  Clear screen */
    memset(scr_addr,0,2*(long)x_size*(long)y_size);

    HideCursor();   /*  Mouse pointer off   */

    return(GFX_OK);
}

int gfx_blit(unsigned *buffer)
{
    int     n;

    unsigned char   *scr=scr_addr;  /*  To ease the calculations    */

    for(n=0;n<scr_lines;n+=scr_inc)
        blit32_blit(&scr[n*scr_rowlen],&buffer[n*buf_rowlen/scr_inc],
                    buf_rowlen,scr_rowlen,0);
}

int gfx_exitevent(void)
{
    if(Button())    /*  If mouse pressed then exit  */
        return(1);
    else
        return(0);
}

/*  Returns to MacOS screen  */
void gfx_close(void)
{
    GDevice **maindevice;

    EndFullScreen(oldscreen,0);
    maindevice=GetMainDevice();
    SetDepth(maindevice,olddepth,0,0);
    ShowCursor();
}

/*  EOS */
